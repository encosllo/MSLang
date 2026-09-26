import Mscong.Substitution

/-!
# `Mscong.Quotient` -- the `z`-quotient and `PRecQ` (`MSCong` §3.4)

Milestone **M3** of the MSCong project (OpenSpec change
`add-substitution-recognizability`): the single-variable substitution
endomorphism, the `z`-quotient `K^{-z}L` of a language by another, and the
recognizability result `PRecQ`.

The paper defines `K^{-z}L = {U | (z\K)^♯_s(U) ∩ L ≠ ∅}` and refines the
syntactic congruence `Ω(δ^{s,L})` by agreement on the finitely many
`K^{-z}[W]`. We instead use the equivalent decomposition

`K^{-z}L = ⋃_{V ∈ K} (subst1 z V)⁻¹[L]`,

which is a **finite** union: by the syntactic congruence of `L` (of finite
index, saturating `L`), the preimage `(subst1 z V)⁻¹[L]` depends only on the
`Ω(δ^{s,L})`-class of `V`. Each term is recognizable as the inverse image of a
recognizable language under a `Σ`-endomorphism, and recognizable languages are
closed under finite unions. This proves the paper's statement, and the
finiteness of the family of `z`-quotients falls out of the same argument.

This is **unmapped infrastructure**: no block IDs, no evidence; `mscong` stays
`ingested = false` (see `design.md`, D5).
-/

namespace Mscong

open Mslang

set_option linter.style.haveILetI false

universe u

variable {S : Type u}

/-! ### Single-variable substitution as a `Σ`-endomorphism -/

/-- `X`-substitution `P ↦ P[z := V]` is a `Σ`-homomorphism of the free algebra
`T_Σ(X)` (it is the free extension of the variable assignment fixing every
variable but `z`, which is sent to `V`). -/
theorem subst1_isAlgHom (Sig : Signature S) (X : SSet S) {t : S} (z : X t)
    (V : Term Sig X t) :
    IsAlgHom Sig (termAlg Sig X).2 (termAlg Sig X).2 (fun r => subst1 Sig X z V r) :=
  fun p σ a => subst1_op Sig X z V p σ a

/-- A congruence is preserved by the substitution endomorphism: if `V` and `V'`
are `Φ`-related then so are `P[z:=V]` and `P[z:=V']`, for every `P`. Proved by
structural induction on `P` (only the variable case uses `hVV'`; the operation
case is the congruence property). -/
theorem subst1_congr (Sig : Signature S) (X : SSet S) {t : S} (z : X t)
    {Φ : SortedEqv (Term Sig X)} (hΦc : IsCongruence Sig (termAlg Sig X).2 Φ)
    {V V' : Term Sig X t} (hVV' : (Φ t).r V V') :
    ∀ (r : S) (U : Term Sig X r),
      (Φ r).r (subst1 Sig X z V r U) (subst1 Sig X z V' r U) := by
  intro r U
  induction U using Term.rec with
  | var y =>
      rename_i u
      by_cases hu : u = t
      · subst hu
        by_cases hy : y = z
        · subst hy
          simpa only [subst1_var_self] using hVV'
        · rw [subst1_var_of_ne Sig X V y hy, subst1_var_of_ne Sig X V' y hy]
      · rw [subst1_var_of_ne_sort Sig X V y hu, subst1_var_of_ne_sort Sig X V' y hu]
  | op p σ b ih =>
      rw [subst1_op Sig X z V p σ b, subst1_op Sig X z V' p σ b]
      exact hΦc p σ _ _ ih

/-- Convergence of the substitution image for `Φ`-related substituted terms,
against a `Φ`-saturated language: `P[z:=V] ∈ L ↔ P[z:=V'] ∈ L` when
`V Φ V'` and `L` is saturated. -/
theorem subst1_mem_iff_of_rel (Sig : Signature S) (X : SSet S) {t s : S} (z : X t)
    {L : Set (Term Sig X s)} {Φ : SortedEqv (Term Sig X)}
    (hΦc : IsCongruence Sig (termAlg Sig X).2 Φ)
    (hLsat : IsSat Φ (deltaSub s L))
    {V V' : Term Sig X t} (hVV' : (Φ t).r V V') (U : Term Sig X s) :
    subst1 Sig X z V s U ∈ L ↔ subst1 Sig X z V' s U ∈ L := by
  have hrel := subst1_congr Sig X z hΦc hVV' s U
  have hmem : ∀ {A B : Term Sig X s}, A ∈ L → (Φ s).r A B → B ∈ L := by
    intro A B hA hAB
    have hA' : A ∈ (deltaSub s L) s := by rwa [deltaSub_self]
    have hB' : B ∈ (deltaSub s L) s := isSat_mem hLsat hA' hAB
    rwa [deltaSub_self] at hB'
  constructor
  · intro h; exact hmem h hrel
  · intro h; exact hmem h ((Φ s).symm hrel)

/-! ### The `z`-quotient `K^{-z}L` -/

/-- `MSCong` §3.4: the `z`-quotient `K^{-z}L = {U | (z\K)^♯_s(U) ∩ L ≠ ∅}`, i.e.
the terms `U` from which substituting some `V ∈ K` for `z` lands in `L`. -/
noncomputable def quotLang (Sig : Signature S) (X : SSet S) {t s : S} (z : X t)
    (K : Set (Term Sig X t)) (L : Set (Term Sig X s)) : Set (Term Sig X s) :=
  {U | ∃ V ∈ K, subst1 Sig X z V s U ∈ L}

/-- The membership restatement of `quotLang`. -/
theorem mem_quotLang {Sig : Signature S} {X : SSet S} {t s : S} {z : X t}
    {K : Set (Term Sig X t)} {L : Set (Term Sig X s)} {U : Term Sig X s} :
    U ∈ quotLang Sig X z K L ↔ ∃ V ∈ K, subst1 Sig X z V s U ∈ L :=
  Iff.rfl

/-! ### Recognizability of finite unions (needed for `PRecQ`) -/

/-- The empty language of the free algebra is recognizable (recognize through the
constant homomorphism to the finite two-element algebra `2^S`). -/
theorem recognizable_empty_term (Sig : Signature S) (X : SSet S) [Finite S] :
    Recognizable Sig (termAlg Sig X) (fun _ => (∅ : Set _)) := by
  refine ⟨twoAlg Sig, finiteAlg_twoAlg Sig, (fun _ _ => Two.z), ?_,
    (fun _ => (∅ : Set Two)), ?_⟩
  · intro p σ a; rfl
  · funext s; rfl

/-- Recognizable languages of the free algebra are closed under finite unions. -/
theorem recognizable_finset_iUnion {ι : Type u} [DecidableEq ι]
    (Sig : Signature S) (X : SSet S) [Finite S] (T : Finset ι)
    (F : ι → Sub (Term Sig X))
    (hF : ∀ i, Recognizable Sig (termAlg Sig X) (F i)) :
    Recognizable Sig (termAlg Sig X) (fun s => ⋃ i ∈ (T : Set ι), F i s) := by
  induction T using Finset.induction_on with
  | empty =>
      have h : (fun s => ⋃ i ∈ ((∅ : Finset ι) : Set ι), F i s)
          = fun _ => (∅ : Set _) := by
        funext s x
        simp
      rw [h]
      exact recognizable_empty_term Sig X
  | insert a T ha ih =>
      have h : (fun s => ⋃ i ∈ ((insert a T : Finset ι) : Set ι), F i s)
          = Sub_union (F a) (fun s => ⋃ i ∈ (T : Set ι), F i s) := by
        funext s
        ext x
        simp only [Sub_union, Set.mem_union, Set.mem_iUnion, Finset.coe_insert,
          Set.mem_insert_iff]
        constructor
        · rintro ⟨i, (rfl | hi), hx⟩
          · exact Or.inl hx
          · exact Or.inr ⟨i, hi, hx⟩
        · rintro (hx | ⟨i, hi, hx⟩)
          · exact ⟨a, Or.inl rfl, hx⟩
          · exact ⟨i, Or.inr hi, hx⟩
      rw [h]
      exact recognizable_union Sig (termAlg Sig X) (hF a) ih

/-! ### `PRecQ` (`MSCong` §3.4) -/

/-- `PRecQ` (`MSCong` Prop. `PRecQ`): if `L ⊆ T_Σ(X)_s` is `s`-recognizable then
for every `z ∈ X_t` and every `K ⊆ T_Σ(X)_t` the `z`-quotient `K^{-z}L` is
`s`-recognizable. The proof decomposes `K^{-z}L` into the finite union of the
preimages `(subst1 z V)⁻¹[L]` over the `Ω(δ^{s,L})`-classes met by `K`. -/
theorem PRecQ (Sig : Signature S) (X : SSet S) [Finite S]
    (s : S) {t : S} (z : X t) (K : Set (Term Sig X t)) (L : Set (Term Sig X s))
    (hL : RecognizableAt Sig (termAlg Sig X) s L) :
    RecognizableAt Sig (termAlg Sig X) s (quotLang Sig X z K L) := by
  classical
  rw [recognizableAt_iff] at hL ⊢
  let Φ : SortedEqv (Term Sig X) :=
    congCogenerated Sig (termAlg Sig X) (deltaSub s L)
  have hΦc : IsCongruence Sig (termAlg Sig X).2 Φ :=
    congCogenerated_isCongruence Sig (termAlg Sig X) (deltaSub s L)
  have hΦf : IsFiniteIndex Φ :=
    (recognizable_iff_isRegularLanguage Sig (termAlg Sig X) (deltaSub s L)).mp hL
  have hsat : IsSat Φ (deltaSub s L) :=
    isSat_congCogenerated Sig (termAlg Sig X) (deltaSub s L)
  obtain ⟨_hsupp, hfib⟩ := (finiteSSet_iff (quot Φ)).mp hΦf
  haveI : Finite (Quotient (Φ t)) := by
    by_cases ht : Nonempty (Quotient (Φ t))
    · obtain ⟨q⟩ := ht
      exact hfib t ⟨q⟩
    · haveI : IsEmpty (Quotient (Φ t)) := ⟨fun q => ht ⟨q⟩⟩
      exact Finite.of_injective (fun q : Quotient (Φ t) => (isEmptyElim q : PEmpty))
        (fun a => isEmptyElim a)
  haveI : Fintype (Quotient (Φ t)) := Fintype.ofFinite _
  let C : Finset (Quotient (Φ t)) :=
    Finset.univ.filter (fun q => ∃ V : Term Sig X t, Quotient.mk (Φ t) V = q ∧ V ∈ K)
  have hset : quotLang Sig X z K L
      = ⋃ q ∈ (C : Set (Quotient (Φ t))),
          (subst1 Sig X z (Quotient.out q) s) ⁻¹' L := by
    ext U
    simp only [Set.mem_iUnion]
    constructor
    · rintro ⟨V, hVK, hVL⟩
      refine ⟨Quotient.mk (Φ t) V, ?_, ?_⟩
      · rw [Finset.mem_coe]
        simp only [C, Finset.mem_filter, Finset.mem_univ, true_and]
        exact ⟨V, rfl, hVK⟩
      · have hout : (Φ t).r (Quotient.out (Quotient.mk (Φ t) V)) V :=
          Quotient.exact (Quotient.out_eq (Quotient.mk (Φ t) V))
        exact (subst1_mem_iff_of_rel Sig X z hΦc hsat hout U).mpr hVL
    · rintro ⟨q, hqC, hqUL⟩
      rw [Finset.mem_coe] at hqC
      simp only [C, Finset.mem_filter, Finset.mem_univ, true_and] at hqC
      obtain ⟨V, hVq, hVK⟩ := hqC
      have hout : (Φ t).r V (Quotient.out q) := by
        apply Quotient.exact
        rw [Quotient.out_eq, hVq]
      exact ⟨V, hVK, (subst1_mem_iff_of_rel Sig X z hΦc hsat hout U).mpr hqUL⟩
  have hsub_eq : deltaSub s (quotLang Sig X z K L)
      = fun r => ⋃ q ∈ (C : Set (Quotient (Φ t))),
          inverseImage (fun r' => subst1 Sig X z (Quotient.out q) r') (deltaSub s L) r := by
    funext r
    by_cases hr : r = s
    · subst hr
      rw [deltaSub_self, hset]
      simp only [inverseImage, deltaSub_self]
    · rw [deltaSub_of_ne hr]
      have hempty : ∀ q : Quotient (Φ t),
          inverseImage (fun r' => subst1 Sig X z (Quotient.out q) r')
            (deltaSub s L) r = (∅ : Set (Term Sig X r)) := by
        intro q
        unfold inverseImage
        rw [deltaSub_of_ne hr]
        simp
      simp only [hempty]
      ext x
      simp
  rw [hsub_eq]
  refine recognizable_finset_iUnion Sig X C
    (fun q => inverseImage (fun r' => subst1 Sig X z (Quotient.out q) r')
      (deltaSub s L)) ?_
  intro q
  exact recognizable_inverseImage Sig (termAlg Sig X) (termAlg Sig X)
    (subst1_isAlgHom Sig X z (Quotient.out q)) hL

/-- The "moreover" clause of `MSCong` Prop. `PRecQ`: for a fixed recognizable
`L`, there are only finitely many `z`-quotients `K^{-z}L`. The proof is the one
behind `PRecQ`: `K^{-z}L` depends on `K` only through the finite set of
`Ω(δ^{s,L})`-classes that `K` meets, so the family factors through the finite
powerset `Set (T_Σ(X)_t/Ω(δ^{s,L}))`. -/
theorem quotLang_range_finite (Sig : Signature S) (X : SSet S) [Finite S]
    (s : S) {t : S} (z : X t) (L : Set (Term Sig X s))
    (hL : RecognizableAt Sig (termAlg Sig X) s L) :
    (Set.range (fun K : Set (Term Sig X t) => quotLang Sig X z K L)).Finite := by
  classical
  let Φ : SortedEqv (Term Sig X) :=
    congCogenerated Sig (termAlg Sig X) (deltaSub s L)
  have hΦc : IsCongruence Sig (termAlg Sig X).2 Φ :=
    congCogenerated_isCongruence Sig (termAlg Sig X) (deltaSub s L)
  have hsat : IsSat Φ (deltaSub s L) :=
    isSat_congCogenerated Sig (termAlg Sig X) (deltaSub s L)
  have hΦf : IsFiniteIndex Φ :=
    (recognizable_iff_isRegularLanguage Sig (termAlg Sig X) (deltaSub s L)).mp
      ((recognizableAt_iff Sig (termAlg Sig X) s L).mp hL)
  obtain ⟨_, hfib⟩ := (finiteSSet_iff (quot Φ)).mp hΦf
  haveI : Finite (Quotient (Φ t)) := by
    by_cases ht : Nonempty (Quotient (Φ t))
    · obtain ⟨q⟩ := ht
      exact hfib t ⟨q⟩
    · haveI : IsEmpty (Quotient (Φ t)) := ⟨fun q => ht ⟨q⟩⟩
      exact Finite.of_injective (fun q : Quotient (Φ t) => (isEmptyElim q : PEmpty))
        (fun a => isEmptyElim a)
  let U : Set (Quotient (Φ t)) → Set (Term Sig X s) :=
    fun Q => ⋃ q ∈ Q, (subst1 Sig X z (Quotient.out q) s) ⁻¹' L
  have hfact : ∀ K : Set (Term Sig X t),
      quotLang Sig X z K L = U (Quotient.mk (Φ t) '' K) := by
    intro K
    ext W
    rw [mem_quotLang]
    simp only [U, Set.mem_iUnion, Set.mem_image]
    constructor
    · rintro ⟨V, hVK, hVL⟩
      exact ⟨Quotient.mk (Φ t) V, ⟨V, hVK, rfl⟩,
        (subst1_mem_iff_of_rel Sig X z hΦc hsat
          (Quotient.exact (Quotient.out_eq (Quotient.mk (Φ t) V))) W).mpr hVL⟩
    · rintro ⟨q, ⟨V, hVK, rfl⟩, hqL⟩
      exact ⟨V, hVK, (subst1_mem_iff_of_rel Sig X z hΦc hsat
        (Quotient.exact (Quotient.out_eq (Quotient.mk (Φ t) V))) W).mp hqL⟩
  refine (Set.finite_range U).subset ?_
  rintro _ ⟨K, rfl⟩
  exact ⟨Quotient.mk (Φ t) '' K, (hfact K).symm⟩

end Mscong
