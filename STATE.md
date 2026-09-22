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
| Mathlib | `0df444a360eaa60ab8c11dca51a86af692955474` (tag `v4.33.1`; fixed at bootstrap item 4, Session 9) |
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

## Session 3 -- 2026-09-14 -- pilot representation draft

**Goal.** Address the Session 2 critical-path blocker: with no representation
record, every closure fails closed. Draft the encoding record for the pilot
cluster so the closure engine and the author's encoding audit have something
concrete to work on (Section 11.5, roadmap Phase 0).

**What was established (closed).**

- `representation/pilot-encoding.md` written: a **DRAFT, unaudited** encoding
  record for the pilot cluster `{B-D002, B-D003, B-D005, B-D006, B-D009,
  B-D014, B-D015, B-P002, B-P003, B-C001, B-C002}`. It states the paper's
  foundation (ZFSK + Grothendieck universe, S-sorted sets as `S → 𝒰`, subset,
  componentwise operations, `Eqv(A)`, saturation, `Φ-Sat(A)`), a proposed Lean
  encoding (`S : Type u`; `A : S → Set U`; `Setoid` for sorted equivalences;
  `Quotient`; pointwise `Set` operations), the bridge obligations, and seven
  enumerated divergences.
- With that file supplied as the representation, `scripts/closure.py` now emits
  a real review closure for the pilot, e.g.
  `--block B-P002 --layer review --representation representation/pilot-encoding.md`
  (inputs: `B-P002` statement + proof, `B-D014` statement, representation hash).
  Before the record existed the same call failed closed.

**Findings.**

- The anticipated audit outcome is **`faithful-with-caveat`, not `faithful`**:
  the fixed-ambient carrier model (D2) cannot express componentwise operations
  on unrelated carriers, and `Setoid` vs relation (D4) and `Quotient` vs
  equivalence classes (D5) need bridge lemmas. This is honest, not a defect.
- Extraction gap confirmed again: the closure engine reports the pilot closure
  as `{B-P002, B-D014}` because `δ` and `supp` appear as `\delta^{...}` /
  `\mathrm{supp}`, which the current extractor does not catch as symbol edges;
  the paper's proof of `B-P002` really uses `B-D006` (delta) and `B-D009`/
  `B-P001` (support). Real closures are larger than the graph says.
- `B-D004` (`card(A_s) ≤ 1`) is outside the pilot cluster but the encoding table
  records its bridge (`Subsingleton`) for reuse.

**Honestly deferred / reserved.**

- The encoding audit itself (Section 11.5) and author acceptance of the carrier
  model are reserved; the draft is not evidence and must not be treated as
  authoritative.
- No content hash is pinned in any evidence record yet (no records exist).

**Prioritized next steps.**

1. Author: audit `representation/pilot-encoding.md` (Section 11.5) and accept or
   revise the carrier model (D2).
2. Expand symbol extraction to catch non-`\mathrm` operators (`\delta`,
   `\supp`, `\Omega`, superscripted operators) so closures match the paper.
3. Free disk and run the Lean/Mathlib fetch; then prove the bridge obligations
   and the first formal target `sat_antitone` (`B-C001`).
4. Author: choose JSON vs YAML for evidence records.

---

## Session 4 -- 2026-09-14 -- hygiene tests and extraction recall

**Goal.** Close Phase 1's remaining exit criteria that are testable without
Lean (Section 21): seeded line-shift stability, re-ingestion identity, and
better closure-extraction recall (Section 12.1).

**What was established (closed).**

- `scripts/hygiene_test.py` -- 10 seeded checks, **all pass**: inserted
  comments/paragraphs shift no hash; editing one block changes exactly that
  block's hash; block IDs/order/labels survive re-ingestion; editing a proof
  leaves the statement hash unchanged. Runs on in-memory copies only.
- Extraction recall improved (`scripts/ingest.py`):
  - bare operator macros are now scanned as notation tokens (`\delta`,
    `\Omega`, `\nabla`, `\Delta`, `\Theta`, `\Lambda`), not only
    `\mathrm{...}`;
  - a token introduced by several definitions is disambiguated by the
    definition's stated term with a strict rule (exact word ignoring trailing
    `s`, or prefix of length >= 4), which kills the false `\Alg` -> `B-D032`
    match inside "algebras" while keeping `delta` -> `B-D006`.
  - 12 new `\delta` edges to `B-D006` ("delta of Kronecker") were reviewed and
    confirmed in `blocks/edge_decisions.json`; graph 111 -> 123 confirmed edges.
  - **The pilot `B-P002` review closure now includes `B-D006`**, matching the
    paper's proof (it previously read `{B-P002, B-D014}`).

**Findings / remaining gaps.**

- `\supp` remains ambiguous and is **not** auto-resolved: two different
  definitions state the term "support of" -- `B-D009` (support of an `S`-sorted
  set) and `B-D018` (support of a `Σ`-algebra). The extractor refuses to guess;
  the paper uses `\mathrm{supp}_S` vs `\mathrm{supp}`. Author confirmation
  needed, or a finer disambiguator on the subscript.
- 10 tokens remain ambiguous: `Alg, Cgr, Form, Hom, Omega, Sg, Sub, f, fi,
  supp`. All 12 `\delta` edges are confirmed; 0 others unconfirmed.
- Extraction is still name/notation-based; semantic dependencies with no
  shared operator (e.g. "by a standard compactness argument") remain the
  reviewer's job, as Section 12.1 anticipates.

**Prioritized next steps.**

1. Author: disambiguate `\supp` (`B-D009` vs `B-D018`) and the other ambiguous
   tokens; audit the representation record; choose JSON vs YAML.
2. Free disk and run the Lean/Mathlib fetch; prove the bridge obligations and
   the first formal target `sat_antitone` (`B-C001`).
3. Reconstruct one omitted proof as an `Explanation` for a pilot block and
   adversarial-read it (Section 11a.5).

---

## Session 5 -- 2026-09-14 -- validity rule and layer status

**Goal.** Complete the Phase 2 evidence engine: the validity rule (Section 7.2)
and the per-layer status model (Section 8), consuming the computed closures.

**What was established (closed).**

- `scripts/status.py` -- derives, per block and layer, `none | in_progress |
  pass | fail | stale` from evidence records by comparing each record's input
  hashes against current facet hashes (facet resolution mirrors
  `closure.py`; `representation/<name>` resolves from `--representation`).
  A record is current iff **every** input hash matches; an unresolvable input
  fails closed. It never authors evidence -- it only reads records an audit
  produced. CLI: `python3 scripts/status.py --representation FILE [--block ID]`.
- `scripts/status_test.py` -- 11 synthetic-record checks, **all pass**:
  dependency-statement change stales; dependency-proof change does **not**;
  representation change stales; missing representation fails closed; layer
  `pass`/`stale`/`fail`/`none`; a current record beats a stale one; layers are
  grouped independently.
- On the current repository (0 evidence records) the CLI reports all 129 blocks
  as having no evidence, which is correct.

**Findings.**

- The evidence engine is now feature-complete for the mechanical part of
  Phase 2: inputs are computed (`closure.py`), records are schema-validated
  (`validate_records.py`), and validity/status are derived (`status.py`). The
  only missing ingredient is real audit output, which is gated on the
  representation audit and on Lean.
- No evidence records are fabricated anywhere: the tests build records in
  memory from computed closures and never write to `evidence/`.

**Prioritized next steps.**

1. Author: audit `representation/pilot-encoding.md`; disambiguate `\supp`; pick
   JSON vs YAML for records.
2. Free disk, run the Lean/Mathlib fetch, prove the bridge obligations and
   `sat_antitone` (`B-C001`); then produce the first real evidence records.
3. Project views (Section 19) once there is evidence to display; a record-writer
   that enforces computed inputs and immutability.

---

## Session 6 -- 2026-09-14 -- one-command hygiene gate

**Goal.** Satisfy Phase 4's exit ("every edit triggers all four checks
automatically") with a single entry point, and make the importer artifacts
reproducible/path-independent so drift is detectable.

**What was established (closed).**

- `scripts/ingest.py` gained `--check`: recomputes the registry, symbols, and
  graph and compares byte-for-byte against the committed files, exiting 1 on
  drift without writing. `source`/`decisions_source` are now stored as
  **relative** paths (they were absolute, machine-specific), so the committed
  artifacts are path-independent and `--check` is meaningful.
- `scripts/check_all.sh` runs, in order: non-ASCII scan, anchor-hash check,
  importer drift check, cross-reference audit, hygiene tests, propagation
  tests, status tests, record validation, and the exit-code-checked manuscript
  build. It prints PASS/FAIL per check (detail only on failure) and exits
  non-zero if any fail. Current result: **9 passed, 0 failed**.

**Prioritized next steps.**

1. Author: audit `representation/pilot-encoding.md`; disambiguate `\supp`; pick
   JSON vs YAML for records.
2. Free disk, run the Lean/Mathlib fetch, prove the bridge obligations and
   `sat_antitone` (`B-C001`); then produce the first real evidence records.
3. Project views (Section 19) and a record-writer, once real evidence exists.

---

## Session 7 -- 2026-09-14 -- first evidence: Explanation + representation audit

**Goal.** Execute the two author-directed items: reconstruct the omitted
`B-C001` proof and adversarial-read it, and self-audit the representation draft;
this produces the first real evidence records.

**What was established (closed).**

- `blocks/explanations/B-C001.md` -- a proposed `Explanation` for the omitted
  corollary `B-C001` (`IncSat`), derived from `B-P002` (`PropIncSat`). It is a
  proposal, not manuscript prose.
- Engines extended: `ingest.py` now records an `explanation` facet from
  `blocks/explanations/<id>.md`; `closure.py` treats an explanation as a
  substitute for an absent informal proof in the review layer (Section 11a.5)
  and supports a `representation` layer; `scripts/evidence.py` writes records
  whose inputs are **computed** from the closure (P13), schema-validated,
  refusing to write when the closure is blocked.
- **`evidence/E-000001.json`** (review, `B-C001`, `pass`, strength R1): result
  of an independent-context adversarial read. A fresh subagent, given only the
  definitions and the proposed proof with no project history, reconstructed the
  argument, probed edge cases (`X=∅`, `Φ=Ψ`, top/bottom), and returned **VALID,
  no gap**. Caveat: it shares this session's model.
- **`evidence/E-000002.json`** (representation, `representation/encoding`,
  `faithful-with-caveat`): the encoding self-audit. Residuals propagated:
  D1 (universe/smallness), D2 (fixed-ambient carrier model), D4 (`Setoid` vs
  relation; bridge `setoid_le_iff` unproved). D3/D5 bounded for the pilot; D6/D7
  fine. Caveat: same-session self-audit, **not independent**.
- `status.py` now reports `B-C001/review = pass (current)` and
  `representation/encoding = pass (current)`; 128 blocks still have no evidence.
- `check_all.sh`: still 9/9.

**Decisions/notes.**

- Evidence records are stored as **JSON** (`E-XXXXXX.json`); the architecture's
  example is YAML but no YAML parser is installed and the validator handles
  JSON. This is a small format choice still open for the author, but JSON is
  what the tooling currently validates.
- The Phase 0 deliverable "one omitted manuscript proof reconstructed and
  adversarial-read" is met at the *proposal* level; **author acceptance** of the
  Explanation into the manuscript is still required (reserved).

**Prioritized next steps.**

1. Author: accept or revise the `B-C001` Explanation; audit
   `representation/pilot-encoding.md` independently; choose JSON vs YAML.
2. Free disk, run the Lean/Mathlib fetch, prove the bridge obligations and
   `sat_antitone` (`B-C001`); then produce correspondence/verification records.
3. Propagate the D2 caveat into the trust boundary of dependent blocks; build
   the project views (Section 19).

---

## Session 8 -- 2026-09-14 -- trust boundary and project views

**Goal.** Execute the unblocked half of Session 7's step 3: propagate the
representation's residual caveats into dependent blocks' trust boundaries
(Section 11.5) and stand up the Section 19 project views. No author-reserved
decision was taken; the Lean/Mathlib fetch remains blocked on disk.

**What was established (closed).**

- `representation/coverage.json` -- declares which blocks the pilot
  representation covers (`encoding` -> the 11-block pilot cluster) and its five
  unproved bridge obligations. This is the machine-readable form of the
  cluster already stated in `representation/pilot-encoding.md`; it is the
  coverage input to trust-boundary propagation.
- `scripts/trust.py` -- derives, per representation, `outcome`, `current`, and
  the residual set from the representation-layer evidence records, then
  propagates the residuals to every covered block. Residuals are parsed from
  the encoding auditor's authoritative `Verdict: ... with residuals D1, D2,
  D4.` finding; the bounded labels D3/D5/D6/D7 are **not** leaked in. Currency
  reuses `status.record_is_current`, so a representation change (C6) fails the
  boundary closed (a stale audit asserts no residual).
- `scripts/report.py` -- renders three deterministic, tracked views from the
  registry, evidence, and coverage: `reports/coverage.md` (per-layer status
  vectors; derived status is deliberately **not** asserted because contract
  acceptance and treatment tiers are not recorded), `reports/trust_boundary.md`
  (representations, residuals propagated per block, unproved bridge
  obligations, statement-only note), and `reports/staleness.md`. `--check`
  detects drift.
- `scripts/trust_test.py` -- 12 seeded checks, **all pass**: residual parsing
  ignores bounded labels; a `faithful-with-caveat` current audit propagates
  exactly D1/D2/D4 to exactly the covered blocks; `faithful` imposes none; a
  stale audit is not current and asserts no residual; an uncovered block gets
  none; and the real records give `B-C001`/`B-D014` the D1/D2/D4 caveat while
  `B-D001` gets none.
- `scripts/check_all.sh` extended to **11 checks** (adds trust-boundary tests
  and a project-views drift check). Current result: **11 passed, 0 failed**.

**Findings.**

- The D2 caveat named in Session 3/7 is now visible where Section 11.5 requires
  it: `reports/trust_boundary.md` lists it for all 11 covered blocks, including
  `B-C001` (which already had a review record) and the definitions nothing has
  reviewed yet. The representation is still **not accepted**: the audit is a
  same-session self-audit (`E-000002`, independence caveat), and D4's bridge
  `setoid_le_iff` is unproved.
- Coverage is declared, not inferred: `coverage.json` restates the cluster from
  `pilot-encoding.md`. If the cluster should grow, that file (an author-visible
  artifact) is the place to say so.

**Prioritized next steps.**

1. Author: audit `representation/pilot-encoding.md` independently; accept the
   carrier model (D2) or revise it; decide JSON vs YAML for records.
2. Free disk, then run the Lean/Mathlib fetch and record the clean-build time;
   prove the bridge obligations and `sat_antitone` (`B-C001`); produce the first
   correspondence/verification records.
3. Stand up the seeded-mismatch calibration suite (Section 11.4; Phase 1 exit,
   explicitly "early"), which is now the largest missing mechanical piece. It
   needs a corpus of statements, mutation operators, and a recorded detection
   rate per mutation type; it does not need Lean.
4. Extend the views with the decision queue, frontier, and discrepancy reports
   once there is more than one evidence record to display.

---

## Session 9 -- 2026-09-14 -- Lean/Mathlib fetch and clean build (bootstrap item 4)

**Goal.** Execute the long-blocked fetch: bring the pinned Mathlib into
`lean/` and record the clean-build baseline. Author-directed ("fetch now").

**What was established (closed).**

- `scripts/env.sh` now exports **`MATHLIB_CACHE_DIR="$MSLANG_ROOT/.cache/mathlib"`**
  so `lake exe cache get` writes the download cache inside the repo, not the
  machine-wide `~/.cache/mathlib` (Section 15.3 isolation; `.cache/` added to
  `.gitignore`). The machine-wide cache was **not** touched.
- `lean/lake update` fetched the pinned Mathlib (commit
  `0df444a360eaa60ab8c11dca51a86af692955474`, tag `v4.33.1`) plus its
  dependencies (`plausible`, `LeanSearchClient`, `importGraph`, `proofwidgets`,
  `aesop`, `Qq`, `batteries`, `Cli`). Mathlib's `post-update` hook fetched the
  precompiled **8,690-file** olean cache. `lake update` wall time **1m55s**.
- `lean/lake-manifest.json` written and now tracked (the pinned lockfile;
  manifest revisions recorded). `lean/lakefile.toml`'s exact rev was honoured.
- **Clean build baseline (bootstrap item 4):** `lake build` completed
  successfully, **8,707 jobs**, **0 errors, 0 warnings**, wall time **4m13s**
  (the single `Mslang` module elaborates `import Mathlib`, ~235s of that).
  `lake env lean Mslang.lean` re-run: **3m03s**, `#print axioms mslang_smoke`
  reports **"does not depend on any axioms"** -- a subset of the permitted set
  (the `rfl` smoke theorem uses none; add a `Classical.choice`-using probe if a
  positive axiom check is wanted).
- Chosen isolation tactic: the fetch ran with `ELAN_HOME` **unset**, so `elan`
  used the machine `~/.elan` toolchain (v4.33.1 is already installed there),
  avoiding a duplicate 2.7 GiB project-local toolchain copy. Project-local
  toolchain isolation (bootstrap item 2) therefore remains **partial**: the
  package cache (`.lake/`) and download cache (`.cache/`) are project-local;
  the toolchain is not.

**Findings / gotchas.**

- The `~/.cache/mathlib` that exists on this machine (2.4 GiB) belongs to other
  projects (MathForm's Mathlib v4.32.0) and was deliberately not used; the
  project-local cache filled to 440 MiB of ltars, deleted after extraction.
- **Disk is now the binding constraint.** The extracted Mathlib oleans in
  `lean/.lake/packages/mathlib/.lake/build/lib` are **5.9 GiB** (plus 448 MiB
  IR; total `lean/.lake` 7.5 GiB). Free space went from ~9.7 GiB to ~1.3 GiB.
  Do not run further large fetches without freeing space.
- Pre-existing installs found while surveying the machine: full Mathlib
  **v4.32.0** build at `~/Desktop/MathForm/.lake/packages/mathlib` (6.9 GiB,
  incompatible with our rev), source-only v4.13.0-rc3 at `~/Lean4`, and elan
  toolchains v4.13.0-rc3/v4.23.0/v4.31.0/v4.32.0/v4.33.1.

**Prioritized next steps.**

1. Free disk (e.g. retire the unused `~/Desktop/MathForm` v4.32.0 build, or the
   machine-wide `~/.cache/mathlib`) before any further fetch/rebuild, and decide
   whether to install the project-local toolchain (bootstrap item 2 full).
2. Prove the encoding bridge obligations (`setoid_le_iff` first) and
   `sat_antitone` (`B-C001`); then produce the first correspondence and
   verification evidence records via `scripts/evidence.py`.
3. Stand up the seeded-mismatch calibration suite (Section 11.4).
4. Author: independent representation audit; JSON vs YAML records.

---

## Session 10 -- 2026-09-14 -- first formal target and verification evidence

**Goal.** With Lean/Mathlib fetched (Session 9), formalize the pilot's first
target, hash Lean statement/proof facets, and produce the first verification
record.

**What was established (closed).**

- `lean/Mslang/Pilot.lean` -- the pilot encoding from
  `representation/pilot-encoding.md`: `SSorted` (`S → Set U`), pointwise `le`,
  `SortedEqv` (`∀ s, Setoid (A s)`), pointwise refinement `sortedEqvLe`,
  saturation `sat`, and `IsSat`. Theorems:
  - `sat_antitone` (`B-C001`, `IncSat`): `Φ ⊆ Ψ → Ψ-Sat(A) ⊆ Φ-Sat(A)`, the
    first formal target;
  - `sat_sat_eq`, the forward direction of `B-P002` (`PropIncSat`).
- `lean/Mslang.lean` now imports `Mslang.Pilot` and prints the axioms of each
  theorem. **Clean build: 8,708 jobs, 0 errors, 0 warnings**;
  `#print axioms Mslang.sat_antitone` = `[propext, Quot.sound]`, within the
  permitted set (Section 15.5). `sat_antitone` is `sorry`-free.
- `lean/declarations.json` maps pilot blocks to Lean declarations.
  `scripts/lean_facets.py` extracts each declaration, splits it at the first
  top-level `:=`, normalizes (Lean comments stripped, whitespace collapsed),
  and writes the `formal_statement` / `formal_proof` hashes to
  `blocks/formal.json`; `--check` detects drift.
- `scripts/closure.py` and `scripts/status.py` merge `blocks/formal.json` into
  the registry facets at load time, so closures/status see the formal facets
  while `ingest.py --check` still covers the TeX-derived registry alone (no
  drift introduced).
- `scripts/lean_facets_test.py` -- 10 seeded checks, **all pass**: statement
  split, comment stripping, proof rewrite leaves the statement hash unchanged
  and changes the proof hash, signature rewrite changes the statement hash,
  missing declaration flagged.
- **`evidence/E-000003.json`** (verification, `B-C001`, `build_ok`): inputs
  computed by `closure.py` (`B-C001/formal_proof`), environment pinned to lean
  v4.33.1 / mathlib `0df444a`, findings the axiom set. `status.py` now reports
  `B-C001`: review `pass`, verification `pass`; representation `pass`.
- `scripts/check_all.sh` extended to **13 checks** (Lean facet tests + formal
  facet drift). Current result: **13 passed, 0 failed**.

**Findings.**

- The direct proof of `sat_antitone` is simpler than the manuscript's route
  through `B-P002`: `[X]^Φ ⊆ [X]^Ψ = X` and `X ⊆ [X]^Φ` by reflexivity
  suffice. This is a genuine (small) simplification; if the `B-C001`
  Explanation is adopted it should cite this direct argument, or the Lean proof
  should be re-derived from `B-P002` to match the prose (Section 11a.5).
- Only the **forward** direction of `B-P002` is formalized. The converse needs a
  chosen test family `X` and a transport over the dependent sort, not yet done.
  Remaining bridges: `sat_eq_preimage`, `card_le_one_iff`, `delta_support`,
  `setoid_le_iff` (the last is definitional under this encoding).
- **Honest limitation:** `formal_*` facets are a *source-level* hash, not the
  elaborated signature/proof term the architecture specifies. Stable under the
  statement/proof edits that matter here, but not yet a canonical
  representation. Recorded in `E-000003`'s `independence_caveat`.
- Disk recovered to ~8.9 GiB free after the build (the earlier ~1 GiB reading
  was transient during writes).

**Prioritized next steps.**

1. Correspondence for `B-C001`: run the two-stage blind read-back/comparator
   (Section 11.2) and produce a correspondence record; the closure now
   resolves (`formal_statement` + `informal_statement` + representation +
   `B-D014/informal_statement`).
2. Formalize the `B-P002` converse and the remaining bridge obligations, then
   the definition blocks (`B-D002`, `B-D014`).
3. Produce a Lean -> Explanation reconstruction for a proven block
   (Section 11a.5) and adversarial-read it.
4. Seeded-mismatch calibration suite (Section 11.4); independent representation
   audit; JSON vs YAML records.

---

## Session 11 -- 2026-09-14 -- correspondence audit and B-P002

**Goal.** Run the two-stage blind correspondence audit for `B-C001`, and
formalize the full `B-P002` (converse) plus the `setoid_le_iff` bridge.

**What was established (closed).**

- **Correspondence audit for `B-C001` (Section 11.2, two-stage blind).** Stage 1
  (fresh agent, given only the Lean declaration + definitions) read the
  statement back as an informal theorem about sorted sets and equivalences.
  Stage 2 (fresh agent, given only that read-back + the contract) returned
  **`equivalent`**, checking refinement direction, saturation semantics,
  quantifier variance, and the empty-sort / empty-`X` degenerate cases. Full
  transcript saved to `blocks/audits/B-C001-correspondence.md`; recorded as
  **`evidence/E-000004.json`** (correspondence, `equivalent`). Independence
  caveat: both stages share this session's model.
- `lean/Mslang/Pilot.lean` now contains:
  - `prop_incSat` -- the **full** Proposition `B-P002`: `sortedEqvLe Φ Ψ ↔
    ∀ X, sat Φ (sat Ψ X) = sat Ψ X`. The converse uses a singleton test family
    `X = Function.update (fun t => ∅) s {x}` (needs `classical` for
    `DecidableEq S`); no dependent transport.
  - `setoid_le_iff` -- the encoding bridge: `sortedEqvLe` is *definitionally*
    inclusion of the underlying relations (`Iff.rfl`), so the paper's `Φ ⊆ Ψ`
    is the Lean order.
  - Clean build, 0 errors/warnings. `#print axioms Mslang.prop_incSat` =
    `[propext, Classical.choice, Quot.sound]` (permitted); `setoid_le_iff` uses
    no axioms; `sat_antitone` still `[propext, Quot.sound]`.
- `lean/declarations.json` now maps `B-P002 -> Mslang.prop_incSat`; the
  formal statement/proof hashes regenerated (`blocks/formal.json`).
- **`evidence/E-000005.json`** (verification, `B-P002`, `build_ok`).
  `status.py` now: `B-C001` review / correspondence / verification all `pass`;
  `B-P002` verification `pass`; representation `pass`.
- `scripts/check_all.sh`: **13 passed, 0 failed** (unchanged count).

**Findings.**

- The `B-P002` converse is where the encoding's fixed-ambient carrier model
  actually matters: instantiating the hypothesis at the singleton family needs
  `classical` (`Classical.choice`), because `S` has no decidable equality in
  general. This is the first place `Classical.choice` enters a proof (the
  encoding's D6 was declared harmless; it is, but it is now *used*).
- The manuscript's route to `B-C001` (via `B-P002`) is now fully formalized, as
  is the direct route (`sat_antitone`). Both establish the corollary.
- Still unproved bridges: `sat_eq_preimage`, `card_le_one_iff`, `delta_support`.
  The last two need the pilot definitions not yet formalized (`δ^t` `B-D006`,
  `supp_S` `B-D009`, `card`/`Subsingleton` `B-D004`).
- `B-P002` has no correspondence record yet (its blind audit is scheduled), and
  `B-C001` has no *independent* (cross-model) audit: everything is same-model.

**Prioritized next steps.**

1. Blind correspondence for `B-P002`; then the definition blocks (`B-D002`,
   `B-D014`) once their Lean declarations are mapped.
2. Formalize `B-D006` (`δ`), `B-D009` (`supp`), `B-D004` (`card ≤ 1` /
   `Subsingleton`), then the remaining bridges and `B-P003`.
3. Reconstruct a Lean -> `Explanation` for a proven block (Section 11a.5) and
   adversarial-read it.
4. Seeded-mismatch calibration suite (Section 11.4); independent representation
   audit; JSON vs YAML records.

---

## Session 12 -- 2026-09-14 -- B-P002 correspondence, B-P003, facet bug

**Goal.** Continue the pilot: blind correspondence for `B-P002`; formalize
`B-P003` (`NablaSat`) with its definitions.

**What was established (closed).**

- **Correspondence `B-P002`** (two-stage blind): stage 2 returned
  **`equivalent`** after checking refinement direction, saturation order,
  quantifier domain, and the singleton-family converse. Transcript
  `blocks/audits/B-P002-correspondence.md`; record **`E-000006`**.
- `lean/Mslang/Pilot.lean` extended with:
  - `nabla` -- `∇^A`, the universal sorted equivalence;
  - `supp` -- `supp_S(A) = {s | A_s ≠ ∅}` (`B-D009`), and `suppSub` for the
    `Sub(A)` presentation;
  - `nabla_sat` -- Proposition **`B-P003`** (`NablaSat`): `IsSat (nabla A) X ↔
    ∀ s, s ∈ suppSub X → X s = Set.univ`.
- Clean build, 0 errors/0 warnings. `#print axioms Mslang.nabla_sat` =
  `[propext, Quot.sound]` (permitted). `lean/declarations.json` maps
  `B-P003 -> Mslang.nabla_sat` and `B-D009 -> Mslang.supp`.
- **Correspondence `B-P003`** (two-stage blind): stage 2 returned
  **`equivalent`**, verifying that `nabla` is the universal relation, that
  `X_s = A_s` means the whole component, and the empty-`X`/empty-sort cases.
  Transcript `blocks/audits/B-P003-correspondence.md`; record **`E-000008`**.
  Verification record **`E-000007`** (`B-P003`, `build_ok`).

**Finding (real tooling bug, caught by the validity rule).**

- Adding an `@[instance_reducible]` attribute before `nabla` **silently
  changed `B-P002`'s `formal_proof` hash**: the declaration extractor ran a
  declaration's block to the *next* declaration's start, so a leading
  attribute line leaked into the previous block. `status.py` correctly reported
  `B-P002 verification stale`. Fixed `scripts/lean_facets.py` (`BOUNDARY_RE`
  now cuts at a line-leading `@[`) and added a regression check to
  `lean_facets_test.py` (`11` checks, all pass). After the fix the hash returned
  to its recorded value and `E-000005` is current again. This is exactly the
  kind of silent-desync the architecture (Section 13.3) warns about, and it was
  detected mechanically, not by inspection.

**Current pilot state.** `B-C001`, `B-P002`, `B-P003` each have review or
correspondence/verification evidence; `B-C001` has all three layers `pass`.
`check_all`: **13 passed, 0 failed**.

**Prioritized next steps.**

1. Formalize the definition blocks whose declarations are still unmapped:
   `B-D002` (`SSorted`), `B-D014` (`SortedEqv`/`sat`/`IsSat`), `B-D006`
   (`δ^t`), `B-D004` (`Subsingleton`); then the remaining bridges
   (`sat_eq_preimage`, `card_le_one_iff`, `delta_support`).
2. Reconstruct a Lean -> `Explanation` for a proven block (Section 11a.5) and
   adversarial-read it; this is the outstanding Phase 0 deliverable.
3. Seeded-mismatch calibration suite (Section 11.4); independent representation
   audit; JSON vs YAML records.

---

## Session 13 -- 2026-09-14 -- B-C002, delta/support bridge, third facet bug

**Goal.** Continue the pilot: `B-C002`, `B-D006` (`δ`) and its support bridge,
and map the definition blocks.

**What was established (closed).**

- `lean/Mslang/Pilot.lean` extended with:
  - `sortedEqvInf` -- pointwise meet (the paper's `Φ ∩ Ψ`), with
    `sortedEqvInf_le_left/right`;
  - `sat_inf` -- Corollary **`B-C002`**: `Φ-Sat(A) ∩ Ψ-Sat(A) ⊆ (Φ ∩ Ψ)-Sat(A)`,
    a one-line consequence of `sat_antitone` (the meet refines `Φ`);
  - `delta` -- Definition **`B-D006`** (`δ^t`);
  - `supp_delta` -- bridge `supp_S(δ^t) = {t}` (needs `[Nonempty U]`, as the
    paper's universe is nonempty).
- Clean build, 0 errors/0 warnings. Axioms: `sat_inf` `[propext, Quot.sound]`;
  `supp_delta` `[propext, Classical.choice, Quot.sound]` (permitted).
- `lean/declarations.json` now maps `B-C002`, `B-D002` (`SSorted`), `B-D005`
  (`le`), `B-D006` (`delta`) as well -- **8 declarations** hashed.
- Blind correspondence for **`B-C002`** returned **`equivalent`** (transcript
  `blocks/audits/B-C002-correspondence.md`, record **`E-000011`**); the
  comparator noted the second hypothesis is proof-redundant but the statement
  keeps both, so it is not `formal_stronger`.
- Verification records **`E-000009`** (`B-C002`) and **`E-000010`** (`B-D006`).

**Finding (third extraction gap, caught immediately).**

- `Mslang.delta` is a `noncomputable def`; `lean_facets.py`'s declaration regex
  required the keyword at line start and so **did not see it** (`ERROR ...
  not found`). Fixed `DECL_RE` to allow `noncomputable|private|protected|unsafe`
  modifiers and added a regression check (`lean_facets_test.py`, now `12`
  checks). Combined with Session 12's attribute bug, the extractor has now been
  hardened at both ends of a declaration (leading modifiers/attributes,
  trailing next-declaration boundary).

**Current pilot state (6 blocks with evidence).** `B-C001` all three layers
`pass`; `B-C002`, `B-P002`, `B-P003` correspondence + verification `pass`;
`B-D006` verification `pass`. `check_all`: **13 passed, 0 failed**.

**Prioritized next steps.**

1. Remaining bridges: `sat_eq_preimage` (needs quotient/projection),
   `card_le_one_iff` (`B-D004`, `Subsingleton`); and `B-D014` mapping (it has
   several declarations -- `SortedEqv`, `sat`, `IsSat` -- so the one-declaration
   -per-block map needs extending to a declaration list).
2. Reconstruct a Lean -> `Explanation` for a proven block (Section 11a.5) and
   adversarial-read it -- outstanding Phase 0 deliverable.
3. Seeded-mismatch calibration suite (Section 11.4); independent representation
   audit.

---

## Session 14 -- 2026-09-14 -- Explanation from a formal proof (Section 11a.5)

**Goal.** Reconstruct the omitted `B-C002` proof from its Lean counterpart and
adversarial-read it -- the outstanding Phase 0 deliverable.

**What was established (closed).**

- `blocks/explanations/B-C002.md` -- a proposed `Explanation` for the omitted
  corollary `B-C002`, reconstructed from the **Lean proof** `Mslang.sat_inf`
  (the paper's direct argument: `Φ ∩ Ψ ⊆ Φ` gives `[X]^{Φ∩Ψ} ⊆ [X]^Φ = X`, and
  reflexivity gives `X ⊆ [X]^{Φ∩Ψ}`). This is the first Explanation derived
  from a formal proof rather than from another informal one (Section 11a.5).
- `ingest.py` regenerated the registry with the new `explanation` facet.
- **Independent adversarial read** (fresh agent, definitions + proof only, no
  project history): returned **VALID, no gap**. It reconstructed the argument,
  confirmed the meet direction and the reflexivity bound, probed `X = ∅`,
  empty sorts, `X = A`, `Φ = Ψ`, meet = bottom/top, and confirmed the
  `Ψ`-saturation hypothesis is genuinely unused (the stronger
  `Φ-Sat(A) ⊆ (Φ ∩ Ψ)-Sat(A)` holds). Recorded as **`E-000012`** (review,
  `pass`, R1, `adversarial_reader`).
- `B-C002` now has review, correspondence, and verification all `pass`.
- Manuscript `check_all`: **13 passed, 0 failed**.

**Finding (stale test premise, not a regression).**

- `propagation_test.py` used `B-C002` as its "missing own proof, no
  explanation" fail-closed example. Adding the Explanation made that premise
  false, so the check failed. Updated it to `B-P001` (a proposition the
  manuscript still states without proof and with no Explanation). This is the
  intended behaviour of an explanation substituting for an absent proof; the
  test now uses a genuinely unproofed block.

**Phase 0 status.** The exit deliverable "one omitted manuscript proof
reconstructed from its formal counterpart and adversarial-read" is now met at
the **proposal** level (`B-C001` and `B-C002`); **author acceptance** of either
Explanation into the manuscript remains a reserved decision (Section 16.4).
`B-C001` is reconstructed from the informal `B-P002`; `B-C002` from Lean.

**Prioritized next steps.**

1. Remaining bridges `sat_eq_preimage`, `card_le_one_iff` (`B-D004`); extend the
   declaration map to multi-declaration blocks (`B-D014`).
2. Seeded-mismatch calibration suite (Section 11.4) -- still the largest
   missing mechanical piece; the audit pipeline now exists and can be exercised
   with mutated statements.
3. Independent representation audit (Section 11.5) and JSON-vs-YAML decision
   (author).

---

## Session 15 -- 2026-09-14 -- seeded-mismatch calibration suite (Section 11.4)

**Goal.** Stand up the calibration suite the roadmap has repeatedly deferred
("stood up early"), and take a first measurement.

**What was established (closed).**

- `calibration/seeded.json` -- a corpus of **11 cases** over the audited pilot
  blocks (`B-C001`, `B-P002`, `B-C002`, `B-P003`): 4 **controls** (the audited
  read-backs) and 7 **mutations**, one per named type: `direction_flip`,
  `conclusion_reverse`, `saturation_order`, `quantifier_change`,
  `dropped_hypothesis`, `weakened_conclusion`, `encoding` (the last is the
  highest-value seeded encoding mismatch of Section 11.5).
- `scripts/calibration.py` -- corpus self-check (controls equal their base
  read-back, mutations differ, ids unique), blind verdict ingestion,
  per-mutation-type detection rates and control false-positive count, plus a
  deterministic `reports/calibration.md` with `--check-report` drift detection.
- `scripts/calibration_test.py` -- 10 seeded checks, all pass (corpus
  integrity; detection counting; control false positives; `formal_stronger`
  counts as a detection).
- **First measurement** (`calibration/verdicts.json`, run by a blind comparator
  pass): **7/7 mutations detected, 0/4 control false positives**
  (`reports/calibration.md`). Outcomes were typed, not just pass/fail: e.g.
  dropped hypothesis -> `formal_stronger`, quantifier `∀`->`∃` ->
  `formal_weaker`, tautologised conclusion -> `ill_posed`.
- `scripts/check_all.sh` extended to **16 checks** (calibration corpus,
  statistics tests, report drift). Current result: **16 passed, 0 failed**.

**Honest caveats (recorded in the corpus and the report).**

- The first run is a **single batched comparator pass on this session's model**;
  each mutation type has **n = 1**. The 7/7 is an initial point estimate, not a
  stable per-type detection rate, and does not demonstrate cross-model value.
  The suite is built to make the next runs (per-case, second model) cheap and
  comparable; a drop after any model/prompt change is meant to gate the change.

**Prioritized next steps.**

1. Run the calibration per-case and, where a second model is available, by
   model pair; grow each mutation type to n >= a few so the rates are stable.
2. Remaining bridges `sat_eq_preimage`, `card_le_one_iff` (`B-D004`); extend the
   declaration map to multi-declaration blocks (`B-D014`).
3. Independent representation audit (Section 11.5); JSON-vs-YAML decision.

---

## Session 16 -- 2026-09-14 -- independent encoding audit (Section 11.5)

**Goal.** Replace the same-session representation self-audit (`E-000002`) with
an isolated-context encoding audit -- the highest-leverage audit in the system
(Section 11.5).

**What was established (closed).**

- A fresh, isolated subagent was given the **paper's ZFSK foundation** and the
  **proposed Lean encoding table**, but **not** the project's residual list,
  and asked to enumerate divergences and type the outcome. It returned
  **`faithful-with-caveat`**, judging the membership/order core (pointwise
  subset, `Sub`, `Eqv`, saturation, support) faithful under the set-as-predicate
  translation, and enumerated **16 residuals**.
- **`evidence/E-000013.json`** records it (representation layer,
  `encoding_auditor`, isolated-context caveat). It supersedes `E-000002` for
  residual propagation (higher id, current), so the trust boundary now carries
  the independent audit's residuals.
- Three residuals are flagged **blocking-until-bridged**; none is a defect in
  the current Lean:
  - `R-delta`: `δ^t` uses `Set.univ`, not a singleton, so set/cardinality-level
    facts (`A × 1 ≅ A`) fail -- the support level is recovered by `supp_delta`
    (with `Nonempty U`).
  - `R-quotient`: `Quotient` is a type, not of the form `S → Set U`, so `A/Φ`
    leaves the encoded object class.
  - `R-complement`: relative complement must be `sdiff`, **as encoded**, never
    ambient `compl`.
- `scripts/trust.py`'s residual parser generalised from `D<digit>` to arbitrary
  short tags (`D1` *and* `R-carrier`, ...); `trust_test.py` now 13 checks.
  `reports/trust_boundary.md` propagates the 16 residuals to all 11 covered
  blocks.

**Residual cross-walk (for readers of the representation file).** The
representation's original `D1`-`D7` appear in the independent set as
`R-universe` (D1), `R-carrier`/`R-membership` (D2), `R-complement` (D3),
`R-setoid`/`R-order` (D4), `R-quotient` (D5), `R-classical` (D6), `R-empty`
(D7). The rest (`R-index`, `R-product`, `R-morphism`, `R-coproduct`,
`R-category`, `R-ext`) are bridgeable-obligation or out-of-pilot-scope
categorical omissions, not pilot defects.

**Honest caveat.** The audit is isolated-context but still shares this session's
model; the reported residuals are a same-model judgment, stronger than the
self-audit it supersedes, weaker than external review.

**Current state.** `check_all`: **16 passed, 0 failed**. `B-C001` has all
three layers current; `B-C002`/`B-P002`/`B-P003` correspondence + verification;
`B-D006` verification.

**Prioritized next steps.**

1. Address the blocking residuals where the pilot touches them: prove the
   `R-complement` bridge (`sdiff` vs `compl`), decide the `R-delta` singleton
   model, and prove the `R-quotient`/`R-setoid` bridges (`setoid_le_iff` done;
   add `quot_class_bridge`).
2. Remaining pilot bridges `sat_eq_preimage`, `card_le_one_iff` (`B-D004`);
   multi-declaration mapping for `B-D014`.
3. Per-case / second-model calibration runs.

---

## Session 17 -- 2026-09-14 -- C4 propagation cycle (blast-radius view)

**Goal.** Close Phase 0's "one definition change propagates end to end" by
building the missing Section 19 blast-radius view and running it on the real
records.

**What was established (closed).**

- `scripts/impact.py` -- non-destructive change-impact analysis: simulate a
  facet change in memory, apply the validity rule to the **committed evidence**,
  and report (a) the currently-current records that would go stale and (b) the
  transitive downstream users of the changed block. `--report`/`--check-report`
  produce `reports/impact.md`.
- `scripts/impact_test.py` -- 7 checks on the real repo, all pass.
- **Phase 0 C4 demonstration.** A proposed change to the pilot definition's
  statement `B-D014/informal_statement` would:
  - stale **6** current records (5 blocks): `E-000001`/`E-000004` (B-C001),
    `E-000006` (B-P002), `E-000008` (B-P003), `E-000011`/`E-000012` (B-C002);
  - stale **no verification record** -- confirming the statement/proof
    separation (Section 13.1): review/correspondence bind to the dependency
    statement, verification binds only to a block's own `formal_proof`;
  - reach **26 downstream blocks** (transitive `uses_statement`/`uses_definition`
    users).
- `scripts/check_all.sh` extended to **18 checks** (impact tests + impact report
  drift). Current: **18 passed, 0 failed**.

**Reserved decision (escalation opened).** The actual `B-D014` change is a
**definition/contract change**, which only the author can accept (Sections 13.2
class C4, 16.4). Logged as `EV-000019` (`escalation_opened`) with the blast
radius above; the impact report is the decision-queue artifact.

**Known gap (documented, not fixed).** On the formal side, a definition change
should propagate through each dependent's `formal_statement`, whose Section 6
definition includes its **definition closure**. Our `formal_statement` hashes
only the declaration's own signature text, and verification binds only to
`formal_proof`, so a formal definition change does **not** currently stale a
dependent's verification. Closing this needs Lean dependency extraction
(`formal_uses`, Section 12.1) folded into `formal_statement`; deferred, and
recorded as the next structural item.

**Phase 0 status.** `B-C001`/`B-C002` Explanations exist and were adversarial-
read (proposals, author acceptance reserved); the definition-change blast radius
is now demonstrable end to end. The remaining Phase 0 item is author acceptance.

**Prioritized next steps.**

1. Formal dependency extraction (`formal_uses`) -> definition-closure hashing,
   so C4 propagates on the formal side too.
2. Remaining pilot bridges `sat_eq_preimage`, `card_le_one_iff` (`B-D004`);
   multi-declaration mapping for `B-D014`.
3. Views: discrepancy report (informal vs formal graph), decision queue,
   evidence bundle.

---

## Session 18 -- 2026-09-14 -- formal dependencies and the discrepancy report

**Goal.** Close the formal-side dependency gap (`formal_uses`, Section 12.1) by
supporting multi-declaration blocks, then build the Section 12.2 discrepancy
view.

**What was established (closed).**

- `lean/declarations.json` now accepts `decls` (a list) as well as `decl`.
  `B-D014` is mapped to its three declarations `SortedEqv`, `sat`, `IsSat`
  (the previous one-declaration-per-block limitation); **9 blocks** are now
  mapped.
- `scripts/lean_facets.py` computes a block's statement/proof facets from all
  its declarations and extracts **`formal_uses`** edges by whole-identifier
  occurrence, writing `blocks/formal_graph.json` (**13 edges**). `--check`
  covers both files. This is the missing formal dependency graph.
- `scripts/discrepancy.py` + `discrepancy_test.py` + `reports/discrepancy.md`
  compare the informal confirmed graph with the formal graph over the mapped
  universe.
- `scripts/check_all.sh` extended to **20 checks**. Current: **20 passed, 0
  failed**.

**Findings from the discrepancy report (a review queue, not verdicts).**

- **9 formal-only edges**, mostly `X -> B-D002`: the Lean signatures use the
  `SSorted` type, but the informal prose says "`S`-sorted set" by name and the
  prose-name extractor did not record an edge. Expected, but it shows the
  informal graph under-approximates the type dependency.
- **1 informal-only edge, `B-P002 -> B-D006`**: the informal graph says `B-P002`
  depends on `delta` (`B-D006`), but the formal proof `Mslang.prop_incSat`
  **does not use `delta`**. This is a concrete Section 12.2 signal -- a possibly
  spurious symbol edge (recall the `\delta` edges were symbol-extracted) or a
  simplification opportunity. Flagged for review; not resolved.
- No `B-C002 -> B-C001` informal edge, yet the formal `sat_inf` uses
  `sat_antitone`: a formal-only edge (the manuscript proof of `B-C002` is
  omitted; our Explanation cites `B-C001`).

**Note.** Mapping `B-D014` adds formal facets for a block no evidence record
lists, so nothing went stale; the formal graph is new information.

**Prioritized next steps.**

1. Resolve the `B-P002 -> B-D006` discrepancy (author/reviewer): spurious edge
   or real omitted step.
2. Fold `formal_uses` into `formal_statement` (definition closure) so a formal
   definition change propagates to dependents (Session 17's documented gap).
3. Remaining pilot bridges `sat_eq_preimage`, `card_le_one_iff` (`B-D004`).
4. Decision-queue and evidence-bundle views.

---

## Session 19 -- 2026-09-14 -- discrepancy findings resolved

**Goal.** Resolve the Session 18 discrepancy signals by inspecting the source.

**Findings (concrete, from the manuscript).**

- **`B-P002 -> B-D006` is a real informal edge and a formal simplification.**
  The manuscript's converse proof of `B-P002` constructs its test family via
  `\delta^{s,[a]_{\Psi_s}}` (so the paper genuinely uses `delta`, `B-D006`).
  The Lean proof `Mslang.prop_incSat` instead uses a plain singleton family
  (`Function.update (fun _ => ∅) s {x}`), which is *simpler* and does not need
  `delta`. Verdict: the paper's `\delta` use in `B-P002`'s converse is
  **unnecessary** -- a formalization-produced simplification (the Section 12.2
  payoff), not a defect. (`supp_delta` does use `delta`, so `B-D006` is still
  genuinely used.)
- **`B-C002 -> B-C001`** is formal-only and expected: `sat_inf` applies
  `sat_antitone`; the manuscript omits `B-C002`'s proof, and our Explanation
  cites `B-C001`.
- **`X -> B-D002`** (the majority of formal-only edges) is expected: Lean
  signatures mention the `SSorted` type; the informal prose says "`S`-sorted
  set" by name, which the prose-name extractor did not record.

**What was established (closed).**

- `blocks/discrepancy_notes.json` + `discrepancy.py` support: the
  discrepancy report now carries a **Reviewer notes** section, turning the raw
  diff into a review queue with recorded verdicts. `reports/discrepancy.md`
  regenerated; `discrepancy_test.py` checks the annotation.
- Gate: **20 passed, 0 failed**.

**Author-facing finding.** The manuscript's `B-P002` converse can be simplified
by dropping the `\delta` construction in favour of a singleton test family.
This is a manuscript-prose change (Section 16.5), so it is presented as a
finding, not edited.

**Prioritized next steps.**

1. Fold `formal_uses` into `formal_statement` (definition closure) so a formal
   definition change propagates to dependents (Session 17's gap).
2. Remaining pilot bridges `sat_eq_preimage`, `card_le_one_iff` (`B-D004`).
3. Decision-queue and evidence-bundle views; per-case/second-model calibration.

---

## Session 20 -- 2026-09-14 -- B-D004 and B-R006 bridges

**Goal.** Discharge two more encoding bridges: `card_le_one_iff` (`B-D004`) and
`sat_eq_preimage` (`B-R006`).

**What was established (closed).**

- `B-D004` formalized (`lean/Mslang/Pilot.lean`): `Subfinal`, `finalSorted`
  (`1^S`), `initialSorted` (`∅^S`); bridge `card_le_one_iff`
  (`Subfinal A ↔ ∀ s, (A s).encard ≤ 1`, using e-cardinality so the infinite
  case is covered); `supp_finalSorted` (`= univ`, needs `Nonempty U`) and
  `supp_initialSorted` (`= ∅`).
- `B-R006` formalized: `pr` (`Quotient.mk`); `sat_eq_preimage`
  (`[X]^Φ = (pr^Φ)⁻¹[pr^Φ[X]]`); and the second half `isSat_iff_preimage`
  (`X` is `Φ`-saturated iff `X = pr⁻¹[Y]` for some family `Y`).
- Clean build, 0 warnings. Axioms: `card_le_one_iff`
  `[propext, Classical.choice, Quot.sound]`; `sat_eq_preimage` /
  `isSat_iff_preimage` `[propext, Quot.sound]` -- all permitted.
- `lean/declarations.json` maps `B-D004` and `B-R006` (**11 declarations**;
  formal graph now **16 edges**). Verification records **`E-000014`**
  (`B-D004`) and **`E-000015`** (`B-R006`).
- `check_all`: **20 passed, 0 failed**. 8 blocks now have evidence.

**Prioritized next steps (continuing autonomously).**

1. Fold `formal_uses` into `formal_statement` (definition closure) so a formal
   definition change propagates to dependents.
2. Decision-queue view (Section 19) consolidating the open author decisions.
3. `B-R008` (`∅^S, A ∈ ∇^A-Sat(A)` and unions of deltas) + correspondence for
   the new blocks.

---

## Session 21 -- 2026-09-14 -- decision queue and evidence bundle

**Goal.** Build the two remaining Section 19/23 project views: the author
decision queue and the third-party evidence bundle.

**What was established (closed).**

- `decisions/standing.json` + `scripts/decisions.py` -- the **decision queue**:
  8 standing reserved decisions (Explanations, representation, record format,
  scope, the `B-P002` simplification, toolchain, calibration models) merged with
  open journal `escalation_opened` events (currently `EV-000019`, the `B-D014`
  change). Rendered to `reports/decisions.md`; `decisions_test.py` checks it.
- `scripts/bundle.py` -- a deterministic, self-contained
  `reports/bundle.md` (Section 23 / Phase 5 exit): a sha256 **manifest** of the
  durable artifacts, the per-block status vector, the full evidence records, and
  the current views (trust boundary, calibration, discrepancy, impact,
  decisions). `--check-report` detects drift.
- `scripts/check_all.sh` extended to **23 checks**. Current: **23 passed, 0
  failed**.

---

## Session 22 -- 2026-09-14 -- B-R008

**Goal.** Formalize the last pilot remark in scope: `B-R008`.

**What was established (closed).**

- `lean/Mslang/Pilot.lean`: `deltaUnion` (`⋃_{t∈T} δ^{t,A_t}`), and
  `nabla_sat_empty` (`∅^S ∈ ∇^A-Sat(A)`), `nabla_sat_univ` (`A ∈ ∇^A-Sat(A)`),
  `nabla_sat_deltaUnion` (`⋃_{t∈T} δ^{t,A_t} ∈ ∇^A-Sat(A)`) -- the last by
  `nabla_sat`.
- Clean build, 0 warnings; axioms within the permitted set.
  `B-R008` mapped; **12 declarations, 19 formal edges**; verification record
  **`E-000016`**.
- `check_all`: **23 passed, 0 failed**.

**Pilot coverage now.** `B-D002`, `B-D004`, `B-D005`, `B-D006`, `B-D009`,
`B-D014`, `B-R006`, `B-R008`, `B-C001`, `B-C002`, `B-P002`, `B-P003` all have
Lean counterparts; evidence for 9 blocks.

**Prioritized next steps (continuing autonomously).**

1. Fold `formal_uses` into `formal_statement` (definition closure), re-baselining
   the correspondence records deliberately; or extend `impact.py` to traverse
   formal edges.
2. Correspondence audits (blind) for `B-D004`/`B-R006`/`B-R008`.
3. Per-case / second-model calibration runs.

---

## Session 23 -- 2026-09-14 -- definition closure in formal_statement (gap closed)

**Goal.** Close the formal C4 gap flagged in Session 17: a formal definition
change must propagate to dependents.

**What was established (closed).**

- `scripts/lean_facets.py`: `formal_statement` now hashes the declaration's own
  signature **together with its transitive definition closure** (the formal
  dependency statements), exactly as Section 6 specifies; proofs are excluded,
  so proof irrelevance is preserved. `blocks/formal.json` records each block's
  `definition_closure` list.
- **Consequence, and it is the correct behaviour:** recomputing the facets
  staled exactly the **4 correspondence records** (their `formal_statement`
  input changed) and nothing else. They were **superseded** by fresh records
  `E-000017`..`E-000020`; the read-back bundles already included the definitions
  (the definition closure), so the `equivalent` verdicts are unchanged -- noted
  in each new record.
- `scripts/impact.py` now propagates through `formal_graph.json`: a change to a
  definition's `formal_statement` **or to a definition's body** (`formal_proof`
  of a `kind: definition` block, class C4) stales the correspondence records of
  all formal dependents; a **theorem's** proof change (C1) stays local to its own
  verification. `impact_test.py` now 9 checks, all pass.
- `check_all`: **23 passed, 0 failed**.

**Prioritized next steps.**

1. Blind correspondence for `B-D004`, `B-R006`, `B-R008`.
2. Per-case / second-model calibration runs.
3. Resolve remaining residual bridges (`R-delta` singleton model, `R-quotient`
   element-level).

---

## Session 24 -- 2026-09-14 -- correspondence catches an encoding mismatch (B-D004)

**Goal.** Blind correspondence for `B-D004`.

**Finding (the audit pipeline working as intended).**

- Stage 2 returned **`incomparable`** for `B-D004`. `Subfinal` (`card ≤ 1`) and
  `initialSorted` (`∅^S`) match the contract, but **`finalSorted` is `Set.univ`
  (the whole ambient), not the paper's constant-singleton terminal `1^S`**.
  With `|U| ≥ 2` it is strictly larger; with `U = ∅` it degenerates to
  `initialSorted`. Recorded as **`E-000021`** (correspondence, `incomparable`);
  `B-D004` correspondence status is now **`fail`** (its verification remains
  `pass`). Transcript `blocks/audits/B-D004-correspondence.md`.
- Classification **`F-representation`** (Section 10.2), the concrete form of
  encoding residual **`R-delta`**. Proposed remedy: encode `1^S` as a chosen
  singleton (`fun _ => ({x₀} : Set U)`, needing `Nonempty U`) and re-prove
  `supp_finalSorted`; blast radius `B-D004` + `supp_finalSorted` only (the pilot
  theorems use `A` itself, not `finalSorted`).
- This is a **representation change (class C6)**, reserved to the author
  (Sections 11.5, 16.4). Opened **escalation `EV-000027`** and added standing
  decision **`D-finalSorted`**; the change was **not** applied.
- `check_all`: **23 passed, 0 failed**.

**Prioritized next steps.**

1. Author: decide `D-finalSorted` (re-encode `1^S` or accept the caveat).
2. Blind correspondence for `B-R006`, `B-R008`.
3. Per-case / second-model calibration runs.

---

## Sessions 25-26 -- 2026-09-14 -- correspondence for B-R006 and B-R008

**Goal.** Blind correspondence for the two remaining pilot remarks.

**What was established (closed).**

- **`B-R006`** (`sat_eq_preimage`, `isSat_iff_preimage`): stage 2 returned
  **`equivalent`** (contract sentence 2, `X ⊇ [X]^Φ`, is a one-line consequence
  of `IsSat` plus reflexivity). Transcript
  `blocks/audits/B-R006-correspondence.md`; record **`E-000022`**.
- **`B-R008`** (`nabla_sat_empty`, `nabla_sat_univ`, `nabla_sat_deltaUnion`):
  stage 2 returned **`equivalent`** (`nabla` = `∇^A`; the all-`A` family is `A`
  as a subset; `deltaUnion T A` = `⋃_{t∈T} δ^{t,A_t}`; boundary cases `T = ∅`
  and `T = S` agree). Transcript `blocks/audits/B-R008-correspondence.md`;
  record **`E-000023`**.
- `check_all`: **23 passed, 0 failed**. **9 blocks** with evidence; 23 evidence
  records.

**Pilot status.** Every in-scope pilot block (`B-D002`, `B-D004`, `B-D005`,
`B-D006`, `B-D009`, `B-D014`, `B-R006`, `B-R008`, `B-C001`, `B-C002`, `B-P002`,
`B-P003`) has a Lean counterpart and at least a verification record.
Correspondence is `equivalent` for `B-C001`, `B-C002`, `B-P002`, `B-P003`,
`B-R006`, `B-R008`; **`incomparable` for `B-D004`** (the `finalSorted`/`1^S`
representation finding, `E-000021`, author decision `D-finalSorted`).

**Open author decisions (queue).** `D-finalSorted` (representation fix),
`D-explanation-c001`, `D-explanation-c002`, `D-representation`, `D-record-format`,
`D-pilot-scope`, `D-bp002-simplification`, `D-toolchain`, `D-calibration-models`;
journal escalation `EV-000027` (and `EV-000019`).

**Prioritized next steps.**

1. Author: work the decision queue (`reports/decisions.md`).
2. Per-case / second-model calibration runs.
3. `R-quotient` element-level bridge; `R-delta` model (per `D-finalSorted`).

---

## Session 27 -- 2026-09-14 -- sanity checks, frontier, quotient classes

**Goal.** Author-input-free work: the Section 11.3 formal sanity checks, the
Section 19 frontier view, and the element-level quotient bridge.

**What was established (closed).**

- **Formal sanity checks (Section 11.3).** `lean/Mslang/Sanity.lean`: a concrete
  two-sort/two-element model (`exA`, `discrete`), with
  - `sanity_not_subfinal` (convention check: a two-element component is not
    subfinal);
  - `sanity_nonvacuous` (non-vacuity: an instance where `sat_antitone`'s
    hypotheses are jointly satisfiable and its conclusion holds);
  - `sanity_converse_counterexample` (negation probe: with `Φ` discrete and `Ψ`
    universal a family is `Φ`-saturated but not `Ψ`-saturated, so the converse
    of `B-C001` is false -- its direction is essential).
  All compile with permitted axioms. `blocks/sanity.json` + `scripts/sanity.py`
  -> `reports/sanity.md`.
- **Frontier view (Section 19).** `scripts/frontier.py` + `blocks/bridges.json`
  -> `reports/frontier.md`: layers not passing (currently `B-D004`
  correspondence `fail`), open representation bridges (**none** -- all five
  pilot bridges are now discharged), the 117 blocks with no Lean counterpart,
  and the open author decisions.
- **Element-level quotient bridge (`R-quotient`).** `eqvClass` and
  `eqvClass_eq_iff` (`eqvClass Φ s a = eqvClass Φ s b ↔ Φ s a b`) in
  `lean/Mslang/Pilot.lean`; the full quotient-classes bijection is deferred.
- `scripts/check_all.sh` extended to **25 checks**. Current: **25 passed, 0
  failed**.

**Prioritized next steps.**

1. Per-case / second-model calibration runs.
2. Author: work `reports/decisions.md` (esp. `D-finalSorted`).
3. Full `Quotient (Φ s) ≃ {classes}` bijection; `R-delta` model.

---

## Session 28 -- 2026-09-14 -- B-D015 (kernel)

**Goal.** Extend the pilot with the last cleanly-encodable definition, `B-D015`.

**What was established (closed).**

- `lean/Mslang/Pilot.lean`: `SortedMap A B := ∀ s, A s → B s` (the
  componentwise-function encoding of an `S`-sorted mapping, `B-D002`) and
  `ker f` (`B-D015`), the componentwise kernel pair of `f`, with
  `ker_iff : (ker f s).r x y ↔ f s x = f s y`. Clean build; `ker_iff` uses **no
  axioms**.
- `B-D015` mapped; **13 declarations, 21 formal edges**; verification record
  **`E-000024`**. **10 blocks** with evidence.
- `check_all`: **25 passed, 0 failed**.

**Note.** `B-D003` (product) is deliberately not formalized: the product's
component `∏_i A^i_s` is a set of functions, not a subset of the fixed ambient
`U`, so it leaves the encoded object class -- a concrete instance of residual
`R-product`/`R-carrier`, not a mere omission.

**Prioritized next steps.**

1. Author: decision queue (`reports/decisions.md`; `D-finalSorted`).
2. Full `Quotient (Φ s) ≃ {classes}` bijection; per-case calibration runs.

---

## Session 29 -- 2026-09-14 -- C6 representation change (dependent-type carrier)

**Goal.** Implement the author's chosen representation: `SSet S := S → Type u`
(a family of types, not subsets of a fixed ambient `U`).

**What was established (closed).**

- `lean/Mslang/Pilot.lean` and `lean/Mslang/Sanity.lean` **rewritten** for the
  new carrier; `SortedMap`, `ker`, `delta` (`PUnit`/`PEmpty`), `finalSorted`,
  `initialSorted`, `supp` (`Nonempty`), `Sub`/`Subset`, `complA`, `eqvClass`,
  quotient definitions all adapted. Clean build, **0 warnings**, all axioms
  within the permitted set.
- `representation/pilot-encoding.md` rewritten (Section 2 = dependent-type
  encoding; resolved residuals `R-delta`, `R-quotient`, `R-product`,
  `R-complement`). `lean/declarations.json` remapped (`B-D002 → SSet`,
  `B-D005 → Sub/Subset`); **13 declarations, 27 formal edges**.
- **C6 invalidation and re-baseline.** Every facet hash changed. Re-issued all
  13 **verification** records (`E-000025`..`E-000037`) and the 2 **review**
  records (`E-000038`/`E-000039`). Fresh independent **encoding audit**:
  **`faithful-with-caveat`** with just **3 residuals**
  (`carrier-model`, `small-large`, `univalence-missing`), down from 16;
  recorded `E-000040`.
- `scripts/impact_test.py` made re-baseline-robust (synthetic records from
  closures, block/layer-based) rather than hard-coding superseded IDs.
- `D-finalSorted` closed (the new encoding makes `1^S` a genuine `PUnit`
  family); escalation `EV-000027` resolved.
- `check_all`: **25 passed, 0 failed**.

**Pending (documented, not done).** The 6 **correspondence** records are now
**stale** (`B-C001`, `B-C002`, `B-P002`, `B-P003`, `B-R006`, `B-R008`): the Lean
statements changed, so each needs a fresh blind read-back/comparison
(Section 11.2). Listed in `reports/frontier.md`.

**Prioritized next steps.**

1. Re-run the 6 correspondence audits under the new encoding.
2. Per-case / second-model calibration runs.

---

## Session 30 -- 2026-09-15 -- correspondence re-baseline under the new encoding

**Goal.** Execute Session 29's pending item: re-run the 7 correspondence audits
that the C6 representation change staled (`B-C001`, `B-C002`, `B-D004`,
`B-P002`, `B-P003`, `B-R006`, `B-R008`).

**What was established (closed).**

- All 7 blocks re-audited with the **two-stage blind protocol** (Section 11.2):
  a fresh stage-1 read-back from the Lean declarations only, then a fresh
  stage-2 comparator given only the read-back and the manuscript contract.
  **Every stage-2 comparator returned `equivalent`.** Transcripts rewritten in
  `blocks/audits/<id>-correspondence.md`.
- **`B-D004` flipped `incomparable` -> `equivalent`.** The pre-C6
  `finalSorted = Set.univ` was not the paper's constant-singleton `1^S`; the
  dependent-type carrier makes it a genuine constant `PUnit` family, so the
  correspondence now matches. This closes the last residue of the `D-finalSorted`
  finding (already resolved as a contract in Session 29).
- Records **`E-000041`..`E-000047`** (correspondence, `equivalent`; inputs
  computed by `closure.py`). They supersede the stale pre-C6 correspondence
  records (`E-000004`, `E-000006`, `E-000008`, `E-000011`, `E-000018`,
  `E-000019`, `E-000020`, `E-000021`, `E-000022`, `E-000023`), which remain in
  `evidence/` as the historical record.
- `reports/frontier.md` now shows **no layer failing and no open representation
  bridge**; `reports/{coverage,staleness,impact,bundle,frontier}.md` regenerated.
  `check_all`: **25 passed, 0 failed**.

**Pilot status (all current).** Every in-scope pilot block has a Lean
counterpart; review + correspondence + verification are `pass` where each layer
was run. 12 blocks carry evidence (47 records total). The representation audit is
`faithful-with-caveat` with 3 residuals (`carrier-model`, `small-large`,
`univalence-missing`, `E-000040`), all bridgeable-or-out-of-scope, none blocking.

**Honest caveat.** Both audit stages (and the encoding audit before them) still
share this session's underlying model (`deepseek-v4.1-flash`); the verdicts are
independent-context but same-model, weaker than external review.

**Prioritized next steps.**

1. Per-case / second-model calibration runs (Section 11.4); the batched 7/7 is
   still n = 1 per mutation type.
2. Author: work `reports/decisions.md` (Explanations, representation, record
   format, scope).
3. Extend the formalization frontier to the 116 blocks with no Lean counterpart.

---

## Session 31 -- 2026-09-15 -- per-case calibration run (Section 11.4)

**Goal.** Execute Session 30's step 1: run the calibration corpus per-case rather
than batched, so the eleven judgments are independent contexts. No second model
is available on this machine, so the model-pair run remains open.

**What was established (closed).**

- **Run 2 (per-case).** Each of the eleven cases was judged in its own isolated
  comparator context, blind to the case type and to the expected outcome:
  **7/7 mutations detected, 0/4 control false positives** -- identical to the
  batched run. Results are the primary measurement in
  `calibration/verdicts.json`; the batched run is retained at
  `calibration/verdicts.batched.json`.
- **Finding: the detection rate is robust, the typed outcome is not.** The
  category returned is identical for 9/11 cases. It differs for two mutations:
  `CAL-006` (`quantifier_change`) was `formal_weaker` batched vs
  `formal_stronger` per-case; `CAL-008` (`weakened_conclusion`) was `ill_posed`
  batched vs `formal_weaker` per-case. So batching did not change what is
  detected, but it did change how the mismatch is classified in 2/7 mutations --
  a reason to treat the per-type *labels* as less stable than the detection
  *rate*.
- `calibration/seeded.json`'s `audit_note` now describes both runs and the
  comparison; `reports/calibration.md` regenerated; the bundle refreshed.
  `check_all`: **25 passed, 0 failed**.

**Honest caveats (recorded in the note).** Both runs share this session's model
(`deepseek-v4.1-flash`); there is still **no cross-model** measurement. Each
mutation type still has **n = 1**, so the per-type rates are point estimates, not
stable rates. The per-case run increases context independence, not sample size.

**Prioritized next steps.**

1. Grow each mutation type to n >= a few (author corpus work) and, when a second
   model is available, run the model-pair comparison; a detection drop after any
   model/prompt change is the intended gate.
2. Author: work `reports/decisions.md` (Explanations, representation, record
   format, scope).
3. Extend the formalization frontier to the 116 blocks with no Lean counterpart.

---

## Session 32 -- 2026-09-15 -- frontier extension: B-P004

**Goal.** Execute Session 31's step 3: extend the formalization frontier to a
block with no Lean counterpart. Took the smallest remaining dependency-closed
target from `reports/pilot_candidates.md` whose only definition dependency
(`B-D014`) is already formalized: `B-P004`. Also reconciled the working tree.

**What was established (closed).**

- **Committed the pending Sessions 30-31** in two session commits (Session 30:
  correspondence re-baseline, `E-000041`..`E-000047`; Session 31: per-case
  calibration). `git status` is clean.
- **`B-P004` formalized.** New theorem `Mslang.sat_inf_subset`: saturation by a
  pointwise meet is contained in the meet of the saturations,
  `[X]^{Φ∩Ψ} ⊆ [X]^Φ ∩ [X]^Ψ`. Mapped in `lean/declarations.json`;
  `blocks/formal.json`/`blocks/formal_graph.json` regenerated (14 mapped blocks,
  11 formal edges).
- Build clean; `#print axioms Mslang.sat_inf_subset` reports **no axioms**.
- Evidence **`E-000048`** (verification, `build_ok`), **`E-000049`**
  (correspondence, `equivalent`; two-stage blind, transcript
  `blocks/audits/B-P004-correspondence.md`), **`E-000050`** (review, `pass`;
  adversarial read returned `VALID, no gap`, and observed that the equivalence
  axioms are never used -- the inclusion holds for arbitrary componentwise
  relations).
- `reports/frontier.md`: unmapped blocks **116 -> 115**; no layer failing and no
  open representation bridge. `reports/{coverage,trust_boundary,staleness,
  impact,discrepancy,bundle,decisions}.md` regenerated. Journal `EV-000034`.
  `check_all`: **25 passed, 0 failed**.

**Honest caveat.** All three layers share this session's model
(`deepseek-v4.1-flash`); the correspondence verdict is independent-context but
same-model, and inherits the pilot-encoding residuals (`carrier-model`,
`small-large`, `univalence-missing`).

**Prioritized next steps.**

1. Continue the frontier. Next dependency-closed targets: `B-R007` (the
   saturation map is antitone -- a near-immediate corollary of `sat_antitone`),
   `B-P005` (`SatOperator`, the saturation map as a completely additive closure
   operator), and `B-R005` (`supp_S(A) = supp_S(A/Φ)`, needs the quotient).
2. Grow each calibration mutation type to n >= a few and add a second model
   (author-gated; Section 11.4).
3. Author: work `reports/decisions.md` (now 8 standing items plus the
   `EV-000019` escalation).

---

## Session 33 -- 2026-09-15 -- author decision pass; queue emptied

**Goal.** Walk the author through the decision queue item by item and resolve
it, then implement the accepted changes.

**Author decisions (all recorded; `journal/events.jsonl` `EV-000035`..`EV-000037`).**

- `D-explanation-c001`, `D-explanation-c002` -- **accepted**; the reconstructed
  proofs for `B-C001` and `B-C002` were inserted into the manuscript as
  `\begin{proof}` bodies (Session 30's two-stage-blind correspondence already
  covers the statements; the proofs were adversarially read in `E-000001`/
  `E-000038` and `E-000012`/`E-000039`).
- `D-representation` -- **accepted**: the dependent-type encoding and audit
  `E-000040` (`faithful-with-caveat`; residuals `carrier-model`, `small-large`,
  `univalence-missing`). The stale `E-000013` reference is retired.
- `D-record-format` -- **keep JSON**. Blueprint (`Architecture.md` §7.2) now
  specifies JSON records and states why (dependency-free validation).
- `D-pilot-scope` -- **confirmed** the pilot = the 15 formalized blocks; added
  `B-P004`, `B-D004`, `B-R006`, `B-R008` to `representation/coverage.json`;
  **froze `B-D014`** (`EV-000036`).
- `D-bp002-simplification` -- **rejected**: keep the paper's
  `δ^{s,[a]_{Ψ_s}}` construction. The proposed "simplification" used `{a}` at
  `s`, which *is* `δ^{s,{a}}`, so `δ` is not eliminated; the discrepancy note is
  corrected accordingly.
- Delegated mechanical items: `D-toolchain` -- keep the machine toolchain;
  `D-calibration-models` -- accept same-model rates with the caveat.
- `EV-000019` -- **closed** as a completed blast-radius drill (no concrete
  `B-D014` edit was ever proposed).

**Process change (blueprint).** `Architecture.md` §16.4 now states that
mechanical decisions (format, layout, toolchain, calibration-model
availability, reconciling declared vs. actual pilot membership) are coordinator
decisions, reported but not escalated; only contracts, manuscript prose, the
representation, scope changes, freezes, and escalations are author-reserved. It
also fixes the **decision-brief format** this session used (author request):
reserved decisions are presented one at a time, each with a plain-language
keynote, the concrete artifact to audit, the consequences, and numbered
options. The safe-restart checklist gained item 11 to match.

**What was established (closed).**

- `decisions/standing.json` emptied; `decisions_test.py` rewritten to be
  state-independent (synthetic journal fixtures); `reports/decisions.md` now
  empty.
- Manuscript: `B-C001` and `B-C002` proofs added (the accents were preserved
  byte-for-byte; `blocks/hashes.json` 163 anchors, 33 proofs). Registry,
  graph, views, and bundle regenerated. `check_all`: **25 passed, 0 failed**.

**Honest caveats.** (1) The `blocks/explanations/B-C001.md` and `B-C002.md`
files are retained as provenance and still carry their "PROPOSED" header -- a
cosmetic staleness left for a batched C0 edit, since editing them (or the
representation record) stales representation-dependent evidence. (2)
`representation/pilot-encoding.md`'s prose cluster list still omits `B-P004`
for the same reason; `coverage.json` is the live list.

**Prioritized next steps.**

1. Continue the frontier: `B-R007` (antitone saturation map), then `B-P005`
   (`SatOperator`) and `B-R005`.
2. Batch the cosmetic docs (`explanations/*`, pilot-encoding cluster list) into
   one C0 edit with a carried-forward evidence decision.
3. Grow each calibration mutation type to n >= a few; add a second model when
   available.

---

## Session 34 -- 2026-09-15 -- frontier extension: B-R007

**Goal.** Continue the frontier (Session 33 step 1): formalize `B-R007`, the
order-theoretic restatement of `B-C001`.

**What was established (closed).**

- **`B-R007` formalized.** New `Mslang.satSets` (`Φ-Sat(A) := {X | IsSat Φ X}`)
  and `Mslang.satSets_antitone`
  (`sortedEqvLe Φ Ψ → satSets Ψ ⊆ satSets Φ`), the map `Φ ↦ Φ-Sat(A)` being
  antitone. Mapped in `lean/declarations.json`; `blocks/formal.json` /
  `formal_graph.json` regenerated (15 mapped blocks). Axioms: `propext`,
  `Quot.sound` (permitted).
- Evidence **`E-000051`** (verification, `build_ok`) and **`E-000052`**
  (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-R007-correspondence.md`). No review layer: a remark has no
  informal proof or explanation (as with `B-D004`).
- `reports/frontier.md`: unmapped blocks **115 -> 114**. Views and bundle
  regenerated. Journal `EV-000039`. `check_all`: **25 passed, 0 failed**.

**Honest caveat.** Same-model audit as always: the correspondence verdict is
independent-context but shares `deepseek-v4.1-flash`, and inherits the
pilot-encoding residuals.

**Prioritized next steps.**

1. Frontier: `B-P005` (`SatOperator`, the saturation map as a completely
   additive closure operator) is the substantial next target; `B-R005`
   (`supp_S(A) = supp_S(A/Φ)`) needs the quotient.
2. Batch the cosmetic docs (`explanations/*` PROPOSED headers, the
   `pilot-encoding.md` prose cluster list) into one C0 edit with a
   carried-forward evidence decision.
3. Calibration corpus growth and a second model (author-gated).

---

## Session 35 -- 2026-09-15 -- frontier extension: B-P005 (SatOperator)

**Goal.** Continue the frontier: formalize `B-P005`, the saturation map as a
completely additive (uniform, algebraic) closure operator.

**What was established (closed).**

- **`B-P005` formalized** as three predicates plus 13 operator lemmas
  (`lean/Mslang/Pilot.lean`): `IsClosureOperator` (extensive/monotone/idempotent),
  `IsCompletelyAdditive` (preserves arbitrary unions), `IsAlgebraic`
  (componentwise-finite witness); `sat_extensive`, `sat_monotone`, `sat_idem`,
  `sat_isClosureOperator`, `sat_iUnion`, `sat_isCompletelyAdditive`,
  `sat_isAlgebraic`, `sat_iInter_subset`, `sat_univ`, `sat_compl`,
  `suppSub_sat`, `sat_uniform`, `satSets_fix`. Axioms within the permitted set.
  Mapped in `lean/declarations.json` (16 declarations); facets regenerated
  (16 mapped blocks).
- Evidence **`E-000053`** (verification, `build_ok`) and **`E-000054`**
  (correspondence, **`formal_stronger`**; transcript
  `blocks/audits/B-P005-correspondence.md`). The only divergence: the formal
  meet-inclusion holds for every index type, dropping the contract's "nonempty
  `I`" (the empty case is `[A]^Φ ⊆ A`). No review layer (no informal proof).
- `reports/frontier.md`: unmapped blocks **114 -> 113**. Views and bundle
  regenerated. Journal `EV-000040`. `check_all`: **25 passed, 0 failed**.

**Honest caveat.** Same-model audit: the correspondence verdict is
independent-context but shares `deepseek-v4.1-flash`, and inherits the
pilot-encoding residuals. The `formal_stronger` verdict is a *positive* result
(the formalization proves more), but it is a typed divergence, so it is recorded
rather than silently folded into `equivalent`.

**Prioritized next steps.**

1. Frontier: `B-R005` (`supp_S(A) = supp_S(A/Φ)`, needs the quotient) and
   `B-P006` (`CABA Saturades`, the ordered pair on `Φ-Sat(A)`); `B-P005` now
   supplies the operator machinery.
2. Batch the cosmetic docs (`explanations/*` PROPOSED headers, the
   `pilot-encoding.md` prose cluster list) into one C0 edit with a
   carried-forward evidence decision.
3. Calibration corpus growth and a second model (author-gated).

---

## Session 36 -- 2026-09-15 -- frontier extension: B-R005

**Goal.** Continue the frontier: formalize `B-R005`, the support of the quotient.

**What was established (closed).**

- **`B-R005` formalized** as `Mslang.quot` (`A/Φ := fun s => Quotient (Φ s)`, an
  `SSet`) and `Mslang.supp_quot` (`supp (quot Φ) = supp A`). Mapped in
  `lean/declarations.json`; facets regenerated (17 mapped blocks). Axioms:
  `propext`, `Quot.sound`.
- Evidence **`E-000055`** (verification, `build_ok`) and **`E-000056`**
  (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-R005-correspondence.md`). The contract cites `propssupport`,
  but the Lean proof derives the equality directly from the quotient
  construction. No review layer (no informal proof).
- `reports/frontier.md`: unmapped blocks **113 -> 112**. Views and bundle
  regenerated. Journal `EV-000041`. `check_all`: **25 passed, 0 failed**.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals.

**Prioritized next steps.**

1. Frontier: `B-P006` (`CABA Saturades`): `Φ-Sat(A)` under `⊆` is a complete
   atomic Boolean algebra (atoms = the Kronecker deltas `δ^{t,[x]_{Φ_t}}`). This
   is a substantially larger target; may need a reduced scope.
2. Batch the cosmetic docs (`explanations/*`, `pilot-encoding.md` cluster list)
   into one C0 edit with a carried-forward evidence decision.
3. Calibration corpus growth and a second model (author-gated).

---

## Session 37 -- 2026-09-15 -- frontier extension: B-P007

**Goal.** Continue the frontier: formalize `B-P007`, the kernel and the
universal property of the quotient.

**What was established (closed).**

- **`B-P007` formalized** as `Mslang.quotLift` (the descent `A/Φ → B`),
  `Mslang.ker_pr` (`Ker(pr^Φ) = Φ`), `Mslang.quotLift_comp`
  (`f = p^{Φ,Ker(f)} ∘ pr^Φ`) and `Mslang.quotLift_unique` (uniqueness). The
  `Ker(f) ∈ Eqv(A)` clause is satisfied by the type of `ker`. Mapped in
  `lean/declarations.json`; facets regenerated (18 mapped blocks). Axioms:
  `propext`/`Quot.sound`.
- Evidence **`E-000057`** (verification, `build_ok`) and **`E-000058`**
  (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-P007-correspondence.md`). No review layer (no informal
  proof).
- `reports/frontier.md`: unmapped blocks **112 -> 111**. Views and bundle
  regenerated. Journal `EV-000042`. `check_all`: **25 passed, 0 failed**.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals.

**Prioritized next steps.**

1. Frontier: `B-P006` (`CABA Saturades`, `Φ-Sat(A)` is a complete atomic
   Boolean algebra) is a genuinely large target whose proof the manuscript
   leaves "to the reader"; likely a reduced/statement-only scope decision. Also
   open: the `Σ`-algebra layer (`B-D016` signatures, `B-D017` algebras,
   `B-D018` support, `B-D019` finite) needs word/`S⋆` product encodings.
2. Batch the cosmetic docs (`explanations/*`, `pilot-encoding.md` cluster list)
   into one C0 edit with a carried-forward evidence decision.
3. Calibration corpus growth and a second model (author-gated).

---

## Session 38 -- 2026-09-15 -- frontier extension: B-D003, B-D007

**Goal.** Continue the frontier into the foundational Preliminaries definitions
that the pilot cluster had skipped.

**What was established (closed).**

- **`B-D003` formalized**: products of sorted sets — `Mslang.iProd`
  (`∏_{i∈I} A^i := fun s => ∀ i, A i s`), `Mslang.iProj` (`pr^i`) and
  `Mslang.iPair` (`<f^i>`).
- **`B-D007` formalized**: image formation — `Mslang.directImage` (`f[X]`) and
  `Mslang.inverseImage` (`f⁻¹[Y]`).
- Mapped in `lean/declarations.json`; facets regenerated (20 mapped blocks).
- Evidence **`E-000059`** (B-D003) and **`E-000060`** (B-D007), both verification
  `build_ok`. Definitions carry the verification layer only, per the pilot
  convention (as with `B-D002`, `B-D005`, `B-D006`, `B-D009`, `B-D014`,
  `B-D015`); no correspondence audit, no review layer.
- `reports/frontier.md`: unmapped blocks **111 -> 109**. Views and bundle
  regenerated. Journal `EV-000043`. `check_all`: **25 passed, 0 failed**.

**Honest caveat.** Definitions only; the source-level `formal_statement` closure
over-approximates (whole-identifier occurrence), which the discrepancy report
tracks.

**Prioritized next steps.**

1. `B-P001` (`propssupport`): the support-mapping properties. Now that `B-D003`
   (products) and `B-D007` (images) exist, the main missing encoding is
   coproducts/unions/differences of sorted sets; several clauses are
   formalizable directly.
2. `B-D008` (finite sorted set) and `B-R003` (finite iff finite support with
   finite components).
3. `B-D010`-`B-D013` (closure system / compact / algebraic / uniform) connect
   to the `IsClosureOperator`/`IsAlgebraic` predicates already used in `B-P005`.
4. `B-P006` (`CABA`) remains the hard target; likely scope reduction.
5. Batch the cosmetic docs into one C0 edit; calibration growth (author-gated).

---

## Session 39 -- 2026-09-15 -- frontier extension: B-D001, B-D008

**Goal.** Continue the frontier into the foundational Preliminaries definitions.

**What was established (closed).**

- **`B-D008` formalized**: finiteness of sorted sets — `Mslang.FiniteSSet`
  (`Finite (Σ s, A s)`, the disjoint union `∐A`), `Mslang.FiniteSub`
  (finite componentwise subsets) and `Mslang.finiteSubsets` (`Sub_f(B)`).
- **`B-D001` formalized**: the free monoid `S*` on `S` — `Mslang.Word`
  (`= List S`), `Mslang.concat` (`++`) and `Mslang.emptyWord` (`[]`).
- Mapped in `lean/declarations.json`; facets regenerated (22 mapped blocks).
- Evidence **`E-000061`** (B-D001) and **`E-000062`** (B-D008), verification
  `build_ok`. Definitions carry the verification layer only.
- `reports/frontier.md`: unmapped blocks **109 -> 107**. Views and bundle
  regenerated. Journal `EV-000044`. `check_all`: **25 passed, 0 failed**.

**Honest caveat.** Definitions only; the `formal_statement` closure
over-approximates. `B-D008`'s finiteness encoding (`Sigma A` finite) deliberately
follows the paper's `∐A` definition rather than a componentwise `Finite`.

**Prioritized next steps.**

1. `B-R003` (finite iff finite support with finite components) — now that
   `B-D008` exists; needs a sigma-finiteness argument over `supp`.
2. `B-P001` (`propssupport`): needs coproduct/union/difference encodings.
3. `B-P006` (`CABA`) remains the hard target; likely scope reduction.
4. Batch the cosmetic docs into one C0 edit; calibration growth (author-gated).

---

## Session 40 -- 2026-09-15 -- frontier extension: B-D016, B-D017

**Goal.** Continue the frontier into the `Σ`-algebra layer.

**What was established (closed).**

- **`B-D016` formalized**: `Mslang.Signature S := List S × S → Type u` (an
  `S`-sorted signature `Σ : S* × S → 𝒰`, words as `List S`).
- **`B-D017` formalized**: `Mslang.wordProd` (`A_w = ∏_{i<|w|} A_{w_i}`),
  `Mslang.finOp` (`Hom(A_w, A_s)`), `Mslang.AlgStruct` (a structure of
  `Σ`-algebra), and `Mslang.IsAlgHom` (the homomorphism equation
  `f_s(F_σ(a)) = G_σ(f_w(a))`).
- Mapped in `lean/declarations.json`; facets regenerated (24 mapped blocks).
- Evidence **`E-000063`** (B-D016) and **`E-000064`** (B-D017), verification
  `build_ok`. Definitions carry the verification layer only.
- `reports/frontier.md`: unmapped blocks **107 -> 105**. Views and bundle
  regenerated. Journal `EV-000045`. `check_all`: **25 passed, 0 failed**.

**Honest caveat.** Definitions only; no correspondence audit (project
convention for definitions). The homomorphism carrier is the componentwise
`SortedMap`; `AlgStruct` records the operations but does not bundle an algebra
object (that would need a `structure`, which the facet extractor does not map).

**Prioritized next steps.**

1. `B-D018` (support of a `Σ`-algebra) and `B-R009` (supports of `Alg(Σ)` form
   a closure system) — now reachable from `B-D017`.
2. `B-D019` (finite `Σ`-algebra), using `B-D008`.
3. `B-R003` (finite iff finite support with finite components); `B-P001`
   (`propssupport`); `B-P006` (`CABA`, likely scope reduction).
4. Batch the cosmetic docs into one C0 edit; calibration growth (author-gated).

---

## Session 41 -- 2026-09-15 -- frontier extension: B-D018, B-D019

**Goal.** Finish the `Σ`-algebra layer's support/finiteness definitions.

**What was established (closed).**

- **`B-D018` formalized**: `Mslang.Alg Sig := Σ A : SSet S, AlgStruct Sig A` (a
  `Σ`-algebra as carrier + structure) and `Mslang.suppAlg` (the support of a
  `Σ`-algebra is the support of its underlying `S`-sorted set).
- **`B-D019` formalized**: `Mslang.FiniteAlg` (a `Σ`-algebra is finite when its
  carrier is finite, `B-D008`).
- Mapped in `lean/declarations.json`; facets regenerated (26 mapped blocks).
- Evidence **`E-000065`** (B-D018) and **`E-000066`** (B-D019), verification
  `build_ok`. Definitions carry the verification layer only.
- `reports/frontier.md`: unmapped blocks **105 -> 103**. Views and bundle
  regenerated. Journal `EV-000046`. `check_all`: **25 passed, 0 failed**.

**Honest caveat.** Definitions only. The `Σ`-algebra carrier is the raw
`SSet`/`AlgStruct` pair; `Σ`-homomorphisms are the predicate `IsAlgHom`, not a
bundled category (registering a category would be a representation decision).

**Prioritized next steps.**

1. `B-R009` (the supports of `Alg(Σ)` form a closure system on `S`) — a real
   proposition reachable now from `B-D016`-`B-D018`; needs an `IsClosureSystem`
   predicate on `Sub(S)`.
2. `B-R003` (finite iff finite support with finite components); `B-P001`
   (`propssupport`); `B-P006` (`CABA`, likely scope reduction).
3. Batch the cosmetic docs into one C0 edit; calibration growth (author-gated).

---

## Session 42 -- 2026-09-15 -- frontier extension: B-R003

**Goal.** Formalize `B-R003`, the finiteness characterization (first proposition
on the finite layer after `B-D008`).

**What was established (closed).**

- **`B-R003` formalized** as `Mslang.finiteSSet_iff`:
  `FiniteSSet A ↔ (supp A).Finite ∧ ∀ s, s ∈ supp A → Finite (A s)`. Proved from
  `B-D008` by a disjoint-union argument: forward uses `Finite.of_injective` on
  the fibers and on the support (`Classical.choice` of the nonemptiness
  witness); backward surjects the finite type `Σ s : ↥(supp A), A s` onto
  `Sigma A`. Mapped in `lean/declarations.json`; facets regenerated (27 mapped
  blocks). Axioms: `propext`, `Classical.choice`, `Quot.sound`.
- Evidence **`E-000067`** (verification, `build_ok`) and **`E-000068`**
  (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-R003-correspondence.md`). No review layer (no informal proof).
- `reports/frontier.md`: unmapped blocks **103 -> 102**. Views and bundle
  regenerated. Journal `EV-000047`. `check_all`: **25 passed, 0 failed**.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals. The
`↥(supp A)` subtype appears only inside the proof, not in the statement.

**Prioritized next steps.**

1. `B-R009` (supports of `Alg(Σ)` form a closure system on `S`): needs an
   `IsClosureSystem` predicate and closure of supports under nonempty
   intersection (product of `Σ`-algebras); a genuine but reachable target.
2. `B-P001` (`propssupport`): needs coproduct/union/difference encodings.
3. `B-P006` (`CABA`); the `B-D010`-`B-D013` closure-system vocabulary (entangled
   with `B-P005`'s predicates); batch cosmetic docs; calibration (author-gated).

---

## Session 43 -- 2026-09-15 -- staleness fix: re-issued B-P005 verification

**Goal.** Act on a frontier flag: `B-P005/verification` had gone **stale**.

**Root cause.** In Session 35 the verification `E-000053` was recorded, and then
`IsAlgebraic`/`sat_isAlgebraic` were added to `B-P005` a few steps later (to cover
the contract's "algebraic" clause). That changed the block's `formal_proof` hash,
so the earlier record no longer matched. Session 35's own reports regenerated the
frontier, but the stale row was not inspected at the time.

**Fix.** Re-issued `B-P005/verification` as **`E-000069`** (supersedes
`E-000053`, which remains as the historical record). `B-P005/verification` is
pass again; `reports/frontier.md` "Layers not passing" is empty; bundle
regenerated; `check_all`: **25 passed, 0 failed**. Journal `EV-000048`.

**Lesson (recorded in the journal).** After adding any declaration to a block
that already has verification evidence, re-issue that block's verification in
the same session, before committing.

**Prioritized next steps.**

1. `B-R009` (supports of `Alg(Σ)` form a closure system on `S`): needs an
   `IsClosureSystem` predicate and closure of supports under nonempty
   intersection (product of `Σ`-algebras).
2. `B-P001` (`propssupport`); `B-P006` (`CABA`); `B-D010`-`B-D013`; batch
   cosmetic docs; calibration (author-gated).

---

## Session 44 -- 2026-09-16 -- frontier extension: B-D024, B-D025, B-P009

**Goal.** Continue the frontier into the congruence and quotient-`Σ`-algebra
layer.

**What was established (closed).**

- **`B-D024` formalized**: `Mslang.IsCongruence` — a sorted equivalence
  compatible with every formal operation.
- **`B-D025` formalized**: `Mslang.quotOp` (the induced operation on `A/Φ`,
  representatives via `Quotient.out`), `Mslang.quotAlg` (the quotient
  `Σ`-algebra), `Mslang.prAlg` (the canonical projection), with
  `Mslang.quotOp_mk` (`F_{A/Φ,σ}([a]) = [F_σ(a)]`) and
  `Mslang.isAlgHom_prAlg` (`pr^Φ` is a homomorphism).
- **`B-P009` formalized**: `Mslang.ker_isCongruence` (`Ker(f) ∈ Cgr(A)`),
  `Mslang.ker_prAlg` (`Ker(pr^Φ) = Φ`), and the universal property
  `Mslang.quotAlgLift_isAlgHom` / `quotAlgLift_comp` / `quotAlgLift_unique`
  (the induced `p^{Φ,Ker(f)}` is a homomorphism, factors `f`, and is unique).
- Mapped in `lean/declarations.json`; facets regenerated (**29 mapped blocks**).
- Evidence **`E-000070`** (B-D024), **`E-000071`** (B-D025), **`E-000072`**
  (B-P009), all verification `build_ok`, axioms within the permitted set; and
  **`E-000073`** (B-P009 correspondence, `equivalent`; two-stage blind;
  transcript `blocks/audits/B-P009-correspondence.md`). Definitions carry the
  verification layer only; `B-P009` has no informal proof, so no review layer.
- `reports/frontier.md`: unmapped blocks **102 -> 99**. Views and bundle
  regenerated. Journal `EV-000049`. `check_all`: **25 passed, 0 failed**.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals. The
correspondence verdict notes that `quotAlgLift_unique` is stated for arbitrary
sorted maps rather than only homomorphisms — a harmless strengthening the
contract already entails (the projection is surjective). The quotient
representative selection makes `quotOp` noncomputable.

**Prioritized next steps.**

1. `B-R009` (supports of `Alg(Σ)` form a closure system on `S`): needs an
   `IsClosureSystem` predicate and closure of supports under nonempty
   intersection.
2. `B-R012` (the quotient by `∇` is subfinal) and the congruence-lattice
   clauses of `B-D024` (`∇`/`Δ`, `Cgr(A)` an algebraic closure system);
   `B-P001` (`propssupport`); `B-P006` (`CABA`); `B-D010`-`B-D013`; batch
   cosmetic docs; calibration (author-gated).

---

## Session 45 -- 2026-09-16 -- frontier extension: B-R009

**Goal.** Formalize `B-R009`, the long-standing next target: the supports of the
`Σ`-algebras form a closure system on the set of sorts `S`.

**What was established (closed).**

- **`B-R009` formalized**: `Mslang.IsClosureSystemOn` (an ordinary closure
  system on a set: contains the universe, closed under nonempty intersections),
  `Mslang.iAlg` (the product of a family of `Σ`-algebras, pointwise),
  `Mslang.suppAlg_iAlg` (the support of a product is the intersection of the
  factor supports) and `Mslang.supports_isClosureSystem` (universe clause: the
  constant one-element algebra `fun _ => PUnit` has support `Set.univ`;
  intersection clause: the product of chosen witnesses realizes `⋂₀ D`).
- Mapped in `lean/declarations.json`; facets regenerated (**30 mapped blocks**).
- Evidence **`E-000074`** (verification, `build_ok`; axioms
  `propext`/`Classical.choice`/`Quot.sound`) and **`E-000075`**
  (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-R009-correspondence.md`). No review layer (a remark with no
  informal proof).
- `reports/frontier.md`: unmapped blocks **99 -> 98**. Views and bundle
  regenerated. Journal `EV-000050`. `check_all`: **25 passed, 0 failed**.
- **Warning-cleanliness correction.** The pinned build emits a pre-existing
  style warning (`linter.style.haveILetI`) on the load-bearing `haveI`
  instances inside `B-R003`'s `finiteSSet_iff` (from Session 42). It is a false
  positive (the instances are consumed by later synthesis), so it is suppressed
  at file scope in `Pilot.lean` with a comment. Cosmetic: no declaration facet
  changes, so no evidence stales. Earlier "0 warnings" claims had missed it.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals.
`IsClosureSystemOn` packages the *ordinary* (one-sorted) closure system — the
paper's `B-D010` applied to the set of sorts — because `supp_S(A) ⊆ S`; the
paper's many-sorted `ClSy(A)` is not separately formalized here.

**Prioritized next steps.**

1. `B-D020`/`B-D021` (subalgebras and the `Sg` generating operator) and
   `B-R010` (uniformity of `Sg`); connect to the existing `IsClosureOperator`/
   `IsAlgebraic` predicates from `B-P005`.
2. `B-R012` (the quotient by `∇` is subfinal) and the congruence-lattice clauses
   of `B-D024` (`∇`/`Δ`, `Cgr(A)` an algebraic closure system).
3. The many-sorted closure-system vocabulary `B-D010`-`B-D013`
   (`ClSy`/`ClOp`, algebraic, uniform); `B-P001` (`propssupport`); `B-P006`
   (`CABA`, likely scope reduction); batch cosmetic docs; calibration
   (author-gated).

---

## Session 46 -- 2026-09-16 -- frontier extension: B-D020, B-D021, B-R010

**Goal.** Formalize the subalgebra cluster: closed-under-operations subsets, the
generating operator `Sg`, and the uniformity remark.

**What was established (closed).**

- **`B-D020` formalized**: `Mslang.IsSubalgebra` — a componentwise subset closed
  under every formal operation.
- **`B-D021` formalized**: `Mslang.MemSg` (inductive generation of the least
  subalgebra containing `X`), `Mslang.Sg` (`Sg_A(X)`), `Mslang.IsGenerating`
  (`Sg_A(X) = A`), and the order-theoretic facts `subset_Sg`,
  `Sg_isSubalgebra`, `Sg_least`, `Sg_monotone`, `Sg_idem`, and
  `Sg_isClosureOperator` (reusing `B-P005`'s `IsClosureOperator`).
- **`B-R010` formalized**: `Mslang.SuppClosure` (the sort-level arity closure),
  `Mslang.suppSub_Sg` (`supp(Sg_A(X)) = SuppClosure(supp X)`, so it depends only
  on `Sig` and `supp X`), and `Mslang.suppSub_Sg_uniform` (the remark).
- Mapped in `lean/declarations.json`; facets regenerated (**33 mapped blocks**).
- Evidence **`E-000076`** (B-D020), **`E-000077`** (B-D021), **`E-000078`**
  (B-R010), all verification `build_ok`; **`E-000079`** (B-R010 correspondence,
  `equivalent`; two-stage blind; transcript
  `blocks/audits/B-R010-correspondence.md`). Definitions carry verification
  only; `B-R010` has no informal proof, so no review layer.
- `reports/frontier.md`: unmapped blocks **98 -> 95**. Views and bundle
  regenerated. Journal `EV-000051`. `check_all`: **25 passed, 0 failed**.
- **Extractor fix.** `lean_facets`'s `DECL_RE` did not match `inductive`
  declarations, so `MemSg`/`SuppClosure` were invisible to the facet extractor.
  Added `inductive` to `DECL_RE` and a regression check to `lean_facets_test`
  (constructors are part of the statement, no proof facet).

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals.
`Sg_A` is encoded by the inductive predicate `MemSg` (definitionally the least
subalgebra containing `X`). The "algebraic" part of the paper's claim (that
`Sg_A` is an *algebraic* closure operator) is not yet formalized; only the
closure-operator laws are.

**Prioritized next steps.**

1. `B-R012` (the quotient by `∇` is subfinal) and the congruence-lattice clauses
   of `B-D024` (`∇`/`Δ`, `Cgr(A)` an algebraic closure system).
2. `B-D022` (product of `Σ`-algebras, including `pr^i` and `<f^i>`) — the
   product `Mslang.iAlg` already exists (mapped under `B-R009`); formalizing the
   block properly would let it be re-mapped.
3. The many-sorted closure-system vocabulary `B-D010`-`B-D013`
   (`ClSy`/`ClOp`, algebraic, uniform); `B-P001` (`propssupport`); `B-P006`
   (`CABA`, likely scope reduction); batch cosmetic docs; calibration
   (author-gated).

---

## Session 47 -- 2026-09-16 -- frontier extension: B-D022 (products)

**Goal.** Formalize `B-D022`, the product of a family of `Σ`-algebras, and
correct the earlier mis-mapping of `Mslang.iAlg` (it had been attached to
`B-R009`, whose proof introduced it).

**What was established (closed).**

- **`B-D022` formalized**: `Mslang.iAlg` (the product),
  `Mslang.iProjAlg` (the canonical projections `pr^i`),
  `Mslang.isAlgHom_iProjAlg` (they are homomorphisms), `Mslang.iPairAlg`
  (`<f^i>`), `Mslang.isAlgHom_iPairAlg` (the pairing of homomorphisms is a
  homomorphism), `Mslang.iProjAlg_iPairAlg` (`pr^i ∘ <f^i> = f^i`) and
  `Mslang.iPairAlg_unique` (uniqueness).
- **Re-mapping.** `Mslang.iAlg` moved from `B-R009` to `B-D022` (its true
  contract). This changed `B-R009`'s definition closure (now includes `B-D022`),
  staling its verification/correspondence, **re-issued** as `E-000081`
  (supersedes `E-000074`) and `E-000082` (supersedes `E-000075`; verdict
  unchanged). `B-R009` passes again.
- Evidence **`E-000080`** (B-D022 verification, `build_ok`). `iAlg` is
  noncomputable; `isAlgHom_iProjAlg` uses no axioms, the `funext`-based
  statements use `Quot.sound` (permitted).
- Mapped in `lean/declarations.json`; facets regenerated (**34 mapped blocks**).
- `reports/frontier.md`: unmapped blocks **95 -> 94**. Views and bundle
  regenerated. Journal `EV-000052`. `check_all`: **25 passed, 0 failed**.

**Honest caveat.** Definitions only (project convention: verification layer
only, no correspondence audit). The projection/pairing are the `Σ`-algebra
counterparts of the sorted-set-level `B-D003` `iProd`/`iProj`/`iPair`; the
pairing's uniqueness is stated for all sorted maps (a fortiori homomorphisms).

**Prioritized next steps.**

1. `B-R012` (the quotient by `∇` is subfinal) and the congruence-lattice clauses
   of `B-D024` (`∇`/`Δ`, `Cgr(A)` an algebraic closure system).
2. `B-D023` (subfinal `Σ`-algebra) with `B-P008` (`A` subfinal iff `A` is
   subfinal) and `B-R011` (at most one homomorphism into a subfinal algebra);
   these connect to the already-formalized `B-D004` (`Subfinal`/`finalSorted`).
3. The many-sorted closure-system vocabulary `B-D010`-`B-D013`
   (`ClSy`/`ClOp`, algebraic, uniform); `B-P001` (`propssupport`); `B-P006`
   (`CABA`, likely scope reduction); batch cosmetic docs; calibration
   (author-gated).

---

## Session 48 -- 2026-09-16 -- architecture revision (documentation only)

**Goal.** Incorporate the engineering insights from Sessions 40-47 into the
normative `Architecture.md` (author-directed), then record the revision.

**What was established (closed).** `Architecture.md` **Revision 3 -
frontier-hardened** (249 insertions / 27 deletions), covering:

- **Statement/closure separation** (`§6`, `§7.2`, `§12.3`, `§13.1`): a new
  `definition_closure` facet, keyed on declaration identity, decoupled from
  `formal_statement`. Definition *content* still propagates; block-ownership
  bookkeeping (a declaration remap) no longer moves dependents' hashes.
- **Declaration ownership** (`§6`) and the **C5 remap sub-case** (`§13.2`).
- **The mechanical Lean gate** (`§15.6`, new): build with full diagnostics and
  a warning allowlist, `#print axioms` on every mapped declaration, `sorry`
  check, recorded in a derived `lean_audit` artifact. Corrected `§15.2`/`§15.5`,
  which had claimed these were "part of the build" while the gate never invoked
  the compiler (the Session 45 "0 warnings" drift).
- **Re-issue vocabulary** (`§7.2`, `§8.1`): `supersedes`/`reissue_reason`; the
  status model now separates *awaiting re-audit* from *superseded*.
- **Layer assignment by block kind** (`§7.2`) — previously folklore.
- **Extractor fail-closed policy** (`§12.1`); **post-hoc declaration addition**
  as hygiene mode 4 (`§13.3`); a **single session orchestrator** for derived
  views (`§16.1`); auditor model recorded for a same-model metric (`§11.4`,
  `§24.4`); Open Questions 11-12; change log Revision 3 (`§25`).

**Honest caveat.** This is a *specification* edit: no block facet, evidence
record, or derived-view content changed (`Architecture.md` is not a hashed
facet). It documents rules the project has been following by convention; the
tooling in `scripts/` does not yet implement the `§15.6` gate,
`definition_closure` split, or re-issue fields — those are now specified
targets, not built features (see next steps).

**Prioritized next steps.**

1. **Implement the Revision 3 spec gaps** (coordinator-level, mechanical):
   `scripts/lean_audit.py` + a `check_all` entry (`§15.6`); split
   `definition_closure` out of `formal_statement` in `lean_facets.py`
   (`§6`/`§12.3`); add `supersedes`/`reissue_reason` to the evidence schema
   (`§7.2`).
2. `B-R012` (the quotient by `∇` is subfinal) and the congruence-lattice clauses
   of `B-D024` (`∇`/`Δ`, `Cgr(A)` an algebraic closure system).
3. `B-D023` (subfinal `Σ`-algebra) with `B-P008` (`A` subfinal iff `A` is
   subfinal) and `B-R011` (at most one homomorphism into a subfinal algebra).
4. The many-sorted closure-system vocabulary `B-D010`-`B-D013`; `B-P001`
   (`propssupport`); `B-P006` (`CABA`).

---

## Session 49 -- 2026-09-16 -- Lean mechanical gate implemented

**Goal.** Implement the `§15.6` gate (the first Revision 3 gap).

**What was established (closed).**

- **`scripts/lean_audit.py`** — runs `lake build` capturing the full diagnostic
  stream, audits `#print axioms` over all **100** mapped declarations in one
  Lean process, checks the permitted set, scans for `sorry`, and writes a
  deterministic `blocks/lean_audit.json`; `--check` detects drift and fails when
  the audit is not `ok`. `scripts/lean_audit_test.py` covers the parsing (8
  checks).
- Wired into `check_all` (**25 -> 27** checks). Current audit: 100
  declarations, 0 warnings, 0 unpermitted axioms, 0 sorry, `ok=true`.
- `Architecture.md` `§15.6` now names the implementation; the safe-restart
  checklist records the ~2.5 min cost of the gate.

**Honest caveat.** The gate measures build/axioms/sorry; the spec's stronger
"refuse to issue a `build_ok` record that does not match the audit" linkage is
still manual (the evidence writer does not consult `blocks/lean_audit.json`
yet).

---

## Session 50 -- 2026-09-16 -- supersession vocabulary implemented

**Goal.** Implement the `§7.2`/`§8.1` supersession vocabulary (the second
Revision 3 gap), so the status views separate mechanical re-issues from real
outstanding work.

**What was established (closed).**

- Evidence schema and `evidence.py` gained optional `supersedes` +
  `reissue_reason`; `validate_records` self-test covers them.
- `status.py` and the staleness view now classify each stale record as
  **superseded** (its block/layer still has current evidence) or **awaiting**
  (no current evidence in that layer).
- **Design correction made during implementation:** the classification is
  *layer-based*, not field-based. A field-based rule mislabelled the 23 legacy
  re-issues (made before the fields existed) as awaiting; layer-based
  classification reads them correctly as superseded. The fields remain
  provenance (successor id + reason). `Architecture.md` `§7.2`/`§8.1` reworded
  to match.
- `reports/staleness.md` now reads **23 of 82 stale (23 superseded, 0
  awaiting)**, replacing a false backlog. `check_all`: **27 passed, 0 failed**.

**Honest caveat.** The 23 superseded records predate the fields, so the report
cannot name their successors (only `supersedes`-carrying re-issues can). Future
re-issues will.

**Prioritized next steps.**

1. **`definition_closure` facet split** (`§6`/`§12.3`) — the last Revision 3
   gap, and a "big bang": splitting the closure out of `formal_statement`
   changes the statement hash of every block with a closure, staling the
   current correspondence/review surface. Now that the supersession vocabulary
   exists, do it as a dedicated migration and re-issue the staled records with
   `reissue_reason: facet-split` (content-preserving; keep the transcripts).
2. `B-R012` (the quotient by `∇` is subfinal) and the congruence-lattice clauses
   of `B-D024`.
3. `B-D023`/`B-P008`/`B-R011` (subfinal cluster); `B-D010`-`B-D013`;
   `B-P001`; `B-P006`.

---

## Session 51 -- 2026-09-16 -- definition_closure facet split (migration)

**Goal.** Implement the last Revision 3 gap: split `definition_closure` out of
`formal_statement` (`§6`/`§12.3`) so statement hashes are no longer coupled to
graph bookkeeping.

**What was established (closed).**

- `scripts/lean_facets.py`: `formal_statement` is now the declaration's own
  signature only; a third facet `definition_closure = {decls, hash}` holds the
  transitive **declaration-level** closure (whole-identifier `formal_uses`
  among mapped declarations), keyed on declaration identity. The block-level
  `formal_graph` is derived from those declaration edges for the discrepancy
  and impact views.
- `scripts/closure.py`: correspondence self-facets gained `definition_closure`;
  `_merge_formal` merges it from `blocks/formal.json`.
- `scripts/impact.py`: a definition change now propagates to dependents'
  `definition_closure` (was `formal_statement`).
- **Migration.** The split changed every correspondence `formal_statement`
  hash, staling **16** current records (`E-000041`..`E-000082`). Each was
  re-issued content-preservingly as **`E-000083`..`E-000098`** with
  `reissue_reason: facet-split` and `supersedes` set, keeping the original
  transcripts and verdicts.
- Regression test: moving a declaration between owning blocks changes no
  dependent's `formal_statement` or `definition_closure` hash.
- Result: **all layers pass, 0 awaiting** (39 superseded stale records).
  `check_all`: **27 passed, 0 failed**. Journal `EV-000056`.

**Honest caveat.** The declaration-level closure is computed over *mapped*
declarations only (an unmapped helper can still break a transitive chain);
this matches the previous over-approximation and is noted in the spec's honest
limitations. The 39 superseded records predate the `supersedes` field, so the
report cannot name their successors.

**Prioritized next steps.**

1. Resume the frontier: `B-R012` (the quotient by `∇` is subfinal), the
   congruence-lattice clauses of `B-D024`, then `B-D023`/`B-P008`/`B-R011`.
2. The `B-D010`-`B-D013` many-sorted closure-system vocabulary; `B-P001`
   (`propssupport`); `B-P006` (`CABA`).
3. Optional: link `build_ok` evidence issuance to `blocks/lean_audit.json`
   (the `§15.6` "refuse to issue" clause is still manual).

---

## Session 52 -- 2026-09-16 -- frontier extension: B-D010..B-D013

**Goal.** Resume formalization with the many-sorted closure-system vocabulary.

**What was established (closed).**

- **`B-D010`**: `Mslang.Sub_iInter`, `Mslang.IsClosureSystem` (S-closure system
  on `A`). The operator half is the existing `IsClosureOperator` (`B-P005`).
- **`B-D011`**: `Mslang.IsCompact`, `Mslang.IsAlgebraicLattice` (over Mathlib's
  `CompleteLattice`).
- **`B-D012`**: `Mslang.Sub_iUnion`, `Mslang.IsAlgebraicClosureSystem`. The
  algebraic-operator half is the existing `IsAlgebraic` (`B-P005`).
- **`B-D013`**: `Mslang.IsUniform`, `Mslang.IsUniformAlgebraicClosureOperator`.
- Mapped in `lean/declarations.json`; facets regenerated (**39 mapped blocks**).
- Evidence **`E-000099`..`E-000102`**, verification `build_ok`. Definitions
  carry the verification layer only.
- `reports/frontier.md`: unmapped blocks **94 -> 90**. `check_all`: **27 passed,
  0 failed**. Journal `EV-000057`.

**Honest caveat.** Definitions only. `IsClosureOperator`/`IsAlgebraic`
(`B-P005`) already covered the operator halves of `B-D010`/`B-D012`, so this
session adds only the system-level predicates and the lattice vocabulary.

**Prioritized next steps.**

1. `B-R012` (the quotient by `∇` is subfinal) — needs algebra-local vocabulary:
   the final algebra `1`, algebra isomorphism, and the subalgebra-as-algebra
   construction; then the `B-D023`/`B-P008`/`B-R011` subfinal cluster.
2. `B-P001` (`propssupport`) — clauses (1) and (2) are reachable now
   (`SortedMap`, `supp`, direct/inverse image); clause (3) needs coproduct /
   intersection / difference encodings and may be partial.
3. `B-P006` (`CABA`); batch cosmetic docs; calibration (author-gated).

---

## Session 53 -- 2026-09-16 -- frontier extension: B-D023 (subfinal algebra)

**Goal.** Introduce the algebra-local vocabulary needed by the subfinal cluster
(`B-D023`, `B-P008`, `B-R011`, `B-R012`).

**What was established (closed).**

- **`B-D023`**: `Mslang.finalAlg` (the final `Σ`-algebra `1`),
  `Mslang.IsAlgIso` (a sortwise-bijective homomorphism), `Mslang.subAlg` (a
  subalgebra as a standalone `Σ`-algebra over its subtype carrier), and
  `Mslang.SubfinalAlg` (isomorphic to a subalgebra of `1`).
- Mapped in `lean/declarations.json`; facets regenerated (**40 mapped blocks**).
- Evidence **`E-000103`**, verification `build_ok`. Definition carries the
  verification layer only.
- `reports/frontier.md`: unmapped blocks **90 -> 89**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000058`.

**Honest caveat.** Definitions only; the hard content is `B-P008`'s iff, which
needs the image subalgebra `ω^A[X]` and the unique homomorphism `ω^A`. That is
the next target. Note the frontier-ready analysis from the (over-approximating)
dependency graph is unreliable for far blocks (e.g. `B-P017` is *not* actually
ready): trust the STATE priority list, not the reverse-dependency heuristic.

**Prioritized next steps.**

1. `B-P008`: `SubfinalAlg Sig X ↔ Subfinal X.1` (algebra subfinal iff carrier
   subfinal) — the natural sequel; then `B-R011` (at most one homomorphism into
   a subfinal algebra) and `B-R012` (`A/∇^A` is subfinal).
2. `B-P001` (`propssupport`) clauses (1)-(2) via `SortedMap`/`supp`/images;
   clause (3) needs coproduct/intersection/difference encodings.
3. `B-P006` (`CABA`); batch cosmetic docs; calibration (author-gated).

---

## Session 54 -- 2026-09-16 -- frontier extension: B-P008

**Goal.** Prove the substantive half of the subfinal cluster: `A` subfinal as a
`Σ`-algebra iff its carrier is subfinal.

**What was established (closed).**

- **`B-P008`** as `Mslang.subfinalAlg_iff`:
  `SubfinalAlg Sig X ↔ Subfinal X.1`. Forward: a bijective homomorphism onto a
  subalgebra of the one-element algebra forces every component to be a
  subsingleton. Backward: exhibit the image subalgebra
  `Y s = {q : PUnit | Nonempty (X.1 s)}` as a subalgebra of `1` (using `X`'s
  operations to supply witnesses) and the sortwise bijection
  `a ↦ ⟨PUnit.unit, ⟨a⟩⟩`.
- Mapped in `lean/declarations.json`; facets regenerated (**41 mapped blocks**).
- Evidence **`E-000104`** (verification, `build_ok`; axiom `Classical.choice`)
  and **`E-000105`** (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-P008-correspondence.md`).
- `reports/frontier.md`: unmapped blocks **89 -> 88**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000059`.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals. No
review layer (the informal proof is not separately audited, consistent with
`B-P002`/`B-R003`). The proof uses `Classical.choice` to build the witnesses;
`Subsingleton`/empty components are handled.

**Prioritized next steps.**

1. `B-R012` (the quotient by `∇` is subfinal) — now reachable with `quotAlg`
  (`B-D025`), `nabla`, and `SubfinalAlg`; then `B-R011` (at most one
  homomorphism into a subfinal algebra).
2. `B-P001` (`propssupport`) clauses (1)-(2).
3. `B-P006` (`CABA`); batch cosmetic docs; calibration (author-gated).

---

## Session 55 -- 2026-09-16 -- frontier extension: B-R012

**Goal.** `A/∇^A` is subfinal — the first application of the subfinal cluster.

**What was established (closed).**

- **`B-R012`** as `Mslang.nabla_isCongruence` (the greatest sorted equivalence
  is a congruence for any structure) and `Mslang.quot_nabla_subfinal`
  (`SubfinalAlg Sig (quotAlg Sig F (nabla A) ...)`), proved from `B-P008` plus
  double quotient induction.
- Mapped in `lean/declarations.json`; facets regenerated (**42 mapped blocks**).
- Evidence **`E-000106`** (verification, `build_ok`; `propext`, `Classical.choice`,
  `Quot.sound`) and **`E-000107`** (correspondence, `equivalent`; two-stage
  blind; transcript `blocks/audits/B-R012-correspondence.md`).
- `reports/frontier.md`: unmapped blocks **88 -> 87**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000060`.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals. The
remark's further discussion (the single-sorted case, `∅^S`) is commentary and
not formalized; the comparator agreed it is not part of the assertion.

**Prioritized next steps.**

1. `B-R011` (if `A` is subfinal, every `B` has at most one homomorphism
  `B → A`) — the remaining member of the subfinal cluster; needs an
  equation/homomorphism-extensionality argument.
2. `B-P001` (`propssupport`) clauses (1)-(2) via `SortedMap`/`supp`/images.
3. `B-P006` (`CABA`); batch cosmetic docs; calibration (author-gated).

---

## Session 57 -- 2026-09-16 -- frontier extension: B-R011 (subfinal cluster closed)

**Goal.** Finish the subfinal cluster: if `A` is subfinal, every `Σ`-algebra has
at most one homomorphism into `A`.

**What was established (closed).**

- **`B-R011`** as `Mslang.hom_unique_of_subfinalAlg`: from `SubfinalAlg Sig
  ⟨A, FA⟩`, any two homomorphisms `B → A` are equal. Proved from `B-P008`
  (componentwise subsingleton), pointwise.
- Mapped in `lean/declarations.json`; facets regenerated (**43 mapped blocks**).
- Evidence **`E-000108`** (verification, `build_ok`) and **`E-000109`**
  (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-R011-correspondence.md`).
- `reports/frontier.md`: unmapped blocks **87 -> 86**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000062`.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals. The
homomorphism hypotheses are present to match the contract but unused in the
proof (subfinality alone forces equality of any two sorted maps). The subfinal
cluster (`B-D023`, `B-P008`, `B-R011`, `B-R012`) is now complete.

**Prioritized next steps.**

1. `B-P001` (`propssupport`) clauses (1)-(2) via `SortedMap`/`supp`/images;
   clause (3) needs coproduct/intersection/difference encodings.
2. `B-P006` (`CABA`, likely scope reduction).
3. The `B-D026`+ free-algebra layer (algebra of rows, `T_Σ`, adjunction) is the
   next large frontier; batch cosmetic docs; calibration (author-gated).

---

## Session 58 -- 2026-09-16 -- frontier extension: B-D026 (algebra of `Σ`-rows)

**Goal.** Begin the free-algebra layer with the algebra of `Σ`-rows `W_Σ(X)`.

**What was established (closed).**

- **`B-D026`** as `Mslang.SigElem` (`∐Σ`), `Mslang.XElem` (`∐X`),
  `Mslang.RowAlpha` (`∐Σ ⨿ ∐X`), `Mslang.WSet` (the constant word family
  `W_Σ(X)`), and `Mslang.WAlg` (the structural operations: `σ` prepended to the
  concatenation of its arguments).
- Mapped in `lean/declarations.json`; facets regenerated (**44 mapped blocks**).
- Evidence **`E-000110`**, verification `build_ok`. Definition carries the
  verification layer only.
- `reports/frontier.md`: unmapped blocks **86 -> 85**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000063`.

**Honest caveat.** Definitions only. `WAlg`'s operations use `List.ofFn` +
`List.flatten` (the Mathlib `List.join` name is absent in the pinned version).
This unlocks the free-algebra layer: `T_Σ(X)` (`B-D027`) as the subalgebra of
`W_Σ(X)` generated by the inserted variables, then `B-P010` (term
characterization), `B-P011` (universal property), `B-C003` (adjunction).

**Prioritized next steps.**

1. `B-D027`: `T_Σ(X) = Sg_{W_Σ(X)}({(x) | x ∈ X})` via the existing `Sg`
  (`B-D021`); define the insertion `η^X` and the generator set.
2. `B-P010`/`B-P011`: term characterization and the universal property
  (recursion on the generated subalgebra).
3. `B-C003`: `T_Σ ⊣ G_Σ` (needs a functor-level encoding — likely a scope
  decision). Batch cosmetic docs; calibration (author-gated).

---

## Session 59 -- 2026-09-16 -- frontier extension: B-D027 (free algebra `T_Σ`)

**Goal.** Define the free `Σ`-algebra `T_Σ(X)` and the insertion `η^X`.

**What was established (closed).**

- **`B-D027`** as `Mslang.genSet` (the generators `(x)` at sort `s`),
  `Mslang.TAlg` (= `subAlg` over `Sg_{W_Σ(X)}(genSet)`), `Mslang.TSet` (its
  carrier), and `Mslang.etaX` (the insertion `x ↦ (x)`). Reuses `Sg` (`B-D021`)
  and `subAlg` (`B-D023`).
- Mapped in `lean/declarations.json`; facets regenerated (**45 mapped blocks**).
- Evidence **`E-000111`**, verification `build_ok`. Definition carries the
  verification layer only.
- `reports/frontier.md`: unmapped blocks **85 -> 84**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000064`.

**Honest caveat.** Definitions only. Two encoding notes hit while building:
`TAlg` must pass the *generated* subalgebra `Sg …` to `subAlg` (not the
generator set), and `etaX` builds membership via `subset_Sg` to avoid an
unresolved carrier metavariable. The paper's `T_Σ(X)_s` elements ("terms") are
now the subtype `{P // P ∈ Sg … s}`; the next session characterizes them.

**Prioritized next steps.**

1. `B-P010`: term characterization (`x`, `σ`, or `σ(P₀,…)`), i.e. the
  generated elements are exactly those rows; likely an induction over `MemSg`.
2. `B-P011`: the universal property `f^♯ ∘ η^X = f`, by recursion over the
  generated subalgebra.
3. `B-C003`: `T_Σ ⊣ G_Σ` (functor-level encoding — a scope decision).
  Batch cosmetic docs; calibration (author-gated).

---

## Session 60 -- 2026-09-16 -- frontier extension: B-R001 (delta as copower)

**Goal.** `δ^{t,X} ≅ ∐_{x∈X} δ^t`, and with it the sorted-set coproduct vocabulary.

**What was established (closed).**

- **`B-R001`** as `Mslang.delta_iso_coprod`, with supporting
  `Mslang.SortedIso` (sortwise-bijective sorted map), `Mslang.iCoprod`
  (coproduct of sorted sets), `Mslang.deltaT` (`δ^{t,X}`),
  `Mslang.sigmaPUnitEquiv`, and `Mslang.deltaEquiv`. The proof is the evident
  componentwise equivalence (`x ↦ ⟨x, ⋆⟩` at `t`, empty bijection elsewhere).
- Mapped in `lean/declarations.json`; facets regenerated (**46 mapped blocks**).
- Evidence **`E-000112`** (verification, `build_ok`) and **`E-000113`**
  (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-R001-correspondence.md`).
- `reports/frontier.md`: unmapped blocks **84 -> 83**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000065`.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals. The
`δ`/`δ^{t,X}` definitions use an `if s = t` with `classical`, so the equivalence
is built by case analysis on `s = t`; a first build appeared to hang but was a
cold rebuild, not a tactic loop. `SortedIso` and `iCoprod` are reused later.

**Prioritized next steps.**

1. `B-P010` (term characterization): needs "unique parsing" of the three term
  forms (mutual exclusivity + uniqueness) — a genuine multi-session proof.
2. `B-P011`: the universal property `f^♯ ∘ η^X = f`, by recursion on the
  generated subalgebra; depends on `B-P010`'s structure.
3. `B-C003`: `T_Σ ⊣ G_Σ` (functor-level encoding — a scope decision).
  Batch cosmetic docs; calibration (author-gated).

---

## Session 61 -- 2026-09-16 -- refactor: split `Pilot.lean` into modules

**Goal.** Break the single ~1200-line `lean/Mslang/Pilot.lean` into
dependency-ordered modules so a change recompiles only the edited module and its
importers (author-raised: module splitting for rebuild speed, parallel builds,
editor responsiveness, and an explicit dependency graph).

**What was established (closed).**

- Split by **declaration boundary** (not line range) into:
  `Mslang/Prelim.lean` (sorted-set layer: supports, deltas, saturation,
  quotients of sorted sets, finiteness, free monoid, images, products,
  `SortedIso`/`iCoprod`/`B-R001`), `Mslang/Algebra.lean` (signatures, algebras,
  homomorphisms, products of algebras, `Sg`, closure-system vocabulary),
  `Mslang/Congruence.lean` (`B-D024`/`B-D025`/`B-P009`),
  `Mslang/Subfinal.lean` (`B-D023`/`B-P008`/`B-R011`/`B-R012`), and
  `Mslang/Free.lean` (`B-D026`/`B-D027`). `Mslang.lean` is the umbrella
  (`import Mslang.Free` + `Mslang.Sanity`) holding the axiom audit.
- **No evidence staled.** Facets are hashed from declaration text, so the move
  left every `formal_statement`/`formal_proof`/`definition_closure` hash
  unchanged; only the per-block `file` field in `blocks/formal.json` changed.
  Verified: `lean_facets --check` flagged only that `file` field, and a full
  `status` run reports **0 non-pass layers**.
- `lean/declarations.json` `file` fields repointed (46 blocks: 24 Prelim, 13
  Algebra, 4 Subfinal, 3 Congruence, 2 Free). `Mslang/Sanity.lean` now imports
  `Mslang.Prelim`.
- The `haveI` style-linter suppression moved to the module that needs it
  (`Subfinal.lean` for `subfinalAlg_iff`; `Prelim.lean` for `finiteSSet_iff`).
- Build: **0 warnings**, 8713 jobs. `check_all`: **27 passed, 0 failed**.
  Frontier unchanged (**83 unmapped**). `Architecture.md` §10.2 gained a
  "Module structure" paragraph; Revision 3 change log gained a bullet.

**Honest caveat.** `Pilot` remains in a few *historical* STATE entries and in
`scripts/lean_audit_test.py` synthetic fixture strings; those describe past
sessions or synthetic data and were intentionally left. The refactor changes no
mathematics and no evidence.

**Prioritized next steps.**

1. `B-P010` (term characterization; unique-parsing proof), then `B-P011`.
2. `B-C003`: `T_Σ ⊣ G_Σ` (functor-level — a scope decision).
3. Batch cosmetic docs; calibration (author-gated).

---

## Session 62 -- 2026-09-16 -- frontier extension: B-L001

**Goal.** Prove the uniqueness half of the free-algebra universal property:
homomorphisms out of `T_Σ(X)` are determined by their values on generators.

**What was established (closed).**

- **`B-L001`** as `Mslang.TAlg_hom_ext`: for homomorphisms
  `f, g : T_Σ(X) → A`, `f ∘ η^X = g ∘ η^X ⟹ f = g`, by induction over `MemSg`
  (the generator case is the hypothesis; the operation case uses the two
  homomorphism equations plus the induction hypothesis).
- Mapped in `lean/declarations.json`; facets regenerated (**47 mapped blocks**).
- Evidence **`E-000114`** (verification, `build_ok`; axiom `Quot.sound`) and
  **`E-000115`** (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-L001-correspondence.md`).
- `reports/frontier.md`: unmapped blocks **83 -> 82**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000068`.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals.
This is the *uniqueness* half of `B-P011`; the *existence* half (the recursive
homomorphism `f^♯`) still needs `B-P010`'s term characterization, whose
"unique parsing" (mutual exclusivity + uniqueness of the three term forms) is
the genuinely hard remaining step. Two proof-engineering notes: `rw` cannot
unfold the `etaX` def (use `simp only [etaX]`), and the subtype membership
proofs in `MemSg`/`Sg` needed `convert` to bridge by proof irrelevance.

**Prioritized next steps.**

1. `B-P010` (term characterization; the unique-parsing proof) — the gate to
   `B-P011` existence and the projective/free results (`B-P012`, `B-P013`).
2. `B-P012`/`B-P013`: `T_Σ(X)` projective; every algebra is a quotient of a
   free algebra (both need `B-P010`/`B-P011`).
3. `B-C003`: `T_Σ ⊣ G_Σ` (functor-level — a scope decision).

---

## Session 63 -- 2026-09-16 -- frontier: B-D028 (subdirect products)

**Goal.** Open the formation-theoretic layer with the definition of subdirect
product / subdirect embedding.

**What was established (closed).**

- **`B-D028`** in a new module `Mslang/Formation.lean` (importing `Subfinal`):
  `Mslang.IsMonoAlg`, `Mslang.IsEpiAlg` (injective/surjective homomorphisms),
  `Mslang.IsSubdirectEmbedding` (injective hom whose composites with the
  canonical projections are surjective), `Mslang.IsSubdirectProduct`, and
  `Mslang.IsomorphicSubdirectEmbeddings`.
- Encoding note: the subdirect product is *existence of a subdirect embedding*
  into `∏ A^i` (the paper's second formulation), since the type encoding has no
  literal "`A` is a subalgebra of the product".
- Mapped in `lean/declarations.json`; facets regenerated (**48 mapped blocks**).
- Evidence **`E-000116`**, verification `build_ok`. Definition carries the
  verification layer only.
- `reports/frontier.md`: unmapped blocks **82 -> 81**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000069`. `Architecture.md` §10.2 module table
  and the safe-restart layout updated.

**Honest caveat.** Definitions only; no correspondence audit (project
convention). The encoding of "subalgebra of the product" as an embedding is a
representation choice governed by the central encoding audit, not a per-block
audit.

**Prioritized next steps.**

1. `B-P010` (term characterization; the unique-parsing proof) — still the gate
   to `B-P011` existence and the projective/free results (`B-P012`, `B-P013`).
2. The formation-theoretic definitions following `B-D028` (`B-D029` filters,
   `B-D030` formations).
3. `B-C003`: `T_Σ ⊣ G_Σ` (functor-level — a scope decision).

---

## Session 64 -- 2026-09-16 -- frontier: B-D029, B-D030

**Goal.** Continue the formation layer: filters of a lattice, then formations of
congruences.

**What was established (closed).**

- **`B-D029`** as `Mslang.IsLatticeFilter` (nonempty up-set closed under meets)
  and `Mslang.latticeFilters` (`Filt(L)`).
- **`B-D030`** as `Mslang.IsCongruenceFormation`: a dependent choice function
  `F : (A : SSet S) → Set (SortedEqv (T_Σ(A)))` with each `F A` a filter of
  `Cgr(T_Σ(A))` (nonempty, consisting of congruences, meet-closed, up-closed
  under refinement) and closed under `Ker(pr^Θ ∘ f) ∈ F(A)` along
  `Θ`-epimorphisms.
- Both in `Mslang/Formation.lean` (now imports `Free` for `T_Σ`). Mapped in
  `lean/declarations.json`; facets regenerated (**50 mapped blocks**).
- Evidence **`E-000117`** (B-D029) and **`E-000118`** (B-D030), verification
  `build_ok`. Definitions carry the verification layer only.
- `reports/frontier.md`: unmapped blocks **81 -> 79**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000070`.

**Honest caveat.** Definitions only. The "filter of `Cgr(T_Σ(A))`" condition is
*inlined* (the encoding uses predicates, not a bundled congruence lattice), and
the congruence-ness of `Θ` is a named hypothesis rather than derived from
filter membership. `‹_›`/`assumption` does not work in a `def`'s type, so the
congruence hypothesis is named `hΘ` explicitly.

**Prioritized next steps.**

1. `B-D031`+ (`H` and `P_fsd` operators, formation of algebras) — reaches the
   Eilenberg-theorem statement of the section.
2. `B-P010` (term characterization; the unique-parsing proof) — still the gate
   to `B-P011` existence and `B-P012`/`B-P013`.
3. `B-C003`: `T_Σ ⊣ G_Σ` (functor-level — a scope decision).

---

## Session 65 -- 2026-09-16 -- frontier: B-D031, B-D032

**Goal.** The `H`/`P_fsd` operators and the definition of a formation of
`Σ`-algebras.

**What was established (closed).**

- **`B-D031`** as `Mslang.HOperator` (homomorphic images of members of `F`) and
  `Mslang.PFsdOperator` (finite subdirect products of members of `F`).
- **`B-D032`** as `Mslang.IsAlgebraFormation` (`H(F) ⊆ F` and `P_fsd(F) ⊆ F`)
  and `Mslang.algebraFormations` (`Form_Alg(Σ)`).
- Mapped in `lean/declarations.json`; facets regenerated (**54 mapped blocks**).
- Evidence **`E-000119`** (B-D031) and **`E-000120`** (B-D032), verification
  `build_ok`. Definitions carry the verification layer only.
- `reports/frontier.md`: unmapped blocks **79 -> 77**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000071`.

**Honest caveat.** Definitions only. Two encoding notes: (a) the finite index
set in `P_fsd` is an arbitrary *finite type* `ι` (`Fintype ι`) rather than
`n : ℕ`/`Fin n`, to keep the index universe at `u` (an inferred `Fin n` also
caused a metavariable mismatch); (b) `B-D032`'s nonempty and abstractness
clauses are commented out *in the manuscript*, so the formal definition has
only the `H`/`P_fsd` closure clauses.

**Prioritized next steps.**

1. `B-P015`: `F_𝔉` (the algebras isomorphic to a quotient `T_Σ(A)/Φ`) is
   nonempty, abstract, and closed under `H`/`P_fsd` — the first substantive
   proposition of the formation layer (needs isomorphisms, quotients, and the
   free-algebra results).
2. `B-R014`+ and the section's Eilenberg theorem.
3. `B-P010` (term characterization; the unique-parsing proof) — still the gate
   to `B-P011` existence and `B-P012`/`B-P013`.

---

## Session 66 -- 2026-09-16 -- frontier: B-D033 (ShSk-formations)

**Goal.** The Shemetkov–Skiba formation definition.

**What was established (closed).**

- **`B-D033`** as `Mslang.IsShSkFormation` (`F` nonempty, `H(F) ⊆ F`, and
  `A/Φ, A/Ψ ∈ F ⟹ A/(Φ ⊓ Ψ) ∈ F`), plus the auxiliary
  `Mslang.IsCongruence_inf` (the pointwise meet `sortedEqvInf` of two
  congruences is a congruence; **axiom-free**), needed to form the quotient
  `A/(Φ ⊓ Ψ)`.
- Mapped in `lean/declarations.json`; facets regenerated (**56 mapped blocks**).
- Evidence **`E-000121`**, verification `build_ok`. Definition + helper.
- `reports/frontier.md`: unmapped blocks **77 -> 76**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000072`.

**Honest caveat.** `IsCongruence_inf` is attached to `B-D033` as a helper (it is
a general congruence fact, but attaching it to `B-D024` would stale that
block's already-recorded verification; the declaration-ownership rule puts it
with the block that needs it). The intersection in `B-D033` is the pointwise
`sortedEqvInf` of congruences.

**Prioritized next steps.**

1. `B-P016`: a formation of algebras satisfies the `B-D033` intersection
   closure (needs the `p^{Φ,Ψ}` maps and the subdirect embedding into the
   product `A/Φ × A/Ψ`).
2. `B-P017`/`B-C004`: equivalence of the two formation definitions; then
   `B-P018`+ and the section's Eilenberg theorem.
3. `B-P010` (term characterization; the unique-parsing proof).

---

## Session 67 -- 2026-09-16 -- frontier: B-R014

**Goal.** Consequences of the formation axioms: abstractness and non-emptiness.

**What was established (closed).**

- **`B-R014`** as `Mslang.formation_abstract` (`H`-closure implies abstractness:
  a bijective hom is an epimorphism) and `Mslang.formation_nonempty`
  (`P_fsd`-closure implies non-emptiness, witnessed by the empty product).
- Mapped in `lean/declarations.json`; facets regenerated (**58 mapped blocks**).
- Evidence **`E-000122`** (verification; `formation_abstract` axiom-free) and
  **`E-000123`** (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-R014-correspondence.md`).
- `reports/frontier.md`: unmapped blocks **76 -> 75**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000073`.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals. The
abstractness lemma takes the isomorphism in the `A → B` direction (harmless —
isomorphism is symmetric; the comparator agreed). The empty product requires
`PEmpty.{u+1}` as the index (a `Sort u`-level empty type does not fit the
`Type u` index; the same `u+1` convention as `initialSorted`), and the identity
subdirect embedding of the product into itself.

**Prioritized next steps.**

1. `B-P016` (formation of algebras satisfies `B-D033` intersection closure;
   needs the `p^{Φ,Ψ}` maps and the subdirect embedding into `A/Φ × A/Ψ`).
2. `B-P017`/`B-C004`: equivalence of the two formation definitions; then
   `B-P018`+ and the section's Eilenberg theorem.
3. `B-P010` (term characterization; the unique-parsing proof).

---

## Session 68 -- 2026-09-16 -- frontier: B-P016

**Goal.** A formation of `Σ`-algebras satisfies the `B-D033` intersection
closure of congruences.

**What was established (closed).**

- **`B-P016`** as `Mslang.formation_congInf`: for a formation `F`, algebra `A`,
  and congruences `Φ, Ψ` with `A/Φ, A/Ψ ∈ F`, the quotient `A/(Φ ⊓ Ψ) ∈ F`.
- Proof: build the subdirect embedding `⟨p^{Φ⊓Ψ,Φ}, p^{Φ⊓Ψ,Ψ}⟩` of `A/(Φ⊓Ψ)`
  into the finite product `A/Φ × A/Ψ` (`quotLift` over the meet `B-P009`/`B-P007`,
  paired via `iPairAlg` `B-D022` over a lifted 2-element index); prove hom,
  injectivity (the meet refines both factors), and projection-surjectivity; then
  `P_fsd`-closure applies.
- Mapped in `lean/declarations.json`; facets regenerated (**60 mapped blocks**).
- Evidence **`E-000124`** (verification, `build_ok`; `propext`, `Classical.choice`,
  `Quot.sound`) and **`E-000125`** (correspondence, `equivalent`; two-stage
  blind; transcript `blocks/audits/B-P016-correspondence.md`).
- `reports/frontier.md`: unmapped blocks **75 -> 74**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000074`.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals. The
2-element product index must be lifted (`ULift.{u,0} Bool`) because `iAlg`'s
index lives in `Type u` while `Bool` is `Type 0`; `simpa` did not fold
`iPairAlg`/`g`, so the surjectivity witnesses needed explicit `change`.

**Prioritized next steps.**

1. `B-P017`/`B-C004`: equivalence of the two formation definitions (needs
  `B-P016` plus the subdirect-product machinery); then `B-P018`+ and the
  section's Eilenberg theorem.
2. `B-D035`/`B-D036`: elementary translations / translations (heavy dependent
  indexing).
3. `B-P010` (term characterization; the unique-parsing proof).

---

## Session 69 -- 2026-09-16 -- frontier: B-R017

**Goal.** Every subfinal `Σ`-algebra lies in every formation.

**What was established (closed).**

- **`B-R017`** as `Mslang.subfinalAlg_mem_of_formation`: for a formation `F`,
  `SubfinalAlg Sig A → A ∈ F`. Proof: the empty finite product is terminal; a
  subfinal `A` (componentwise subsingleton via `B-P008`) maps into it by the
  unique map, which is injective and homomorphic (vacuous on the empty index)
  with vacuous projection-surjectivity, hence a subdirect embedding; `P_fsd`-
  closure gives `A ∈ F`.
- Mapped in `lean/declarations.json`; facets regenerated (**62 mapped blocks**).
- Evidence **`E-000126`** (verification, `build_ok`) and **`E-000127`**
  (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-R017-correspondence.md`).
- `reports/frontier.md`: unmapped blocks **74 -> 73**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000075`.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals. The
`haveI` style-linter fired on `Subsingleton (A.1 s)`; replaced by an explicit
`@Subsingleton.elim (A.1 s) (hSub s)` to keep the file warning-free without a
further linter suppression.

**Prioritized next steps.**

1. `B-P017`/`B-C004`: equivalence of the two formation definitions; then
   `B-P018`+ and the section's Eilenberg theorem.
2. `B-D035`/`B-D036`: elementary translations / translations (heavy dependent
   indexing).
3. `B-P010` (term characterization; the unique-parsing proof).

---

## Session 70 -- 2026-09-16 -- frontier: B-P017

**Goal.** An ShSk-formation of `Σ`-algebras is closed under binary subdirect
products.

**What was established (closed).**

- **`B-P017`** as `Mslang.shskFormation_mem_of_subdirect_pair`: for an
  ShSk-formation `F`, algebras `B, C ∈ F`, and a subdirect embedding
  `f : A → B × C`, we have `A ∈ F`. New helpers in `Mslang/Formation.lean`:
  `pairAlgFamily` (the two-element family over `ULift.{u,0} Bool`),
  `isAlgIso_symm` (the inverse of a bijective hom is a hom),
  `quotAlg_ker_isAlgIso` (the first isomorphism theorem: a surjective hom
  `f : A → B` induces an iso `A/Ker f → B`), and `formation_mem_of_iso` (the
  converse direction of `formation_abstract`).
- Proof: `Φ = Ker(pr^B ∘ f)`, `Ψ = Ker(pr^C ∘ f)`; `A/Φ ≅ B` and `A/Ψ ≅ C`
  land in `F` by abstractness; ShSk meet-closure gives `A/(Φ ⊓ Ψ) ∈ F`;
  injectivity of `f` gives `Φ ⊓ Ψ = Δ_A`, and `A/(Φ ⊓ Ψ) ≅ A`, so `A ∈ F`.
- Mapped in `lean/declarations.json`; facets regenerated (**63 mapped blocks**).
- Evidence **`E-000128`** (verification, `build_ok`; `propext`,
  `Classical.choice`, `Quot.sound`) and **`E-000129`** (correspondence,
  `equivalent`; two-stage blind; transcript
  `blocks/audits/B-P017-correspondence.md`).
- `reports/frontier.md`: unmapped blocks **73 -> 72**. `check_all`: **27
  passed, 0 failed**. Journal `EV-000076`.

**Honest caveat.** Same-model audit; inherits the pilot-encoding residuals.
`pairAlgFamily` fixes the binary product as `iAlg` over `ULift.{u,0} Bool` (the
same index-lifting convention as `B-P016`); the binary product is not a separate
primitive. `quotAlg_ker_isAlgIso` gives the direct isomorphisms `A/Φ ≅ B`; they
are consumed in the converse direction through `formation_mem_of_iso` because
`formation_abstract` transports membership forward only. `funext` over the
two-element index is what turns injectivity of `f` into `Φ ⊓ Ψ = Δ_A`, so the
proof is specific to the binary case (the general finite product is next, in
`B-C004`).

**Prioritized next steps.**

1. `B-C004`: equivalence of `DefFormAlg` (`B-D032`) and `ShSkFormAlg`
   (`B-D033`) from `B-P016` + `B-P017` (the `n ≥ 1` induction on the finite
   product, plus the `n = 0` subfinal base case via `B-R017`); then `B-P018`+
   and the section's Eilenberg theorem.
2. `B-D035`/`B-D036`: elementary translations / translations (heavy dependent
   indexing).
3. `B-P010` (term characterization; the unique-parsing proof).

---

## Session 71 -- 2026-09-16/17 -- B-C004 (fixed definition); resumed and closed

**Goal.** `B-C004` (Definition `DefFormAlg` `B-D032` ≡ `ShSkFormAlg` `B-D033`)
was found **false as literally stated**: an ShSk-formation need not contain the
subfinal Σ-algebras, so it need not be closed under the **empty** subdirect
product (`n = 0`). The author chose **Option 1**: change `B-D033` clause 1 from
`F ≠ ∅` to `Sf(1) ⊆ F`, and highlight the manuscript change in red. The first
half ran on 2026-09-16 and was interrupted by a machine shutdown; the resume on
2026-09-17 finished the verification/evidence/views work. This entry is the
combined completed record.

**Author decision taken (this session).** Option 1. The manuscript edit is done.

**What is closed / done.**

- **Counterexample (falsification probe).** Durable record:
  `blocks/audits/B-C004-counterexample.md` (probe source:
  `blocks/audits/B-C004-counterexample.lean.txt`; a copy also lives in
  `/var/folders/0c/zp_5pqkn603dcn4m1b4z806m0000gn/T/opencode/ce_bc004.lean`).
  It proved `∃ F, IsShSkFormation Sig F ∧ ¬ IsAlgebraFormation Sig F` for the
  old clause-1 definition: take `S ≠ ∅`, `Σ` with no operations,
  `F = {algebras with nonempty support}` — ShSk but not a formation (the initial
  algebra `∅^S` is a subproduct of the empty family). Axioms permitted. The file
  **no longer compiles** against the fixed definition, confirming the gap is
  closed.
- **Manuscript edit (done, builds).** `manuscript/MSEilenberg.tex`:
  added `\usepackage{xcolor}`; replaced `\item $\mathcal{F}\neq\varnothing$.`
  with `\item $\textcolor{red}{\mathrm{Sf}(\mathbf{1})\subseteq \mathcal{F}}$.`
  (old line kept commented). Manuscript rebuild: exit 0, **49 pages**. Non-ASCII
  scan clean. `hash_blocks`, `ingest` (129 confirmed, 0 proposed, 126 edges),
  crossrefs re-run; new informal symbol edge `B-D033 -> B-D023` (`\Sf`).
- **Lean (done, built once).** `lean/Mslang/Formation.lean`:
  - `IsShSkFormation` clause 1 is now `(∀ A, SubfinalAlg Sig A → A ∈ F)`
    (i.e. `Sf(1) ⊆ F`); `HOperator`/meet-closure clauses unchanged, so
    `hF.2.1`/`hF.2.2` and the `B-P017` proof are untouched.
  - New `shskFormation_mem_of_subdirect` (finite subdirect-product closure:
    finite meet of `ker(pr^i ∘ f)` built by iterating the binary meet-closure;
    empty index handled by the `Sf(1) ⊆ F` clause).
  - New `algebraFormation_iff_shskFormation` = `B-C004`.
  - New `sortedEqvLe_refl` / `sortedEqvLe_trans` (moved here from `Prelim.lean`,
    which is back to its committed state).
  - A build **completed successfully (8714 jobs)** with this code before the
    lemma move; axioms for the new theorems are `propext, Classical.choice,
    Quot.sound` (permitted). No `sorry`.
- `lean/declarations.json`: new `B-C004` mapping
  (`algebraFormation_iff_shskFormation`, `shskFormation_mem_of_subdirect`,
  `sortedEqvLe_refl`, `sortedEqvLe_trans`; file `lean/Mslang/Formation.lean`).
  58 blocks in the file.

**Resumed and completed (2026-09-17).**

1. **Rebuild after the lemma move.** `env -u ELAN_HOME lake build` completed
   (8714 jobs) with 0 warnings / 0 errors. `#print axioms`: `sortedEqvLe_refl`
   and `sortedEqvLe_trans` depend on none; `shskFormation_mem_of_subdirect` and
   `algebraFormation_iff_shskFormation` on `propext, Classical.choice,
   Quot.sound` (permitted). `Mslang.lean`'s axiom smoke-test list was extended
   with the four B-C004 declarations.
2. **Stale evidence, corrected against the records.** The 2026-09-16 note that
   `B-P017` verification `E-000128` was stale was **wrong**: the verification
   layer's only input is `B-P017/formal_proof`, which the clause-1 edit does not
   touch, so `E-000128` remains valid (`status`: current). Only two records were
   actually stale:
   - `B-D033` verification `E-000121` (`formal_proof` moved) -> re-issued as
     `E-000130` (supersede; `reissue_reason=other`, since the definition content
     genuinely changed, not a hash move).
   - `B-P017` correspondence `E-000129` (`definition_closure` moved) -> re-run
     two-stage blind, re-issued as `E-000131` (supersede).
   - `B-C004` new: `E-000132` (verification `build_ok`) and `E-000133`
     (correspondence `equivalent`; transcript
     `blocks/audits/B-C004-correspondence.md`). The `B-P017` transcript gained a
     dated re-run section.
3. **`blocks/lean_audit.json` regenerated** (`scripts/lean_audit.py`): **159**
   declarations, 0 warnings, 0 unpermitted axioms, 0 `sorry`.
4. **Views regenerated in dependency order:** `report.py`, `calibration.py
   --report`, `impact.py --report`, `discrepancy.py --report`, `sanity.py
   --report`, `frontier.py --report`, then the journal, then `decisions.py
   --report`, then `bundle.py`.
5. **Journal `EV-000077`** (B-D033 facet revision / author Option 1) and
   **`EV-000078`** (B-C004 evidence). Two events, because the definition
   revision was an unrecorded state change from the interrupted half.
6. **`scripts/check_all.sh`: 27 passed, 0 failed**; frontier unmapped
   **72 -> 71**.

**Honest caveat (continued).** Same-model audit; inherits the pilot-encoding
residuals. Both the B-P017 re-run and the new B-C004 correspondence are
two-stage blind with the same underlying model (`deepseek-v4.1-flash`), so
common blind spots are not excluded. The B-C004 correspondence verdict is for
the **corrected** pair of definitions; the old pair is genuinely non-equivalent
(`B-C004-counterexample`). The `pairAlgFamily`/`ULift.{u,0} Bool` binary-product
encoding is used in the B-P017 proof only; the B-C004 backward direction now
covers the general finite index directly.

**Engineering gotcha (important, cost real time this session).** The `edit`
tool **corrupts the latin1 manuscript**: it decoded `manuscript/MSEilenberg.tex`
as UTF-8, turning the 6 legitimate high bytes (`0xF3 0xED 0xE9 0xE4`) into
U+FFFD (`EF BF BD`). Fix used: `git checkout -- manuscript/MSEilenberg.tex`,
then apply edits with Python `open(..., encoding='latin1')` read/modify/write
(latin1 round-trips all bytes). **Never edit the manuscript with the `edit`
tool; use Python/latin1.** Verify with a high-byte histogram vs `HEAD`.

**Dirty tree (uncommitted).** `manuscript/MSEilenberg.tex`,
`lean/Mslang/{Formation,Mslang}.lean`, `lean/declarations.json`,
`blocks/{hashes,registry,graph,formal,formal_graph,lean_audit}.json`,
`journal/events.jsonl`, `blocks/audits/B-P017-correspondence.md`, and the
regenerated views `reports/{coverage,staleness,bundle,frontier}.md` plus the
ingest reports `reports/{inventory,gap_report,pilot_candidates}.md`. New
untracked records: `evidence/E-000130.json`..`E-000133.json`,
`blocks/audits/B-C004-correspondence.md`, and the counterexample probes
`blocks/audits/B-C004-counterexample.{md,lean.txt}`. `calibration.md`,
`impact.md`, `decisions.md`, `sanity.md`, `trust_boundary.md` regenerated
byte-identical (no drift). `check_all` is clean (27/27) on this tree. **No commit
was made** (the session was not asked to commit).

---

**Addendum (author-directed).** The splitting insight is now normative spec, not
just this session's practice: `Architecture.md` §10.2 treats the module layout
as the compile-time dependency graph (with the rationale and the layout table),
§12.1 calls the import DAG "the compile-time backbone" (authoritative for build
order; the extracted graph authoritative for closures), and §13.2 adds
"module move" as an explicit C5 identity sub-case. Journal `EV-000067`. Rule to
remember: a module move *must* stale no evidence; if it does, fix the hashing,
not by re-issuing.

---

## Session 72 -- 2026-09-17 -- translations layer: B-D035, B-D036

**Goal.** Open the "Elementary translations and translations" section with its
two definitions: elementary translations (`B-D035`) and their composite closure
(`B-D036`). Chosen over the listed priority `B-P018` because `B-P018`
(`Form_Alg(Σ)` is an algebraic closure system) needs new vocabulary — an
"algebraic closure system on a class" (the existing `IsClosureSystemOn` at
`Algebra.lean:116` has no directed-union clause, and instantiating the sorted
`IsAlgebraicClosureSystem` at `Alg(Σ)` would cross universes) — whereas the
translations cluster depends only on the `Algebra` layer and is a clean,
bounded step.

**What was established (closed).**

- New module `lean/Mslang/Translation.lean` (imports `Mslang.Algebra` only),
  added to the `Architecture.md` §10.2 module table and the STATE safe-restart
  layout. Declarations:
  - **`B-D035`** as `Mslang.IsElemTranslation` + `Mslang.Etl`: `T : A_t → A_s` is
    a `t`-elementary translation of sort `s` when there is a word `w`, an index
    `i : Fin w.length` with `w.get i = t`, an operation `σ : Σ_{w,s}`, and
    constants in the other positions, with `T x = F_σ(…, x, …)` (`x` inserted at
    position `i`). `Etl Sig A t` is the sorted family `(Etl_t(A)_s)_s`.
  - **`B-D036`** as `Mslang.TlGen` (inductive: `refl`/`elem`/`comp`) + `Mslang.Tl`:
    the smallest family containing the identity and the elementary translations
    and closed under composition, i.e. the paper's finite composites; `Tl` is
    `(Tl_t(A)_s)_s`.
- Encoding notes. The paper's `w ∈ S* − {λ}` is witnessed by `i : Fin w.length`
  (nonemptiness is implied), so no separate hypothesis is carried. The variable
  insertion uses the equality `w.get i = t` through a conjoined `congrArg`/`▸`
  cast; a first attempt with `by rw [h]` inside the `if` failed to elaborate
  (`rewrite` did not find the `Fin` index occurrence) and was replaced by an
  explicit equality chain — no tactic rewrite on a `Fin` index.
- Mapped in `lean/declarations.json`; facets regenerated (**60 mapped blocks**,
  **163 declarations**).
- Evidence: **`E-000134`** (`B-D035`, verification, `build_ok`) and
  **`E-000135`** (`B-D036`, verification, `build_ok`); both axiom-free.
  Definitions carry verification only (layer assignment).
- `reports/frontier.md`: unmapped blocks **71 -> 69**. `check_all`: **27 passed,
  0 failed**. Journal `EV-000079`.

**Honest caveat.** Definitions, so no correspondence layer; a later proposition
over `Etl`/`Tl` will audit the encoding. `TlGen` is the inductive (least) closure
of `id`, elementary translations, and composition; this is equivalent to the
paper's "there is a chain of length `n`" formulation, but the equivalence is not
itself formalized. `Etl_t(A)` is encoded as the set of *functions* `A_t → A_s`
satisfying the translation formula (the formula forces the hom property the
paper attributes to `Hom(A_t, A_s)`); a `Hom`-restricted variant is not used.

**Prioritized next steps.**

1. `B-D037` (actions `T[·]`, `T⁻¹[·]` on subsets) and `B-R018` (`Tl(A)` is a
   category, `End(t)` a monoid) — the rest of the translations cluster.
2. `B-P018`/`B-C005`/`B-D034`: `Form_Alg(Σ)` is an algebraic closure system, its
   lattice, and the formation generating operator. **Requires first** a
   directed-union closure-system-on-`Set (Alg Σ)` vocabulary (new definition);
   decide its universe (`Alg Sig : Type (u+1)`).
3. `B-P019`/`B-P020`/`B-C006`: congruence formations `𝔉_F` and the lattice
   isomorphism (depend on `T_Σ`, B-D026/B-D027, mapped).
4. `B-P010` (term characterization; unique parsing) still open in the
   free-algebra layer.

---

## Session 73 -- 2026-09-17 -- translations layer: B-D037, B-D038

**Goal.** Continue the translations section: the actions `T[·]`/`T⁻¹[·]`
(`B-D037`) and the congruence `Ω^A(L)` cogenerated by `L` (`B-D038`). Both are
definitions, so verification only — a bounded step before the harder
`B-P021`/`B-P022` propositions.

**What was established (closed).**

- `lean/Mslang/Translation.lean` gained:
  - **`B-D037`**: `Mslang.deltaSub s Y` (the `S`-sorted subset that is `Y` at
    `s`, empty elsewhere; `Function.update` of the empty family — the
    subset-level analogue of `deltaT`), `Mslang.transImage T L = δ^{s,T[L_t]}`,
    `Mslang.transPreimage T L = δ^{t,T⁻¹[L_s]}`, and the `X : Set (A_t)` /
    `Y : Set (A_s)` variants `Mslang.transImageSet` (`T[X] = T[δ^{t,X}]`) and
    `Mslang.transPreimageSet`.
  - **`B-D038`**: `Mslang.congCogenerated Sig A L : SortedEqv A.1` — `x ~ y` at
    `t` iff every `t`-translation `T` of any sort `s` satisfies
    `T x ∈ L_s ↔ T y ∈ L_s`. It carries an `@[instance_reducible]` attribute
    (class-typed), matching `nabla`/`ker`/`sortedEqvInf`; the first audit run
    flagged this as the only warning and it was fixed in the same session.
- Mapped in `lean/declarations.json`; facets regenerated (**62 mapped blocks**,
  **169 declarations**).
- Evidence: **`E-000136`** (`B-D037`), **`E-000137`** (`B-D038`), both
  verification `build_ok` and axiom-free.
- `reports/frontier.md`: unmapped blocks **69 -> 67**. `check_all`: **27 passed,
  0 failed**. Journal `EV-000080`.

**Honest caveat.** Definitions only; the encoding of `δ`-concentration is via
`deltaSub`, and `transImage`/`transPreimage` are stated for an *arbitrary*
function `T : A_t → A_s` (the paper states them for `T ∈ Tl_t(A)_s`, but the
formula does not use the translation property). `Ω^A(L)` is encoded as a
`Setoid` family; its axioms follow from `Iff` and are not separately audited.

**Prioritized next steps.**

1. `B-P021` (`CharacCong`): `Φ` is a congruence iff closed under `Etl` iff
   closed under `Tl`. The hard direction is (2) ⇒ (1): the telescoping
   `F_σ(a) = T_0(a_0)`, `T_0(b_0) = T_1(a_1)`, … over an arbitrary word `w`,
   proved by induction on the list with `Fin.cases`/`Fin.tail`. (1) ⇒ (2) is the
   congruence property with the elementary-translation constants; (2) ⇔ (3) is
   `TlGen` induction.
2. `B-P022` (`CharacCogenCong`): `Ω^A(L)` is a congruence, `Ω^A(L) ⊆ Ker(ch^L)`,
   and it is greatest — needs `B-P021` and the `ch^L`/`Ker` vocabulary (B-D015,
   B-D006, mapped).
3. `B-R018` (`Tl(A)` is a category, `End(t)` a monoid) — remark; may want a
   light `Category`/`Monoid` instance or be left statement-only.
4. `B-P018`/`B-C005`/`B-D034` (algebraic closure system on `Form_Alg(Σ)`) still
   needs the directed-union closure-system-on-a-class vocabulary first.

---

## Session 74 -- 2026-09-17 -- translations layer: B-P021 (CharacCong)

**Goal.** The characterization `B-P021`: a sorted equivalence `Φ` on a
`Σ`-algebra `A` is a congruence iff it is closed under the elementary
translations iff it is closed under the translations. This is the section's
substantive proposition and the prerequisite for the cogenerated-congruence
results (`B-P022`).

**What was established (closed).**

- `lean/Mslang/Translation.lean` (now importing `Mslang.Congruence` for
  `IsCongruence`) gained:
  - **`B-P021`** as the pair of biconditionals
    `Mslang.isCongruence_iff_closesUnderEtl` `(1) ↔ (2)` and
    `Mslang.closesUnderEtl_iff_closesUnderTl` `(2) ↔ (3)`, with the predicates
    `Mslang.ClosesUnderEtl` and `Mslang.ClosesUnderTl` and the four implications
    `closesUnderEtl_of_isCongruence`, `congruence_of_closesUnderEtl`,
    `closesUnderTl_of_closesUnderEtl`, `closesUnderEtl_of_closesUnderTl`.
  - Proof content. (1)⇒(2): unpack the elementary translation and apply the
    congruence condition to the two tuples differing only at the insertion
    position. (2)⇒(1): **the telescoping** — `mixedTuple a b j` interpolates
    from `a` (`j = 0`) to `b` (`j = Fin.last`), each step changing one
    coordinate via the elementary translation `Tj z = F_σ(insertTuple j rfl z c)`,
    and the steps are chained by transitivity over `Fin.induction`. (2)⇒(3):
    induction on the `TlGen` derivation; (3)⇒(2): the `elem` constructor.
  - Helpers: `Mslang.insertTuple` (the insertion tuple matching the
    `IsElemTranslation` witness), `Mslang.isElemTranslation_insert` (restating
    `IsElemTranslation` via `insertTuple`), `Mslang.cast_rel` (transporting a
    `Φ`-related pair along a sort equality), and `Mslang.mixedTuple` with
    `mixedTuple_zero`/`mixedTuple_last`.
- Mapped in `lean/declarations.json`; `Architecture.md` §10.2 module row and the
  STATE layout updated (`Translation` now depends on `Congruence`); facets
  regenerated (**63 mapped blocks**, **177 declarations**).
- Evidence: **`E-000138`** (verification, `build_ok`; permitted axioms) and
  **`E-000139`** (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-P021-correspondence.md`).
- `reports/frontier.md`: unmapped blocks **67 -> 66**. `check_all`: **27 passed,
  0 failed**. Journal `EV-000081`.

**Engineering note (the one long run).** The telescoping was developed across a
few **targeted `lake build Mslang.Translation`** iterations (one Mathlib process
each) rather than full `lean_audit` runs; the session still budgeted exactly one
`lean_audit.py` and one `check_all.sh` for the gate. Fixes along the way: the
dependent `if` with a `Fin`-index rewrite (replaced by the `congrArg`/`▸` chain
in `IsElemTranslation`; here the insertion uses `insertTuple` and the `Fin`
threshold arithmetic is discharged by `omega`); constructor-index access in the
`TlGen` induction (use `h _ _ x y _ hE hxy` and `ihU _ _ (ihT …)`); and
`(Φ s).trans ih (step j)` rather than `ih.trans` (Setoid method, not proof field
notation). This is a legitimate use of the targeted check per `AGENTS.md`
rule 1's spirit: the minimal process start, with the artifact still produced by
`lean_audit`.

**Honest caveat.** Same-model audit. The correspondence verdict is relative to
the pilot encoding. `TlGen` is the *least* family generated by `id`, `elem`,
`comp`; this is equivalent to the paper's finite-composite formulation but the
equivalence is by construction, not separately formalized. `IsElemTranslation`
is the paper's "operation with a variable in one position", with the nonempty
word witnessed by `Fin w.length`.

**Prioritized next steps.**

1. `B-P022` (`CharacCogenCong`): `Ω^A(L)` is a congruence, `Ω^A(L) ⊆ Ker(ch^L)`,
   and it is the greatest such — uses `B-P021` and the `ch^L`/`Ker` vocabulary
   (`B-D015`, `B-D006`, mapped). `B-D039` is the naming of `Ω^A(L)`.
2. `B-R018` (`Tl(A)` is a category, `End(t)` a monoid) — remark.
3. `B-P018`/`B-C005`/`B-D034` (algebraic closure system on `Form_Alg(Σ)`) —
   needs the directed-union closure-system-on-a-class vocabulary first.

---

## Session 75 -- 2026-09-17 -- translations layer: B-P022, B-D039

**Goal.** The cogenerated-congruence proposition `B-P022`: `Ω^A(L)` is a
congruence, is contained in `Ker(ch^L)`, and contains every congruence so
contained — i.e. it is the greatest congruence saturating `L`. Plus `B-D039`,
the naming of `Ω^A(L)` as the syntactic congruence. Now dependency-closed by
`B-P021`.

**What was established (closed).**

- `lean/Mslang/Translation.lean` gained:
  - **`B-P022`**: `Mslang.charEqv L` (the kernel `Ker(ch^L)`: `x ~ y` at `s`
    iff `x ∈ L s ↔ y ∈ L s`), and the three theorems
    - `congCogenerated_isCongruence` — `Ω^A(L)` is a congruence. Reduces to
      `ClosesUnderTl` via `B-P021`, and closure under composite translations is
      exactly `TlGen.comp` (`U ∘ T`).
    - `congCogenerated_le_charEqv` — `Ω^A(L) ⊆ Ker(ch^L)` by instantiating the
      universal clause at the identity translation (`TlGen.refl`).
    - `le_congCogenerated_of_isCongruence` — from `hΦ : IsCongruence … Φ` get
      translation-closure (via `B-P021`), so `(Φ t).r x y` gives
      `(Φ s).r (T x)(T y)`, and `h : Φ ⊆ Ker(ch^L)` gives
      `T x ∈ L s ↔ T y ∈ L s`.
  - **`B-D039`** as the `abbrev Mslang.syntacticCongruence = congCogenerated`
    (the paper's alternative name for `Ω^A(L)`).
- Mapped in `lean/declarations.json`; facets regenerated (**65 mapped blocks**,
  **182 declarations**).
- Evidence: **`E-000140`** (B-P022 verification, `build_ok`), **`E-000141`**
  (B-P022 correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-P022-correspondence.md`), **`E-000142`** (B-D039 verification,
  `build_ok`).
- `reports/frontier.md`: unmapped blocks **66 -> 64**. `check_all`: **27 passed,
  0 failed**. Journal `EV-000082`.

**Honest caveat.** Same-model audit. `ch^L` is defined only in the manuscript
prose (no block); the Lean encodes `Ker(ch^L)` directly as `charEqv L`, avoiding
a characteristic map into a two-element sorted set. `B-D039` is a naming
convention, encoded as an `abbrev` alias (the only formal content is that name);
its verification does not add mathematics beyond `B-D038`.

**Prioritized next steps.**

1. `B-R018` (`Tl(A)` is a category, `End(t)` a monoid) — remark; may want a
   light `Category`/`Monoid` instance or be left statement-only.
2. `B-P018`/`B-C005`/`B-D034` (`Form_Alg(Σ)` algebraic closure system, its
   lattice, the formation generating operator) — **requires first** a
   directed-union closure-system-on-`Set (Alg Σ)` vocabulary (new definition;
   the existing `IsClosureSystemOn` lacks the directed-union clause, and the
   sorted `IsAlgebraicClosureSystem` cannot be instantiated at `Alg(Σ)` without
   crossing universes). A definition-first step.
3. `B-P019`/`B-P020`/`B-C006` — congruence formations `𝔉_F` and the lattice
   isomorphism `Form_Alg(Σ) ≅ Form_Cgr(Σ)` (depend on `T_Σ`, mapped; large).
4. `B-P010` (term characterization; unique parsing) still open in the
   free-algebra layer.

---

## Session 76 -- 2026-09-17 -- translations layer: B-R018

**Goal.** The category `Tl(A)` of translations and the endomorphism monoid
`End(t)`. Closes the translations section (`B-D035`–`B-D039`, `B-P021`,
`B-P022`, `B-R018`).

**What was established (closed).**

- `lean/Mslang/Translation.lean` gained **`B-R018`**:
  - `Mslang.TlHom Sig A t s = {T : A.1 t → A.1 s // TlGen Sig A t s T}` — the
    hom-set `Tl_t(A)_s`;
  - `Mslang.TlId` (`⟨id, TlGen.refl t⟩`) and `Mslang.TlComp`
    (`⟨g.1 ∘ f.1, TlGen.comp f.2 g.2⟩`);
  - the three category laws `TlComp_id_left`, `TlComp_id_right`,
    `TlComp_assoc` (by `Subtype.ext` + function extensionality, the translation
    proofs being irrelevant);
  - `Mslang.tlEndMonoid : Monoid (TlHom Sig A t t)` with `mul = TlComp`,
    `one = TlId`, registered as a typeclass instance
    (`attribute [instance] tlEndMonoid`).
- The category is presented as **raw data** (hom type, identity, composition,
  the three laws) rather than a Mathlib `CategoryTheory.Category` instance. This
  is deliberate: a `Category` instance keyed on the bare sort type `S` would
  risk leaking. Stage 2 of the audit judged this a packaging difference only.
- Mapped in `lean/declarations.json`; facets regenerated (**66 mapped blocks**,
  **189 declarations**).
- Evidence: **`E-000143`** (verification, `build_ok`) and **`E-000144`**
  (correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-R018-correspondence.md`).
- `reports/frontier.md`: unmapped blocks **64 -> 63**. `check_all`: **27 passed,
  0 failed**. Journal `EV-000083`.

**Honest caveat.** Same-model audit. The `Monoid` structure is a `def`
(`tlEndMonoid`) with `attribute [instance]` rather than an `instance` command,
because the facet extractor matches `def`/`theorem`/`inductive` but not
`instance`; this keeps the declaration mappable while still registering it for
typeclass search. Arguments to `mul` follow the category order (`mul f g =
TlComp f g = g ∘ f`); the opposite convention yields the opposite monoid, and
the stage-2 comparator treated this as notation, not a weakening.

**Prioritized next steps.**

1. `B-P018`/`B-C005`/`B-D034` (`Form_Alg(Σ)` algebraic closure system, its
   lattice, the formation generating operator). **Requires first** a
   directed-union closure-system-on-`Set (Alg Σ)` vocabulary (new definition;
   `IsClosureSystemOn` lacks the directed-union clause, and the sorted
   `IsAlgebraicClosureSystem` cannot be instantiated at `Alg(Σ)` without crossing
   universes). Then: `Alg(Σ)` is a formation; a nonempty intersection of
   formations is a formation; a directed union of formations is a formation (the
   last needs combining finitely many indices via the directedness, over the
   `Fintype` index of `P_fsd`).
2. `B-P019`/`B-P020`/`B-C006` — congruence formations `𝔉_F` and the lattice
   isomorphism `Form_Alg(Σ) ≅ Form_Cgr(Σ)` (depend on `T_Σ`; large).
3. `B-P010`/`B-P011`/`B-C003` — term characterization, free-algebra universal
   property, adjunction.

---

## Session 77 -- 2026-09-17 -- formation cluster: B-P018, B-D034

**Goal.** Open the `Form_Alg(Σ)` cluster: `B-P018` (`Form_Alg(Σ)` is an
algebraic closure system) and `B-D034` (the formation generating operator
`Fmg_Σ`).

**What was established (closed).**

- `lean/Mslang/Algebra.lean` gained a generic one-sorted closure notion,
  **`Mslang.IsAlgebraicClosureSystemOn (X : Type v) (C : Set (Set X))`**: `X ∈ C`,
  closed under nonempty intersections, and closed under nonempty directed unions
  (pairwise upper bounds). This is the encoding device for `B-P018`: the existing
  many-sorted `IsAlgebraicClosureSystem` is `u`-monomorphic and cannot be
  instantiated at `Alg Sig : Type (u+1)`. The file's universe line became
  `universe u v`.
- `lean/Mslang/Formation.lean` gained:
  - **`B-P018`** as `Mslang.algebraFormations_isAlgebraicClosureSystem :
    IsAlgebraicClosureSystemOn (Alg Sig) (algebraFormations Sig)`. Helpers:
    `HOperator_mono`/`PFsdOperator_mono` (monotonicity of the two operators) and
    `exists_mem_superset_finset` (in a nonempty directed family, any finite
    subfamily has a common upper bound, by `Finset` induction). Proof: `Alg(Σ)`
    is a formation; a nonempty intersection is a formation (push each witness
    into every member via monotonicity and `Set.mem_sInter`); a nonempty directed
    union is a formation (H-closure uses one witness; `P_fsd`-closure chooses one
    member per factor and combines the finitely many by directedness).
  - **`B-D034`** as `Mslang.formationGenerating Sig M = ⋂₀ {F |
    IsAlgebraFormation Sig F ∧ M ⊆ F}` — `Fmg_Σ(M)`, the intersection of all
    formations containing `M`.
- Mapped in `lean/declarations.json`; facets regenerated (**68 mapped blocks**,
  **194 declarations**).
- Evidence: **`E-000145`** (B-P018 verification, `build_ok`), **`E-000146`**
  (B-P018 correspondence, `equivalent`; two-stage blind; transcript
  `blocks/audits/B-P018-correspondence.md`), **`E-000147`** (B-D034 verification,
  `build_ok`).
- `reports/frontier.md`: unmapped blocks **63 -> 61**. `check_all`: **27 passed,
  0 failed**. Journal `EV-000084`.

**Honest caveat.** Same-model audit. `IsAlgebraicClosureSystemOn` is an encoding
device (no manuscript block); the many-sorted `IsAlgebraicClosureSystem`
(`B-D012`) is not universe-polymorphic, so the one-sorted notion is introduced
rather than instantiated. `B-D034` is a definition by reference: the paper calls
`Fmg_Σ` "the algebraic closure operator canonically associated to
`Form_Alg(Σ)`", and the Lean encodes it as the intersection of the formations
containing `M`; the closure-operator laws (extensive/monotone/idempotent,
`B-P005`'s `IsClosureOperator`) are **not** proved here (deferred to `B-C005`).

**Prioritized next steps.**

1. `B-C005`: `Form_Alg(Σ)` is an *algebraic lattice*, and `F` is compact iff
   `F = Fmg_Σ(M)` for a finite `M`. Needs a `CompleteLattice` structure on the
   formations (order `⊆`, `sInf` = intersection, `sSup` = `Fmg_Σ` of the union)
   and `IsAlgebraicLattice`; this is the natural continuation and also lets the
   `B-D034` closure-operator laws be added.
2. `B-P019`/`B-P020`/`B-C006` — congruence formations `𝔉_F` and the lattice
   isomorphism `Form_Alg(Σ) ≅ Form_Cgr(Σ)`.
3. `B-P010`/`B-P011`/`B-C003` — term characterization, free-algebra universal
   property, adjunction.

---

## Session 78 -- 2026-09-17 -- cogenerated-congruence section: B-P023, B-P025

**Goal.** Two more blocks in the "Congruence cogenerated by an `S`-sorted
subset" section, both dependency-closed by the translations layer.

**What was established (closed).**

- `lean/Mslang/Translation.lean` gained:
  - **`B-P023`** (`CharacSatCCog`) as
    `Mslang.isSat_iff_le_congCogenerated : IsSat Φ L ↔ sortedEqvLe Φ
    (congCogenerated Sig A L)` for `hΦ : IsCongruence Sig A.2 Φ`, plus the
    structure-free helper `Mslang.isSat_iff_sortedEqvLe_charEqv :
    IsSat Φ L ↔ sortedEqvLe Φ (charEqv L)` (saturation is containment in
    `Ker(ch^L)`). Proof: (→) `B-P022`(3)
    (`le_congCogenerated_of_isCongruence`, the only use of `hΦ`); (←)
    `congCogenerated_le_charEqv` composed pointwise.
  - **`B-P025`** (`Compl`) as `Mslang.congCogenerated_compl :
    congCogenerated Sig A L = congCogenerated Sig A (complA L)`. Proof:
    `funext t`, `Setoid.ext`, then the pointwise iff — `Iff.not` for (→), and
    `Iff.not` + double-negation elimination (`not_not`) for (←), with
    `complA_bridge` exposing the negation.
- Mapped in `lean/declarations.json`; facets regenerated (**70 mapped blocks**,
  **197 declarations**).
- Evidence: **`E-000148`/`E-000149`** (B-P023 verification/correspondence) and
  **`E-000150`/`E-000151`** (B-P025 verification/correspondence); both
  correspondences `equivalent`, two-stage blind, transcripts
  `blocks/audits/B-P023-correspondence.md` and `B-P025-correspondence.md`.
- `reports/frontier.md`: unmapped blocks **61 -> 59**. `check_all`: **27 passed,
  0 failed**. Journal `EV-000085`.

**Honest caveat.** Same-model audit. `B-P025`'s reverse direction uses classical
double-negation elimination (the forward direction is constructive); stage 2
treated this as a proof-method difference, not a statement difference.
`B-P023`'s helper `isSat_iff_sortedEqvLe_charEqv` is stated at the bare
sorted-set level (no signature), which is the natural level for
"saturation = membership-invariance".

**Prioritized next steps.**

1. `B-P024`/`B-R020` (`Φ = ⋂ Ω^A(δ^{s,[a]_{Φ_s}})`; `Δ^A = ⋂ Ω^A(δ^{s,a})`) and
   `B-P026` (`⋂_j Ω^A(L^j) ⊆ Ω^A(⋂_j L^j)`) — all need an **arbitrary meet of
   sorted equivalences** (`sortedEqv_iInf`, the infinitary analogue of
   `sortedEqvInf`), which is new infrastructure. `B-P024` needs the
   `δ^{s,[a]_Φ}` subsets and the `B-P023` bridge.
2. `B-P027` (`Ω^A(L) ⊆ Ω^A(T⁻¹[L])`, using `transPreimage` B-D037) and `B-P028`
   (pullback along a homomorphism, with equality for an epimorphism).
3. `B-C005` (`Form_Alg(Σ)` is an algebraic lattice) — needs a `CompleteLattice`
   on the formations (a `ClosureOperator` on `Set (Alg Σ)` with `toFun =
   formationGenerating` and `GaloisInsertion.liftCompleteLattice`, then transport
   across `IsClosed ↔ IsAlgebraFormation`) and the finitary/compact argument;
   the project's `IsCompact`/`IsAlgebraicLattice` are `u`-monomorphic, so
   universe-`v` versions are also needed.
4. `B-P019`/`B-P020`/`B-C006` — congruence formations `𝔉_F` and the lattice
   isomorphism `Form_Alg(Σ) ≅ Form_Cgr(Σ)`.

---

## Session 79 -- 2026-09-17 -- cogenerated-congruence section: B-P026, B-P027, B-R020

**Goal.** Add the missing *arbitrary meet of sorted equivalences* and use it to
close the meet/anti-translation results of the cogenerated-congruence section.

**What was established (closed).**

- `lean/Mslang/Prelim.lean` gained **`Mslang.sortedEqv_iInf`** (the componentwise
  meet `⋂_i Φ_i` of a family of sorted equivalences), with `sortedEqv_iInf_le`
  and `le_sortedEqv_iInf` (the meet is the greatest lower bound). This is the
  infinitary analogue of the existing binary `sortedEqvInf`.
- `lean/Mslang/Translation.lean` gained:
  - **`B-P026`** (`InterCCog and CCogInter`) as
    `Mslang.congCogenerated_iInter_le : ⋂_j Ω^A(L^j) ⊆ Ω^A(⋂_j L^j)`, with
    `Mslang.isCongruence_iInf` (a meet of congruences is a congruence). Proof:
    the meet is contained in `Ker(ch^{⋂ L^j})` (`B-P022`(2) at each `j`), the
    meet of congruences is a congruence, and `B-P022`(3) concludes. The
    nonemptiness of the index set is **unnecessary** (the empty case gives the
    universal relation on both sides), so the correspondence is
    `formal_stronger`.
  - **`B-P027`** (`TAntiTrans`) as `Mslang.congCogenerated_le_transPreimage :
    Ω^A(L) ⊆ Ω^A(T⁻¹[L])` for `T ∈ Tl_t(A)_s`. Proof: the composite translation
    `T ∘ V` (`TlGen.comp`) handles the `s'' = t` case; the other case is empty.
  - **`B-R020`** as `Mslang.deltaEqv` (the diagonal sorted equivalence) and
    `Mslang.deltaEqv_eq_iInf_congCogenerated : Δ^A = ⋂_{s,a} Ω^A(δ^{s,a})`
    (index `Σ s, A_s`; the marked point `⟨s,x⟩` with the identity translation
    forces `y = x`).
- Mapped in `lean/declarations.json`; facets regenerated (**73 mapped blocks**,
  **202 declarations**).
- Evidence: **`E-000152`/`E-000153`** (B-P026), **`E-000154`/`E-000155`**
  (B-P027), **`E-000156`/`E-000157`** (B-R020). Correspondences: `formal_stronger`
  (B-P026), `equivalent` (B-P027, B-R020); two-stage blind; transcripts
  `blocks/audits/B-P026-correspondence.md`, `B-P027-correspondence.md`,
  `B-R020-correspondence.md`.
- `reports/frontier.md`: unmapped blocks **59 -> 56**. `check_all`: **27 passed,
  0 failed**. Journal `EV-000086`.

**Honest caveat.** Same-model audit. `B-P026` is `formal_stronger` because the
manuscript's index nonemptiness is dropped; the empty case holds vacuously, so
this is a faithful conservative generalization (the same shape as `B-P005`'s
`formal_stronger`). `B-R020`'s reverse direction uses the identity translation
at the chosen marked point.

**Prioritized next steps.**

1. `B-P024` (`Φ = ⋂{Ω^A(δ^{s,[a]_{Φ_s}})}`) — needs the `Φ`-classes (`eqvClass`,
  B-P013 of Prelim) and the `B-P023` bridge; the same `sortedEqv_iInf` now
  applies.
2. `B-P028` (pullback `(f×f)⁻¹[Ω^B(M)] ⊆ Ω^A(f⁻¹[M])`, equality for an
  epimorphism) — needs the pullback of a sorted relation along `f×f`.
3. `B-C005` (`Form_Alg(Σ)` is an algebraic lattice) — needs a `CompleteLattice`
  on the formations and universe-`v` `IsCompact`/`IsAlgebraicLattice`.
4. `B-P019`/`B-P020`/`B-C006` — congruence formations `𝔉_F` and the lattice
   isomorphism.
5. `B-P010`/`B-P011`/`B-P012`/`B-P013`/`B-P015`/`B-C003` — the free-algebra
   cluster, blocked on the term characterization (unique parsing).

---

## Session 80 -- 2026-09-17 -- cogenerated-congruence section: B-P024, B-P028

**Goal.** Finish the cogenerated-congruence section: the class decomposition of a
congruence and the behaviour of `Ω` under homomorphisms.

**What was established (closed).**

- `lean/Mslang/Translation.lean` gained:
  - **`B-P024`** (`RepCongInterCCogKroneckerDelta`) as
    `Mslang.isCongruence_eq_iInf_congCogenerated : Φ = ⋂_{s,a}
    Ω^A(δ^{s,[a]_{Φ_s}})` for a congruence `Φ`. (⊆) uses closure of `Φ` under
    translations (`B-P021`) and transitivity; (⊇) the marked point `(t,x)` with
    the identity translation forces `y ∈ [x]_Φ`.
  - **`B-P028`** (`TAntiHom`) as `Mslang.pullbackEqv` (the pullback
    `(f×f)⁻¹[·]`), `Mslang.pullbackEqv_congCogenerated_le`
    (`(f×f)⁻¹[Ω^B(M)] ⊆ Ω^A(f⁻¹[M])` for a homomorphism) and
    `Mslang.congCogenerated_le_pullback_of_surj` (the reverse inclusion for an
    epimorphism, giving equality). Helpers: `Mslang.sortedMap_cast`
    (`Eq.rec`-transport naturality for a sorted map), `Mslang.isElemTranslation_map`
    / `Mslang.tlGen_map` (transport a translation along a homomorphism) and
    `Mslang.isElemTranslation_lift` / `Mslang.tlGen_lift` (lift a translation
    along an epimorphism, choosing preimages with `Classical.choose`). These
    formalize the manuscript's **commented-out** proposition `TlandHom`.
- Mapped in `lean/declarations.json`; facets regenerated (**75 mapped blocks**,
  **206 declarations**).
- Evidence: **`E-000158`/`E-000159`** (B-P024), **`E-000160`/`E-000161`**
  (B-P028); both correspondences `equivalent`, two-stage blind; transcripts
  `blocks/audits/B-P024-correspondence.md` and `B-P028-correspondence.md`.
- `reports/frontier.md`: unmapped blocks **56 -> 54**. `check_all`: **27 passed,
  0 failed**. Journal `EV-000087`.

**Honest caveat.** Same-model audit. The translation/homomorphism helpers go
beyond `B-P028`'s contract (they are the commented-out `TlandHom` proposition);
they are mapped as helpers of `B-P028` rather than as a block, since the
manuscript does not mint an ID for that commented proposition. The cogenerated-
congruence section is now essentially complete on the formalization frontier.

**Prioritized next steps.**

1. `B-R021` (`Ω` is a natural transformation `P⁻ ⇒ Cgr` between contravariant
   functors on `Alg(Σ)_epi`) — the manuscript's other large cogenerated-
   congruence remark; needs a light category/functor encoding (like `B-R018`)
   and the `B-P028` equality.
2. `B-C005` (`Form_Alg(Σ)` is an algebraic lattice) — `CompleteLattice` on the
   formations plus universe-`v` `IsCompact`/`IsAlgebraicLattice` and the
   finitary/compact argument.
3. `B-P019`/`B-P020`/`B-C006` — congruence formations `𝔉_F` (a filter-valued
   choice function) and the lattice isomorphism `Form_Alg(Σ) ≅ Form_Cgr(Σ)`.
4. `B-P010`/`B-P011`/`B-P012`/`B-P013`/`B-P015`/`B-C003` — the free-algebra
   cluster, blocked on the term characterization (unique parsing).

---

## Session 81 -- 2026-09-17 -- verification hardening (OpenSpec change)

**Goal.** Implement `harden-verification-workflow` (the OpenSpec change that
turns the explore-mode review into tracked work): make audit independence
computed and visible, measure calibration at scale, turn reports into countable
queues, close the manuscript loop, triage scope, and tier the gate.

**What was established (closed).**

- **Independence is computed and gated.** `schemas/evidence.schema.json` gained
  the `independence` object; `scripts/status.py` gained `family_of`,
  `derive_independence`, `classify_stages`, `classify_record`,
  `independence_of`, `derive_caveat`, and `load_tiers`, plus the `provisional`
  layer status. A current positive layer whose positive evidence is all
  `same_model` is `provisional` unless the block is **explicitly** `light`
  (unclassified is not exempt). `scripts/evidence.py` computes `independence`
  and a derived `independence_caveat` (the free-text `--caveat` is gone; new
  `--stage`, `--protocol`, `--residual`, `--models`). Shadow run over the
  corpus: **41 layers pass -> provisional, 0 other changes**; recorded as
  **`EV-000088`**. The 161 existing records were not edited.
- **Model registry and routing.** `calibration/models.json` +
  `scripts/models.py` (`choose_stages`, `--check`) route an
  independence-requiring stage to a different model family when one is declared,
  and record `same_model` (never a claim) when none is.
- **Calibration at scale.** `scripts/mutations.py` (7 named operators) generates
  `calibration/generated.json` (13 cases); the corpus self-check enforces a
  per-type minimum; `scripts/calibration.py` reports `n`, detected, rate, and a
  Wilson interval per type (never a rate without its `n`), per model pair, and
  gates on a recorded baseline (`calibration/baseline.json`). 24 cases over 4
  blocks; 7 run mutations, 13 generated unrun.
- **Discrepancy dispositions.** `blocks/discrepancy_decisions.json` (the 3
  legacy notes migrated), documented default rules (carrier target -> type-carrier),
  and a report that surfaces a single **undecided** count/list and collapses
  default-classified edges: 244 undecided, 49 default, 3 reviewed.
- **Scope triage.** `blocks/scope_decisions.json` + `scripts/scope.py`
  (author-reserved: an agent write is refused); `scripts/frontier.py` groups
  unmapped blocks by disposition and excludes `out-of-scope` from open
  obligations.
- **Manuscript reconciliation.** `reconciliation/proposals.json` +
  `scripts/reconcile.py`; the two existing Explanations are registered as open
  `reconstructed-proof` proposals; acceptance is author-reserved and records the
  resulting manuscript hash.
- **Tiered gate.** `scripts/check_all.sh --fast` (32 checks; no Lean, no PDF;
  Lean/build printed `DEFERRED`) is the per-edit gate; the full run is the
  session-close artifact.
- **Tests** added/extended: `status_test` (provisional, classification, caveat),
  `models_test`, `scope_test`, `reconcile_test`; `calibration_test` (interval,
  per-pair, baseline); `discrepancy_test` (dispositions, not-evidence).
- **Docs**: `Architecture.md` **Revision 5** (Sections 8.1, 9, 11.4, 12.2, 19,
  21, 25); `AGENTS.md` rule 2 restated as fast-per-edit / slow-per-session;
  `STATE.md` safe-restart item 7 restated.

**Findings.**

- The spec's `light`-tier exemption collided with Architecture's "light is the
  default": with a literal reading nothing would flip. The author chose
  **unclassified is not light**, so the 41 same-model layers are visibly
  provisional until a `light` designation is recorded; Architecture 8.3's
  wording is corrected by Revision 5.
- The discrepancy default rule is deliberately narrow (only the carrier target,
  49 edges); 244 rows remain a genuine, countable review queue rather than
  untriaged noise. Widening the defaults is a review decision, not a mechanical
  one.
- Generated calibration cases carry no verdicts and are reported **unrun**; no
  detection was fabricated.

**Gate.** `scripts/check_all.sh`: **35 passed, 0 failed** (Session 81). Journal
`EV-000089`.

**Honestly deferred / author-reserved.**

- The 244 undecided discrepancy rows are a review queue for the author/reviewer.
- The 13 generated calibration cases need a blind comparator run; a second model
  would upgrade `provisional` to `pass`.
- The two reconciliation proposals (B-C001, B-C002) and the 54-block scope
  triage await author decisions; a scope decision brief is presented.

**Prioritized next steps.**

1. Run the 13 generated calibration cases blind; record verdicts and re-baseline.
2. Obtain/declare a second model in `calibration/models.json` so routing can
   produce `cross_model` and clear `provisional` layers.
3. Author: accept or reject `R-0001`/`R-0002`; set scope dispositions for the
   unmapped blocks; decide the 244 undecided discrepancy rows.
4. Continue the formalization frontier (unchanged: the largest remaining
   clusters from Session 80).

**Session 81 (continued) -- post-archive corrections.** After archiving
`harden-verification-workflow`, a self-audit of the session's own claims found
three integration gaps; all are fixed and the fast gate is 32/0/3.

- **The `light` exemption was not wired into the views.** `report.py`,
  `frontier.py`, and `bundle.py` called `status.block_status` without the tier
  store, so an explicit `light` designation would have been ignored in every
  view (only the `status.py` CLI passed tiers). Added
  `status.load_default_tiers()`, the committed store
  `blocks/treatment_tiers.json` (empty; unclassified is still not light), and
  wired all three callers; `status_test.py` now checks the exemption flows
  through `block_status`. This corrects the coverage claimed for the archived
  task 1.4; the archived `tasks.md` is left frozen.
- **The bundle omitted the new durable stores and one view.** `bundle.py` now
  hashes `calibration/{models,generated,baseline}.json`,
  `blocks/{treatment_tiers,scope_decisions,discrepancy_decisions}.json`, and
  `reconciliation/proposals.json`, and embeds `reports/reconciliation.md`.
- **`AGENTS.md` named a non-existent flag** `--supersede`; corrected to
  `--supersedes` (the flag `scripts/evidence.py` actually defines).
- **The tier store's entry form was mishandled.** `block_status` compared the
  raw store value, so a `{"tier": "light"}` entry would never have cleared
  `provisional`; added `status.tier_of` and a normalization check.
- **Added `scripts/tiers.py`** (author-guarded `set`, `--check`, `--list`) and
  `scripts/tiers_test.py`, wired into the fast tier, so a tier can be recorded
  without hand-editing JSON. Fast gate: **34 passed, 0 failed, 3 deferred**.
- **Calibration run 3 -- generated cases, blind.** A fresh blind comparator
  (contract/readback only, no type or expectation) judged the generated cases.
  The first pass **exposed two operator defects**: the `encoding` operator only
  changed "componentwise subset" to "subset", which is *not* a mismatch here
  (all four were rightly judged equivalent), and `direction_flip` produced a
  self-contradictory gloss. Both were fixed in `scripts/mutations.py`;
  `encoding` now switches "S-sorted equivalences" to "S-sorted relations", a
  genuine Setoid-vs-relation (residual D4) change. On the corrected corpus the
  comparator returned **12/12 detected**; calibration is now **19/19 mutations
  detected, 0/4 control false positives, 0 unrun**, and the baseline gate
  passes. This is the calibration suite catching a bug in itself, which is what
  it exists for. Caveat unchanged: one model pair, wide intervals at these
  sample sizes.

---

## Session 82 -- 2026-09-17 -- frontier: B-R021 (Ω natural transformation)

**Goal.** Formalize the next block on the frontier: `B-R021`, which says `Ω^A`
is the component at `A` of a natural transformation `Ω : P⁻ ⇒ Cgr` between two
contravariant functors on `Alg(Σ)_epi`. Session 80's `B-P028` pullback equality
is its missing ingredient, so it became the natural next target.

**Recon.** The disk was at **128 MiB free (99%)**, so Lean work was blocked;
the author deleted the retired `~/Desktop/MathForm` (7.6 GiB, its own working
tree, no symlinks from this repo), restoring **8.2 GiB**. The `B-R018` light
category encoding (hom-sets + laws, not Mathlib `CategoryTheory`) was the
precedent.

**What was established (closed).**

- `lean/Mslang/Translation.lean` gained the light encoding:
  - `isAlgHom_id`, `isAlgHom_comp` -- the homomorphism calculus;
  - `sortedEqvLe_antisymm` -- mutual refinement is equality;
  - `AlgEpi` (a surjective homomorphism), `AlgEpiId`, `AlgEpiComp`,
    `AlgEpiComp_id_left`/`_id_right`/`_assoc`, `AlgEpiExt` -- the category
    `Alg(Σ)_epi`;
  - `SubMap` (= `inverseImage`), `CgrMap` (= `pullbackEqv`) and their
    contravariant functor laws `SubMap_id`/`_comp`, `CgrMap_id`/`_comp`;
  - `congCogenerated_natural`: for an epimorphism `f`,
    `CgrMap f (Ω^B M) = Ω^A (SubMap f M)`, exactly the two `B-P028` inclusions
    combined by antisymmetry.
- Clean build; `lean_audit` **223 declarations, 0 warnings, 0 unpermitted, 0
  `sorry`**. Axioms of `congCogenerated_natural`:
  `{Classical.choice, Quot.sound, propext}` (permitted).
- Facet extractor extended to `structure` declarations (with a regression test:
  `lean_facets_test` now 16 checks, all pass).
- Evidence: **`E-000163`** (verification, `build_ok`; supersedes `E-000162` after
  the category laws changed the block's proof facet) and **`E-000164`**
  (correspondence, **`equivalent`**, two-stage blind). Transcript
  `blocks/audits/B-R021-correspondence.md`.
- `reports/frontier.md`: unmapped blocks **54 -> 53**. `check_all`: **37 passed,
  0 failed**. Journal `EV-000090` / `EV-000091`.

**Finding (the audit changed the artifact).** The first-pass stage-1 read-back
listed as *not claimed* exactly the epi category's identity/associativity laws
and extensionality -- the paper calls `Alg(Σ)_epi` a category, but the first
version proved only the functor laws. The laws were added
(`AlgEpiComp_id_left`/`_id_right`/`_assoc`, `AlgEpiExt`) and the second pass
returned `equivalent`. This is the two-stage blind audit doing its job: it drove
a faithfulness fix rather than merely recording a verdict.

**Gotchas.**

- The facet extractor's `DECL_RE` did not match `structure` (now added), and it
  does **not** match a keyword carrying an inline leading attribute
  (`@[ext] theorem X`) -- the attribute must be on its own line, as elsewhere in
  the codebase. Both surfaced here (`AlgEpi`, then `AlgEpiExt`).
- No `AlgEpi.ext` is generated (the `hom`/`surj` fields are `Prop`); the
  explicit `AlgEpiExt` is supplied.
- **Three `lean_audit.py` runs were spent this session**: the first before the
  category laws existed, and again after the attribute-placement edit. Each is a
  full Mathlib load. Lesson: add a block's helper laws *before* the first audit.

**Honestly deferred.** `B-R021`'s correspondence is `same_model`, so the layer is
`provisional`; no second model is available. No `Category`/`Functor` typeclass
instance is used (the light encoding gives the operations and their laws only),
matching `B-R018`.

**Prioritized next steps.**

1. `B-C005` (`Form_Alg(Σ)` is an algebraic lattice) -- `CompleteLattice` on the
   formations plus universe-`v` `IsCompact`/`IsAlgebraicLattice`.
2. `B-P019`/`B-P020`/`B-C006` -- congruence formations and the lattice
   isomorphism `Form_Alg(Σ) ≅ Form_Cgr(Σ)`.
3. The free-algebra cluster (`B-P010`..`B-P015`, `B-C003`), still blocked on the
   term characterization (unique parsing).
4. Author decisions still open: reconciliation `R-0001`/`R-0002`, scope triage
   for the 53 unmapped blocks, the discrepancy review queue; declare a second
   model to clear `provisional` layers.

**Session 82 (continued) -- author scope triage.** The author triaged all 53
unmapped blocks (the conservative option 1): **33 worth-formalizing** (both
Eilenberg theorems and their load-bearing support), **20 deferred** (the
free-algebra cluster `B-P010`-`B-P013`, `B-C003` pending the term
characterization; `B-P036` as a subsumed lattice statement; and 12 remarks + 2
examples), **0 out-of-scope**. Recorded in `blocks/scope_decisions.json`
(`decided_by author:session82`) with journal `EV-000092`; `reports/frontier.md`
now reports the triage, so the 53 are classified rather than undecided. Because
nothing was marked `out-of-scope`, the open-obligation list is still 53 -- the
classification, not a shorter list, is the deliverable (option 2 would have
removed the 14 illustrative blocks from obligations). `check_all`: **34 passed,
0 failed, 3 deferred**. Next: resume the frontier with `B-C005`.

---

## Session 83 -- 2026-09-17 -- notation resolution (OpenSpec change)

**Goal.** Implement `resolve-ambiguous-notation` (the change the explore session
produced): make notation extraction compound-aware and introducer-based, add an
author-reserved resolution store, stop silently dropping ambiguous-notation
edges, and stage the recovered dependency edges as candidates. No Lean or
manuscript edit.

**What was established (closed).**

- **Compound notation identity.** `scripts/ingest.py` now folds a
  `\mathrm{...}` base plus its normalised subscript chain into one identity,
  including nesting (`\mathrm{Form}_{\mathrm{Cgr}_{\mathrm{fi}}}` -> `Form_Cgr_fi`).
  The phantom tokens `f`/`fi` are gone (`parse_notations`, `_content_identity`,
  `_qualifier_identity`, `_mathrm_identity`, `_subscript_end`).
- **Introducer determination is sentence-scoped.** The fixed 100-character cue
  window is replaced by definee detection: the cue must sit in the same sentence
  and the notation must be adjacent to it (`denote by` / `call` / `write` /
  coordinated `and by`, or `stands for` after an argument). `Alg` is now owned by
  its true introducer `B-D017` (previously missed) and the five false owners
  `B-D031`/`B-D032`/`B-D034`/`B-D042`/`B-D043` are dropped; mention-only
  definitions no longer own (`Hom` -> `B-D002` only, `Sg` -> `B-D021`, and
  `B-D027`'s "determined by" no longer captures `Sg`).
- **Author-reserved resolution store.** `blocks/notation.json` +
  `scripts/notation.py` (`--list`/`--check`/`set`; refuses any `decided_by` not
  beginning `author:`) + `scripts/notation_test.py`. Resolution order is
  store-first, then mechanical unique owner (term-match fallback, e.g. `\delta`
  via "delta of Kronecker in"), else **unresolved and reported** rather than
  assigned a default owner.
- **Fail closed.** An unparsable `\mathrm{...}` declaration raises
  `NotationError`; `ingest` reports it and exits 1 without a partial map.
- **Recovered edges are candidates.** Graph edges **126 -> 236**; **113 new
  candidates**; **no confirmed edge lost** (diffed against the pre-change
  `graph.json`) and no layer status changed. Unconfirmed candidates do not enter
  closure computation.
- **Ambiguity is visible.** Gap report §7 lists every notation identity's
  resolution state; the 4 genuinely ambiguous ones were resolved by the author
  (`author:session73`): `supp_S`->`B-D009`, `Omega`->`B-D038`, `Delta`->`B-D014`,
  `Sub`->`ambient`. `blocks/symbols.json` carries each identity's state and use
  count.
- **Drift and tests.** `ingest.py --check` now also drift-checks
  `reports/gap_report.md`; `scripts/ingest_test.py` and `scripts/notation_test.py`
  are wired into the fast tier. `reports/bundle.md` regenerated.
- **OpenSpec.** proposal/specs/design/tasks complete; archived to
  `openspec/changes/archive/2026-09-17-resolve-ambiguous-notation/`; the new main
  spec `openspec/specs/dependencies/notation/spec.md` was created by the sync;
  `openspec validate --specs` 7 passed, 0 failed.

**Findings.**

- The 10 `ambiguous_symbols` were **not 10 decisions**: two tokenizer artifacts
  (`f`, `fi`), one prefix artifact (`Form`), five misattributed owners (`Alg`,
  `Cgr`, `Sg`, `Sub`, `Hom`), and only two genuine overloads (`supp`, `Omega`).
  The window both missed the real introducer (`B-D017` for `Alg`) and invented
  five false ones.
- `\Sub` is a genuine **overloading**, not a single-owner ambiguity: `B-D005`
  means sorted *subsets*, `B-D020` means *subalgebras*. The single-target store
  cannot express both, so it is `ambient` pending a context-sensitive rule (a
  spec amendment). `\Delta` and `\Omega` are nested duals and resolved to their
  root definition.
- Confirmation cannot be free: **every one of the 113 recovered edges stales at
  least one current evidence record**; confirming all would stale **59 of 72**
  statement-layer records. The staged rollout is therefore not a mechanism
  detail but the whole point.

**Gate.** `scripts/check_all.sh`: **40 passed, 0 failed** (Session 83).

**Honestly deferred / author-reserved.**

- **Task 7.3** (confirm the 113 recovered edges, re-issue the staled evidence) is
  deferred by author decision; the candidates stay unconfirmed and **no evidence
  was invalidated**. Recorded in the archived `tasks.md`.
- `\Sub` context-sensitive resolution (subsets vs subalgebras) needs a
  `dependencies/notation` spec amendment.
- The four notation resolutions were typed by the coordinator at the author's
  direction and attributed to `author:session73`.

**Prioritized next steps.**

1. The original motivation: **goal-directed dependency ranking** (reverse rank
   for the target, forward rank over its ancestors), now better grounded by the
   126 -> 236-edge graph; start it as a new OpenSpec change.
2. Edge confirmation + evidence re-issue policy for the 113 candidates.
3. `\Sub` context rule (`dependencies/notation` amendment).

---

## Session 84 -- 2026-09-17 -- goal-directed ranking (OpenSpec change)

**Goal.** Implement `goal-directed-ranking` (the change that turns the notation
work into ordered formalization): a reverse-rank goal shortlist, an
author-designated goal, and a target-conditioned forward rank that recommends the
next buildable prerequisite. Advisory only.

**What was established (closed).**

- **Goal store.** `blocks/ranking.json` (author-reserved) +
  `scripts/ranking.py` (`--set-goal`/`--list`/`--check`/`--report`/
  `--check-report`/`--dry-run`); a goal whose `decided_by` does not begin
  `author:` is refused, and at most one goal is supported.
- **Goal proposal (reverse rank).** PageRank on the impact graph (dependency ->
  user) with restart mass over result-bearing blocks. On the real graph the
  shortlist tops `B-P035`, `B-P038`, `B-P015` - the headline results - and the
  report labels it a *size* proxy (largest supporting foundation), not a value
  judgement.
- **Next step (forward rank).** Restrict to the goal's ancestor set, PageRank
  conditioned on the goal (goal excluded), and recommend the highest-ranked
  ancestor that is undone and ready. `done(a)` = `a` mapped in
  `lean/declarations.json`; `ready(b)` = every dependency target of `b` done.
- **Weighted graph.** All confirmed *and* candidate edges; source weights
  explicit 1.0 > prose 0.5 > symbol 0.3; edges disposed `type-carrier`/
  `simplification` excluded; unresolved edges named. Advisory: no closure, layer
  status, or evidence record changes.
- **Tests and view.** `scripts/ranking_test.py` (store author-reservation, edge
  weighting, disposition exclusion, determinism, advisory, goal-excluded
  recommendation, readiness, ancestor restriction, unresolved naming, headline
  shortlist) and a drift-checked `reports/ranking.md`; the three checks are
  wired into the fast gate.
- **Bundle gap fixed.** `scripts/bundle.py` now hashes `blocks/notation.json`
  (the gap left by Session 83) plus `blocks/ranking.json`, and embeds
  `reports/ranking.md`.
- **OpenSpec.** proposal/specs/design complete; 16/16 tasks; `--strict` valid.

**Findings.**

- Reverse PageRank on a DAG ranks by supporting-subtree size, so the shortlist
  reads as "the biggest theorem by dependency count", not "the most valuable";
  the author designates the goal and the report states it adopts nothing
  automatically.
- With no goal recorded the report is **Undecided**; the tool is dormant until
  an author goal exists. A probe goal `B-P035` recommended `B-P006`.
- Deep prerequisite ties fall through to a block-id tie-break (cost/risk
  weighting is a design open question).

**Gate.** `scripts/check_all.sh`: **43 passed, 0 failed** (Session 84).

**Honestly deferred / author-reserved.**

- No goal is designated yet (author decision); the ranking awaits it.
- The 113 recovered candidate edges remain unconfirmed and their evidence
  re-issue is deferred (Session 83).

**Prioritized next steps.**

1. Author designates a goal (`python3 scripts/ranking.py --set-goal ...`) to
   activate the ranking.
2. Edge confirmation + evidence re-issue for the 113 candidates.
3. `\Sub` context rule (`dependencies/notation` amendment).

---

## Session 85 -- 2026-09-17 -- multi-goal ranking (OpenSpec change)

**Goal.** Extend `scheduling/ranking` so the author's goal is a *set*, not a
single block, and record the author's goal (both Eilenberg theorems). Implement
`multi-goal-ranking`.

**What was established (closed).**

- **Goal set store.** `validate` no longer caps at one goal; `--set-goal`
  adds/updates and a new `--remove-goal` removes (both author-reserved).
- **Forward rank over the set.** Restart mass is spread over the designated
  goals; the ranking covers the union of their ancestor sets, and the report
  names, per ranked block, which designated goals it contributes to.
- **Mid-implementation spec amendment (author option 1).** A *terminal* goal (a
  designated goal that no other designated goal depends on) is never
  recommended, but a designated goal that is a **prerequisite of another
  designated goal** MAY be. Without this, `B-P020` - a goal and a prerequisite of
  `B-P034` - was wrongly suppressed. Requirement and a new scenario updated in
  the delta and synced to the main spec.
- **Author goal set recorded** (`author:session84`), the two Eilenberg theorems
  as three headline statements:
  - `B-P020` first theorem: `Form_Alg(Σ) ≅ Form_Cgr(Σ)`
  - `B-P034` second (half): `Form_Alg_f(Σ) ≅ Form_Cgr_fi(Σ)`
  - `B-P039` second (half): `Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)`
- **Recommendation.** `reports/ranking.md` recommends **`B-P020`** (ready, score
  0.1667, contributes to `B-P034`); next ready shared foundations `B-D040`
  (`{B-P034, B-P039}`) and `B-D042`.
- **Tests.** Extended for two goals, add/remove, agent refusal, shared
  prerequisite, per-goal column, and the prerequisite-goal recommendation;
  `ranking_test` green.
- **OpenSpec.** proposal/specs/design/tasks complete; archived to
  `openspec/changes/archive/2026-09-17-multi-goal-ranking/`; main spec
  `scheduling/ranking` synced; `openspec validate --specs` 8 passed, 0 failed.
- **Bundle** regenerated (`blocks/ranking.json` + `reports/ranking.md` embedded).

**Findings.**

- The reverse-rank top pick `B-P035` ("Def1FRL and Def2FRL are equivalent") is a
  large *supporting* proposition, not a headline - the size proxy surfaced it,
  confirming that author designation is the correction. The paper's Eilenberg
  theorems are `B-P020`, `B-P034`, `B-P039`.
- The second theorem's two halves (`B-P034`, `B-P039`) are mutually independent,
  but `B-P034` uses the first theorem (`B-P020`) - so a single goal was
  insufficient and a goal set was required.
- Excluding *all* designated goals from the recommendation hid a valid next step;
  the terminal/prerequisite distinction fixes it.

**Gate.** `scripts/check_all.sh`: **43 passed, 0 failed** (Session 85).

**Honestly deferred / author-reserved.**

- The 113 recovered candidate edges remain unconfirmed; evidence re-issue is
  deferred (Session 83).
- `\Sub` context rule (`dependencies/notation` amendment).
- Cost/risk weighting and a per-goal separate recommendation (design open
  questions).

**Prioritized next steps.**

1. Formalize `B-P020` (the ranking's recommendation; all its prerequisites are
   mapped), then the shared foundations `B-D040`/`B-D042` or `B-P020`'s sequel
   toward `B-P034`/`B-P039`.
2. Edge confirmation + evidence re-issue for the 113 candidates.
3. `\Sub` context rule (`dependencies/notation` amendment).

---

## Session 86 -- 2026-09-17 -- free-algebra universal property (`Mslang.Term`)

**Goal.** Take the first infrastructure step toward `B-P020` (the ranking's
recommendation) after reconnaissance showed the word-based free algebra cannot
support its proof.

**Reconnaissance (blocker found).** `B-P020`'s mapped prerequisites all exist
(`IsCongruenceFormation`, `IsAlgebraFormation`, `HOperator`/`PFsdOperator`,
`formationGenerating`, `formation_congInf`, `quotAlg_ker_isAlgIso`, ...), but the
proof needs facts the development lacks: the free universal property's
*existence* half, projectivity of the free algebra, and quotient-of-a-quotient /
coproduct facts. `TAlg` (`Free.lean`) is a `Sg`-generated subalgebra of `W_Σ(X)`
and `MemSg` is a `Prop`, so it supports only the uniqueness half
(`TAlg_hom_ext`); a data-valued recursor is required. **Finding:** the ranking's
`done`/`ready` predicate (a block mapped, its prerequisites mapped) is necessary
but not sufficient - `B-P020` is dependency-ready but not proof-ready, the first
case of the `STATE.md` Session 53 caveat.

**What was established (closed).**

- **New module `lean/Mslang/Term.lean`** (imports `Mslang.Free`): the free
  `Σ`-algebra `Term_Σ(X)` as an inductive `Type` with a recursor.
  - `Term`, `termAlg`, `termEta`.
  - **Free universal property (existence and uniqueness):** `termLift`,
    `termLift_isAlgHom`, `termLift_eta`, `termLift_unique`.
  - **Every algebra is a quotient of a free algebra:** `termEval`,
    `termEval_isAlgHom`, `termEval_surjective`.
  - **Projectivity of the free algebra:** `term_projective`.
- Wired into the library: `import Mslang.Term` and five `#print axioms` lines in
  `lean/Mslang.lean`; a `Mslang/Term.lean` row in the `Architecture.md` §10.2
  module table; the safe-restart module list updated.
- **Gate.** `scripts/lean_audit.py`: 223 declarations, 0 warnings, 0 `sorry`,
  `ok=True`. `scripts/check_all.sh`: **43 passed, 0 failed**.

**Honestly deferred (not started).**

- `B-P020` itself: still needs the round trips `F = F_{𝔉_F}` and
  `𝔉 = 𝔉_{F_𝔉}` built on `termEval_surjective` and `term_projective`, an
  isomorphism connecting `Term` to the word-based `TAlg`, and the
  quotient/coproduct facts.
- No block was formalized and no evidence record was created: this module is
  infrastructure (like `isAlgIso_symm`), so it carries no block and no layer.

**Prioritized next steps.**

1. Connect `Term` to `TAlg` (`Term_Σ(X) ≅ T_Σ(X)`) so both presentations are
   interchangeable.
2. Define `𝔉_F` and `F_𝔉`; prove the round trips with
   `termEval_surjective`/`term_projective`.
3. Then `B-P020` and `B-C006`, and the free-algebra cluster
   (`B-P010`-`B-P015`, `B-C003`) that the term characterization also unblocks.

---

## Session 87 -- 2026-09-18 -- free-algebra encoding adopted (B-P011/B-P012/B-P013)

**Goal.** Unblock the author's designated goal `B-P020` by adopting the inductive
`Term_Σ(X)` as the encoding of the free `Σ`-algebra (author decision **Option
1**), after recon showed the row presentation's universal property is exactly the
deferred `B-P010` (unique parsing).

**What was established (closed).**

- **The canonical comparison map.** `lean/Mslang/Term.lean` gained
  `toT : Term_Σ(X) → T_Σ(X)` (extends `η^X`), `toT_isAlgHom`, `toT_eta`, and
  `toT_surjective` (the image is a subalgebra of `W_Σ(X)` containing `genSet`, so
  it contains `Sg(genSet) = T_Σ(X)`). `toT` **injectivity is `B-P010` (unique
  parsing), recorded as the open bridge** between the row and inductive
  presentations; it is not needed once `Term_Σ` is the encoding.
- **`B-P011`** (free-algebra universal property, existence + uniqueness) added as
  `termLift` / `termLift_isAlgHom` / `termLift_eta` / `exists_unique_termLift`
  (`∃! f, IsAlgHom … ∧ f ∘ termEta = g`). Axioms `{Quot.sound}`.
- **`B-P012`** (projectivity) added as `term_projective`; axioms
  `{Classical.choice, Quot.sound}`.
- **`B-P013`** (every algebra is isomorphic to a quotient of a free algebra) added
  as `termEval` / `termEval_isAlgHom` / `termEval_surjective`; axiom-free. The
  correspondence comparator judged the surjection `Term_Σ(A) ↠ A` equivalent to
  the contract via `B-P017`'s `quotAlg_ker_isAlgIso` (first isomorphism theorem),
  so no separate quotient/iso declaration was needed.
- **`B-D027` now spans modules.** It maps to both presentations — the row
  declarations (`genSet`, `TAlg`, `TSet`, `etaX`, `Free.lean`) and the inductive
  ones (`Term`, `termAlg`, `termEta`, `Term.lean`). To support this,
  `scripts/lean_facets.py` gained a per-declaration **`decl_files`** override
  (multi-file blocks); `file` remains the primary file.
- **`B-L001` remapped** (class C5) from `TAlg_hom_ext` (row) to
  `termLift_unique` (inductive).
- **Evidence.** Reissues: `E-000165` (B-D027 verification, supersedes
  `E-000111`), `E-000166`/`E-000167` (B-L001 verification/correspondence,
  supersede `E-000114`/`E-000115`, `remap`). New: `E-000168`..`E-000173`
  (verification + correspondence for `B-P011`/`B-P012`/`B-P013`; both
  correspondences `equivalent`, two-stage blind; transcripts
  `blocks/audits/{B-P011,B-P012,B-P013}-correspondence.md`, and a dated re-run
  section in `B-L001-correspondence.md`).
- `blocks/lean_audit.json`: **234 declarations, 0 warnings, 0 unpermitted, 0
  `sorry`, ok=True**. `scripts/check_all.sh` (slow): **43 passed, 0 failed**.
  Journal `EV-000097`.

**Honest caveat.** Same-model audit (all stages `deepseek-v4.1-flash`; layers
report `provisional`). `Term_Σ ≅ T_Σ` is not proved — only the surjection `toT`;
`B-P010`, `B-C003`, and the term characterization remain open. The
free-algebra encoding choice (both presentations under `B-D027`) is the author's
Option 1.

**Prioritized next steps.**

1. `B-P020` (the ranking's recommendation): define `𝔉_F`/`F_𝔉` on `Term_Σ` and
   prove the round trips using `exists_unique_termLift`, `term_projective`,
   `termEval_surjective` — its two free-algebra inputs now exist.
2. The `B-P034`/`B-P039` finite-index halves (share `B-D040`, `B-D042`).
3. Optional: prove `toT` injective (`B-P010` unique parsing) to close the
   row/inductive bridge; and a second model to clear `provisional`.

---

## Session 88 -- 2026-09-18 -- B-P019 (`𝔉_F` is a congruence formation)

**Goal.** First step toward `B-P020`: formalize `B-P019`, which builds the
congruence formation `𝔉_F` from an algebra formation `F` — the object whose
lattice is the right-hand side of the Eilenberg isomorphism.

**What was established (closed).**

- **`B-P019`** in `lean/Mslang/Formation.lean`:
  - `congruenceFormationOf Sig F A = {Φ | IsCongruence Sig (termAlg Sig A).2 Φ ∧
    quotAlg Sig (termAlg Sig A).2 Φ hΦ ∈ F}` (the `∃ hΦ` Σ-form, since
    `IsCongruence` is a proposition);
  - `congruenceFormation_isCongruenceFormation : IsAlgebraFormation Sig F →
    IsCongruenceFormation Sig (congruenceFormationOf Sig F)`.
  - Proof: **non-empty** `∇^{T_Σ(A)}` (`quot_nabla_subfinal` + `B-R017`
    `subfinalAlg_mem_of_formation`); **meet-closure** `B-P016`
    `formation_congInf`; **up-closure** the induced `quotLift`
    `T_Σ(A)/Φ ↠ T_Σ(A)/Ψ` is a surjective hom, so `HOperator` closure applies;
    **formation clause** `quotAlg_ker_isAlgIso` (`B-P017`) plus
    `formation_mem_of_iso`. Axioms
    `{Classical.choice, Quot.sound, propext}`.
- **`B-D030` re-based on the adopted encoding.** `IsCongruenceFormation` now
  uses `Term`/`termAlg` (the adopted free algebra) instead of `TAlg`; its content
  is unchanged (`T_Σ(A)` is the same object). `Formation.lean` now imports
  `Mslang.Term` (which imports `Free`, so `W_Σ`/`TAlg` remain available).
- Evidence: **`E-000174`** (B-D030 verification, supersedes `E-000117`,
  `reissue_reason: other`), **`E-000175`** (B-P019 verification),
  **`E-000176`** (B-P019 correspondence, `equivalent`; two-stage blind;
  transcript `blocks/audits/B-P019-correspondence.md`).
- `blocks/lean_audit.json`: **236 declarations, 0 warnings, 0 unpermitted, 0
  `sorry`, ok=True**. `check_all.sh` (slow): **43 passed, 0 failed**. Journal
  `EV-000098`. Frontier unmapped **50 -> 49**; ranking still recommends
  `B-P020`.

**Engineering gotcha.** `rw`/`▸` matching at Lean's `implicit` transparency does
not unfold `termAlg` to see `(termAlg Sig A).1 = Term Sig A`, so `rw [ker_prAlg]`
failed; the fix is `(congrArg (fun R => …) hk).symm.mp hle` (a `Prop`-level
transport) instead of rewriting under the quotient term. Also `HOperator`'s
witness starts with the *source* algebra.

**Honest caveat.** Same-model audit (`provisional` layer). `B-D030`'s encoding
change is the same representation decision as Session 87 (adopt `Term`); the
`Term ≅ T_Σ` equivalence remains the open `B-P010` bridge.

**Prioritized next steps.**

1. `B-P020`: define `F_𝔉` (the algebras isomorphic to a quotient `T_Σ(A)/Φ` with
   `Φ ∈ 𝔉(A)`) and prove `F = F_{𝔉_F}`, `𝔉 = 𝔉_{F_𝔉}`, then the complete-lattice
   isomorphism, using `B-P013` (`termEval_surjective`) and `B-P019`.
2. `B-C005` (the two formation lattices are algebraic): the `CompleteLattice`
   structure on `algebraFormations`/congruence formations.
3. The `B-P034`/`B-P039` finite-index halves (shared foundations `B-D040`,
   `B-D042` are ready).

---

## Session 89 -- 2026-09-18 -- B-P020 round trips (`F_𝔉` infrastructure)

**Goal.** Continue toward `B-P020`: the maps `θ_Σ : F ↦ 𝔉_F` and
`θ_Σ⁻¹ : 𝔉 ↦ F_𝔉` and the round trips that make them mutually inverse.

**What was established (closed; infrastructure, no block mapped).**

- `lean/Mslang/Formation.lean` gained:
  - `algebraFormationOfCongruenceFormation Sig G` — the direct image `F_𝔉`, the
    `Σ`-algebras isomorphic to a quotient `T_Σ(A)/Φ` with `Φ ∈ G(A)`;
  - helpers `pr_surjective` (the projection `pr^Φ` is surjective) and
    `ker_comp_of_injective` (`Ker(f ∘ h) = Ker(h)` for injective `f`);
  - **first round trip** `algebraFormationOfCongruenceFormation_congruenceFormationOf`:
    `F_{𝔉_F} = F` for an algebra formation `F`. `⊆` uses `B-P013`
    (`termEval_surjective` + `quoAlg_ker_isAlgIso`), `⊇` uses abstractness
    (`formation_mem_of_iso`).
  - **second round trip** `congruenceFormationOf_algebraFormationOfCongruenceFormation`:
    `𝔉_{F_𝔉} = 𝔉` for a congruence formation `𝔉`. The `⊆` direction is the
    substantive one: a quotient `T_Σ(A)/Φ ∈ F_𝔉` comes from `T_Σ(B)/Ψ` with
    `Ψ ∈ 𝔉(B)`; **projectivity of the free algebra (`B-P012` `term_projective`)**
    lifts the isomorphism to `g : T_Σ(A) → T_Σ(B)` with `pr^Ψ ∘ g = f ∘ pr^Φ`;
    the formation clause of `B-P019` gives `Ker(pr^Ψ ∘ g) ∈ 𝔉(A)`, and
    `Ker(pr^Ψ ∘ g) = Φ` because the isomorphism is injective
    (`ker_comp_of_injective`, `ker_prAlg`).
- Build clean; `scripts/check_all.sh` (slow): **43 passed, 0 failed**. Only
  `lean/Mslang/Formation.lean` changed, so no facet, evidence, or derived view
  moved (the declarations are unmapped infrastructure, like `Term.lean` in
  Session 86).

**Finding that changes the plan.** The companion of `B-P019` is a *separate
block*: the manuscript's **`B-P015`** states that `F_𝔉` is a formation
(nonempty, abstract, `H`-closed, `P_fsd`-closed), with the `P_fsd` direction
using projectivity and a finite intersection of kernels. `B-P020`'s
"complete lattices are isomorphic" needs `B-P015` (so `θ⁻¹` maps into
`Form_Alg(Σ)`) plus the lattice/order packaging. So the frontier order is
`B-P015` before `B-P020`, not `B-P019`'s round trips directly.
`B-P015` is already in the author's "worth-formalizing" triage.

**Engineering gotcha (recurring).** Lean's `rw`/`▸` matching at `implicit`
transparency does not unfold `termAlg` to see `(termAlg Sig A).1 = Term Sig A`.
Fixes used: `congrArg`-transported equalities (`(congrArg … hk).symm.mp hle`),
`congrArg ker hg_comp`, explicit `AlgStruct Sig (Term Sig A)` binders for
`FA`/`FB`, and `Eq.trans` chains instead of rewriting under `termAlg`.

**Honest caveat.** The two round trips are proved but **not mapped**. `F_𝔉` is
not yet shown to be an algebra formation (that is `B-P015`), and `B-P020`'s
complete-lattice isomorphism is not yet stated; both remain open.

**Prioritized next steps.**

1. `B-P015`: `F_𝔉` is a nonempty abstract formation (`H`-closure via
   `B-P019`'s up-closure; `P_fsd`-closure via `B-P012` projectivity, a finite
   intersection of kernels, and the subdirect-embedding argument). Then map it.
2. `B-P020`: package the round trips + order preservation as the lattice
   isomorphism (needs a `CompleteLattice`/`OrderIso` on the two formation
   families; related to `B-C005`).
3. `B-C005` (`Form_Alg(Σ)` is an algebraic lattice).

---

## Session 90 -- 2026-09-18 -- B-P015 (`F_𝔉` is a formation of algebras)

**Goal.** Complete `B-P015`, the companion of `B-P019` and the prerequisite for
`B-P020`: if `𝔉` is a congruence formation, the direct image
`F_𝔉 = {C | ∃ A, ∃ Φ ∈ 𝔉(A), C ≅ T_Σ(A)/Φ}` is a formation of `Σ`-algebras.

**What was established (closed, and mapped).**

- `lean/Mslang/Formation.lean` (`B-P015`):
  - `algebraFormationOfCongruenceFormation Sig G` — the direct image `F_𝔉`;
  - `..._nonempty` (`1 ≅ T_Σ(1)/∇`, `∇ ∈ G(1)` by up-closure);
  - `..._abstract` (composition of isomorphisms; the helper `isAlgIso_comp`);
  - `..._HOperator` (`H(F_𝔉) ⊆ F_𝔉`): an epimorphism `C ↠ D` composes with
    `T_Σ(A) ↠ C`; the kernel contains `Φ`, so up-closure of `𝔉(A)` + the first
    isomorphism theorem put `D ∈ F_𝔉`;
  - `..._PFsdOperator` (`P_fsd(F_𝔉) ⊆ F_𝔉`): a finite subdirect product `A` of
    `C^i ≅ T_Σ(A^i)/Φ^i` is a quotient of `T_Σ(B)` (`B = A`, `g = termEval`);
    **projectivity (`B-P012`) lifts each `pr^i ∘ f ∘ g`** to
    `h^i : T_Σ(B) → T_Σ(A^i)`; the `B-P019` formation clause puts
    `Ker(pr^{Φ^i} ∘ h^i) ∈ 𝔉(B)`, hence their finite meet (`Finset.inf`
    induction over closure under binary meets + nonemptiness); the meet refines
    `Ker(g)` because the `f(g ·)`-images agree on every projection and `f` is
    injective; first isomorphism theorem concludes.
- Mapping: `B-P015` -> the above five declarations. Evidence **`E-000177`**
  (verification) and **`E-000178`** (correspondence; two-stage blind; verdict
  **`formal_stronger`** — abstractness is proved for arbitrary `G`, a positive
  strict generalization, recorded not `equivalent`; transcript
  `blocks/audits/B-P015-correspondence.md`).
- `blocks/lean_audit.json`: **241 declarations, 0 warnings, 0 unpermitted, 0
  `sorry`, ok=True**. `check_all.sh` (slow): **43 passed, 0 failed**. Journal
  `EV-000098` (round trips) / `EV-000099` (B-P015). Frontier unmapped
  **49 -> 48**.

**Engineering gotcha (recurring, now with a standard set of fixes).** Lean's
`rw`/`simpa`/`▸` at `implicit` transparency does not unfold `termAlg`/`Phi`
to see carrier equalities. Standard fixes: bind the structure with an explicit
carrier (`let FA : AlgStruct Sig (Term Sig A) := (termAlg Sig A).2`); use
`Eq.trans`/`congrArg`-transported equalities instead of rewriting under
`termAlg`; use `Pi.le_def.mp` + `Setoid.le_def.mp` to turn `Finset.inf_le`'s
`≤` into a pointwise implication; reduce beta-redexes in `obtain`ed hypotheses
(`have ha' : f s a i = c := by simpa using ha`).

**B-P020 readiness.** `θ_Σ : F ↦ 𝔉_F` is well-defined by `B-P019`; `θ_Σ⁻¹ : 𝔉 ↦ F_𝔉`
is well-defined by `B-P015`; the round trips (`F_{𝔉_F} = F`, `𝔉_{F_𝔉} = 𝔉`) are
proved (Session 89). Remaining for `B-P020`: package these as the complete-lattice
isomorphism (order preservation + the `CompleteLattice`/`OrderIso` on the two
formation families, related to `B-C005`).

**Prioritized next steps.**

1. `B-P020`: state and prove the lattice isomorphism from `B-P019` + `B-P015` +
   the two round trips (order preservation is straightforward; completeness via
   `B-P018`/`B-C005`).
2. `B-C005` (`Form_Alg(Σ)` is an algebraic lattice) if the `CompleteLattice`
   packaging is built there first.
3. The `B-P034`/`B-P039` finite-index halves.

---

## Session 91 -- 2026-09-18 -- B-P020 (first Eilenberg theorem)

**Goal.** Package the Session 89 round trips and `B-P015` into `B-P020`:
`Form_Alg(Σ) ≅ Form_Cgr(Σ)`.

**What was established (closed, and mapped).**

- `lean/Mslang/Formation.lean` (`B-P020`):
  - `congruenceFormations Sig` — the family `Form_Cgr(Σ)` of congruence
    formations;
  - `algebraFormationOfCongruenceFormation_isAlgebraFormation` —
    `F_𝔉` is an algebra formation when `𝔉` is a congruence formation (from
    `B-P015`'s H/P_fsd closures), so `θ_Σ⁻¹` is well-defined;
  - `congruenceFormationOf_mono` / `algebraFormationOfCongruenceFormation_mono`
    (order preservation);
  - `thetaSigma` (`F ↦ 𝔉_F`), `thetaSigmaInv` (`𝔉 ↦ F_𝔉`), with
    `thetaSigma_left_inv`/`_right_inv` from the two round trips;
  - **`formAlgFormCgrIso : algebraFormations Sig ≃o congruenceFormations Sig`**
    — the order isomorphism (`map_rel_iff'` from the monotonicity lemmas and the
    round trips).
- Mapping: `B-P020` → the above (plus the Session 89 round-trip declarations).
  Evidence **`E-000179`** (verification) and **`E-000180`** (correspondence;
  two-stage blind; verdict **`equivalent`** — an order isomorphism between
  complete lattices is a complete-lattice isomorphism, and completeness of
  `Form_Alg(Σ)` is the separate `B-P018` closure-system result; transcript
  `blocks/audits/B-P020-correspondence.md`).
- **Tooling fix.** `scripts/lean_audit.py`'s `AXIOM_RE` could not parse
  `#print axioms` output whose list wraps across lines for long names (the three
  longest `B-P020` names produced no report, `ok=False`); `parse_axioms` now
  accumulates continuation lines, with a regression check in
  `scripts/lean_audit_test.py` (10 checks).
- `blocks/lean_audit.json`: **252 declarations, 0 warnings, 0 unpermitted, 0
  `sorry`, ok=True**. `check_all.sh` (slow): **43 passed, 0 failed**. Journal
  `EV-000100`. Frontier unmapped **48 -> 47**.

**Honest caveat.** The Lean statement is an `OrderIso` of the two formation
families; it does **not** itself construct the `CompleteLattice` structures
(completeness of `Form_Alg(Σ)` is `B-P018`, and `Form_Cgr(Σ)`'s follows by
transport). The comparator judged this `equivalent` for exactly that reason, but
the explicit lattice structures (and `B-C005`'s algebraic-lattice statement)
remain separate, open blocks. Same-model audit (`provisional` layer).

**Prioritized next steps.**

1. `B-C005` (`Form_Alg(Σ)` is an algebraic lattice) and `B-C006`
   (`Form_Cgr(Σ)` is an algebraic lattice, from `B-C005` + `B-P020`) — the
   lattice-structure statements behind the isomorphism.
2. The second Eilenberg theorem's two halves: `B-P034`
   (`Form_Alg_f(Σ) ≅ Form_Cgr_fi(Σ)`) and `B-P039`
   (`Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)`), whose shared foundations `B-D040`,
   `B-D042` are ready.
3. Optional: prove `toT` injectivity (`B-P010`, unique parsing) and declare a
   second model to clear `provisional` layers.

---

## Session 92 -- 2026-09-18 -- second Eilenberg layer: finite index and languages

**Goal.** Open the second Eilenberg theorem's layer (author goals `B-P034`,
`B-P039`): finite-index congruences, finite algebras, and regular languages.

**What was established (closed, and mapped).**

- **New module `lean/Mslang/Regular.lean`** (imports `Formation` and `Translation`;
  added to `Mslang.lean` and the `Architecture.md` module table):
  - **`B-D040`**: `IsFiniteIndex Φ := FiniteSSet (quot Φ)` and
    `congFi Sig F = {Φ | IsCongruence Sig F Φ ∧ IsFiniteIndex Φ}` (`Cgr_fi(A)`);
  - **`B-D041`**: `IsFiniteIndexCongruenceFormation` /
    `finiteIndexCongruenceFormations` (`Form_Cgr_fi(Σ)`);
  - **`B-D042`**: `algebraFinite Sig = Alg_f(Σ)`;
  - **`B-D043`**: `IsFiniteAlgebraFormation` / `finiteAlgebraFormations`
    (`Form_Alg_f(Σ)`);
  - **`B-D044`**: `IsRegularLanguage Sig A L := IsFiniteIndex (congCogenerated
    Sig A L)` and `regularLanguages` (`Lang_r(A)`);
  - **`B-P031`**: `congFi_filter` — when `supp_S(A)` is finite, `Cgr_fi(A)` is a
    filter (non-empty, meet-closed, up-closed among congruences), via the
    quotient-finiteness lemmas `isFiniteIndex_nabla`, `IsFiniteIndex_of_le`,
    `IsFiniteIndex_inf` and the canonical surjection `quotLe`.
- Evidence: `E-000181`..`E-000185` (verifications; definitions carry the
  verification layer only), `E-000186`/`E-000187` (B-P031 verification +
  correspondence, two-stage blind, **`equivalent`**; transcript
  `blocks/audits/B-P031-correspondence.md`).
- `blocks/lean_audit.json`: **267 declarations, 0 warnings, 0 unpermitted, 0
  `sorry`, ok=True**. `check_all.sh` (slow): **43 passed, 0 failed**. Journal
  `EV-000101`. Frontier unmapped **47 -> 41**.

**Honest caveat.** Same-model audit (`provisional`). The definitions use the
blanket `supp_S(A)`-finiteness hypothesis only where the manuscript does; the
support hypothesis for the free algebras (used later in the section) is not yet
threaded. `IsRegularLanguage` records the finite-index condition; the supporting
`supp`-finiteness is a hypothesis of the propositions, not of the definition.

**Prioritized next steps.**

1. `B-P032` (`Form_Cgr_fi(Σ)` is a complete lattice) and `B-P033`
   (`Form_Alg_f(Σ)` is an algebraic closure system), then `B-P034`
   (`Form_Alg_f(Σ) ≅ Form_Cgr_fi(Σ)`, the second Eilenberg theorem's first half).
2. `B-D045`/`B-D046` (formations of regular languages) and `B-P035`-`B-P039`
   (the second half, `Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)`).
3. `B-C005`/`B-C006` (the algebraic-lattice structures).

---

## Session 93 -- 2026-09-18 -- B-P034 (second Eilenberg theorem, first half)

**Goal.** Restrict the `B-P020` isomorphism to the finite-index / finite-algebra
subfamilies: `Form_Alg_f(Σ) ≅ Form_Cgr_fi(Σ)`.

**What was established (closed, and mapped).**

- `lean/Mslang/Regular.lean` (`B-P034`):
  - `finiteSSet_of_isAlgIso` — finiteness transfers along a sortwise bijection;
  - `congruenceFormationOf_isFiniteIndex` — if `F ⊆ Alg_f(Σ)` then every
    `Φ ∈ 𝔉_F(A)` has finite index (`T_Σ(A)/Φ ∈ F`);
  - `algebraFormationOfCongruenceFormation_isFiniteAlgebra` — if every `G(A)`
    consists of finite-index congruences then `F_𝔉 ⊆ Alg_f(Σ)`;
  - **`formAlgFFormCgrFiIso : finiteAlgebraFormations Sig ≃o
    finiteIndexCongruenceFormations Sig`** — the bi-restriction of `θ_Σ`, with
    the inverse laws from the `B-P020` round trips and inclusion-reflection from
    monotonicity.
- Evidence **`E-000188`** (verification), **`E-000189`** (correspondence,
  two-stage blind, **`equivalent`**; transcript
  `blocks/audits/B-P034-correspondence.md`).
- `lean_audit`: **271 declarations, 0 warnings, 0 unpermitted, 0 `sorry`**.
  `check_all.sh` (slow): **43 passed, 0 failed**. Journal `EV-000102`. Frontier
  **41 -> 40**.

**Honest caveat.** Same-model audit (`provisional`). As with `B-P020`, the Lean
statement is an order isomorphism (the lattice structures are separate);
well-definedness composes the earlier `B-P019`/`B-P015`/`B-P020` results.

**Prioritized next steps.**

1. `B-P032` (`Form_Cgr_fi(Σ)` is a complete lattice) and `B-P033`
   (`Form_Alg_f(Σ)` is an algebraic closure system) — the lattice structures.
2. `B-D045`/`B-D046` (formations of regular languages) and `B-P035`-`B-P039`
   (the second half: `Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)`).
3. `B-C005`/`B-C006` (the algebraic-lattice structures).

---

## Session 94 -- 2026-09-18 -- B-P030 (`L_𝔉`, gateway to the second half)

**Goal.** Formalize the congruence-formation-to-language-formation construction,
the prerequisite for the second half of the second Eilenberg theorem.

**What was established (closed, and mapped).**

- `lean/Mslang/Regular.lean` (`B-P030`, `Cong2LangBasic`):
  - `langFormationOf Sig G A = {L | Ω^{T_Σ(A)}(L) ∈ G A}`;
  - `mem_langFormationOf_iff` — equals the `∃ Φ ∈ G A, L = [L]^Φ`
    (`Φ`-saturated) presentation;
  - `langFormationOf_nabla` — every `∇`-saturated language lies in the family
    (so `∅` and `T_Σ(A)` do);
  - `langFormationOf_inf` — `(Ω(L) ∩ Ω(L'))`-saturated languages lie in the
    family;
  - `langFormationOf_ker` — for `M ∈ L_𝔉(B)` and an `Ω(M)`-epimorphism
    `f : T_Σ(A) → T_Σ(B)`, `Ker(pr^{Ω(M)} ∘ f)`-saturated languages lie in the
    family.
  Proofs use `isSat_iff_le_congCogenerated` (`B-P023`), `congCogenerated_isCongruence`
  (`B-P022`), `IsCongruence_inf`, `sortedEqvLe_antisymm`, and the filter/formation
  clauses of `G`.
- Evidence **`E-000190`** (verification), **`E-000191`** (correspondence,
  two-stage blind, **`equivalent`**; transcript
  `blocks/audits/B-P030-correspondence.md`).
- `lean_audit`: **276 declarations, 0 warnings, 0 unpermitted, 0 `sorry`**.
  `check_all.sh` (slow): **43 passed, 0 failed**. Journal `EV-000103`. Frontier
  **40 -> 39**.

**Honest caveat.** Same-model audit (`provisional`). The `∅`/`T_Σ(A)` special
case is a corollary of the `∇` clause, not separately stated.

**Prioritized next steps.**

1. `B-D045`/`B-D046` (the two definitions of formation of regular languages) and
   `B-P035` (they are equivalent).
2. `B-P037` (`𝔉 ↦ L_𝔉` lands in regular-language formations) and `B-P038`
   (`L ↦ 𝔉_𝔏` lands in finite-index congruence formations), then `B-P039`
   (`Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)`), completing the second theorem.
3. `B-P032`/`B-P033` and `B-C005`/`B-C006` (the lattice structures).

---

## Session 95 -- 2026-09-18 -- B-D045/B-D046 (regular-language formations)

**Goal.** The two definitions of "formation of regular languages" (equivalent by
`B-P035`), prerequisites for the second half of the second Eilenberg theorem.

**What was established (closed, and mapped).**

- `lean/Mslang/Regular.lean`:
  - **`B-D045`** (`Def1FRL`): `IsRegularLanguageFormation Sig L` =
    `L(A) ⊆ Lang_r(T_Σ(A))`, closed under `∇`-, `(Ω(L) ∩ Ω(L'))`- and
    `Ker(pr^{Ω(M)} ∘ f)`-saturation; `regularLanguageFormations Sig`
    (`Form_Lang_r(Σ)`);
  - **`B-D046`** (`Def2FRL`): `IsBPSLanguageFormation Sig L` = `L(A) ⊆ Lang_r`,
    `∇`-saturated languages, closure under inverse images of translations
    (`transPreimage T X`), Boolean closure (union, intersection, `complA`), and
    closure under `f⁻¹[M]` along `Ω(M)`-epimorphisms; `bpsLanguageFormations Sig`.
- Evidence **`E-000192`** (`B-D045`), **`E-000193`** (`B-D046`), verifications
  (definitions carry the verification layer only).
- `lean_audit`: **280 declarations, 0 warnings, 0 unpermitted, 0 `sorry`**.
  `check_all.sh` (slow): **43 passed, 0 failed**. Journal `EV-000104`. Frontier
  **39 -> 37**.

**Honest caveat.** The `Lang_r` condition uses `IsRegularLanguage` =
finite-index (the manuscript's finite-support hypothesis on `T_Σ(A)` is the
section's blanket assumption `B-A001`, not threaded through the definition).

**Prioritized next steps.**

1. `B-P035` (the two definitions are equivalent).
2. `B-P037` (`𝔉 ↦ L_𝔉` lands in `Form_Lang_r`), `B-P038`
   (`L ↦ 𝔉_𝔏` lands in `Form_Cgr_fi`), then `B-P039`
   (`Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)`), completing the second theorem.
3. `B-P032`/`B-P033`, `B-C005`/`B-C006` (lattice structures).

---

## Session 96 -- 2026-09-18 -- B-P037 (`𝔉 ↦ L_𝔉` is a language formation)

**Goal.** The forward direction of the second-Eilenberg isomorphism: a
finite-index congruence formation yields a regular-language formation.

**What was established (closed, and mapped).**

- `lean/Mslang/Regular.lean` (`B-P037`, `Cong2LangEnFinit`):
  `langFormationOf_isRegularLanguageFormation : IsFiniteIndexCongruenceFormation
  Sig G → IsRegularLanguageFormation Sig (langFormationOf Sig G)`. The regularity
  clause is `(hG.2 A hL).2` (`Ω(L) ∈ 𝔉(A)` has finite index); the three closure
  clauses are `B-P030`'s `langFormationOf_nabla`/`_inf`/`_ker` under `hG.1`.
- Evidence **`E-000194`** (verification), **`E-000195`** (correspondence,
  two-stage blind, **`equivalent`**; transcript
  `blocks/audits/B-P037-correspondence.md`).
- `lean_audit`: **281 declarations, 0 warnings, 0 unpermitted, 0 `sorry`**.
  `check_all.sh` (slow): **43 passed, 0 failed**. Journal `EV-000105`. Frontier
  **37 -> 36**.

**Honest caveat.** Same-model audit (`provisional`).

**Prioritized next steps.**

1. `B-P038` (`Lang2CongEnFinit`): `L ↦ 𝔉_𝔏` — the converse direction. Its
   meet-closure step represents a finite-index `Φ ∩ Ψ`-saturated language as a
   finite union of Kronecker deltas, needing `B-C009`/`B-P024`/`B-R020`-style
   machinery (finite decomposition).
2. `B-P039` (`Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)`), combining `B-P037`/`B-P038`
   with `B-P030`-style round trips.
3. `B-P035` (equivalence of the two language-formation definitions), `B-P032`/
   `B-P033`, `B-C005`/`B-C006`.

---

## Session 97 -- 2026-09-18 -- B-P038 (`L ↦ 𝔉_𝔏`, converse direction)

**Goal.** Complete the WIP left by Session 96's successor: the targeted
`lake build Mslang.Regular` for `B-P038` had timed out, so the code was
committed unelaborated. Elaborate it, then run the normal facet/evidence/views
pipeline.

**What was established (closed, and mapped).**

- **Build completed.** The WIP's `Regular.lean` additions (Boolean closure of a
  language formation, class atoms `δ^{s,[a]_Φ}`, the finite decomposition of a
  saturated set, and the `Lang2CongEnFinit` development) had several
  elaboration errors, now fixed:
  - `subst ht` on `t = s` was eliminating `s` and breaking later references
    (use `subst t`); `Set.mem_setOf_eq` deprecated (use `Set.mem_ofPred_eq`);
  - `sortedEqvInf` is `instance_reducible`, so `simp` will not unfold it
    (added `unfold sortedEqvInf`);
  - the subtype predicates of `eq_iUnion_atoms` / `langCongFormationOf_inf`
    wrongly projected `q.1.1`/`q.1.2` where the subtype variable is already the
    `Sigma` (they are `q.1`/`q.2` inside the subtype; `q.1.1`/`q.1.2` are correct
    only in the surrounding proof);
  - `isSat_iff_le_congCogenerated` needed its congruence argument to be `hΘ`,
    and `charEqv`'s `Iff` runs `x ∈ L ↔ y ∈ L`, so the step wanted `.mp`;
  - `(F A).Nonempty` needs an explicit witness, not a membership proof.
  `lake build Mslang.Regular` clean; `lean_audit`: **287 declarations, 0
  warnings, 0 unpermitted, 0 `sorry`**, ok.
- Mapping `B-P038` -> `langCongFormationOf` plus the four closure lemmas and
  `langCongFormationOf_isFiniteIndexCongruenceFormation`; facets regenerated
  (formal graph includes the new edges).
- Evidence **`E-000196`** (verification, `build_ok`) and **`E-000197`**
  (correspondence, **`equivalent`**; two-stage blind; transcript
  `blocks/audits/B-P038-correspondence.md`). The first comparator pass
  (bare proposition, no section assumptions) returned `formal_weaker` on the
  `[Finite S]` hypothesis; a fresh pass with the section's standing assumption
  `B-A001` ("in the remainder of this section `S` is finite") returned
  `equivalent` -- the omission was in the audit prompt, not the formalization.
- `reports/frontier.md`: unmapped blocks **36 -> 35**. Views and bundle
  regenerated. Journal `EV-000106`. `check_all.sh --fast`: **40 passed, 0
  failed**.

**Honest caveat.** Same-model audit as always: the correspondence verdict is
independent-context but shares `deepseek-v4.1-flash`, and inherits the
pilot-encoding residuals (`carrier-model`, `small-large`, `univalence-missing`).

**Prioritized next steps.**

1. `B-P039` (`Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)`), combining `B-P037`/`B-P038`
   with `B-P030`-style round trips, completing the second Eilenberg theorem.
2. `B-P035` (equivalence of the two language-formation definitions).
3. `B-P032`/`B-P033` and `B-C005`/`B-C006` (the lattice structures).

---

## Session 98 -- 2026-09-18 -- B-P039 (second Eilenberg theorem)

**Goal.** Complete the second Eilenberg theorem: `Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)`.

**What was established (closed, and mapped).**

- `lean/Mslang/Regular.lean` (`B-P039`):
  - `sortedEqvInf_self` (idempotence) and `IsCongruenceFormation_finset_inf`
    (a congruence formation is closed under finite meets over any finite index;
    empty case by up-closure of the nonempty witness to `⊤`);
  - `langFormationOf_mono` / `langCongFormationOf_mono` (order preservation of
    the two maps);
  - **first round trip `langCongFormationOf_langFormationOf`**: `𝔉_{L_𝔉} = 𝔉`
    for a finite-index congruence formation. The substantive direction is
    formalized *without* the manuscript's full meet representation
    `Φ = ⋂ Ω(δ^{s,[a]_Φ})`: for `Φ ∈ 𝔉_{L_𝔉}(A)`, each class atom
    `atomOf Φ q` (`q : Σ(A/Φ)`) is `Φ`-saturated, hence lies in `L_𝔉(A)`, hence
    its syntactic congruence is in `𝔉(A)` by up-closure; the **finite** meet over
    the finitely many classes is in `𝔉(A)`; and that meet refines `Φ` because for
    `x` the class `q_x` has `x` in its atom, so `Ω(atomOf Φ q_x)`-relatedness
    forces `Φ`-relatedness. Up-closure then gives `Φ ∈ 𝔉(A)`;
  - **second round trip `langFormationOf_langCongFormationOf`**: `L_{𝔉_𝔏} = L`,
    using the meet clause of `B-D045` at `X = Y = L` to see that every
    `Ω(L)`-saturated language lies in `L(A)`;
  - **`formCgrFiFormLangRIso : finiteIndexCongruenceFormations Sig ≃o
    regularLanguageFormations Sig`** — the order isomorphism (mutual inverses
    plus order preservation/reflection).
  Axioms within the permitted set.
- Mapping: `B-P039` -> the seven declarations above. Evidence **`E-000198`**
  (verification) and **`E-000199`** (correspondence, two-stage blind,
  **`equivalent`**; transcript `blocks/audits/B-P039-correspondence.md`).
- `blocks/lean_audit.json`: **294 declarations, 0 warnings, 0 unpermitted,
  0 `sorry`**, ok. `check_all.sh` (slow): **43 passed, 0 failed**. Journal
  `EV-000107`. Frontier unmapped **35 -> 34** (95 mapped blocks).

**Finding (formalization simplification).** The manuscript's `𝔉_{L_𝔉} ⊆ 𝔉`
direction invokes `B-P024` (`Φ = ⋂ Ω(δ^{s,[a]_Φ})`, indexed by all elements of
`A`) and then finiteness to collapse the intersection to the classes. The Lean
proof needs only the class-indexed atoms and the *one* class of `x`, so the
`sortedEqv_iInf` representation theorem is not needed. Same-model audit
(`provisional` layer); inherits the pilot-encoding residuals.

**Honest caveat.** The Lean statement is an order isomorphism of the two posets;
the `CompleteLattice`/algebraic-lattice structures behind "complete lattices"
are the separate `B-P018`/`B-C005`/`B-C012` results (as with `B-P020`/`B-P034`).

**Prioritized next steps.**

1. `B-C013` (`Form_Lang_r(Σ)` is an algebraic lattice, from `B-P039` +
   `B-C012`) and `B-C005`/`B-C006` (the algebraic-lattice structures).
2. `B-P035` (equivalence of the two language-formation definitions).
3. `B-P032`/`B-P033` (the lattice structures on the finite subfamilies).

---

## Session 99 -- 2026-09-18 -- L_𝔉 closure corollaries (B-C007/B-C008/B-C009/B-C010, B-R022/B-R023)

**Goal.** Long-run continuation after the designated Eilenberg goals: formalize
the closure properties of the language formation `L_𝔉` that the second half of
the paper uses.

**What was established (closed, and mapped).**

- `lean/Mslang/Regular.lean`:
  - **`B-R022`** `langFormationOf_eq_iUnion_satSets`:
    `L_𝔉(A) = ⋃_{Φ∈𝔉(A)} Φ-Sat(T_Σ(A))`;
  - **`B-R023`** `langFormationOf_sat_of_le`: if `L ∈ L_𝔉(A)` and
    `Ω(L) ⊆ Ψ` then `[L]^Ψ ∈ L_𝔉(A)` (via `sat_antitone` + `sat_idem`);
  - **`B-C007`** `langFormationOf_transPreimage`: closure under translation
    preimages (`B-P027` + the meet clause at `X = Y = L`);
  - **`B-C010`** `langFormationOf_inverseImage`: closure under `f⁻¹[M]` along
    `Ω(M)`-epimorphisms (`B-P028` then the kernel clause);
  - **`B-C008`** `langFormationOf_union`/`_inter`/`_compl`/`_empty`/`_univ`:
    `L_𝔉(A)` is a Boolean subalgebra of `Sub(T_Σ(A))` (the two bounds are the
    `∇`-saturated empty and full languages, so the "subalgebra" wording is
    exact, not just closure);
  - **`B-C009`** `langFormationOf_atom_inf`: `δ^{s,[P]_{Φ∩Ψ}} ∈ L_𝔉(A)` when
    both factors are (`atomRep_inf` + `B-C008`).
- Mapping: the six blocks. Evidence `E-000200`..`E-000205` (verification) and
  `E-000206` (B-C008 reissued after the bounds were added), `E-000207`..`E-000210`
  (correspondence). Verdicts: `B-C007`/`B-C008`/`B-C010` **`equivalent`**;
  `B-C009` **`formal_stronger`** (the Lean statement quantifies over arbitrary
  sorted equivalences, not only congruences — a positive generalization,
  recorded).
- `blocks/lean_audit.json`: **304 declarations, 0 warnings, 0 unpermitted,
  0 `sorry`**. `check_all.sh` slow: **43 passed, 0 failed**. Journal `EV-000108`.
  Frontier unmapped **34 -> 28** (101 mapped blocks).

**Note on the audit protocol (caught by the comparator).** The first `B-C008`
comparator pass returned `formal_weaker`: the bare three closure implications do
not entail "Boolean subalgebra" without the bounds. The `∅`/`T_Σ(A)` lemmas were
then added and the verification record reissued (`E-000204` -> `E-000206`,
reason `remap`). This is the protocol working as intended.

**Honest caveat.** Same-model audits (`provisional`); B-R022/B-R023 carry
verification only (definitional restatement / remark, matching the convention
for remarks without a distinct result-bearing statement).

**Prioritized next steps.**

1. The lattice structures: `B-C005`/`B-C006`/`B-C011`/`B-C012`/`B-C013` and
   `B-P032`/`B-P033`/`B-P036`.
2. `B-P035` (Def1FRL ⇔ Def2FRL); the forward direction is short, the converse
   needs the class representation `B-P029` (`DesClasCog`).
3. `B-P001` (`propssupport`) support properties.

---

## Session 100 -- 2026-09-18 -- B-P029 (`DesClasCog`)

**Goal.** Formalize the representation of an `Ω`-class as an
intersection-minus-union of translation preimages — the key input for the
`Def2 ⇒ Def1` direction of `B-P035`.

**What was established (closed, and mapped).**

- `lean/Mslang/Translation.lean` (`B-P029`):
  - `cogClassSets Sig A L t a`: the family `𝒳_{L,t,a}` of `T⁻¹[L_s]` over
    translations `T : A_t → A_s` with `T a ∈ L_s`;
  - `cogClassSetsCompl Sig A L t a`: the `𝒳̄_{L,t,a}` with `T a ∉ L_s`;
  - `eqvClass_congCogenerated`: the `Ω^A(L)_t`-class of `a` equals
    `(⋂₀ 𝒳_{L,t,a}) \ (⋃₀ 𝒳̄_{L,t,a})`. The forward inclusion uses the two
    directions of the defining equivalence `T a ∈ L_s ↔ T b ∈ L_s`; the reverse
    uses the family members for a given `T`.
- Evidence **`E-000211`** (verification) and **`E-000212`** (correspondence,
  two-stage blind, **`equivalent`**; transcript
  `blocks/audits/B-P029-correspondence.md`).
- `blocks/lean_audit.json`: **307 declarations, 0 warnings, 0 unpermitted,
  0 `sorry`**. `check_all.sh` slow: **43 passed, 0 failed**. Journal `EV-000109`.
  Frontier unmapped **28 -> 27** (102 mapped blocks).

**Honest caveat.** Same-model audit (`provisional`); inherits the pilot-encoding
residuals.

**Prioritized next steps.**

1. `B-P035` (`Def1FRL ⇔ Def2FRL`): the forward direction (`Def1 ⇒ Def2`) is
   short (translation preimages by `B-P027`, Boolean closure by `B-C008`
   restricted to `L_𝔉`); the converse (`Def2 ⇒ Def1`) now has its key input in
   `B-P029` plus the finiteness of `Ω(X) ∩ Ω(Y)`.
2. The lattice structures: `B-C005`/`B-C011` (from `B-P018`/`B-P033` plus an
   algebraic-closure-system-to-algebraic-lattice bridge and a `CompleteLattice`
   instance), then `B-C006`/`B-C012`/`B-C013` by transport along the
   `B-P020`/`B-P034`/`B-P039` order isomorphisms, and `B-P014`/`B-P032`/`B-P036`.
3. `B-P006` (`Φ-Sat(A)` is a complete atomic Boolean algebra).

---

## Session 101 (partial) -- 2026-09-18 -- B-P035 forward direction

**Goal.** Start `B-P035` (`Def1FRL ⇔ Def2FRL`) with the tractable half.

**What was established (unmapped infrastructure, no block mapped).**

- `lean/Mslang/Regular.lean`: `regularFormation_compl`,
  `regularFormation_transPreimage`, `regularFormation_inverseImage`, and
  `isBPSLanguageFormation_of_isRegularLanguageFormation`
  (`IsRegularLanguageFormation → IsBPSLanguageFormation`): `BPS 3` is `B-P027`
  at `X = Y = L`, `BPS 4` is the Def1 Boolean closure, `BPS 5` is the Def1
  kernel clause with `B-P028`.
- Converse infrastructure (also unmapped):
  - `finite_satSets`: for a finite-index `Φ`, the `Φ`-saturated componentwise
    subsets form a **finite** type — a saturated subset is determined by which
    classes it contains, giving an injection into `(Σ(quot Φ)) → Bool`.
  - `bpsLanguageFormation_empty`/`_univ`/`_union`/`_inter`/`_compl`,
    `bpsLanguageFormation_finset_biUnion`/`_iUnion_finite`,
    `bpsLanguageFormation_finset_biInter`/`_iInter_finite`: the BPS-side Boolean
    closure and finite (arbitrary-index) unions/intersections.
  - `deltaSub_sdiff`/`_inter`/`_union`/`_eq_inter` and the componentwise
    distribution laws `deltaSub_sUnion`/`deltaSub_iInter` (the latter for a
    nonempty family), the set-algebra input for the atom claim.
- Build clean, 0 warnings; slow `check_all`: **43 passed, 0 failed**.
- **`B-P035` stays unmapped**: the converse `Def2 ⇒ Def1` is the open half; the
  remaining pieces are the `deltaSub` distributive laws, the atom claim
  `δ^{t,[P]_{Ω(X)}} ∈ L(A)` via `B-P029` + `finite_satSets`, and the assembly of
  `IsBPSLanguageFormation → IsRegularLanguageFormation`. Because no block is
  mapped, there is no facet, evidence record, or frontier movement from this
  session (per the convention that unmapped infrastructure does not enter the
  frontier).

**Prioritized next steps.**

1. `B-P035` converse: formalize `δ^{t,[P]_{Ω(X)}} ∈ L(A)` for `X ∈ L(A)` using
   `B-P029` + the finiteness of `Ω(X)`-saturated sets + the BPS Boolean
   closure, then assemble `IsBPSLanguageFormation → IsRegularLanguageFormation`
   and map `B-P035`.
2. The lattice structures (`B-C005`/`B-C011` + bridge, then transports) and
   `B-P006`.

---

## Session 102 -- 2026-09-19 -- B-P035 completed (Def1FRL ⇔ Def2FRL)

**Goal.** Finish the Session 101 WIP: prove the converse of `B-P035` and map
the block. The dirty tree at session start was the unverified scrape of the
atom claim; a targeted `lake build Mslang.Regular` had six to eight elaboration
errors.

**What was established (closed, and mapped).**

- `lean/Mslang/Regular.lean`: the converse
  `isRegularLanguageFormation_of_isBPSLanguageFormation` (`Def2FRL ⇒ Def1FRL`),
  assembled from:
  - `finite_satSets` -- a finite-index `Φ` has only finitely many `Φ`-saturated
    componentwise subsets (injection into `(Σ(quot Φ)) → Bool`);
  - BPS closure `bpsLanguageFormation_sInter`/`_sUnion` (finite `δ^{t,·}`
    intersections/unions) via `bpsLanguageFormation_iInter_finite`/
    `_iUnion_finite`, generic in the finite **subtype** index `𝒳` -- the earlier
    `hfin.coe_toFinset` route was replaced because the Finset-vs-Set coercion
    could not be found by `rw` at low transparency;
  - `deltaSub_transPreimage_mem`/`_isSat`, `covClass_finite`,
    `cogClassSets_finite`/`cogClassSetsCompl_finite` -- the `B-P029` class
    families are finite when `Ω(X)` has finite index;
  - `atom_deltaSub_mem` -- the class atom `δ^{t,[P]_{Ω(X)}} ∈ L(A)` for
    `X ∈ L(A)`, writing the class (`B-P029`) as intersection-minus-union of
    translation preimages and applying the BPS Boolean closure; the pointwise
    `\` vs `∩ ᶜ` mismatch was closed by an explicit function equality using
    `Set.sdiff_eq`, not `convert`;
  - `bps_sat_inf_mem` -- `Def1FRL` clause 2: a `(Ω(X) ∩ Ω(Y))`-saturated `N` is
    a finite union of `Φ`-class atoms over the finite quotient
    `Σ(termAlg/Φ)`, each a language by `atom_deltaSub_mem` applied to `X` and
    `Y` separately plus `eqvClass_sortedEqvInf`; `Φ` carries an explicit
    `SortedEqv (Term Sig A)` ascription so the finite-union decomposition
    typechecks;
  - clause 3 (kernel saturation along `Ω(M)`-epimorphisms) reduces to clause 2
    by saturating the direct image and pulling back
    (`inverseImage f (sat ΩM (f '' N)) = N`).
- `lean/Mslang/Prelim.lean`: `eqvClass_sortedEqvInf` (class under a pointwise
  meet = intersection of classes). `lean/Mslang/Translation.lean`:
  `deltaSub_self`/`_of_ne`/`_empty`.
- **Tooling fix.** `Mslang.termAlg` marked `@[reducible]` (`Term.lean`): Lean
  would not reduce `(termAlg Sig A).1` to `Term Sig A` at the transparency
  `rw`/`simp` use, so the `Sub (Term Sig A)` vs `Sub (termAlg Sig A).1` defeq was
  invisible to tactics. The attribute is not part of the extracted declaration
  text (attributes are boundaries in `lean_facets.py`), so **no facet hash
  changed** -- verified by a pure-addition diff of `blocks/formal.json`.
- `lean/declarations.json` maps `B-P035` to both directions; facets regenerated.
  `blocks/lean_audit.json`: **309 declarations, 0 warnings, 0 unpermitted,
  0 `sorry`**; both new declarations use `[propext, Classical.choice,
  Quot.sound]`.
- Evidence **`E-000213`** (verification, `build_ok`) and **`E-000214`**
  (correspondence, two-stage blind, **`equivalent`**; transcript
  `blocks/audits/B-P035-correspondence.md`); `B-P035` consequently has no
  `fail` layer. Journal `EV-000110`. Frontier unmapped **27 → 26**. Views and
  bundle regenerated. Fast gate: **40 passed, 0 failed**.

**Honest caveats.** Same-model audit as always: the correspondence verdict is
independent-context but shares `deepseek-v4.1-flash` and inherits the
pilot-encoding residuals (`carrier-model`, `small-large`, `univalence-missing`).
The `@[reducible]` on `termAlg` is a proof-engineering accommodation, not a
mathematical change; it is recorded here because it is a Lean-source edit, but
it is attribute-only and hash-neutral.

**Prioritized next steps.**

1. The lattice structures: `B-C005`/`B-C011` (from `B-P018`/`B-P033` plus an
   algebraic-closure-system-to-algebraic-lattice bridge and a `CompleteLattice`
   instance), then `B-C006`/`B-C012`/`B-C013` by transport along the
   `B-P020`/`B-P034`/`B-P039` order isomorphisms, and `B-P014`/`B-P032`/`B-P036`.
2. `B-P006` (`Φ-Sat(A)` is a complete atomic Boolean algebra).
3. `B-P001` (support properties).

---

## Session 103 -- 2026-09-19 -- B-P033 (`Form_Alg_f(Σ)` is an algebraic closure system)

**Goal.** Continue the frontier (Session 102 step 1) into the finite-algebra
lattice cluster, starting with `B-P033`, the top-ranked unmapped block and the
direct finite analogue of `B-P018`.

**What was established (closed, and mapped).**

- `lean/Mslang/Algebra.lean`: `IsAlgebraicClosureSystemOnCarrier` -- an
  algebraic closure system on a type `X` with a fixed carrier `C₀` (unmapped
  infrastructure, like `IsAlgebraicClosureSystemOn`). This is the encoding the
  block needs because the ambient class is the **finite** algebras `Alg_f(Σ)`,
  not all of `Alg(Σ)`: `Set.univ` is not a member of
  `finiteAlgebraFormations`, so `IsAlgebraicClosureSystemOn` does not apply.
- `lean/Mslang/Regular.lean`:
  - `algebraFinite_closed_HOperator`: a homomorphic image of a finite
    `Σ`-algebra is finite (a componentwise surjection of the disjoint unions,
    `Finite.of_surjective`).
  - `algebraFinite_closed_PFsdOperator` (under `[Finite S]`, i.e. `B-A001`): a
    finite subdirect product of finite algebras is finite. The product's support
    is the finite intersection `⋂ supp(C i)` (finite because `S` is) and each
    support-component is a finite pi; this is exactly where `B-A001` is needed
    (the empty product is the final algebra `1`, with support all of `S`).
    Finiteness is checked through `B-R003` (`finiteSSet_iff`).
  - `finiteAlgebraFormations_isAlgebraicClosureSystem`: `Alg_f(Σ)` is a
    formation of finite algebras; a nonempty intersection and a nonempty
    directed union of formations of finite algebras are formations of finite
    algebras contained in `Alg_f(Σ)`. The formation half reuses the argument of
    `B-P018` (each `H`/`P_fsd` witness lands in every family member; the
    finitely many `P_fsd` witnesses are combined by directedness via
    `exists_mem_superset_finset`), with `IsFormation` extracted from the
    `IsFiniteAlgebraFormation` conjunction.
- `lean/declarations.json` maps `B-P033`; facets regenerated.
  `blocks/lean_audit.json`: **312 declarations, 0 warnings, 0 unpermitted,
  0 `sorry`**; the three new declarations use `[propext, Classical.choice,
  Quot.sound]`.
- Evidence **`E-000215`** (verification, `build_ok`) and **`E-000216`**
  (correspondence, two-stage blind, **`equivalent`**; transcript
  `blocks/audits/B-P033-correspondence.md`). Journal `EV-000111`. Frontier
  unmapped **26 → 25**. Views and bundle regenerated. Fast gate: **40 passed,
  0 failed**.

**Honest caveats.** Same-model audit as always (independent-context, shares
`deepseek-v4.1-flash`, inherits the pilot-encoding residuals). The block's Lean
statement carries `[Finite S]` for `B-A001`; the `P_fsd` half would be false
without it. The adjacency `IsAlgebraicClosureSystemOnCarrier` is new
infrastructure whose hash is not tracked in any mapped block (as with
`IsAlgebraicClosureSystemOn` itself).

**Prioritized next steps.**

1. `B-C011` (`Form_Alg_f(Σ)` is an algebraic lattice): the missing piece is the
   algebraic-closure-system-to-algebraic-lattice bridge plus a `CompleteLattice`
   instance on the carrier. Then `B-C005`/`B-C006` (`Form_Alg`/`Form_Cgr`
   algebraic lattices), `B-P014`/`B-P032` (complete lattices).
2. The `B-C012`/`B-C013` transports along the `B-P020`/`B-P034`/`B-P039` order
   isomorphisms.
3. `B-P006` (`Φ-Sat(A)` is a complete atomic Boolean algebra).

---

## Session 104 -- 2026-09-19 -- B-P014 (`Form_Cgr(Σ)` is a complete lattice)

**Goal.** Continue the lattice cluster with the first completable block, after
the user chose the **bespoke construction** (no representation change) over the
C6 re-encoding of formations as subsets of `Cgr`.

**Why bespoke.** The existing formations are `Set`-valued on
`Set (SortedEqv …)` / `Set (Alg …)`, whose ambient top (`univ`) is *not* a
member (not every sorted equivalence is a congruence). So the standard
closure-operator → `CompleteLattice` bridge does not apply; the infimum must be
built with the top formation folded in. Doing this directly leaves every
existing `formal_*` hash untouched.

**What was established (closed, and mapped).**

- `lean/Mslang/Formation.lean`:
  - `congruenceFormationsTop` -- the greatest congruence formation,
    `A ↦ {Φ | Φ a congruence on T_Σ(A)}` (nonempty via `nabla_isCongruence`,
    meet-closed via `IsCongruence_inf`, kernel-closed via `ker_isCongruence` on
    the composite homomorphism, proved inline since `isAlgHom_comp` lives in
    `Translation.lean`).
  - `congruenceFormationsInf` -- for a set `T` of formations, the pointwise
    intersection `A ↦ ⋂ G ∈ insert congruenceFormationsTop T, G A`. The top is
    inserted so the family is nonempty; this is the pointwise intersection for
    nonempty `T` and the top for empty `T`. Its formation proof uses the
    pointwise-filter and kernel clauses of each member.
  - `congruenceFormationsInfSet` (the `InfSet` instance),
    `congruenceFormations_isGLB_sInf` (it is the greatest lower bound; the
    "greatest" half unfolds `B ∈ lowerBounds T`), and
    `congruenceFormationsCompleteLattice` via `completeLatticeOfInf`
    (`@[instance_reducible]`, since its type is a class).
- `lean/declarations.json` maps `B-P014`; facets regenerated.
  `blocks/lean_audit.json`: **316 declarations, 0 warnings, 0 unpermitted,
  0 `sorry`**; the four new declarations use `[propext, Classical.choice,
  Quot.sound]`.
- Evidence **`E-000217`** (verification, `build_ok`) and **`E-000218`**
  (correspondence, two-stage blind, **`equivalent`**; transcript
  `blocks/audits/B-P014-correspondence.md`). Journal `EV-000112`. Frontier
  unmapped **25 → 24**. Views and bundle regenerated. Fast gate: **40 passed,
  0 failed**.

**Honest caveats.** Same-model audit as always. `congruenceFormationsInfSet` is
an unnamed `InfSet` instance (infrastructure); `B-P014` is mapped to the four
named declarations. The `CompleteLattice` instance is the bespoke one, not a
Mathlib closure-system instance.

**Prioritized next steps.**

1. `B-C005`/`B-C006` (`Form_Alg`/`Form_Cgr` are **algebraic** lattices): the
   complete-lattice half for `Form_Cgr` is now `B-P014`; the algebraic half
   needs the finite-character/compactness argument (compact elements are
   `Fmg_Σ(M)`, `M` finite).
2. `B-P032` (`Form_Cgr_fi` complete lattice, needs `B-A001 [Finite S]`) and
   `B-C011` (`Form_Alg_f`), then the `B-C012`/`B-C013` transports.
3. `B-P006` (`Φ-Sat(A)` is a complete atomic Boolean algebra).

---

## Session 105 -- 2026-09-19 -- B-P032 (`Form_Cgr_fi(Σ)` is a complete lattice)

**Goal.** Extend the lattice cluster to the finite-index case, reusing the
`B-P014` bespoke pattern and the `B-A001` (`S` finite) standing assumption.

**What was established (closed, and mapped).**

- `lean/Mslang/Regular.lean`:
  - `isFiniteIndex_ker_of_finite` -- a sorted map `f : A → B` into a finite
    `S`-set `B` has finite-index kernel `ker f`. The descent
    `quot (ker f) → B` (via `quotLift`) is injective (the witness
    `⟨s, [a]⟩ ↦ ⟨s, f s a⟩` is injective), so `Σ quot(ker f)` embeds in the
    finite `Σ B`. Notably **surjectivity is not needed**: finiteness of the
    codomain alone suffices, so the kernel clause of `IsCongruenceFormation`
    upgrades to finite index with no extra hypothesis.
  - `finiteIndexCongruenceFormationsTop` -- `A ↦ Cgr_fi(T_Σ(A))`, the greatest
    finite-index congruence formation (nonempty via `nabla` with
    `isFiniteIndex_nabla` under `[Finite S]`; meet via `IsCongruence_inf` +
    `IsFiniteIndex_inf`; up-closure via `IsFiniteIndex_of_le`; kernel via the
    lemma above).
  - `finiteIndexCongruenceFormationsInf` (pointwise intersection with the top
    inserted so the family is nonempty), `finiteIndexCongruenceFormationsInfSet`,
    `finiteIndexCongruenceFormations_isGLB_sInf`, and
    `finiteIndexCongruenceFormationsCompleteLattice` via `completeLatticeOfInf`
    (`@[instance_reducible]`).
- `lean/declarations.json` maps `B-P032`; facets regenerated.
  `blocks/lean_audit.json`: **321 declarations, 0 warnings, 0 unpermitted,
  0 `sorry`**; the five new declarations use `[propext, Classical.choice,
  Quot.sound]`.
- Evidence **`E-000219`** (verification, `build_ok`) and **`E-000220`**
  (correspondence, two-stage blind, **`equivalent`**; transcript
  `blocks/audits/B-P032-correspondence.md`). Journal `EV-000113`. Frontier
  unmapped **24 → 23**. Views and bundle regenerated. Fast gate: **40 passed,
  0 failed**.

**Honest caveats.** Same-model audit as always. All declarations carry
`[Finite S]` (`B-A001`), which the top's nonemptiness (`nabla` finite index)
genuinely needs. No representation change; existing hashes untouched.

**Prioritized next steps.**

1. `B-C005`/`B-C006`/`B-C011`/`B-C012`/`B-C013` (the **algebraic** lattice
   statements): the complete-lattice halves now exist for `Form_Cgr` (`B-P014`)
   and `Form_Cgr_fi` (`B-P032`); the missing ingredient across all five is the
   finite-character/compactness argument (compact elements `Fmg_Σ(M)`,
   `M` finite; equivalently `Fmg_Σ(M) = ⋃_{M₀ ⊆ M finite} Fmg_Σ(M₀)`). This is
   the multi-session blocker.
2. `B-P006` (`Φ-Sat(A)` is a complete atomic Boolean algebra).
3. `B-P001` (support properties; componentwise union/intersection/difference of
   `S`-sorted sets have no dependent-type analogue — an encoding question).

---

## Session 106 -- 2026-09-19 -- B-C005 (`Form_Alg(Σ)` algebraic lattice)

**Goal.** Break the multi-session blocker: the compactness/finite-character half
of the algebraic-lattice cluster.

**What was established (closed, and mapped).**

- `lean/Mslang/Algebra.lean`: **`isAlgebraicLattice_of_isAlgebraicClosureOperator`**
  -- the generic bridge. For a closure operator `c` on `Set X` whose closed sets
  are closed under directed unions (`halg`), the closed sets `c.Closeds` (with
  the `CompleteLattice` from `c.gi.liftCompleteLattice`) form an algebraic
  lattice in the project's `IsAlgebraicLattice` sense. The proof:
  - **finite character** of `c`: `x ∈ c U → ∃ F finite ⊆ U, x ∈ c F`. The family
    `D = {c F | F finite ⊆ U}` is directed, its union is closed by `halg`, and
    contains `U`; hence `c U ⊆ ⋃₀ D`.
  - **`c.toCloseds F` is compact for finite `F`**: given `c F ≤ sSup S`, choose
    finitely many `c Fₓ` (finite character) and finitely many members of `S`
    covering the union, and take the finite subfamily.
  - every closed set is the supremum of the closures of its finite subsets.
  (This is the standard "algebraic closure operator ↦ algebraic lattice" result,
  proved directly rather than via Mathlib's compactly-generated API.)
- `lean/Mslang/Formation.lean`:
  - `algebraFormationsClosureOperator` -- `ofCompletePred` from `B-P018`
    (`univ` + arbitrary intersections of formations are formations; the empty
    intersection is handled separately).
  - `algebraFormationsCompleteLattice` -- `c.gi.liftCompleteLattice`.
  - `algebraFormations_isAlgebraicLattice` -- the generic bridge applied to
    `B-P018`'s directed-union clause. Statement uses the explicit instance
    `@IsAlgebraicLattice … (algebraFormationsCompleteLattice Sig)` (the
    instance-transport problem is why the statement is `@`-pinned).
- `lean/declarations.json` maps `B-C005`; facets regenerated.
  `blocks/lean_audit.json`: **324 declarations, 0 warnings, 0 unpermitted,
  0 `sorry`**.
- Evidence **`E-000221`** (verification, `build_ok`) and **`E-000222`**
  (correspondence, two-stage blind, **`formal_weaker`**; transcript
  `blocks/audits/B-C005-correspondence.md`). Journal `EV-000114`. Frontier
  unmapped **23 → 22**. Views and bundle regenerated. Fast gate: **40 passed,
  0 failed**.

**Honest finding (review queue).** The correspondence audit is `formal_weaker`:
`B-C005` also asserts the **compact characterization** "`F` compact iff
`F = Fmg_Σ(M)` for some finite `M`", which was not stated. It is provable from
the same construction (compact elements are `c.toCloseds M` for finite `M`);
the gap is recorded rather than dropped.

**Prioritized next steps.**

1. Close the `B-C005` gap by stating the compact characterization (extract
   `closure_finite_compact` from the generic proof and add the `iff`), then
   re-run the correspondence to move `formal_weaker` → `equivalent`.
2. `B-C006` (`Form_Cgr` algebraic, via the `B-P020` order iso) — needs an
   order-iso preservation lemma for `IsAlgebraicLattice` plus reconciliation of
   the transported instance with `B-P014`'s.
3. `B-C011` (`Form_Alg_f`, the carrier variant), then `B-C012`/`B-C013`, and
   `B-P006`.

---

## Session 107 -- 2026-09-19 -- `B-C005` compact characterization (gap closed)

**Goal.** Execute Session 106 step 1: close the `formal_weaker` correspondence
gap on `B-C005` by stating the corollary's compact characterization.

**What was established (closed, and mapped).**

- `lean/Mslang/Algebra.lean`: the generic proof was **refactored** into exposed,
  reusable lemmas:
  - `closure_finite_character` (finite character of an algebraic closure
    operator);
  - `closure_finite_compact` (`c F` is compact for finite `F`);
  - `closure_sSup_finite` (every closed set is the supremum of the closures of
    its finite subsets; needs no algebraicness);
  - `isAlgebraicLattice_of_isAlgebraicClosureOperator` (now a short assembly);
  - **`isCompact_iff_exists_finite_closure`** -- the compact characterization:
    `F` compact iff `F = c M` for some finite `M`.
- `lean/Mslang/Formation.lean`: `algebraFormations_isCompact_iff` -- for
  `Form_Alg(Σ)`, `F` is compact iff `F = Fmg_Σ(M)` for some finite `M`
  (`= (algebraFormationsClosureOperator Sig).toCloseds M`).
- `lean/declarations.json` maps the new declaration under `B-C005`; facets
  regenerated. `blocks/lean_audit.json`: **325 declarations, 0 warnings,
  0 unpermitted, 0 `sorry`**.
- Evidence **`E-000223`** (verification; supersedes `E-000221`) and
  **`E-000224`** (correspondence, two-stage blind, **`equivalent`**; supersedes
  the earlier `formal_weaker` `E-000222`). Transcript rewritten
  (`blocks/audits/B-C005-correspondence.md`, which records both audit rounds).
  Journal `EV-000115`. Views and bundle regenerated. Fast gate: **40 passed,
  0 failed**.

**Caveat.** Same-model audit as always; inherits the pilot-encoding residuals.

**Prioritized next steps.**

1. `B-C006` (`Form_Cgr` algebraic via the `B-P020` order iso): needs an
   order-isomorphism-preserves-`IsAlgebraicLattice` lemma plus reconciliation of
   the transported `CompleteLattice` instance with `B-P014`'s (which is built
   independently via `completeLatticeOfInf`).
2. `B-C011` (`Form_Alg_f`): the carrier variant of the generic bridge
   (`IsAlgebraicClosureSystemOnCarrier` from `B-P033`).
3. `B-C012`/`B-C013` by transport along `B-P034`/`B-P039`, and `B-P006`.

---

## Session 108 -- 2026-09-19 -- B-C006 (`Form_Cgr(Σ)` algebraic lattice)

**Goal.** Session 107 step 1: transport `B-C005` to `Form_Cgr(Σ)` along
`B-P020`.

**Insight that removed the blocker.** The instance-reconciliation worry was
moot: state the transport lemma abstractly over *any* two `CompleteLattice`
instances and an `OrderIso`. `IsCompact`/`IsAlgebraicLattice` use only `≤` and
`sSup`, and an `OrderIso` preserves `sSup` (`OrderIso.map_sSup`), so the result
holds for whichever complete-lattice structures are in scope — no need to prove
the transported instance is *defeq* to `B-P014`'s.

**What was established (closed, and mapped).**

- `lean/Mslang/Algebra.lean`: `isCompact_of_orderIso_apply` (an order iso maps a
  compact element to a compact element: pull `sSup` back and push the finite
  subfamily forward), `isCompact_of_orderIso`, and
  `isAlgebraicLattice_of_orderIso`.
- `lean/Mslang/Formation.lean`: `congruenceFormations_isAlgebraicLattice`, via
  `letI`-installing `congruenceFormationsCompleteLattice` (`B-P014`) and
  `algebraFormationsCompleteLattice` (`B-C005`) and applying the transport to
  `formAlgFormCgrIso` (`B-P020`). The statement is `@`-pinned to `B-P014`'s
  instance.
- `lean/declarations.json` maps `B-C006`; facets regenerated.
  `blocks/lean_audit.json`: **326 declarations, 0 warnings, 0 unpermitted,
  0 `sorry`**.
- Evidence **`E-000225`** (verification, `build_ok`) and **`E-000226`**
  (correspondence, two-stage blind, **`equivalent`**; transcript
  `blocks/audits/B-C006-correspondence.md`). Journal `EV-000116`. Frontier
  unmapped **22 → 21**. Fast gate: **40 passed, 0 failed**.

**Caveat.** Same-model audit; inherits the pilot-encoding residuals.

**Prioritized next steps.**

1. `B-C011` (`Form_Alg_f` algebraic): the **carrier** variant of the generic
   bridge, from `IsAlgebraicClosureSystemOnCarrier` (`B-P033`). The ambient
   `Set C₀` has `univ ↦ C₀ ∈ C`, so the plain `ofCompletePred` route applies
   once the closure system is transported to `Set C₀`.
2. `B-C012` (transport of `B-C011` along `B-P034`) and `B-C013` (along
   `B-P039`), reusing `isAlgebraicLattice_of_orderIso`.
3. `B-P006` (CABA on `Φ-Sat`).

---

## Session 109 -- 2026-09-19 -- `B-C011` (`Form_Alg_f(Σ)` algebraic lattice)

**Goal.** Session 108 step 1: the **carrier** variant of the closure-system
bridge, from `IsAlgebraicClosureSystemOnCarrier` (`B-P033`). Resumed from the
WIP commit `4370c77`, whose `Mslang.Regular` check had been aborted.

**What was established (closed, and mapped).**

- `lean/Mslang/Algebra.lean`: the generic carrier bridge —
  `carrierImage` (a carrier family `C ⊆ Set X` viewed as a family of subsets of
  the carrier `C₀`), `isAlgebraicClosureSystemOn_carrierImage` (it is an
  ordinary algebraic closure system on `C₀`), `carrierClosureOperator`
  (`ClosureOperator.ofCompletePred`, with the empty intersection handled
  separately as `C₀`), `isAlgebraicLattice_carrierImage` (the closed sets form
  an algebraic lattice, by `B-C005`'s generic theorem), and `carrierOrderIso`
  (`C ≃o carrierImage C₀ C`, preserving and reflecting inclusion).
- `lean/Mslang/Regular.lean`: `finiteAlgebraFormationsCompleteLattice` and
  `finiteAlgebraFormations_isAlgebraicLattice` for `Form_Alg_f(Σ)`, under
  `B-A001` `[Finite S]`. The lattice is transported across
  `(carrierOrderIso …).symm`; the algebraicness follows from
  `isAlgebraicLattice_carrierImage` through `isAlgebraicLattice_of_orderIso`.
- `lean/declarations.json` maps `B-C011`; facets regenerated.
  `blocks/lean_audit.json`: **328 declarations, 0 warnings, 0 unpermitted,
  0 `sorry`**.
- Evidence **`E-000227`** (verification, `build_ok`) and **`E-000228`**
  (correspondence, two-stage blind, **`equivalent`**; transcript
  `blocks/audits/B-C011-correspondence.md`). Journal `EV-000117`. Frontier
  unmapped **21 → 20**. Fast gate: **40 passed, 0 failed**.

**Finding (the WIP did not compile; two fixes).** The committed WIP omitted
`B-A001`'s `[Finite S]` on both new declarations, so
`finiteAlgebraFormations_isAlgebraicClosureSystem` could not be applied; and the
order-isomorphism transport was taken in the wrong direction (`carrierOrderIso`
is `C ≃o carrierImage`, but `isAlgebraicLattice_of_orderIso` needs the source
algebraic and the target derived), so `.symm` is required on both uses.
`carrierOrderIso` goes from the carrier-side lattice's *codomain*, hence
`(carrierOrderIso …).symm.toGaloisInsertion.liftCompleteLattice` places the
`CompleteLattice` on `Form_Alg_f(Σ)`.

**Caveat.** Same-model audit; inherits the pilot-encoding residuals.

**Prioritized next steps.**

1. `B-C012` (transport of `B-C011` along `B-P034`) and `B-C013` (along
   `B-P039`), reusing `isAlgebraicLattice_of_orderIso` and the complete-lattice
   halves already present (`B-P032`, `B-P014`).
2. `B-P006` (CABA on `Φ-Sat`).
3. Independent representation audit; the author-reserved decisions.

---

## Session 110 -- 2026-09-20 -- `B-C012`/`B-C013` (the Eilenberg algebraic lattices)

**Goal.** Session 109 step 1: complete the chain of algebraic-lattice results by
transport along the two Eilenberg order isomorphisms. No author-reserved
decision was taken.

**What was established (closed, and mapped).**

- `lean/Mslang/Regular.lean`:
  - `finiteIndexCongruenceFormations_isAlgebraicLattice` (**`B-C012`**,
    `FormCgrfiAlg`): transports `B-C011`'s
    `finiteAlgebraFormations_isAlgebraicLattice` across the `B-P034` order
    isomorphism `formAlgFFormCgrFiIso` with the generic
    `isAlgebraicLattice_of_orderIso`, under `B-A001` `[Finite S]`. No new
    complete-lattice instance is needed: `B-P032`'s
    `finiteIndexCongruenceFormationsCompleteLattice` already supplies it.
  - `regularLanguageFormationsCompleteLattice` + `regularLanguageFormations_isAlgebraicLattice`
    (**`B-C013`**): a `CompleteLattice` instance for `Form_Lang_r(Σ)` obtained by
    `liftCompleteLattice` along the Galois insertion of the `B-P039` order
    isomorphism `formCgrFiFormLangRIso`, then `B-C012` transported across that
    isomorphism. `Form_Lang_r(Σ)` had no lattice instance before; this session
    mints one.
- `lean/declarations.json` maps both blocks. `blocks/lean_audit.json`:
  **331 declarations** (was 328), 0 warnings, 0 unpermitted, 0 `sorry`. Every
  new axiom set is within the permitted `[propext, Classical.choice, Quot.sound]`.
- Evidence **`E-000229`/`E-000230`** (`B-C012` verification / correspondence) and
  **`E-000231`/`E-000232`** (`B-C013` verification / correspondence; both
  two-stage blind, **`equivalent`**). Transcripts
  `blocks/audits/B-C012-correspondence.md`, `B-C013-correspondence.md`. Journal
  `EV-000118`. Frontier unmapped **20 → 18**. Fast gate: **40 passed, 0 failed**;
  slow gate: **43 passed, 0 failed**.

**Findings / notes.**

- The transport pattern is now uniform: `isAlgebraicLattice_of_orderIso` needs
  the source instance algebraic and the target's `CompleteLattice` derived; for
  `B-C012` both complete lattices already exist (`B-P032`, `B-C011`) and only a
  local `letI` plus `change` is needed to reconcile instances, exactly as in
  `B-C011`. `B-C013` additionally had to mint the target instance, since
  `Form_Lang_r(Σ)` (a plain `Set` of choice functions) had none.
- Both new `CompleteLattice` defs are plain (non-instance) defs; the theorems
  install them with `letI` and close with `change` to the explicit instance, so
  no global instance diamonds are introduced.
- `B-C012`/`B-C013` have **no informal proof** and no `Explanation`, so their
  **review** layer still fails closed; only correspondence + verification were
  produced. They keep the other blocks in this family's state (algebraic-lattice
  facts are cited, not reproved, in the manuscript).
- Same-model audit; inherits the pilot-encoding residuals (`carrier-model`,
  `small-large`, `univalence-missing`).

**Prioritized next steps.**

1. `B-P006` (CABA on `Φ-Sat`).
2. The remaining `worth-formalizing` unmapped blocks (`B-C003`) and the deferred
   set; the definition-block declarations of `B-D002`/`B-D014` if wanted.
3. Independent representation audit; the author-reserved decisions (Explanation
   acceptance, JSON/YAML record format).

---

## Session 111 -- 2026-09-20 -- `B-P006` (`Φ-Sat(A)` is a complete atomic Boolean algebra)

**Goal.** Session 110 step 1: the CABA on `Φ-Sat(A)`. No author-reserved
decision was taken.

**What was established (closed, and mapped).**

- `lean/Mslang/Regular.lean`, new `CABA` section:
  - `SatSet Φ = {X : Sub A // sat Φ X = X}` (the type of `satSets Φ`), with the
    order bijection `satSetsFamilyEquiv Φ : SatSet Φ ≃ QuotFamily Φ`, where
    `QuotFamily Φ = ∀ s, Set (A_s/Φ_s)` and `familyOf Φ X s = pr Φ s '' X_s`,
    inverse `satOfFamily`. The two round-trips rest on surjectivity of
    `pr Φ s` (`B-R006`, `sat_eq_preimage`).
  - `satSetsCABA Φ : CompleteAtomicBooleanAlgebra (SatSet Φ)`, the structure
    transported from the product of powersets across that bijection.
  - `familyOf_deltaSub`, `familyOf_atomRep`: `familyOf` sends the Kronecker
    delta `δ^{s,Y}` to the singleton update `⊥`-family `Function.update ⊥ s
    (pr Φ s '' Y)`.
  - `satSets_isAtom_iff`: the atoms of `Φ-Sat(A)` are exactly the deltas
    `δ^{s,[x]_Φ}`, i.e. one per class per sort (`Σ_{s∈S} A_s/Φ_s`), via
    `OrderIso`-free use of `Pi.isAtom_iff_eq_single` and `Set.isAtom_singleton`.
  - `satSets_eq_sSup_atoms`: every saturated `X` is the join of the atoms below
    it (`le_iff_atom_le_imp` + `le_sSup` / `sSup_le`).
- `lean/declarations.json` maps `B-P006`. `blocks/lean_audit.json`:
  **338 declarations** (was 331), 0 warnings, 0 unpermitted, 0 `sorry`.
- Evidence **`E-000233`** (verification) / **`E-000234`** (correspondence,
  two-stage blind, **`equivalent`**). Transcript
  `blocks/audits/B-P006-correspondence.md`. Journal `EV-000119`. Frontier
  unmapped **18 → 17**. Fast gate: **40 passed, 0 failed**; slow gate:
  **43 passed, 0 failed**.

**Findings / notes.**

- **Packaging (honest):** the atom and join facts are stated on
  `familyOf Φ X` in `QuotFamily Φ`, not directly on `X : SatSet Φ`. This is a
  Lean instance-synthesis limitation, not a mathematical weakening:
  `familyOf` is an `OrderIso`-grade bijection (it preserves and reflects
  inclusion), so atoms, joins and the CABA structure transfer exactly. The
  independent two-stage comparator returned `equivalent` and explicitly
  reasoned that the packaging does not change strength. The transported
  instance `satSetsCABA` itself is a plain `def` (the extractor does not index
  `instance`s). If a later session wants the facts stated directly on
  `SatSet Φ`, the route is an explicit `OrderIso` on the transported order.
- A naive attempt to install `satSetsCABA` as a global `instance` made
  `IsAtom X` fail to synthesize `OrderBot ↥(SatSet Φ)`: instance search unifies
  the *whnf*'d subtype of `X`'s type against the instance's folded `SatSet Φ`
  and fails. Working around it via `letI`/`SatSetIsAtom` predicates was also
  rejected (`change` could not see the `let`-bound instance as defeq). Hence the
  family-level statements above.
- Same-model audit; inherits the pilot-encoding residuals (`carrier-model`,
  `small-large`, `univalence-missing`).

**Prioritized next steps.**

1. `B-P001` (support properties of sorted sets) -- the last `worth-formalizing`
   block besides the `B-A001` assumption; note that the literal *union* item
   `supp(⋃_i A^i)` needs a universe/subset encoding (the type-level encoding
   only has `iCoprod`), so parts may be `formal_weaker`/`formal_stronger`.
2. `B-P036` (`Form_Lang_r` complete lattice) is already subsumed by `B-C013`'s
   `regularLanguageFormationsCompleteLattice`; if mapped, it should cite that
   instance rather than reprove.
3. Independent representation audit; the author-reserved decisions.

---

## Session 112 -- 2026-09-20 -- `B-P001` (support properties; `formal_weaker`)

**Goal.** Formalize the last `worth-formalizing` block besides the `B-A001`
assumption. Outcome is an honest `formal_weaker` correspondence.

**What was established (closed, and mapped).**

- `lean/Mslang/Prelim.lean`, new `B-P001` section:
  - `nonempty_sortedMap_iff : Nonempty (SortedMap A B) ↔ supp A ⊆ supp B`.
  - `supp_mono_of_injective`, `suppSub_directImage`, `supp_eq_of_surjective`,
    `suppSub_inverseImage`.
  - `supp_initialSorted`, `supp_finalSorted` (now mapped here).
  - `supp_iCoprod`, `supp_iProd`.
  - `suppSub_iInter_subset`, `suppSub_sdiff_subset` (for componentwise subsets
    of a common carrier).
- `lean/declarations.json` maps `B-P001`. `blocks/lean_audit.json`:
  **349 declarations** (was 338), 0 warnings, 0 unpermitted, 0 `sorry`.
- Evidence **`E-000235`** (verification) / **`E-000236`** (correspondence,
  two-stage blind, **`formal_weaker`**). Transcript
  `blocks/audits/B-P001-correspondence.md`. Journal `EV-000120`. Frontier
  unmapped **17 → 16** (`worth-formalizing` 2 → 1, only `B-A001` left). Fast
  gate: **40 passed, 0 failed**; slow gate: **43 passed, 0 failed**.

**Findings (the gap is representational, not a proof gap).**

- Three clauses of `B-P001` are **not expressible** in the type-level encoding:
  `supp(⋃_i A^i)` (a set-theoretic union of arbitrary sorted sets; the encoding
  only has the coproduct `iCoprod`, whose support formula coincides), and the
  intersection/difference clauses `supp(⋂_i A^i) ⊆ ⋂_i supp(A^i)` and
  `supp(A) - supp(B) ⊆ supp(A - B)`, which are stated only for componentwise
  subsets of a **common** carrier. This is exactly the pilot representation's
  declared D2 residual (fixed-ambient carrier model). The independent comparator
  returned `formal_weaker`, clause by clause, and explicitly attributed the gap
  to the missing union operation and the carrier restriction.
- Consequence: `B-P001`'s correspondence layer is recorded **negative**
  (`fail`). Closing it to `equivalent` needs a representation revision
  (S-sorted sets as subobjects of a universe, class **C6**), which would stale
  every current record — an author-reserved decision, not a mechanical one.
  Recorded honestly rather than hidden or papered over.

**Prioritized next steps.**

1. Author: decide whether to revise the representation to a universe/subobject
   model to close `B-P001`; that is a class-C6 representation change.
2. The remaining frontier is otherwise `B-A001` (the `[Finite S]` assumption)
   plus the 15 deferred blocks; `B-P036` is already subsumed by `B-C013`.
3. Independent representation audit; the author-reserved decisions.

---

## Session 113 -- 2026-09-20 -- B-A001, B-R024, B-P010 (worth-formalizing frontier emptied)

**Goal.** Author-directed long run: formalize the last `worth-formalizing` block
(`B-A001`) and probe the deferred free-algebra cluster (`B-C003`, `B-P010`). No
author-reserved decision was taken beyond the scope updates below.

**What was established (closed, and mapped).**

- `B-A001` (the standing assumption that `S` is finite) is named
  `Mslang.FiniteSorts (S : Type u) : Prop := Finite S` (`Regular.lean`); the
  finite-index section's declarations carry it as the `[Finite S]` typeclass
  hypothesis. Evidence `E-000237` (verification) / `E-000239` (correspondence,
  `equivalent`).
- `B-R024` formalized as `Mslang.finite_supp_term_iff` (`Regular.lean`):
  `(∀ A : SSet S, (supp (Term Sig A)).Finite) ↔ Finite S`. The forward direction
  instantiates the terminal sorted set `finalSorted S` (whose free algebra is
  inhabited at every sort, so its support is `univ`); the backward direction is
  `supp ⊆ univ`. Evidence `E-000238` / `E-000240` (`equivalent`).
- `B-P010` (unique parsing) formalized in `Term.lean`:
  - `rowOf` (the row of a term) and `toT_apply` (`(toT t).1 = rowOf t`);
  - a fuel-bounded parser `parseRow`/`parseFam` with correctness `parse_correct`
    (recovers a term / a family of terms from its row, returning the untouched
    suffix; a `2 * length` fuel invariant absorbs the two fuel decrements per
    consumed symbol), proved by induction on the fuel;
  - `toT_injective`: the row presentation `T_Σ(X)` and the inductive
    presentation `Term_Σ(X)` agree — the open bridge flagged in Sessions 87/111;
  - `term_shape`: every term is a variable, a nullary operation, or an operation
    of nonempty arity.
  Evidence `E-000241` (verification) / `E-000242` (correspondence,
  `equivalent`; the comparator verified that case-3 uniqueness follows from
  `toT_injective` plus constructor injectivity). Transcript
  `blocks/audits/B-P010-correspondence.md`.
- Scope dispositions for `B-A001`, `B-R024`, `B-P010` removed (now mapped); the
  earlier `deferred` rationales for `B-R024`/`B-P010` are superseded by the
  author-directed probe.
- `lean_audit`: **353 declarations** (was 349), 0 warnings, 0 unpermitted, 0
  `sorry`. Fast gate: **40 passed, 0 failed**; slow gate: **43 passed, 0 failed**.
  Journal `EV-000121`. Frontier unmapped **16 → 13**; `worth-formalizing`
  **1 → 0**.

**Probe result (B-C003).** The corollary `T_Σ ⊣ G_Σ` (the free-algebra functor is
left adjoint to the forgetful functor) needs the categories `Alg(Σ)`/`Set^S`, the
functor `T_Σ`, and a natural bijection of hom-sets; the encoding has no category
or functor infrastructure. It is a scope/representation decision, not a proof
gap, and remains deferred.

**Honest caveats.** (1) Same-model audit as always: all correspondence verdicts
are independent-context but share `deepseek-v4.1-flash`, and inherit the
pilot-encoding residuals (`carrier-model`, `small-large`, `univalence-missing`).
(2) `B-A001` is an assumption; naming it (`FiniteSorts`) records it as a mapped
object without pretending it is proved. Its companion `B-R024` shows the
hypothesis is equivalent to the free-support-finiteness property, so it is not
vacuous.

**Prioritized next steps.**

1. Author: the `B-P001` representation revision (class C6: S-sorted sets as
   subobjects of a universe) to close its `formal_weaker` gap; and the `B-C003`
   scope decision.
2. The 13 remaining unmapped blocks are all deferred illustrative remarks /
   examples (`B-C003`, `B-P036`, `B-R002`, `B-R004`, `B-R013`, `B-R015`,
   `B-R016`, `B-R019`, `B-R025`–`B-R027`, `B-X001`, `B-X002`). `B-R016` (the
   subfinal algebras form a formation) and `B-X001` (periodic algebras form a
   formation) carry genuine theorem content if the author re-tiers them.
3. Independent representation audit; a second model for the calibration suite.

---

## Session 114 -- 2026-09-20 -- B-R016, B-X001, and a B-P001 representation brief

**Goal.** Author-directed long run: formalize the two deferred blocks with real
content (`B-R016`, `B-X001`) and write the `B-P001` representation design brief.
Author re-tiered `B-R016`/`B-X001` from `deferred` to `worth-formalizing`
(`scope_decisions.json`, `author:session114`).

**What was established (closed, and mapped).**

- `B-R016` in `Formation.lean`: `subfinalAlgebras` (`Sf(1)`) and
  `subfinalAlgebras_isAlgebraFormation`. Both closure conditions reduce through
  `B-P008` (`subfinalAlg_iff`: subfinal = componentwise subsingleton). Evidence
  `E-000243` / `E-000244` (correspondence **`equivalent`**).
- `B-X001` in `Regular.lean`: `IsCyclicSub`, `IsPeriodicAlg`,
  `periodicAlgebras`, the infrastructure `directImage_Sg`,
  `directImage_deltaSub`, `finiteSSet_iAlg`, `finiteSSet_of_injective`, and the
  `H`-/`P_fsd`-closure lemmas, giving `periodicAlgebras_isAlgebraFormation`
  **under `[Finite S]`**. Evidence `E-000245` / `E-000246` (correspondence
  **`formal_weaker`**).
- `representation/p001-representation-brief.md`: a decision brief (PROPOSED,
  unaudited) analysing why `B-P001` is `formal_weaker`, the union-vs-quotient
  tension, the re-baseline cost of any C6 revision, and four options.
- `lean_audit`: **361 declarations** (was 353), 0 warnings, 0 unpermitted, 0
  `sorry`. Fast gate **40 passed, 0 failed**; slow gate **43 passed, 0 failed**.
  Journal `EV-000122`. Frontier unmapped **13 → 11**.

**Finding (a gap in the paper, not in the Lean).** `B-X001` -- `F_p` is a
formation -- is **false as stated for infinite `S`**. The subdirect-product
definition includes `n = 0`, whose empty product is the final algebra `1`; `1`
embeds subdirectly in itself, so `1 ∈ P_fsd(F_p)` for any `F_p`, forcing
`1 ∈ F_p`. But `1` need not be periodic: with `S` infinite and operations
`σ_n : () → n`, the cyclic subalgebra `Sg_1(δ^{t,*})` reaches every sort and is
infinite. The paper states `B-X001` in Section 5, before the `[Finite S]`
assumption `B-A001` (Section 7). The two-stage blind comparator independently
returned `formal_weaker` and reproduced the argument. The formalization proves
the true statement under `[Finite S]`; the gap is recorded, not hidden.

**Honest caveats.** (1) Same-model audit as always (`deepseek-v4.1-flash`);
`provisional` layers; inherits the pilot-encoding residuals (`carrier-model`,
`small-large`, `univalence-missing`). (2) `B-X001`'s Lean proof is more elaborate
than the paper's, needing `directImage_Sg` (generation commutes with direct
image) and the empty-product finiteness handled explicitly. (3) The brief
proposes no change; the representation revision remains author-reserved.

**Prioritized next steps.**

1. Author: the `B-P001` representation decision (brief above); the `B-C003`
   scope decision.
2. Remaining unmapped (11): all deferred illustrative remarks/examples
   (`B-C003`, `B-P036`, `B-R002`, `B-R004`, `B-R013`, `B-R015`, `B-R019`,
   `B-R025`–`B-R027`, `B-X002`).
3. Independent representation audit; a second model for the calibration suite.

---

## Session 115 -- 2026-09-20 -- B-X002, B-R019, B-P036 (content-bearing deferred batch)

**Goal.** Author-directed: formalize the last three content-bearing deferred
blocks. Author re-tiered them from `deferred` to `worth-formalizing`
(`scope_decisions.json`, `author:session115`).

**What was established (closed, and mapped).**

- `B-X002` in `Regular.lean`: `congFi_nonempty_iff` (`Cgr_fi(A) ≠ ∅ ↔ supp(A)`
  finite; forward via `supp_quot`/`finiteSSet_iff`, backward via
  `nabla_isCongruence`/`isFiniteIndex_nabla`) and
  `congFi_nonempty_of_finite_sorts` (`[Finite S]` ⇒ nonempty). Evidence
  `E-000247` / `E-000248` (**`equivalent`**).
- `B-R019` in `Translation.lean`:
  `syntacticCongruence_eq_congCogenerated` (definitional, since `B-D039` names
  `congCogenerated` the syntactic congruence). Evidence `E-000249` /
  `E-000250` (**`equivalent`**).
- `B-P036` in `Regular.lean`: `regularLanguageFormations_completeLattice`, the
  `CompleteLattice` part of `B-C013` (which also gives algebraicity). Evidence
  `E-000251` / `E-000252` (**`equivalent`**).
- `lean_audit`: **365 declarations** (was 361), 0 warnings, 0 unpermitted, 0
  `sorry`. Fast gate **40 passed, 0 failed**; slow gate **43 passed, 0 failed**.
  Journal `EV-000123`. Frontier unmapped **11 → 8**.

**Frontier now.** The 8 unmapped blocks are: content-free meta/future-work
remarks (`B-R002`, `B-R004`, `B-R013`, `B-R015`, `B-R025`, `B-R027`), the small
`B-R026` (existence of an infinite regular language), and `B-C003` (the
adjunction, needing category-theoretic infrastructure).

**Honest caveats.** Same-model audit (`deepseek-v4.1-flash`); `provisional`
layers; inherits the pilot-encoding residuals (`carrier-model`, `small-large`,
`univalence-missing`).

**Prioritized next steps.**

1. Author: the `B-P001` representation decision (Session 114 brief); the
   `B-C003` scope decision.
2. Optional: `B-R026` (infinite regular language) and a `light` treatment-tier
   pass to clear `provisional` layers.
3. Independent representation audit; a second model for the calibration suite.

---

## Session 116 -- 2026-09-20 -- B-R026 (an infinite regular language)

**Goal.** Author-directed: formalize `B-R026`, the last content-bearing deferred
block.

**What was established (closed, and mapped).**

- `B-R026` in `Regular.lean`: `exists_regular_infinite_language`, with the
  concrete witness (one sort `PUnit`, the empty signature, carrier `ℕ`, and
  `L = A`). `supp(A)` is the single sort (finite); `Ω^A(A) = ∇^A` has finite
  index (`isFiniteIndex_nabla`), so `L` is regular; and `L = A` is infinite.
  Evidence `E-000253` / `E-000254` (correspondence **`equivalent`**).
- `lean_audit`: **366 declarations** (was 365), 0 warnings, 0 unpermitted, 0
  `sorry`. Fast gate **40 passed, 0 failed**; slow gate **43 passed, 0 failed**.
  Journal `EV-000124`. Frontier unmapped **8 → 7**.

**Frontier now.** The 7 unmapped blocks are all content-free meta/future-work
remarks (`B-R002`, `B-R004`, `B-R013`, `B-R015`, `B-R025`, `B-R027`) plus
`B-C003` (the adjunction, needing category-theoretic infrastructure).

**Honest caveats.** Same-model audit (`deepseek-v4.1-flash`); `provisional`
layers; inherits the pilot-encoding residuals (`carrier-model`, `small-large`,
`univalence-missing`). The witness lives at universe 0 (`S = PUnit`, carrier
`ℕ`); the contract's existence claim is universe-agnostic.

**Prioritized next steps.**

1. Author: the `B-P001` representation decision (Session 114 brief); the
   `B-C003` scope decision.
2. The frontier is now exhausted of content-bearing blocks: the remaining 7 are
   meta-remarks with no formal content, or the category-theoretic `B-C003`.
3. Independent representation audit; a second model for the calibration suite; a
   `light` treatment-tier pass to clear `provisional` layers.

---

## Session 117 -- 2026-09-21 -- manuscript Lean pointers and the B-X001 correction

**Goal.** Author-directed manuscript update: add a visible pointer to the Lean
code next to every formalized block, and correct the statements the
formalization found false, highlighting the changes in red.

**What was established (closed).**

- **Lean pointers.** All 122 mapped blocks now carry `\lean{...}` (listing their
  mapped declaration names) on the line *before* `\blockid{...}`, rendered as a
  small monospace tag. The placement is deliberate: `hash_blocks.py` and
  `ingest.py` key the anchor to the `\blockid` immediately preceding
  `\begin{...}` and hash the environment body, so a pointer between `\blockid`
  and `\begin` would break the anchor, and one inside the environment would
  change the body hash. Placed before `\blockid`, the pointer changes **no**
  body hash (verified: only `B-X001` moved).
- **`B-X001` corrected in red.** The claim "the set `F_p` is a formation" is
  false for infinite `S` (Section 25.5). It now reads "**If `S` is finite,**
  then the set `F_p` is a formation", with a red note explaining the
  empty-product counterexample. `B-D033` had already been corrected in red
  (Session 71).
- **Evidence re-baseline.** Only `B-X001`'s `informal_statement` hash moved; its
  correspondence record was re-audited against the corrected contract and
  returned `equivalent` (**`E-000255`** supersedes `E-000246`). Its
  correspondence layer is now `provisional` (was `fail`). No other record
  staled.
- Manuscript build: exit 0, **55 pages** (was 49; the 122 pointer lines add ~6
  pages), 0 LaTeX warnings, 3 overfull hboxes (the baseline). Fast gate
  **40 passed, 0 failed**; slow gate **43 passed, 0 failed**. Journal
  `EV-000125`.

**Renderer choice (a gotcha worth recording).** A margin note (`\marginpar`)
overflowed the narrow margin on long declaration names and collided (10 margin
warnings at 122 blocks); an inline `\path`/`\detokenize` tag would not break at
the comma-spaces. The working form is a full-width
`\parbox{\linewidth}{\raggedright\footnotesize\texttt{...}}` with each name in
its own `\detokenize{...}`, which breaks at the inter-name spaces and keeps the
overfull count at the baseline 3.

**Prioritized next steps.**

1. Author: the `B-P001` representation decision (Session 114 brief); the
   `B-C003` scope decision.
2. Optional: extend the `\lean` pointers with the Lean *file* per block; a
   `light` treatment-tier pass to clear `provisional` layers.

---

## Session 118 -- 2026-09-21 -- B-R001 record correction and two derived-report fixes

**Goal.** Mechanical follow-up to the two independent block-by-block reports
(`Report_Claude.md`, `Report_Codex.md`): close the one audit defect they agree
on, and fix the derived-report defects Codex documented.

**What was established (closed).**

- **`B-R001` record corrected.** `E-000113` (`equivalent`) had a two-stage
  transcript that read back only the opening assertion
  `δ^{t,X} ≅ ∐_{x∈X} δ^t`. The same remark (line 289) also asserts that
  `{δ^s}` generates `Set^S`, that it is the set of atoms of `Sub(1^S)`, that
  `Sub(1^S) ≅ Sub(S)`, that each `δ^s` is projective, and that every map out of
  a `δ^s` is monic; none is mapped. Superseded by **`E-000256`**
  (`formal_weaker`, partial coverage); `blocks/audits/B-R001-correspondence.md`
  gained a "Full-block correction (Session 118)" section. `B-R001`
  correspondence layer is now `fail` (was `provisional`).
- **Trust boundary fixed.** `scripts/report.py` now reads
  `blocks/bridges.json` and excludes discharged obligations from the "Unproved
  bridge obligations" section (it had listed all five, which `bridges.json`
  marks proved). `frontier.py` already reported 0 open; the two now agree.
- **Discrepancy mapped universe fixed.** `scripts/discrepancy.py` derives the
  mapped universe from `blocks/formal.json` declarations
  (`load_mapped_blocks`) instead of formal-graph endpoints, so isolated mapped
  blocks `B-A001`, `B-D001`, `B-D029` are included. Universe 119→122;
  informal-only 38→40; unmapped 3→1; undecided 621→623 (the two new
  informal-only edges `B-D030→B-D029` and `B-P014→B-D029` enter the review
  queue). `load_mapped_blocks` has two new `discrepancy_test.py` checks.
- Reports regenerated in the Section 15.6 order; journal **`EV-000126`**. Fast
  gate **40 passed, 0 failed**; slow gate **43 passed, 0 failed** (Lean audit
  unchanged: 366 declarations, 0 `sorry`).

**Part 2 -- the five partial-map blocks audited (`EV-000127`).**

- **Ownership repaired (class C5).** `SortedMap` (`B-D015`→`B-D002`), `iCoprod`
  (`B-R001`→`B-D003`), `deltaT` (`B-R001`→`B-D006`), `quot` (`B-R005`→`B-D014`),
  `satSets` (`B-R007`→`B-D014`), `Sub_iUnion`/`Sub_iInter`
  (`B-D012`/`B-D010`→`B-D003`); and formerly unowned declarations claimed:
  `complA` (B-D003), `pr`, `eqvClass`, `nabla`, `sortedEqvLe`, `sortedEqvInf`,
  `sortedEqv_iInf` (B-D014). Deps' `definition_closure` is declaration-keyed, so
  these moves stale no dependent; affected verification/correspondence records
  were re-issued with `reissue_reason: remap`.
- **Cheap gaps formalized** in `lean/Mslang/Prelim.lean`: `Hom` (B-D002);
  `prod2`, `coprod2`, `iPair_unique`, `Sub_union`, `Sub_inter`, `Sub_sdiff`
  (B-D003); `deltaSingleton`, `delta_eq_deltaT_punit` (B-D006). Lean audit now
  **382 declarations**, 0 `sorry`, 0 unpermitted axioms.
- **Two-stage blind audits** (new transcripts under `blocks/audits/`):
  - `B-D003` **`equivalent`** (`E-000275`), `B-D006` **`equivalent`**
    (`E-000276`).
  - `B-D002` **`formal_weaker`** (`E-000274`): only the closing `Set^S`
    category clause is unmapped -- the same `CategoryTheory` blocker as
    `B-C003`, and a scope-decision candidate.
  - `B-D014` **`formal_weaker`** (`E-000277`): `Eqv(A)`, its
    algebraic-closure-system/algebraic-lattice structure, and `Delta^A` are
    unmapped (substantive).
  - `B-D024` **`formal_weaker`** (`E-000278`): `IsCongruence` faithfully
    generalizes the defining clause (drops the nonempty-arity restriction,
    `formal_stronger` there), but the `Cgr(A)` closure-system/lattice claims and
    `nabla^A`/`Delta^A` are unmapped (substantive).
- Fast gate **40 passed, 0 failed**; slow gate **43 passed, 0 failed**.

**Prioritized next steps.**

1. Formalize the `SortedEqv(A)` and `Cgr(A)` algebraic-closure-system/algebraic-
   lattice results (B-D014/B-D024) -- the remaining substantive correspondence
   gaps among the former partial-map blocks.
2. Author: scope decision for the `Set^S` category clause in `B-D002`; the
   `B-P001` representation decision (Session 114 brief); reclassify the unmapped
   frontier (`B-R002`, `B-R004`, `B-R015`, `B-R027` are content-bearing) and
   refresh `B-C003`'s rationale.
3. Add correspondence audits for the remaining 42 verification-only blocks.
4. Review the 604 undecided dependency edges by impact.

---

## Session 119 -- 2026-09-21 -- Eqv(A)/Cgr(A) algebraic closure systems and lattices

**Goal.** Close the last substantive correspondence gaps among the former
partial-map blocks (Session 118 step 1): formalize `Eqv(A)` and `Cgr(A)` as
algebraic closure systems / algebraic lattices with their extremal elements
`Δ`/`∇`, then re-audit the two blocks. No author-reserved decision was taken.

**What was established (closed).**

- `lean/Mslang/Prelim.lean` -- `deltaEqv` (moved here from `Translation.lean` /
  `B-R020`), `le_nabla`, `deltaEqv_le`, `PairSpace` (the Σ-encoded sorted product
  `A×A`), `EqvOn`, `univ_mem_EqvOn`, `sInter_mem_EqvOn`, `sUnion_mem_EqvOn`,
  `eqvToSet`, `eqvToSet_mem_EqvOn`, `setToEqv`, `eqvToSet_subset_iff`.
- `lean/Mslang/Algebra.lean` -- `EqvOn_isAlgebraicClosureSystemOn`,
  `eqvClosureOperator`, `eqvClosedSets_isAlgebraicLattice`, `eqvOrderIso`,
  `SortedEqv_isAlgebraicLattice` (the transport of the lattice across the
  inclusion/refinement order isomorphism).
- `lean/Mslang/Congruence.lean` -- `deltaEqv_isCongruence`, `CongOn`,
  `sInter_mem_CongOn`, `sUnion_mem_CongOn`, `CongOn_isAlgebraicClosureSystemOn`,
  `congClosureOperator`, `congClosedSets_isAlgebraicLattice`, `congOrderIso`,
  `congSubtypeCompleteLattice`, `Cgr_isAlgebraicLattice`.
- `lean/declarations.json`: `B-D014` gains 17 declarations, `B-D024` gains 10,
  `B-R020` loses `deltaEqv` (a class C5 ownership move to its natural block).
- Lean gate: **408 declarations, 0 `sorry`, 0 unpermitted axioms**.
- **Two-stage blind re-audits return `equivalent` for both blocks**:
  `B-D014` (`E-000279`, supersedes the Session 118 `formal_weaker` `E-000277`)
  and `B-D024` (`E-000280`, supersedes `E-000278`). Transcripts
  `blocks/audits/B-D014-correspondence.md`, `B-D024-correspondence.md`.
- Verification/correspondence re-issued for the moved/unblocked facets:
  `E-000281` (`B-D014` verification), `E-000282` (`B-D024` verification),
  `E-000283`/`E-000284` (`B-R020` verification/correspondence, `remap`).
- Manuscript `\lean` pointers extended for `B-D014`/`B-D024` and trimmed for
  `B-R020` to match `declarations.json`; the pointers sit before `\blockid`, so
  anchors and importer artifacts are unchanged (`hash_blocks --check`,
  `ingest --check` both current).
- Reports regenerated in the Section 15.6 order; journal **`EV-000128`**. Fast
  gate **40 passed, 0 failed**; slow gate **43 passed, 0 failed**.

**Findings.**

- `EqvOn` is the Σ-encoding of the S-sorted product `A×A`; `eqvOrderIso` /
  `eqvToSet_subset_iff` are the bridge between inclusion of pair-sets and the
  refinement order on `SortedEqv A`. This is the same `carrier-model` tension
  recorded for `B-P001` (D2), faithful under the pilot encoding.
- `B-D024`'s `IsCongruence` quantifies over **all** finite arities, including the
  empty word, whereas the manuscript restricts to `S* − {λ}`. The re-audit judged
  the difference **vacuous** (the nullary hypothesis is empty and the conclusion
  is reflexivity), so the block is `equivalent` without a scope decision -- in
  contrast to `B-D002`'s `Set^S` category clause, which remains a genuine gap.
- `deltaEqv` is now owned by `B-D014`, the block that introduces it as the least
  element of `Eqv(A)`; `B-R020` keeps `deltaEqv_eq_iInf_congCogenerated`.
- **Lean-gate caveat (audit determinism).** The previous session's
  `blocks/lean_audit.json` recorded `ok: false` on a
  `congSubtypeCompleteLattice ... semireducible` warning emitted while the module
  was being compiled; the warning is gone now that the declaration carries
  `@[instance_reducible]`. Because `lake build` only emits a module's warnings
  when it actually recompiles it, an incremental audit can silently show zero
  warnings. The Session 119 audit was re-run after deleting the module's olean so
  that the (clean) result is a *measured* one. Worth folding into the Section
  15.6 cost model: a `build_ok` audit should force-recompile the touched module,
  or the recorded warning set is only as fresh as the olean cache.

**Prioritized next steps.**

1. Author: scope decision for the `Set^S` category clause in `B-D002` (the last
   former partial-map gap); the `B-P001` representation decision (Session 114
   brief); reclassify the unmapped frontier and refresh `B-C003`'s rationale.
2. Add correspondence audits for the remaining verification-only blocks.
3. Review the undecided dependency edges by impact.

**Part 2 -- correspondence backlog cleared (`EV-000129`).**

Author-directed: re-audit the 46 blocks whose correspondence layer had gone
stale (the "mechanical debt"). All 46 were re-run through the two-stage blind
protocol in section batches; new records `E-000285`--`E-000330` supersede the
newest stale record of each block.

- **Verdicts:** 42 `equivalent`; `formal_stronger` for `B-C009` and `B-P026`
  (both drop a hypothesis); `formal_weaker` for `B-R012` (`Sub(1)` arithmetic and
  the `A/∇^A ≅` subalgebra-of-`1` isomorphism unmapped) and `B-X002` (the
  category examples `Sgr-Act`, `Mon-Act`, `Grp-Act`, `Mod` unmapped).
- **Staleness ledger:** 120 stale, **all superseded, 0 awaiting** (was 67
  awaiting). Correspondence status: 75 `provisional`, 5 `fail`
  (`B-D002`, `B-P001`, `B-R001`, `B-R012`, `B-X002`), 43 blocks with no
  correspondence layer.
- **Verdict moves vs the prior records:** `B-P005`, `B-P015` `formal_stronger`
  -> `equivalent`; `B-C007` -> `equivalent` (re-read with definition bodies);
  `B-R012`, `B-X002` -> `formal_weaker`.
- **Method caveat (recorded honestly).** Two extraction defects were caught and
  corrected mid-batch: (i) contracts taken from the block text alone omitted the
  section's standing Assumption `B-A001` (`S` finite), producing four false
  `formal_weaker` verdicts (`B-P032`, `B-P036`, `B-P038`, `B-P039`; re-compared
  with the assumption, all four are `equivalent`); (ii) the first excerpts showed
  supporting *definitions* statement-only, hiding their bodies, which flipped
  `B-C007`; the five non-`equivalent` blocks were re-read with full definition
  bodies. The batch protocol shares one stage agent across the blocks of a
  section, and all stages remain same-model (`provisional`).

**Prioritized next steps (after Part 2).**

1. Author decisions: `B-P001` representation brief; `B-D002` `Set^S` category
   scope; unmapped-frontier reclassification (`B-R002`, `B-R004`, `B-R015`,
   `B-R027`, `B-C003`).
2. The four remaining substantive correspondence gaps (`B-R001`, `B-R012`,
   `B-X002`, plus `B-D002`/`B-P001`): formalize or scope-triage each.
3. First-ever correspondence audits for the 43 mapped verification-only blocks.

**Part 3 -- first correspondence audits for the verification-only blocks (`EV-000130`).**

Same batch protocol as Part 2, for the **42** mapped blocks that had only
verification evidence (all definitions except `B-R022`/`B-R023`). New records
`E-000331`--`E-000372`; transcripts written.

- **Verdicts:** 34 `equivalent`; `formal_weaker` for `B-D010`, `B-D012`
  (the closure-operator half of the definition has no Lean counterpart),
  `B-D013` (the bundled `IsUniformAlgebraicClosureOperator` drops the
  closure-operator axioms), and `B-D021` (the finitary/algebraic clause of `Sg`
  is unmapped); `formal_stronger` for `B-D037` (drops `T ∈ Tl_t(A)_s`),
  `B-D038` (bundles `Ω^A(L)` as a `Setoid`), `B-D044` (`IsRegularLanguage`
  drops support-finiteness), and `B-R023` (drops the congruence hypothesis on
  `Ψ`).
- **The four `formal_weaker` verdicts cluster on one thing:** the manuscript's
  explicit `ClOp(A)`/`AClOp(A)` closure-operator notion is not formalized as a
  predicate. A single `IsClosureOperator`/Mathlib-`ClosureOperator` mapping
  (or a `B-D011`-level closure-operator block) would close `B-D010`/`B-D012`/
  `B-D013`; `B-D021` additionally needs the finitary characterization of `Sg`.
- Every block now has correspondence evidence except the **7 unmapped**
  (`B-C003`, `B-R002`, `B-R004`, `B-R013`, `B-R015`, `B-R025`, `B-R027`) and
  the **5 `fail`** layers (`B-D002`, `B-P001`, `B-R001`, `B-R012`, `B-X002`).
- Fast gate **40 passed, 0 failed**; reports regenerated, journal `EV-000130`.

**Prioritized next steps (after Part 3).**

1. Close the closure-operator cluster: formalize `ClOp(A)`/`AClOp(A)` (or map
   Mathlib's `ClosureOperator`) and the finitary `Sg` clause; re-audit
   `B-D010`, `B-D012`, `B-D013`, `B-D021`.
2. Author decisions: `B-P001` representation brief; `B-D002` `Set^S` category
   scope; unmapped-frontier reclassification (`B-R002`, `B-R004`, `B-R015`,
   `B-R027`, `B-C003`).
3. Scope-triage or formalize `B-R001`, `B-R012`, `B-X002`.

**Part 4 -- closure-operator cluster closed (`EV-000131`).**

- **Class C5 ownership remap.** `IsClosureOperator` moved `B-P005 -> B-D010` and
  `IsAlgebraic` moved `B-P005 -> B-D012`; the Lean comments in `Algebra.lean`
  already named them "the operator half of `B-D010`/`B-D012`". They were defined
  in `Prelim.lean`, hence the `decl_files` override. `B-P005` keeps the `sat_*`
  theorems about the saturation operator.
- **Formalization.** `IsUniformAlgebraicClosureOperator` extended to
  `IsClosureOperator c ∧ IsAlgebraic c ∧ IsUniform c` (it had omitted the
  closure-operator axioms); `MemSg_mono` and `Sg_isAlgebraic` added so `Sg` is
  finitary/algebraic.
- **Re-audits.** `B-D010`, `B-D012`, `B-D013`, `B-D021` are now **`equivalent`**
  (`E-000374`--`E-000377`, superseding the `formal_weaker` `E-000336`/`E-000338`/
  `E-000339`/`E-000346`). `B-P005`, whose statement changed by the remap,
  re-audits **`formal_stronger`** (`E-000373`: `sat_iInter_subset` drops the
  contract's nonempty-index hypothesis). Verification re-issued
  `E-000378`--`E-000382`.
- Lean gate **410 declarations, 0 `sorry`, 0 unpermitted**; manuscript **55
  pages**; full gate **43 passed, 0 failed**. Journal `EV-000131`.
- **Remaining frontier is only the 5 `fail` correspondence layers:** `B-D002`
  (`Set^S` category — scope decision), `B-P001` (carrier model — representation
  brief), `B-R001` (partial coverage), `B-R012` (`Sub(1)` arithmetic / the
  `A/∇^A ≅` subalgebra-of-`1` isomorphism), `B-X002` (category examples). All are
  author-facing or need new formalization, not mechanical cleanup.

**Part 5 -- frontier escalated to the author (`EV-000132`--`EV-000135`).**

With the mechanical debt cleared and the tractable formalization cluster closed,
the remaining frontier is reserved to the author; no agent-decidable work
remains. Four escalations were opened (queue: `reports/decisions.md`) and the
agent stopped rather than decide scope:

| escalation | block | decision |
|---|---|---|
| `EV-000132` | `B-P001` | accept the pilot encoding (scope the carrier operations) or revise the carrier model (C6) at `representation/p001-representation-brief.md` |
| `EV-000133` | `B-D002` | formalize `Set^S` as a category or scope the category clause out |
| `EV-000134` | `B-C003` | reclassify the 7 unmapped blocks (`B-C003`, `B-R002`, `B-R004`, `B-R013`, `B-R015`, `B-R025`, `B-R027`) |
| `EV-000135` | `B-R001` | formalize or scope out the residual prose clauses of `B-R001`, `B-R012`, `B-X002` |

Fast gate **40 passed, 0 failed**; `reports/decisions.md` and
`reports/frontier.md` regenerated, bundle updated.

---

## Session 120 -- 2026-09-21 -- author decision pass on the four open escalations

**Goal.** Clear the author-decision frontier escalated at the end of Session 119
(`EV-000132`--`EV-000135`). The user decided all four interactively; each was
recorded as an `escalation_resolved` journal event with a rationale, the affected
reports were regenerated, and the fast gate re-run after each. No author-reserved
decision was taken by the agent.

**What was established (closed).**

- **`EV-000132` (`B-P001`).** Author chose **Option 1**: accept the dependent-type
  encoding and keep `B-P001`'s arbitrary union/intersection/difference clauses as
  an accepted `formal_weaker` under the carrier-model/`D2` residual. No C6
  revision, no re-baseline. Rationale: the missing clauses are an instance of the
  already-declared `R-universe` residual (the Grothendieck-universe closure Lean
  cannot reproduce), and `B-P001` is a leaf (2 outbound symbol edges, no
  dependents), so no downstream fidelity is lost. Recorded `EV-000136`.
- **`EV-000133` (`B-D002`).** Author chose **Option 1**: scope out the closing
  clause "`Set^S` is the category of `S`-sorted sets and `S`-sorted mappings" and
  accept the `formal_weaker`; the definitional core (`SSet`/`SortedMap`/`Hom`) is
  faithful and machine-checked and no `CategoryTheory` layer is built. Recorded
  `EV-000137`. This is deliberately coupled with `EV-000134`: both category-theoretic
  items were declined together.
- **`EV-000134` (7 unmapped blocks).** Author accepted the recommended triage
  (`EV-000138`, resolution `EV-000139`): **out-of-scope** for `B-C003` and `B-R002`
  (category-theoretic; same declined infrastructure), `B-R013`/`B-R025` (pure
  forward references already discharged by the mapped `B-C006`/`B-C012`), and
  `B-R015` (Grothendieck-universe size bookkeeping); **worth-formalizing** for
  `B-R004` (single-sorted uniformity is automatic) and `B-R027` ((BPS1) follows
  from (BPS2)+(BPS3)). The frontier's open-obligation list is now exactly those two
  blocks.
- **`EV-000135` (`B-R001`/`B-R012`/`B-X002`).** Author accepted the recommendation
  to **scope out** all three residual prose clauses as illustrations (`EV-000140`,
  resolution `EV-000141`): `B-R001`'s categorical clauses (generating set
  `{δ^s}`, atoms of `Sub(1^S)`, `Sub(1^S) ≅ Sub(S)`, projectivity/monomorphisms)
  and `B-X002`'s example categories (`Sgr/Mon/Grp-Act`, `Mod`) need the declined
  `CategoryTheory` layer; `B-R012`'s `Sub(1)` classification is left as prose,
  recorded as the only non-category residual and a possible later small
  formalization.

**State after the pass.**

- Journal `EV-000136`--`EV-000141`; `decisions/standing.json` empty and
  **0 open escalations** (was 4). `blocks/scope_decisions.json` now
  **2 worth-formalizing / 0 deferred / 5 out-of-scope** over the 7 unmapped
  blocks. `reports/decisions.md`, `reports/frontier.md`, `reports/bundle.md`
  regenerated.
- The frontier's remaining non-passing layers are all **`provisional`**
  (same-model evidence, the dominant caveat of Architecture §25.3) plus the five
  **accepted** `formal_weaker`/scoped findings (`B-P001`, `B-D002`, `B-R001`,
  `B-R012`, `B-X002`). These are recorded steady states, not open obligations:
  the evidence records still read `formal_weaker`, which the author has accepted
  at the representation/scope level. No layer status was changed (a scope
  disposition is not evidence).
- Decision work committed as `d42c457`; slow gate (**43 passed, 0 failed**)
  re-run after the commit as the artifact of record.

**Prioritized next steps.**

1. Formalize the two `worth-formalizing` blocks: `B-R004` (single-sorted
   uniformity is automatic) and `B-R027` ((BPS1) redundant given (BPS2)+(BPS3)),
   each with fresh verification/correspondence evidence records.
2. Independent (cross-model) audit of the representation and of the positive
   layers, if a second model family becomes available -- the one caveat the
   project cannot remove with the current resources (Architecture §25.3 item 1).
3. No other agent-decidable work: the remaining frontier is the accepted scope
   decisions above.

---

## Session 121 -- 2026-09-21 -- formalize the two worth-formalizing blocks

**Goal.** Execute the only agent work created by the Session 120 decision pass:
formalize the two blocks the author marked `worth-formalizing`, `B-R004` and
`B-R027`, each with fresh verification/correspondence evidence.

**What was established (closed).**

- **`B-R004` (single-sorted uniformity is automatic).** Added
  `Mslang.isUniform_of_subsingleton_sorts` (`lean/Mslang/Algebra.lean`): over a
  `Subsingleton` sort type every extensive `S`-closure operator is uniform,
  because `suppSub X = ∅` forces `X` to be the empty subobject and extensivity
  carries a nonempty component to a nonempty component. Mapped in
  `lean/declarations.json`; manuscript `\lean` pointer added. Evidence
  **`E-000383`** (verification, `build_ok`) and **`E-000384`** (correspondence,
  **`formal_stronger`**: the Lean statement also covers the degenerate empty-sort
  case). Journal `EV-000142`.
- **`B-R027` (BPS1 redundant given BPS2+BPS3).** Added
  `Mslang.nabla_sat_mem_of_transPreimage_boolean` (`lean/Mslang/Regular.lean`):
  for finite `S` and nonempty `L(A)`, translation-preimage closure (BPS2) and
  Boolean closure (BPS3) imply that every `∇`-saturated subobject lies in `L(A)`
  (BPS1). The proof: `X ∈ L(A)` gives the full language by Boolean closure, the
  identity translation's preimage of the full language is the concentrated
  saturated language `δ^{t,*}`, and finite unions of the `δ^{t,*}` give every
  `∇`-saturated language. Evidence **`E-000385`** (verification, `build_ok`) and
  **`E-000386`** (correspondence, **`equivalent`**). Journal `EV-000143`.

**Finding (the empty-family subtlety, resolved in the paper's favour).**

- A first reading suggested `B-R027` was false: the constant family
  `L(A) = {∅, full}` looked like a model of (BPS2)+(BPS3) that omits the
  intermediate `∇`-saturated languages. That reading was wrong -- `{∅,full}` is
  not closed under translation preimages (`T⁻¹[full] = δ^{t,*}`, concentrated at
  the domain sort). The real edge is the **empty** family `L(A) = ∅`, which
  satisfies the closure clauses vacuously. The manuscript's (BPS3) says `L(A)` is
  a *Boolean subalgebra*, which contains `⊤`/`⊥` and hence is nonempty; the Lean
  hypothesis `hne` is exactly the formal counterpart of that containment, and the
  blind comparator judged the correspondence `equivalent` on that basis. No
  manuscript correction is needed.
- **Numbering note (still worth a future cleanup):** the Lean
  `IsBPSLanguageFormation` counts the preamble *regularity* clause as "BPS 1"
  (`Regular.lean`, comment at the forward direction), shifting the manuscript's
  (BPS1-4) to its clauses 2-5. `B-R027` refers to the manuscript's (BPS1), which
  is the `∇`-saturated clause (Lean clause 2).

**State after the session.**

- The frontier's open obligations are now **empty**: the 5 remaining unmapped
  blocks are all `out-of-scope` (`B-C003`, `B-R002`, `B-R013`, `B-R015`,
  `B-R025`). The non-passing layers are the `provisional` same-model layers plus
  the five accepted `formal_weaker`/scoped findings from Session 120.
- Lean gate **412 declarations, 0 `sorry`, 0 unpermitted, 0 warnings**; manuscript
  **55 pages** (0 errors, 0 warnings, 3 overfull hboxes). Fast gate **40/0**;
  slow gate **43/0**. Commits `595cfbb`, `1e08db6` (`B-R004`), `4aec128`
  (`B-R027`).

**Prioritized next steps.**

1. Independent (cross-model) audit of the representation and of the positive
   layers, if a second model family becomes available -- the one caveat the
   project cannot remove with the current resources (Architecture §25.3 item 1).
2. Optional cleanup: reconcile the BPS clause numbering between the manuscript
   and the Lean comments.
3. No other agent-decidable work: all four Session 120 decisions are recorded and
   the two resulting formalizations are closed.

---

## Session 122 -- 2026-09-21 -- first cross-model audits (Tier 1 of the brief)

**Goal.** Item 1 of Session 121's next steps just became actionable: this
session runs on `claude-sonnet-5` (family `claude`), a second model family.
Execute `blocks/audits/cross-model-audit-brief.md` Tier 1: the encoding audit
(Protocol A) and Protocol B (two-stage blind correspondence) on `B-P020`,
`B-P034`/`B-P039` (second Eilenberg theorem), `B-P035`. Declared
`claude-sonnet-5` in `calibration/models.json` first.

**What was established (closed).**

- **Encoding audit** of `representation/pilot-encoding.md`: a fresh, isolated
  agent (no repo access) rated it `faithful-with-caveat`, confirming the four
  named residuals (`R-universe`, `R-setoid`, `R-classical`, `R-ext`) and
  adding one new observation not named by the document itself:
  componentwise intersection/union of sorted subsets is not shown in the
  encoding table (follows trivially from `Sub A := ∀ s, Set (A s)` but is
  unevidenced), residual `R-union-inter-unevidenced`. **`E-000389`**
  (supersedes `E-000387`/`E-000388`: fixed producer-model attribution and
  residual-list formatting), `independence.class = cross_model` -- the
  project's **first non-`same_model` positive record**.
- **`B-P020` (first Eilenberg theorem, `FormAlgFormCgrIso`).** Two independent
  cross-model runs, both `equivalent`: `E-000390` (fully fresh double-`claude`
  stage1+stage2 redo, `same_model` since both stages ran on `claude`) and
  `E-000391` (reuses the existing Session-119 `deepseek-v4.1-flash` stage-1
  read-back with a fresh `claude` stage-2 comparator, per the brief's Section
  6 ingestion pattern -- `cross_model`). Correspondence flips `provisional`
  -> `pass`.
- **`B-P034` (second Eilenberg theorem, finite restriction) -- self-correction.**
  The fresh double-`claude` run (`E-000392`) first said `equivalent`, noting
  but underrating the absence of a `Finite S` hypothesis. A second run
  (reusing the deepseek read-back) called it `formal_stronger` instead.
  **Verified directly against `lean/Mslang/Regular.lean`**: none of
  `finiteSSet_of_isAlgIso`, `congruenceFormationOf_isFiniteIndex`,
  `algebraFormationOfCongruenceFormation_isFiniteAlgebra`, or
  `formAlgFFormCgrFiIso` take a `Finite S` hypothesis, while the manuscript's
  `B-P034` sits under the section-wide standing Assumption `B-A001` (`S`
  finite). This is a **real, source-confirmed generalization** the original
  same-model deepseek audit (`E-000319`, also `equivalent`) missed too.
  Corrected: `E-000392` superseded by `E-000393` (`same_model`,
  `formal_stronger`); `E-000394` is the `cross_model` record (also
  `formal_stronger`). Flagged for the author: accept the Lean's extra
  generality, or add a `Finite S` hypothesis to match `B-A001`.
- **`B-P035` (`Def1FRL` <=> `Def2FRL`) and `B-P039` (second Eilenberg theorem,
  `Form_Cgr_fi(Σ)` <-> `Form_Lang_r(Σ)`).** Both audited by reusing their
  existing deepseek stage-1 read-backs with a fresh `claude` stage-2
  comparator; both `equivalent`, both source-verified (a lesson learned from
  `B-P034`): `B-P035`'s two language-formation predicates need no `Finite S`
  (finiteness enters only via the shared `regularLanguages` typing clause the
  read-back correctly resolved a broad-vs-narrow inverse-image ambiguity
  against), and `B-P039`'s `formCgrFiFormLangRIso` correctly carries
  `[Finite S]`, unlike its sibling `B-P034`. `E-000395` (`B-P035`), `E-000396`
  (`B-P039`), both `cross_model`. Both flip `provisional` -> `pass`.
- Every stage ran as a **fresh, isolated agent** given only the pasted
  material (no repo access), matching the brief's independence rules; a
  Lean-side "own declarations + definition closure" package was built with a
  small reusable Python snippet (`lean_facets.extract_declarations`) rather
  than by hand, and manuscript contract packages were assembled by reading
  the relevant `\blockid{...}` blocks and their prerequisite definitions
  directly.

**Lesson for future cross-model sessions.** A stage-2 agent that notices an
absent ambient hypothesis (e.g. `Finite S`) and judges it "inconsequential"
should be treated as a hypothesis to verify, not a conclusion to accept --
the coordinator must grep/read the actual Lean source before trusting either
verdict when two independent runs disagree. This caught a real discrepancy
(`B-P034`) that both the original same-model audit and one of two cross-model
runs got wrong.

**State after the session.**

- `calibration/models.json` now declares two model families:
  `deepseek-v4.1-flash` (`deepseek`) and `claude-sonnet-5` (`claude`).
- Tier 1 of `blocks/audits/cross-model-audit-brief.md` is **complete**:
  representation (encoding) and `B-P020`/`B-P034`/`B-P035`/`B-P039`
  correspondence all now carry at least one `cross_model` positive record and
  show `pass` rather than `provisional` in `reports/coverage.md`.
  `B-P034`'s verdict changed from `equivalent` to `formal_stronger`
  (author-decision pending, see above); all others confirmed their prior
  same-model verdict.
  New audit transcripts: `blocks/audits/representation-encoding-crossmodel-claude.md`,
  `blocks/audits/B-P020-correspondence-crossmodel-{claude,mixed}.md`,
  `blocks/audits/B-P034-correspondence-crossmodel-{claude,mixed}.md`,
  `blocks/audits/B-P035-correspondence-crossmodel-mixed.md`,
  `blocks/audits/B-P039-correspondence-crossmodel-mixed.md`.
  New evidence: `E-000387`-`E-000396` (ten records; three are supersession
  corrections). Journal `EV-000144`-`EV-000147`.
- Fast gate **40/0** after each step (once briefly `39/1` on a missed
  `impact.py --report` regeneration, then `40/0`); slow gate **43/0** at
  session close. Commits `07cf7eb` (encoding + `B-P020`), `6ab179b`
  (`B-P034` + self-correction), `d0b1900` (`B-P035`/`B-P039`, Tier 1 done).

**Prioritized next steps.**

1. **Author decision pending:** `B-P034`'s Lean is `formal_stronger` than the
   manuscript (drops the section's `Finite S` assumption) -- accept the
   generalization, or add a `Finite S` hypothesis to `formAlgFFormCgrFiIso`
   (and its two supporting lemmas) to match `B-A001` exactly.
2. Continue the brief: Tier 2 (Protocol B on `B-C005`, `B-C006`, `B-C011`,
   `B-C012`, `B-C013`), Tier 3 (Protocol C adversarial reads on `B-C001`,
   `B-C002`), Tier 4 (re-confirm the five accepted `formal_weaker` findings
   cross-model: `B-P001`, `B-D002`, `B-R001`, `B-R012`, `B-X002`). Each
   correspondence block costs roughly one context-heavy session slice
   (Lean-closure + manuscript-contract extraction, two subagent calls,
   ingestion); budget accordingly rather than batching many per session.
3. Optional cleanup carried over from Session 121: reconcile the BPS clause
   numbering between the manuscript and the Lean comments.

---

## Session 123 -- 2026-09-22 -- all four tiers of the cross-model audit brief

**Goal.** Continue `blocks/audits/cross-model-audit-brief.md` per Session
122's item 2: Tier 2, Protocol B (two-stage blind correspondence) on the five
algebraic-lattice corollaries `B-C005`, `B-C006`, `B-C011`, `B-C012`,
`B-C013`; then, on request, Tier 3, Protocol C (adversarial read of a
reconstructed proof, Section 11a.5) on `B-C001`, `B-C002`; then, on further
request, Tier 4, cross-model re-confirmation of the five accepted
`formal_weaker` correspondence findings (`B-P001`, `B-D002`, `B-R001`,
`B-R012`, `B-X002`).

**What was established (closed).**

Tier 2 (correspondence, Protocol B):

- Reused the "mixed" ingestion pattern from Session 122's `B-P035`/`B-P039`
  (existing `deepseek-v4.1-flash` stage-1 read-back, verbatim or excerpted to
  the relevant theorem, plus a fresh, isolated `claude-sonnet-5` stage-2
  comparator with no repo access) for all five blocks, dispatched as five
  parallel subagents. Each stage-2 prompt for the `[Finite S]`-governed
  blocks (`B-C011`, `B-C012`, `B-C013`) explicitly carried the standing
  Assumption `B-A001` text and the Session-122 lesson (do not treat an
  ambient assumption as absent just because it is not restated locally).
- **All five verdicts: `equivalent`**, each confirming the existing
  same-model verdict with no discrepancy: `B-C005` (`E-000397`, confirms
  `E-000224`), `B-C006` (`E-000398`, confirms `E-000288`), `B-C011`
  (`E-000399`, confirms `E-000228`), `B-C012` (`E-000400`, confirms
  `E-000293`), `B-C013` (`E-000401`, confirms `E-000294`). All `cross_model`.
- Source-verified `B-C011`/`B-C012`/`B-C013` directly against
  `lean/Mslang/Regular.lean`: `finiteAlgebraFormationsCompleteLattice`,
  `finiteAlgebraFormations_isAlgebraicLattice`,
  `finiteIndexCongruenceFormations_isAlgebraicLattice`, and its complete
  lattice instance, `regularLanguageFormationsCompleteLattice`, and
  `regularLanguageFormations_isAlgebraicLattice` all carry `[Finite S]`,
  matching `B-A001` -- no `B-P034`-style gap on this trio.
- New transcripts: `blocks/audits/B-C0{05,06,11,12,13}-correspondence-crossmodel-mixed.md`.
  New evidence: `E-000397`-`E-000401`. Journal `EV-000148`. Commit `67c3c5d`.

Tier 3 (review, Protocol C -- adversarial read):

- Discovered en route that the brief's premise ("manuscript proof was
  reconstructed") is now slightly stale for these two blocks: commit
  `a76a26a` (Session ~4, 2026-09-15) already adopted the `deepseek`-authored
  `blocks/explanations/B-C001.md`/`B-C002.md` proofs into the manuscript
  verbatim. Used the accepted manuscript proof text as the package (it agrees
  with the explanation files), attributing the `coordinator` stage-role to
  `deepseek-v4.1-flash` (the original explanation author) and dispatching a
  fresh, isolated `claude-sonnet-5` adversarial reader with no project
  history for each block, per the brief's Section 6 adversarial-read pattern.
- **Both `RESULT: VALID`, no gap**, both re-confirming the existing
  same-model `pass` verdicts: `B-C001` (`E-000402`, confirms
  `E-000001`/`E-000038`), `B-C002` (`E-000403`, confirms
  `E-000012`/`E-000039`). Both `cross_model`.
- `B-C002`'s fresh reader independently rediscovered, unprompted beyond a
  general instruction to check whether every stated hypothesis is used, the
  exact observation already flagged in the explanation's own "notes for the
  adversarial reader": the `Ψ`-saturation hypothesis is logically unused (the
  proof only needs `X ∈ Φ-Sat(A)`, so it actually proves the stronger
  `Φ-Sat(A) ⊆ (Φ∩Ψ)-Sat(A)`, an immediate instance of `B-C001`/`IncSat`).
  Convergent confirmation, not a new finding.
- New transcripts: `blocks/audits/B-C001-adversarial.md`,
  `blocks/audits/B-C002-adversarial.md`. New evidence: `E-000402`,
  `E-000403`. Journal `EV-000149`. Commit `8cad997`.

Tier 4 (correspondence, Protocol B -- re-confirm/challenge five accepted
`formal_weaker` findings):

- Same "mixed" pattern (reused `deepseek-v4.1-flash` stage-1 read-back, fresh
  isolated `claude-sonnet-5` stage-2 comparator), but since the point was to
  genuinely confirm-or-challenge a *negative* finding rather than rubber-stamp
  it, each stage-2 prompt carried the **full** manuscript contract text (every
  clause, not a paraphrase) and an explicit instruction to go clause by
  clause and list every contract clause with no Lean counterpart. Dispatched
  as five parallel subagents.
- **All five verdicts: `formal_weaker`**, all confirming the existing
  same-model findings, each independently re-deriving the identical specific
  gap: `B-P001` (`E-000404` confirms `E-000236` -- general set-union of
  arbitrary sorted sets unformalized; intersection/difference restricted to
  `Sub A`), `B-D002` (`E-000405` confirms `E-000274` -- the `Set^S` category
  clause unformalized), `B-R001` (`E-000406` confirms `E-000265` -- only the
  delta-coproduct isomorphism formalized; generation/separation and items
  (1)-(4) on atoms/`Sub(1^S)`/projectivity/monomorphism unformalized),
  `B-R012` (`E-000407` confirms `E-000327` -- general subfinality theorem
  formalized; two worked examples, an existence claim, and a refinement
  corollary unformalized), `B-X002` (`E-000408` confirms `E-000330` -- the
  finite-index dichotomy formalized; the four concrete-category instantiation
  clauses `Sgr-Act`/`Mon-Act`/`Grp-Act`/`Mod` unformalized). All `cross_model`.
- These remain representation-level gaps (the pilot encoding cannot express
  unrelated-carrier set operations or category-theoretic structure), not
  proof gaps; `reports/coverage.md` correctly continues to show `fail` for
  correspondence on all five (cross-model independence confirms a negative
  finding, it does not turn it positive) -- now cross-model-confirmed rather
  than same-model-only.
- New transcripts:
  `blocks/audits/B-P001-correspondence-crossmodel-mixed.md`,
  `blocks/audits/B-D002-correspondence-crossmodel-mixed.md`,
  `blocks/audits/B-R001-correspondence-crossmodel-mixed.md`,
  `blocks/audits/B-R012-correspondence-crossmodel-mixed.md`,
  `blocks/audits/B-X002-correspondence-crossmodel-mixed.md`. New evidence:
  `E-000404`-`E-000408`. Journal `EV-000150`. Commit `a427b81`.

**All four tiers of `blocks/audits/cross-model-audit-brief.md` are now
complete.**

**State after the session.**

- `reports/coverage.md` shows `pass` rather than `provisional` for:
  correspondence on `B-C005`/`B-C006`/`B-C011`/`B-C012`/`B-C013`, and review
  on `B-C001`/`B-C002`. It continues to show `fail` (not `provisional`) for
  correspondence on `B-P001`/`B-D002`/`B-R001`/`B-R012`/`B-X002`, now backed
  by `cross_model` evidence -- an honestly-recorded, cross-model-confirmed
  representation limitation, not an open question.
- Fast gate **40/0** after each tier's ingestion; slow gate **43/0** run once
  after Tier 2 and again at session close after Tier 4.

**`B-P034` author decision -- resolved.** The author chose option 1 (accept
the generalization) of the Session-122 decision brief. Resolution: minted a
new Remark `B-R028` immediately after `B-P034`'s proof, recording in the
manuscript that the isomorphism holds for an arbitrary set of sorts `S`, not
just finite `S` -- the broader scope is now documented rather than left an
undocumented discrepancy. `B-P034` itself (proposition text, proof, body
hash) was left untouched, so its existing `formal_stronger` correspondence
verdict (`E-000392`-`E-000394`) still stands, accurately, as a reading of
that specific numbered proposition under the section's ambient Assumption
`B-A001`; `B-R028` is where the wider truth now lives. `B-R028` carries no
`\lean` pointer of its own (it cites the already-mapped
`formAlgFFormCgrFiIso` narratively, not as new formal content), so it is
correctly unmapped in `reports/coverage.md`, like other prose-only remarks.
Manuscript rebuilt: 55 pages, 0 warnings, 3 overfull hboxes, unchanged from
baseline; high-byte histogram unchanged. `blocks/hashes.json`: **164**
anchors (was 163); `blocks/registry.json`: **130** blocks (was 129). Journal
`EV-000151`. Commit `7357bc4`.

**Prioritized next steps.**

1. Protocol B on the remaining mapped blocks still `provisional` in
   `reports/coverage.md` (most of the ~124 mapped blocks -- Tiers 1-4 of the
   brief covered only the blocks flagged as high-priority or previously
   contentious). This is the brief's own "optional (large)" item and the
   only substantial audit work left it names. Budget roughly one
   context-heavy session slice per block, as the brief itself warns.
2. Optional cleanup carried over from Session 121: reconcile the BPS clause
   numbering between the manuscript and the Lean comments.

---

**Safe-restart checklist (run before touching anything).**

1. `git status` and `git log --oneline -10`; reconcile any dirty tree before
   trusting this file (Section 10.5).
2. `. scripts/env.sh`; expect the "project-local toolchain not installed"
   warning: `ELAN_HOME` points at the (empty) `./.elan`, so `elan` falls back
   to the machine toolchain. Export `MATHLIB_CACHE_DIR` is project-local. For
   Lean work run `lake` with `ELAN_HOME` unset (the v4.33.1 machine toolchain).
2b. Check disk before Lean work: `df -h /`. The extracted Mathlib oleans are
    5.9 GiB inside `lean/.lake`. Free space was **8.2 GiB** at Session 82 after
    the retired `~/Desktop/MathForm` (7.6 GiB) was deleted; it had fallen to
    128 MiB, at which point Lean work must stop until space is reclaimed.
3. Verify the manuscript baseline still holds: `./scripts/build_manuscript.sh`
   should exit 0 with a **55-page** PDF, 0 LaTeX warnings, 3 overfull hboxes
   (was 49 pages before the Session 117 `\lean` pointers). Each mapped block
   carries a `\lean{...}` pointer on the line *before* its `\blockid{...}`;
   never move a pointer between `\blockid` and `\begin` (it would break the
   anchor) or inside the environment (it would change the body hash).
4. Before editing the manuscript, run
   `python3 scripts/nonascii_scan.py manuscript/MSEilenberg.tex`.
5. After *every* manuscript edit, re-run
   `python3 scripts/hash_blocks.py --out blocks/hashes.json manuscript/MSEilenberg.tex`
   and check `blocks/hashes.json` by direct search, not just exit status.
   `blocks/hashes.json` currently holds **163** anchors (129 block IDs keyed to
   the `\blockid` preceding each environment, 33 proofs, 1 equation label
   `Eq1`).
6. After manuscript edits, also re-run
   `python3 scripts/ingest.py --aux manuscript/MSEilenberg.aux manuscript/MSEilenberg.tex`
   and inspect `reports/gap_report.md`; `blocks/hashes.json` anchors and
   `blocks/registry.json` body hashes must agree (both use
   `hash_blocks.normalize`).
7. Run the mechanical gate after any change, in tiers:
   `scripts/check_all.sh --fast` runs every check needing neither Lean
   compilation nor a PDF build (40 checks; seconds) and prints the Lean audit,
   `lean_audit.py`, and the manuscript build as `DEFERRED`, never as passes. At
   session close run `scripts/check_all.sh` once without `--fast`: it is the
   artifact of record and adds the Lean audit tests, the Lean mechanical gate
   (`scripts/lean_audit.py`, Architecture.md Section 15.6; rebuilds the project,
   audits axioms on every mapped declaration, scans for `sorry`), and the
   manuscript build. The slow tier takes ~2.5 min because it loads Mathlib
   oleans, so it is run once per session, not per edit.
8. After editing Lean, **do not run `lake build` as a standalone step** (it
   reloads the whole Mathlib olean graph, ~2.5 min, every time). Run
   `python3 scripts/lean_audit.py` **once**: it runs `lake build`, audits
   `#print axioms` for every declaration in `lean/declarations.json`, scans for
   `sorry`, and writes `blocks/lean_audit.json`. Then run
   `python3 scripts/lean_facets.py` (or `--check`) to re-hash the facets. Budget
   exactly one `lean_audit.py` and one `check_all.sh` run per session that
   touches Lean (see `Architecture.md` Section 15.6, Revision 4, for the cost
   model). The Lean
   sources are split by dependency layer under `lean/Mslang/`:
   `Prelim` -> `Algebra` -> `Congruence` -> `Subfinal`, with `Algebra` -> `Free`
   -> `Term`, `Subfinal` -> `Formation`, and `Congruence` -> `Translation`
   (Section 10.2); `Pilot.lean` no longer exists. Edit the module that owns the
   block and update its `file` in `lean/declarations.json` if a declaration
   moves (the facet hashes are text-based, so a pure move stales no evidence).
9. `scripts/validate_records.py --self-test` exercises the schema validator's
   rejection paths (old numeric IDs, unknown keys, missing required keys).
10. Do not edit or delete existing files under `evidence/` (the pre-commit
    hook enforces this); supersede with a new record instead.
11. Present reserved author decisions as **decision briefs**, one at a time
    (Architecture.md Section 16.4): a plain-language keynote, the concrete
    artifact to audit, the consequences, and numbered options. Mechanical
    decisions are the coordinator's to take and report, never to escalate.
12. `Architecture.md` is at **Revision 6 (program-complete)**. Revisions 3-5
    built the `§15.6` mechanical Lean gate (`scripts/lean_audit.py` +
    `blocks/lean_audit.json`, in `check_all`), the `§7.2`/`§8.1` supersession
    vocabulary, the `§6`/`§12.3` `definition_closure` facet split, computed
    independence and `provisional` status, and the tiered fast/slow gate.
    Revision 6 adds `§25` "Field notes from the completed formalization": the
    end state, the caveats (chiefly same-model evidence), the carrier-model
    tension, the paper-level findings, and the operational lessons. Keep the
    sections as normative spec; read `§25` first when planning a future
    project.
13. **Narrate the session as it runs** (`Architecture.md` §16.1; adopted by the
    author in Session 56, default level "step lines + rationale"): open with a
    banner (number, goal, numbered plan), emit a `step k/n: <action> -> <result>`
    line after each meaningful action or small batch with a sentence of
    rationale when the step is non-obvious, and surface decisions where they are
    made - not only in the final summary. The `STATE.md` entry is the post-hoc
    record; the live work log is what lets a human follow along without reading
    diffs.
