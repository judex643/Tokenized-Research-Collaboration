;; Project Registration Contract
;; Records details of scientific initiatives

;; Map to store registered projects
(define-map projects uint
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    institution: principal,
    lead-researcher: principal,
    registration-date: uint,
    status: (string-ascii 20)
  }
)

;; Counter for project IDs
(define-data-var project-id-counter uint u1)

;; Define admin principal
(define-data-var admin principal tx-sender)

;; Public function to register a new project
(define-public (register-project
    (title (string-ascii 100))
    (description (string-ascii 500))
    (institution principal)
    (lead-researcher principal))
  (let ((current-id (var-get project-id-counter)))
    (begin
      (map-set projects current-id
        {
          title: title,
          description: description,
          institution: institution,
          lead-researcher: lead-researcher,
          registration-date: block-height,
          status: "active"
        }
      )
      (var-set project-id-counter (+ current-id u1))
      (ok current-id)
    )
  )
)

;; Public function to update project status
(define-public (update-project-status (project-id uint) (new-status (string-ascii 20)))
  (let ((project (unwrap! (map-get? projects project-id) (err u404))))
    (begin
      (asserts! (or
                  (is-eq tx-sender (get lead-researcher project))
                  (is-eq tx-sender (var-get admin)))
                (err u403))
      (ok (map-set projects project-id
        (merge project { status: new-status })))
    )
  )
)

;; Read-only function to get project details
(define-read-only (get-project (project-id uint))
  (map-get? projects project-id)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
