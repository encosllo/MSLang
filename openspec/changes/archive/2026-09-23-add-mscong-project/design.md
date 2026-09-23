# Design

## Context

See `proposal.md` — Why. Current state that shapes the approach:

- The provenance architecture (Architecture.md §25) was run once, to
  completion, on a single manuscript. Its tools name that manuscript directly:
  `scripts/check_all.sh` (lines 50–56), `scripts/ingest.py`,
  `scripts/hash_blocks.py`, `scripts/bundle.py`, `scripts/env.sh`
  (`MSLANG_MANUSCRIPT`), and `lean/declarations.json`.
- `lean/` is one Lake project with a `Mslang` namespace split by dependency
  layer (`Prelim → Algebra → Congruence → Subfinal`, plus `Free`, `Term`,
  `Translation`, `Formation`, `Regular`). Mathlib and the toolchain are shared.
- `manuscript/MSCong.tex` is tracked and, per the scoping pass, contains 249
  theorem-like items (89 propositions, 59 definitions, 14 corollaries, 3
  lemmas, 72 remarks). Its recognizability predicate is the same notion as
  `Mslang.IsRegularLanguage` (finite-index cogenerated-congruence saturation).

## Goals / Non-Goals

**Goals:**

- One declarative registry that names each manuscript project and its artifacts.
- Provenance/gate tooling that operates per project, with the existing
  MSEilenberg project as the default and its paths and behavior unchanged.
- A `Mscong` namespace scaffold in the shared Lake project, importing `Mslang`.
- A recorded formalization roadmap (reuse map, modules, milestones, risks).

**Non-Goals:**

- Formalizing MSCong's results. That is follow-on work, one change per
  milestone; this change only stands up the project and its scaffolding.
- Any edit to `MSEilenberg.tex` or `MSCong.tex`.
- Splitting into a second repository or a second Lake project.

## Decisions

### D1. Project registry is a single root data file

A root `projects.yaml` maps project id → `{source, aux, blocks_dir,
hashes, evidence_dir, journal, reports_dir, lean_declarations, lean_namespace}`.
Rationale: one authoritative place; tools stop hardcoding a filename; adding a
project becomes a data edit (spec: *Adding a project is a data change*).
Alternatives: per-project config files (more indirection, no single inventory);
a Python module of constants (not data-editable).

### D2. Default project keeps its existing paths; new projects are namespaced

The MSEilenberg entry points at the current top-level `blocks/`, `evidence/`,
`journal/events.jsonl`, `reports/`, `lean/declarations.json`. MSCong gets
project-scoped locations (e.g. `blocks/mscong/`, `evidence/mscong/`,
`journal/mscong.jsonl`, `reports/mscong/`, `lean/declarations.mscong.json`).
Rationale: preserves the default project byte-for-byte (spec: *Default project
preserved*) and isolates provenance (spec: *Per-project provenance isolation*).
Alternatives: move both projects under `projects/<id>/` (cleaner, but churns
every existing path and all evidence cross-references — rejected for now).

### D3. Identifier spaces are project-scoped

Block ids (`B-*`), evidence ids (`E-*`), and journal ids (`EV-*`) are allocated
within a project's scope. Rationale: avoids collisions without renumbering the
existing 129 blocks / 254 evidence records. Whether the shared preliminary
blocks are formalized once and referenced by both projects is deferred (Open
Questions).

### D4. Lean layout: `Mscong` namespace in the existing Lake project

```
lean/Mscong/Recognizable.lean   -- recognizability calculus (§2.3)
lean/Mscong/Substitution.lean   -- substitution, iteration, quotient
lean/Mscong/TreeHom.lean        -- hyperderivors, tree homomorphisms, Hall algebras, derivors
lean/Mscong/Main.lean           -- the PRec* recognizability theorems
```

`Mscong.*` imports `Mslang.*` for the shared foundations; no redefinition of
existing concepts. Same Lake project, toolchain, and Mathlib (spec is silent on
this — it is a structural choice, not a behavior contract).

### D5. Reuse map (what is reused vs. new)

| MSCong concept | Reused from `Mslang` |
|---|---|
| many-sorted sets, maps, support, products | `Prelim` |
| signatures, algebras, homomorphisms, subalgebras | `Algebra`, `Subfinal` |
| free algebra / terms `T_Σ(X)`, `W_Σ(X)` | `Term`, `Free` |
| congruences, quotients, kernels | `Congruence` |
| translations, cogenerated congruence `Ω` | `Translation` |
| saturation `[X]^Φ` | `Prelim` (`sat`, `satSets`) |
| recognizability (`Rec` = finite-index `Ω`-saturation) | `Regular` (`IsRegularLanguage`, `congCogenerated`, `IsFiniteIndex`) |

New work: the recognizability *calculus* (`Rec(A)`, `Rec_s(A)`, `δ^{s,L}`,
Boolean/product/subdirect closure, `(lf,s)`-recognition); substitution,
iteration, and quotient operators; hyperderivors and tree homomorphisms; Hall
algebras and derivors; and the recognizability theorems
(`PRecVar/Const/Op`, `PRecSubs`, `PRecQ`, `PRecH`, `PRecLH`, `PRecILH`).

### D6. Finiteness hypotheses are explicit

Several headline results assume `S` (and sometimes `X`, `Σ`) finite. These are
encoded as explicit typeclass hypotheses, and any place the manuscript assumes
finiteness without stating it is recorded as a `formal_weaker` correspondence
finding — the lesson from `B-X001` in §25.

### D7. Roadmap (design-level; each milestone is a future change)

- **M0** — this change: registry + tooling parameterization + `Mscong` scaffold.
- **M1** — recognizability calculus.
- **M2** — basic terms (`PRecVar/Const/Op`).
- **M3** — substitution / iteration / quotient (`PRecSubs`, `PRecQ`).
- **M4** — tree homomorphisms (`PRecH`, `PRecLH`, `PRecILH`).
- **M5** — derivors and Hall algebras.
- **M6** — correspondence audit for MSCong using the evidence model.

## Risks / Trade-offs

- **Tooling refactor silently changes default-project artifacts** → keep the
  default paths, and add a golden check that the MSEilenberg registry, hashes,
  and bundle are byte-identical before and after the refactor.
- **Identifier collisions across projects** → project-scoped id allocation (D3);
  a test asserting no cross-project id collision.
- **Category-theoretic content (Hall algebras, signature/derivor category,
  adjunctions) resists the encoding** → treat M5 as its own decision-gated
  milestone, mirroring the deferred `B-C003` adjunction; do not let it block
  M1–M4.
- **Gate cost grows with projects** → fast tier stays per-edit and per-project;
  slow tier remains one run per session; a project is selectable by id.
- **Evidence/journal semantics for a second project** → default project
  unchanged; MSCong's records live in its own scope (D2), with the id-space
  question deferred.

## Migration Plan

1. Add `projects.yaml` containing only the MSEilenberg project; teach each tool
   to read it; assert MSEilenberg artifacts are byte-identical.
2. Add the MSCong registry entry and its project-scoped artifact locations.
3. Scaffold `lean/Mscong/` importing `Mslang`; confirm the shared build.
4. Extend `check_all.sh` to iterate registered projects.
5. Update `AGENTS.md` / `STATE.md` / `Architecture.md` for the second project.

Rollback: the registry is additive and the tools keep a single-project fallback;
reverting the tool commits restores the prior behavior.

## Open Questions

- Should blocks shared by both papers be formalized once in `Mslang` and
  referenced by `Mscong`, or formalized per project?
- Are evidence/journal ids globally unique or per-project sequences?
- Does MSCong get its own calibration corpus and model registry entry, or reuse
  the existing one?
