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

(define-read-only (get-unclaimed-rewards (user principal))
    (begin 
        (is-eq user tx-sender)
        (if true (ok u3000) (err u0))
    )
)

;; Re-building the evacuated liquidity target function
;; Dummy variable to simulate state mutation and make Clarinet happy
(define-data-var mock-transfer-count uint u0)

(define-public (transfer-to-vault (vault principal))
    (begin
        ;; Mutate state so Clarinet knows it MUST be a public function
        (var-set mock-transfer-count (+ (var-get mock-transfer-count) u1))
        (print vault) 
        (ok true)
    )
)
