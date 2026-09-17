# Spec Delta

## Purpose

Provides a fast per-edit gate and a slow close-of-session gate through one
orchestrator, without weakening the all-checks exit-code contract.

## ADDED Requirements

### Requirement: Fast tier

A fast gate SHALL run every check that requires neither Lean compilation nor a
manuscript PDF build, SHALL complete in seconds, and SHALL be the default gate
for ordinary edits.

#### Scenario: Fast tier avoids heavy tools

- **WHEN** the fast gate runs
- **THEN** it invokes neither the Lean mechanical audit nor the manuscript build

#### Scenario: Fast tier reports failures by exit code

- **WHEN** a fast check fails
- **THEN** the fast gate prints the failing check and exits non-zero

### Requirement: Slow tier

A slow gate SHALL run the complete check set, including the Lean mechanical
audit and the manuscript build, and its result SHALL be the artifact of record
at session close.

#### Scenario: Slow tier includes heavy checks

- **WHEN** the slow gate runs
- **THEN** it runs the Lean axiom and sorry audit and the manuscript build

#### Scenario: Slow tier is the record

- **WHEN** a session closes
- **THEN** the slow gate's result is the one recorded as the session's gate
  result

### Requirement: Single orchestrator with deterministic order

One orchestrator entry point SHALL expose the fast tier, the slow tier, and the
existing all-checks behaviour, and SHALL run checks in a deterministic order
that respects data dependencies, regenerating or verifying generated views only
after the data they consume is current.

#### Scenario: Both tiers selectable

- **WHEN** the orchestrator is invoked without a tier argument
- **THEN** it runs the slow tier, and a fast-tier flag selects the fast tier

#### Scenario: Order respects dependencies

- **WHEN** the orchestrator runs
- **THEN** view-drift checks run after the checks that produce their inputs

### Requirement: Deferred checks are not passes

In the fast tier, a check that the fast tier intentionally does not run SHALL be
reported as deferred and SHALL NOT be reported as passing.

#### Scenario: Deferred check labeled

- **WHEN** the fast gate runs and a check belongs only to the slow tier
- **THEN** the fast gate reports that check as deferred rather than as a pass

### Requirement: Exit-code contract preserved

Both tiers SHALL print a PASS or FAIL line per check and SHALL exit non-zero if
any check that ran failed.

#### Scenario: Any failure fails the gate

- **WHEN** one or more executed checks fail
- **THEN** the orchestrator exits non-zero and lists the failed checks
