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
