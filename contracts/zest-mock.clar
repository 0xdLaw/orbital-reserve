(define-data-var mock-state uint u0)

(define-public (claim-supply-rewards) 
    (begin 
        (var-set mock-state (+ (var-get mock-state) u1)) 
        (if true (ok true) (err u0))
    )
)

(define-public (emergency-withdraw-collateral) 
    (begin 
        (var-set mock-state (+ (var-get mock-state) u1)) 
        (if true (ok true) (err u0))
    )
)

(define-public (transfer-to-vault (vault principal)) 
    (begin 
        (var-set mock-state (+ (var-get mock-state) u1)) 
        (if (is-eq vault tx-sender) (ok true) (err u0))
    )
)

(define-read-only (get-unclaimed-rewards (user principal))
    (begin 
        (is-eq user tx-sender)
        (if true (ok u3000) (err u0))
    )
)
