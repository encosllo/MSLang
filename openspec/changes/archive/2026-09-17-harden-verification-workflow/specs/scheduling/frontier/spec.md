# Spec Delta

## Purpose

Gives each confirmed-but-unmapped block an explicit scope disposition so the
frontier reads as a triaged plan instead of an undifferentiated list.

## ADDED Requirements

### Requirement: Scope disposition store

Each confirmed block that has no Lean counterpart SHALL be assignable a scope
disposition from a fixed set (`worth-formalizing`, `deferred`, `out-of-scope`),
with an optional rationale and a reference to the decision that set it. A block
with no recorded disposition SHALL be reported as undecided rather than assumed
to be worth formalizing.

#### Scenario: Undecided by default

- **WHEN** a confirmed block has no Lean counterpart and no recorded
  disposition
- **THEN** it is reported as undecided

#### Scenario: Disposition records its decision

- **WHEN** a disposition is recorded
- **THEN** it references the decision that set it and survives regeneration of
  the registry

### Requirement: Frontier reports triage

The frontier view SHALL group unmapped blocks by scope disposition and report
counts, distinguishing decided from undecided blocks.

#### Scenario: Grouped counts reported

- **WHEN** the frontier view is generated
- **THEN** it reports the count of `worth-formalizing`, `deferred`,
  `out-of-scope`, and undecided unmapped blocks

### Requirement: Out-of-scope blocks leave the scheduling list

A block whose scope disposition is `out-of-scope` SHALL NOT appear in the
frontier's open-obligation scheduling list while remaining visible in the
triage summary.

#### Scenario: Out-of-scope excluded but counted

- **WHEN** a block is marked `out-of-scope`
- **THEN** it is absent from the open obligations and present in the triage
  counts

### Requirement: Scope disposition is author-reserved

An agent SHALL NOT set a block's scope disposition; it may propose a
disposition and present it for decision.

#### Scenario: Agent cannot set scope

- **WHEN** an agent attempts to set a scope disposition
- **THEN** the action is refused and the disposition is unchanged
