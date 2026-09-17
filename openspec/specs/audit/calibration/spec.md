# calibration Specification

## Purpose

Measures audit detection at sample sizes and model pairings that make the
reported rates informative, and gates on a regression in detection.

## Requirements

### Requirement: Corpus scale per mutation type

The calibration corpus SHALL contain multiple cases per mutation type, over a
sampled set of audited blocks that spans statement, encoding, and proof checks,
and the corpus self-check SHALL report any mutation type with fewer than the
declared minimum number of cases.

#### Scenario: Type below minimum reported

- **WHEN** a mutation type has fewer cases than the declared minimum
- **THEN** the corpus self-check reports that type by name and fails

#### Scenario: Type at or above minimum

- **WHEN** every mutation type meets the declared minimum
- **THEN** the corpus self-check passes and reports the per-type counts

### Requirement: Generated mutation operators

The system SHALL provide a documented set of mutation operators that each take
an audited contract and produce a mutated read-back, and every corpus case SHALL
record the operator that produced it.

#### Scenario: Operator produces a mutation

- **WHEN** a mutation operator is applied to an audited contract
- **THEN** the resulting read-back differs from the control read-back

#### Scenario: Case records its operator

- **WHEN** a corpus case is generated
- **THEN** the case records the operator identifier that produced it

### Requirement: Detection reported with sample size

The calibration report SHALL state, for each mutation type, the number of cases
run, the number detected, the rate, and an uncertainty interval, and SHALL NOT
present a rate without its case count.

#### Scenario: Small sample is visibly uninformative

- **WHEN** a mutation type has a single case
- **THEN** the report shows the case count and an interval that shows the point
  estimate to be uninformative

### Requirement: Detection per model pair

The calibration report SHALL present detection per model pair (producer family
paired with comparator family) and SHALL state explicitly when only one model
pair exists.

#### Scenario: Single-pair run labeled

- **WHEN** the corpus is run with one producer and one comparator family
- **THEN** the report states that only one model pair was measured

#### Scenario: Multiple pairs reported separately

- **WHEN** the corpus is run under two distinct model pairs
- **THEN** the report gives a separate detection summary for each pair

### Requirement: Regression gate

The system SHALL compare a calibration run against a recorded baseline and SHALL
fail when the detection rate for a mutation type drops below the baseline
without a recorded explanation, and SHALL report a missing baseline rather than
passing.

#### Scenario: Detection drop blocks the change

- **WHEN** a run's detection rate for a mutation type is below its baseline and
  no explanation is recorded
- **THEN** the gate fails and names the mutation type

#### Scenario: No baseline recorded

- **WHEN** no baseline exists for a mutation type
- **THEN** the gate reports the absence of a baseline and does not report a pass
