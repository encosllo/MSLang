# mcong-full-mapping Specification

## Purpose

Defines the full-manuscript block mapping for the `mscong` project: complete
block identities for `MSCong.tex`, a fully ingested registry, a curated
declaration map, and project-scoped views — extending the six-block M6 pilot to
the whole paper without disturbing the default project.

## Requirements

### Requirement: Complete block identities

Every importer-visible theorem-like environment in `MSCong.tex` SHALL carry a
stable `\blockid{}` in the `mslang` `B-<letter><NNN>` grammar, keyed to its
kind, and the pilot's six IDs SHALL be preserved unchanged.

#### Scenario: No proposed blocks remain

- **WHEN** the full mapping is complete
- **THEN** `blocks/mscong/registry.json` reports `0 proposed` and every block
  carries an `id`, and `ingest.py --project mscong --check` passes

#### Scenario: Pilot identities and hashes are preserved

- **WHEN** the new IDs are inserted
- **THEN** the six pilot blocks still carry `B-D101`, `B-P101`, `B-D102`,
  `B-P102`, `B-P103`, `B-P104`, and their body hashes are unchanged

#### Scenario: ID spaces stay disjoint

- **WHEN** both projects are ingested
- **THEN** `projects.py --collisions` reports no block ID shared between
  `mslang` and `mscong`

### Requirement: Ingested full registry and graph

The `mscong` registry, anchor hashes, symbols, and dependency graph SHALL be
regenerated for the complete environment set.

#### Scenario: Artifacts are current

- **WHEN** the mapping is complete
- **THEN** `hash_blocks.py --project mscong --check` and `ingest.py --project
  mscong --check` pass, and `reports/mscong/gap_report.md` lists no unmarked
  theorem-like environment

### Requirement: Curated declaration map

Blocks with a documented Lean counterpart SHALL be mapped in
`lean/declarations.mscong.json`, and the formal facets SHALL be regenerated
for every mapped declaration.

#### Scenario: Formal facets for all mapped blocks

- **WHEN** the declaration map is extended
- **THEN** `lean_facets.py --project mscong` writes a `formal_statement`/`formal_proof`
  entry for every mapped block with no error, and `lean_audit.py --project
  mscong` audits their axioms within the permitted set

#### Scenario: Unmapped blocks are declared

- **WHEN** a block has no Lean counterpart
- **THEN** it is absent from the declaration map and reported as unmapped, not
  silently dropped

### Requirement: Project-scoped views and bundle

The `mscong` views and evidence bundle SHALL be regenerated for the full
registry, and the default project SHALL be untouched.

#### Scenario: Views cover the full registry

- **WHEN** `report.py --project mscong` runs
- **THEN** the generated views cover the full block set, and `bundle.py
  --project mscong` embeds the updated registry and journal

#### Scenario: Default project unchanged

- **WHEN** the full mapping is complete
- **THEN** `projects.py --check-baseline` passes and no `mslang` artifact
  changes

### Requirement: Deferred audits and category layer

The change SHALL NOT run per-block correspondence/review audits for the newly
mapped blocks, formalize the `Sig_d`/`Alg_d` layer, or implement `PRecILH`, and
SHALL record the deferral.

#### Scenario: Audits deferred

- **WHEN** the mapping is complete
- **THEN** no new evidence record is added outside the pilot, and the deferral
  is recorded in `STATE.md` and the change design
