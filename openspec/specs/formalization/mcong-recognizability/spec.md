# mcong-recognizability Specification

## Purpose

Defines the M1 deliverable for the `mscong` project: the finite-index
recognizability calculus of `MSCong.tex` §2.3, formalized in the `Mscong` Lean
namespace as unmapped infrastructure that reuses `Mslang` and leaves the
default project untouched.

## Requirements

### Requirement: Finite-index congruence calculus

The `Mscong` development SHALL define congruences of finite index and the
closure properties the paper's recognizability proofs use, expressed over
`Mslang`'s `Cgr` and `IsFiniteIndex` notions.

#### Scenario: Finite-index congruences are upward closed

- **WHEN** `Φ` has finite index and `Φ ⊆ Ψ` for congruences `Φ, Ψ` on `A`
- **THEN** `Ψ` has finite index

#### Scenario: Finite-index congruences are closed under finite meets

- **WHEN** a finite nonempty family of congruences on `A` each has finite index
- **THEN** their meet has finite index

#### Scenario: Finite-index congruences form a filter

- **WHEN** `supp_S(A)` is finite
- **THEN** the finite-index congruences on `A` form a filter of the congruence
  lattice

### Requirement: Recognizability predicates and the Kronecker-delta bridge

The development SHALL define the recognizability predicates `Rec_T`, `Rec_s`,
and `Rec` (for `T ⊆ S` and `s ∈ S`) and SHALL establish the bridge between
sort-indexed and full-language recognizability.

#### Scenario: Sort recognizability via the Kronecker delta

- **WHEN** `L ⊆ A_s` for a sort `s`
- **THEN** `L` is `s`-recognizable if and only if the concentrated language
  `δ^{s,L}` is recognizable

#### Scenario: Characterization by a finite-index saturation

- **WHEN** `L` is a language of `A` (or of `A↾_T` for `T ⊆ S`)
- **THEN** `L` is recognizable if and only if it is saturated by some
  finite-index congruence, equivalently `Ω^A(L)` has finite index

### Requirement: Closure of recognizable languages

The development SHALL establish that the recognizable languages are closed
under the operations the paper uses to build them.

#### Scenario: Boolean closure

- **WHEN** `K` and `L` are recognizable
- **THEN** their union, intersection, and relative complement are recognizable

#### Scenario: Translation preimages

- **WHEN** `T` is a translation and `L` is recognizable
- **THEN** the translation preimage `T⁻¹[L]` is recognizable

#### Scenario: Inverse images along homomorphisms

- **WHEN** `f : A → B` is a homomorphism and `M` is recognizable in `B`
- **THEN** `f⁻¹[M]` is recognizable in `A`

### Requirement: Reuse of the `Mslang` foundations

The development SHALL import and reuse `Mslang`'s existing notions rather than
redefine them, so the two manuscripts share one formalization of the
preliminaries.

#### Scenario: No redefinition of shared concepts

- **WHEN** the recognizability calculus refers to congruences, quotients,
  saturation, or the cogenerated congruence
- **THEN** it uses `Mslang.Congruence`, `Mslang.Prelim` (saturation), and
  `Mslang.Translation` (`congCogenerated`) rather than new definitions

### Requirement: Unmapped infrastructure discipline

The M1 development SHALL be unmapped infrastructure: it SHALL NOT mint block
IDs, write evidence, or alter the default project, and SHALL satisfy the
mechanical Lean gate.

#### Scenario: No block mapping or evidence

- **WHEN** M1 is complete
- **THEN** `lean/declarations.mscong.json` still maps no declarations,
  `mscong` remains `ingested: false`, and no record is added under
  `evidence/mscong/`

#### Scenario: Default project untouched

- **WHEN** M1 is complete
- **THEN** the `mslang` golden baseline (registry, hashes, bundle) is
  unchanged and the gate reports no failure

#### Scenario: Clean and axiom-permitted

- **WHEN** the Lean mechanical gate runs
- **THEN** the `Mscong` development builds with no warnings and no `sorry`, and
  every axiom it uses lies within the permitted set
