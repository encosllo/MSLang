# Design

## Context

See `proposal.md` - Why. The current `scheduling/ranking` implementation
(`scripts/ranking.py`, `blocks/ranking.json`, `reports/ranking.md`) holds exactly
one goal; `validate` rejects more than one, and the forward rank restarts at that
single goal. The ranked-ancestor and readiness logic is reusable as-is.

## Goals / Non-Goals

**Goals:**

- Record and use a goal set.
- Recommend the shared foundation when goals overlap.
- Keep the report per-goal attributable and deterministic.

**Non-Goals:**

- Weighting goals against one another.
- Cost/risk scoring.
- Changing reverse rank or the graph weighting.

## Decisions

**D1. Store shape: a map of goals, not a single entry.** `blocks/ranking.json`
keeps `goals` keyed by block; `validate` no longer enforces a maximum of one.
The CLI `--set-goal` adds/updates one goal; `--remove-goal --block B-...`
removes one. All remain author-reserved (`decided_by` begins `author:`).

**D2. Forward rank over the goal set.** Restart mass is spread uniformly over
the designated goals (personalized PageRank on the union of their ancestor
sets); the goal blocks are excluded from the recommendation, and the
recommendation is the highest-ranked undone-and-ready block. *Alternative
considered:* per-goal sections with separate recommendations - it fragments a
shared foundation into duplicates; kept only as the breakdown (D3).

**D3. Per-goal breakdown by membership.** Each ranked block reports the set of
designated goals whose ancestor set contains it. This is deterministic, cheap,
and shows exactly which foundations are shared. *Alternative considered:*
per-goal score shares - more numbers, less clarity.

**D4. Determinism and fail-closed are unchanged.** Sorted iteration and
tie-breaks, fixed damping/iterations; unresolved edges are still named.

## Risks / Trade-offs

- **Uniform goal weighting is arbitrary** when goals differ in size → recorded as
  an open question; the per-goal membership column lets a reader re-weight.
- **Store format change** → `validate` accepts both an empty and a multi-entry
  map; the existing single-goal file is already a one-entry map, so no migration
  is needed.
- **Report grows with the goal set** → cap the ranked table as today.

## Migration Plan

No data migration: the current store is a one-entry `goals` map. Relax the
validator, extend the CLI and the forward-rank/report logic, regenerate
`reports/ranking.md`, and add tests. Advisory only, so nothing else changes.

## Open Questions

- Weighting goals (e.g. by kind or author weight) instead of uniform restart.
- Whether to also report a per-goal recommended step alongside the shared one.
