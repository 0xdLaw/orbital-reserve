(define-public (claim-supply-rewards) (ok true))
(define-public (emergency-withdraw-collateral) (ok true))
(define-public (transfer-to-vault (vault principal)) (ok true))
(define-read-only (get-unclaimed-rewards (user principal)) (ok u3000))
