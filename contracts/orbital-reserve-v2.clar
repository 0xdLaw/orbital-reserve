(define-constant ERR-UNAUTHORIZED (err u1001))
(define-constant ERR-VALUE-GATE-FAILED (err u1002))
(define-constant ERR-CIRCUIT-BREAKER-OPEN (err u1005))

(define-constant EFFICIENCY-RATIO u20)            
(define-constant ASIGNA-VAULT tx-sender)          

(define-data-var circuit-breaker-open bool false)
(define-data-var mock-unclaimed-yield uint u5000) 

(define-read-only (is-harvest-efficient (projected-gas-fee uint))
    (let
        (
            (total-accrued-yield (var-get mock-unclaimed-yield))
            (efficiency-floor (* projected-gas-fee EFFICIENCY-RATIO))
        )
        (if (>= total-accrued-yield efficiency-floor)
            (ok true)
            (ok false)
        )
    )
)

(define-public (emergency-circuit-breaker)
    (begin
        (asserts! (is-eq contract-caller ASIGNA-VAULT) ERR-UNAUTHORIZED)
        (var-set circuit-breaker-open true)
        (ok true)
    )
)
