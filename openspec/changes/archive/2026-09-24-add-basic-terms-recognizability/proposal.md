# Proposal

## Why

M1 formalized the finite-index recognizability calculus of `MSCong.tex` §2.3
(the predicates `Rec`/`Rec_T`/`Rec_s`, their finite-index characterizations, and
the general closure properties), but only for *arbitrary* `Σ`-algebras. The
paper's recognition theorems are about the **free** many-sorted algebra
`T_Σ(X)`; M2 is the next roadmap milestone and takes the first step into it:
the "Basic terms" propositions of `MSCong.tex` §3.1 (`PRecVar`, `PRecConst`,
`PRecOp`), which prove that the singleton languages consisting of a variable, a
constant, and an operation symbol applied to variables are recognizable. These
are the base cases the later substitution / iteration / quotient /
tree-homomorphism theorems build on (they make the recognizable languages a
`Σ`-algebra of the same signature). Formalizing them now advances the second
project's frontier and reuses M1's predicates plus `Mslang`'s term/free layer.

## What Changes

- Add the **basic-term recognizability** development to `lean/Mscong`:
  - the finite two-element `Σ`-algebra `2^S` (carrier `Fin 2` at every sort,
    every operation the constant map to `0`), finite because `S` is finite;
  - the homomorphic extension of a sorted map `X → 2^S` along the insertion
    `η^X`, reused from `Mslang.termLift` (the free-algebra universal property);
  - **`PRecVar`**: for `x : X s`, the language `{x} ⊆ T_Σ(X)_s` is
    recognizable;
  - **`PRecConst`**: for a constant `σ : Σ_{λ,s}`, the language
    `{σ} ⊆ T_Σ(X)_s` is recognizable;
  - **`PRecOp`**: for `(w,s)` with `w` nonempty, `σ : Σ_{w,s}`, and a family of
    variables `(x_i)_{i∈w}` in `X_w`, the language `{σ((x_i)_{i∈w})} ⊆
    T_Σ(X)_s` is recognizable.
- Work on the **inductive** free algebra `Mslang.Term` (`termAlg Sig X`), which
  has the recursor the constructions need, and state recognizability through
  M1's `Recognizable`/`RecognizableAt`.
- Implement it as **unmapped Lean infrastructure**: no `\blockid`s are minted,
  `mscong.ingested` stays `false`, no evidence records are written.
- Keep the development clean, `sorry`-free, and within the permitted axiom set.

## Capabilities

### New Capabilities

- `formalization/mcong-basic-terms`: the M2 basic-term recognizability results
  for the `Mscong` project — requirements on what the development must prove,
  what it must reuse, and its being unmapped infrastructure that does not
  disturb the default project.

### Modified Capabilities

<!-- None: no existing capability's requirements change. `formalization/mcong-recognizability`
     (M1) supplies the predicates this change consumes, unchanged. -->

## Impact

- `lean/Mscong/BasicTerms.lean` (new module), imported by `lean/Mscong.lean`;
  possibly a small helper in `lean/Mscong/Recognizable.lean` if a lemma is
  reusable. `lean/declarations.mscong.json` stays empty.
- `STATE.md`: a session entry and the M2 status.
- **No** change to `mslang` artifacts, evidence, hashes, or views; **no** change
  to the gate's behavior; **no** manuscript edit; `mscong` remains
  `ingested: false` (its provenance checks stay deferred).
