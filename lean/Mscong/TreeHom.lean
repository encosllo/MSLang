import Mscong.Substitution

/-!
# `Mscong.TreeHom` -- hyperderivors and tree homomorphisms (`MSCong` §3.5)

Milestone **M4** of the MSCong project (OpenSpec change
`add-tree-homomorphisms-recognizability`): the base change `Δ_φ`, hyperderivors,
the induced `Σ`-algebra `c(T_Ξ(Y))`, tree homomorphisms, and the recognizability
results `PRecH` (inverse image) and `PRecLH` (direct image of a linear tree
homomorphism).

Following the paper, a **hyperderivor** from `(Σ, X)` to `(Ξ, Y)` is a sort map
`φ : S → T`, an `S⋆ × S`-indexed map `c` sending `σ : Σ_{w,s}` to a term in
`T_Ξ(Y ∪ ↓φ*(w))_{φ(s)}` (the fresh placeholders `↓φ*(w)`, one per argument
position), and a sorted map `f : X → T_Ξ(Y)_φ`. We encode `Y ∪ ↓φ*(w)` as the
coproduct `Yplus φ Y w t = Y t ⊕ {i : Fin w.length // φ (w.get i) = t}`; the
`σ`-operation of `c(T_Ξ(Y))` substitutes the argument family into `c(σ)` along
the universal property, and the tree homomorphism is the free extension of `f`.

This is **unmapped infrastructure**: no block IDs, no evidence; `mscong` stays
`ingested: false` (see `design.md`).
-/

namespace Mscong

open Mslang

set_option linter.style.haveILetI false

universe u

variable {S T : Type u}

/-! ### Base change `Δ_φ` -/

/-- The base change `Δ_φ(A) = A ∘ φ` of a `T`-sorted set along `φ : S → T`. -/
abbrev Delta (φ : S → T) (A : SSet T) : SSet S := fun s => A (φ s)

/-! ### Hyperderivors -/

/-- The paper's `Y ∪ ↓φ*(w)`: the `T`-sorted set of the variables `Y` together
with the fresh placeholders, one per argument position `i < |w|`, placed at sort
`φ(w_i)`. -/
abbrev Yplus (φ : S → T) (Y : SSet T) (w : List S) : SSet T :=
  fun t => Y t ⊕ {i : Fin w.length // φ (w.get i) = t}

/-- A **hyperderivor** from `(Σ, X)` to `(Ξ, Y)` (`MSCong` §3.5): the
`S⋆ × S`-indexed `c` (a term in `T_Ξ(Y ∪ ↓φ*(w))_{φ(s)}` for `σ : Σ_{w,s}`),
and `f : X → T_Ξ(Y)_φ`, along a sort map `φ`. -/
structure Hyperderivor (φ : S → T) (Sig : Signature S) (Xi : Signature T)
    (X : SSet S) (Y : SSet T) where
  /-- The term assigned to each operation symbol `σ : Σ_{w,s}`. -/
  c : (p : List S × S) → Sig p → Term Xi (Yplus φ Y p.1) (φ p.2)
  /-- The sorted map on the generators. -/
  f : SortedMap X (fun s => Term Xi Y (φ s))

/-- The number of occurrences of the placeholder at position `i` in a term with
the variable set `Yplus φ Y w`. -/
def countPlaceholder {Xi : Signature T} {Y : SSet T} (φ : S → T) (w : List S)
    (i : Fin w.length) : {u : T} → Term Xi (Yplus φ Y w) u → ℕ
  | _, Term.var v =>
      match v with
      | Sum.inl _ => 0
      | Sum.inr q => if (q.1 : Fin w.length) = i then 1 else 0
  | _, Term.op _ _ a => Finset.univ.sum (fun j => countPlaceholder φ w i (a j))

/-- A hyperderivor is **linear** when every placeholder occurs at most once
(`MSCong` §3.5). -/
def Hyperderivor.IsLinear {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) : Prop :=
  ∀ (p : List S × S) (σ : Sig p) (i : Fin p.1.length),
    countPlaceholder φ p.1 i (H.c p σ) ≤ 1

/-! ### The induced `Σ`-algebra `c(T_Ξ(Y))` -/

/-- Substituting the argument family `a` into the term `c(σ)`: the paper's
`S^w_{(a_i)}(c(σ))`. -/
noncomputable def cSubst {φ : S → T} (H : Hyperderivor φ Sig Xi X Y)
    (p : List S × S) (σ : Sig p)
    (a : (i : Fin p.1.length) → Term Xi Y (φ (p.1.get i))) :
    Term Xi Y (φ p.2) :=
  termLift Xi (Yplus φ Y p.1) (termAlg Xi Y).2
    (fun _ v =>
      match v with
      | Sum.inl y => Term.var y
      | Sum.inr q => q.2 ▸ a q.1)
    (φ p.2) (H.c p σ)

/-- The `Σ`-algebra structure `c(T_Ξ(Y))` on `T_Ξ(Y)_φ` (`MSCong` §3.5): the
operation for `σ` substitutes the arguments into `c(σ)`. -/
noncomputable def cAlg {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) :
    AlgStruct Sig (fun s => Term Xi Y (φ s)) :=
  fun p σ a => cSubst H p σ a

/-- The **tree homomorphism** `f♯ : T_Σ(X) → c(T_Ξ(Y))` determined by a
hyperderivor `(c, f)`: the free extension of `f`. -/
noncomputable def treeHom {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) :
    SortedMap (Term Sig X) (fun s => Term Xi Y (φ s)) :=
  termLift Sig X (cAlg H) H.f

/-- The tree homomorphism is a `Σ`-homomorphism. -/
theorem treeHom_isAlgHom {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) :
    IsAlgHom Sig (termAlg Sig X).2 (cAlg H) (treeHom H) :=
  termLift_isAlgHom Sig X (cAlg H) H.f

/-- The tree homomorphism agrees with `f` on the generators. -/
theorem treeHom_eta {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) :
    (fun s => treeHom H s ∘ termEta Sig X s) = H.f :=
  termLift_eta Sig X (cAlg H) H.f

end Mscong
