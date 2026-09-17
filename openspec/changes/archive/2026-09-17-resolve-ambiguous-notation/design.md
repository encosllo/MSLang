# Design

## Context

See `proposal.md` - Why, and `specs/dependencies/notation/spec.md` for the
behavior contract. The pieces this touches, as they exist today:

- `scripts/ingest.py` owns extraction. `edges_for()` scans each block body for
  notation with `\mathrm{([A-Za-z]{1,24})}` (`ingest.py:356-359`), attributes a
  token to a definition when a "denote/call/…" cue occurs within a fixed
  100-character window before the token (`ingest.py:369-370`), falls back to a
  term match that rejects prefixes shorter than 4 characters (`_term_matches`,
  `ingest.py:484`), and on non-unique resolution records the token in
  `ambiguous` and creates **no edge** (`ingest.py:437-451`).
- Edges are proposed as candidates (`confirmed=false`) unless a decision exists
  in `blocks/edge_decisions.json`, keyed `from|to|kind` (`ingest.py:381-400`);
  confirmed decisions the extractor no longer proposes are re-added
  (`ingest.py:454-473`). That re-add is a safety net against dropping a
  previously confirmed edge.
- `ingest.py --check` is a drift check over `blocks/registry.json`,
  `blocks/symbols.json`, `blocks/graph.json` (`ingest.py:786-800`), wired into
  the fast gate (`scripts/check_all.sh:52`).
- The author-reserved store pattern already exists: `scripts/scope.py` refuses a
  disposition whose `decided_by` does not begin with `author:`, keeps the data
  in `blocks/scope_decisions.json`, and is validated by `scope.py --check`
  (`scripts/check_all.sh:71`), with tests in `scripts/scope_test.py`.
- The gap report's section 7 lists ambiguous tokens with their candidate owners
  (`ingest.py:604-612`).
- `blocks/graph.json` feeds closure generation; the 123 confirmed edges each
  have an entry in `blocks/edge_decisions.json`.

Constraints from the project: extraction must be deterministic and fail closed
(Architecture.md Section 12.1); evidence inputs are computed, never authored
(Section 12.3); stores that record author judgments are author-reserved
(Sections 16.4, 17).

## Goals / Non-Goals

**Goals:**

- Make notation identity compound-aware so subscript qualifiers stop producing
  phantom tokens and base/qualified notations are distinct.
- Attribute a notation to its introducer, not to every block that mentions it.
- Give genuinely ambiguous or ambient notation an author-owned resolution path.
- Make unresolved notation visible and staged, never silently dropped.
- Keep recovered edges out of closures until confirmed, so the fix lands without
  mass-staling evidence.

**Non-Goals:**

- Any ranking or scheduling algorithm (separate change).
- Re-deriving the entire symbol map from the elaborated manuscript; the
  sentence-scoped heuristic plus the author store is the target.
- Changing manuscript prose or the block registry.
- Auto-confirming recovered edges.

## Decisions

**D1. Notation identity is the full compound form.** Identity is the base token
plus its normalized subscript chain (`Alg`, `Alg_f`, `Cgr_fi`, `Sub`, `Sub_f`,
`Form_Alg`, `Form_Cgr_fi`, `Omega`). This makes `f` and `fi` vanish as standalone
tokens and separates notations that share a base. *Alternative considered:*
keep a base token plus a separate qualifier dimension — rejected as more
machinery for the same result and harder to key a store on.

**D2. Ownership is sentence-scoped, not window-scoped.** A block owns a notation
only when that notation is the definee of an introduction sentence in its body.
The cue window is replaced by sentence segmentation plus a small pattern set for
introductions ("We denote by …", "… is denoted by …", "we call …", "… is the
…"). This fixes both failure modes: the true introducer whose cue is far from
the token (`B-D017` for `Alg`) and the false owners that merely mention a
notation near a cue. *Alternative considered:* enlarge the window — rejected, it
cannot tell mention from introduction. *Alternative considered:* a hand-authored
exception table only — rejected, it does not scale and hides the real defect.

**D3. Unresolved notation produces a reported identity, not a silent drop.** A
notation that mechanical rules cannot resolve to a single owner does not create
an edge; it appears in the notation report with its candidate owners and the
blocks that use it. *Alternative considered:* pick the highest-ranked candidate
— rejected, it fabricates a dependency.

**D4. A separate author-reserved store holds resolutions.**
`blocks/notation.json`, shaped like `blocks/scope_decisions.json`: a `note`
plus `resolutions` keyed by compound notation identity, each entry with
`resolution` (`block` with a target id, or `ambient`), `decided_by`, and
`rationale`. `scripts/notation.py` provides `--list`, `--check`, and
`set --notation ... --resolution ...`, refusing any `decided_by` not beginning
with `author:`. *Alternatives considered:* extend the generated
`blocks/symbols.json` — rejected, it is overwritten on regeneration and cannot
carry author state; reuse `blocks/edge_decisions.json` — rejected, resolution is
per-notation, not per-edge, and edge decisions are already the confirmation
layer.

**D5. Resolution order: store, then mechanical, then report.** For each notation
identity: a recorded resolution wins; else a unique mechanical owner resolves
it; else it is unresolved and reported. The store is consulted before the
heuristic so the author can override any mechanical result. *Alternative
considered:* mechanical first — rejected, the point of the store is to correct
the heuristic.

**D6. Recovered edges enter unconfirmed.** A resolved (block) notation whose
blocks use it yields candidate edges with `source: symbol` and
`confirmed=false`; `ambient` yields none. Confirmation flows through
`blocks/edge_decisions.json` unchanged. *Alternative considered:* auto-confirm —
rejected, confirming edges changes `definition_closure` hashes and stales
evidence; that must be deliberate per edge.

**D7. Resolution state is machine-readable and drift-checked.** `symbols.json`
gains each notation identity's resolution state and use count, and the gap
report's section 7 is rewritten to show per-notation state, candidate owners, and
how many candidate edges a resolution would add. `ingest.py --check` gains a
drift check on `reports/gap_report.md`, which it generates today but does not
verify. *Alternative considered:* leave the report unverified — rejected; the
spec requires the notation report to be drift-checked.

**D8. Initial author pass covers the genuine residue.** The migration records
resolutions for `Hom` (ambient vs `B-D002`), `supp` (root `B-D009` with
`B-D018` nested), `Omega` (`B-D038` owning the symbol, `B-D039` depending on
it), and confirms `Alg`'s owner (`B-D017`). The mechanical fixes handle the rest.

## Risks / Trade-offs

- **Reassigning an owner can drop a previously confirmed edge** → the
  append-confirmed-decisions branch (`ingest.py:454-473`) keeps an already
  confirmed edge even when the extractor stops proposing it; migration also
  diffs confirmed edges before/after and re-confirms any changed endpoint.
- **Recovered edges staling evidence** → edges land unconfirmed and only enter
  closures on confirmation; the rollout confirms incrementally and watches
  staled evidence, rather than sweeping.
- **Ambient notation inflating hubs** (`Sub`, `Cgr`, `Alg` become high in-degree)
  → mathematically these are real dependencies and closure already counts them,
  but the future ranking must account for hub inflation; the per-notation
  resolution is author-owned, so a notation can be marked `ambient` instead.
- **Sentence patterns missing unusual introductions** → residues surface in the
  report as unresolved and are resolved in the store; the failure is visible,
  not silent.
- **Compound tokenizer over- or under-merging** → unit tests pin the known
  families (`Alg`/`Alg_f`, `Cgr`/`Cgr_fi`, `Sub`/`Sub_f`, `Form_*`) and
  determinism is asserted on a fixture.
- **Scope creep into ranking** → explicitly a non-goal; this change only makes
  the graph trustworthy.

## Migration Plan

1. Land the extractor changes, the `notation.py` store tooling, the report
   change, and tests. Regenerate; recovered edges appear unconfirmed. No
   evidence changes at this step.
2. Diff confirmed edges (before/after). Re-confirm any edge whose endpoint
   changed; verify the five misattributed owners now resolve to their true
   introducers.
3. Author decision pass recording the residue in `blocks/notation.json`.
4. Incrementally confirm recovered edges, checking staled evidence as each is
   confirmed; regenerate views and the bundle in the project's standard order.
5. Rollback is clean: unconfirmed candidates contribute nothing to closures, so
   reverting the store and extractor restores current behavior.

## Open Questions

- Whether pervasive ambient notation (`Hom`, `Sub`, `Cgr`, `Alg`) should resolve
  to its defining block or to `ambient`. This is per-notation author data, not a
  spec change, and can be answered during step 3 without affecting the design or
  tasks.
