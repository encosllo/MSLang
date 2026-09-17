# Proposal

## Why

The project's evidentiary machinery is unusually thorough, but three gaps let
its rigor be asserted rather than demonstrated, and a fourth caps the rate at
which the work can proceed:

- **Independence is documented, not achieved or enforced.** Of 66
  correspondence records, 48 carry an identical caveat saying both blind stages
  share one model. Nothing in the pipeline detects this or marks the affected
  claims as provisional.
- **Audit reliability is not measured at a useful sample size.**
  `reports/calibration.md` reports 7/7 detection with **n=1 per mutation type**
  over 4 blocks and a single model; that is a smoke test, not a detection rate,
  and no per-model-pair measurement exists.
- **Reports accumulate rows without dispositions.** `reports/discrepancy.md`
  lists 328 "formal-only" rows with 3 reviewer notes; the frontier lists 54
  unmapped blocks with no triage. A list no one can act on is worse than no
  list, because it reads as coverage.
- **The loop back to the manuscript is open.** Formalization has already
  produced reconstructed proofs (`B-C001`, `B-C002`), a simplification, and a
  proof of a **commented-out** proposition, none of which has a path back into
  the prose; they have sat unaccepted for 60+ sessions.
- **Throughput is capped by a monolithic gate.** `check_all.sh` runs 27 checks
  including a full Lean axiom audit and a PDF build; the project policy budgets
  one run per session, which is ~2.5 min of `import Mathlib` reload for every
  edit.

This change makes independence machine-checked and visible, measures audit
detection at real sample sizes per model pair, converts reports into countable
queues, closes the manuscript loop, triages scope, and tiers the gate so the
common edit is cheap.

## What Changes

- **Structured independence in evidence records.** A record's producer model
  and audit protocol produce a computed `independence` classification
  (`cross_model`, `same_model`, `human`, `build`). The free-text
  `independence_caveat` is derived from structured fields rather than retyped,
  eliminating the copy-paste drift that produced 48 identical strings.
- **Independence gates status.** A layer whose highest-stakes audit is
  `same_model` reports `provisional`, not `pass`, unless the block is
  author-designated `light`-tier. **BREAKING**: existing same-model
  correspondence records currently reading `pass` will read `provisional`.
- **Model routing and a model registry.** A declared registry of available
  models; the coordinator routes read-back/comparator/adversarial stages to a
  model different from the producer where one is available, and records the
  pairing.
- **Calibration at scale, per model pair.** Mutation operators generate many
  cases per type across a sampled set of audited blocks; the report gives
  counts and an uncertainty interval per type, and detection per model pair,
  and gates on a regression.
- **Dispositions instead of raw row volume.** Formal-only edges gain a typed
  disposition store with a default classification rule; the report collapses
  default-category rows and surfaces only undecided rows as a countable queue.
- **Manuscript reconciliation view.** Every formalization-produced proposal to
  change the prose (reconstructed proof, simplification, now-proven commented
  result, statement correction) is registered with an author acceptance state;
  a view lists the open proposals and what accepting each one edits.
- **Scope triage for unmapped blocks.** Each unmapped confirmed block carries a
  scope disposition (`worth-formalizing` / `deferred` / `out-of-scope`), so the
  frontier shows a triaged plan rather than an undifferentiated 54-item list.
- **Tiered gate.** `check_all` splits into a fast tier (no Lean, no PDF;
  seconds) and a slow tier (Lean axioms, sorry scan, PDF, report drift), with a
  single orchestrator; the fast tier is the default per-edit gate.

## Capabilities

### New Capabilities

- `audit/independence`: model registry, routing policy, computed independence
  classification, derived caveat, and the proof/status gating that makes
  same-model evidence visible as provisional.
- `audit/calibration`: the seeded-mismatch corpus, mutation operators, sampling
  across audited blocks, and detection reporting per mutation type and per
  model pair with explicit sample sizes.
- `dependencies/discrepancy`: typed dispositions for formal-only and
  informal-only edges, a default classification rule, and a report that
  surfaces an undecided queue rather than every row.
- `reporting/reconciliation`: a registered catalogue of formalization-produced
  manuscript proposals and an acceptance workflow that closes the loop from
  Lean back to the prose.
- `scheduling/frontier`: per-block scope dispositions for confirmed-but-unmapped
  blocks and a frontier view that reports a triaged plan.
- `orchestration/gate`: the fast/slow check tiers, their membership, the
  orchestrator entry point, and the exit-code contract.

### Modified Capabilities

None. The project has no existing OpenSpec specs; all capabilities above are
introduced by this change. Behavioural changes that the project's normative
`Architecture.md` text describes (Sections 9, 11.4, 12.2, 19, 21) are updated as
implementation work under this change and recorded as a new Architecture
revision, not as a spec delta.

## Impact

- **Schemas**: `schemas/evidence.schema.json` (new `independence` object;
  `independence_caveat` becomes derived), possibly
  `schemas/journal_event.schema.json` (new event kinds for reconciliation
  acceptance and scope disposition).
- **Scripts**: `evidence.py`, `status.py`, `trust.py`, `calibration.py`,
  `discrepancy.py`, `frontier.py`, `report.py`, `check_all.sh`; new scripts for
  the model registry/routing, reconciliation, and the gate orchestrator.
- **Data stores**: new `calibration/models.json`; new dispositions for edges and
  for block scope; new proposal catalogue.
- **Views**: `reports/discrepancy.md`, `reports/frontier.md`,
  `reports/calibration.md`, new reconciliation view; `check_all` check count
  changes.
- **Existing evidence**: reclassification of 48 same-model correspondence
  records from `pass` to `provisional` is a visible status change and needs a
  journal event; records themselves are append-only and are not edited.
- **Normative doc**: `Architecture.md` requires a new revision to match the
  changed behaviour (Sections 9, 11.4, 12.2, 19, 21); `STATE.md` records the
  session.
- **Out of scope**: obtaining a second model is an environment/author matter;
  this change makes the routing and measurement *correct and honest* whether or
  not a second model is available.
- **Recorded assumption**: OpenSpec is used here purely as the planning vehicle
  for this change; `Architecture.md` remains the normative source of truth. A
  decision to migrate the normative record into OpenSpec specs is explicitly not
  taken by this change (see design.md, Decisions).
