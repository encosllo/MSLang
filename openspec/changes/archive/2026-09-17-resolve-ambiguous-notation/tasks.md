# Tasks

## 1. Author-reserved resolution store

- [x] 1.1 Add `blocks/notation.json` with the documented shape (a `note` plus a
  `resolutions` map keyed by compound notation identity, each entry carrying a
  `resolution`, `decided_by`, and `rationale`); verify `python3
  scripts/notation.py --check` passes on the empty store.
- [x] 1.2 Implement `scripts/notation.py` with `--list`, `--check`, and
  `set --notation ... --resolution ...`, mirroring `scripts/scope.py` and
  refusing any `decided_by` that does not begin with `author:`; verify via 1.3.
- [x] 1.3 Add `scripts/notation_test.py` covering a valid `block` resolution, a
  valid `ambient` resolution, an invalid target, and an agent `decided_by`
  refusal; verify the test file runs green.
- [x] 1.4 Register the store validation in `scripts/check_all.sh`; verify
  `scripts/check_all.sh --fast` reports the notation check and passes.

## 2. Compound-aware notation identity

- [x] 2.1 Implement compound notation identity (base token plus normalized
  subscript chain) in `scripts/ingest.py`; verify unit tests distinguish
  `Alg`/`Alg_f`, `Cgr`/`Cgr_fi`, `Sub`/`Sub_f`, and `Form_*`.
- [x] 2.2 Verify `f` and `fi` no longer appear as standalone notation tokens and
  produce no edges or unresolved rows.
- [x] 2.3 Add a determinism check on a fixture; verify two extraction runs
  produce an identical notation map and identical candidates.

## 3. Sentence-scoped introducer detection

- [x] 3.1 Replace the fixed cue window with sentence-scoped definee detection in
  `scripts/ingest.py`; verify a fixture attributes `Alg` to `B-D017` and drops
  the false owners `B-D031`/`B-D032`/`B-D034`/`B-D042`/`B-D043`.
- [x] 3.2 Verify mention-only definitions are not owners; cover `Hom` with
  `B-D035`/`B-D036` as the negative fixture.
- [x] 3.3 Verify an unparsable notation declaration is reported as an error and
  no partial notation map is emitted.

## 4. Resolution order and staged candidate edges

- [x] 4.1 Consult `blocks/notation.json` before the mechanical heuristic and
  fall back to it only when no resolution is recorded; verify an author
  resolution overrides a mechanical owner in a test.
- [x] 4.2 Emit recovered edges as unconfirmed candidates and `ambient` notations
  as none; verify closure computation and layer statuses are unchanged while the
  candidates are unconfirmed.
- [x] 4.3 Preserve previously confirmed edges across reassignment; verify a
  confirmed edge whose endpoint changed remains present and is re-confirmed
  through `blocks/edge_decisions.json`.

## 5. Report and drift check

- [x] 5.1 Extend `blocks/symbols.json` with each notation identity's resolution
  state and use count, and rewrite gap report section 7 to show resolution
  state, candidate owners, affected blocks, and candidate-edge counts; verify the
  regenerated report lists every notation's state.
- [x] 5.2 Add an `ingest.py --check` drift check on `reports/gap_report.md`;
  verify a manual edit fails the check and regeneration makes it pass.

## 6. Gate wiring and integration

- [x] 6.1 Add the new unit tests to `scripts/check_all.sh`; verify
  `scripts/check_all.sh --fast` runs them and passes.
- [x] 6.2 Run `python3 scripts/ingest.py` to regenerate registry, symbols, graph,
  and reports; verify recovered edges appear unconfirmed and the fast gate is
  green.

## 7. Migration and author pass

- [x] 7.1 Diff confirmed edges before and after regeneration; verify no
  confirmed edge is silently dropped and re-confirm any edge whose endpoint
  changed.
- [x] 7.2 Record the author resolutions for `Hom`, `supp`, `Omega`, and `Alg`'s
  owner in `blocks/notation.json`; verify `python3 scripts/notation.py --check`
  passes and extraction consumes them.
- [ ] 7.3 Confirm the recovered edges incrementally, watching staled evidence;
  verify each confirmation records its decision and updates closures and
  staleness as expected.
  **Deferred by author decision** (this change stops at candidates): confirming
  any recovered edge stales current evidence (all 113 do; confirming all stales
  59 of 72 statement-layer records), so confirmation is a follow-up tied to an
  evidence re-issue plan, not part of this change.
- [x] 7.4 Regenerate views and the bundle in the project's standard order; verify
  the slow `scripts/check_all.sh` passes and the notation report is
  drift-checked.
