import Mscong.BasicTerms

/-!
# `Mscong.Substitution` -- substitution operators and `PRecSubs` (`MSCong` §3.2)

Milestone **M3** of the MSCong project (OpenSpec change
`add-substitution-recognizability`): the substitution operators on the free
`Σ`-algebra `T_Σ(X)` and the recognizability result `PRecSubs`.

Following the paper, the codomain of the substitution operators is the **subset
algebra** `A^℘` (`MSCong` Prop. `subsetalg`): carrier `fun s => Set (A s)`, with
the operation for `σ : Σ_{w,s}` sending `(L_i)` to the direct image
`{F_σ(a_i) | a_i ∈ L_i}`. The induced substitution homomorphism is the free
extension `termLift` of an assignment `X → A^℘`.

This is **unmapped infrastructure**: no block IDs, no evidence; `mscong` stays
`ingested: false` (see `design.md`, D5).
-/

namespace Mscong

open Mslang

attribute [local instance] Classical.propDecidable

universe u

variable {S : Type u}

/-! ### The subset algebra `A^℘` -/

/-- The carrier of the subset algebra `A^℘`: the `S`-sorted set of subsets. -/
abbrev pCarrier (A : SSet S) : SSet S := fun s => Set (A s)

/-- `MSCong` Prop. `subsetalg`: the subset `Σ`-algebra `A^℘` associated to `A`.
The operation for `σ : Σ_{w,s}` maps `(L_i)` to the direct image
`{F_σ(a_i) | a_i ∈ L_i}`. -/
noncomputable def pAlg (Sig : Signature S) (A : SSet S) (F : AlgStruct Sig A) : Alg Sig :=
  ⟨pCarrier A, fun p σ L => fun y =>
    ∃ (a : wordProd A p.1), (∀ i, a i ∈ L i) ∧ F p σ a = y⟩

/-- The insertion `{·}^Σ : A → A^℘`, `a ↦ {a}`. -/
def pEta {S : Type u} (A : SSet S) : SortedMap A (pCarrier A) :=
  fun _ a => {a}

/-- `MSCong` §3.2: the substitution homomorphism induced by an `S`-sorted
assignment `L : X → T_Σ(X)^℘`; the free extension of `L` from `T_Σ(X)` to the
subset algebra of `T_Σ(X)`. -/
noncomputable def substHom (Sig : Signature S) (X : SSet S)
    (L : SortedMap X (pCarrier (Term Sig X))) :
    SortedMap (Term Sig X) (pCarrier (Term Sig X)) :=
  termLift Sig X (pAlg Sig (Term Sig X) (termAlg Sig X).2).2 L

/-- The substitution homomorphism is a `Σ`-homomorphism (task 1.4). -/
theorem substHom_isAlgHom (Sig : Signature S) (X : SSet S)
    (L : SortedMap X (pCarrier (Term Sig X))) :
    IsAlgHom Sig (termAlg Sig X).2 (pAlg Sig (Term Sig X) (termAlg Sig X).2).2
      (substHom Sig X L) :=
  termLift_isAlgHom Sig X _ L

/-- The substitution homomorphism agrees with `L` on the generators `η^X`. -/
theorem substHom_eta (Sig : Signature S) (X : SSet S)
    (L : SortedMap X (pCarrier (Term Sig X))) :
    (fun s => substHom Sig X L s ∘ termEta Sig X s) = L :=
  termLift_eta Sig X _ L

/-- The substituted language of a language `K`: the union of the substitution
images `substHom L P` over `P ∈ K`. -/
noncomputable def substLang (Sig : Signature S) (X : SSet S)
    (L : SortedMap X (pCarrier (Term Sig X))) (s : S) (K : Set (Term Sig X s)) :
    Set (Term Sig X s) :=
  ⋃ P ∈ K, substHom Sig X L s P

/-! ### Single-variable substitution -/

/-- The single-variable substitution `(z\Q)(P)`: replace every occurrence of `z`
in `P` by `Q`. -/
noncomputable def subst1 (Sig : Signature S) (X : SSet S) {t : S} (z : X t)
    (Q : Term Sig X t) : (s : S) → Term Sig X s → Term Sig X s
  | s, Term.var y =>
      if h : s = t then
        (if (h ▸ y) = z then h.symm ▸ Q else Term.var y) else Term.var y
  | _, Term.op p σ a => Term.op p σ (fun i => subst1 Sig X z Q (p.1.get i) (a i))

theorem subst1_var_self (Sig : Signature S) (X : SSet S) {t : S} (z : X t)
    (Q : Term Sig X t) : subst1 Sig X z Q t (Term.var z) = Q := by
  simp only [subst1, dif_pos trivial, if_pos trivial]

theorem subst1_var_of_ne_sort (Sig : Signature S) (X : SSet S) {t s : S} {z : X t}
    (Q : Term Sig X t) (y : X s) (h : s ≠ t) :
    subst1 Sig X z Q s (Term.var y) = Term.var y := by
  simp only [subst1, dif_neg h]

theorem subst1_var_of_ne (Sig : Signature S) (X : SSet S) {t : S} {z : X t}
    (Q : Term Sig X t) (y : X t) (hy : y ≠ z) :
    subst1 Sig X z Q t (Term.var y) = Term.var y := by
  simp only [subst1, dif_pos trivial, if_neg hy]

theorem subst1_op (Sig : Signature S) (X : SSet S) {t : S} (z : X t)
    (Q : Term Sig X t) (p : List S × S) (σ : Sig p)
    (a : (i : Fin p.1.length) → Term Sig X (p.1.get i)) :
    subst1 Sig X z Q p.2 (Term.op p σ a)
      = Term.op p σ (fun i => subst1 Sig X z Q (p.1.get i) (a i)) := rfl

end Mscong
