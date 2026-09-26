# Design

## Context

See `proposal.md` — Why. Current state that shapes the approach:

- `Mslang` supplies the inductive free algebra `Term Sig X`, its universal
  property (`termLift`, `termLift_isAlgHom`, `termLift_unique`), signatures
  (`Signature S = List S × S → Type u`), algebras (`Alg`, `AlgStruct`,
  `IsAlgHom`), the cogenerated congruence `congCogenerated`, saturation `IsSat`,
  and the finite-index calculus.
- M1/M2/M3 (`Mscong.Recognizable`, `Mscong.BasicTerms`, `Mscong.Substitution`,
  `Mscong.Iteration`, `Mscong.Quotient`) supply `Recognizable`/`RecognizableAt`,
  the finite-index characterization, `PRecVar`, base change of congruences
  (`pullbackEqv`/`isFiniteIndex_pullback`), and the subset-algebra machinery.
- `MSCong.tex` §3.5 defines hyperderivors, the induced `Σ`-algebra
  `c(T_Ξ(Y))`, tree homomorphisms, and proves `PRecH` (inverse image, no
  finiteness) and `PRecLH` (direct image, linear, finite `S,T,Σ,X`).
- `mscong` is still a scaffold (`ingested: false`).

## Goals / Non-Goals

**Goals:**

- Formalize `Δ_φ`, hyperderivors, `c(T_Ξ(Y))`, tree homomorphisms, `PRecH`, and
  `PRecLH` in `Mscong`, reusing `Mslang` and M1–M3.
- Keep it **unmapped infrastructure**: no block IDs, no evidence, no change to
  `mslang`, `mscong` stays `ingested: false`.
- Build clean, `sorry`-free, within the permitted axiom set.

**Non-Goals:**

- `PRecILH` (commented out in the manuscript).
- Derivors / Hall algebras (M5); the correspondence audit (M6).
- Any manuscript edit, block-ID minting, evidence record, or mapping.

## Decisions

### D1. Base change `Δ_φ`

`Δ_φ Y := fun s => Y (φ s)` for `φ : S → T`, `Y : SSet T`, a `SSet S`. This is
`A ∘ φ`; no functoriality beyond the object map is needed for `PRecH`/`PRecLH`.

### D2. Hyperderivor and the per-arity variable set

A `Hyperderivor Sig Xi X Y` is a structure with

- `phi : S → T`,
- `c : (p : List S × S) → Sig p → Term Xi (Yplus p) (phi p.2)`, where
  `Yplus p : SSet T := fun t => Y t ⊕ {i : Fin p.1.length // phi (p.1.get i) = t}`
  is the paper's `Y ∪ ↓φ*(w)` (fresh placeholders, one per argument position and
  sorted by `φ`),
- `f : SortedMap X (fun s => Term Xi Y (phi s))`.

Rationale: the paper's `↓φ*(w)` is a `T`-sorted set of placeholders whose
`t`-component is the set of positions `i < |w|` with `φ(w_i) = t`, i.e. exactly
the `Sum.inr` summand; `Y` is the `Sum.inl` summand. This avoids an
`isomorphic`/disjointness side condition (the paper's disjointness assumption is
automatic with the coproduct).

### D3. `c(T_Ξ(Y))` and `treeHom` via the universal property

The operation for `σ : Σ_{w,s}` on arguments `a : (i) → T_Ξ(Y)_{φ(w_i)}` is

`cSubst c σ a := termLift Xi (Yplus w) (termAlg Xi Y).2 g_a (φ s) (c (w,s) σ)`,

where `g_a : SortedMap (Yplus w) (Term Xi Y)` maps `Sum.inl y ↦ Term.var y` and
`Sum.inr ⟨i, hi⟩ ↦ hi ▸ a i`. This is the paper's `S^w_{(a_i)}(c(σ))` (substitute
each placeholder by the corresponding argument). The resulting
`AlgStruct Sig (fun s => Term Xi Y (phi s))` is `cAlg`, and the tree
homomorphism is `treeHom := termLift Sig X (cAlg).2 f`, a `Σ`-homomorphism by
`termLift_isAlgHom`.

### D4. Linearity

The paper: no placeholder `v^{φ(w_i)}_i` occurs more than once in `c_{w,s}(σ)`.
We encode this as an occurrence-count predicate on `c (w,s) σ`: a `Nat`-valued
count of the `Sum.inr ⟨i, _⟩` variables, required `≤ 1`. A structural
`countVar`/`occurs` function on `Term` supplies it. Rationale: this is the exact
hypothesis `PRecLH` uses (linearity makes the direct image computable by a
finite-index saturation); a weaker "injective on positions" phrasing is not
enough for the paper's argument.

### D5. `PRecH` via the induced algebra

Given `L ∈ Rec_{φ(s)}(T_Ξ(Y))`, fix a finite `Ξ`-algebra `A`, a hom
`g : T_Ξ(Y) → A`, and `M ⊆ A_{φ(s)}` with `L = g_{φ(s)}⁻¹[M]`. The structure
`c(A)` on `A_φ` (`IndAlgStrucImHom`) is defined on representatives and is
well-defined by `g` being a hom and `c` substituting; then `g_φ : c(T_Ξ(Y)) →
c(A)` is a hom and `(f♯)⁻¹[L] = (g_φ ∘ f♯)⁻¹[M]`, so it is recognized by the
finite `Σ`-algebra `c(A)`. No finiteness hypothesis on `S,T,Σ,X`.

### D6. `PRecLH` via a refined congruence

For a **linear** hyperderivor and finite `S,T,Σ,X`, the paper fixes
`Φ = ⋂_{(x,r)} Ω(δ^{φ(r),{f_r(x)}})` (finite index, saturating each `{f_r(x)}`),
`Θ = Ω(δ^{s,L})` (finite index, saturating `L`), and refines `Φ` by `Ψ` on
`T_Ξ(Y)`: `(M,N) ∈ Ψ_t` iff `M Φ_t N` and, for every `Θ_r`-class `[W]`, the
direct images `f♯_r[[W]]` agree on `M`/`N`. Then `Ψ` is a finite-index
congruence and `f♯_s[L]` is `Ψ_{φ(s)}`-saturated, giving `PRecLH` by
`recognizable_iff_exists_finiteIndex_sat`. The linearity of `c` is used exactly
in the operation case, where two `Ψ`-related argument families must yield the
same membership in each `f♯_r[[W]]`.

### D7. Module layout and unmapped infrastructure

Everything goes in `lean/Mscong/TreeHom.lean` (definitions, `PRecH`, `PRecLH`),
imported by `Mscong.Main`. No declaration is added to
`lean/declarations.mscong.json`; audited by `lean_audit.py --project mscong`.

## Risks / Trade-offs

- **The placeholder encoding (D2) vs the paper's `Y ∪ ↓φ*(w)`.** The coproduct
  is faithful and avoids disjointness bookkeeping, but the "same variable, many
  positions" reading (the paper's `↓v^t_n` convention where positions of equal
  sort share variables by index) differs: the paper identifies placeholders by
  position *and* allows the `Remark`'s alternative indexing. Our `Sum.inr` is
  the position-indexed form, which is what substitution needs. Recorded as a
  deliberate encoding choice.
- **Linearity (D4)** needs an occurrence-count function and its lemmas; if a
  clean count is hard, the count can be taken over a `Finset` of positions with
  a `≤ 1` condition.
- **`PRecLH` is the technical heart** (finite transversal + `Ψ` refinement);
  like `PRecSubs`/`PRecIt` it may need a bespoke argument. If `PRecLH` proves
  too large, the change may be closed in stages (definitions + `PRecH` first),
  a coordinator decision recorded in `STATE.md`.
- **Assumption hygiene**: `PRecH` needs no finiteness; `PRecLH` needs `S,T,Σ,X`
  finite. Keep them exactly as the paper states.

## Migration Plan

1. Extend `lean/Mscong/TreeHom.lean` in dependency order: `Delta`, `Yplus`,
  `Hyperderivor`, `cSubst`/`cAlg`, `treeHom`, `PRecH`, then `PRecLH`.
2. Iterate with a targeted `lake build Mscong.TreeHom`.
3. Run `scripts/check_all.sh --fast`, one `scripts/check_all.sh` at close, and
   `lean_audit.py --project mscong`.
4. Record the milestone in `STATE.md`; leave `mscong.ingested: false`; archive
   the change when complete.

Rollback: additive to `Mscong.TreeHom`; reverting the commit restores the
scaffold.

## Open Questions

- Represent linearity as a recursive `Nat` occurrence count, or as a
  `Finset`-based "positions where the placeholder occurs" with `.card ≤ 1`?
  Decide when building D4.
- Whether `PRecH`'s `IndAlgStrucImHom` needs `A` finite (it should not; only
  `PRecLH` does).
