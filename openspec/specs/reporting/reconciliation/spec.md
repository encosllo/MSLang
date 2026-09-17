# reconciliation Specification

## Purpose

Catalogues formalization-produced proposals to change the manuscript and tracks
their acceptance, closing the loop from Lean back to the prose.

## Requirements

### Requirement: Proposal catalogue

Every formalization-produced proposal to change the manuscript SHALL be
registered with a stable identifier, a kind drawn from a fixed set
(`reconstructed-proof`, `simplification`, `newly-proven-commented-result`,
`statement-correction`), the source that produced it, the target block or
blocks, and the concrete prose change proposed.

#### Scenario: Reconstructed proof registered

- **WHEN** an `Explanation` is produced for a block that has no manuscript proof
- **THEN** a proposal of kind `reconstructed-proof` is registered naming that
  block and the source record

#### Scenario: Simplification registered

- **WHEN** a discrepancy disposition records a possible simplification
- **THEN** a proposal of kind `simplification` is registered or linked to that
  disposition

### Requirement: Acceptance state

Each proposal SHALL carry an acceptance state (`open`, `accepted`, `rejected`,
`superseded`), and a resolved proposal SHALL reference the author decision that
resolved it and SHALL retain its rationale.

#### Scenario: Acceptance records a decision

- **WHEN** a proposal is accepted
- **THEN** it records the author decision reference, a journal event is emitted,
  and its state is `accepted`

#### Scenario: Rejection retains rationale

- **WHEN** a proposal is rejected
- **THEN** its state is `rejected` and its rationale remains readable

### Requirement: Acceptance is author-reserved

An agent SHALL NOT set a proposal's state to `accepted` or `rejected`; it may
only register proposals and present them for decision.

#### Scenario: Agent cannot accept

- **WHEN** an agent attempts to mark a proposal accepted
- **THEN** the action is refused and the state is unchanged

### Requirement: Reconciliation view

The system SHALL generate a view listing every open proposal with the concrete
manuscript edit that accepting it would make, and the view SHALL be
drift-checked like the project's other generated views.

#### Scenario: Open proposals listed

- **WHEN** the view is generated
- **THEN** every `open` proposal appears with its kind, target, and proposed
  prose change

#### Scenario: View drift detected

- **WHEN** the catalogue changes and the view is not regenerated
- **THEN** the view drift check fails

### Requirement: Acceptance closes the loop

Accepting a proposal SHALL cause the corresponding manuscript edit to be made,
SHALL re-run the affected block hashes and facets, and SHALL record the
resulting manuscript text hash so that evidence depending on the proposal
becomes current.

#### Scenario: Accepted proposal records resulting hash

- **WHEN** an accepted proposal's manuscript edit is made
- **THEN** the proposal records the resulting manuscript hash and affected
  evidence is re-evaluated for currency

#### Scenario: Explanation becomes manuscript prose

- **WHEN** an `Explanation` proposal is accepted and merged into the manuscript
- **THEN** the block is marked as carrying manuscript prose and no longer as an
  unaccepted proposal
