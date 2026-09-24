# mcong-basic-terms Specification

## Purpose

Defines the M2 deliverable for the `mscong` project: the basic-term
recognizability results of `MSCong.tex` §3.1, formalized in the `Mscong` Lean
namespace over the free algebra `T_Σ(X)`, as unmapped infrastructure that reuses
`Mslang` and leaves the default project untouched.

## Requirements

### Requirement: Finite recognizing algebra for basic terms

The `Mscong` development SHALL provide, for a finite sort set `S`, a finite
two-element `Σ`-algebra `2^S` (carrier `Fin 2` at every sort, every operation
the constant map to `0`) and SHALL obtain homomorphisms `T_Σ(X) → 2^S` as the
homomorphic extension of a sorted map `X → 2^S` along the insertion `η^X`.

#### Scenario: Two-element algebra is finite

- **WHEN** the sort set `S` is finite
- **THEN** `2^S` is a finite `Σ`-algebra

#### Scenario: Free extension of a sorted map

- **WHEN** a sorted map `g : X → 2^S` is given
- **THEN** there is a `Σ`-homomorphism `g♯ : T_Σ(X) → 2^S` with
  `g♯ ∘ η^X = g`

### Requirement: Basic-term recognizability

The development SHALL prove that the singleton languages made of a variable, a
constant, and an operation symbol applied to a family of variables are
recognizable in the free algebra `T_Σ(X)`.

#### Scenario: Variable singleton is recognizable

- **WHEN** `s ∈ S` and `x : X_s`
- **THEN** the language `{x} ⊆ T_Σ(X)_s` is recognizable

#### Scenario: Constant singleton is recognizable

- **WHEN** `σ : Σ_{λ,s}` is a constant operation symbol
- **THEN** the language `{σ} ⊆ T_Σ(X)_s` is recognizable

#### Scenario: Operation-on-variables singleton is recognizable

- **WHEN** `(w,s)` has `w` nonempty, `σ : Σ_{w,s}`, and `(x_i)_{i∈w}` is a
  family of variables in `X_w`
- **THEN** the language `{σ((x_i)_{i∈w})} ⊆ T_Σ(X)_s` is recognizable

### Requirement: Reuse of the `Mslang` free-algebra layer

The development SHALL import and reuse `Mslang`'s inductive terms and free
algebra (`Term`, `termAlg`, `termLift`), the recognizability predicates from M1,
and `Mslang`'s shared preliminaries rather than redefining them.

#### Scenario: No redefinition of terms or free algebra

- **WHEN** the basic-term results refer to terms, the free algebra, or its
  universal property
- **THEN** they use `Mslang.Term`/`Mslang.termAlg`/`Mslang.termLift` and
  `Mscong.Recognizable` rather than new definitions

### Requirement: Unmapped infrastructure discipline

The M2 development SHALL be unmapped infrastructure: it SHALL NOT mint block
IDs, write evidence, or alter the default project, and SHALL satisfy the
mechanical Lean gate.

#### Scenario: No block mapping or evidence

- **WHEN** M2 is complete
- **THEN** `lean/declarations.mscong.json` still maps no declarations,
  `mscong` remains `ingested: false`, and no record is added under
  `evidence/mscong/`

#### Scenario: Default project untouched

- **WHEN** M2 is complete
- **THEN** the `mslang` golden baseline (registry, hashes, bundle) is unchanged
  and the gate reports no failure

#### Scenario: Clean and axiom-permitted

- **WHEN** the Lean mechanical gate runs
- **THEN** the `Mscong` development builds with no warnings and no `sorry`, and
  every axiom it uses lies within the permitted set
