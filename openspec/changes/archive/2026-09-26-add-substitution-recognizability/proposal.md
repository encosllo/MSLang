# Proposal

## Why

M2 formalized the §3.1 basic-term propositions (`PRecVar`/`PRecConst`/`PRecOp`),
the base cases that make the recognizable languages of a free algebra `T_Σ(X)`
closed under the term constructors. M3 is the next roadmap milestone: the
§3.2–§3.4 **substitution, iteration, and quotient** results (`PRecSubs`,
`PRecIt`, `PRecQ`), which are the operator-preservation theorems the paper is
built around. They reuse M2's basic-term results and M1's finite-index
recognizability calculus, and they are the last recognizability results before
the tree-homomorphism machinery of M4.

## What Changes

- Add the **substitution / iteration / quotient** recognizability development to
  `lean/Mscong`:
  - the **substitution operators** on `T_Σ(X)`: the single-variable
    substitution `(z\Q)(P)` and the simultaneous substitution
    `((x,t)\(Q^{x,t}_α)_{α∈P_x})(P)`, together with the induced homomorphism
    `((x\L_x)_{x∈X_t})_{t∈S}^♯` into the subset algebra `Sub(T_Σ(X))`, whose
    value at `P` is the set of substituted terms (the paper's
    `Im((x,t)\·)(P)↾∏ L_x^{P_x})`;
  - **`PRecSubs`**: if `K ∈ Rec_s(T_Σ(X))` and each `L_x ∈ Rec_t(T_Σ(X))`, then
    the substituted language is `s`-recognizable (paper: `S` and `X` finite);
  - **`PRecIt`**: the `z`-iteration `L^{⋆z}` of a recognizable `L ⊆ T_Σ(X)_s` is
    recognizable (paper: `S` finite);
  - **`PRecQ`**: the `z`-quotient `K^{-z}L` of a recognizable `L` by any
    `K ⊆ T_Σ(X)_t` is recognizable, and there are finitely many such quotients
    (paper: `S` finite).
- Implement it as **unmapped Lean infrastructure**, reusing `Mslang`
  (`Term`/`termLift`, the subset-algebra operations, `Ω`/`congCogenerated`,
  saturation, finite index) and M1/M2's predicates, with no block IDs, no
  evidence, and no change to `mslang`; `mscong.ingested` stays `false`.
- Keep the development clean, `sorry`-free, within the permitted axiom set.

## Capabilities

### New Capabilities

- `formalization/mcong-substitution`: the M3 substitution / iteration / quotient
  recognizability results for the `Mscong` project — requirements on what the
  development must contain, reuse, and guarantee, and on its being unmapped
  infrastructure that does not disturb the default project.

### Modified Capabilities

<!-- None: `formalization/mcong-basic-terms` (M2) and
     `formalization/mcong-recognizability` (M1) supply the results this change
     consumes, unchanged. -->

## Impact

- `lean/Mscong/Substitution.lean` (currently a scaffold) and possibly a helper
  module; imported by `lean/Mscong/Main.lean`. `lean/declarations.mscong.json`
  stays empty.
- `STATE.md`: a session entry and the M3 status.
- **No** change to `mslang` artifacts, evidence, hashes, or views; **no** change
  to the gate's behavior; **no** manuscript edit; `mscong` remains
  `ingested: false`.
