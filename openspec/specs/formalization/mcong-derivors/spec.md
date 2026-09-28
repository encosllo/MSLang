# mcong-derivors Specification

## Purpose

Defines the M5 deliverable for the `mscong` project: the **derivors and Hall
algebras** development of `MSCong.tex` §6, formalized in the `Mscong` Lean
namespace as unmapped infrastructure that reuses `Mslang` and M1–M4, completes
the paper's recognizability theorems, and deliberately defers the
category-theoretic packaging.

## Requirements

### Requirement: Hall algebras

The `Mscong` development SHALL define a **Hall algebra** for a sort set `S`: an
`S⋆ × S`-indexed carrier equipped with projections `π^w_i` (for `i ∈ |w|`) and
substitution operators `ξ_{u,w,s}` (of arity `(w,s),(u,w_0),…,(u,w_{|w|-1})`),
satisfying the **projection** (`H1`), **identity** (`H2`), and
**associativity** (`H3`) equations.

#### Scenario: Hall-algebra data and laws

- **WHEN** an `S⋆ × S`-indexed carrier with `π` and `ξ` is given
- **THEN** it forms a Hall algebra for `S` exactly when `H1`, `H2`, and `H3`
  hold, and these laws are available as hypotheses to later results

### Requirement: Hall algebra of operations

The development SHALL equip, for every `S`-sorted set `A`, the operation set
`Op_H(A) = (A_w → A_s)_{(w,s)}` with a Hall-algebra structure: projections are
the true projections and substitution is composition with the tuple map
`⟨g_i⟩_{i∈|w|}`.

#### Scenario: `Op_H(A)` is a Hall algebra

- **WHEN** an `S`-sorted set `A` is given
- **THEN** `Op_H(A)` is a Hall algebra for `S`, with `π` the projections and `ξ`
  the generalized composition of mappings

### Requirement: Hall algebra of terms

The development SHALL equip, for every `S`-sorted signature `Σ`, the term set
`Ter_H(Σ) = (T_Σ(↓w)_s)_{(w,s)}` with a Hall-algebra structure: projections are
the placeholder variables and substitution is the free-algebra substitution
`Q♯` sending each placeholder to the corresponding argument.

#### Scenario: `Ter_H(Σ)` is a Hall algebra

- **WHEN** an `S`-sorted signature `Σ` is given
- **THEN** `Ter_H(Σ)` is a Hall algebra for `S`, reusing the free-algebra
  universal property and the existing substitution operators

### Requirement: Derived algebras

The development SHALL define, for a Hall algebra `A`, an `S`-sorted signature
`Σ`, a mapping `f : Σ → A`, and `u : S⋆`, the **derived `Σ`-algebra** `A^{f,u}`
on the `S`-sorted set `A_{u,·}` with `σ`-operation
`ξ^A_{u,w,s}(f_{w,s}(σ), -)`, and SHALL prove the auxiliary computation Lemma
`L:aux` describing `P^{A^{f,u}}` in terms of `ξ^A` and the placeholder extension
`(p^w)♯`.

#### Scenario: Derived-algebra operation and `L:aux`

- **WHEN** `A`, `Σ`, `f`, `u` are given
- **THEN** `A^{f,u}` is a `Σ`-algebra and, for every `P ∈ T_Σ(↓w)_s` and
  argument family `a`, the image of `P` under `A^{f,u}` equals
  `ξ^A_{u,w,s}((p^w)♯_s(P), a)`

### Requirement: Derivors and the tree-homomorphism bridge

The development SHALL define a **derivor** `(φ, d)` from `(S, Σ)` to `(T, Λ)`:
a sort map `φ : S → T` and `d : (w,s) → Σ_{w,s} → Ter_H(Λ)_{φ⋆(w), φ(s)}`, its
**linearity** predicate (each placeholder occurs at most once), and SHALL prove
that a derivor together with `f : X → T_Λ(Y)_φ` yields a **hyperderivor** (resp.
a linear hyperderivor) from `(Σ, X)` to `(Λ, Y)`.

#### Scenario: Every derivor with data is a hyperderivor

- **WHEN** a (linear) derivor `(φ, d)` and an `S`-sorted map
  `f : X → T_Λ(Y)_φ` are given
- **THEN** they assemble into a (linear) hyperderivor from `(Σ, X)` to
  `(Λ, Y)`, consistently with the M4 `Hyperderivor` structure

### Requirement: Recognizability under a derivor

The development SHALL prove the two §6 counterparts:

- for a derivor `d`, `X`, `Y`, `f : X → T_Λ(Y)_φ`, `s ∈ S`, and
  `L ∈ Rec_{φ(s)}(T_Λ(Y))`, the inverse image `(f♯_{φ(s)})⁻¹[L]` is
  `s`-recognizable in `T_Σ(X)`, with no finiteness hypotheses;
- for finite `S`, `T`, `Σ`, `X`, a **linear** derivor, and
  `L ∈ Rec_s(T_Σ(X))`, the direct image `f♯_s[L]` is `φ(s)`-recognizable in
  `T_Λ(Y)`.

#### Scenario: Inverse image under a derivor

- **WHEN** `L ∈ Rec_{φ(s)}(T_Λ(Y))`
- **THEN** `(f♯_{φ(s)})⁻¹[L] ∈ Rec_s(T_Σ(X))`

#### Scenario: Direct image under a linear derivor

- **WHEN** `S`, `T`, `Σ`, `X` are finite, the derivor is linear, and
  `L ∈ Rec_s(T_Σ(X))`
- **THEN** `f♯_s[L] ∈ Rec_{φ(s)}(T_Λ(Y))`

### Requirement: Reuse of the `Mslang` and M1–M4 foundations

The development SHALL reuse `Mslang`'s terms and free-algebra universal property
(`Term`/`termLift`), signatures, algebras and homomorphisms, and M1–M4's
`Recognizable`/`RecognizableAt`, substitution machinery, and
`Hyperderivor`/`PRecH`/`PRecLH`, rather than redefining them.

#### Scenario: No redefinition of shared concepts

- **WHEN** the derivor results refer to terms, homomorphisms, substitution,
  hyperderivors, or recognizability
- **THEN** they use the `Mslang`, M1–M4 definitions rather than new ones

### Requirement: Deferred category-theoretic scope

The M5 development SHALL NOT formalize the free-Hall-algebra isomorphism
`iso:FrH-TerH`, the category `Sig_d` (or its Kleisli/monad characterization),
the contravariant functor `Alg_d`, the Grothendieck category `Alg_d`, or the
2-categorical remark; these SHALL be recorded as an explicit deferral.

#### Scenario: Category layer out of scope

- **WHEN** M5 is complete
- **THEN** no declaration formalizes the free-Hall-algebra isomorphism or the
  `Sig_d` / `Alg_d` categories, and the deferral is recorded in `STATE.md` and
  the change design

### Requirement: Unmapped infrastructure discipline

The M5 development SHALL be unmapped infrastructure: it SHALL NOT mint block
IDs, write evidence, or alter the default project, and SHALL satisfy the
mechanical Lean gate.

#### Scenario: No block mapping or evidence

- **WHEN** M5 is complete
- **THEN** `lean/declarations.mscong.json` still maps no declarations,
  `mscong` remains `ingested: false`, and no record is added under
  `evidence/mscong/`

#### Scenario: Default project untouched

- **WHEN** M5 is complete
- **THEN** the `mslang` golden baseline (registry, hashes, bundle) is unchanged
  and the gate reports no failure

#### Scenario: Clean and axiom-permitted

- **WHEN** the Lean mechanical gate runs
- **THEN** the `Mscong` development builds with no warnings and no `sorry`, and
  every axiom it uses lies within the permitted set
