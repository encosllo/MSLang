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

/-! ### `B-P034`: `Form_Alg_f(Σ) ≅ Form_Cgr_fi(Σ)`. -/

/-- Finiteness of an `S`-sorted set is invariant under a sortwise bijection. -/
theorem finiteSSet_of_isAlgIso {S : Type u} (Sig : Signature S) {A B : SSet S}
    {FA : AlgStruct Sig A} {FB : AlgStruct Sig B} {f : SortedMap A B}
    (hf : IsAlgIso Sig FA FB f) (hA : FiniteSSet A) : FiniteSSet B := by
  unfold FiniteSSet at hA ⊢
  haveI := hA
  apply Finite.of_surjective (fun p : Sigma A => (⟨p.1, f p.1 p.2⟩ : Sigma B))
  rintro ⟨s, b⟩
  obtain ⟨a, ha⟩ := (hf.2 s).2 b
  exact ⟨⟨s, a⟩, Sigma.mk.inj_iff.mpr ⟨rfl, heq_of_eq ha⟩⟩

/-- `B-P034`: if `F ⊆ Alg_f(Σ)`, then every `Φ ∈ 𝔉_F(A)` has finite index, because
`T_Σ(A)/Φ ∈ F` is finite. -/
theorem congruenceFormationOf_isFiniteIndex {S : Type u} (Sig : Signature S)
    {F : Set (Alg Sig)} (hF : F ⊆ algebraFinite Sig) :
    ∀ A, congruenceFormationOf Sig F A ⊆ congFi Sig (termAlg Sig A).2 := by
  rintro A Φ ⟨hΦ, hΦF⟩
  exact ⟨hΦ, hF hΦF⟩

/-- `B-P034`: if every `G(A) ⊆ Cgr_fi(T_Σ(A))`, then `F_𝔉 ⊆ Alg_f(Σ)`, because a
quotient by a finite-index congruence is finite and finiteness is isomorphism-
invariant. -/
theorem algebraFormationOfCongruenceFormation_isFiniteAlgebra {S : Type u}
    (Sig : Signature S) {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hfi : ∀ A, G A ⊆ congFi Sig (termAlg Sig A).2) :
    algebraFormationOfCongruenceFormation Sig G ⊆ algebraFinite Sig := by
  rintro C ⟨A, Φ, hΦ, hΦG, g, hg⟩
  exact finiteSSet_of_isAlgIso Sig
    (isAlgIso_symm Sig C.2 (quotAlg Sig (termAlg Sig A).2 Φ hΦ).2 hg) (hfi A hΦG).2

/-- `B-P034`: the bi-restriction of `θ_Σ` (`B-P020`) to formations of finite
algebras and formations of finite-index congruences: the two are isomorphic
(the first half of the second Eilenberg theorem). -/
def formAlgFFormCgrFiIso {S : Type u} (Sig : Signature S) :
    finiteAlgebraFormations Sig ≃o finiteIndexCongruenceFormations Sig where
  toFun := fun F => ⟨congruenceFormationOf Sig F.1,
    congruenceFormation_isCongruenceFormation Sig F.2.1,
    congruenceFormationOf_isFiniteIndex Sig F.2.2⟩
  invFun := fun G => ⟨algebraFormationOfCongruenceFormation Sig G.1,
    algebraFormationOfCongruenceFormation_isAlgebraFormation Sig G.2.1,
    algebraFormationOfCongruenceFormation_isFiniteAlgebra Sig G.2.2⟩
  left_inv := fun F => Subtype.ext
    (algebraFormationOfCongruenceFormation_congruenceFormationOf Sig F.2.1)
  right_inv := fun G => Subtype.ext
    (congruenceFormationOf_algebraFormationOfCongruenceFormation Sig G.2.1)
  map_rel_iff' := by
    intro F F'
    constructor
    · intro h
      have h' : ∀ A, congruenceFormationOf Sig F.1 A ⊆ congruenceFormationOf Sig F'.1 A := h
      have h1 := algebraFormationOfCongruenceFormation_mono Sig h'
      rw [algebraFormationOfCongruenceFormation_congruenceFormationOf Sig F.2.1,
          algebraFormationOfCongruenceFormation_congruenceFormationOf Sig F'.2.1] at h1
      exact h1
    · intro h
      exact congruenceFormationOf_mono Sig h

/-! ### `B-P030`: the language formation `L_𝔉` of a congruence formation. -/

/-- `B-P030` (`Cong2LangBasic`): the language formation `L_𝔉` associated to a
congruence formation `𝔉`, `L_𝔉(A) = {L ∈ Sub(T_Σ(A)) | Ω^{T_Σ(A)}(L) ∈ 𝔉(A)}`
(equivalently the `Φ`-saturated languages for some `Φ ∈ 𝔉(A)`). -/
def langFormationOf {S : Type u} (Sig : Signature S)
    (G : (A : SSet S) → Set (SortedEqv (Term Sig A))) :
    (A : SSet S) → Set (Sub (Term Sig A)) :=
  fun A => {L | congCogenerated Sig (termAlg Sig A) L ∈ G A}

/-- `B-P030`: the two defining presentations of `L_𝔉(A) agree`: `L ∈ L_𝔉(A)`
iff `L` is `Φ`-saturated for some `Φ ∈ 𝔉(A)`. -/
theorem mem_langFormationOf_iff {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S) (L : Sub (Term Sig A)) :
    L ∈ langFormationOf Sig G A ↔ ∃ Φ ∈ G A, IsSat Φ L := by
  constructor
  · intro h
    exact ⟨congCogenerated Sig (termAlg Sig A) L, h,
      (isSat_iff_le_congCogenerated Sig (termAlg Sig A) L
        (congCogenerated_isCongruence Sig (termAlg Sig A) L)).mpr (fun _ _ _ h => h)⟩
  · rintro ⟨Φ, hΦG, hΦsat⟩
    exact (hG.1 A).2.2.2 Φ hΦG (congCogenerated Sig (termAlg Sig A) L)
      (congCogenerated_isCongruence Sig (termAlg Sig A) L)
      ((isSat_iff_le_congCogenerated Sig (termAlg Sig A) L ((hG.1 A).2.1 Φ hΦG)).mp hΦsat)

/-- `B-P030`(1): every `∇^{T_Σ(A)}`-saturated language lies in `L_𝔉(A)` (so `∅`
and `T_Σ(A)` are languages). -/
theorem langFormationOf_nabla {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S) :
    ∀ L : Sub (Term Sig A), IsSat (nabla (Term Sig A)) L → L ∈ langFormationOf Sig G A := by
  intro L hL
  obtain ⟨Φ₀, hΦ₀⟩ := (hG.1 A).1
  have hnablaG : nabla (Term Sig A) ∈ G A :=
    (hG.1 A).2.2.2 Φ₀ hΦ₀ (nabla (Term Sig A))
      (nabla_isCongruence Sig (termAlg Sig A).2) (fun _ _ _ _ => trivial)
  show congCogenerated Sig (termAlg Sig A) L ∈ G A
  have heq : congCogenerated Sig (termAlg Sig A) L = nabla (Term Sig A) :=
    sortedEqvLe_antisymm (fun _ _ _ _ => trivial)
      ((isSat_iff_le_congCogenerated Sig (termAlg Sig A) L
        (nabla_isCongruence Sig (termAlg Sig A).2)).mp hL)
  rw [heq]; exact hnablaG

/-- `B-P030`(2): if `L, L' ∈ L_𝔉(A)`, every `(Ω(L) ∩ Ω(L'))`-saturated language
lies in `L_𝔉(A)`. -/
theorem langFormationOf_inf {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S) :
    ∀ L L' : Sub (Term Sig A), L ∈ langFormationOf Sig G A →
      L' ∈ langFormationOf Sig G A → ∀ N : Sub (Term Sig A),
        IsSat (sortedEqvInf (congCogenerated Sig (termAlg Sig A) L)
          (congCogenerated Sig (termAlg Sig A) L')) N → N ∈ langFormationOf Sig G A := by
  intro L L' hL hL' N hN
  show congCogenerated Sig (termAlg Sig A) N ∈ G A
  have hmeet : sortedEqvInf (congCogenerated Sig (termAlg Sig A) L)
      (congCogenerated Sig (termAlg Sig A) L') ∈ G A :=
    (hG.1 A).2.2.1 _ hL _ hL'
  exact (hG.1 A).2.2.2 _ hmeet _ (congCogenerated_isCongruence Sig (termAlg Sig A) N)
    ((isSat_iff_le_congCogenerated Sig (termAlg Sig A) N
      (IsCongruence_inf Sig (termAlg Sig A).2
        (congCogenerated_isCongruence Sig (termAlg Sig A) L)
        (congCogenerated_isCongruence Sig (termAlg Sig A) L'))).mp hN)

/-- `B-P030`(3): for `M ∈ L_𝔉(B)` and an `Ω^{T_Σ(B)}(M)`-epimorphism
`f : T_Σ(A) → T_Σ(B)`, every `Ker(pr^{Ω(M)} ∘ f)`-saturated language lies in
`L_𝔉(A)`. -/
theorem langFormationOf_ker {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A B : SSet S) :
    ∀ M : Sub (Term Sig B), M ∈ langFormationOf Sig G B →
      ∀ f : SortedMap (Term Sig A) (Term Sig B),
        IsAlgHom Sig (termAlg Sig A).2 (termAlg Sig B).2 f →
        (∀ s, Function.Surjective (fun x => prAlg Sig (termAlg Sig B).2
          (congCogenerated Sig (termAlg Sig B) M)
          (congCogenerated_isCongruence Sig (termAlg Sig B) M) s (f s x))) →
        ∀ N : Sub (Term Sig A),
          IsSat (ker (fun s => prAlg Sig (termAlg Sig B).2
            (congCogenerated Sig (termAlg Sig B) M)
            (congCogenerated_isCongruence Sig (termAlg Sig B) M) s ∘ f s)) N →
          N ∈ langFormationOf Sig G A := by
  intro M hM f hf hsurj N hN
  let Θ : SortedEqv (Term Sig B) := congCogenerated Sig (termAlg Sig B) M
  let hΘ : IsCongruence Sig (termAlg Sig B).2 Θ :=
    congCogenerated_isCongruence Sig (termAlg Sig B) M
  let g : SortedMap (Term Sig A) (quotAlg Sig (termAlg Sig B).2 Θ hΘ).1 :=
    fun s => (prAlg Sig (termAlg Sig B).2 Θ hΘ s) ∘ (f s)
  have hg : IsAlgHom Sig (termAlg Sig A).2 (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 g := by
    intro p σ a
    show prAlg Sig (termAlg Sig B).2 Θ hΘ p.2 (f p.2 ((termAlg Sig A).2 p σ a)) =
      (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 p σ
        (fun i => prAlg Sig (termAlg Sig B).2 Θ hΘ (p.1.get i) (f (p.1.get i) (a i)))
    rw [hf p σ a]
    exact isAlgHom_prAlg Sig (termAlg Sig B).2 Θ hΘ p σ
      (fun i => f (p.1.get i) (a i))
  have hker : ker (fun s => prAlg Sig (termAlg Sig B).2 Θ hΘ s ∘ f s) ∈ G A :=
    hG.2 A B Θ hΘ (show Θ ∈ G B from hM) f hf hsurj
  show congCogenerated Sig (termAlg Sig A) N ∈ G A
  exact (hG.1 A).2.2.2 _ hker _ (congCogenerated_isCongruence Sig (termAlg Sig A) N)
    ((isSat_iff_le_congCogenerated Sig (termAlg Sig A) N
      (ker_isCongruence Sig (termAlg Sig A).2 (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 g hg)).mp hN)

/-! ### `B-D045`/`B-D046`: formations of regular languages. -/

/-- `B-D045` (`Def1FRL`): a *formation of regular languages*: a choice function
`L` with `L(A) ⊆ Lang_r(T_Σ(A))`, containing every `∇^{T_Σ(A)}`-saturated
language, closed under `(Ω(L) ∩ Ω(L'))`-saturation, and closed under
`Ker(pr^{Ω(M)} ∘ f)`-saturation along `Ω(M)`-epimorphisms. -/
def IsRegularLanguageFormation {S : Type u} (Sig : Signature S)
    (L : (A : SSet S) → Set (Sub (Term Sig A))) : Prop :=
  (∀ A, L A ⊆ regularLanguages Sig (termAlg Sig A)) ∧
  (∀ A, ∀ X : Sub (Term Sig A), IsSat (nabla (Term Sig A)) X → X ∈ L A) ∧
  (∀ A, ∀ X Y : Sub (Term Sig A), X ∈ L A → Y ∈ L A → ∀ N : Sub (Term Sig A),
      IsSat (sortedEqvInf (congCogenerated Sig (termAlg Sig A) X)
        (congCogenerated Sig (termAlg Sig A) Y)) N → N ∈ L A) ∧
  (∀ A B (M : Sub (Term Sig B)), M ∈ L B →
      ∀ f : SortedMap (Term Sig A) (Term Sig B),
        IsAlgHom Sig (termAlg Sig A).2 (termAlg Sig B).2 f →
        (∀ s, Function.Surjective (fun x => prAlg Sig (termAlg Sig B).2
          (congCogenerated Sig (termAlg Sig B) M)
          (congCogenerated_isCongruence Sig (termAlg Sig B) M) s (f s x))) →
        ∀ N : Sub (Term Sig A),
          IsSat (ker (fun s => prAlg Sig (termAlg Sig B).2
            (congCogenerated Sig (termAlg Sig B) M)
            (congCogenerated_isCongruence Sig (termAlg Sig B) M) s ∘ f s)) N →
          N ∈ L A)

/-- `B-D046` (`Def2FRL`): a (BPS-)formation of regular languages, by translations
and Boolean operations: `L(A) ⊆ Lang_r(T_Σ(A))`, contains the `∇`-saturated
languages, is closed under inverse images of translations, is a Boolean
subalgebra of `Sub(T_Σ(A))`, and is closed under inverse images along
`Ω(M)`-epimorphisms. -/
def IsBPSLanguageFormation {S : Type u} (Sig : Signature S)
    (L : (A : SSet S) → Set (Sub (Term Sig A))) : Prop :=
  (∀ A, L A ⊆ regularLanguages Sig (termAlg Sig A)) ∧
  (∀ A, ∀ X : Sub (Term Sig A), IsSat (nabla (Term Sig A)) X → X ∈ L A) ∧
  (∀ A, ∀ X : Sub (Term Sig A), X ∈ L A →
      ∀ (t s : S) (T : (Term Sig A) t → (Term Sig A) s),
        TlGen Sig (termAlg Sig A) t s T → transPreimage T X ∈ L A) ∧
  (∀ A, ∀ X : Sub (Term Sig A), X ∈ L A → ∀ Y : Sub (Term Sig A), Y ∈ L A →
      (fun s => X s ∪ Y s) ∈ L A ∧ (fun s => X s ∩ Y s) ∈ L A ∧ complA X ∈ L A) ∧
  (∀ A B (M : Sub (Term Sig B)), M ∈ L B →
      ∀ f : SortedMap (Term Sig A) (Term Sig B),
        IsAlgHom Sig (termAlg Sig A).2 (termAlg Sig B).2 f →
        (∀ s, Function.Surjective (fun x => prAlg Sig (termAlg Sig B).2
          (congCogenerated Sig (termAlg Sig B) M)
          (congCogenerated_isCongruence Sig (termAlg Sig B) M) s (f s x))) →
        inverseImage f M ∈ L A)

/-- `B-D045`: `Form_Lang_r(Σ)`, the set of formations of regular languages. -/
def regularLanguageFormations {S : Type u} (Sig : Signature S) :
    Set ((A : SSet S) → Set (Sub (Term Sig A))) :=
  {L | IsRegularLanguageFormation Sig L}

/-- `B-D046`: `Form^BPS_Lang_r(Σ)`, the set of BPS-formations of regular
languages. -/
def bpsLanguageFormations {S : Type u} (Sig : Signature S) :
    Set ((A : SSet S) → Set (Sub (Term Sig A))) :=
  {L | IsBPSLanguageFormation Sig L}

/-! ### `B-P037`: `𝔉 ↦ L_𝔉` lands in regular-language formations. -/

/-- `B-P037` (`Cong2LangEnFinit`): if `𝔉` is a formation of finite-index
congruences, then `L_𝔉` is a formation of regular languages. The regularity
clause is that `Ω(L) ∈ 𝔉(A)` has finite index; the three closure clauses are
`B-P030`'s `langFormationOf_nabla`/`_inf`/`_ker`. -/
theorem langFormationOf_isRegularLanguageFormation {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsFiniteIndexCongruenceFormation Sig G) :
    IsRegularLanguageFormation Sig (langFormationOf Sig G) :=
  ⟨fun A _L hL => (hG.2 A hL).2,
   fun A X hX => langFormationOf_nabla Sig hG.1 A X hX,
   fun A X Y hX hY N hN => langFormationOf_inf Sig hG.1 A X Y hX hY N hN,
   fun A B M hM f hf hsurj N hN =>
     langFormationOf_ker Sig hG.1 A B M hM f hf hsurj N hN⟩

end Mslang
