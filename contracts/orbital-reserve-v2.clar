;; =========================================================================
;; PROTOCOL: ORBITAL RESERVE (V2.0) - PRODUCTION ENGINE
;; =========================================================================

(define-constant ERR-UNAUTHORIZED (err u1001))
(define-constant ERR-VALUE-GATE-FAILED (err u1002))
(define-constant ERR-TIMELOCK-ACTIVE (err u1003))
(define-constant ERR-SLIPPAGE-EXCEEDED (err u1004))
(define-constant ERR-CIRCUIT-BREAKER-OPEN (err u1005))
(define-constant ERR-INVALID-STAGE-SEQUENCE (err u1006))

(define-constant TIMELOCK-BLOCKS u2)             
(define-constant EFFICIENCY-RATIO u20)            
(define-constant SLIPPAGE-TOLERANCE-BPS u200)     

(define-constant ASIGNA-VAULT tx-sender)          

(define-data-var circuit-breaker-open bool false)
(define-data-var active-harvest-stage uint u0)   
(define-data-var buffer-liquid-usdh uint u0)    

(define-map timelock-queue (buff 32) uint)

(define-private (is-governance-auth)
    (is-eq contract-caller ASIGNA-VAULT)
)

(define-private (is-system-operational)
    (is-eq (var-get circuit-breaker-open) false)
)

(define-public (propose-governance-action (action-hash (buff 32)))
    (begin
        (asserts! (is-governance-auth) ERR-UNAUTHORIZED)
        (ok (map-set timelock-queue action-hash (+ block-height TIMELOCK-BLOCKS)))
    )
)

(define-read-only (is-harvest-efficient (projected-gas-fee uint))
    (let
        (
            (unclaimed-zest (unwrap-panic (contract-call? .zest-mock get-unclaimed-rewards tx-sender)))
            (unclaimed-hermetica (unwrap-panic (contract-call? .hermetica-mock get-unclaimed-rewards tx-sender)))
            (total-accrued-yield (+ unclaimed-zest unclaimed-hermetica))
            (efficiency-floor (* projected-gas-fee EFFICIENCY-RATIO))
        )
        (>= total-accrued-yield efficiency-floor)
    )
)

(define-public (harvest-yields (estimated-gas uint))
    (begin
        (asserts! (is-system-operational) ERR-CIRCUIT-BREAKER-OPEN)
        (asserts! (is-eq (var-get active-harvest-stage) u0) ERR-INVALID-STAGE-SEQUENCE)
        (asserts! (is-harvest-efficient estimated-gas) ERR-VALUE-GATE-FAILED)
        
        (try! (contract-call? .zest-mock claim-supply-rewards))
        (try! (contract-call? .hermetica-mock claim-yield-payout))
        
        (var-set buffer-liquid-usdh (try! (contract-call? .hermetica-mock get-balance (as-contract tx-sender))))
        (var-set active-harvest-stage u1) 
        
        (ok true)
    )
)

(define-public (compound-buffer (min-btc-expected uint))
    (begin
        (asserts! (is-system-operational) ERR-CIRCUIT-BREAKER-OPEN)
        (asserts! (is-eq (var-get active-harvest-stage) u1) ERR-INVALID-STAGE-SEQUENCE)
        
        (let
            (
                (usdh-to-swap (var-get buffer-liquid-usdh))
                (swapped-btc (unwrap! (contract-call? .bitflow-mock swap-rewards-for-btc usdh-to-swap) ERR-SLIPPAGE-EXCEEDED))
            )
            
            (asserts! (>= swapped-btc min-btc-expected) ERR-SLIPPAGE-EXCEEDED)
            (try! (contract-call? .hermetica-mock deposit-btc swapped-btc))
            
            (var-set buffer-liquid-usdh u0)
            (var-set active-harvest-stage u0)
            
            (ok swapped-btc)
        )
    )
)

(define-public (emergency-circuit-breaker)
    (begin
        (asserts! (is-governance-auth) ERR-UNAUTHORIZED)
        (var-set circuit-breaker-open true)
        (ok true)
    )
)

(define-public (evacuate-liquid-tier)
    (begin
        (asserts! (is-eq (var-get circuit-breaker-open) true) ERR-CIRCUIT-BREAKER-OPEN)
        (asserts! (is-governance-auth) ERR-UNAUTHORIZED)
        (try! (contract-call? .zest-mock emergency-withdraw-collateral))
        (as-contract (try! (contract-call? .zest-mock transfer-to-vault ASIGNA-VAULT)))
        (ok true)
    )
)
