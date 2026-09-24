import Mslang.Regular
import Mslang.Formation

/-!
# `Mscong.Recognizable` -- the finite-index recognizability calculus (MSCong §2.3)

Milestone **M1** of the MSCong project (OpenSpec change
`add-recognizability-calculus`): the *finite-index* half of the recognizability
calculus, built on `Mslang`'s shared preliminaries.

Reused from `Mslang` (no redefinition):

* congruences of finite index: `Mslang.IsFiniteIndex`, `Mslang.congFi`, and the
  closure/filter facts `Mslang.IsFiniteIndex_of_le`, `Mslang.IsFiniteIndex_inf`,
  `Mslang.congFi_filter`;
* the cogenerated congruence `Ω^A(L)` = `Mslang.congCogenerated`, saturation
  `Mslang.IsSat`/`Mslang.sat`, quotients `Mslang.quotAlg`/`Mslang.prAlg`, and the
  Kronecker concentration `Mslang.deltaSub`;
* regular language `Mslang.IsRegularLanguage` (`Ω^A(L)` of finite index).

New here: the paper's *existential* definition of recognizability (a finite
`Σ`-algebra `B`, a homomorphism `f : A → B`, and `M ⊆ B` with `L = f⁻¹[M]`),
its characterization by a finite-index saturation, the sort-indexed version and
its `δ^{s,L}` bridge, and closure under the Boolean operations.

This is **unmapped infrastructure**: no block IDs, no evidence; `mscong` stays
`ingested: false` (see `design.md`, D5).
-/

namespace Mscong

open Mslang

-- The `haveI`s below register `Finite` instances consumed by `Finite.of_surjective`;
-- the style linter's `have` suggestion would not register them (the same false
-- positive suppressed at file scope in `Mslang/Prelim.lean`).
set_option linter.style.haveILetI false

universe u

variable {S : Type u}

/-! ### Kernel of a homomorphism into a finite algebra -/

/-- The quotient by the kernel of `f` is finite when the codomain component is:
it is a quotient of the (finite) range of `f s`. -/
theorem finite_quot_ker {A B : SSet S}
    (f : SortedMap A B) (s : S) (hBs : Finite (B s)) :
    Finite (Quotient ((ker f) s)) := by
  haveI : Finite (B s) := hBs
  haveI : Finite (Set.range (f s)) :=
    Finite.of_injective (fun b : Set.range (f s) => b.1)
      (by intro a b h; exact Subtype.ext h)
  refine Finite.of_surjective
    (f := fun b : Set.range (f s) => Quotient.mk ((ker f) s) (Classical.choose b.2)) ?_
  intro q
  induction q using Quotient.inductionOn with
  | h a =>
      have hb : f s a ∈ Set.range (f s) := ⟨a, rfl⟩
      exact ⟨⟨f s a, hb⟩, Quotient.sound (Classical.choose_spec hb)⟩

/-- The kernel of a homomorphism into a finite algebra has finite index. -/
theorem isFiniteIndex_ker {A B : SSet S}
    (f : SortedMap A B) (hB : FiniteSSet B) : IsFiniteIndex (ker f) := by
  have hBiff := (finiteSSet_iff B).mp hB
  have hsubset : supp (quot (ker f)) ⊆ supp B := by
    intro s hs
    obtain ⟨q⟩ := hs
    exact ⟨Quotient.liftOn q (fun a => f s a) (fun _ _ h => h)⟩
  unfold IsFiniteIndex
  rw [finiteSSet_iff]
  exact ⟨hBiff.1.subset hsubset,
    fun s hs => finite_quot_ker f s (hBiff.2 s (hsubset hs))⟩

/-- The quotient by the pullback of `Ψ` along `f` injects into `Ψ`'s quotient. -/
theorem finite_quot_pullback {A B : SSet S} (f : SortedMap A B) (Ψ : SortedEqv B)
    (s : S) (h : Finite (Quotient (Ψ s))) :
    Finite (Quotient ((pullbackEqv f Ψ) s)) := by
  haveI := h
  refine Finite.of_injective (Quotient.map (f s) (fun _ _ h => h)) ?_
  intro x y hxy
  induction x using Quotient.inductionOn with
  | h a =>
      induction y using Quotient.inductionOn with
      | h b =>
          rw [Quotient.map_mk, Quotient.map_mk] at hxy
          exact Quotient.sound (Quotient.exact hxy : (Ψ s).r (f s a) (f s b))

/-- The pullback of a finite-index sorted equivalence along any sorted map has
finite index. -/
theorem isFiniteIndex_pullback {A B : SSet S} (f : SortedMap A B) (Ψ : SortedEqv B)
    (h : IsFiniteIndex Ψ) : IsFiniteIndex (pullbackEqv f Ψ) := by
  have hiff := (finiteSSet_iff (quot Ψ)).mp h
  have hsubset : supp (quot (pullbackEqv f Ψ)) ⊆ supp (quot Ψ) := by
    intro s hs
    obtain ⟨q⟩ := hs
    exact ⟨Quotient.lift (fun a => Quotient.mk (Ψ s) (f s a))
      (fun _ _ h => Quotient.sound h) q⟩
  unfold IsFiniteIndex
  rw [finiteSSet_iff]
  exact ⟨hiff.1.subset hsubset,
    fun s hs => finite_quot_pullback f Ψ s (hiff.2 s (hsubset hs))⟩

/-! ### Recognizability (the paper's existential definition) -/

/-- A language `L ⊆ A` is *recognizable* (`MSCong` §2.3, `T = S`) when there is
a finite `Σ`-algebra `B`, a homomorphism `f : A → B`, and `M ⊆ B` with
`L = f⁻¹[M]`. -/
def Recognizable (Sig : Signature S) (A : Alg Sig) (L : Sub A.1) : Prop :=
  ∃ B : Alg Sig, FiniteAlg B ∧
    ∃ f : SortedMap A.1 B.1, IsAlgHom Sig A.2 B.2 f ∧
      ∃ M : Sub B.1, L = inverseImage f M

/-- A language `L ⊆ A_s` is `s`-*recognizable* when there is a finite
`Σ`-algebra `B`, a homomorphism `f : A → B`, and `M ⊆ B_s` with
`L = f_s⁻¹[M]`. -/
def RecognizableAt (Sig : Signature S) (A : Alg Sig) (s : S) (L : Set (A.1 s)) : Prop :=
  ∃ B : Alg Sig, FiniteAlg B ∧
    ∃ f : SortedMap A.1 B.1, IsAlgHom Sig A.2 B.2 f ∧
      ∃ M : Set (B.1 s), L = f s ⁻¹' M

/-! ### The `T`-indexed predicate `Rec_T` and its zero-extension -/

/-- The zero-extension `[L, ∅^{S−T}]` of a `T`-indexed language to a language of
`A`: `L` on the sorts in `T`, the empty language elsewhere. -/
noncomputable def zeroExtension {S : Type u} {A : SSet S} (T : Set S)
    (L : (t : T) → Set (A t.1)) : Sub A := by
  classical
  exact fun s => if hs : s ∈ T then L ⟨s, hs⟩ else ∅

theorem zeroExtension_self {S : Type u} {A : SSet S} (T : Set S)
    (L : (t : T) → Set (A t.1)) (t : T) : zeroExtension T L t.1 = L t := by
  classical
  simp only [zeroExtension, dif_pos t.2]

theorem zeroExtension_of_notMem {S : Type u} {A : SSet S} {T : Set S}
    (L : (t : T) → Set (A t.1)) {s : S} (hs : s ∉ T) :
    zeroExtension T L s = ∅ := by
  classical
  simp only [zeroExtension, dif_neg hs]

/-- `MSCong` §2.3: a `T`-indexed language `L ⊆ A↾_T` is `T`-*recognizable* when
there is a finite `Σ`-algebra `B`, a homomorphism `f : A → B`, and a subset
`M ⊆ B↾_T` with `L_t = f_t⁻¹[M_t]` for every `t ∈ T`. -/
def RecognizableOn (Sig : Signature S) (A : Alg Sig) (T : Set S)
    (L : (t : T) → Set (A.1 t.1)) : Prop :=
  ∃ B : Alg Sig, FiniteAlg B ∧
    ∃ f : SortedMap A.1 B.1, IsAlgHom Sig A.2 B.2 f ∧
      ∃ M : (t : T) → Set (B.1 t.1), ∀ t, L t = f t.1 ⁻¹' M t

/-! ### Characterization by a finite-index saturation -/

/-- `(1) ⟹ (3)`: a recognizable language has `Ω^A(L)` of finite index. -/
theorem recognizable_isRegularLanguage (Sig : Signature S) (A : Alg Sig) (L : Sub A.1)
    (h : Recognizable Sig A L) : IsRegularLanguage Sig A L := by
  rcases h with ⟨B, hB, f, hf, M, hM⟩
  rw [hM]
  unfold IsRegularLanguage
  have hker : IsCongruence Sig A.2 (ker f) := ker_isCongruence Sig A.2 B.2 f hf
  have hsat : IsSat (ker f) (inverseImage f M) := by
    unfold IsSat sat inverseImage ker
    funext s
    ext a
    constructor
    · rintro ⟨x, hx, hxa⟩
      show f s a ∈ M s
      rw [← (hxa : f s x = f s a)]
      exact hx
    · intro ha
      exact ⟨a, ha, rfl⟩
  have hle : sortedEqvLe (ker f) (congCogenerated Sig A (inverseImage f M)) :=
    (isSat_iff_le_congCogenerated Sig A (inverseImage f M) hker).mp hsat
  exact IsFiniteIndex_of_le hle (isFiniteIndex_ker f hB)

/-- `(3) ⟹ (1)`: a language saturated by a finite-index congruence is
recognizable (take the quotient by `Ω^A(L)` and the projection). -/
theorem isRegularLanguage_recognizable (Sig : Signature S) (A : Alg Sig) (L : Sub A.1)
    (h : IsRegularLanguage Sig A L) : Recognizable Sig A L := by
  unfold IsRegularLanguage at h
  have hc : IsCongruence Sig A.2 (congCogenerated Sig A L) :=
    congCogenerated_isCongruence Sig A L
  refine ⟨quotAlg Sig A.2 (congCogenerated Sig A L) hc, ?_,
    prAlg Sig A.2 (congCogenerated Sig A L) hc,
    isAlgHom_prAlg Sig A.2 (congCogenerated Sig A L) hc,
    directImage (prAlg Sig A.2 (congCogenerated Sig A L) hc) L, ?_⟩
  · simpa [FiniteAlg, quotAlg, IsFiniteIndex] using h
  · have hsat : IsSat (congCogenerated Sig A L) L := isSat_congCogenerated Sig A L
    rw [IsSat] at hsat
    calc L = sat (congCogenerated Sig A L) L := hsat.symm
      _ = inverseImage (prAlg Sig A.2 (congCogenerated Sig A L) hc)
            (directImage (prAlg Sig A.2 (congCogenerated Sig A L) hc) L) := by
            rw [sat_eq_preimage (congCogenerated Sig A L) L]
            rfl

/-- The paper's equivalence `(1) ⟺ (3)`: recognizable iff `Ω^A(L)` has finite
index. -/
theorem recognizable_iff_isRegularLanguage (Sig : Signature S) (A : Alg Sig) (L : Sub A.1) :
    Recognizable Sig A L ↔ IsRegularLanguage Sig A L :=
  ⟨recognizable_isRegularLanguage Sig A L, isRegularLanguage_recognizable Sig A L⟩

/-- The paper's assertion `(2)`: recognizable iff saturated by a congruence of
finite index. -/
theorem recognizable_iff_exists_finiteIndex_sat (Sig : Signature S) (A : Alg Sig) (L : Sub A.1) :
    Recognizable Sig A L ↔
      ∃ Φ : SortedEqv A.1, IsCongruence Sig A.2 Φ ∧ IsFiniteIndex Φ ∧ IsSat Φ L := by
  constructor
  · intro h
    exact ⟨congCogenerated Sig A L, congCogenerated_isCongruence Sig A L,
      (recognizable_iff_isRegularLanguage Sig A L).mp h, isSat_congCogenerated Sig A L⟩
  · rintro ⟨Φ, hΦc, hΦf, hΦs⟩
    exact (recognizable_iff_isRegularLanguage Sig A L).mpr
      (IsFiniteIndex_of_le ((isSat_iff_le_congCogenerated Sig A L hΦc).mp hΦs) hΦf)

/-! ### The `T`-indexed characterization (`MSCong` §2.3) -/

/-- A `T`-indexed language is `T`-recognizable if and only if its zero-extension
`[L, ∅^{S−T}]` is recognizable; the restriction bookkeeping is absorbed by the
zero-extension. -/
theorem recognizableOn_iff_zeroExtension (Sig : Signature S) (A : Alg Sig) (T : Set S)
    (L : (t : T) → Set (A.1 t.1)) :
    RecognizableOn Sig A T L ↔ Recognizable Sig A (zeroExtension T L) := by
  constructor
  · rintro ⟨B, hB, f, hf, M, hM⟩
    refine ⟨B, hB, f, hf, directImage f (zeroExtension T L), ?_⟩
    funext s
    by_cases hs : s ∈ T
    · simp only [zeroExtension, dif_pos hs, directImage, inverseImage]
      -- `zeroExtension T L` is `f`-saturated on the sorts in `T`
      ext a
      constructor
      · intro ha
        exact ⟨a, ha, rfl⟩
      · rintro ⟨x, hx, hxa⟩
        have hxM : f s x ∈ M ⟨s, hs⟩ := by
          have h := hM ⟨s, hs⟩
          rw [h] at hx
          exact hx
        have hfa : f s a ∈ M ⟨s, hs⟩ := by rw [← hxa]; exact hxM
        have h := hM ⟨s, hs⟩
        rw [h]
        exact hfa
    · simp only [zeroExtension, dif_neg hs, directImage, inverseImage,
        Set.image_empty, Set.preimage_empty]
  · rintro ⟨B, hB, f, hf, M, hM⟩
    refine ⟨B, hB, f, hf, fun t => M t.1, ?_⟩
    intro t
    have h := congrFun hM t.1
    rw [zeroExtension_self T L t] at h
    simpa [inverseImage] using h

/-- The `T`-indexed characterization `(1) ⟺ (3)`: `L` is `T`-recognizable if and
only if `Ω^A([L, ∅^{S−T}])` has finite index. -/
theorem recognizableOn_iff_finiteIndex_zeroExtension (Sig : Signature S) (A : Alg Sig)
    (T : Set S) (L : (t : T) → Set (A.1 t.1)) :
    RecognizableOn Sig A T L ↔
      IsFiniteIndex (congCogenerated Sig A (zeroExtension T L)) :=
  (recognizableOn_iff_zeroExtension Sig A T L).trans
    (recognizable_iff_isRegularLanguage Sig A (zeroExtension T L))

/-- The `T`-indexed characterization `(1) ⟺ (2)`: `L` is `T`-recognizable if and
only if it is saturated by a congruence of finite index (with the outside-`T`
components empty). -/
theorem recognizableOn_iff_exists_finiteIndex_sat (Sig : Signature S) (A : Alg Sig)
    (T : Set S) (L : (t : T) → Set (A.1 t.1)) :
    RecognizableOn Sig A T L ↔
      ∃ Φ : SortedEqv A.1, IsCongruence Sig A.2 Φ ∧ IsFiniteIndex Φ ∧
        IsSat Φ (zeroExtension T L) :=
  (recognizableOn_iff_zeroExtension Sig A T L).trans
    (recognizable_iff_exists_finiteIndex_sat Sig A (zeroExtension T L))

/-! ### The sort-indexed bridge `L ∈ Rec_s(A) ⟺ δ^{s,L} ∈ Rec(A)` -/

/-- The Kronecker concentration of a sort language is recognizable iff the sort
language is (`MSCong` §2.3, `s-Rec iff Rec`). -/
theorem recognizableAt_iff (Sig : Signature S) (A : Alg Sig) (s : S) (L : Set (A.1 s)) :
    RecognizableAt Sig A s L ↔ Recognizable Sig A (deltaSub s L) := by
  constructor
  · rintro ⟨B, hB, f, hf, M, hM⟩
    refine ⟨B, hB, f, hf, deltaSub s M, ?_⟩
    funext t
    by_cases ht : t = s
    · subst ht
      simpa [deltaSub, inverseImage] using hM
    · simp [deltaSub, inverseImage, ht]
  · rintro ⟨B, hB, f, hf, M, hM⟩
    refine ⟨B, hB, f, hf, M s, ?_⟩
    have := congrFun hM s
    simpa [deltaSub, inverseImage] using this

/-! ### Boolean closure -/

/-- Recognizable languages are closed under binary union. -/
theorem recognizable_union (Sig : Signature S) (A : Alg Sig) {K L : Sub A.1}
    (hK : Recognizable Sig A K) (hL : Recognizable Sig A L) :
    Recognizable Sig A (Sub_union K L) := by
  rw [recognizable_iff_isRegularLanguage] at hK hL ⊢
  unfold IsRegularLanguage at hK hL ⊢
  have hcK := congCogenerated_isCongruence Sig A K
  have hcL := congCogenerated_isCongruence Sig A L
  have hcong : IsCongruence Sig A.2
      (sortedEqvInf (congCogenerated Sig A K) (congCogenerated Sig A L)) :=
    IsCongruence_inf Sig A.2 hcK hcL
  have hsatK : IsSat (sortedEqvInf (congCogenerated Sig A K) (congCogenerated Sig A L)) K :=
    sat_antitone (sortedEqvInf_le_left _ _) (isSat_congCogenerated Sig A K)
  have hsatL : IsSat (sortedEqvInf (congCogenerated Sig A K) (congCogenerated Sig A L)) L :=
    sat_antitone (sortedEqvInf_le_right _ _) (isSat_congCogenerated Sig A L)
  have hsat : IsSat (sortedEqvInf (congCogenerated Sig A K) (congCogenerated Sig A L))
      (Sub_union K L) := isSat_union hsatK hsatL
  have hle : sortedEqvLe (sortedEqvInf (congCogenerated Sig A K) (congCogenerated Sig A L))
      (congCogenerated Sig A (Sub_union K L)) :=
    (isSat_iff_le_congCogenerated Sig A (Sub_union K L) hcong).mp hsat
  exact IsFiniteIndex_of_le hle (IsFiniteIndex_inf hK hL)

/-- Recognizable languages are closed under binary intersection. -/
theorem recognizable_inter (Sig : Signature S) (A : Alg Sig) {K L : Sub A.1}
    (hK : Recognizable Sig A K) (hL : Recognizable Sig A L) :
    Recognizable Sig A (Sub_inter K L) := by
  rw [recognizable_iff_isRegularLanguage] at hK hL ⊢
  unfold IsRegularLanguage at hK hL ⊢
  have hcK := congCogenerated_isCongruence Sig A K
  have hcL := congCogenerated_isCongruence Sig A L
  have hcong : IsCongruence Sig A.2
      (sortedEqvInf (congCogenerated Sig A K) (congCogenerated Sig A L)) :=
    IsCongruence_inf Sig A.2 hcK hcL
  have hsatK : IsSat (sortedEqvInf (congCogenerated Sig A K) (congCogenerated Sig A L)) K :=
    sat_antitone (sortedEqvInf_le_left _ _) (isSat_congCogenerated Sig A K)
  have hsatL : IsSat (sortedEqvInf (congCogenerated Sig A K) (congCogenerated Sig A L)) L :=
    sat_antitone (sortedEqvInf_le_right _ _) (isSat_congCogenerated Sig A L)
  have hsat : IsSat (sortedEqvInf (congCogenerated Sig A K) (congCogenerated Sig A L))
      (Sub_inter K L) := isSat_inter hsatK hsatL
  have hle : sortedEqvLe (sortedEqvInf (congCogenerated Sig A K) (congCogenerated Sig A L))
      (congCogenerated Sig A (Sub_inter K L)) :=
    (isSat_iff_le_congCogenerated Sig A (Sub_inter K L) hcong).mp hsat
  exact IsFiniteIndex_of_le hle (IsFiniteIndex_inf hK hL)

/-- Recognizable languages are closed under relative complement. -/
theorem recognizable_compl (Sig : Signature S) (A : Alg Sig) {L : Sub A.1}
    (hL : Recognizable Sig A L) : Recognizable Sig A (complA L) := by
  rw [recognizable_iff_isRegularLanguage] at hL ⊢
  unfold IsRegularLanguage at hL ⊢
  rw [← congCogenerated_compl Sig A L]
  exact hL

/-! ### The Boolean bounds `∅^S, A ∈ Rec(A)` (`Rec is Bool`(1))

The paper states these without a hypothesis, but a finite recognizing algebra
`B` forces `supp(A) ⊆ supp(B)`, so finite support of `A` is exactly the
precondition (an algebra with infinite support has no finite quotient of the
whole carrier). We therefore carry the hypothesis `(supp A).Finite`. -/

/-- `∅^S ∈ Rec(A)` when `A` has finite support. -/
theorem recognizable_empty (Sig : Signature S) (A : Alg Sig)
    (h : (supp A.1).Finite) :
    Recognizable Sig A (fun s => (∅ : Set (A.1 s))) := by
  have hc : IsCongruence Sig A.2 (nabla A.1) := nabla_isCongruence Sig A.2
  refine ⟨quotAlg Sig A.2 (nabla A.1) hc, ?_,
    prAlg Sig A.2 (nabla A.1) hc, isAlgHom_prAlg Sig A.2 (nabla A.1) hc,
    (fun _ => (∅ : Set _)), ?_⟩
  · simpa [FiniteAlg, quotAlg, IsFiniteIndex] using isFiniteIndex_nabla A.1 h
  · funext s
    simp [inverseImage]

/-- `A ∈ Rec(A)` when `A` has finite support. -/
theorem recognizable_univ (Sig : Signature S) (A : Alg Sig)
    (h : (supp A.1).Finite) :
    Recognizable Sig A (fun s => (Set.univ : Set (A.1 s))) := by
  have hc : IsCongruence Sig A.2 (nabla A.1) := nabla_isCongruence Sig A.2
  refine ⟨quotAlg Sig A.2 (nabla A.1) hc, ?_,
    prAlg Sig A.2 (nabla A.1) hc, isAlgHom_prAlg Sig A.2 (nabla A.1) hc,
    (fun _ => (Set.univ : Set _)), ?_⟩
  · simpa [FiniteAlg, quotAlg, IsFiniteIndex] using isFiniteIndex_nabla A.1 h
  · funext s
    simp [inverseImage]

/-- `∅ ⊆ A_s` is `s`-recognizable when `A` has finite support. -/
theorem recognizableAt_empty (Sig : Signature S) (A : Alg Sig) (s : S)
    (h : (supp A.1).Finite) :
    RecognizableAt Sig A s (∅ : Set (A.1 s)) := by
  rw [recognizableAt_iff, deltaSub_empty]
  exact recognizable_empty Sig A h

/-- `A_s` is `s`-recognizable when `A` has finite support. -/
theorem recognizableAt_univ (Sig : Signature S) (A : Alg Sig) (s : S)
    (h : (supp A.1).Finite) :
    RecognizableAt Sig A s (Set.univ : Set (A.1 s)) := by
  have hc : IsCongruence Sig A.2 (nabla A.1) := nabla_isCongruence Sig A.2
  refine ⟨quotAlg Sig A.2 (nabla A.1) hc, ?_,
    prAlg Sig A.2 (nabla A.1) hc, isAlgHom_prAlg Sig A.2 (nabla A.1) hc,
    (Set.univ : Set ((quotAlg Sig A.2 (nabla A.1) hc).1 s)), ?_⟩
  · simpa [FiniteAlg, quotAlg, IsFiniteIndex] using isFiniteIndex_nabla A.1 h
  · simp

/-- Recognizable languages are closed under translation preimages. -/
theorem recognizable_transPreimage (Sig : Signature S) (A : Alg Sig) {t s : S}
    {T : A.1 t → A.1 s} (hT : TlGen Sig A t s T) {L : Sub A.1}
    (hL : Recognizable Sig A L) : Recognizable Sig A (transPreimage T L) := by
  rw [recognizable_iff_isRegularLanguage] at hL ⊢
  exact IsFiniteIndex_of_le (congCogenerated_le_transPreimage Sig A hT L) hL

/-- Recognizable languages are closed under inverse images along homomorphisms. -/
theorem recognizable_inverseImage (Sig : Signature S) (A B : Alg Sig)
    {f : SortedMap A.1 B.1} (hf : IsAlgHom Sig A.2 B.2 f) {M : Sub B.1}
    (hM : Recognizable Sig B M) : Recognizable Sig A (inverseImage f M) := by
  rw [recognizable_iff_isRegularLanguage] at hM ⊢
  exact IsFiniteIndex_of_le (pullbackEqv_congCogenerated_le Sig hf M)
    (isFiniteIndex_pullback f (congCogenerated Sig B M) hM)

end Mscong
