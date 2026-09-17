# Design

## Context

See `proposal.md` - Why. Current state that shapes the approach:

- `blocks/graph.json` now holds **236 edges** (123 confirmed, 113 candidates
  staged by the archived `resolve-ambiguous-notation` change), over 129 blocks
  (76 mapped, 53 unmapped). Candidate edges are unconfirmed and do not enter
  closure computation.
- Existing traversal primitives: `scripts/closure.py` (`load_edges(...,
  confirmed_only=)`, transitive statement closure), `scripts/impact.py`
  (downstream/reverse reachability), `pilot_candidates.md` (in-degree), and
  `scripts/frontier.py` (open obligations, scope-triaged).
- An experiment on the committed graph showed plain reverse PageRank
  concentrates on pure sinks - the headline propositions (`B-P035`, `B-P038`,
  `B-P015`), i.e. "the biggest theorem by dependency count", not "the most
  valuable".
- Governance: scope dispositions and treatment tiers are author-reserved
  (`scope.py`, `tiers.py`); a ranking must propose, never set. Evidence inputs
  are computed, never authored (Section 12.3).
- Confirming candidate edges stales evidence (every recovered edge does), so an
  advisory ranking must not confirm anything.

## Goals / Non-Goals

**Goals:**

- Propose a ranked goal shortlist and an author-designated goal.
- Recommend the next *buildable* block on the goal's foundational path.
- Consume the richer (candidate-inclusive) graph without touching evidence.
- Be deterministic, explainable, and drift-checked.

**Non-Goals:**

- Setting scope, tiers, or priorities.
- Confirming edges or re-issuing evidence.
- A cost model, a risk override, or multi-goal blending (open questions).

## Decisions

**D1. Two stages, not one global score.** Stage 1 picks the goal (reverse
rank); Stage 2 picks the next step among the goal's ancestors (forward rank,
conditioned on the goal). Separating "what to aim at" (author) from "what to do
next" (machine) keeps the tool advisory and local. *Alternative considered:* one
personalized PageRank seeded on all headline results - it blends goals and
hides which one is being funded; deferred (Open Questions).

**D2. Reverse rank is PageRank on the impact graph**, edges `dependency ->
user`, with restart mass spread over result-bearing blocks (propositions,
corollaries and lemmas, weighted by the kind prior). On a DAG this concentrates
on sinks, so the shortlist reads as "the results with the largest supporting
foundation"; the report states this explicitly so it is not mistaken for a value
judgement. *Alternative considered:* in-degree or ancestor-subtree size (the
current `pilot_candidates` heuristic) - cruder and already distrusted.

**D3. Forward rank is target-conditioned personalized PageRank** on the
ancestor-induced subgraph, restart mass at the goal, goal excluded from the
recommendation, restricted to `undone and ready` blocks. It answers "how
centrally does this prerequisite feed the goal". *Alternative considered:*
dominator / must-pass analysis - sound under edge-adding noise but too strict on
the current graph (it returned zero must-pass nodes for the top goal); kept as a
future second signal (Open Questions).

**D4. Consume all edges, weighted, dispositions excluded.** Edge weight by
source (`explicit` above `symbol`); edges disposed `type-carrier` or
`simplification` are dropped as non-dependencies. Because the ranking is a
report and feeds no closure, using candidates stales nothing. *Alternative
considered:* confirmed-only - excludes all 113 recovered candidates and leaves
the headline cluster near-isolated, defeating the purpose.

**D5. `done` is "formalized"; `ready` is "every dependency `done`".** `done(a)`
holds when `a` is mapped in `lean/declarations.json`; `ready(b)` holds when every
target of `b`'s dependency edges is `done`. The report states this predicate.
*Alternative considered:* `done` = all evidence layers `pass` - stricter and
evidence-coupled; deferred (Open Questions) because it would make the ranking
track audit throughput rather than formalizability.

**D6. Goal designation is a small author-reserved store**, `blocks/ranking.json`,
keyed by goal block with `decided_by` beginning `author:` (mirrors
`scope.py`/`tiers.py`), plus `scripts/ranking.py --set-goal` refusing an agent
write. *Alternative considered:* report-only with no store - the designated goal
could not persist across regeneration.

**D7. Output is a drift-checked report** `reports/ranking.md` (goal shortlist,
designated goal, ranked ancestors with readiness, recommended next step,
predicate and edge-weighting stated), generated from the store and the graph and
verified by `--check-report`, matching the project's other views.

**D8. Deterministic and fail-closed.** Fixed damping and iteration count, sorted
tie-breaks; an edge that would enter the walk but cannot be resolved is named in
the report rather than dropped.

## Risks / Trade-offs

- **Reverse rank measures size, not value** → the author designates the goal,
  and the report labels the shortlist as a size proxy.
- **Over-approximating edges inflate hubs** → source weighting plus disposition
  exclusion; and the ranking is advisory, so a wrong ranking costs a bad
  suggestion, not a wrong closure.
- **`done` = mapped ignores correctness and audit state** → stated in the report;
  a stricter predicate is an Open Question.
- **Sparse graph / dangling nodes** → PageRank dangling mass is redistributed
  deterministically; small ancestor sets are reported as such.
- **Governance creep** → the spec forbids setting scope/tier/priority and
  adopting a goal without author designation.

## Migration Plan

No data migration. Add `scripts/ranking.py`, `blocks/ranking.json` (empty), and
`reports/ranking.md`; wire the store check and the report drift check into
`scripts/check_all.sh`; add `scripts/ranking_test.py`. Runs are advisory, so
nothing existing changes.

## Open Questions

- A cost model (value per unit effort) for `argmax(value/cost)` (§17.1 item 4).
- A risk override: §17.1 is risk-first, so an unproved ancestor proposition
  might warrant promotion regardless of rank.
- Multi-goal portfolio: unify the two stages into one PageRank seeded on a goal
  set.
- Whether `done` should require current evidence rather than mere mapping.
- Dominator / must-pass foundations as a second, noise-robust signal once edge
  confidence improves.
