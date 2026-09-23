# Spec Delta

## Purpose

Lets the workspace carry more than one manuscript formalization at once: a
declarative registry names each project, and the ingestion, hashing, gate,
evidence, and bundle tooling operate per project instead of against a single
hardwired manuscript.

## ADDED Requirements

### Requirement: Project registry

The workspace SHALL declare each manuscript formalization project in one
registry that names, per project, a stable project id, the manuscript TeX
source and its `.aux`, the block registry and hash-anchor locations, the
evidence, journal, and report scope, and the Lean namespace.

#### Scenario: Registry enumerates projects

- **WHEN** the registry is read
- **THEN** it returns one entry per formalization project, each carrying a
  stable id and all required locations

#### Scenario: Registry is the single source of project paths

- **WHEN** a tool needs a project's source or artifact locations
- **THEN** it reads them from the registry and does not hardcode a manuscript
  filename

### Requirement: Per-project checks

The mechanical gate SHALL run every check for every registered project, and a
failure in any project SHALL fail the gate and name the project that failed.

#### Scenario: Every project is checked

- **WHEN** the slow gate runs
- **THEN** each registered project's non-ASCII scan, anchor-hash check,
  importer-artifact check, and cross-reference audit run

#### Scenario: Failure is attributed to a project

- **WHEN** a check fails for one project
- **THEN** the gate reports the failing project and exits non-zero

### Requirement: Per-project provenance isolation

Ingestion, anchor hashing, block registry, evidence, journal, and bundle
artifacts SHALL be scoped to a project so that two projects cannot collide on
identifiers or artifact paths.

#### Scenario: No identifier collision across projects

- **WHEN** two projects each register blocks and evidence
- **THEN** their block ids and evidence ids are resolved within their own
  project scope without collision

#### Scenario: Bundle is project-scoped

- **WHEN** the evidence bundle is generated
- **THEN** it embeds only the selected project's manifest, views, and journal
  scope

### Requirement: Default project preserved

The existing MSEilenberg formalization SHALL remain the default project, and
its current artifact paths and single-project behavior SHALL be preserved.

#### Scenario: Unchanged default run

- **WHEN** the gate runs with no project selection
- **THEN** the MSEilenberg project is checked exactly as before the change

#### Scenario: Existing paths still resolve

- **WHEN** the MSEilenberg project's artifacts are read
- **THEN** they are found at their existing paths

### Requirement: Adding a project is a data change

Registering a new manuscript project SHALL require only adding a registry entry
and its project-scoped artifact locations, not editing check logic or script
code.

#### Scenario: New project needs no code edit

- **WHEN** a new project is added to the registry
- **THEN** the gate, importer, hasher, and bundle operate on it without changes
  to their logic
