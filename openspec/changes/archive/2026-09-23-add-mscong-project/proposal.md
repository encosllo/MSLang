# Proposal

## Why

The workspace completed a full formalization of `manuscript/MSEilenberg.tex`,
but every provenance tool is hardwired to that one file: `scripts/check_all.sh`,
`scripts/ingest.py`, `scripts/hash_blocks.py`, `scripts/bundle.py`,
`scripts/env.sh`, `lean/declarations.json`, and the gate all name
`MSEilenberg.tex`, `blocks/`, and `lean/Mslang` directly. A second, closely
related paper is now being formalized in the same Lean/Lake project —
`manuscript/MSCong.tex`, *"Congruence based proofs of the recognizability
theorems for free many-sorted algebras"* — and its content reuses the existing
`Mslang` infrastructure (many-sorted sets, signatures, algebras, free
algebras/terms, congruences, translations, cogenerated congruence,
recognizability). Without multi-manuscript support, the second project either
forks the tooling or silently loses the provenance, gate, and evidence
guarantees the first project depended on.

## What Changes

- Introduce a **project registry** declaring each manuscript project: a stable
  project id, its TeX source and `.aux`, its block registry and hash anchors,
  its evidence/journal/report scope, and its Lean namespace and declaration
  map.
- **Parameterize the provenance tooling** (`ingest.py`, `hash_blocks.py`,
  `check_all.sh`, `bundle.py`, `lean_facets.py`/`declarations.json`, `env.sh`)
  to operate per project instead of against hardwired paths.
- Keep the existing **MSEilenberg project as the first/default project** and
  preserve its current behavior and artifact paths; the second project is
  additive.
- **Scaffold the `Mscong` Lean namespace** in the existing `lean/` Lake project
  (sharing Mathlib), with modules for recognizability, substitution/iteration/
  quotient, tree homomorphisms, and the recognizability theorems.
- Record the **MSCong formalization roadmap** (reuse map, module layout,
  milestones, risks) as design input; the per-result formalization itself is
  **not** part of this change.

## Capabilities

### New Capabilities

- `orchestration/projects`: a multi-manuscript project registry, and per-project
  operation of the ingestion, hashing, gate, evidence, and bundle tooling, with
  the existing single-manuscript behavior preserved as the default project.

### Modified Capabilities

<!-- None at the spec level: the gate/ingest requirements ("run every check",
     "verify generated views are current") are unchanged; this change widens the
     configured set of projects those requirements apply to, which the new
     capability specifies. -->

## Impact

- `scripts/`: `env.sh`, `ingest.py`, `hash_blocks.py`, `check_all.sh`,
  `bundle.py`, `lean_facets.py`, `lean_audit.py`, and the regeneration chain
  gain a project dimension.
- `blocks/`, `evidence/`, `journal/`, `reports/`: scoped per project (MSCong
  gets its own registry/hashes/evidence, or a namespaced equivalent).
- `lean/`: a new `Mscong` namespace alongside `Mslang`, sharing the Lake
  project and Mathlib.
- `AGENTS.md`, `STATE.md`, `Architecture.md`: the operational rules and the
  cost model extend to a second project.
- No manuscript content changes; `manuscript/MSCong.tex` is already tracked.
