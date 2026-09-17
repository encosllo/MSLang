# Spec Delta

## MODIFIED Requirements

### Requirement: Goal proposal by reverse rank

The system SHALL compute a reverse (impact) rank over the dependency graph that
concentrates on the manuscript's result-bearing blocks, and SHALL present a
ranked shortlist of candidate goals. The effective goal set, consisting of one
or more goals, SHALL be designated by the author, and no goal SHALL be adopted
without an author designation.

#### Scenario: Shortlist proposed

- **WHEN** the rank is computed
- **THEN** a ranked shortlist of candidate goals is reported

#### Scenario: Goal requires author designation

- **WHEN** no goal has been designated
- **THEN** the report presents the shortlist and states that the goal set is
  undecided rather than adopting the top candidate

#### Scenario: Multiple goals designated

- **WHEN** the author designates more than one goal
- **THEN** every designated goal is recorded and each contributes to the
  ranking

### Requirement: Next step by target-conditioned forward rank

Given a designated goal set, the system SHALL restrict to the union of the
goals' transitive ancestor sets, compute a forward rank conditioned on the goal
set with restart mass spread over the goals, and recommend the highest-ranked
block that is both undone and ready and is not a terminal goal. A terminal goal
- a designated goal that no other designated goal depends on - SHALL NOT be
recommended as a next step, while a designated goal that is a prerequisite of
another designated goal MAY be. The report SHALL break the ranking down per
goal, naming for each ranked block the designated goals it contributes to.

#### Scenario: Prerequisite recommended

- **WHEN** a goal set is designated and an undone ready prerequisite outranks
  the others
- **THEN** that prerequisite is the recommended next step

#### Scenario: Only contributing blocks are ranked

- **WHEN** a block is not in the union of the goals' transitive ancestor sets
- **THEN** it is not ranked under that goal set

#### Scenario: Goal is not the next step

- **WHEN** a goal set is designated
- **THEN** a terminal goal is not recommended as a next step

#### Scenario: Prerequisite goal may be recommended

- **WHEN** a designated goal is a prerequisite of another designated goal and is
  undone and ready
- **THEN** it may be the recommended next step

#### Scenario: Per-goal breakdown reported

- **WHEN** two or more goals are designated
- **THEN** each ranked block names the designated goals it contributes to
