# STATE.md -- running session narrative

> Narrative aid, not ground truth. The ground truth is `blocks/*.yaml`,
> `evidence/*.yaml`, `journal/events.jsonl`, and git history. A new session
> must **spot-check the top suggested item against the actual records**
> before trusting it (Architecture.md Section 16.1), and run the
> safe-restart checklist at the end of this file first.

---

## Session 0 -- 2026-09-14 -- first-run bootstrap

**Goal.** Instantiate the workspace described in `Architecture.md` for the
manuscript `manuscript/MSEilenberg.tex` ("Eilenberg theorems for many-sorted
formations", J. Climent Vidal and E. Cosme Lopez). Scope agreed with the
author: scaffold the Section 10.4 layout and initialize git (bootstrap items
2, 3, 5, 7, 8, 11). The Lean/Mathlib project (items 1, 4) was explicitly
deferred.

**What was established (closed).**

- Section 10.4 directory layout scaffolded: `manuscript/`, `lean/`,
  `representation/`, `blocks/`, `evidence/`, `schemas/`, `journal/`,
  `scripts/`, `reports/`, plus `STATE.md`.
- Manuscript sources relocated into `manuscript/`: `MSEilenberg.tex`,
  `hjm1.cls`, `Bibliothek.bib`.
- `.gitignore` written to exclude only regenerable build artifacts
  (`.lake/`, `*.olean`, TeX byproducts, `manuscript/*.pdf`); the durable
  record is tracked (Section 10.5).
- `scripts/env.sh`: project-local `ELAN_HOME=$MSLANG_ROOT/.elan`, pinned
  `LEAN_VERSION`, `MATHLIB_REV`, and manuscript `TEXINPUTS`/`BIBINPUTS`.
- Mechanical hygiene scripts (Section 13.3) installed and exercised:
  - `scripts/nonascii_scan.py` -- flags valid UTF-8 sequences in the latin1
    source; lone latin1 high bytes are expected, not flagged.
  - `scripts/hash_blocks.py` -- anchor-based (label / `\blockid` / proof)
    hashing; baseline written to `blocks/hashes.json` (**158 anchors**).
  - `scripts/check_crossrefs.py` -- `--audit` (undefined refs, unused
    labels, cross-section refs) and `--who NAME` blast-radius scan.
  - `scripts/build_manuscript.sh` -- non-ASCII scan then `latexmk`, checks
    the numeric exit code rather than log text.
  - `scripts/check_evidence_immutability.sh` + `scripts/hooks/pre-commit`,
    wired via `scripts/install_hooks.sh` (`core.hooksPath=scripts/hooks`).
- `schemas/evidence.schema.json`, `schemas/journal_event.schema.json`.
- Manuscript build baseline (**bootstrap item 5**): clean, **49 pages**,
  `latexmk` exit **0**, **0 errors, 0 LaTeX warnings, 0 missing characters,
  3 overfull hboxes**, ~1.6 s.

**Pinned versions.**

| Component | Value |
|---|---|
| Lean | `leanprover/lean4:v4.33.1` (native arm64; machine has several elan toolchains) |
| Mathlib | `TBD` -- fixed at bootstrap item 4 |
| TeX | TeX Live 2024, `pdflatex` via `latexmk` |
| Manuscript engine | `pdflatex` (declares `\usepackage[latin1]{inputenc}`) |

**Honestly deferred (not closed).**

- Bootstrap items 1 and 4: no project-local Lean toolchain or Lake/Mathlib
  project exists yet. `ELAN_HOME` is configured but empty, so `env.sh`
  falls back to the machine `elan` with a warning. `MATHLIB_REV` is `TBD`.
- Bootstrap item 9: the Section 14 TeX ingestion importer does **not** exist
  yet -- no source inventory, symbol registry, block registry with confirmed
  IDs, dependency graph, or gap report. `blocks/hashes.json` is a mechanical
  anchor list, not the registry.
- Bootstrap item 10: no git remote configured (visibility is an author
  decision).
- Phase 2: no evidence-record schema validation tooling yet; the schemas
  exist but nothing enforces them.
- Prose-name dependency detection (Section 12.1) is not implemented;
  `check_crossrefs.py` covers `\ref`/`\cref` only.
- `hash_blocks.py` does **not** expand macros; a macro edit changes hashes
  (treated as C4 per Section 13.1 until an importer lands).

**Engineering gotchas hit.**

- `rg`/UTF-8-aware tools do **not** reliably see the latin1 bytes (0xF3,
  0xED, 0xE9, 0xE4) in `MSEilenberg.tex`; a raw byte scan in Python is
  needed. There are exactly 6 such bytes, all legitimate accents (author
  address, bibliography).
- Sourcing `scripts/env.sh` under `set -u` failed on an unset `$TEXINPUTS`;
  fixed with `${TEXINPUTS:-}`.
- `manuscript/Bibliothek.bib` is a **dangling symlink** to
  `../Bibliothek.bib`. It is *unused*: the bibliography is an inline
  `\begin{thebibliography}` block. The build is unaffected.
- The manuscript already `\providecommand`s the blueprint macros
  `\lean`, `\uses`, `\leanok`, `\mathlibok` as no-ops (lines 94-97); a
  `\blockid{}` macro does not exist yet and must be added before it is used.

**Prioritized next steps.**

1. **Author decision (blocking pilot):** choose the pilot milestone, i.e. a
   small dependency-closed set of blocks containing at least one definition
   likely to change (Section 21 Phase 0), and decide the fate of the
   dangling `Bibliothek.bib`.
2. Build the Section 14 importer enough to produce a symbol registry and a
   *lazy* block registry with author-confirmed IDs (Phase 1). Do not mint
   IDs for the whole manuscript.
3. Bootstrap the isolated Lean/Lake project (items 1 and 4), pin Mathlib,
   and record the clean-build time.
4. Stand up the seeded-mismatch calibration suite early (Phase 1, not last).
5. Implement evidence-record schema validation and computed closures
   (Phase 2).

**Decisions reserved for the author (Section 16.4).** Pilot scope; whether
to remove or repoint `Bibliothek.bib`; git hosting and visibility; minting
the first tracked block IDs; anything that would freeze a contract.

---

## Session 1 -- 2026-09-14 -- Section 14 importer

**Goal.** Continue Phase 1: stand up the Section 14 TeX importer and reconcile
it against the actual records. No author-reserved decision was taken: no block
IDs were minted, no contract frozen, no pilot chosen.

**What was established (closed).**

- `scripts/ingest.py` built and run against `manuscript/MSEilenberg.tex`
  (latin1). It produces:
  - `reports/inventory.md` -- source inventory (6 sections, theorem-like env
    counts, `\newtheorem` table, symbol count);
  - `reports/gap_report.md` -- seven gap classes;
  - `reports/pilot_candidates.md` -- dependency-closed pilot candidates plus the
    most-referenced definitions;
  - `blocks/registry.json` -- **129 confirmed blocks** (46 definitions, 39
    propositions, 27 remarks, 13 corollaries, 2 examples, 1 lemma, 1
    assumption), **0 proposed** (every uncommented theorem-like env already
    carries a `\blockid`);
  - `blocks/symbols.json` -- **47** preamble macros/notations;
  - `blocks/graph.json` -- **74 candidate edges** (38 explicit, 36
    symbol-usage), and 31 ambiguous notation tokens whose symbol edges were
    suppressed.
- `scripts/hash_blocks.py` **fixed** (see gotchas): anchors are now keyed to the
  `\blockid` preceding an environment, and `example`/`examples`/`assumption`
  are scanned. `blocks/hashes.json` regenerated: **161 anchors** (129 block IDs,
  31 proofs, 1 stray equation label `Eq1`), up from 158. All 129 registry
  hashes now equal their `hashes.json` anchor by direct check.
- Manuscript build re-verified unchanged: exit 0, 49 pages.

**Findings that change the picture.**

- Session 0 said "no block registry with confirmed IDs" and that the importer
  did not exist. **Both were stale**: the source already carried 129
  author-minted `\blockid`s, and the tex preamble already named
  `scripts/ingest.py`. The bootstrap "158 anchors" was also wrong in a
  load-bearing way -- `hash_blocks.py` searched for `\blockid` *inside* the
  body, but the manuscript writes it *before* `\begin{...}`, so none of the 129
  IDs was ever an anchor; 86 blocks were hashed to positional `env:*` fallbacks
  (exactly the anchor drift of Section 13.3 item 1), and 3 blocks were not
  hashed at all.
- `schemas/evidence.schema.json` constrains `block` to `^B-[0-9]{4}$`, but the
  manuscript IDs are `B-<letter><NNN>` (e.g. `B-D001`, `B-P039`). No evidence
  record for an existing block can validate until this is reconciled. **Left
  unchanged and flagged** -- the ID pattern is registry arithmetic
  (Section 16.4).

**Gaps measured (candidate; extraction incomplete).**

- 129/129 blocks declare no `\blockscope`.
- 89/129 blocks have no `\label`, so they are not citable by `\ref` (why a
  `\ref`-only closure is tiny).
- 21/53 proof-expected blocks have no following proof (candidate `M-gap` /
  omitted-proof blocks for Section 11a.5).
- 58 blocks have no candidate edge; 31 notation tokens are ambiguous.
- 0 undefined `\ref` targets.

**Suggested pilot (for author confirmation).** Most-referenced definition:
`B-D014` (sorted equivalence relation, candidate in-degree 10). Smallest
nonempty closures: `B-C001`, `B-C002`, `B-P002`, each with `B-D014`. See
`reports/pilot_candidates.md`; edges are unconfirmed.

**Honestly deferred.** Edge confirmation; symbol/prose extractor completeness
(only a heuristic `\mathrm`-token extractor plus number-cited prose); evidence
schema validation and computed closures (Phase 2); Lean project (items 1, 4);
the dangling `Bibliothek.bib`.

**Engineering gotchas.**

- `hash_blocks.py`'s comment claimed it read `\blockid`, but its regex searched
  only the env body. Source placement is *before* the env; the tool now accepts
  both.
- `THEOREM_ENVS` omitted `example`/`examples`/`assumption`; those IDs were
  invisible to the hasher. Extended.
- System `ls`/`date` render in Catalan (`14 set.`); harmless to the tooling.

**Prioritized next steps.**

1. Author: reconcile `evidence.schema.json`'s `block` pattern with the actual
   `B-<letter><NNN>` IDs, and confirm or reject the candidate edges.
2. Author: choose the pilot milestone from `reports/pilot_candidates.md`.
3. Confirm `\blockscope` for the pilot blocks and backfill `\label` where a
   `\ref` is wanted.
4. Complete symbol/prose extraction and add an edge-confirmation store
   (Phase 1 exit criteria).
5. Evidence schema validation and computed closures (Phase 2).

**Session 1 (continued) -- author-directed follow-ups.**

Author directed: fix the schema, choose the pilot, review the edges, commit,
and bootstrap Lean/Mathlib. Outcome:

- **Schema reconciled.** `schemas/evidence.schema.json` `block` pattern is now
  `^(B-[A-Z][0-9]{3}|representation/...)$`; the artifact example was updated to
  `B-D001/formal_statement`. Evidence records for existing blocks can validate.
- **Edge review + decision store.** `blocks/edge_decisions.json` added (111
  entries, all `confirmed: true`, `reviewed_by: agent:opencode`); `ingest.py`
  reads it so confirmations/rejections survive re-ingestion (a rejected edge is
  remembered and not re-proposed). The extractor was tightened before review:
  symbol tokens are now `\mathrm{...}` only (bold/caligraphic single letters are
  variable names, not notation), a *definition cue* ("denote by", "we call",
  ...) is required within 100 chars, and a token introduced by more than one
  definition is suppressed as ambiguous (9 ambiguous tokens: `Alg, Cgr, Form,
  Hom, Sg, Sub, f, fi, supp`). After tightening, all 73 symbol edges point at a
  token genuinely introduced by the target definition; all 38 explicit edges are
  author-written `\ref`/`\uses`. **Author spot-check of the confirmations is
  still wanted** -- they were reviewed by the agent, not the author.
- **Pilot chosen (B-D014-centred).** Most-referenced definition is `B-D014`
  (sorted equivalence relation, in-degree 20). The pilot scope is the
  dependency-closed set `{B-D014, B-P002, B-P003, B-C001, B-C002}` (definition
  plus its smallest dependents; changing `B-D014` is exactly the C4 propagation
  exercise Phase 0 wants). Adjust if a different milestone is preferred.
- **Lean skeleton created, cache fetch deferred on disk.** `lean/lean-toolchain`
  pins `leanprover/lean4:v4.33.1`; `lean/lakefile.toml` pins Mathlib at the
  exact commit `0df444a360eaa60ab8c11dca51a86af692955474` (tag `v4.33.1`);
  `lean/Mslang.lean` is the smoke/axiom test; `scripts/env.sh` `MATHLIB_REV` set
  to the same commit. `lake --version` in `lean/` resolves to Lean 4.33.1.
  **Blocker:** the disk is at 95%, ~10 GiB free; the Mathlib source + `.lake`
  olean cache is ~6-8 GiB, so `lake update && lake exe cache get && lake build`
  was **not** run (bootstrap item 10). Free space first, then run those three
  commands and record the clean-build time.

---

## Session 2 -- 2026-09-14 -- evidence engine (computed closures)

**Goal.** Implement the Phase 2 evidence-engine core that is unblocked by
Lean/disk: computed input closures, schema validation, and seeded propagation
tests (P13, Sections 12.3, 13.1, 18, 22).

**What was established (closed).**

- `blocks/registry.json` now carries a `facets` object per block:
  `informal_statement` (hash) and `informal_proof` (hash + anchor when a proof
  follows). `ingest.py` computes the proof hash with the same normalization as
  `hash_blocks.py`.
- `scripts/closure.py` -- computed, fail-closed, deterministic input closures
  (Section 12.3). `--layer review|correspondence|verification`,
  `--representation FILE`, confirmed edges only by default. A review closure
  contains the block's statement and proof, the **statements** of every block in
  its transitive dependency closure, and the representation hash. Proof facets
  of dependencies are never pulled in (proof irrelevance).
- `scripts/propagation_test.py` -- 11 seeded checks, **all pass**:
  determinism; dependency-statement change alters the closure; dependency-proof
  change does **not**; own-proof change does; representation change (C6) alters;
  missing representation / unresolved edge / missing own proof all **fail
  closed**; transitive dependency statement present.
- `scripts/validate_records.py` -- dependency-free JSON-Schema-subset validator
  (no `jsonschema`/`PyYAML` in this environment) for `evidence/*.json` and
  `journal/events.jsonl`; `--self-test` confirms it rejects the old numeric ID,
  unknown keys, and missing required keys. Validates the 3 journal events;
  0 evidence records exist yet.

**Findings.**

- The evidence engine is honest but currently **all closures fail closed**,
  which is the correct behaviour at this stage: no representation record exists
  (Section 11.5 must be audited first), no Lean/formal facets exist, and 21
  proof-expected blocks have no informal proof (candidate `M-gap`; they need an
  `Explanation` under Section 11a.5 before any review evidence can be current).
- Record storage format is unresolved: the architecture's example is YAML, but
  no YAML parser is installed and the schemas are JSON. The validator handles
  JSON directly and would validate YAML if `PyYAML` is installed. Before the
  first evidence record is written, pick JSON vs YAML (a small author choice)
  and install the parser if YAML is chosen.

**Prioritized next steps.**

1. Author: free disk, then run the Lean/Mathlib fetch and record the clean-build
   time (Session 1 blocker).
2. Author: draft/accept a **representation record** (`representation/` is still
   empty); it is the precondition for every review/correspondence closure.
3. Author: choose JSON vs YAML for evidence records.
4. Reconstruct one omitted proof as an `Explanation` for a pilot block
   (`B-C001`/`B-C002`/`B-P002`) and adversarial-read it (Section 11a.5).
5. Complete symbol/prose extraction and backfill `\blockscope`/`\label` for the
   pilot blocks.

---

**Safe-restart checklist (run before touching anything).**

1. `git status` and `git log --oneline -10`; reconcile any dirty tree before
   trusting this file (Section 10.5).
2. `. scripts/env.sh`; expect the "project-local toolchain not installed"
   warning until bootstrap item 4 lands.
3. Verify the baseline still holds: `./scripts/build_manuscript.sh` should
   exit 0 with a 49-page PDF.
4. Before editing the manuscript, run
   `python3 scripts/nonascii_scan.py manuscript/MSEilenberg.tex`.
5. After *every* manuscript edit, re-run
   `python3 scripts/hash_blocks.py --out blocks/hashes.json manuscript/MSEilenberg.tex`
   and check `blocks/hashes.json` by direct search, not just exit status.
   `blocks/hashes.json` currently holds **161** anchors (129 block IDs keyed to
   the `\blockid` preceding each environment, 31 proofs, 1 equation label
   `Eq1`).
6. After manuscript edits, also re-run
   `python3 scripts/ingest.py --aux manuscript/MSEilenberg.aux manuscript/MSEilenberg.tex`
   and inspect `reports/gap_report.md`; `blocks/hashes.json` anchors and
   `blocks/registry.json` body hashes must agree (both use
   `hash_blocks.normalize`).
7. Run the evidence-engine checks after any change to the importer, graph, or
   schemas: `python3 scripts/propagation_test.py` (all checks must pass) and
   `python3 scripts/validate_records.py --self-test`.
8. Do not edit or delete existing files under `evidence/` (the pre-commit
   hook enforces this); supersede with a new record instead.
