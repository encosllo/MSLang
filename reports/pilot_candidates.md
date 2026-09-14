# Suggested pilot milestone

Generated from the dependency edges in `blocks/graph.json`; confirmations/rejections live in `blocks/edge_decisions.json` (Architecture.md Sections 12.1, 14, 21 Phase 0).

## A. Smallest dependency-closed targets

A target plus its transitive upstream closure (its dependencies). Pick one to hand-build the Phase-0 vertical slice.


### `B-C001` — corollary (closure size 2)

- Preliminaries. (line 531)
- definitions in closure: `B-D014`
- members: `B-C001`, `B-D014`

### `B-C002` — corollary (closure size 2)

- Preliminaries. (line 567)
- definitions in closure: `B-D014`
- members: `B-C002`, `B-D014`

### `B-C005` — corollary (closure size 2)

- $\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them. (line 1295)
- definitions in closure: `B-D034`
- members: `B-C005`, `B-D034`

### `B-C010` — corollary (closure size 2)

- $\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them. (line 1944)
- definitions in closure: none
- members: `B-C010`, `B-P028`

### `B-P003` — proposition (closure size 2)

- Preliminaries. (line 541)
- definitions in closure: `B-D014`
- members: `B-P003`, `B-D014`

### `B-P004` — proposition (closure size 2)

- Preliminaries. (line 557)
- definitions in closure: `B-D014`
- members: `B-P004`, `B-D014`

## B. Most-referenced definitions (encoding-sensitive core)

In-degree counts candidate incoming edges; high in-degree means a change here has the largest blast radius.

| id | term | in-degree |
|---|---|---|
| B-D014 | sorted equivalence relation on | 20 |
| B-D015 | kernel | 14 |
| B-D006 | delta of Kronecker in | 12 |
| B-D027 | free | 12 |
| B-D036 | translations of sort | 10 |
| B-D031 |  | 7 |
| B-D023 | subfinal | 3 |
| B-D028 | subdirect product | 3 |
| B-D029 | filter | 2 |
| B-D032 | formation of $\Sigma$-algebras | 2 |

---

Known limitation: only `\ref`/`\uses`, number-cited prose, and a definition-cue notation extractor seed edges. Symbol and prose-name coverage is still incomplete (Architecture.md Section 12.1), so real closures are probably larger.

