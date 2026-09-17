# ranking Specification

## Purpose

Orders the formalization frontier by the mathematics: it proposes the result
worth formalizing, ranks the target's prerequisites by how centrally they
contribute to it, and recommends the next buildable block - always as an
advisory proposal, never as a change to scope, tiers, or evidence.

## Requirements

### Requirement: Weighted dependency graph for ranking

The ranking SHALL consume all dependency edges, both confirmed and candidate,
SHALL weight each edge by its evidence source with author-written citations
above extracted symbol usage, and SHALL exclude an edge whose recorded
discrepancy disposition is `type-carrier` or `simplification`. The ranking SHALL
NOT modify the graph, any closure, any layer status, or any evidence record.

#### Scenario: Candidates are included but weighted below explicit edges

- **WHEN** the ranking consumes the graph
- **THEN** candidate and confirmed edges both contribute, and an explicit edge
  contributes more than a symbol edge between the same blocks

#### Scenario: Dispositioned edges excluded

- **WHEN** an edge carries a `type-carrier` or `simplification` disposition
- **THEN** it is excluded from the ranking walk

#### Scenario: Advisory only

- **WHEN** the ranking runs
- **THEN** no closure, layer status, or evidence record changes

### Requirement: Goal proposal by reverse rank

The system SHALL compute a reverse (impact) rank over the dependency graph that
concentrates on the manuscript's result-bearing blocks, and SHALL present a
ranked shortlist of candidate goals. The effective goal SHALL be designated by
the author, and a goal SHALL NOT be adopted without an author designation.

#### Scenario: Shortlist proposed

- **WHEN** the rank is computed
- **THEN** a ranked shortlist of candidate goals is reported

#### Scenario: Goal requires author designation

- **WHEN** no goal has been designated
- **THEN** the report presents the shortlist and states that the goal is
  undecided rather than adopting the top candidate

### Requirement: Next step by target-conditioned forward rank

Given a designated goal, the system SHALL restrict to the goal's transitive
ancestor set, compute a forward rank conditioned on the goal, and recommend the
highest-ranked ancestor that is both undone and ready. The goal itself SHALL NOT
be recommended as a next step.

#### Scenario: Prerequisite recommended

- **WHEN** a goal is designated and an undone ready prerequisite outranks the
  others
- **THEN** that prerequisite is the recommended next step

#### Scenario: Only contributing blocks are ranked

- **WHEN** a block is not in the goal's transitive ancestor set
- **THEN** it is not ranked under that goal

#### Scenario: Goal is not the next step

- **WHEN** a goal is designated
- **THEN** the recommendation is a prerequisite, never the goal itself

### Requirement: Done and ready

The system SHALL define `done` and `ready` explicitly and SHALL report them for
each ranked block, where a block is `ready` only when every dependency of that
block is `done`. The definition of `done` SHALL be recorded in the report.

#### Scenario: Block with an undone dependency is not ready

- **WHEN** a ranked block has a dependency that is not done
- **THEN** the block is reported as not ready and is not recommended

#### Scenario: Definition of done is stated

- **WHEN** the ranking report is generated
- **THEN** it states the predicate used for `done`

### Requirement: Ranking is author-reserved and advisory

The ranking SHALL NOT set a scope disposition, a treatment tier, or a priority,
and an agent SHALL NOT adopt a goal on the author's behalf. It MAY propose a
goal and a next step for decision.

#### Scenario: Ranking cannot set scope or tier

- **WHEN** an agent attempts to set a scope disposition or tier from the ranking
- **THEN** the action is refused and the stores are unchanged

#### Scenario: Goal adoption is author-only

- **WHEN** a goal designation is recorded
- **THEN** it references the author decision that set it

### Requirement: Deterministic and fail-closed ranking

The ranking SHALL be deterministic, and an edge that cannot be resolved when it
would enter the walk SHALL be reported rather than silently dropped.

#### Scenario: Same inputs, same ranking

- **WHEN** the ranking runs twice on unchanged inputs
- **THEN** it produces the identical ordering and recommendation

#### Scenario: Unresolved edge reported

- **WHEN** an edge that would enter the walk is unresolved
- **THEN** the report names it instead of omitting it silently

### Requirement: Drift-checked ranking report

The ranking report SHALL be generated and drift-checked like the project's other
generated views.

#### Scenario: Report drift detected

- **WHEN** the ranking inputs change and the report is not regenerated
- **THEN** the report drift check fails
