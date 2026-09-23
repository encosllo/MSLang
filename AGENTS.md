# Agent workflow notes (MSLang)

Operational rules for working in this repo. They exist to keep sessions fast.
`STATE.md` (its safe-restart checklist) remains the ground-truth process; this
file is the operational restatement of `Architecture.md` Section 15.6
(Revision 6), which is the normative source for the Lean-gate cost model.

## Rules

1. **Never run `lake build` as a standalone step.** One
   `python3 scripts/lean_audit.py` covers build diagnostics, `#print axioms` for
   every declaration in `lean/declarations.json`, and the `sorry` scan, and
   writes `blocks/lean_audit.json`. While *developing* a hard proof, a targeted
   `lake build Mslang.<Module>` (one process, the edited module only) is the
   minimal check and is the intended way to iterate; the final artifact must
   still come from one `lean_audit.py` run and one *slow* `check_all.sh` run.
2. **Use the fast gate per edit; budget one slow `check_all.sh` per session.**
   `scripts/check_all.sh --fast` runs every check that needs neither Lean
   compilation nor a PDF build (seconds), and reports the Lean audit and
   manuscript build as `DEFERRED`, never as passes. Run it after each change. At
   session close run `scripts/check_all.sh` once: it is the artifact of record
   and includes `lean_audit.py --check` and the manuscript build. If the slow
   gate fails, read only the failing check, fix that, and re-run once — do not
   loop.
3. `--skip-build` changes the emitted payload, so it fails `lean_audit.py
   --check`. Use it only as a quick mid-edit axiom probe, never to produce the
   artifact or to satisfy `check_all`.
4. **Batch independent commands into one message** (parallel tool calls). Never
   re-run a command whose output you already have — search the captured output
   instead. A redundant `lake` call is the single most expensive mistake here.
5. Prefer `--check`/dry-run modes (`lean_facets.py --check`, `frontier.py
   --check-report`, `report.py --check`, `bundle.py --check-report`,
   `validate_records.py`) before regenerating; they are seconds-fast and locate
   exactly the drift.
6. Regeneration order when views/bundle are involved: `report.py`,
   `calibration.py --report`, `impact.py --report`, `discrepancy.py --report`,
   `sanity.py --report`, `frontier.py --report`, `reconcile.py --report`, then
   the journal event, then `decisions.py --report`, then `bundle.py`. `bundle.py`
   embeds the journal and the other reports, so it is always last.
7. **Never edit `manuscript/MSEilenberg.tex` with the `edit` tool** — it decodes
   latin1 as UTF-8 and corrupts the six legitimate high bytes. Read/modify/write
   with Python `open(..., encoding='latin1')`, then verify the high-byte
   histogram is unchanged (see `STATE.md` safe-restart step 5).
8. `evidence/` is append-only: never edit or delete; supersede with a new record
   via `python3 scripts/evidence.py new --supersedes E-XXXXXX ... --write`.
9. **More than one manuscript project lives here; never hardcode a manuscript
   filename.** `projects.yaml` is the registry: it names each project's TeX
   source/`.aux`, block registry and hash anchors, evidence/journal/report
   scope, and Lean namespace/declaration map. `mslang` (`MSEilenberg.tex`) is
   the default and keeps its original top-level paths; `mscong`
   (`MSCong.tex`) is namespaced (`blocks/mscong/`, `evidence/mscong/`,
   `journal/mscong.jsonl`, `reports/mscong/`, `lean/declarations.mscong.json`).
   Resolve paths with `python3 scripts/projects.py --field <id> <key>` (or
   `--env <id>`); `hash_blocks.py`, `ingest.py`, `bundle.py`, `lean_facets.py`,
   and `lean_audit.py` take `--project <id>`. `scripts/check_all.sh` runs the
   source-dependent checks once per registered project and names it in each
   line (`[mslang]`, `[mscong]`); a project with `ingested: false` has those
   checks **deferred**, never reported as passing. `Mscong.*` shares this Lake
   project and Mathlib and imports `Mslang.*`.
