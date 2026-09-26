# Spec Delta

## Purpose

Defines the M4 deliverable for the `mscong` project: the hyperderivor / tree
homomorphism development of `MSCong.tex` §3.5, formalized in the `Mscong` Lean
namespace between two free algebras `T_Σ(X)` and `T_Ξ(Y)` along a sort map
`φ : S → T`, as unmapped infrastructure that reuses `Mslang` and M1–M3 and
leaves the default project untouched.

## ADDED Requirements

### Requirement: Base change and hyperderivors

The `Mscong` development SHALL define the base change `Δ_φ` of a `T`-sorted set
along a sort map `φ : S → T`, and the **hyperderivor** `(c, f)` from
`(Σ, X)` to `(Ξ, Y)`: a sort map `φ : S → T`, an `S⋆ × S`-indexed map `c`
sending `σ : Σ_{w,s}` to a term in `T_Ξ(Y ∪ ↓φ*(w))_{φ(s)}` (with `↓φ*(w)` the
fresh placeholders, one per argument position, sorted by `φ`), and a sorted map
`f : X → T_Ξ(Y)_φ`. It SHALL define the **linearity** predicate (no placeholder
occurs more than once).

#### Scenario: Hyperderivor data

- **WHEN** sort maps `φ : S → T` and the maps `c`, `f` are given
- **THEN** they assemble into a hyperderivor from `(Σ, X)` to `(Ξ, Y)`, and
  linearity is a decidable predicate on the terms `c(σ)`

### Requirement: Induced Σ-algebra and tree homomorphism

The development SHALL equip `T_Ξ(Y)_φ` with the `Σ`-algebra structure
`c(T_Ξ(Y))` whose `σ`-operation substitutes the argument family into `c(σ)`
along the universal property, and SHALL define the **tree homomorphism**
`f♯ : T_Σ(X) → c(T_Ξ(Y))` as the free extension of `f`, a `Σ`-homomorphism.

#### Scenario: Tree homomorphism is a homomorphism

- **WHEN** a hyperderivor `(c, f)` is given
- **THEN** `f♯` is a `Σ`-homomorphism `T_Σ(X) → c(T_Ξ(Y))` with `f♯ ∘ η^X = f`

#### Scenario: Linearity is inherited

- **WHEN** the hyperderivor is linear
- **THEN** its tree homomorphism is linear in the paper's sense

### Requirement: Recognizability reflection under a tree homomorphism

The development SHALL prove **`PRecH`**: for a hyperderivor `(c, f)`, a sort
`s ∈ S`, and `L ∈ Rec_{φ(s)}(T_Ξ(Y))`, the inverse image
`(f♯_{φ(s)})⁻¹[L]` is `s`-recognizable in `T_Σ(X)`, with no finiteness
hypotheses.

#### Scenario: PRecH

- **WHEN** `L ∈ Rec_{φ(s)}(T_Ξ(Y))`
- **THEN** `(f♯_{φ(s)})⁻¹[L] ∈ Rec_s(T_Σ(X))`

### Requirement: Recognizability preservation under a linear tree homomorphism

The development SHALL prove **`PRecLH`**: for finite `S`, `T`, `Σ`, `X`, a
**linear** hyperderivor `(c, f)`, a sort `s ∈ S`, and `L ∈ Rec_s(T_Σ(X))`, the
direct image `f♯_s[L]` is `φ(s)`-recognizable in `T_Ξ(Y)`.

#### Scenario: PRecLH

- **WHEN** `S`, `T`, `Σ`, `X` are finite, the hyperderivor is linear, and
  `L ∈ Rec_s(T_Σ(X))`
- **THEN** `f♯_s[L] ∈ Rec_{φ(s)}(T_Ξ(Y))`

### Requirement: Reuse of the `Mslang` and M1–M3 foundations

The development SHALL reuse `Mslang`'s terms, free-algebra universal property
(`Term`/`termLift`), signatures, algebras and homomorphisms, the cogenerated
congruence (`congCogenerated`), saturation, and finite-index calculus, and
M1–M3's `Recognizable`/`RecognizableAt` and recognition results, rather than
redefining them.

#### Scenario: No redefinition of shared concepts

- **WHEN** the tree-homomorphism results refer to terms, homomorphisms,
  congruences, saturation, or recognizability
- **THEN** they use the `Mslang` and `Mscong` definitions rather than new ones

### Requirement: Unmapped infrastructure discipline

The M4 development SHALL be unmapped infrastructure: it SHALL NOT mint block
IDs, write evidence, or alter the default project, and SHALL satisfy the
mechanical Lean gate.

#### Scenario: No block mapping or evidence

- **WHEN** M4 is complete
- **THEN** `lean/declarations.mscong.json` still maps no declarations,
  `mscong` remains `ingested: false`, and no record is added under
  `evidence/mscong/`

#### Scenario: Default project untouched

- **WHEN** M4 is complete
- **THEN** the `mslang` golden baseline (registry, hashes, bundle) is unchanged
  and the gate reports no failure

#### Scenario: Clean and axiom-permitted

- **WHEN** the Lean mechanical gate runs
- **THEN** the `Mscong` development builds with no warnings and no `sorry`, and
  every axiom it uses lies within the permitted set
