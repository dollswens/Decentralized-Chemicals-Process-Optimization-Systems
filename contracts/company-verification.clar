;; Chemical Company Verification Contract
;; Manages verification of chemical manufacturers

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-verified (err u101))
(define-constant err-not-verified (err u102))
(define-constant err-not-found (err u103))

;; Data structures
(define-map verified-companies
  { company-id: uint }
  {
    name: (string-ascii 100),
    license-number: (string-ascii 50),
    verification-date: uint,
    is-active: bool
  }
)

(define-map company-counter { id: uint } { count: uint })

;; Initialize counter
(map-set company-counter { id: u0 } { count: u0 })

;; Public functions
(define-public (verify-company (name (string-ascii 100)) (license-number (string-ascii 50)))
  (let ((current-count (default-to u0 (get count (map-get? company-counter { id: u0 }))))
        (new-id (+ current-count u1)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-none (map-get? verified-companies { company-id: new-id })) err-already-verified)

    (map-set verified-companies
      { company-id: new-id }
      {
        name: name,
        license-number: license-number,
        verification-date: block-height,
        is-active: true
      }
    )
    (map-set company-counter { id: u0 } { count: new-id })
    (ok new-id)
  )
)

(define-public (deactivate-company (company-id uint))
  (let ((company (unwrap! (map-get? verified-companies { company-id: company-id }) err-not-found)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set verified-companies
      { company-id: company-id }
      (merge company { is-active: false })
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (is-company-verified (company-id uint))
  (match (map-get? verified-companies { company-id: company-id })
    company (get is-active company)
    false
  )
)

(define-read-only (get-company-info (company-id uint))
  (map-get? verified-companies { company-id: company-id })
)

(define-read-only (get-total-companies)
  (default-to u0 (get count (map-get? company-counter { id: u0 })))
)
