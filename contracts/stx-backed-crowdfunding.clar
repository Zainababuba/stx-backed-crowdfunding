;; constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-FUNDS (err u101))
(define-constant ERR-PROJECT-CLOSED (err u102))
(define-constant ERR-MILESTONE-VALIDATION (err u103))
(define-constant ERR-REFUND-NOT-ALLOWED (err u104))
(define-constant ERR-ALREADY-VOTED (err u105))
(define-constant ERR-INVALID-VOTE (err u106))

;; data vars
;; Track the next available project and milestone IDs
(define-data-var next-project-id uint u1)
(define-data-var next-milestone-id uint u1)
(define-data-var current-block-height uint u0)

;; data maps
;; Store project status and details
(define-map ProjectStatus
    { project-id: uint }
    { 
        total-raised: uint,
        goal: uint, 
        is-active: bool,
        creator: principal
    }
)

;; Store milestone details for each project
(define-map ProjectMilestones
    { project-id: uint, milestone-id: uint }
    {
        description: (string-utf8 200),
        target-amount: uint,
        is-completed: bool
    }
)

;; Track voting for milestone completion
(define-map MilestoneVotes
    { project-id: uint, milestone-id: uint, voter: principal }
    { voted: bool }
)

;; Store vote counts for each milestone
(define-map MilestoneVoteCount
    { project-id: uint, milestone-id: uint }
    { 
        approve-votes: uint, 
        reject-votes: uint,
        total-voters: uint
    }
)

;; Support NFT tracking 
(define-non-fungible-token SupportNFT uint)

;; private functions
;; Helper function to add milestones to a project
(define-private (add-milestone 
    (milestone { description: (string-utf8 200), target-amount: uint })
    (project-id uint)
)
    (let 
        (
            (milestone-id (var-get next-milestone-id))
        )
        ;; Store milestone for the project
        (map-set ProjectMilestones 
            { project-id: project-id, milestone-id: milestone-id }
            {
                description: (get description milestone),
                target-amount: (get target-amount milestone),
                is-completed: false
            }
        )

        ;; Increment milestone counter
        (var-set next-milestone-id (+ milestone-id u1))

        project-id
    )
)

;; public functions
;; Create a new crowdfunding project
(define-public (create-project 
    (project-name (string-utf8 50))
    (funding-goal uint)
    (milestones (list 5 { 
        description: (string-utf8 200), 
        target-amount: uint 
    }))
)
    (let 
        (
            (project-id (var-get next-project-id))
        )
        ;; Validate project parameters
        (asserts! (> funding-goal u0) ERR-INSUFFICIENT-FUNDS)

        ;; Store project status
        (map-set ProjectStatus 
            { project-id: project-id }
            {
                total-raised: u0,
                goal: funding-goal,
                is-active: true,
                creator: tx-sender
            }
        )

        ;; Store milestones
        (fold add-milestone milestones project-id)

        ;; Increment project counter
        (var-set next-project-id (+ project-id u1))

        (ok project-id)
    )
)

;; Cancel project by creator
(define-public (cancel-project (project-id uint))
    (let 
        (
            (project-details 
                (unwrap! 
                    (map-get? ProjectStatus { project-id: project-id }) 
                    ERR-UNAUTHORIZED
                )
            )
        )
        ;; Only project creator can cancel
        (asserts! (is-eq tx-sender (get creator project-details)) ERR-UNAUTHORIZED)

        ;; Mark project as inactive
        (map-set ProjectStatus 
            { project-id: project-id }
            (merge project-details { is-active: false })
        )

        (ok true)
    )
)

;; Add voting mechanism for milestone validation
(define-public (vote-on-milestone
    (project-id uint)
    (milestone-id uint)
    (vote-type bool)
)
    (let 
        (
            ;; Check if voter has already voted
            (existing-vote 
                (map-get? MilestoneVotes 
                    { 
                        project-id: project-id, 
                        milestone-id: milestone-id, 
                        voter: tx-sender 
                    }
                )
            )
            ;; Get current vote count
            (current-votes 
                (default-to 
                    { 
                        approve-votes: u0, 
                        reject-votes: u0,
                        total-voters: u0 
                    }
                    (map-get? MilestoneVoteCount 
                        { 
                            project-id: project-id, 
                            milestone-id: milestone-id 
                        }
                    )
                )
            )
        )
        ;; Prevent double voting
        (asserts! (is-none existing-vote) ERR-ALREADY-VOTED)

        ;; Record individual vote
        (map-set MilestoneVotes
            { 
                project-id: project-id, 
                milestone-id: milestone-id, 
                voter: tx-sender 
            }
            { voted: true }
        )

        ;; Update vote counts
        (map-set MilestoneVoteCount
            { 
                project-id: project-id, 
                milestone-id: milestone-id 
            }
            (if vote-type
                {
                    approve-votes: (+ (get approve-votes current-votes) u1),
                    reject-votes: (get reject-votes current-votes),
                    total-voters: (+ (get total-voters current-votes) u1)
                }
                {
                    approve-votes: (get approve-votes current-votes),
                    reject-votes: (+ (get reject-votes current-votes) u1),
                    total-voters: (+ (get total-voters current-votes) u1)
                }
            )
        )

        (ok true)
    )
)

;; Finalize milestone based on voting results
(define-public (finalize-milestone
    (project-id uint)
    (milestone-id uint)
)
    (let 
        (
            (vote-results 
                (unwrap! 
                    (map-get? MilestoneVoteCount 
                        { 
                            project-id: project-id, 
                            milestone-id: milestone-id 
                        }
                    )
                    ERR-UNAUTHORIZED
                )
            )
            (milestone-details 
                (unwrap! 
                    (map-get? ProjectMilestones 
                        { 
                            project-id: project-id, 
                            milestone-id: milestone-id 
                        }
                    )
                    ERR-UNAUTHORIZED
                )
            )
        )
        ;; Validate milestone can be finalized
        (asserts! 
            (>= (get approve-votes vote-results) 
                (/ (get total-voters vote-results) u2)
            ) 
            ERR-INVALID-VOTE
        )

        ;; Mark milestone as completed
        (map-set ProjectMilestones
            { 
                project-id: project-id, 
                milestone-id: milestone-id 
            }
            (merge milestone-details { is-completed: true })
        )

        (ok true)
    )
)
