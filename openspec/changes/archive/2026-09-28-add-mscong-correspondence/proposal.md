# Proposal

## Why

M1–M5 formalized the recognizability theorems of `MSCong.tex` entirely as
**unmapped infrastructure**: `mscong` is still a scaffold (`ingested: false`),
`blocks/mscong/` holds empty artifacts, `lean/declarations.mscong.json` maps no
declarations, and no evidence record exists. The formalization therefore has no
provenance, no block identities, and no audit trail tying the Lean theorems back
to the paper — the central promise of the evidence model.

**M6** is the last milestone of the M0 roadmap: a **correspondence audit for
MSCong using the evidence model**. Per the author's decision this session it is
scoped as a **pilot**: a small dependency-closed cluster tied to already-proven
Lean declarations, not a 247-environment contract freeze. The pilot mirrors the
`mslang` Phase 0 pilot (which chose the `B-D014`-centred cluster) and proves the
M0 prediction that only the `mslang` `\blockid` machinery needs to scale to a
second project.

## What Changes

- **Mint block IDs for the pilot cluster only.** Add `\blockid{}` for the
  `MSCong.tex` §3.1 *basic terms* cluster — the recognizability definition, the
  finite-index congruence definition and its filter proposition, and the three
  propositions `PRecVar`, `PRecConst`, `PRecOp` (IDs to be assigned in
  `design.md`; the `B-` prefix is the author's original choice, and `mslang` and
  `mscong` never collide because the ID spaces are checked by
  `projects.py --collisions`).
- **Flip `mscong.ingested: true`** and populate `blocks/mscong/` through the
  existing importer, so the anchor-hash, importer-drift, and cross-reference
  checks run for real for `mscong`.
- **Reconcile the two pre-existing label defects** the audit finds: the
  `\ref{PRecIt}` in a commented-out proof (line 2911) and the multiply-defined
  `\label{TAntiHom}` (lines 1779 and 1872). These are minimal correctness fixes
  to the source the importer must accept, not content edits.
- **Map the pilot declarations** in `lean/declarations.mscong.json`
  (`PRecVar`, `PRecConst`, `PRecOp`, and any pilot definition counterpart) so
  `lean_facets.py --project mscong` produces formal facets.
- **Run the two-stage blind correspondence audit** for the pilot propositions
  (the `mslang` Section 11.2 method) and record the verdicts as
  `evidence/mscong/E-*.json` through `scripts/evidence.py --project mscong`.
- **Give the evidence/status/view tools a project dimension** where the pilot
  needs it, so `status.py`, `closure.py`, and `report.py` can operate on
  `mscong` without touching the `mslang` golden baseline.
- **Defer** (recorded as an explicit caveat): mapping the remaining ~240
  environments, the `Sig_d`/`Alg_d` category layer, and `PRecILH`.

## Capabilities

### New Capabilities

- `formalization/mcong-correspondence`: the M6 deliverable for the `mscong`
  project — pilot block IDs, ingested provenance, the declaration map, the
  two-stage correspondence audits and their evidence records, the project
  dimension of the evidence/status/view tools, and the deferred full mapping.

### Modified Capabilities

- `orchestration/projects`: the evidence/status/view tooling gains a project
  dimension for a **second ingested project**, and the registry's `ingested`
  flag for `mscong` becomes `true`; the `mslang` default behaviour is unchanged.

## Impact

- `manuscript/MSCong.tex`: `\blockid{}`s for the pilot cluster plus the two
  label fixes; **no mathematical content change**.
- `projects.yaml`: `mscong.ingested: true` (and any newly needed path fields).
- `blocks/mscong/` becomes populated (registry, hashes, symbols, graph);
  `reports/mscong/` gains views; `evidence/mscong/` gains records;
  `journal/mscong.jsonl` gains events.
- `lean/declarations.mscong.json` gains the pilot entries;
  `lean/declarations.json`, `blocks/*.json`, and every `mslang` artifact are
  **untouched** (the golden baseline must stay current).
- **No** change to the `Mscong` Lean sources; no axiom or gate change.

## Note

The pilot cluster is deliberately the smallest set that exercises every part of
the M6 machinery end to end: a definition block, a proposition with a proof,
and three propositions whose Lean counterparts (`PRecVar`/`PRecConst`/`PRecOp`)
already exist and are `sorry`-free. Extending to the full manuscript is a
follow-on change with no new machinery.
