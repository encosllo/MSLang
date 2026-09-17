# discrepancy Specification

## Purpose

Turns the discrepancy report's rows into a triaged queue with recorded
dispositions, so undecided rows are a countable queue rather than untriaged
volume.

## Requirements

### Requirement: Typed edge dispositions

Each edge reported as formal-only or informal-only SHALL be assignable a
disposition from a fixed set (`real-hidden-dependency`, `type-carrier`,
`simplification`, `expected`, `corrected`) together with a free-text note, and
the disposition SHALL be stored keyed by the edge's `FROM->TO` identity and
SHALL survive regeneration of the dependency graphs.

#### Scenario: Disposition persists across re-ingestion

- **WHEN** an edge disposition is recorded and the dependency graphs are
  regenerated
- **THEN** the disposition is still attached to that edge

#### Scenario: Unknown disposition rejected

- **WHEN** a disposition value outside the fixed set is supplied
- **THEN** validation fails and names the invalid value

### Requirement: Default classification rule

The system SHALL apply a documented default disposition to edges matching
structural patterns for which a class is known, so that an edge matching no rule
remains explicitly undecided.

#### Scenario: Known-structure edge defaulted

- **WHEN** an edge's dependency is the type-carrier block
- **THEN** it is classified `type-carrier` without manual work

#### Scenario: Unmatched edge stays undecided

- **WHEN** an edge matches no default rule and has no recorded disposition
- **THEN** it is reported as undecided

### Requirement: Report surfaces the undecided queue

The discrepancy report SHALL report the count of undecided edges and list the
undecided edges explicitly, and SHALL collapse default-classified edges into
per-category counts rather than enumerating them as open items.

#### Scenario: Large default class collapsed

- **WHEN** most rows carry a default disposition
- **THEN** the report shows their counts by category and enumerates only the
  undecided rows

#### Scenario: Undecided count drives review

- **WHEN** the report is generated
- **THEN** it states a single undecided-edge count that a reviewer can act on

### Requirement: Dispositions are not evidence

An edge disposition SHALL NOT be treated as an evidence record and SHALL NOT, by
itself, change any layer status.

#### Scenario: Disposition does not pass a layer

- **WHEN** an edge receives a disposition
- **THEN** no block's layer status changes as a result
