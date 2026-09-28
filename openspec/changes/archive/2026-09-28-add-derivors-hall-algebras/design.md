# Design

## Context

See `proposal.md` — Why. Current state that shapes the approach:

- `Mslang` supplies the inductive free algebra `Term Sig X`, its universal
  property (`termLift`, `termLift_isAlgHom`, `termLift_unique`), signatures
  (`Signature S = List S × S → Type u`), algebras (`Alg`, `AlgStruct`,
  `IsAlgHom`), and the sorted-set / sorted-map vocabulary (`SSet`, `SortedMap`).
- M4 (`Mscong.TreeHom`, 1596 lines) supplies `Hyperderivor φ Sig Xi X Y`,
  `Yplus φ Y w = fun t => Y t ⊕ {i : Fin w.length // φ (w.get i) = t}`,
  `cAlg`/`treeHom`, `Hyperderivor.IsLinear`, `countPlaceholder`, `Occurs`,
  `PRecH`, and `PRecLH`.
- M1/M3 supply `Recognizable`/`RecognizableAt` and the substitution operators
  (`substHom`, `cSubst`-style machinery) over terms.
- `MSCong.tex` §6 defines: the Hall algebra for `S` (projections `π`, operators
  `ξ`, equations `H1`–`H3`), `Op_{H_S}(A)`, `Ter_{H_S}(Σ)`, the derived algebra
  `A^{f,u}` and Lemma `L:aux`, derivors `(φ, d)` and their linearity, the
  derivor→hyperderivor bridge (line 4566), and the two derivor recognizability
  counterparts (lines 4572, 4585).
- `mscong` is still a scaffold (`ingested: false`).

## Goals / Non-Goals

**Goals:**

- Formalize the algebraic core of §6 in new `Mscong` modules: Hall algebras,
  `Op_H(A)`, `Ter_H(Σ)`, derived algebras, derivors, the bridge to M4
  `Hyperderivor`, and the two recognizability counterparts.
- Keep it **unmapped infrastructure** as in M1–M4: no block IDs, no evidence, no
  change to `mslang`, `mscong` stays `ingested: false`.
- Build clean, `sorry`-free, within the permitted axiom set.

**Non-Goals:**

- The free-Hall-algebra isomorphism `iso:FrH-TerH` and the variety adjunction
  `T_{H_S} ⊣ G_{H_S}`.
- The category `Sig_d`, its Kleisli/monad characterization, the contravariant
  functor `Alg_d : Sig_d → Cat`, the Grothendieck category `Alg_d`, and the
  2-categorical remark.
- General Hall-algebra homomorphisms beyond what the counterparts need
  (the bridge uses term substitution, not a `HallAlgHom`).
- `PRecILH`; any manuscript edit, block-ID minting, evidence record, or mapping.

## Decisions

### D1. A bespoke `HallAlg` structure, not an instance of `Mslang.Alg`

A `HallAlg S` is a structure with `carrier : List S × S → Type u`,
`pi : (w : List S) → (i : Fin w.length) → carrier (w, w.get i)`,
`xi : (u w : List S) → (s : S) → carrier (w,s) →
((i : Fin w.length) → carrier (u, w.get i)) → carrier (u,s)`, and law fields
`H1 : xi u w (w.get i) (pi w i) g = g i`,
`H2 : xi u u (u.get j) a (fun i => pi u i) = a`, and
`H3 : xi u v s (xi v w s x g) h = xi u w s x (fun j => xi u v (w.get j) (g j) h)`
(the associativity of substitution).

Rationale: the paper's signature `Σ^{H_S}` is an `(S⋆×S)`-sorted signature with
nullary `π` and `|w|+1`-ary `ξ` for every `(u,w,s)`; encoding it as a
`Signature (List S × S)` value and instantiating `Alg` would force a large
dependent index type plus transport through `AlgStruct`. A bespoke structure is
the faithful variety presentation and is directly usable. Alternatives: the
`Alg`-valued coding (heavy, no benefit here); a Mathlib `UniversalAlgebra`/clone
(brings an external dependency and a different universe story).

### D2. `Op_H(A)`: operations with composition

For `A : SSet S`, the carrier is
`fun p => ((i : Fin p.1.length) → A (p.1.get i)) → A p.2` (the paper's
`A_w → A_s`), `pi w i := fun f => f i`, and
`xi u w s f g := fun a => f (fun i => g i a)` (composition with the tuple map
`⟨g_i⟩`). The three laws are extensional (`funext`/`rfl`).

### D3. `Ter_H(Σ)`: placeholder-indexed terms with substitution

For `Σ : Signature S`, the carrier is
`fun p => Term Σ (derivPlace id p.1) p.2`, where
`derivPlace (φ : S → T) (w : List S) : SSet T :=
fun t => {i : Fin w.length // φ (w.get i) = t}` is the paper's `↓φ*(w)`.
`pi w i := Term.var ⟨i, rfl⟩`; `xi u w s P Q` substitutes each placeholder
`⟨i, _⟩` by `Q i` via `termLift Σ (derivPlace _ w) (termAlg Σ (derivPlace _ u)).2`
along the sorted map `v ↦ (v.2 ▸ Q v.1)`.

Rationale for `derivPlace` rather than `placeholders (w.map φ)`: it keeps the
index on the original `w` (`Fin w.length`) and avoids `List.get_map` transport
throughout; it is *definitionally* the `Sum.inr` summand of M4's
`Yplus φ Y w = fun t => Y t ⊕ {i : Fin w.length // φ (w.get i) = t}` (D5).
`H1` follows from `termLift` on a variable, `H2` from `termLift` along
`Term.var` being the identity (via `termLift_unique` against the identity
homomorphism), and `H3` from associativity of `termLift` substitution.

### D4. Derived `Σ`-algebra `A^{f,u}` and Lemma `L:aux`

Given `A : HallAlg S`, `Σ : Signature S`, `f : (p : List S × S) → Σ p →
A.carrier p`, and `u : List S`, the carrier is `fun s => A.carrier (u,s)` with
`σ`-operation `a ↦ A.xi u w s (f (w,s) σ) a`. `p^u` maps `⟨i, _⟩` to
`A.pi u i`, and `(p^u)♯ := termLift Σ (derivPlace id u) …`. Lemma `L:aux`,
`P^{A^{f,u}}(a) = A.xi u w s ((p^w)♯ P) a`, is by `Term.rec` (algebraic induction
on `P`), using `H2` for the variable case and `H3` for the operation case,
exactly as the manuscript's proof.

### D5. Derivors and the bridge

`structure Derivor (φ : S → T) (Σ : Signature S) (Λ : Signature T)` with
`d : (p : List S × S) → Σ p → Term Λ (derivPlace φ p.1) (φ p.2)`, plus
`Derivor.IsLinear` (each placeholder occurs at most once in `d p σ`). The bridge
`Derivor.toHyperderivor` (`X`, `Y`, `f : SortedMap X (fun s => Term Λ Y (φ s))`)
sets
`c p σ := termLift Λ (derivPlace φ p.1) (termAlg Λ (Yplus φ Y p.1)).2
   (fun _ v => Term.var (Sum.inr v)) (φ p.2) (d p σ)`,
i.e. the paper's composition with the canonical homomorphism
`in^{@}_{↓φ*(w), Y∪↓φ*(w)}`. Since `Sum.inr` *is* `derivPlace φ p.1` inside
`Yplus`, no transport is needed for `c`; only the linearity transfer
(`IsLinear d → Hyperderivor.IsLinear (toHyperderivor …)`) needs a count lemma.

### D6. Recognizability counterparts via M4

The inverse-image counterpart is stated and proved using the bridge
hyperderivor's `treeHom`:

- **inverse image:** `(treeHom (toHyperderivor …) (φ s))⁻¹[L]` is `s`-recognizable
  for `L ∈ Rec_{φ(s)}(T_Λ(Y))`, by M4 `PRecH` (no finiteness);
- **direct image:** for finite `S,T,Σ,X` and a linear derivor,
  `(treeHom (toHyperderivor …) s)[L]` is `φ(s)`-recognizable for
  `L ∈ Rec_s(T_Σ(X))`, by M4 `PRecLH`.

Encoding choice: the paper writes `Alg_d(d)(T_Λ(Y))`; under this change that
functor is deferred (D7) and its value on the free algebra is realized directly
by the bridge hyperderivor's induced algebra `cAlg`. This is faithful to the
mathematics of the two propositions (whose proofs are "It follows from
`PRecH`/`PRecLH`") but does not construct `Alg_d`.

### D7. Module layout, and the deferred category layer

New modules `lean/Mscong/Hall.lean` (D1–D4) and `lean/Mscong/Derivor.lean`
(D5–D6), imported by `Mscong.Main`. This departs from the M0 design's
`TreeHom.lean` plan (that module is already 1596 lines) and is a coordinator
layout decision. The free-Hall-algebra isomorphism, `Sig_d`, `Alg_d`, and the
Grothendieck construction are **not** formalized; the deferral is recorded in the
change design and in `STATE.md`. No declaration is added to
`lean/declarations.mscong.json`; audited by `lean_audit.py --project mscong`.

## Risks / Trade-offs

- **`H3` (substitution associativity) for `Ter_H(Σ)` is the technical heart.**
  `Mslang` has no packaged `termLift`-composition lemma (M3/M4 proved bespoke
  substitution facts). → Prove a `termLift`-composition lemma once (by
  `Term.rec` or by `termLift_unique` against the composed homomorphism) and
  derive `H3`; if needed, stage `Op_H`/derivors/counterparts before `Ter_H`'s
  `H3`.
- **Linearity count for derivors vs M4's `countPlaceholder`.** M4's counter is
  indexed by `Yplus`'s `Sum.inr`; the derivor term lives in
  `Term Λ (derivPlace φ w)`. → Either reuse `countPlaceholder φ w` through the
  definitional identification `Yplus φ (fun _ => Empty) w` or add a parallel
  `countPlaceholderD`; decide when building D5. The bridge's linearity transfer
  needs the count to be preserved by `Term.var ∘ Sum.inr` substitution.
- **Universe/dependency bookkeeping** for `HallAlg` over `Type u` with a
  `List S × S` index mirror the existing `Mslang` style; keep `u` explicit as in
  `SSet`.
- **Scope creep into the category layer.** → The spec's "Deferred
  category-theoretic scope" requirement and D7 keep `Sig_d`/`Alg_d` out; any
  future need for them is a separate change.
- **Assumption hygiene**: the inverse-image counterpart needs no finiteness; the
  direct-image counterpart needs exactly finite `S,T,Σ,X` and a linear derivor.

## Migration Plan

1. Add `lean/Mscong/Hall.lean` in dependency order: `derivPlace`, `HallAlg`,
   `Op_H`, `Ter_H`, `derivedAlg`, `L:aux`.
2. Add `lean/Mscong/Derivor.lean`: `Derivor`, `IsLinear`, `toHyperderivor`,
   then the two counterparts. Import both from `Mscong.Main`.
3. Iterate with targeted `lake build Mscong.Hall` / `lake build Mscong.Derivor`.
4. Run `scripts/check_all.sh --fast`, one `scripts/check_all.sh` at close, and
   `lean_audit.py --project mscong`.
5. Record the milestone in `STATE.md` and the journal; leave
   `mscong.ingested: false`; archive the change when complete.

Rollback: additive new modules plus a `Main` import; reverting the commit
restores the M4 state.

## Open Questions

- Reuse M4's `countPlaceholder` for derivor linearity via
  `Yplus φ (fun _ => Empty) w`, or add a parallel derivor counter? Decide when
  building D5; either keeps the specs and task breakdown unchanged.
- Whether `HallAlgHom` (and hence a `Ter_H`/`Op_H` homomorphism) is needed for
  any counterpart statement: currently no; if a statement is cleaner with it,
  add it minimally without opening the category layer.
