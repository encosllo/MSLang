# Design

## Context

- `manuscript/MSCong.tex` (latin1, 4800+ lines) has 182 importer-visible
  theorem-like environments: 6 already carry the pilot `\blockid`s (all in §2.3
  and §3.1), 176 are `proposed` in `blocks/mscong/registry.json`. The registry
  records each environment's 1-indexed `\begin` line, kind, label, and section.
- The `mslang` block-ID grammar is `B-<letter><NNN>` with `<letter>` keyed to
  kind: `A` assumption, `C` corollary, `D` definition, `L` lemma, `P`
  proposition, `R` remark, `X` example(s).
- The pilot used `B-D101`/`B-D102` and `B-P101`–`B-P104`. The `B-0xx` range is
  **not** available: `mslang` owns `B-A001`, `B-C001…`, `B-D001…`, `B-P001…`,
  `B-R001…`, `B-L001`, `B-X001…` (`projects.py --collisions` proves it). The
  pilot's `1xx` choice was exactly to stay disjoint from `mslang`.

## Goals / Non-Goals

**Goals:**

- Give every `MSCong.tex` theorem-like environment a stable block ID.
- Ingest the complete `mscong` registry/hashes/symbols/graph.
- Map the Lean declarations for every block with a documented counterpart.
- Keep the pilot IDs, the pilot evidence, and the `mslang` baseline stable.

**Non-Goals:**

- Per-block correspondence/review audits for the newly mapped blocks.
- New Lean mathematics; the `Mscong` sources are untouched.
- The `Sig_d`/`Alg_d` category layer and `PRecILH`.
- Prose edits; only `\blockid{}` lines are added.

## Decisions

### D1. Keep the pilot IDs; assign the rest in the reserved `0xx` range

Renumbering the pilot IDs to document order would supersede the six pilot
evidence records and the audits that name them — a contract change. Block IDs
are stable persistent identities (Architecture.md §14), so the pilot's
`B-D101`/`B-D102`/`B-P101`–`B-P104` are **kept**, and the 176 remaining
environments are numbered **per kind, in document order, continuing the `1xx`
range from `101`** and skipping the numbers the pilot already occupies. The
result:

| kind | pilot | remaining |
|---|---|---|
| assumption | — | `A101`–`A109` |
| corollary | — | `C101`–`C112` |
| definition | `D101`, `D102` | `D103`–`D149` |
| lemma | — | `L101`–`L102` |
| proposition | `P101`–`P104` | `P105`–`P159` |
| remark | — | `R101`–`R151` |

Every `mscong` ID is therefore `≥ 100`, disjoint from `mslang`'s `0xx` range and
from the pilot's own numbers; `projects.py --collisions` proves it. The pilot's
IDs are unchanged, so its evidence stays current.

### D2. Insertion rule

For each `proposed` registry block with `\begin` line `L`, insert
`\blockid{ID}` immediately above line `L` in `MSCong.tex`. The registry's `line`
is exactly the `\begin{env}` line (verified against the pilot IDs), and the
importer works on comment-stripped text, so a proposed block is never inside a
comment. Insertions are computed against the original line indices and applied
in one pass (build the full line list, then splice), so earlier insertions do
not shift later targets. The file is read/written with
`open(..., encoding='latin1')` — never the `edit` tool (STATE safe-restart
rule 2/7) — and the high-byte histogram is verified unchanged.

### D3. Environment kinds and letters

| kind | count (proposed) | letter |
|---|---|---|
| assumption | 9 | `A` |
| definition | 47 | `D` |
| proposition | 55 | `P` |
| corollary | 12 | `C` |
| remark | 51 | `R` |
| lemma | 2 | `L` |
| example | 0 (already covered / none proposed) | `X` |

`THEOREM_ENVS` in `hash_blocks.py` includes `example`/`examples`; the single
`example` in the manuscript is not proposed (importer count), so no `X` IDs are
minted. If the importer later proposes one, it takes `X001`.

### D4. Declaration mapping is curated, not exhaustive

`lean/declarations.mscong.json` is extended for the blocks with an unambiguous
Lean counterpart (the M1–M5 named results and the pilot definitions). Every
mapping is a *documented* correspondence (the Lean module docstring names the
manuscript result), e.g.:

| block | Lean |
|---|---|
| `PropIncSat and PropsIncSat` | `Mscong.prop_incSat` |
| `IncSat and sIncSat` | `Mscong.sat_antitone` |
| `NablaSat` | `Mscong.nabla_sat` |
| `Rec is Bool` / `Rec s is Bool` | `Mscong.recognizable_union/inter/compl` |
| `s-Rec iff Rec` | `Mscong.recognizableAt_iff` |
| `PRecSubs` | `Mscong.PRecSubs` |
| `PRecQ` | `Mscong.PRecQ` |
| `PRecH` | `Mscong.PRecH` |
| `PRecLH` | `Mscong.PRecLH` |
| `L:aux` | `Mscong.derivedAlg_eval` |

Blocks without a documented counterpart (most of the preliminaries, the
unlabelled iteration/derivor propositions, `iso:FrH-TerH`) stay **unmapped** and
appear as such in the views; this is honest, not an omission.

### D5. Graph edges stay unconfirmed

Ingesting 182 blocks yields many new candidate symbol edges. As for the pilot,
no edge is auto-confirmed; `blocks/mscong/edge_decisions.json` stays empty until
an author review. Review/correspondence closures for newly mapped blocks will
therefore be missing dependencies, exactly as the pilot's were — a known,
documented limitation, not a regression.

### D6. Evidence and views

No new evidence is fabricated. The pilot records remain current (their block
IDs and facet hashes are unchanged by D1/D2 — the *body* of each environment is
untouched, only a `\blockid` line is inserted above it). `report.py --project
mscong` and `bundle.py --project mscong` are regenerated; `status.py --project
mscong` now reports the pilot blocks `provisional`/`fail` and every other block
as having no evidence.

## Risks / Trade-offs

- **`\blockid` insertion changes hashes adjacent to the block.** The anchor for
  a block is the preceding `\blockid`, and the body hash is the environment
  body; inserting the ID does not change the body. But `hash_blocks.py` also
  hashes positional `env:*` fallbacks for unmarked environments — after D2
  there are none. → Re-run `hash_blocks.py --project mscong --out` and verify
  the six pilot anchors are byte-identical to before.
- **Some environments may be inside `\iffalse` or inline comments that the
  importer's comment stripper handles differently.** → The registry is the
  single source of truth for what the importer sees; mint only from it, then
  `ingest --check` must come back with 0 proposed.
- **A `\blockid` line could land between an existing `\label` and its
  environment if a label precedes `\begin`.** → Insert immediately above the
  `\begin` line, matching the pilot placement (label is inside the environment
  in this manuscript).
- **Declaration-map errors.** A wrong `decls` entry makes `lean_facets.py`
  fail loud (missing declaration), not silently. → The gate catches it.

## Migration Plan

1. Mint the 176 IDs (D1–D3); verify the body hashes of the pilot blocks are
   unchanged.
2. Re-run `hash_blocks.py --project mscong --out` and `ingest.py --project
   mscong`; confirm 0 proposed remain and `--check` passes.
3. Extend `lean/declarations.mscong.json` (D4); `lean_facets.py --project
   mscong` and `lean_audit.py --project mscong`.
4. Regenerate `reports/mscong/` and the bundle; append journal events.
5. Run `check_all.sh --fast`, one slow `check_all.sh`, and archive + sync.

Rollback: revert the commit; the `mscong` scaffold state returns, and the
`MSCong.tex` edits are additive.

## Open Questions

- Whether the unlabelled iteration/derivor propositions should get `\label`s so
  they can be cited and mapped. Deferred: that is a prose edit, author-reserved.
- Whether the `0xx`/`1xx` split should be normalized later by renumbering the
  pilot under a formal "ID migration" (superseding the pilot evidence). Not
  worth it now.
