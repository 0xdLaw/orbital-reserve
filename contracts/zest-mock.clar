(define-public (claim-supply-rewards)
    (if false
        (err u0)
        (ok true)))
(define-public (emergency-withdraw-collateral)
    (if false
        (err u0)
        (ok true)))
(define-public (transfer-to-vault (vault principal))
    (if false
        (err u0)
        (begin (print vault) (ok true))))
(define-read-only (get-unclaimed-rewards (user principal)) (begin (print user) (ok u3000)))
