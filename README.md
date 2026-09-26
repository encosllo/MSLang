# MSLang — many-sorted languages

Lean 4 / Mathlib formalizations of **several papers on many-sorted algebra and
language theory**, each living next to its manuscript source and behind a
shared block/evidence provenance pipeline that keeps the formalization and the
paper in sync.

MSLang is a workspace, not a single development. Each paper is registered as a
*project* in `projects.yaml`; the tooling resolves every project's manuscript,
block registry, evidence, journal, and Lean declaration map from that registry,
runs the mechanical gate once per project, and reports per-project status. The
projects share one Lake/Mathlib build and one foundation of many-sorted sets,
terms, free algebras, congruences, saturation, and finite-index
recognizability.

## Projects

| id | paper | Lean namespace | status |
|---|---|---|---|
| `mslang` (default) | *Eilenberg theorems for many-sorted formations* — J. Climent Vidal & E. Cosme Llópez, Houston J. Math. 45(2):321–369, 2019 | `Mslang` | formalized; provenance ingested |
| `mscong` | *Congruence-based proofs of the recognizability theorems for free many-sorted algebras* — J. Climent Vidal & E. Cosme Llópez, Journal of Logic and Computation 30(2):561–633, 2020. doi:[10.1093/logcom/exz032](https://doi.org/10.1093/logcom/exz032) | `Mscong` | in progress (through M3; M4 partial) |

`Mscong.*` shares this Lake project and Mathlib and imports `Mslang.*`, so the
recognizability development reuses the `Mslang` preliminaries rather than
redefining them.

## What is here

- `manuscript/` — the paper sources (`MSEilenberg.tex`, `MSCong.tex`, typeset
  with `amsart`).
- `lean/` — the Lean 4 + Mathlib formalization (`lean/Mslang/`, `lean/Mscong/`).
- `blocks/`, `evidence/`, `journal/`, `reports/` — per-project block registry,
  append-only evidence records and journal, and generated audit views (coverage,
  trust boundary, discrepancy, frontier, bundle, …).
- `scripts/` — mechanical hygiene, audit, and bundle tooling;
  `scripts/check_all.sh` runs the whole gate, once per registered project.
- `Architecture.md`, `AGENTS.md`, `STATE.md` — the process specification, the
  operational rules, and the running session narrative.

## Build and check

- Manuscript: `scripts/build_manuscript.sh [--project <id>]`
- Lean mechanical gate: `python3 scripts/lean_audit.py --project <id>`
- Full mechanical gate: `scripts/check_all.sh` (`--fast` for the per-edit tier)
- Project registry: `python3 scripts/projects.py --check` / `list`

## License

The Lean formalization and tooling in this repository (`lean/`, `scripts/`, and
the supporting metadata) are released under the Apache License 2.0 — see
`LICENSE`. This matches the license of Mathlib, on which the formalization
depends.

`manuscript/` is an exception: it contains the sources of published papers,
which remain under their respective journal copyright and terms and are **not**
covered by the Apache-2.0 grant above.
