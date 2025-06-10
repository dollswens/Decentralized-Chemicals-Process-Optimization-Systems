;; Efficiency Tracking Contract
;; Tracks chemical process efficiency metrics

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u500))
(define-constant err-invalid-metrics (err u501))
(define-constant err-record-not-found (err u502))

;; Data structures
(define-map efficiency-records
  { record-id: uint }
  {
    process-id: uint,
    efficiency-score: uint,
    energy-consumption: uint,
    waste-production: uint,
    output-quality: uint,
    cost-per-unit: uint,
    timestamp: uint
  }
)

(define-map record-counter { id: uint } { count: uint })

;; Initialize counter
(map-set record-counter { id: u0 } { count: u0 })

;; Public functions
(define-public (record-efficiency (process-id uint) (energy-consumption uint) (waste-production uint) (output-quality uint) (cost-per-unit uint))
  (let ((current-count (default-to u0 (get count (map-get? record-counter { id: u0 }))))
        (new-id (+ current-count u1))
        (efficiency-score (calculate-efficiency-score energy-consumption waste-production output-quality cost-per-unit)))

    (asserts! (and (> energy-consumption u0) (> output-quality u0) (> cost-per-unit u0)) err-invalid-metrics)

    (map-set efficiency-records
      { record-id: new-id }
      {
        process-id: process-id,
        efficiency-score: efficiency-score,
        energy-consumption: energy-consumption,
        waste-production: waste-production,
        output-quality: output-quality,
        cost-per-unit: cost-per-unit,
        timestamp: block-height
      }
    )
    (map-set record-counter { id: u0 } { count: new-id })
    (ok new-id)
  )
)

;; Private helper function to calculate efficiency score
(define-private (calculate-efficiency-score (energy uint) (waste uint) (quality uint) (cost uint))
  (let ((energy-factor (if (< energy u1000) u30 u20))
        (waste-factor (if (< waste u50) u25 u15))
        (quality-factor (if (> quality u90) u30 u20))
        (cost-factor (if (< cost u100) u15 u10)))
    (+ energy-factor waste-factor quality-factor cost-factor)
  )
)

;; Read-only functions
(define-read-only (get-efficiency-record (record-id uint))
  (map-get? efficiency-records { record-id: record-id })
)

(define-read-only (get-process-efficiency (process-id uint))
  ;; This would typically aggregate multiple records for a process
  ;; For simplicity, we'll return the latest record
  (let ((total-records (get-total-records)))
    (map-get? efficiency-records { record-id: total-records })
  )
)

(define-read-only (get-total-records)
  (default-to u0 (get count (map-get? record-counter { id: u0 })))
)

(define-read-only (calculate-average-efficiency (process-id uint))
  ;; Simplified calculation - in practice would aggregate multiple records
  u75
)
