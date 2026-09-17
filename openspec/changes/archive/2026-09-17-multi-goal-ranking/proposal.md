# Proposal

## Why

The ranking supports a single designated goal. The author's goal is the
Eilenberg theorem, but the paper proves **two** Eilenberg-type theorems - the
first (`B-P020`: `Form_Alg(Σ) ≅ Form_Cgr(Σ)`) and the second, a triple
isomorphism (`B-P034`: `Form_Alg_f(Σ) ≅ Form_Cgr_fi(Σ)`, `B-P039`:
`Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)`). A single goal forces an arbitrary choice and
hides the foundations shared by both theorems, which are usually the most
valuable next step. Goal designation must therefore accept a set.

## What Changes

- **Goal set.** `blocks/ranking.json` records one or more designated goals; the
  store CLI adds and removes goals (author-reserved, unchanged).
- **Next step over a goal set.** Restrict to the union of the goals' transitive
  ancestor sets, compute a forward rank conditioned on the goal set (restart
  mass spread over the goals), and recommend the highest-ranked block that is
  undone, ready, and not itself a designated goal.
- **Per-goal breakdown.** The report names, for each ranked block, which
  designated goals it contributes to, so a shared foundation is visible.
- Advisory-only, no evidence/closure effect, and no automatic goal adoption all
  remain unchanged.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `scheduling/ranking`: goal designation becomes a set (was a single goal), and
  the next-step requirement is conditioned on the goal set with a per-goal
  breakdown.

## Impact

- `scripts/ranking.py` (store shape, forward rank over a goal set, report),
  `scripts/ranking_test.py`, `blocks/ranking.json`, `reports/ranking.md`.
- Spec delta for `scheduling/ranking`; no other capability changes.

## Non-goals

- A cost model or a risk override.
- Changing the reverse-rank definition or auto-adopting goals.
- Weighting goals against one another (recorded as an open question).
