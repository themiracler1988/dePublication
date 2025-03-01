;; Scientific Paper Repository
;; A decentralized system for managing academic publications

;; Error Definition Section
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERROR_UNAUTHORIZED (err u305))
(define-constant ERROR_INVALID_PUBLICATION (err u303))
(define-constant ERROR_PUBLICATION_SIZE (err u304))
(define-constant ERROR_PUBLICATION_EXISTS (err u302))
(define-constant ERROR_PUBLICATION_MISSING (err u301))
(define-constant ERROR_OWNER_REQUIRED (err u300))

;; Storage Structures
(define-map publication-registry
  { publication-uid: uint }
  {
    title: (string-ascii 80),
    creator: principal,
    byte-count: uint,
    timestamp: uint,
    summary: (string-ascii 256),
    tags: (list 8 (string-ascii 40))
  }
)

(define-map viewer-permissions
  { publication-uid: uint, viewer: principal }
  { has-permission: bool }
)

;; State Variables
(define-data-var total-publications uint u0)

;; Validation Functions
(define-private (validate-tag-length (tag (string-ascii 40)))
  (and 
    (> (len tag) u0)
    (< (len tag) u41)
  )
)

(define-private (validate-tag-collection (tag-collection (list 8 (string-ascii 40))))
  (and
    (> (len tag-collection) u0)
    (<= (len tag-collection) u8)
    (is-eq (len (filter validate-tag-length tag-collection)) (len tag-collection))
  )
)

;; Helper Functions 
(define-private (publication-exists (publication-uid uint))
  (is-some (map-get? publication-registry { publication-uid: publication-uid }))
)

(define-private (is-publication-creator (publication-uid uint) (creator principal))
  (match (map-get? publication-registry { publication-uid: publication-uid })
    publication-record (is-eq (get creator publication-record) creator)
    false
  )
)

(define-private (get-byte-count (publication-uid uint))
  (default-to u0 
    (get byte-count 
      (map-get? publication-registry { publication-uid: publication-uid })
    )
  )
)

;; Publication Management Functions

;; Register a new scientific publication
(define-public (register-publication (title (string-ascii 80)) (byte-count uint) (summary (string-ascii 256)) (tags (list 8 (string-ascii 40))))
  (let
    (
      (new-id (+ (var-get total-publications) u1))
    )
    (asserts! (> (len title) u0) ERROR_INVALID_PUBLICATION)
    (asserts! (< (len title) u81) ERROR_INVALID_PUBLICATION)
    (asserts! (> byte-count u0) ERROR_PUBLICATION_SIZE)
    (asserts! (< byte-count u2000000000) ERROR_PUBLICATION_SIZE)
    (asserts! (> (len summary) u0) ERROR_INVALID_PUBLICATION)
    (asserts! (< (len summary) u257) ERROR_INVALID_PUBLICATION)
    (asserts! (validate-tag-collection tags) ERROR_INVALID_PUBLICATION)

    (map-insert publication-registry
      { publication-uid: new-id }
      {
        title: title,
        creator: tx-sender,
        byte-count: byte-count,
        timestamp: block-height,
        summary: summary,
        tags: tags
      }
    )

    (map-insert viewer-permissions
      { publication-uid: new-id, viewer: tx-sender }
      { has-permission: true }
    )
    (var-set total-publications new-id)
    (ok new-id)
  )
)

;; Remove an existing publication
(define-public (remove-publication (publication-uid uint))
  (let
    (
      (publication-data (unwrap! (map-get? publication-registry { publication-uid: publication-uid }) ERROR_PUBLICATION_MISSING))
    )
    (asserts! (publication-exists publication-uid) ERROR_PUBLICATION_MISSING)
    (asserts! (is-eq (get creator publication-data) tx-sender) ERROR_UNAUTHORIZED)
    
    (map-delete publication-registry { publication-uid: publication-uid })
    (ok true)
  )
)

;; Modify publication details
(define-public (modify-publication (publication-uid uint) (updated-title (string-ascii 80)) (updated-byte-count uint) (updated-summary (string-ascii 256)) (updated-tags (list 8 (string-ascii 40))))
  (let
    (
      (publication-data (unwrap! (map-get? publication-registry { publication-uid: publication-uid }) ERROR_PUBLICATION_MISSING))
    )
    (asserts! (publication-exists publication-uid) ERROR_PUBLICATION_MISSING)
    (asserts! (is-eq (get creator publication-data) tx-sender) ERROR_UNAUTHORIZED)
    (asserts! (> (len updated-title) u0) ERROR_INVALID_PUBLICATION)
    (asserts! (< (len updated-title) u81) ERROR_INVALID_PUBLICATION)
    (asserts! (> updated-byte-count u0) ERROR_PUBLICATION_SIZE)
    (asserts! (< updated-byte-count u2000000000) ERROR_PUBLICATION_SIZE)
    (asserts! (> (len updated-summary) u0) ERROR_INVALID_PUBLICATION)
    (asserts! (< (len updated-summary) u257) ERROR_INVALID_PUBLICATION)
    (asserts! (validate-tag-collection updated-tags) ERROR_INVALID_PUBLICATION)

    (map-set publication-registry
      { publication-uid: publication-uid }
      (merge publication-data { 
        title: updated-title, 
        byte-count: updated-byte-count, 
        summary: updated-summary, 
        tags: updated-tags 
      })
    )
    (ok true)
  )
)

;; Transfer publication ownership
(define-public (transfer-publication (publication-uid uint) (new-creator principal))
  (let
    (
      (publication-data (unwrap! (map-get? publication-registry { publication-uid: publication-uid }) ERROR_PUBLICATION_MISSING))
    )
    (asserts! (publication-exists publication-uid) ERROR_PUBLICATION_MISSING)
    (asserts! (is-eq (get creator publication-data) tx-sender) ERROR_UNAUTHORIZED)
    
    (map-set publication-registry
      { publication-uid: publication-uid }
      (merge publication-data { creator: new-creator })
    )
    (ok true)
  )
)

