# Proposal

## Why

The formalization frontier is currently ordered by a hand-curated list in
`STATE.md`, because the machine's only ordering signal - the in-degree /
reverse-dependency heuristic in `pilot_candidates.md` - is explicitly distrusted
(`STATE.md`, Session 53). The archived `resolve-ambiguous-notation` change made
the dependency graph usable (126 -> 236 edges, headline cluster no longer
near-isolated), so the original motivation can now be built: an order that
follows the mathematics instead of a linear block-by-block sweep. Pick the
result worth formalizing, then build its foundational prerequisites first.

## What Changes

- **Goal proposal (reverse rank).** Over the dependency graph, compute a reverse
  (impact) PageRank that concentrates on the manuscript's headline results, and
  present a shortlist of goals. The author designates the goal; the tool only
  proposes.
- **Next-step proposal (forward rank).** Restrict to the target's ancestor set
  (the blocks that contribute to the goal), compute a target-conditioned forward
  PageRank over that subgraph, and recommend the highest-ranked ancestor that is
  **undone and ready**. Recompute after each block is completed.
- **Done/ready predicate.** Define `done` (formalized) and `ready` (every
  dependency done) explicitly, so the recommendation is buildable.
- **Weighted graph.** Consume all dependency edges (confirmed and candidate),
  weighted by evidence source (`explicit` above `symbol`) and with edges whose
  discrepancy disposition is `type-carrier` or `simplification` excluded.
- **Drift-checked report.** A ranking report shows the goal shortlist, the
  target's ranked ancestor set with readiness, and the recommended next step.
  It is advisory: it never sets scope, tiers, or priorities.
- **Determinism and fail-closed.** Same inputs produce the same ranking; an
  unresolved edge that would enter the walk is surfaced, not silently dropped.

## Capabilities

### New Capabilities
- `scheduling/ranking`: goal-directed ordering of the formalization frontier -
  reverse-rank goal proposal, ancestor-restricted forward-rank next-step
  proposal, readiness, and the advisory ranking report.

### Modified Capabilities
<!-- None: scheduling/frontier's triage and dependencies/discrepancy's
     dispositions are consumed, not changed. -->

## Impact

- New `scripts/ranking.py`, tests, and a generated `reports/ranking.md` wired
  into the fast gate as a drift-checked view.
- Consumes `blocks/graph.json`, `blocks/registry.json`, `blocks/discrepancy_decisions.json`,
  `lean/declarations.json` (or `blocks/formal.json`) for the done predicate, and
  the representation/scope stores.
- Relationships: `scheduling/frontier` supplies the open obligations the ranking
  orders; `Architecture.md` §12.1 (edges) and §17.1 (risk, criticality, cost)
  are the governing sections.
- **Advisory only:** it changes no closure, no layer status, and no evidence; it
  cannot and does not confirm edges.

## Non-goals

- Setting scope dispositions, treatment tiers, or priorities (author-reserved;
  the report proposes).
- Confirming the 113 staged candidate edges or re-issuing staled evidence (the
  deferred work of `resolve-ambiguous-notation`; separate effort).
- A cost model, a risk override, and a multi-goal portfolio (recorded as open
  questions in design).
