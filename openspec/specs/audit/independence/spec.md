# independence Specification

## Purpose

Makes the independence of an audit's stages an explicit, computed property of
the evidence record, and surfaces same-model evidence as provisional rather
than as a pass.

## Requirements

### Requirement: Model registry

The system SHALL maintain a declared registry of models available for audit
stages, each entry carrying a stable identifier and a model family, and SHALL
reject an audit that names a model absent from the registry.

#### Scenario: Known model accepted

- **WHEN** an audit names a model present in the registry
- **THEN** the record is accepted and stores the model identifier and family

#### Scenario: Unknown model rejected

- **WHEN** an audit names a model absent from the registry
- **THEN** record creation fails with a message naming the unknown model

### Requirement: Computed independence classification

Every evidence record SHALL carry an `independence` classification computed
from structured fields, with one of the values `cross_model`, `same_model`,
`human`, or `build`. A record produced by a build SHALL be `build`; a record
produced by a human SHALL be `human`; an agent-produced record whose audit
stages all ran on one model family SHALL be `same_model`; and an
agent-produced record whose stages ran on two or more model families SHALL be
`cross_model`. The classification SHALL NOT be settable by free choice.

#### Scenario: Build record classified build

- **WHEN** a verification record is produced by the local pinned build
- **THEN** its independence classification is `build`

#### Scenario: Same-model two-stage audit

- **WHEN** a read-back stage and a comparator stage both run on the same model
  family
- **THEN** the correspondence record's independence classification is
  `same_model`

#### Scenario: Cross-model two-stage audit

- **WHEN** the read-back stage and the comparator stage run on different model
  families
- **THEN** the correspondence record's independence classification is
  `cross_model`

### Requirement: Derived independence caveat

The human-readable `independence_caveat` of an agent-produced record SHALL be
generated from structured fields (producer model, stage models, audit protocol,
and any inherited representation residuals) and SHALL NOT be a hand-entered
string.

#### Scenario: Identical inputs produce identical caveat

- **WHEN** two records are produced with the same model, protocol, and inherited
  residuals
- **THEN** their generated caveats are byte-identical

#### Scenario: Model change changes the caveat

- **WHEN** the model of a stage changes
- **THEN** the generated caveat changes to name the new model and the resulting
  classification

### Requirement: Same-model evidence cannot pass a cabinet layer

A layer whose highest-stakes current audit is classified `same_model` SHALL
report `provisional` rather than `pass`, unless the block's treatment tier is
`light`.

#### Scenario: Same-model correspondence is provisional

- **WHEN** a block's only current correspondence audit is `same_model` and the
  block is not `light`-tier
- **THEN** the correspondence layer status is `provisional`

#### Scenario: Cross-model correspondence passes

- **WHEN** a block's current correspondence audit is `cross_model`
- **THEN** the correspondence layer status is `pass`

#### Scenario: Light-tier block is exempt

- **WHEN** a `light`-tier block's current audit is `same_model`
- **THEN** the layer status remains `pass`

### Requirement: Routing preference

When an audit stage that requires independence is created, the system SHALL
select a model from a different family than the producer's whenever the registry
offers one, SHALL record the model chosen for every stage, and SHALL record
`same_model` rather than claim independence when no such model is available.

#### Scenario: Second family available

- **WHEN** the registry contains a second model family
- **THEN** the comparator stage is assigned a model from that family and the
  record names both stage models

#### Scenario: No second family available

- **WHEN** the registry contains a single model family
- **THEN** the record is written with classification `same_model` and no claim
  of independence

### Requirement: Reclassification is recorded, never silent

Introducing or changing the independence classification SHALL emit a journal
event and re-derive layer status, and SHALL NOT edit existing evidence records.

#### Scenario: Existing records become provisional

- **WHEN** the classification is introduced over a corpus of existing
  same-model records
- **THEN** a journal event records the reclassification, the records are
  unchanged on disk, and affected layers report `provisional`
