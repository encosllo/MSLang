# Suggested pilot milestone

Generated from the dependency edges in `blocks/graph.json`; confirmations/rejections live in `blocks/edge_decisions.json` (Architecture.md Sections 12.1, 14, 21 Phase 0).

## A. Smallest dependency-closed targets

A target plus its transitive upstream closure (its dependencies). Pick one to hand-build the Phase-0 vertical slice.


### `B-C011` — corollary (closure size 2)

- $\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them. (line 2097)
- definitions in closure: `B-D042`
- members: `B-C011`, `B-D042`

### `B-P004` — proposition (closure size 2)

- Preliminaries. (line 572)
- definitions in closure: `B-D014`
- members: `B-P004`, `B-D014`

### `B-P017` — proposition (closure size 2)

- $\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them. (line 1285)
- definitions in closure: `B-D015`
- members: `B-P017`, `B-D015`

### `B-C006` — corollary (closure size 3)

- $\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them. (line 1416)
- definitions in closure: `B-D014`, `B-D024`
- members: `B-C006`, `B-D014`, `B-D024`

### `B-P001` — proposition (closure size 3)

- Preliminaries. (line 347)
- definitions in closure: `B-D002`, `B-D009`
- members: `B-P001`, `B-D002`, `B-D009`

### `B-P002` — proposition (closure size 3)

- Preliminaries. (line 518)
- definitions in closure: `B-D006`, `B-D014`
- members: `B-P002`, `B-D006`, `B-D014`

## B. Most-referenced definitions (encoding-sensitive core)

In-degree counts candidate incoming edges; high in-degree means a change here has the largest blast radius.

| id | term | in-degree |
|---|---|---|
| B-D014 | sorted equivalence relation on | 22 |
| B-D038 |  | 22 |
| B-D009 | support of | 18 |
| B-D024 | sorted congruence on | 17 |
| B-D015 | kernel | 14 |
| B-D006 | delta of Kronecker in | 12 |
| B-D027 | free | 12 |
| B-D017 | finitary operations on | 11 |
| B-D036 | translations of sort | 10 |
| B-D040 | finite index | 9 |

---

Known limitation: only `\ref`/`\uses`, number-cited prose, and a definition-cue notation extractor seed edges. Symbol and prose-name coverage is still incomplete (Architecture.md Section 12.1), so real closures are probably larger.

