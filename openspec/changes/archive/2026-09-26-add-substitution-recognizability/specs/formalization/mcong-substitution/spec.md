# Spec Delta

## Purpose

Defines the M3 deliverable for the `mscong` project: the substitution,
iteration, and quotient recognizability results of `MSCong.tex` §3.2–§3.4,
formalized in the `Mscong` Lean namespace over the free algebra `T_Σ(X)` as
unmapped infrastructure that reuses `Mslang` and M1/M2 and leaves the default
project untouched.

## ADDED Requirements

### Requirement: Substitution operators

The `Mscong` development SHALL define the single-variable substitution
`(z\Q)(P)` and the simultaneous substitution
`((x,t)\(Q^{x,t}_α)_{α∈P_x})(P)` on terms of `T_Σ(X)`, and the induced
homomorphism `((x\L_x)_{x∈X_t})_{t∈S}^♯` from `T_Σ(X)` to the subset algebra
`Sub(T_Σ(X))` obtained from the free-algebra universal property, whose value at
`P` is the set of substituted terms.

#### Scenario: Substitution agrees with the universal property

- **WHEN** an `S`-sorted family of languages `(L_x)_{{t∈S},{x∈X_t}}` is given and
  `P ∈ T_Σ(X)_s`
- **THEN** the value of the induced homomorphism at `P` is the image of the
  simultaneous-substitution map at `P` restricted to the product of the `L_x`

#### Scenario: Single-variable substitution is a specialization

- **WHEN** all but one variable `z` are assigned the singleton `{z}`
- **THEN** the simultaneous substitution is the single-variable substitution
  `(z\Q)(P)`

### Requirement: Closure under substitution

The development SHALL prove that, for a finite sort set `S` and finite variable
set `X`, if `K ⊆ T_Σ(X)_s` is recognizable and every `L_x ⊆ T_Σ(X)_t` is
recognizable, then the substituted language is recognizable.

#### Scenario: PRecSubs

- **WHEN** `S` and `X` are finite, `K ∈ Rec_s(T_Σ(X))`, and
  `L_x ∈ Rec_t(T_Σ(X))` for every `x : X_t`
- **THEN** `((x\L_x)_{x∈X_t})_{t∈S}^♯_s(K) ∈ Rec_s(T_Σ(X))`

### Requirement: Closure under iteration

The development SHALL define the `z`-iteration `L^{⋆z}` of a language
`L ⊆ T_Σ(X)_s` and prove that it is recognizable whenever `L` is, for finite
`S`.

#### Scenario: PRecIt

- **WHEN** `S` is finite, `s ∈ S`, `z : X_s`, and `L ∈ Rec_s(T_Σ(X))`
- **THEN** `L^{⋆z} ∈ Rec_s(T_Σ(X))`

### Requirement: Closure under quotient

The development SHALL define the `z`-quotient `K^{-z}L` of a language `L` by a
language `K` and prove that it is recognizable whenever `L` is, for finite `S`,
and that there are finitely many `z`-quotients of a fixed recognizable `L`.

#### Scenario: PRecQ

- **WHEN** `S` is finite, `L ∈ Rec_s(T_Σ(X))`, and `K ⊆ T_Σ(X)_t` is arbitrary
- **THEN** `K^{-z}L ∈ Rec_s(T_Σ(X))` for every `z : X_t`

#### Scenario: Finitely many quotients

- **WHEN** `S` is finite and `L ∈ Rec_s(T_Σ(X))`
- **THEN** the set of `z`-quotients `K^{-z}L`, over all `t`, `z : X_t`, and
  `K ⊆ T_Σ(X)_t`, is finite

### Requirement: Reuse of the `Mslang` and M1/M2 foundations

The development SHALL reuse `Mslang`'s terms, free-algebra universal property
(`Term`/`termLift`), subset-algebra operations, cogenerated congruence
(`congCogenerated`), saturation, and finite-index calculus, and M1/M2's
`Recognizable`/`RecognizableAt` and basic-term results, rather than redefining
them.

#### Scenario: No redefinition of shared concepts

- **WHEN** the substitution results refer to terms, substitution, congruences,
  saturation, or recognizability
- **THEN** they use the `Mslang` and `Mscong` definitions rather than new ones

### Requirement: Unmapped infrastructure discipline

The M3 development SHALL be unmapped infrastructure: it SHALL NOT mint block
IDs, write evidence, or alter the default project, and SHALL satisfy the
mechanical Lean gate.

#### Scenario: No block mapping or evidence

- **WHEN** M3 is complete
- **THEN** `lean/declarations.mscong.json` still maps no declarations,
  `mscong` remains `ingested: false`, and no record is added under
  `evidence/mscong/`

#### Scenario: Default project untouched

- **WHEN** M3 is complete
- **THEN** the `mslang` golden baseline (registry, hashes, bundle) is unchanged
  and the gate reports no failure

#### Scenario: Clean and axiom-permitted

- **WHEN** the Lean mechanical gate runs
- **THEN** the `Mscong` development builds with no warnings and no `sorry`, and
  every axiom it uses lies within the permitted set
