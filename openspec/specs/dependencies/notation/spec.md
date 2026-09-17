# notation Specification

## Purpose

Turns the manuscript's notation into dependency edges: it fixes how notation
tokens are identified and attributed to their defining blocks, records
resolutions for genuinely ambiguous notation, and stages recovered edges as
reviewable candidates instead of silently dropping them.

## Requirements

### Requirement: Compound notation identity

A notation token SHALL be identified by its full compound form, including any
subscript qualifiers, so that a base notation and a subscript-qualified notation
are distinct notation identities. A qualifier that appears only as part of a
compound notation SHALL NOT itself be treated as a notation token.

#### Scenario: Base and qualified notation are distinct

- **WHEN** one block uses a base notation and another uses the same base with a
  subscript qualifier
- **THEN** they resolve to two distinct notation identities and may yield
  separate dependency candidates

#### Scenario: Qualifier is not a standalone token

- **WHEN** a subscript qualifier occurs only as part of a compound notation
- **THEN** it produces no dependency edge of its own and is not reported as an
  unresolved notation

### Requirement: Introducer determination

A defining block SHALL be attributed as the owner of a notation only when the
notation is the definee of an introduction in that block's own body. Merely
mentioning a notation, even near an introduction cue, SHALL NOT make a block an
owner.

#### Scenario: Definee is owned

- **WHEN** a definition's body introduces a notation as the definee of an
  introduction
- **THEN** that definition is attributed as the notation's owner

#### Scenario: Mention is not ownership

- **WHEN** a definition mentions a notation inside a sentence containing an
  introduction cue but the notation is introduced elsewhere
- **THEN** that definition is not attributed as an owner

#### Scenario: Distance within the sentence does not hide the introducer

- **WHEN** a notation is the definee of an introduction and the token occurs far
  from the introduction cue within that same sentence
- **THEN** the definition is still attributed as the owner

### Requirement: Mechanical resolution to a single owner

The system SHALL resolve each notation identity to at most one defining block by
mechanical rules, and SHALL NOT create a dependency edge for a notation whose
resolution is not unique by those rules.

#### Scenario: Unique owner yields a dependency candidate

- **WHEN** a notation identity has exactly one mechanical owner and a block uses
  it
- **THEN** a dependency candidate from that block to the owner is produced

#### Scenario: Non-unique resolution produces no edge

- **WHEN** a notation identity has more than one mechanical owner
- **THEN** no dependency edge is created from its uses until a resolution is
  recorded

### Requirement: Notation resolution store

The system SHALL maintain a store keyed by notation identity that records, for
each resolved notation, either a defining block, an `ambient` classification
meaning the notation yields no dependency edge, or a recorded resolution for a
genuinely ambiguous identity. A resolution SHALL survive regeneration of the
symbol and dependency data, and a notation with no recorded resolution SHALL be
reported as unresolved rather than assigned a default owner.

#### Scenario: Ambient notation yields no edge

- **WHEN** a notation identity is recorded as `ambient`
- **THEN** its uses produce no dependency edge

#### Scenario: Resolution survives regeneration

- **WHEN** a notation resolution is recorded and the symbol and dependency data
  are regenerated
- **THEN** the resolution is still attached to that notation identity

#### Scenario: No default owner

- **WHEN** a notation identity has no recorded resolution and is not
  mechanically unique
- **THEN** it is reported as unresolved

### Requirement: Resolution of genuine ambiguity is author-reserved

For a notation identity that remains ambiguous after mechanical resolution, an
agent SHALL NOT record a resolution; it MAY propose one for decision. A recorded
resolution SHALL reference the author decision that set it.

#### Scenario: Agent cannot resolve

- **WHEN** an agent attempts to record a resolution for an ambiguous notation
- **THEN** the action is refused and the resolution store is unchanged

#### Scenario: Author resolution records its decision

- **WHEN** the author records a resolution for an ambiguous notation
- **THEN** the resolution references the author decision and is used by
  subsequent extraction

### Requirement: Unresolved notation is reviewable

Every notation identity that cannot be resolved SHALL be reported with its
candidate owning blocks and the blocks that use it, and SHALL NOT be silently
dropped. The report SHALL state each notation's resolution state and the number
of dependency candidates its resolution would add.

#### Scenario: Unresolved notation is enumerated

- **WHEN** a notation identity is unresolved
- **THEN** the report names it with its candidate owners and the blocks whose
  uses depend on the resolution

#### Scenario: Previously dropped notation is visible

- **WHEN** extraction encounters a notation it cannot resolve
- **THEN** the notation appears in the report instead of producing no trace

### Requirement: Recovered edges are candidates until confirmed

An edge recovered through a recorded resolution SHALL enter the dependency graph
unconfirmed and SHALL NOT affect closure computation or any layer status until
it is confirmed through the edge-decision flow.

#### Scenario: Unconfirmed recovered edge does not enter closure

- **WHEN** a recovered edge is present but unconfirmed
- **THEN** closure computation and layer statuses are unchanged by it

#### Scenario: Confirming a recovered edge records the decision

- **WHEN** a recovered edge is confirmed
- **THEN** the confirmation is recorded with its source and the edge enters
  closure computation

### Requirement: Deterministic extraction and drift-checked report

Notation extraction SHALL be deterministic, an unparsable notation declaration
SHALL be reported as an error rather than skipped, and the notation report SHALL
be drift-checked like the project's other generated views.

#### Scenario: Same input yields the same result

- **WHEN** extraction runs twice on unchanged input
- **THEN** it produces the identical notation map and dependency candidates

#### Scenario: Unparsable declaration fails closed

- **WHEN** a notation declaration cannot be parsed
- **THEN** extraction reports it as an error and does not emit a partial map

#### Scenario: Report drift detected

- **WHEN** the notation data changes and the report is not regenerated
- **THEN** the report drift check fails
