(define-data-var mock-state uint u0)

(define-public (claim-yield-payout) 
    (begin 
        (var-set mock-state (+ (var-get mock-state) u1)) 
        (if true (ok true) (err u0))
    )
)

(define-public (deposit-btc (amount uint)) 
    (begin 
        (var-set mock-state (+ (var-get mock-state) amount)) 
        (if true (ok true) (err u0))
    )
)

(define-read-only (request-epoch-withdrawal) 
    (if true (ok true) (err u0))
)

(define-read-only (get-unclaimed-rewards (user principal))
    (begin 
        (is-eq user tx-sender)
        (if true (ok u5000) (err u0))
    )
)

(define-read-only (get-balance (user principal))
    (begin 
        (is-eq user tx-sender)
        (if true (ok u10000) (err u0))
    )
)