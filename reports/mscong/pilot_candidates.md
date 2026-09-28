# Suggested pilot milestone

Generated from the dependency edges in `blocks/graph.json`; confirmations/rejections live in `blocks/edge_decisions.json` (Architecture.md Sections 12.1, 14, 21 Phase 0).

## A. Smallest dependency-closed targets

A target plus its transitive upstream closure (its dependencies). Pick one to hand-build the Phase-0 vertical slice.


### `B-P101` — proposition (closure size 2)

- Preliminaries (line 2105)
- definitions in closure: `B-D101`
- members: `B-P101`, `B-D101`

## B. Most-referenced definitions (encoding-sensitive core)

In-degree counts candidate incoming edges; high in-degree means a change here has the largest blast radius.

| id | term | in-degree |
|---|---|---|
| B-D101 | finite index | 1 |
| B-D102 | recognizable | 0 |

---

Known limitation: only `\ref`/`\uses`, number-cited prose, and a definition-cue notation extractor seed edges. Symbol and prose-name coverage is still incomplete (Architecture.md Section 12.1), so real closures are probably larger.

