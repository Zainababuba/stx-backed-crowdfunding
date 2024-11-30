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





