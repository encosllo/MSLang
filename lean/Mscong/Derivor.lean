import Mscong.Hall
import Mscong.TreeHom

/-!
# `Mscong.Derivor` -- derivors and their recognizability theorems (`MSCong` §6)

Milestone **M5** of the MSCong project (OpenSpec change
`add-derivors-hall-algebras`), continued: a **derivor** `(φ, d)` from `(S, Σ)` to
`(T, Λ)` is a sort map `φ : S → T` together with a map `d` sending each
`σ : Σ_{w,s}` to a term in `T_Λ(↓φ*(w))_{φ(s)}`. A derivor (with data) gives
rise to a hyperderivor, so the two derivor recognizability propositions follow
from M4's `PRecH` and `PRecLH`.

This is **unmapped infrastructure**: no block IDs, no evidence; `mscong` stays
`ingested: false` (see `design.md`). The free-Hall-algebra isomorphism and the
category-theoretic layer (`Sig_d`, `Alg_d`) are out of scope.
-/

namespace Mscong

open Mslang

universe u

variable {S T : Type u}

/-! ### Derivors -/

/-- A derivor from `(S, Σ)` to `(T, Λ)` (`MSCong` §6): a sort map `φ : S → T`
and `d` sending `σ : Σ_{w,s}` to a term in `T_Λ(↓φ*(w))_{φ(s)}`. -/
structure Derivor (φ : S → T) (Sig : Signature S) (Lam : Signature T) where
  /-- The action on operation symbols. -/
  d : (p : List S × S) → Sig p → Term Lam (derivPlace φ p.1) (φ p.2)

/-- The number of occurrences of the placeholder at position `i` in a term with
variables `↓φ*(w)`. -/
def countPlaceholderD {S T : Type u} {Lam : Signature T} (φ : S → T) (w : List S)
    (i : Fin w.length) : {t : T} → Term Lam (derivPlace φ w) t → ℕ
  | _, Term.var v => if (v.down.1 : Fin w.length) = i then 1 else 0
  | _, Term.op _ _ a => Finset.univ.sum (fun j => countPlaceholderD φ w i (a j))

/-- The canonical inclusion `↓φ*(w) ↪ Y ∪ ↓φ*(w)` underlying the derivor
→ hyperderivor construction. -/
def placeIncl {S T : Type u} (Lam : Signature T) (φ : S → T) (Y : SSet T)
    (w : List S) : SortedMap (derivPlace φ w) (Term Lam (Yplus φ Y w)) :=
  fun _ v => Term.var (Sum.inr v.down)

/-- A derivor is **linear** when every placeholder occurs at most once in each
`d(σ)` (`MSCong` §6). -/
def Derivor.IsLinear {φ : S → T} (D : Derivor φ Sig Lam) : Prop :=
  ∀ (p : List S × S) (σ : Sig p) (i : Fin p.1.length),
    countPlaceholderD φ p.1 i (D.d p σ) ≤ 1

/-! ### The hyperderivor induced by a derivor -/

/-- The **hyperderivor** determined by a derivor together with `f : X → T_Λ(Y)_φ`:
`d^Y` composes `d` with the canonical inclusion `↓φ*(w) ↪ Y ∪ ↓φ*(w)`
(`MSCong` §6, the derivor→hyperderivor proposition). -/
def Derivor.toHyperderivor {φ : S → T} (D : Derivor φ Sig Lam) (X : SSet S)
    (Y : SSet T) (f : SortedMap X (fun s => Term Lam Y (φ s))) :
    Hyperderivor φ Sig Lam X Y where
  c := fun p σ =>
    termSubst Lam (placeIncl Lam φ Y p.1) (φ p.2) (D.d p σ)
  f := f

/-- The occurrence count is preserved by the inclusion `↓φ*(w) ↪ Y ∪ ↓φ*(w)`. -/
theorem countPlaceholder_toHyperderivor {φ : S → T} {Lam : Signature T}
    {Y : SSet T} {w : List S} (i : Fin w.length) :
    ∀ {s : T} (P : Term Lam (derivPlace φ w) s),
      countPlaceholder φ w i (termSubst Lam (placeIncl Lam φ Y w) s P)
        = countPlaceholderD φ w i P := by
  intro s P
  refine Term.rec (motive := fun s P =>
      countPlaceholder φ w i (termSubst Lam (placeIncl Lam φ Y w) s P)
        = countPlaceholderD φ w i P) ?var ?op P
  case var =>
    intro s v
    simp only [termSubst_var, placeIncl, countPlaceholder, countPlaceholderD]
  case op =>
    intro p σ a ih
    simp only [termSubst_op, countPlaceholder, countPlaceholderD]
    exact Finset.sum_congr rfl (fun j _ => ih j)

/-- The hyperderivor induced by a linear derivor is linear. -/
theorem Derivor.toHyperderivor_isLinear {φ : S → T} {D : Derivor φ Sig Lam}
    (hirr : D.IsLinear) (X : SSet S) (Y : SSet T)
    (f : SortedMap X (fun s => Term Lam Y (φ s))) :
    (D.toHyperderivor X Y f).IsLinear := by
  intro p σ i
  show countPlaceholder φ p.1 i
      (termSubst Lam (placeIncl Lam φ Y p.1) (φ p.2) (D.d p σ)) ≤ 1
  rw [countPlaceholder_toHyperderivor]
  exact hirr p σ i

/-! ### Recognizability under a derivor -/

/-- The inverse image of a recognizable language under a derivor's tree
homomorphism is recognizable (`MSCong` §6; from `PRecH`). -/
theorem PRecDerivor {φ : S → T} [Finite S] (D : Derivor φ Sig Lam) (X : SSet S)
    (Y : SSet T) (f : SortedMap X (fun s => Term Lam Y (φ s))) (s : S)
    (L : Set (Term Lam Y (φ s)))
    (hL : RecognizableAt Lam (termAlg Lam Y) (φ s) L) :
    RecognizableAt Sig (termAlg Sig X) s
      ((treeHom (D.toHyperderivor X Y f) s) ⁻¹' L) :=
  PRecH (D.toHyperderivor X Y f) s L hL

/-- The direct image of a recognizable language under a **linear** derivor's tree
homomorphism is recognizable (`MSCong` §6; from `PRecLH`). -/
theorem PRecLinDerivor {φ : S → T} [Finite S] [Finite T] [Finite (Sigma Sig)]
    (D : Derivor φ Sig Lam) (hirr : D.IsLinear) (X : SSet S) (hX : FiniteSSet X)
    (Y : SSet T) (f : SortedMap X (fun s => Term Lam Y (φ s))) (s : S)
    (L : Set (Term Sig X s)) (hL : RecognizableAt Sig (termAlg Sig X) s L) :
    RecognizableAt Lam (termAlg Lam Y) (φ s)
      (treeHom (D.toHyperderivor X Y f) s '' L) :=
  PRecLH (D.toHyperderivor X Y f) (D.toHyperderivor_isLinear hirr X Y f) hX s L hL

end Mscong
