;; =========================================================================
;; PROTOCOL: ORBITAL RESERVE (V2.0) - PRODUCTION ENGINE
;; =========================================================================

(define-constant ERR_UNAUTHORIZED (err u1001))
(define-constant ERR_VALUE_GATE_FAILED (err u1002))
(define-constant ERR_SLIPPAGE_EXCEEDED (err u1004))
(define-constant ERR_CIRCUIT_BREAKER_OPEN (err u1005))
(define-constant ERR_INVALID_STAGE_SEQUENCE (err u1006))

(define-constant TIMELOCK_BLOCKS u2)             
(define-constant EFFICIENCY_RATIO u20)            

(define-constant ASIGNA_VAULT tx-sender)          

(define-data-var circuit-breaker-open bool false)
(define-data-var active-harvest-stage uint u0)   
(define-data-var buffer-liquid-usdh uint u0)    

(define-map timelock-queue (buff 32) uint)

(define-private (is-governance-auth)
    (is-eq contract-caller ASIGNA_VAULT)
)

(define-private (is-system-operational)
    (not (var-get circuit-breaker-open))
)

(define-public (propose-governance-action (action-hash (buff 32)))
    (begin
        (asserts! (is-governance-auth) ERR_UNAUTHORIZED)
        (ok (map-set timelock-queue action-hash (+ block-height TIMELOCK_BLOCKS)))
    )
)

(define-read-only (get-timelock-release-block (action-hash (buff 32)))
    (map-get? timelock-queue action-hash)
)

(define-read-only (is-harvest-efficient (projected-gas-fee uint))
    (if (and
            (not (var-get circuit-breaker-open))
                 (is-eq tx-sender ASIGNA_VAULT)
    )

     (let 
        (
            (unclaimed-zest (unwrap! (contract-call? .zest-mock get-unclaimed-rewards tx-sender) false))
            (unclaimed-hermetica (unwrap! (contract-call? .hermetica-mock get-unclaimed-rewards tx-sender) false))
            (total-accrued-yield (+ unclaimed-zest unclaimed-hermetica))
            (efficiency-floor (* projected-gas-fee EFFICIENCY_RATIO))
        )
        (>= total-accrued-yield efficiency-floor)      
    )
        false
    )
)

(define-public (harvest-yields (estimated-gas uint))
    (begin
        (asserts! (is-system-operational) ERR_CIRCUIT_BREAKER_OPEN)
        (asserts! (is-eq (var-get active-harvest-stage) u0) ERR_INVALID_STAGE_SEQUENCE)
        (asserts! (is-harvest-efficient estimated-gas) ERR_VALUE_GATE_FAILED)
        
        (unwrap! (contract-call? .zest-mock claim-supply-rewards) ERR_VALUE_GATE_FAILED)
        (unwrap! (contract-call? .hermetica-mock claim-yield-payout) ERR_VALUE_GATE_FAILED)
        
        (var-set buffer-liquid-usdh (unwrap! (contract-call? .hermetica-mock get-balance (as-contract tx-sender)) ERR_VALUE_GATE_FAILED))
        (var-set active-harvest-stage u1) 
        (ok true)
    )
)

(define-public (compound-buffer (min-btc-expected uint))
    (begin
        (asserts! (is-system-operational) ERR_CIRCUIT_BREAKER_OPEN)
        (asserts! (is-eq (var-get active-harvest-stage) u1) ERR_INVALID_STAGE_SEQUENCE)
        
        (let
            (
                (usdh-to-swap (var-get buffer-liquid-usdh))
                (swapped-btc (unwrap! (contract-call? .bitflow-mock swap-rewards-for-btc usdh-to-swap) ERR_SLIPPAGE_EXCEEDED))
            )
            
            (asserts! (>= swapped-btc min-btc-expected) ERR_SLIPPAGE_EXCEEDED)
            (unwrap! (contract-call? .hermetica-mock deposit-btc swapped-btc) ERR_SLIPPAGE_EXCEEDED)
            
            (var-set buffer-liquid-usdh u0)
            (var-set active-harvest-stage u0)
            
            (ok swapped-btc)
        )
    )
)

(define-public (emergency-circuit-breaker)
    (begin
        (asserts! (is-governance-auth) ERR_UNAUTHORIZED)
        (var-set circuit-breaker-open true)
        (ok true)
    )
)

(define-public (reset-circuit-breaker)
    (begin
        (asserts! (is-governance-auth) ERR_UNAUTHORIZED)
        (var-set circuit-breaker-open false)
        (ok true)
    )
)

(define-public (evacuate-liquid-tier)
    (begin
        (asserts! (var-get circuit-breaker-open) ERR_CIRCUIT_BREAKER_OPEN)
        (asserts! (is-governance-auth) ERR_UNAUTHORIZED)
        (unwrap! (contract-call? .zest-mock emergency-withdraw-collateral) ERR_CIRCUIT_BREAKER_OPEN)
        (unwrap! (as-contract (contract-call? .zest-mock transfer-to-vault ASIGNA_VAULT)) ERR_UNAUTHORIZED)
        (ok true)
    )
)
