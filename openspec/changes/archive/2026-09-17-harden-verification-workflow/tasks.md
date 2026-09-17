# Tasks

## 1. Independence classification

- [x] 1.1 Add the `independence` object (`class` plus per-stage model families)
  to `schemas/evidence.schema.json` and keep `additionalProperties: false`;
  verify `python3 scripts/validate_records.py` and
  `python3 scripts/validate_records.py --self-test` still pass and a fixture
  record with the object validates.
- [x] 1.2 Implement a single `classify_record()` used by both
  `scripts/evidence.py` (write path) and `scripts/status.py` (read path), with
  legacy records lacking the field classified from their existing `producer`
  and protocol; verify a golden test pins the class of the current corpus
  (48 correspondence records `same_model`, build records `build`).
- [x] 1.3 Derive `independence_caveat` from the structured fields instead of
  accepting a hand-entered string; verify a test asserts byte-identical caveats
  for identical inputs and a changed stage model changes the caveat, and that
  existing records on disk are unmodified.
- [x] 1.4 Add the `provisional` layer status to `scripts/status.py` and update
  every status consumer (`scripts/frontier.py`, `scripts/report.py`,
  `scripts/trust.py`, `scripts/impact.py`); verify `scripts/status_test.py`
  covers a same-model record reporting `provisional` and a cross-model record
  reporting `pass`, and a `light`-tier block staying `pass`.
- [x] 1.5 Run classification in shadow mode and verify the computed report over
  the corpus changes no other class; then enable the gate, emit a
  reclassification journal event, and verify `reports/frontier.md` and
  `reports/coverage.md` regenerate with the drift checks passing.

## 2. Model registry and routing

- [x] 2.1 Add `calibration/models.json` declaring available models with
  identifiers and families; verify a loader rejects an audit naming an
  unregistered model.
- [x] 2.2 Implement `scripts/models.py` with `choose_stages()` and `--check`;
  verify a test where two families yield `cross_model` and one family yields
  `same_model` with no independence claim.
- [x] 2.3 Wire stage model choices into record creation; verify a created
  record validates against the schema and carries the computed `independence`
  object.

## 3. Calibration at scale

- [x] 3.1 Implement the named mutation operators and a deterministic sampler
  over the mapped universe that generates cases into
  `calibration/seeded.json`; verify `python3 scripts/calibration.py --self-test`
  reports per-type counts and fails a type below the declared minimum.
- [x] 3.2 Extend `scripts/calibration.py` to report per type the case count,
  detected count, rate, and a dependency-free Wilson interval; verify
  `scripts/calibration_test.py` checks that a rate is never rendered without
  its `n` and that a single-case type is shown as uninformative.
- [x] 3.3 Add per-model-pair detection reporting; verify the report states
  explicitly when only one model pair was measured and gives separate summaries
  for two pairs.
- [x] 3.4 Record a detection baseline and add a regression gate; verify
  `scripts/calibration.py --check-baseline` fails on a simulated drop, passes
  an unchanged run, and reports a missing baseline rather than passing.
- [x] 3.5 Run the full calibration and regenerate `reports/calibration.md`;
  verify the calibration report drift check in `scripts/check_all.sh` passes.

## 4. Discrepancy dispositions

- [x] 4.1 Add `blocks/discrepancy_decisions.json` (typed dispositions keyed
  `FROM->TO` with `decided_by`) and a reader that migrates the 3 existing
  `blocks/discrepancy_notes.json` entries; verify all 3 load as dispositions
  and an unknown disposition value is rejected.
- [x] 4.2 Implement the documented default classification rules; verify a rule
  classifies an edge whose target is the carrier block as `type-carrier` and
  that an unmatched edge remains undecided.
- [x] 4.3 Update `render_report` to state an undecided count, enumerate only
  undecided edges, and collapse default-classified edges into per-category
  counts; verify `scripts/discrepancy_test.py` passes and
  `scripts/discrepancy.py --check-report` reports current after regeneration.
- [x] 4.4 Assert dispositions are not evidence; verify a test shows recording a
  disposition changes no block's layer status.

## 5. Scope triage for unmapped blocks

- [x] 5.1 Add `blocks/scope_decisions.json` with a reader that reports a block
  with no disposition as undecided; verify a disposition survives registry
  regeneration.
- [x] 5.2 Update `scripts/frontier.py` to group unmapped blocks by disposition,
  report decided versus undecided counts, and exclude `out-of-scope` from the
  open obligations while counting it; verify `scripts/frontier.py
  --check-report` passes after regeneration.
- [x] 5.3 Present the scope-triage decision brief for the 54 unmapped blocks
  (author-reserved): verify the agent records only proposed dispositions and
  cannot set one, and the decision is recorded in the journal when made.

## 6. Manuscript reconciliation

- [x] 6.1 Add `reconciliation/proposals.json` and a writer that registers
  proposals and refuses to set state to `accepted`/`rejected` without
  `--decided-by author:...`; verify the refusal path with a test.
- [x] 6.2 Register the two existing `blocks/explanations/*.md` as
  `reconstructed-proof` proposals; verify the catalogue contains two `open`
  proposals naming their blocks and source records.
- [x] 6.3 Add the reconciliation view as a generated, drift-checked report;
  verify a test detects drift when the catalogue changes without regeneration.
- [x] 6.4 Implement the acceptance close-the-loop path: on an author decision,
  perform the latin1 manuscript edit, re-run `hash_blocks.py`, `ingest.py`, and
  `lean_facets.py`, and record the resulting manuscript hash; verify an accepted
  proposal cites the hash and dependent evidence is re-evaluated for currency.
  (Manuscript edit and decision are author-performed.)

## 7. Tiered gate

- [x] 7.1 Refactor `scripts/check_all.sh` into `--fast` and full tiers with a
  shared check list, printing `deferred` for slow-only checks in fast mode;
  verify the fast run invokes neither the Lean audit nor `latexmk`, a seeded
  failing check makes it exit non-zero, and the full run still executes both
  heavy checks.
- [x] 7.2 Add the new test and drift checks (models, calibration baseline,
  discrepancy, frontier, reconciliation) to the appropriate tier; verify the
  orchestrator's PASS/FAIL count updates and `scripts/check_all.sh` exits 0.
- [x] 7.3 Update `AGENTS.md` and the `STATE.md` safe-restart checklist from
  "one `lean_audit.py` and one `check_all.sh` per session" to "fast gate per
  edit, slow gate once at session close"; verify both documents state the tiers
  and their membership.

## 8. Normative documentation and close-out

- [x] 8.1 Revise `Architecture.md` to Revision 5 covering the status
  vocabulary (Section 8), independence model (Section 9), calibration reporting
  (Section 11.4), discrepancy dispositions (Section 12.2), frontier triage
  (Section 19), and gate tiering (Section 21); verify the Section 25 change log
  entry exists and the revised sections match the shipped behaviour.
- [x] 8.2 Run the slow gate once and record the result in `STATE.md` and a
  journal event; verify `scripts/check_all.sh` exits 0 and the session entry
  names the gate result and the new journal event id.
