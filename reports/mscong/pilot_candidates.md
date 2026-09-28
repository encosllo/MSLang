# Suggested pilot milestone

Generated from the dependency edges in `blocks/graph.json`; confirmations/rejections live in `blocks/edge_decisions.json` (Architecture.md Sections 12.1, 14, 21 Phase 0).

## A. Smallest dependency-closed targets

A target plus its transitive upstream closure (its dependencies). Pick one to hand-build the Phase-0 vertical slice.


### `B-C108` — corollary (closure size 2)

- Recognizable subsets of a free many-sorted algebra (line 3044)
- definitions in closure: `B-D102`
- members: `B-C108`, `B-D102`

### `B-C110` — corollary (closure size 2)

- Recognizable subsets of a free many-sorted algebra (line 3061)
- definitions in closure: `B-D102`
- members: `B-C110`, `B-D102`

### `B-C105` — corollary (closure size 3)

- Recognizable subsets of a free many-sorted algebra (line 2706)
- definitions in closure: `B-D123`, `B-D125`
- members: `B-C105`, `B-D123`, `B-D125`

### `B-C106` — corollary (closure size 3)

- Recognizable subsets of a free many-sorted algebra (line 2778)
- definitions in closure: `B-D123`, `B-D125`
- members: `B-C106`, `B-D123`, `B-D125`

### `B-L101` — lemma (closure size 3)

- Recognizable subsets of a free many-sorted algebra (line 2721)
- definitions in closure: `B-D123`, `B-D125`
- members: `B-L101`, `B-D123`, `B-D125`

### `B-L102` — lemma (closure size 3)

- Recognizable subsets of a free many-sorted algebra (line 4267)
- definitions in closure: `B-D123`, `B-D125`
- members: `B-L102`, `B-D123`, `B-D125`

## B. Most-referenced definitions (encoding-sensitive core)

In-degree counts candidate incoming edges; high in-degree means a change here has the largest blast radius.

| id | term | in-degree |
|---|---|---|
| B-D125 | free | 43 |
| B-D134 | cogenerated | 28 |
| B-D102 | recognizable | 19 |
| B-D107 | delta of Kronecker associated to | 17 |
| B-D129 | sorted congruence on | 16 |
| B-D112 | sorted equivalence relation on | 14 |
| B-D108 | direct image formation | 13 |
| B-D131 | translations of sort | 11 |
| B-D103 | sorted set | 10 |
| B-D110 | cardinal | 10 |

---

Known limitation: only `\ref`/`\uses`, number-cited prose, and a definition-cue notation extractor seed edges. Symbol and prose-name coverage is still incomplete (Architecture.md Section 12.1), so real closures are probably larger.

