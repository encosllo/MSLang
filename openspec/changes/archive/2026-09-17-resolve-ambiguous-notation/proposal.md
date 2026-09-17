# Proposal

## Why

The dependency graph that drives closures, the discrepancy report, and the
frontier is missing more than half its edges. Symbol extraction suppresses any
edge routed through an ambiguous notation token, and it misattributes the
defining block for several global notations. The headline results are the worst
affected: `B-P020` (the first Eilenberg isomorphism) currently shows a single
prerequisite, so the graph reports an empty path to the project's most important
goals. The project already distrusts this heuristic (`STATE.md`, Session 53:
"trust the STATE priority list, not the reverse-dependency heuristic"); resolving
notation is the prerequisite for any trustworthy dependency-aware analysis,
including the goal-directed scheduling discussed separately.

Reading the 10 flagged tokens against the manuscript shows they are not 10
author decisions. They decompose into two tokenizer artifacts (`f`, `fi`), one
prefix artifact (`Form`), five misattributed owners (`Alg`, `Cgr`, `Sg`, `Sub`,
`Hom`), and only two genuine overloads (`supp`, `Ω`).

## What Changes

- **Compound-token tokenization.** Treat `\mathrm{X}_{\mathrm{Y}}` (and chains
  such as `\mathrm{Form}_{\mathrm{Cgr}_{\mathrm{fi}}}`) as one notation token,
  so subscript modifiers (`f`, `fi`) stop being counted as notation and
  `Alg`/`Alg_f`, `Cgr`/`Cgr_fi`, `Sub`/`Sub_f` become distinct referents.
- **Sentence-scoped introducer detection.** A definition owns a notation only
  when that notation is the definee of an introduction ("We denote by …", "we
  call …"), not when the definition merely mentions it near a cue word. This
  removes the arbitrary window that currently misses the true introducer
  (`B-D017` for `\mathrm{Alg}`) and invents false ones.
- **Notation resolution store.** Introduce a store for genuinely overloaded or
  ambient notation (`Hom`, `supp`, `Ω`), with an author-reserved path: an agent
  may propose a resolution; only the author may record one.
- **Unresolved notation becomes reviewable, not silent.** A token that cannot be
  resolved mechanically SHALL yield explicit candidate edges (or a reported row)
  instead of dropping the dependency without trace.
- **Staged rollout.** Recovered edges enter as unconfirmed candidates and feed
  closures only once confirmed through the existing `blocks/edge_decisions.json`
  flow, so the fix does not mass-stale evidence in one step.
- **Report.** The gap report SHALL show each notation's resolution state and the
  candidate edges an unresolved token would contribute.

## Capabilities

### New Capabilities
- `dependencies/notation`: how notation tokens are tokenized, attributed to
  defining blocks, and resolved; how genuinely ambiguous notation is
  author-resolved; and how unresolved notation is reported and staged as
  candidate dependency edges.

### Modified Capabilities
<!-- None: no existing capability's requirements change. The discrepancy
     disposition rules and the frontier triage are unaffected. -->

## Impact

- `scripts/ingest.py`: tokenization, introducer detection, ambiguity and
  candidate-edge emission.
- Regenerated artifacts: `blocks/symbols.json`, `blocks/graph.json`,
  `reports/gap_report.md`.
- New resolution store (e.g. `blocks/notation.json`), plus validation and
  drift-checking wired into `scripts/check_all.sh` and the report generators.
- Downstream: confirmed recovered edges change `definition_closure` hashes, so
  affected evidence becomes stale. This is staged deliberately, candidate by
  candidate, rather than applied in one sweep.
- Unblocks goal-directed dependency ranking, which is a separate future change
  and explicitly out of scope here.

## Non-goals

- Building the ranking/scheduling algorithm itself.
- Resolving notation that is genuinely a bound variable or generic symbol by
  inventing a defining block for it.
- Editing the manuscript prose.
