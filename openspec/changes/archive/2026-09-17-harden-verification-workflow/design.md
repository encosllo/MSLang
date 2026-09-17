# Design

## Context

See `proposal.md` - Why. The relevant current state:

- `schemas/evidence.schema.json` has `additionalProperties: false`; the only
  independence signal is the optional free-text `independence_caveat`, and
  `producer.model` already records a model but nothing consumes it.
- `scripts/status.py` derives `none | in_progress | pass | fail | stale` from
  current records; `closure.py`, `trust.py`, `frontier.py`, `report.py` all
  consume that model.
- `evidence/` is **append-only** (`scripts/check_evidence_immutability.sh`, the
  pre-commit hook): the 161 existing records must not be edited, only superseded.
- `scripts/calibration.py` reads `calibration/seeded.json` (11 cases, one per
  mutation type, 4 blocks) and `calibration/verdicts.json`, and renders
  `reports/calibration.md`; it groups by mutation type only.
- `scripts/discrepancy.py` already accepts `--notes blocks/discrepancy_notes.json`
  keyed `FROM->TO` (3 notes), rendered as a flat "Reviewer notes" list after all
  328 rows.
- `scripts/frontier.py` lists unmapped blocks with no disposition, and reads
  `decisions/standing.json` (empty) and journal escalations.
- `scripts/check_all.sh` is the single entry point (27 checks) and runs the Lean
  audit and the PDF build in one monolithic pass.
- The normative behaviour text lives in `Architecture.md` (Sections 8, 9, 11.4,
  12.2, 19, 21), which is a doc change, not code.
- No second model is guaranteed to exist in the environment; `scripts/evidence.py`
  hardcodes `--model` default `deepseek-v4.1-flash`.

## Goals / Non-Goals

**Goals:**

- Make independence a computed, schema-validated property, and make same-model
  evidence visibly provisional without editing a single existing record.
- Make calibration report a count and an interval, per mutation type and per
  model pair, from generated cases over a sampled universe.
- Turn the discrepancy and frontier reports into countable queues with recorded
  dispositions.
- Give formalization-produced manuscript proposals a catalogue, a view, and an
  acceptance path that closes the loop back to the prose.
- Make the common edit cost seconds by tiering the gate, without weakening the
  session-close gate.

**Non-Goals:**

- Obtaining, budgeting, or selecting a second model (environment/author matter;
  the design is honest with zero, one, or many).
- Migrating `Architecture.md` into OpenSpec specs; this change plans against
  Architecture as the normative source and updates it as a revision.
- Auto-accepting any author-reserved decision (proposal acceptance, scope
  disposition, treatment tier).
- Rewriting the 161 existing evidence records.

## Decisions

### D1. Independence is a structured, computed object, not a boolean or free text

`independence_caveat` becomes derived from a structured `independence` object:
`class` (`cross_model` / `same_model` / `human` / `build`) plus per-stage model
families, computed by one function shared by `evidence.py` (write path) and
`status.py` (read path). A boolean `independent: true|false` was rejected
because it loses the build/human distinction and the model-pair identity that
calibration needs; keeping free text was rejected because it is unenforceable
and produced 48 identical strings.

**Legacy records are classified on read, not rewritten.** Because `evidence/`
is append-only, `classify_record()` derives the class for records lacking the
field from their existing `producer` and protocol (uniformly `same_model`
today). New records store the object. A golden test pins the classification of
the current corpus so the derivation cannot drift.

### D2. A distinct `provisional` layer status

`status.py` gains a `provisional` value. Reusing `stale` was rejected (stale
means an input hash moved, which is a different fact); reusing treatment tiers
was rejected (tiers are author-designated while provisional is mechanical).
`provisional` sits between `pass` and `in_progress`: a current positive record
whose independence is insufficient for the block's tier. Every consumer of the
status enum (`frontier.py`, `report.py`, `trust.py`, `impact.py`) is updated and
covered by a test.

### D3. Routing is a coordinator duty the repo validates, not a runtime intercept

The repository cannot call a model, so `scripts/models.py` provides: the registry
(`calibration/models.json`), `choose_stages(registry, producer_family)` returning
the per-stage models and the resulting class, and a `--check` that validates
recorded pairings against the registry. Enforcement is at write time (schema +
registry) and at report time (provisional status), not by intercepting a call.

### D4. Wilson interval, dependency-free

Per-type detection reports `n`, `detected`, rate, and a Wilson score interval
computed in pure Python, preserving the repo's dependency-free posture
(`validate_records.py` already avoids `jsonschema`). Normal approximation was
rejected (degenerate at `p = 1` and small `n`); a Bayesian posterior was
rejected as unnecessary.

### D5. Mutation operators over a sampled universe, deterministically

`calibration/seeded.json` grows a `cases` set produced by named operators
applied to read-backs sampled from the mapped universe under a fixed seed, so a
run is reproducible and a type can reach `n > 1`. Hand-authoring hundreds of
cases was rejected (toil and drift); exhaustive coverage was rejected (not every
block has a read-back, and the cost is unbounded). The corpus self-check keeps
requiring controls, so a frozen control still guards false positives.

### D6. Discrepancy dispositions evolve the existing notes file

`blocks/discrepancy_notes.json` is superseded by a structured
`blocks/discrepancy_decisions.json` carrying `{from, to, disposition, note,
decided_by}`; the reader remains backward-compatible with the old `notes` map
so the 3 existing notes migrate without loss. Default rules live in a named,
inspectable table in `discrepancy.py` (e.g. "target is the carrier block" ->
`type-carrier`), and the renderer collapses default-classified rows into counts
while enumerating only undecided rows. A parallel store was rejected (two
sources of truth).

### D7. Reconciliation is a catalogue, not evidence

`reconciliation/proposals.json` holds proposals with a stable id, kind, source,
target blocks, proposed prose change, state, and decision reference. It is
**not** an evidence record and changes no layer status. Explanations produced by
`ingest.py` are registered as `reconstructed-proof` proposals so the two
existing ones stop being invisible. Acceptance is refused unless
`--decided-by author:...` is given.

### D8. Acceptance edits the manuscript in a separate, guarded session

Because accepting a proposal changes `manuscript/MSEilenberg.tex` (which stales
hashes across the project and must be edited as latin1, never by a generic
text-edit tool - `AGENTS.md`), acceptance records the *proposed* edit and the
resulting manuscript hash, but the manuscript edit itself is performed by the
latin1 read/modify/write procedure and followed by `hash_blocks.py`,
`ingest.py`, `lean_facets.py`, and the gate. The catalogue records the resulting
hash; it never performs the edit implicitly.

### D9. Scope dispositions live beside the edge decisions

`blocks/scope_decisions.json` mirrors `blocks/edge_decisions.json`; `frontier.py`
groups unmapped blocks by disposition and excludes `out-of-scope` from the open
obligations while counting it. No status or evidence changes: scope is a
scheduling fact, not a proof fact.

### D10. The gate stays `check_all.sh`, gains a fast tier

`check_all.sh` becomes the orchestrator with `--fast` (default remains the full
run, preserving every existing invocation in docs, hooks, and `STATE.md`). The
fast tier is defined as the checks requiring neither Lean nor `latexmk`;
Lean-dependent checks print `deferred` rather than `pass`. A Makefile or task
runner was rejected: it adds a dependency the repo does not have, and the
existing bash+python posture is deliberate. `AGENTS.md`'s "one `lean_audit.py`
and one `check_all.sh` per session" is restated as "fast gate per edit, slow gate
once at session close".

### D11. Architecture.md gets a Revision 5

The changed status vocabulary, independence model, calibration reporting, and
gate tiering are normative, so `Architecture.md` is revised (Section 25 change
log) in the same session the code lands. This is a plan artifact of the change,
not a spec delta; OpenSpec here is the planning vehicle only.

## Risks / Trade-offs

- **[Adding a status value breaks a consumer that assumes the old enum]** ->
  grep every reader of layer status, update `frontier.py`, `report.py`,
  `trust.py`, `impact.py`, and `status_test.py`; add an explicit test that the
  new value propagates.
- **[The whole correspondence corpus flips to `provisional`, read as a
  regression]** -> this is the intended, honest outcome; mitigate perception by
  reporting the provisional count with what would clear it, and by the `light`
  tier exemption. Record the flip as a journal event, not a silent status change.
- **[No second model available, so routing cannot upgrade anything]** -> the
  design still yields the correct `same_model` classification; a second model is
  an author/environment decision surfaced in the reconciliation/decision queue,
  not a blocker.
- **[Generated mutations are trivially detected, inflating the rate]** ->
  operators are reviewed against the existing hand-written cases, controls stay
  mandatory, and the interval plus `n` are reported so an inflated rate is
  visible.
- **[Accepting a proposal corrupts the latin1 TeX or stales the project
  silently]** -> D8: acceptance never edits implicitly; the edit uses the
  mandated latin1 procedure and is followed by the full re-hash chain.
- **[Fast tier lets a Lean break slip through]** -> the slow tier is mandatory
  at session close and is the recorded result; `AGENTS.md` and the `STATE.md`
  safe-restart checklist are updated.
- **[Default disposition rules over-collapse a real hidden dependency]** ->
  defaults are named and inspectable, the report shows per-category counts, and
  any disposition can be overridden by a recorded decision.

## Migration Plan

Shadow-first, so nothing gating is turned on before it is observed to be
correct. Each step is independently revertable and leaves `evidence/` untouched.

1. Add the `independence` object to the schema and `classify_record()`; run in
   shadow mode (compute and report, do not gate). Verify the 48 known records
   classify `same_model` and no other record changes class.
2. Turn on the `provisional` status and emit the reclassification journal event;
   regenerate views.
3. Add the model registry and `models.py` routing check.
4. Expand calibration (operators, sampler, Wilson, per-pair); record a baseline.
5. Migrate discrepancy notes to dispositions, add default rules, collapse the
   report.
6. Add scope dispositions and frontier triage.
7. Add the reconciliation catalogue and view; register the two existing
   Explanations.
8. Split the gate, add `--fast`, update `AGENTS.md` and `STATE.md`.
9. Revise `Architecture.md` (Revision 5).

**Rollback:** steps 3-7 are additive stores and views and can be reverted
without touching evidence; step 2's gate can be disabled by a flag while keeping
the computed classification in reports; steps 8-9 are doc/entry-point changes.
No step rewrites an existing evidence record.

## Open Questions

- Whether the author wants to obtain a second model, and which, is deferred; it
  does not change the specs, the approach, or the task breakdown (the design is
  correct with zero, one, or many models).
- The exact declared minimum cases per mutation type is deferred to
  implementation; it does not change the approach, only a constant in the
  corpus self-check.
