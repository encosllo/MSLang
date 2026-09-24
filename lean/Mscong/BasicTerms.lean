import Mscong.Recognizable
import Mslang.Term

/-!
# `Mscong.BasicTerms` -- basic-term recognizability (`MSCong` §3.1)

Milestone **M2** of the MSCong project (OpenSpec change
`add-basic-terms-recognizability`): the propositions of `MSCong.tex` §3.1 over
the free `Σ`-algebra `T_Σ(X)` as presented by the inductive family
`Mslang.Term`. This file currently contains `PRecVar` and `PRecConst`;
`PRecOp` (the operation-on-variables singleton) is pending -- see `STATE.md`
session 129 for the exact obstacle.

Following the paper, each proof exhibits a **finite** recognising `Σ`-algebra
`B` and the free extension `g♯ : T_Σ(X) → B` of a sorted map `g : X → B`, such
that the singleton language is the fibre of a distinguished value of `B`.

This is **unmapped infrastructure**: no block IDs, no evidence; `mscong` stays
`ingested: false` (see `design.md`, D4).
-/

namespace Mscong

open Mslang

universe u

variable {S : Type u}

/-- The two-element type at universe `u` used as the carrier of `2^S`. -/
inductive Two : Type u where
  | z : Two
  | o : Two
  deriving DecidableEq

instance : Fintype Two := ⟨{Two.z, Two.o}, by intro x; cases x <;> simp⟩

instance : Nonempty Two := ⟨Two.z⟩

/-! ### The finite recognizing algebra `2^S` -/

/-- The two-element `Σ`-algebra `2^S` (`MSCong` §3.1): carrier `Two` at every
sort and every operation the constant map to `z`. -/
noncomputable def twoAlg (Sig : Signature S) : Alg Sig :=
  ⟨fun _ => Two, fun _ _ _ => Two.z⟩

/-- `2^S` is finite when the sort set `S` is finite (`MSCong` §3.1, Assumption). -/
theorem finiteAlg_twoAlg (Sig : Signature S) [Finite S] : FiniteAlg (twoAlg Sig) := by
  rw [FiniteAlg, finiteSSet_iff]
  refine ⟨?_, fun _s _ => inferInstanceAs (Finite Two)⟩
  have hsupp : supp (twoAlg Sig).1 = Set.univ := by
    ext s
    constructor
    · intro _; trivial
    · intro _; exact ⟨Two.z⟩
  rw [hsupp]
  exact Set.finite_univ

/-- `PRecVar` (`MSCong` §3.1): for a variable `x : X s`, the singleton language
`{x} ⊆ T_Σ(X)_s` is recognizable. -/
theorem PRecVar (Sig : Signature S) (X : SSet S) [Finite S] (s : S) (x : X s) :
    RecognizableAt Sig (termAlg Sig X) s ({Term.var x} : Set (Term Sig X s)) := by
  classical
  let g : SortedMap X (fun _ => Two) := fun t y =>
    if ht : t = s then (if ht ▸ y = x then Two.o else Two.z) else Two.z
  have hgx : g s x = Two.o := by simp only [g, dif_pos rfl, if_true]
  refine ⟨twoAlg Sig, finiteAlg_twoAlg Sig, termLift Sig X (twoAlg Sig).2 g,
    termLift_isAlgHom Sig X (twoAlg Sig).2 g, {Two.o}, ?_⟩
  ext P
  simp only [Set.mem_singleton_iff, Set.mem_preimage]
  constructor
  · rintro rfl
    exact hgx
  · intro h
    suffices ∀ (t : S) (P : Term Sig X t),
        termLift Sig X (twoAlg Sig).2 g t P = Two.o →
          HEq P (Term.var x) by
      exact eq_of_heq (this s P h)
    exact fun t P =>
      Term.rec (motive := fun t P =>
          termLift Sig X (twoAlg Sig).2 g t P = Two.o → HEq P (Term.var x))
        (fun {u : S} (y : X u) => fun hy => by
          change g u y = Two.o at hy
          by_cases ht : u = s
          · subst ht
            have hy' : (if y = x then Two.o else Two.z) = Two.o := by
              simpa only [g, dif_pos rfl] using hy
            by_cases hxy : y = x
            · subst hxy; exact HEq.refl _
            · rw [if_neg hxy] at hy'
              exact absurd hy' (by decide)
          · simp only [g, dif_neg ht] at hy
            exact absurd hy (by decide))
        (fun p τ a ih => fun hy => by
          change Two.z = Two.o at hy
          exact absurd hy (by decide))
        P

/-! ### `PRecConst` -/

/-- The `2^S`-variant used by `PRecConst`: the distinguished constant
`σ : Σ_{λ,s}` maps the unique element of `2_{λ}` to `o`, every other operation
to `z`. -/
noncomputable def twoAlgConst (Sig : Signature S) {s : S} (σ : Sig ([], s)) : Alg Sig := by
  classical
  exact ⟨fun _ => Two, fun p τ _ =>
    if h : p = ([], s) then
      (if (Eq.mp (congrArg Sig h) τ : Sig ([], s)) = σ then Two.o else Two.z)
    else Two.z⟩

/-- `PRecConst` (`MSCong` §3.1): for a constant `σ : Σ_{λ,s}`, the singleton
language `{σ} ⊆ T_Σ(X)_s` is recognizable. -/
theorem PRecConst (Sig : Signature S) (X : SSet S) [Finite S] (s : S) (σ : Sig ([], s)) :
    RecognizableAt Sig (termAlg Sig X) s
      ({Term.op ([], s) σ (fun i => i.elim0)} : Set (Term Sig X s)) := by
  classical
  let g : SortedMap X (fun _ => Two) := fun _ _ => Two.z
  have hσ : (Eq.mp (congrArg Sig rfl) σ : Sig ([], s)) = σ := rfl
  have hT0 : termLift Sig X (twoAlgConst Sig σ).2 g s
      (Term.op ([], s) σ (fun i => i.elim0)) = Two.o := by
    change (if h : ([], s) = ([], s) then
        (if (Eq.mp (congrArg Sig h) σ : Sig ([], s)) = σ then Two.o else Two.z)
        else Two.z) = Two.o
    rw [dif_pos rfl, if_pos hσ]
  refine ⟨twoAlgConst Sig σ, finiteAlg_twoAlg Sig, termLift Sig X (twoAlgConst Sig σ).2 g,
    termLift_isAlgHom Sig X (twoAlgConst Sig σ).2 g, {Two.o}, ?_⟩
  ext P
  simp only [Set.mem_singleton_iff, Set.mem_preimage]
  constructor
  · rintro rfl
    exact hT0
  · intro h
    suffices ∀ (t : S) (P : Term Sig X t),
        termLift Sig X (twoAlgConst Sig σ).2 g t P = Two.o →
          HEq P (Term.op ([], s) σ (fun i => i.elim0)) by
      exact eq_of_heq (this s P h)
    exact fun t P =>
      Term.rec (motive := fun t P =>
          termLift Sig X (twoAlgConst Sig σ).2 g t P = Two.o →
            HEq P (Term.op ([], s) σ (fun i => i.elim0)))
        (fun {u : S} (y : X u) => fun hy => by
          change g u y = Two.o at hy
          simp only [g] at hy
          exact absurd hy (by decide))
        (fun p τ a ih => fun hy => by
          change (if h : p = ([], s) then
              (if (Eq.mp (congrArg Sig h) τ : Sig ([], s)) = σ then Two.o else Two.z)
              else Two.z) = Two.o at hy
          by_cases hp : p = ([], s)
          · rw [dif_pos hp] at hy
            by_cases hτ : (Eq.mp (congrArg Sig hp) τ : Sig ([], s)) = σ
            · rw [if_pos hτ] at hy
              subst hp
              change τ = σ at hτ
              subst hτ
              apply heq_of_eq
              have hargs : a = (fun i : Fin ([].length) => i.elim0) :=
                funext (fun i => i.elim0)
              rw [hargs]
            · rw [if_neg hτ] at hy
              exact absurd hy (by decide)
          · rw [dif_neg hp] at hy
            exact absurd hy (by decide))
        P

end Mscong
