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

**Safe-restart checklist (run before touching anything).**

1. `git status` and `git log --oneline -10`; reconcile any dirty tree before
   trusting this file (Section 10.5).
2. `. scripts/env.sh`; expect the "project-local toolchain not installed"
   warning: `ELAN_HOME` points at the (empty) `./.elan`, so `elan` falls back
   to the machine toolchain. Export `MATHLIB_CACHE_DIR` is project-local. For
   Lean work run `lake` with `ELAN_HOME` unset (the v4.33.1 machine toolchain).
2b. Check disk before Lean work: `df -h /`. The extracted Mathlib oleans are
   5.9 GiB; free space was ~1.3 GiB after the Session 9 fetch.
3. Verify the manuscript baseline still holds: `./scripts/build_manuscript.sh`
   should exit 0 with a 49-page PDF.
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
7. Run the whole mechanical gate after any change:
   `scripts/check_all.sh` (27 checks; exits non-zero on any failure). It covers
   the non-ASCII scan, anchor hashes, importer drift, cross-references, the
   hygiene/propagation/status/trust/Lean-facet/Lean-audit/calibration/impact/
   discrepancy tests, decisions and bundle drift, record validation, view
   drift, and the build. The Lean mechanical gate (`scripts/lean_audit.py`,
   Architecture.md Section 15.6) rebuilds the project, audits axioms on all 100
   mapped declarations, and scans for `sorry`; it takes ~2.5 min because it
   loads Mathlib oleans, so `check_all` is no longer seconds-fast.
8. After editing Lean, rebuild and re-hash:
   `(unset ELAN_HOME; cd lean && lake build)` then
   `python3 scripts/lean_facets.py` (or `--check`). Confirm
   `#print axioms` on the new theorems stays within the permitted set.
9. `scripts/validate_records.py --self-test` exercises the schema validator's
   rejection paths (old numeric IDs, unknown keys, missing required keys).
10. Do not edit or delete existing files under `evidence/` (the pre-commit
    hook enforces this); supersede with a new record instead.
11. Present reserved author decisions as **decision briefs**, one at a time
    (Architecture.md Section 16.4): a plain-language keynote, the concrete
    artifact to audit, the consequences, and numbered options. Mechanical
    decisions are the coordinator's to take and report, never to escalate.
12. `Architecture.md` is at **Revision 3 (frontier-hardened)** (Session 48,
    `EV-000053`). Implemented in Session 49: the `§15.6` mechanical Lean gate
    (`scripts/lean_audit.py` + `blocks/lean_audit.json`, wired into
    `check_all`). **Still not implemented**: the `definition_closure` facet
    split (`§6`/`§12.3`; `lean_facets.py` still folds the closure into
    `formal_statement`) and the `supersedes`/`reissue_reason` evidence fields
    (`§7.2`; the schema is unchanged, re-issues are noted in `findings` prose).
    Until those land, treat those sections as target state; keep re-issuing per
    the Session 43 rule and the `independence_caveat` convention.
