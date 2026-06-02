(define-data-var mock-state uint u0)

(define-public (claim-yield-payout) 
    (begin (var-set mock-state (+ (var-get mock-state) u1)) (ok true))
)

(define-public (deposit-btc (amount uint)) 
    (begin (var-set mock-state (+ (var-get mock-state) amount)) (ok true))
)

(define-read-only (request-epoch-withdrawal) 
    (ok true)
)

(define-read-only (get-unclaimed-rewards (user principal))
    (let ((unused-shush (is-eq user tx-sender)))
        (ok u5000)
    )
)

(define-read-only (get-balance (user principal))
    (let ((unused-shush (is-eq user tx-sender)))
        (ok u10000)
    )
)
