# Crowdfunding Smart Contract on Stacks Blockchain

This project implements a crowdfunding platform as a Clarity smart contract on the Stacks blockchain. The contract enables project creators to raise funds for their projects, track milestones, and allow contributors to vote on milestone completion.

## Key Features

- **Project Creation**: Allows users to create projects with a funding goal and milestones.
- **Milestone Management**: Enables the addition of milestones with target amounts and descriptions.
- **Voting Mechanism**: Contributors can vote to approve or reject milestone completions.
- **NFT Support**: Contributors receive a non-fungible token (NFT) to signify their support.
- **Project Cancellation**: Project creators can cancel projects they own.
- **Finalization**: Milestones can be finalized based on the outcome of votes.

## Table of Contents

- [Requirements](#requirements)
- [Data Structures](#data-structures)
    - [Data Variables](#data-variables)
    - [Data Maps](#data-maps)
    - [NFT](#nft)
- [Constants](#constants)
- [Functions](#functions)
    - [Public Functions](#public-functions)
    - [Private Functions](#private-functions)
    - [Read-only Functions](#read-only-functions)
- [Usage](#usage)
    - [Deployment](#deployment)
    - [Interactions](#interactions)
- [License](#license)

## Requirements

- **Stacks Blockchain**: This contract is designed for deployment and interaction on the Stacks blockchain.
- **Clarity Language**: Written in Clarity, a decidable and non-Turing-complete language specifically for the Stacks ecosystem.
- **Stacks CLI/Wallet**: Required to deploy and interact with the smart contract.

## Data Structures

### Data Variables

- `next-project-id`: Tracks the next available project ID.
- `next-milestone-id`: Tracks the next available milestone ID.
- `current-block-height`: Tracks the blockchain's current height (for testing and tracking purposes).

### Data Maps

- `ProjectStatus`: Stores project information, including:
    - Total funds raised.
    - Funding goal.
    - Active status.
    - Project creator.
- `ProjectMilestones`: Stores milestones for each project with:
    - Description.
    - Target funding amount.
    - Completion status.
- `MilestoneVotes`: Tracks individual votes for milestone completion.
- `MilestoneVoteCount`: Aggregates votes (approve/reject) and total voters.

### NFT

- `SupportNFT`: A non-fungible token to represent contributor support for projects.

## Constants

The contract includes error constants to ensure clean error handling:

- `ERR-UNAUTHORIZED`: Returned when a user attempts unauthorized actions.
- `ERR-INSUFFICIENT-FUNDS`: Triggered when a funding goal is invalid.
- `ERR-PROJECT-CLOSED`: Used when a project is inactive.
- `ERR-MILESTONE-VALIDATION`: Raised if a milestone cannot be validated.
- `ERR-REFUND-NOT-ALLOWED`: Indicates refund conditions are unmet.
- `ERR-ALREADY-VOTED`: Prevents double voting on milestones.
- `ERR-INVALID-VOTE`: Triggered when milestone voting fails quorum.

## Functions

### Public Functions

#### Project Management

- `(create-project project-name funding-goal milestones)`: Creates a new crowdfunding project.
- `(cancel-project project-id)`: Allows a project creator to cancel their project.

#### Voting & Milestone Management

- `(vote-on-milestone project-id milestone-id vote-type)`: Allows contributors to vote on a milestone.
- `(finalize-milestone project-id milestone-id)`: Finalizes a milestone based on voting results.

#### Block Management (Testing Support)

- `(increment-block-height)`: Increments the block height for testing purposes.
- `(set-block-height new-height)`: Manually sets the block height.

### Private Functions

- `(add-milestone milestone project-id)`: Adds a milestone to a project during creation.

### Read-only Functions

- `(get-block-height)`: Returns the current block height.
- `(get-project-details project-id)`: Fetches details of a specific project.
- `(get-milestone-details project-id milestone-id)`: Fetches details of a specific milestone.
- `(get-milestone-votes project-id milestone-id)`: Returns voting results for a milestone.

## Usage

### Deployment

1. Clone the repository.
2. Use the Stacks CLI to deploy the contract:
     ```bash
     stacks-cli deploy contract-name clarity-file.clar
     ```
3. Test and interact using the Stacks Explorer or CLI.

### Interactions

- **Create a Project**: Call `create-project` with a name, funding goal, and list of milestones.
- **Vote on a Milestone**: Contributors can vote using the `vote-on-milestone` function.
- **Finalize Milestones**: Once sufficient votes are collected, the project owner finalizes the milestone.

### Example Calls

**Create a project:**

```clarity
(create-project "Decentralized Marketplace" u100000 
    [ { description: "Prototype development", target-amount: u20000 }, 
        { description: "Marketing", target-amount: u30000 }
    ])
```

**Vote on a milestone:**

```clarity
(vote-on-milestone u1 u1 true) ;; Approve milestone
```

**Finalize a milestone:**

```clarity
(finalize-milestone u1 u1)
```
