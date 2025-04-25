;; Contribution Tracking Contract
;; Records individual researcher inputs

;; Map to store contributions
(define-map contributions uint
  {
    project-id: uint,
    contributor: principal,
    description: (string-ascii 200),
    contribution-type: (string-ascii 50),
    contribution-date: uint,
    verified: bool
  }
)

;; Counter for contribution IDs
(define-data-var contribution-id-counter uint u1)

;; Define admin principal
(define-data-var admin principal tx-sender)

;; Public function to record a contribution
(define-public (record-contribution
    (project-id uint)
    (description (string-ascii 200))
    (contribution-type (string-ascii 50)))
  (let ((current-id (var-get contribution-id-counter)))
    (begin
      (map-set contributions current-id
        {
          project-id: project-id,
          contributor: tx-sender,
          description: description,
          contribution-type: contribution-type,
          contribution-date: block-height,
          verified: false
        }
      )
      (var-set contribution-id-counter (+ current-id u1))
      (ok current-id)
    )
  )
)

;; Public function to verify a contribution
(define-public (verify-contribution (contribution-id uint))
  (let ((contribution (unwrap! (map-get? contributions contribution-id) (err u404))))
    (begin
      ;; Only admin can verify contributions in this simplified version
      (asserts! (is-eq tx-sender (var-get admin)) (err u403))
      (ok (map-set contributions contribution-id
        (merge contribution { verified: true })))
    )
  )
)

;; Read-only function to get contribution details
(define-read-only (get-contribution (contribution-id uint))
  (map-get? contributions contribution-id)
)
