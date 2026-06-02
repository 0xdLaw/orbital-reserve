(define-data-var mock-state uint u0)

(define-public (claim-supply-rewards) 
    (begin (var-set mock-state (+ (var-get mock-state) u1)) (ok true))
)

(define-public (emergency-withdraw-collateral) 
    (begin (var-set mock-state (+ (var-get mock-state) u1)) (ok true))
)

(define-public (transfer-to-vault (vault principal)) 
    (begin 
        (var-set mock-state (+ (var-get mock-state) u1)) 
        (ok (is-eq vault tx-sender))
    )
)

(define-read-only (get-unclaimed-rewards (user principal))
    (let ((unused-shush (is-eq user tx-sender)))
        (ok u3000)
    )
)
