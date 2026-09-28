# mcong-correspondence Specification

## Purpose

Defines the M6 deliverable for the `mscong` project: the pilot correspondence
audit that gives `MSCong.tex` §3.1 block identities, ingested provenance, a
declaration map, and two-stage blind correspondence evidence, proving on a
small dependency-closed cluster that the evidence model scales to a second
manuscript without disturbing the default project.

## Requirements

### Requirement: Pilot block identities

The `mscong` project SHALL mint `\blockid{}`s for the pilot cluster only: the
finite-index congruence definition, its filter proposition, the recognizability
definition, and the three §3.1 propositions `PRecVar`, `PRecConst`, and
`PRecOp`. Each `\blockid{}` SHALL be placed on the line before its environment
and SHALL lie outside the `mslang` ID space.

#### Scenario: Pilot cluster is identified

- **WHEN** the pilot is complete
- **THEN** `blocks/mscong/registry.json` contains exactly the six pilot blocks,
  each with its `\blockid` anchor and body hash, and
  `projects.py --collisions` reports no block ID shared with `mslang`

#### Scenario: Block IDs do not disturb the environment body

- **WHEN** a `\blockid{}` is added before an environment
- **THEN** the environment's body hash is unchanged from before the annotation

### Requirement: Ingested `mscong` provenance

The `mscong` project SHALL be ingested, so that the anchor-hash, importer-drift,
and cross-reference checks run for it rather than being deferred.

#### Scenario: Provenance checks run for `mscong`

- **WHEN** the gate runs after the pilot
- **THEN** `mscong.ingested` is `true`, `hash_blocks.py --project mscong
  --check` and `ingest.py --project mscong --check` pass, and the
  cross-reference audit reports no undefined reference

#### Scenario: Manuscript defects reconciled

- **WHEN** the manuscript is ingested
- **THEN** the stale `\ref{PRecIt}` no longer appears, no label is defined twice
  in `MSCong.tex`, and the `mscong` manuscript still builds

### Requirement: Declaration map and formal facets

The pilot blocks SHALL be mapped to their Lean declarations in
`lean/declarations.mscong.json`, and the mechanical Lean gate SHALL produce
formal statement/proof facets for every mapped declaration.

#### Scenario: Formal facets from the map

- **WHEN** the declaration map is present
- **THEN** `lean_facets.py --project mscong` writes
  `blocks/mscong/formal.json` for the mapped declarations, and
  `lean_audit.py --project mscong` audits their axioms within the permitted set

### Requirement: Two-stage blind correspondence

For each pilot proposition the development SHALL run the two-stage blind
correspondence audit and SHALL record the verdict as a correspondence evidence
record, with the same independence caveat the default project records.

#### Scenario: Correspondence verdict recorded

- **WHEN** the two-stage audit is run for a pilot proposition
- **THEN** a transcript is saved under `blocks/mscong/audits/` and an
  `evidence/mscong/E-*.json` correspondence record carries the stage-2 verdict,
  its computed inputs, and the independence caveat

### Requirement: Project dimension for the evidence tools

The evidence, status, and view tools SHALL accept a project selection so the
pilot can be audited for `mscong`; with no selection they SHALL behave exactly
as before.

#### Scenario: `mscong` status is derived

- **WHEN** `status.py --project mscong` runs on the pilot evidence
- **THEN** it reports the pilot blocks' per-layer status from the `mscong`
  registry, hashes, and records

#### Scenario: Default project unchanged

- **WHEN** any project-aware tool is invoked without `--project`
- **THEN** its output is byte-identical to the pre-change `mslang` output

### Requirement: Default project untouched

The pilot SHALL leave the default project's artifacts unchanged.

#### Scenario: Golden baseline current

- **WHEN** the pilot is complete
- **THEN** `projects.py --check-baseline` passes, the `mslang` registry, hashes,
  and bundle are unchanged, and the gate reports no failure

### Requirement: Deferred full mapping

The pilot SHALL NOT map the remaining `MSCong.tex` environments, the
`Sig_d`/`Alg_d` category layer, or `PRecILH`, and SHALL record the deferral.

#### Scenario: Full mapping out of scope

- **WHEN** the pilot is complete
- **THEN** only the pilot cluster is mapped, and the deferral is recorded in
  `STATE.md` and the change design
