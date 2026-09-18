import Mslang.Formation
import Mslang.Translation

/-!
The finite-index / regular-language layer underlying the second Eilenberg theorem:
congruences of finite index (`B-D040`), formations of finite-index congruences
(`B-D041`), finite `Σ`-algebras and their formations (`B-D042`, `B-D043`), and
regular languages (`B-D044`).
-/

universe u

-- `haveI` installs the `Finite`/`Fintype` instances the proofs consume; the
-- style linter's `have` suggestion would not register them.
set_option linter.style.haveILetI false

namespace Mslang

variable {S : Type u}

/-! ### `B-D040`: congruences of finite index. -/

/-- `B-D040`: a congruence `Φ` on a `Σ`-algebra `A` is of *finite index* when the
quotient `S`-sorted set `A/Φ` is finite. -/
def IsFiniteIndex {S : Type u} {A : SSet S} (Φ : SortedEqv A) : Prop :=
  FiniteSSet (quot Φ)

/-- `B-D040`: `Cgr_fi(A)`, the set of congruences on `A` of finite index. -/
def congFi {S : Type u} (Sig : Signature S) {A : SSet S} (F : AlgStruct Sig A) :
    Set (SortedEqv A) :=
  {Φ | IsCongruence Sig F Φ ∧ IsFiniteIndex Φ}

/-! ### `B-D042`/`B-D043`: finite `Σ`-algebras and their formations. -/

/-- `B-D042`: `Alg_f(Σ)`, the set of all finite `Σ`-algebras. -/
def algebraFinite {S : Type u} (Sig : Signature S) : Set (Alg Sig) :=
  {A | FiniteAlg A}

/-- `B-D043`: a formation of finite `Σ`-algebras: a formation of `Σ`-algebras
contained in `Alg_f(Σ)`. -/
def IsFiniteAlgebraFormation {S : Type u} (Sig : Signature S) (F : Set (Alg Sig)) : Prop :=
  IsAlgebraFormation Sig F ∧ F ⊆ algebraFinite Sig

/-- `B-D043`: `Form_Alg_f(Σ)`, the set of formations of finite `Σ`-algebras. -/
def finiteAlgebraFormations {S : Type u} (Sig : Signature S) : Set (Set (Alg Sig)) :=
  {F | IsFiniteAlgebraFormation Sig F}

/-! ### `B-D041`: formations of finite-index congruences. -/

/-- `B-D041`: a formation of finite-index congruences with respect to `Σ`: a
congruence formation `G` with `G(A) ⊆ Cgr_fi(T_Σ(A))` for every `A`. -/
def IsFiniteIndexCongruenceFormation {S : Type u} (Sig : Signature S)
    (G : (A : SSet S) → Set (SortedEqv (Term Sig A))) : Prop :=
  IsCongruenceFormation Sig G ∧ ∀ A, G A ⊆ congFi Sig (termAlg Sig A).2

/-- `B-D041`: `Form_Cgr_fi(Σ)`, the set of formations of finite-index
congruences. -/
def finiteIndexCongruenceFormations {S : Type u} (Sig : Signature S) :
    Set ((A : SSet S) → Set (SortedEqv (Term Sig A))) :=
  {G | IsFiniteIndexCongruenceFormation Sig G}

/-! ### `B-D044`: regular languages. -/

/-- `B-D044`: `L ⊆ A` is a *regular language* over a `Σ`-algebra `A` when the
cogenerated congruence `Ω^A(L)` has finite index (`Ω^A(L) ∈ Cgr_fi(A)`). -/
def IsRegularLanguage {S : Type u} (Sig : Signature S) (A : Alg Sig) (L : Sub A.1) : Prop :=
  IsFiniteIndex (congCogenerated Sig A L)

/-- `B-D044`: `Lang_r(A)`, the set of regular languages over `A`. -/
def regularLanguages {S : Type u} (Sig : Signature S) (A : Alg Sig) : Set (Sub A.1) :=
  {L | IsRegularLanguage Sig A L}

/-! ### `B-P031`: `Cgr_fi(A)` is a filter. -/

/-- The canonical map `A/Φ → A/Ψ` on quotients when `Φ ⊆ Ψ`. -/
def quotLe {S : Type u} {A : SSet S} (Φ Ψ : SortedEqv A) (h : sortedEqvLe Φ Ψ) :
    SortedMap (quot Φ) (quot Ψ) :=
  fun s => Quotient.lift (fun a => Quotient.mk (Ψ s) a)
    (fun a b hab => Quotient.sound (h s a b hab))

theorem quotLe_mk {S : Type u} {A : SSet S} (Φ Ψ : SortedEqv A)
    (h : sortedEqvLe Φ Ψ) (s : S) (a : A s) :
    quotLe Φ Ψ h s (Quotient.mk (Φ s) a) = Quotient.mk (Ψ s) a := rfl

/-- `∇` has finite index when `supp(A)` is finite (`A/∇ ≃ supp(A)`). -/
theorem isFiniteIndex_nabla {S : Type u} (A : SSet S) (h : (supp A).Finite) :
    IsFiniteIndex (nabla A) := by
  unfold IsFiniteIndex FiniteSSet
  haveI : Fintype ↥(supp A) := h.fintype
  apply Finite.of_surjective
    (f := fun p : ↥(supp A) =>
      (⟨p.1, Quotient.mk (nabla A p.1) (Classical.choice p.2)⟩ :
        Sigma (fun s => Quotient (nabla A s))))
  rintro ⟨s, q⟩
  induction q using Quotient.inductionOn with
  | _ a =>
    refine ⟨⟨s, ⟨a⟩⟩, ?_⟩
    exact Sigma.mk.inj_iff.mpr ⟨rfl, heq_of_eq (Quotient.sound trivial)⟩

/-- `IsFiniteIndex` is up-closed under refinement. -/
theorem IsFiniteIndex_of_le {S : Type u} {A : SSet S} {Φ Ψ : SortedEqv A}
    (h : sortedEqvLe Φ Ψ) (hΦ : IsFiniteIndex Φ) : IsFiniteIndex Ψ := by
  unfold IsFiniteIndex FiniteSSet at hΦ ⊢
  haveI : Finite (Sigma (fun s => Quotient (Φ s))) := hΦ
  apply Finite.of_surjective
    (f := fun p : Sigma (fun s => Quotient (Φ s)) =>
      (⟨p.1, quotLe Φ Ψ h p.1 p.2⟩ : Sigma (fun s => Quotient (Ψ s))))
  rintro ⟨s, q⟩
  induction q using Quotient.inductionOn with
  | _ b =>
    refine ⟨⟨s, Quotient.mk (Φ s) b⟩, ?_⟩
    exact Sigma.mk.inj_iff.mpr ⟨rfl, heq_of_eq (quotLe_mk Φ Ψ h s b)⟩

/-- `IsFiniteIndex` is closed under pointwise meet. -/
theorem IsFiniteIndex_inf {S : Type u} {A : SSet S} {Φ Ψ : SortedEqv A}
    (hΦ : IsFiniteIndex Φ) (hΨ : IsFiniteIndex Ψ) :
    IsFiniteIndex (sortedEqvInf Φ Ψ) := by
  unfold IsFiniteIndex FiniteSSet at hΦ hΨ ⊢
  haveI : Finite (Sigma (fun s => Quotient (Φ s))) := hΦ
  haveI : Finite (Sigma (fun s => Quotient (Ψ s))) := hΨ
  apply Finite.of_injective
    (f := fun p : Sigma (fun s => Quotient ((sortedEqvInf Φ Ψ) s)) =>
      ((⟨p.1, quotLe (sortedEqvInf Φ Ψ) Φ (sortedEqvInf_le_left Φ Ψ) p.1 p.2⟩ :
          Sigma (fun s => Quotient (Φ s))),
       (⟨p.1, quotLe (sortedEqvInf Φ Ψ) Ψ (sortedEqvInf_le_right Φ Ψ) p.1 p.2⟩ :
          Sigma (fun s => Quotient (Ψ s)))))
  rintro ⟨s, q⟩ ⟨t, r⟩ h
  have h1 := congrArg Prod.fst h
  have h2 := congrArg Prod.snd h
  have hst : s = t := (Sigma.mk.inj_iff.mp h1).1
  subst hst
  have hq : quotLe (sortedEqvInf Φ Ψ) Φ (sortedEqvInf_le_left Φ Ψ) s q =
      quotLe (sortedEqvInf Φ Ψ) Φ (sortedEqvInf_le_left Φ Ψ) s r :=
    eq_of_heq (Sigma.mk.inj_iff.mp h1).2
  have hr : quotLe (sortedEqvInf Φ Ψ) Ψ (sortedEqvInf_le_right Φ Ψ) s q =
      quotLe (sortedEqvInf Φ Ψ) Ψ (sortedEqvInf_le_right Φ Ψ) s r :=
    eq_of_heq (Sigma.mk.inj_iff.mp h2).2
  induction q using Quotient.inductionOn with
  | _ a =>
    induction r using Quotient.inductionOn with
    | _ b =>
      have habΦ : (Φ s).r a b := by
        have := hq
        simp only [quotLe] at this
        exact Quotient.exact this
      have habΨ : (Ψ s).r a b := by
        have := hr
        simp only [quotLe] at this
        exact Quotient.exact this
      exact Sigma.mk.inj_iff.mpr ⟨rfl, heq_of_eq (Quotient.sound ⟨habΦ, habΨ⟩)⟩

/-- `B-P031`: if `supp_S(A)` is finite, then `Cgr_fi(A)` is a filter: it is
non-empty (`∇`), closed under pointwise meet, and up-closed under refinement
among congruences. -/
theorem congFi_filter {S : Type u} (Sig : Signature S) {A : SSet S} (F : AlgStruct Sig A)
    (hfin : (supp A).Finite) :
    (congFi Sig F).Nonempty ∧
      (∀ Φ ∈ congFi Sig F, ∀ Ψ ∈ congFi Sig F, sortedEqvInf Φ Ψ ∈ congFi Sig F) ∧
      (∀ Φ ∈ congFi Sig F, ∀ Ψ : SortedEqv A,
        IsCongruence Sig F Ψ → sortedEqvLe Φ Ψ → Ψ ∈ congFi Sig F) := by
  refine ⟨?_, ?_, ?_⟩
  · exact ⟨nabla A, nabla_isCongruence Sig F, isFiniteIndex_nabla A hfin⟩
  · rintro Φ ⟨hΦc, hΦf⟩ Ψ ⟨hΨc, hΨf⟩
    exact ⟨IsCongruence_inf Sig F hΦc hΨc, IsFiniteIndex_inf hΦf hΨf⟩
  · rintro Φ ⟨_, hΦf⟩ Ψ hΨc hle
    exact ⟨hΨc, IsFiniteIndex_of_le hle hΦf⟩

end Mslang
