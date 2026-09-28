# Tasks

## 1. Manuscript reconciliation

- [ ] 1.1 Remove the stale `\ref{PRecIt}` from the commented-out proof
  (`manuscript/MSCong.tex` line 2911); confirm `check_crossrefs.py --audit`
  reports 0 undefined for `mscong`.
- [ ] 1.2 Rename the second multiply-defined `\label{TAntiHom}` (line 1872) to a
  unique label; check for `\ref` callers and update them or leave them if none.
- [ ] 1.3 Rebuild the `mscong` PDF (`scripts/build_manuscript.sh --project
  mscong`): exit 0, record the page count and warning delta.

## 2. Pilot block identities

- [ ] 2.1 Add `\providecommand{\blockid}[1]{}` to the `MSCong.tex` preamble
  (mirroring `MSEilenberg.tex`).
- [ ] 2.2 Add `\blockid{}`s for the six pilot environments (`B-D101` finite-index
  congruence definition, `B-P101` filter proposition, `B-D102` recognizability
  definition, `B-P102`/`B-P103`/`B-P104` = `PRecVar`/`PRecConst`/`PRecOp`),
  each on the line before its environment.
- [ ] 2.3 Re-hash and verify: `hash_blocks.py --project mscong` anchors equal
  the registry body hashes; the environment bodies are unchanged.

## 3. Ingested provenance

- [ ] 3.1 Set `projects.yaml` `mscong.source: manuscript/MSCong.tex`,
  `mscong.aux: manuscript/MSCong.aux`, and `mscong.ingested: true`.
- [ ] 3.2 Run `ingest.py --project mscong` (and `--check`), `hash_blocks.py
  --project mscong` (and `--check`); inspect `reports/mscong/gap_report.md`.
- [ ] 3.3 Confirm the gate's `[mscong]` anchor/importer/crossref lines now run
  and pass; `projects.py --check`, `--collisions`, and `--check-baseline` pass.

## 4. Declaration map and formal facets

- [ ] 4.1 Add the pilot entries to `lean/declarations.mscong.json`
  (`PRecVar`, `PRecConst`, `PRecOp`, and the definition counterparts).
- [ ] 4.2 Run `lean_facets.py --project mscong` to write
  `blocks/mscong/formal.json`; verify `--check` is current.
- [ ] 4.3 Run `lean_audit.py --project mscong`: every mapped declaration's
  axioms lie within the permitted set; 0 `sorry`.

## 5. Project dimension for the evidence tools

- [ ] 5.1 Add `--project` to `closure.py`, `status.py`, `evidence.py`,
  `report.py`, and `trust.py`, resolving paths through `projects.py`; default
  stays `mslang` and emitted bytes are unchanged.
- [ ] 5.2 Assert no `mslang` artifact changed: `check_all.sh --fast` green,
  `report.py --check`, `bundle.py --check-report`, `--check-baseline` pass.

## 6. Correspondence audits and evidence

- [ ] 6.1 Run the two-stage blind correspondence audit for `PRecVar`,
  `PRecConst`, and `PRecOp`; save transcripts under
  `blocks/mscong/audits/`.
- [ ] 6.2 Record each verdict with `evidence.py --project mscong` (computed
  inputs, independence caveat); validate with `validate_records.py`.
- [ ] 6.3 Derive `status.py --project mscong` and confirm the pilot's per-layer
  status; regenerate `reports/mscong/bundle.md` and append the `mscong` journal
  events.

## 7. Gate and archive

- [ ] 7.1 `scripts/check_all.sh --fast` green; one slow `scripts/check_all.sh`
  green; record any stale-premise test fix.
- [ ] 7.2 Archive the change and sync `formalization/mcong-correspondence`;
  record the session in `STATE.md` (pilot scope, deferred full mapping,
  `Sig_d`/`Alg_d`/`PRecILH` caveat) and the `mscong` journal event(s).
