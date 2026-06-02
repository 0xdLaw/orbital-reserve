(define-data-var mock-state uint u0)

(define-public (swap-rewards-for-btc (amount uint)) 
    (begin 
        (var-set mock-state (+ (var-get mock-state) amount)) 
        (if true (ok amount) (err u0))
    )
)
