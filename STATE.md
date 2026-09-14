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
6. Do not edit or delete existing files under `evidence/` (the pre-commit
   hook enforces this); supersede with a new record instead.
