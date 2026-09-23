# Mslang

Lean 4 / Mathlib formalization of *Eilenberg theorems for many-sorted
formations*, together with the manuscript source and the block/evidence
provenance tooling that keeps the formalization and the paper in sync.

## Original paper

J. Climent Vidal and E. Cosme Llópez. *Eilenberg theorems for many-sorted
formations*. Houston Journal of Mathematics, 45(2):321–369, 2019.

## Layout

- `manuscript/` — the paper source (`MSEilenberg.tex`, typeset with `amsart`).
- `lean/` — the Lean 4 + Mathlib formalization (`lean/Mslang/`).
- `blocks/`, `evidence/`, `journal/`, `reports/` — block registry, evidence
  records, append-only journal, and generated audit views.
- `scripts/` — mechanical hygiene, audit, and bundle tooling.
- `Architecture.md`, `AGENTS.md`, `STATE.md` — process, operational rules, and
  the running session narrative.

## Build and check

- Manuscript: `scripts/build_manuscript.sh`
- Lean mechanical gate: `python3 scripts/lean_audit.py`
- Full mechanical gate: `scripts/check_all.sh` (`--fast` for the per-edit tier)

## License

The Lean formalization and tooling in this repository (`lean/`, `scripts/`, and
the supporting metadata) are released under the Apache License 2.0 — see
`LICENSE`. This matches the license of Mathlib, on which the formalization
depends.

`manuscript/` is an exception: it is the source of the published paper, which
remains under the copyright and terms of the Houston Journal of Mathematics and
is **not** covered by the Apache-2.0 grant above.
