# Design

## Context

See `proposal.md` — Why. Current state that shapes the approach:

- **Manuscript.** `manuscript/MSCong.tex` has **247 theorem-like environments**
  (89 propositions, 72 remarks, 59 definitions, 14 corollaries, 9 assumptions,
  3 lemmas, 1 example) and **zero `\blockid`s**. Its `\newtheorem`s live in the
  preamble; `\blockid` is not even defined as a macro.
- **Lean.** M1–M5 are complete and `sorry`-free: `Mscong.Recognizable` (M1),
  `Mscong.BasicTerms` (`PRecVar`, `PRecConst`, `PRecOp`; M2),
  `Mscong.Substitution`/`Iteration`/`Quotient` (M3), `Mscong.TreeHom`
  (`PRecH`, `PRecLH`; M4), `Mscong.Hall`/`Derivor` (M5). 4029 lines total.
- **Tooling.** `ingest.py`, `hash_blocks.py`, `lean_facets.py`, `bundle.py`
  already take `--project`, and `check_all.sh` runs the source-dependent checks
  per registered project, deferring them when `ingested: false`. `closure.py`,
  `status.py`, `report.py`, `trust.py`, and `evidence.py` are
  **default-project-only**.
- **Registry.** `projects.yaml` resolves every `mscong` path (`registry`,
  `hashes`, `graph`, `symbols`, `evidence_dir`, `journal`, `reports_dir`,
  `lean_declarations`, `lean_formal`, `lean_audit`) under a namespaced
  directory; `source` and `aux` are `null` until ingestion.
- **Known defects.** An undefined `\ref{PRecIt}` inside a commented-out proof
  (line 2911), a multiply-defined `\label{TAntiHom}` (lines 1779, 1872), and
  CROSS-SECTION notices that `check_crossrefs.py` prints without failing.

## Goals / Non-Goals

**Goals:**

- Mint block IDs for a small, dependency-closed pilot cluster and ingest
  `mscong` provenance for real.
- Map the pilot Lean declarations and produce formal facets.
- Audit the correspondence between each pilot proposition's statement and its
  Lean counterpart with the two-stage blind method (Section 11.2 of
  `Architecture.md`), and record the verdicts as evidence.
- Make the evidence/status/view tools project-aware so the above can run for
  `mscong`.
- Leave the `mslang` golden baseline byte-identical.

**Non-Goals:**

- Mapping the remaining ~240 `MSCong.tex` environments.
- New Lean mathematics; the `Mscong` sources are not edited.
- The `Sig_d`/`Alg_d` category layer or `PRecILH`.
- Re-opening the `MSCong.tex` prose: only `\blockid`s, labels, and the two
  correctness fixes.

## Decisions

### D1. Pilot cluster and IDs

The pilot is the §3.1 *basic terms* cluster:

| block | kind | line | label | Lean counterpart |
|---|---|---|---|---|
| the finite-index congruence definition | definition | 2075 | — | `Recognizable.IsFiniteIndex` (M1) |
| the finite-index filter proposition | proposition | 2096 | `Filter` | `isFiniteIndex_inter`, `isFiniteIndex_mono` |
| the recognizability definition | definition | 2132 | — | `Recognizable`, `RecognizableAt` (M1) |
| the variable singleton | proposition | 2420 | `PRecVar` | `PRecVar` |
| the constant singleton | proposition | 2430 | `PRecConst` | `PRecConst` |
| the operation-on-variables singleton | proposition | 2440 | `PRecOp` | `PRecOp` |

Six blocks. This exercises a definition, a proposition with a proof, and the
three propositions whose Lean theorems exist, and it is dependency-closed: the
three propositions use the recognizability definition, which uses the
finite-index definition, whose filter proposition is used by the surrounding
manuscript (§3.2 proofs cite `\ref{Filter}`).

**ID allotment.** The `mslang` scheme is `B-<letter><NNN>` with the letter
keyed to the kind (`D` definition, `P` proposition, `C` corollary, `R` remark,
`L` lemma, `X` example). `mscong` reuses the same grammar in a **disjoint
number range** to avoid any clutter if the two manuscripts are ever read
together or merged: the pilot takes `B-D101`, `B-P101`, `B-P102`, `B-P103`,
`B-D102`, and `B-P104` (the two definitions keep their document order:
`B-D101` finite-index congruence, `B-D102` recognizability). `projects.py
--collisions` proves the spaces are disjoint; the number range is the
coordinator's mechanical choice, and `B-D014` remains an `mslang` ID untouched.

### D2. `\blockid` before the environment, as in `mslang`

The `mslang` convention is the `\blockid{}` on the line **before**
`\begin{env}` (never inside, which would change the body hash).
`hash_blocks.py` already accepts the preceding-line placement, and its
`THEOREM_ENVS` already includes `definition`, `proposition`, `assumption`,
`remark`, and `example`. `\blockid` must be `\providecommand`ed in the
`MSCong.tex` preamble (as `MSEilenberg.tex` does) before first use.

### D3. Ingest with a real `source` and `aux`

Set `projects.yaml` `mscong.source` to `manuscript/MSCong.tex` and
`aux` to `manuscript/MSCong.aux`, set `ingested: true`, and let
`ingest.py --project mscong` and `hash_blocks.py --project mscong` populate
`blocks/mscong/`. The registry for `mscong` lists **only** the six pilot blocks
(`0 proposed` for everything else), because the importer's registry is built
from `\blockid`s, exactly as `mslang`'s was in its Phase 0 pilot; unmarked
environments produce the `gap_report.md` backlog, not proposed IDs.

### D4. Label reconciliation

Two minimal source fixes, both correctness-only:

1. Delete the stale `Proposition~\ref{PRecIt}` from the commented-out proof at
   line 2911 (the surrounding block is already commented out; the ref is dead).
   Alternative: add a `\label{...}` for it somewhere. Deleting is safer — a
   reference to a theorem that is only mentioned in a comment has no home.
2. Rename the second `TAntiHom` (line 1872) to a unique label (e.g.
   `TAntiHomSubset`, since it is the subset form) and check whether any `\ref`
   targets the second one. If both forms are genuinely cited, the caller must
   be updated; if not, the rename is local.

Both are recorded as a journal `status_change` event, since they change the
manuscript.

### D5. Declaration mapping

`lean/declarations.mscong.json` gains entries for the pilot. The `mslang` map
uses `blocks[<ID>] = {"file": ..., "decl": ...}` or `{"decls": [...]}`, and
`lean_facets.py` already splits a declaration at the first top-level `:=`.
Definition blocks map to the *bundled* declaration that carries the meaning
(`Recognizable`, `RecognizableAt`, `IsFiniteIndex`); if a definition has no
single declaration, its formal facet is simply absent and the status view says
so — the `mslang` tooling already handles a missing facet fail-closed.

### D6. Evidence/status/view tools gain `--project`

`closure.py`, `status.py`, `evidence.py`, `report.py`, and `trust.py` load
`blocks/registry.json`, `blocks/hashes.json`, `blocks/formal.json`,
`blocks/graph.json`, `evidence/`, and `reports/` **relative to the current
project**. The change is mechanical: resolve those paths through `projects.py`
when `--project` is given (default `mslang`), and write to the project's
`reports_dir` / `evidence_dir`. The `mslang` code path and every emitted byte
must be unchanged, so `check_all.sh`'s `--check`/`--check-report` gates stay
green without regenerating anything.

### D7. Two-stage blind correspondence

For each pilot proposition, run the `mslang` method:

1. Stage 1 (fresh agent, given only the Lean declaration plus the pilot
   definitions) reads the statement back as informal mathematics.
2. Stage 2 (fresh agent, given only that read-back plus the manuscript
   statement) returns `equivalent` / `formal_stronger` / `formal_weaker` /
   `divergent`.

Transcripts go to `blocks/mscong/audits/<ID>-correspondence.md`; the verdict is
recorded with `scripts/evidence.py --project mscong` as a correspondence
record. The independence caveat (same session, same model) is recorded exactly
as `mslang` records it.

### D8. What stays deferred

The remaining ~240 environments, the `Sig_d`/`Alg_d`/Grothendieck layer, and
`PRecILH`. The `mscong` bundle and views will therefore show a six-block
project — honest and small, which is the pilot's point.

## Risks / Trade-offs

- **`ingested: true` turns on checks that currently defer.** The crossref audit
  prints CROSS-SECTION notices but exits 0, so it will pass; the undefined-ref
  count is what fails, and D4 removes it. → Do D4 before flipping `ingested`.
- **`hash_blocks.py` anchor count** for `mscong` will be tiny (six blocks plus
  proofs). That is expected; the `mslang` gate compares against the committed
  `blocks/mscong/hashes.json`, not a magic number.
- **Tool project-dimension regression.** The single largest risk is silently
  changing an `mslang` artifact. → Every step keeps `--project mslang` the
  default and is verified by `check_all.sh` (fast and slow) plus
  `projects.py --check-baseline`.
- **Evidence independence.** Same-model audits are weak evidence; the caveat is
  recorded, as for `mslang`. The pilot's value is proving the pipeline, not the
  audit result.
- **`\newtheorem` sharing.** `MSCong.tex`'s environments are counted by the
  importer's `THEOREM_ENVS`; a `\newtheorem`-declared name that is not in that
  list is invisible. → Confirm the six pilot environments parse before trusting
  the registry counts.

## Migration Plan

1. Reconcile the two labels (D4); rebuild the `mscong` PDF and record the
   before/after page count.
2. Add `\providecommand{\blockid}` and the six `\blockid{}`s (D1, D2); re-hash.
3. Flip `mscong.ingested: true` and set `source`/`aux` (D3); run
   `ingest.py --project mscong` and `hash_blocks.py --project mscong`.
4. Add the declaration map (D5); run `lean_facets.py --project mscong`.
5. Add `--project` to the evidence/status/view tools (D6); assert the `mslang`
   outputs are unchanged.
6. Run the correspondence audits (D7) and write the evidence records.
7. Regenerate `reports/mscong/` (bundle) and append the `mscong` journal events.
8. Run `check_all.sh --fast`, one slow `check_all.sh`, and
   `lean_audit.py --project mscong`; then archive and sync the spec.

Rollback: revert the commit; `mscong.ingested: false` restores the deferred
state, and the `manuscript/MSCong.tex` edits are additive.

## Open Questions

- Should the two pilot definitions share the `B-D1xx` range with future
  `mscong` definition IDs, or should the full-manuscript numbering be reserved
  now (e.g. `B-D001`–`B-D059`) and the pilot take the first two? The pilot
  takes `B-D101`/`B-D102` to keep the whole `B-D0xx` range free for a later
  document-order assignment; revisit if the follow-on mapping prefers
  contiguous numbering.
- Whether `check_crossrefs.py` should fail on CROSS-SECTION notices for a
  second manuscript, or keep them advisory. Adopted: keep advisory (changing it
  would change `mslang` gate semantics).
