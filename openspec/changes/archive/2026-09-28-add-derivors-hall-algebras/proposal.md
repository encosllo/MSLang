# Proposal

## Why

M4 (archived) completed the §3.5 tree-homomorphism recognizability results
(`PRecH`, `PRecLH`), so the `Mscong` development now covers every recognizability
theorem acting within or between free algebras `T_Σ(X)` and `T_Ξ(Y)`. **M5** is
the last mathematical milestone of the roadmap: the §6 **derivors and Hall
algebras**, which recast the tree-homomorphism results for the naturally
categorical class of *derivors* (sort map + operation-symbol-to-term map) and so
complete the paper's recognizability theorems.

M5 is decision-gated (M0 roadmap) because §6 mixes an algebraically-encodable
core with category-theoretic packaging (the free-Hall-algebra isomorphism and the
`Sig_d` / `Alg_d` categories via the Grothendieck construction). Per the author's
decision this session, this change formalizes the **algebraic core** and defers
the category-theoretic packaging, which is organizational and adds no new
recognizability content.

## What Changes

- Add a **Hall-algebra structure** for a sort set `S`: an `S⋆ × S`-indexed
  carrier with projections `π^w_i` and substitution operators `ξ_{u,w,s}`
  satisfying the equations `H1` (projection), `H2` (identity), and `H3`
  (associativity).
- Add the two canonical Hall algebras:
  - **`Op_H(A)`** for an `S`-sorted set `A`: the operation set
    `(A_w → A_s)_{(w,s)}` with projections and generalized composition;
  - **`Ter_H(Σ)`** for an `S`-sorted signature `Σ`: the term set
    `(T_Σ(↓w)_s)_{(w,s)}` with variable projections and substitution.
- Add the **derived `Σ`-algebra** `A^{f,u}` of a Hall algebra `A` for
  `(f : Σ → A, u : S⋆)` and the auxiliary Lemma `L:aux`.
- Add **derivors** `(φ, d)`, **linear derivors**, and the bridge
  *every derivor (with data) gives a hyperderivor* (`Proposición` at §6 line
  4566), reducing the two derivor recognizability propositions to M4's `PRecH`
  and `PRecLH`.
- Add the two **derivor recognizability counterparts**: inverse image
  (`Rec`) under `f♯` (no finiteness) and direct image under a linear derivor
  (finite `S,T,Σ,X`).
- Implement as **unmapped Lean infrastructure** (new `Mscong` modules), reusing
  `Mslang` and M1–M4, with no block IDs, no evidence, and no change to `mslang`;
  `mscong.ingested` stays `false`.
- **Defer** (recorded as caveats): the free-Hall-algebra isomorphism
  `iso:FrH-TerH`, the category `Sig_d` and its Kleisli/monad characterization,
  the contravariant functor `Alg_d : Sig_d → Cat`, the Grothendieck category
  `Alg_d`, and the 2-categorical remark. These are packaging, not recognizability
  results; they are out of scope for this change.
- Keep the development clean, `sorry`-free, within the permitted axiom set.

## Capabilities

### New Capabilities

- `formalization/mcong-derivors`: the M5 Hall-algebra / derivor development for
  the `Mscong` project — the Hall-algebra structure, `Op_H(A)`, `Ter_H(Σ)`,
  derived algebras, derivors and the derivor→hyperderivor bridge, the two
  recognizability counterparts, reuse of `Mslang`/M1–M4, the deferred
  category-theoretic packaging, and unmapped-infrastructure discipline.

### Modified Capabilities

<!-- None. M5 adds a new capability; M1–M4 requirements are unchanged. -->

## Impact

- New Lean modules under `lean/Mscong/` (Hall algebra development and the derivor
  layer), imported by `lean/Mscong/Main.lean`. `lean/declarations.mscong.json`
  stays empty.
- `STATE.md`: a session entry and the M5 status.
- **No** change to `mslang` artifacts, evidence, hashes, or views; **no** change
  to the gate's behavior; **no** manuscript edit; `mscong` remains
  `ingested: false`.

## Note

`PRecILH` remains commented out in `MSCong.tex` and is not part of this change.
The category-theoretic results of §6 (free Hall algebra, `Sig_d`, `Alg_d`) are
deliberately out of scope; if the author later wants them, they are their own
change, mirroring the deferred `B-C003` adjunction.
