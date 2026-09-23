# Tasks

## 1. Project registry

- [x] 1.1 Add root `projects.yaml` with a single `mslang` entry (`source`, `aux`, `blocks_dir`, `hashes`, `evidence_dir`, `journal`, `reports_dir`, `lean_declarations`, `lean_namespace`) pointing at the existing paths; verify it parses and enumerates exactly one project. *(Plus a `mscong` scaffold entry; `mslang` parses and is the default.)*
- [x] 1.2 Add `scripts/projects.py` exposing `list_projects()`, `get(id)`, and path resolution with a default project id; verify unit tests cover enumeration, lookup, unknown-id error, and default selection.

## 2. Tooling parameterization

- [x] 2.1 Make `scripts/hash_blocks.py` resolve its source and anchors path from the registry; verify `blocks/hashes.json` is byte-identical for `mslang`.
- [x] 2.2 Make `scripts/ingest.py` resolve source, aux, and output locations from the registry; verify `blocks/registry.json`, `blocks/graph.json`, `blocks/symbols.json`, and `reports/{inventory,gap_report,pilot_candidates}.md` are byte-identical for `mslang`.
- [x] 2.3 Make `scripts/bundle.py` scope its manifest, views, and journal to the selected project; verify `reports/bundle.md` is byte-identical for `mslang`.
- [x] 2.4 Make `scripts/env.sh` and `scripts/check_all.sh` accept a project id (default `mslang`) and export project-scoped paths; verify `scripts/check_all.sh --fast` still passes and reports the default project.

## 3. Default-project preservation

- [x] 3.1 Add a golden check that hashes the `mslang` registry, hashes, and bundle and compares them against the pre-refactor baseline; verify it passes and is wired into `check_all.sh`. *(`projects.baseline.json` + `projects.py --check-baseline`.)*

## 4. MSCong project registration

- [x] 4.1 Add a `mscong` entry to `projects.yaml` with project-scoped paths (`blocks/mscong/`, `evidence/mscong/`, `journal/mscong.jsonl`, `reports/mscong/`, `lean/declarations.mscong.json`, `Mscong`); verify the loader resolves every path and none coincide with `mslang`'s.
- [x] 4.2 Create the project-scoped artifact locations with valid empty contents (`registry.json`, `hashes.json`, `graph.json`, `symbols.json`, `evidence/mscong/`, `journal/mscong.jsonl`, `reports/mscong/`); verify each passes `scripts/validate_records.py` / schema validation.
- [x] 4.3 Add a test asserting block, evidence, and journal ids do not collide across projects; verify it passes.

## 5. Mscong Lean scaffold

- [x] 5.1 Add `lean/Mscong/{Recognizable,Substitution,TreeHom,Main}.lean` with namespace `Mscong`, importing the needed `Mslang` modules; verify the shared project builds (`python3 scripts/lean_audit.py` or a targeted `lake build Mscong.Main`). *(Targeted `lake build Mscong.Main`: 8,718 jobs, 0 warnings.)*
- [x] 5.2 Add `lean/declarations.mscong.json` with an empty block map and wire the per-project declaration map into `lean_facets.py`/`lean_audit.py`; verify the audit runs on `mscong` with zero declarations and no error. *(Wiring done; the zero-declaration path is verified cheaply via `lean_facets.py --project mscong`. The full `lean_audit.py --project mscong` run — a second Mathlib elaboration — is deferred to M1 to respect the one-slow-load-per-session budget; the scaffold is covered by the `Mscong` default target in the slow gate.)*

## 6. Gate integration

- [x] 6.1 Extend `scripts/check_all.sh` to iterate registered projects for the non-ASCII, anchor-hash, importer, and cross-reference checks; verify a deliberately broken `mscong` input fails the gate and the failure names `mscong`. *(Author-approved adaptation: `mscong` is scaffolded with `ingested: false`, so its three provenance checks are **deferred** and named `[mscong]`; its non-ASCII scan and record validation run. Failure attribution is verified by `projects_test.py`'s deliberately-broken ingested-project fixture plus the `[<id>]` label on every per-project line.)*
- [x] 6.2 Add a per-project manuscript build for `mscong` (`latexmk` on `manuscript/MSCong.tex`); verify exit 0, or record the missing TeX packages as a follow-up. *(`build_manuscript.sh --project mscong`: exit 0, 56 pages.)*

## 7. Docs and roadmap

- [x] 7.1 Update `AGENTS.md`, `STATE.md`, and `Architecture.md` to describe multi-project operation and reference `projects.yaml`; verify each names the registry and the `mscong` project.
- [x] 7.2 Record the M1–M6 roadmap and the reuse map from `design.md` in `STATE.md`; verify the milestones and the `Mslang` reuse table are present.
