# Tasks

## 1. Mint the remaining block IDs

- [ ] 1.1 Assign IDs in document order from the registry's `proposed` blocks
  (per-kind `0xx` counters, pilot IDs kept); write a deterministic mint script
  or inline pass.
- [ ] 1.2 Insert `\blockid{}` immediately above each proposed block's `\begin`
  line (latin1-safe; one pass against original indices).
- [ ] 1.3 Verify: the ASCII/non-ASCII scan passes, the body hashes of the six
  pilot blocks are unchanged, and `check_crossrefs.py --audit` still reports 0
  undefined.

## 2. Re-ingest

- [ ] 2.1 `hash_blocks.py --project mscong --out blocks/mscong/hashes.json`.
- [ ] 2.2 `ingest.py --project mscong`; confirm **0 proposed** and inspect
  `reports/mscong/gap_report.md`.
- [ ] 2.3 `hash_blocks.py --project mscong --check`, `ingest.py --project
  mscong --check`; `projects.py --check/--collisions/--check-baseline`.

## 3. Declaration map

- [ ] 3.1 Extend `lean/declarations.mscong.json` for the documented
  counterparts (M1–M5 results and the pilot definitions).
- [ ] 3.2 `lean_facets.py --project mscong` (and `--check`);
  `lean_audit.py --project mscong` (0 warnings, 0 `sorry`, permitted axioms).

## 4. Views, journal, state

- [ ] 4.1 `report.py --project mscong`, `bundle.py --project mscong`,
  `status.py --project mscong`; confirm the pilot records stay current.
- [ ] 4.2 Append the `mscong` journal event(s) and record the session in
  `STATE.md` (full mapping, deferred audits, `Sig_d`/`Alg_d`/`PRecILH` caveat).

## 5. Gate and archive

- [ ] 5.1 `scripts/check_all.sh --fast` green; one slow `scripts/check_all.sh`
  green.
- [ ] 5.2 Archive the change and sync `formalization/mcong-full-mapping`.
