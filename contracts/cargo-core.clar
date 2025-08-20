;; Specialized Cargo and Freight Services - Core Cargo Contract
;; Manages cargo registration, tracking, and basic operations

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-CARGO-NOT-FOUND (err u101))
(define-constant ERR-CARGO-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-STATUS (err u103))
(define-constant ERR-INVALID-WEIGHT (err u104))
(define-constant ERR-INVALID-INPUT (err u105))

;; Cargo Status Constants
(define-constant STATUS-REGISTERED u1)
(define-constant STATUS-IN-TRANSIT u2)
(define-constant STATUS-DELIVERED u3)
(define-constant STATUS-DELAYED u4)
(define-constant STATUS-DAMAGED u5)
(define-constant STATUS-LOST u6)

;; Data Structures
(define-map cargo-registry
  { cargo-id: (string-ascii 50) }
  {
    owner: principal,
    operator: principal,
    cargo-type: (string-ascii 100),
    weight: uint,
    origin: (string-ascii 100),
    destination: (string-ascii 100),
    status: uint,
    special-handling: (optional (string-ascii 200)),
    created-at: uint,
    updated-at: uint
  }
)

(define-map cargo-locations
  { cargo-id: (string-ascii 50) }
  {
    current-location: (string-ascii 100),
    latitude: (optional (string-ascii 20)),
    longitude: (optional (string-ascii 20)),
    updated-at: uint,
    updated-by: principal
  }
)

(define-map authorized-operators
  { operator: principal }
  { authorized: bool, authorized-by: principal, authorized-at: uint }
)

;; Data Variables
(define-data-var total-cargo-count uint u0)
(define-data-var contract-active bool true)

;; Authorization Functions
(define-private (is-contract-owner)
  (is-eq tx-sender CONTRACT-OWNER)
)

(define-private (is-authorized-operator (operator principal))
  (default-to false (get authorized (map-get? authorized-operators { operator: operator })))
)

(define-private (is-cargo-owner-or-operator (cargo-id (string-ascii 50)))
  (match (map-get? cargo-registry { cargo-id: cargo-id })
    cargo-data (or
      (is-eq tx-sender (get owner cargo-data))
      (is-eq tx-sender (get operator cargo-data))
      (is-authorized-operator tx-sender)
    )
    false
  )
)

;; Public Functions

;; Register new cargo
(define-public (register-cargo
  (cargo-id (string-ascii 50))
  (cargo-type (string-ascii 100))
  (weight uint)
  (origin (string-ascii 100))
  (destination (string-ascii 100))
  (special-handling (optional (string-ascii 200)))
)
  (let (
    (current-block-height block-height)
  )
    (asserts! (var-get contract-active) ERR-NOT-AUTHORIZED)
    (asserts! (> weight u0) ERR-INVALID-WEIGHT)
    (asserts! (> (len cargo-id) u0) ERR-INVALID-INPUT)
    (asserts! (> (len cargo-type) u0) ERR-INVALID-INPUT)
    (asserts! (> (len origin) u0) ERR-INVALID-INPUT)
    (asserts! (> (len destination) u0) ERR-INVALID-INPUT)
    (asserts! (is-none (map-get? cargo-registry { cargo-id: cargo-id })) ERR-CARGO-ALREADY-EXISTS)

    (map-set cargo-registry
      { cargo-id: cargo-id }
      {
        owner: tx-sender,
        operator: tx-sender,
        cargo-type: cargo-type,
        weight: weight,
        origin: origin,
        destination: destination,
        status: STATUS-REGISTERED,
        special-handling: special-handling,
        created-at: current-block-height,
        updated-at: current-block-height
      }
    )

    (var-set total-cargo-count (+ (var-get total-cargo-count) u1))
    (ok cargo-id)
  )
)

;; Update cargo status
(define-public (update-cargo-status
  (cargo-id (string-ascii 50))
  (new-status uint)
)
  (let (
    (current-block-height block-height)
  )
    (asserts! (var-get contract-active) ERR-NOT-AUTHORIZED)
    (asserts! (is-cargo-owner-or-operator cargo-id) ERR-NOT-AUTHORIZED)
    (asserts! (and (>= new-status u1) (<= new-status u6)) ERR-INVALID-STATUS)

    (match (map-get? cargo-registry { cargo-id: cargo-id })
      cargo-data (begin
        (map-set cargo-registry
          { cargo-id: cargo-id }
          (merge cargo-data {
            status: new-status,
            updated-at: current-block-height
          })
        )
        (ok new-status)
      )
      ERR-CARGO-NOT-FOUND
    )
  )
)

;; Update cargo location
(define-public (update-cargo-location
  (cargo-id (string-ascii 50))
  (location (string-ascii 100))
  (latitude (optional (string-ascii 20)))
  (longitude (optional (string-ascii 20)))
)
  (let (
    (current-block-height block-height)
  )
    (asserts! (var-get contract-active) ERR-NOT-AUTHORIZED)
    (asserts! (is-cargo-owner-or-operator cargo-id) ERR-NOT-AUTHORIZED)
    (asserts! (> (len location) u0) ERR-INVALID-INPUT)
    (asserts! (is-some (map-get? cargo-registry { cargo-id: cargo-id })) ERR-CARGO-NOT-FOUND)

    (map-set cargo-locations
      { cargo-id: cargo-id }
      {
        current-location: location,
        latitude: latitude,
        longitude: longitude,
        updated-at: current-block-height,
        updated-by: tx-sender
      }
    )
    (ok location)
  )
)

;; Transfer cargo ownership
(define-public (transfer-cargo-ownership
  (cargo-id (string-ascii 50))
  (new-owner principal)
)
  (let (
    (current-block-height block-height)
  )
    (asserts! (var-get contract-active) ERR-NOT-AUTHORIZED)
    (asserts! (is-cargo-owner-or-operator cargo-id) ERR-NOT-AUTHORIZED)

    (match (map-get? cargo-registry { cargo-id: cargo-id })
      cargo-data (begin
        (map-set cargo-registry
          { cargo-id: cargo-id }
          (merge cargo-data {
            owner: new-owner,
            updated-at: current-block-height
          })
        )
        (ok new-owner)
      )
      ERR-CARGO-NOT-FOUND
    )
  )
)

;; Assign cargo operator
(define-public (assign-cargo-operator
  (cargo-id (string-ascii 50))
  (new-operator principal)
)
  (let (
    (current-block-height block-height)
  )
    (asserts! (var-get contract-active) ERR-NOT-AUTHORIZED)
    (asserts! (is-cargo-owner-or-operator cargo-id) ERR-NOT-AUTHORIZED)

    (match (map-get? cargo-registry { cargo-id: cargo-id })
      cargo-data (begin
        (map-set cargo-registry
          { cargo-id: cargo-id }
          (merge cargo-data {
            operator: new-operator,
            updated-at: current-block-height
          })
        )
        (ok new-operator)
      )
      ERR-CARGO-NOT-FOUND
    )
  )
)

;; Authorize operator (only contract owner)
(define-public (authorize-operator (operator principal))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (map-set authorized-operators
      { operator: operator }
      {
        authorized: true,
        authorized-by: tx-sender,
        authorized-at: block-height
      }
    )
    (ok operator)
  )
)

;; Revoke operator authorization (only contract owner)
(define-public (revoke-operator-authorization (operator principal))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (map-set authorized-operators
      { operator: operator }
      {
        authorized: false,
        authorized-by: tx-sender,
        authorized-at: block-height
      }
    )
    (ok operator)
  )
)

;; Emergency contract pause (only contract owner)
(define-public (toggle-contract-active)
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (var-set contract-active (not (var-get contract-active)))
    (ok (var-get contract-active))
  )
)

;; Read-only Functions

;; Get cargo information
(define-read-only (get-cargo-info (cargo-id (string-ascii 50)))
  (map-get? cargo-registry { cargo-id: cargo-id })
)

;; Get cargo location
(define-read-only (get-cargo-location (cargo-id (string-ascii 50)))
  (map-get? cargo-locations { cargo-id: cargo-id })
)

;; Get total cargo count
(define-read-only (get-total-cargo-count)
  (var-get total-cargo-count)
)

;; Check if operator is authorized
(define-read-only (is-operator-authorized (operator principal))
  (is-authorized-operator operator)
)

;; Get contract status
(define-read-only (get-contract-status)
  {
    active: (var-get contract-active),
    owner: CONTRACT-OWNER,
    total-cargo: (var-get total-cargo-count)
  }
)

;; Check cargo ownership
(define-read-only (is-cargo-owner (cargo-id (string-ascii 50)) (user principal))
  (match (map-get? cargo-registry { cargo-id: cargo-id })
    cargo-data (is-eq user (get owner cargo-data))
    false
  )
)

;; Get cargo status name
(define-read-only (get-status-name (status-code uint))
  (if (is-eq status-code STATUS-REGISTERED)
    "Registered"
    (if (is-eq status-code STATUS-IN-TRANSIT)
      "In Transit"
      (if (is-eq status-code STATUS-DELIVERED)
        "Delivered"
        (if (is-eq status-code STATUS-DELAYED)
          "Delayed"
          (if (is-eq status-code STATUS-DAMAGED)
            "Damaged"
            (if (is-eq status-code STATUS-LOST)
              "Lost"
              "Unknown"
            )
          )
        )
      )
    )
  )
)
