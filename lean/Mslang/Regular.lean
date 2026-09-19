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

/-! ### Boolean closure of a regular-language formation. -/

/-- `Ω^A(L)` saturates `L` (it is the greatest congruence doing so). -/
theorem isSat_congCogenerated {S : Type u} (Sig : Signature S) (A : Alg Sig)
    (X : Sub A.1) : IsSat (congCogenerated Sig A X) X :=
  (isSat_iff_le_congCogenerated Sig A X (congCogenerated_isCongruence Sig A X)).mpr
    (fun _ _ _ h => h)

/-- A regular-language formation contains the empty language. -/
theorem regularFormation_empty {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) (A : SSet S) :
    (fun s => (∅ : Set (Term Sig A s))) ∈ L A :=
  hL.2.1 A _ nabla_sat_empty

/-- A regular-language formation is closed under binary union. -/
theorem regularFormation_union {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) (A : SSet S)
    (X Y : Sub (Term Sig A)) (hX : X ∈ L A) (hY : Y ∈ L A) :
    (fun s => X s ∪ Y s) ∈ L A :=
  hL.2.2.1 A X Y hX hY (fun s => X s ∪ Y s)
    (isSat_union
      (sat_antitone
        (sortedEqvInf_le_left (congCogenerated Sig (termAlg Sig A) X)
          (congCogenerated Sig (termAlg Sig A) Y))
        (isSat_congCogenerated Sig (termAlg Sig A) X))
      (sat_antitone
        (sortedEqvInf_le_right (congCogenerated Sig (termAlg Sig A) X)
          (congCogenerated Sig (termAlg Sig A) Y))
        (isSat_congCogenerated Sig (termAlg Sig A) Y)))

/-- A regular-language formation is closed under binary intersection. -/
theorem regularFormation_inter {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) (A : SSet S)
    (X Y : Sub (Term Sig A)) (hX : X ∈ L A) (hY : Y ∈ L A) :
    (fun s => X s ∩ Y s) ∈ L A :=
  hL.2.2.1 A X Y hX hY (fun s => X s ∩ Y s)
    (isSat_inter
      (sat_antitone
        (sortedEqvInf_le_left (congCogenerated Sig (termAlg Sig A) X)
          (congCogenerated Sig (termAlg Sig A) Y))
        (isSat_congCogenerated Sig (termAlg Sig A) X))
      (sat_antitone
        (sortedEqvInf_le_right (congCogenerated Sig (termAlg Sig A) X)
          (congCogenerated Sig (termAlg Sig A) Y))
        (isSat_congCogenerated Sig (termAlg Sig A) Y)))

/-- A regular-language formation is closed under finite unions (induction on the
`Finset` of indices). -/
theorem regularFormation_finset_biUnion {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) (A : SSet S) {ι : Type u}
    [DecidableEq ι] (s : Finset ι) (f : ι → Sub (Term Sig A))
    (hf : ∀ i ∈ s, f i ∈ L A) :
    (fun u => ⋃ i ∈ s, f i u) ∈ L A := by
  classical
  revert hf
  induction s using Finset.induction_on with
  | empty =>
      intro _
      have h : (fun u => ⋃ i ∈ (∅ : Finset ι), f i u)
          = fun u => (∅ : Set (Term Sig A u)) := by
        funext u
        simp
      rw [h]
      exact regularFormation_empty Sig hL A
  | insert a s ha ih =>
      intro hf
      have h : (fun u => ⋃ i ∈ insert a s, f i u)
          = fun u => f a u ∪ (⋃ i ∈ s, f i u) := by
        funext u
        rw [Finset.set_biUnion_insert]
      rw [h]
      exact regularFormation_union Sig hL A (f a) (fun u => ⋃ i ∈ s, f i u)
        (hf a (Finset.mem_insert_self a s))
        (ih (fun i hi => hf i (Finset.mem_insert_of_mem hi)))

/-- A regular-language formation is closed under unions indexed by any finite
type. -/
theorem regularFormation_iUnion_finite {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) (A : SSet S) {ι : Type u} [Finite ι]
    (f : ι → Sub (Term Sig A)) (hf : ∀ i, f i ∈ L A) :
    (fun s => ⋃ i, f i s) ∈ L A := by
  classical
  haveI : Fintype ι := Fintype.ofFinite ι
  have hEq : (fun s => ⋃ i, f i s)
      = fun s => ⋃ i ∈ (Finset.univ : Finset ι), f i s := by
    funext s
    rw [← Finset.set_biUnion_coe, Finset.coe_univ, Set.biUnion_univ]
  rw [hEq]
  exact regularFormation_finset_biUnion Sig hL A Finset.univ f (fun i _ => hf i)

/-! ### Atoms of a sorted equivalence: `δ^{s,[a]_Φ}`. -/

/-- The shell `δ^{s,[a]_Φ}` of an explicit representative: the `Φ`-class of `a`
concentrated at sort `s`. -/
noncomputable def atomRep {S : Type u} {A : SSet S} (Φ : SortedEqv A) (s : S) (a : A s) :
    Sub A :=
  deltaSub s (eqvClass Φ s a)

/-- The atom of a class `q : A/Φ`: the paper's Kronecker delta
`δ^{q.1,[out q]_{Φ_{q.1}}}`. (`Quotient.out` selects a representative.) -/
noncomputable def atomOf {S : Type u} {A : SSet S} (Φ : SortedEqv A)
    (q : Sigma (quot Φ)) : Sub A :=
  atomRep Φ q.1 (Quotient.out q.2)

/-- Each atom `δ^{s,[a]_Φ}` is `Φ`-saturated. -/
theorem isSat_atomRep {S : Type u} {A : SSet S} (Φ : SortedEqv A) (s : S) (a : A s) :
    IsSat Φ (atomRep Φ s a) := by
  classical
  unfold IsSat
  funext t
  by_cases ht : t = s
  · subst t
    ext b
    simp only [atomRep, deltaSub, Function.update_self, sat, Set.mem_ofPred_eq, eqvClass]
    constructor
    · rintro ⟨x, hax, hxb⟩
      exact (Φ s).trans hax hxb
    · intro hab
      exact ⟨a, (Φ s).refl a, hab⟩
  · have hz : atomRep Φ s a t = (∅ : Set (A t)) := by
      simp only [atomRep, deltaSub, Function.update_of_ne ht]
    rw [hz]
    simp [sat, hz]

theorem isSat_atomOf {S : Type u} {A : SSet S} (Φ : SortedEqv A)
    (q : Sigma (quot Φ)) : IsSat Φ (atomOf Φ q) :=
  isSat_atomRep Φ q.1 (Quotient.out q.2)

/-- The atoms of a meet factor through the atoms of the two factors:
`δ^{s,[a]_{Φ∩Ψ}} = δ^{s,[a]_Φ} ∩ δ^{s,[a]_Ψ}`. -/
theorem atomRep_inf {S : Type u} {A : SSet S} (Φ Ψ : SortedEqv A) (s : S) (a : A s) :
    atomRep (sortedEqvInf Φ Ψ) s a = fun t => atomRep Φ s a t ∩ atomRep Ψ s a t := by
  classical
  funext t
  by_cases ht : t = s
  · subst t
    ext b
    simp only [atomRep, deltaSub, Function.update_self, eqvClass]
    unfold sortedEqvInf
    exact Iff.rfl
  · have h1 : atomRep (sortedEqvInf Φ Ψ) s a t = (∅ : Set (A t)) := by
      simp only [atomRep, deltaSub, Function.update_of_ne ht]
    have h2 : atomRep Φ s a t = (∅ : Set (A t)) := by
      simp only [atomRep, deltaSub, Function.update_of_ne ht]
    have h3 : atomRep Ψ s a t = (∅ : Set (A t)) := by
      simp only [atomRep, deltaSub, Function.update_of_ne ht]
    rw [h1, h2, h3, Set.empty_inter]

theorem atomOf_inf {S : Type u} {A : SSet S} (Φ Ψ : SortedEqv A)
    (q : Sigma (quot (sortedEqvInf Φ Ψ))) :
    atomOf (sortedEqvInf Φ Ψ) q
      = fun s => atomRep Φ q.1 (Quotient.out q.2) s
          ∩ atomRep Ψ q.1 (Quotient.out q.2) s := by
  unfold atomOf
  exact atomRep_inf Φ Ψ q.1 (Quotient.out q.2)

/-- A `Φ`-saturated set is the union of the atoms of `Φ` whose representative
lies in it. -/
theorem eq_iUnion_atoms {S : Type u} {A : SSet S} (Φ : SortedEqv A) (N : Sub A)
    (hN : IsSat Φ N) :
    N = fun s => ⋃ q : {q : Sigma (quot Φ) //
        (Quotient.out q.2 : A q.1) ∈ N q.1}, atomOf Φ q.1 s := by
  classical
  funext s
  ext a
  constructor
  · intro ha
    refine Set.mem_iUnion.mpr ⟨⟨⟨s, Quotient.mk (Φ s) a⟩, ?_⟩, ?_⟩
    · have hrel : (Φ s).r (Quotient.out (Quotient.mk (Φ s) a)) a :=
        Quotient.exact (Quotient.out_eq (Quotient.mk (Φ s) a))
      rw [← hN]
      exact ⟨a, ha, (Φ s).symm hrel⟩
    · simp only [atomOf, atomRep, deltaSub, Function.update_self, eqvClass]
      exact Quotient.exact (Quotient.out_eq (Quotient.mk (Φ s) a))
  · intro ha
    rcases Set.mem_iUnion.mp ha with ⟨q, hq⟩
    have hcond : (Quotient.out q.1.2 : A q.1.1) ∈ N q.1.1 := q.2
    have hs : s = q.1.1 := by
      by_contra hne
      have hz : atomOf Φ q.1 s = (∅ : Set (A s)) := by
        simp only [atomOf, atomRep, deltaSub, Function.update_of_ne hne]
      rw [hz] at hq
      exact hq
    subst hs
    have hrel : (Φ q.1.1).r (Quotient.out q.1.2) a := by
      simpa only [atomOf, atomRep, deltaSub, Function.update_self, eqvClass,
        Set.mem_ofPred_eq] using hq
    have hsat : a ∈ sat Φ N q.1.1 := ⟨Quotient.out q.1.2, hcond, hrel⟩
    rw [hN] at hsat
    exact hsat

/-! ### `B-P038`: `𝔉_𝔏`, the congruence formation of a regular-language
formation. -/

/-- `B-P038` (`Lang2CongEnFinit`): the congruence formation
`𝔉_𝔏(A) = {Φ ∈ Cgr_fi(T_Σ(A)) | Φ-Sat(T_Σ(A)) ⊆ 𝔏(A)}` associated to a
formation `𝔏` of regular languages. -/
def langCongFormationOf {S : Type u} (Sig : Signature S)
    (L : (A : SSet S) → Set (Sub (Term Sig A))) :
    (A : SSet S) → Set (SortedEqv (Term Sig A)) :=
  fun A => {Φ | Φ ∈ congFi Sig (termAlg Sig A).2 ∧
    ∀ N : Sub (Term Sig A), IsSat Φ N → N ∈ L A}

/-- `B-P038`: `𝔉_𝔏(A)` is nonempty, because `∇^{T_Σ(A)}` has finite index (as
`S` is finite) and every `∇`-saturated language lies in `𝔏(A)`. -/
theorem langCongFormationOf_nabla {S : Type u} (Sig : Signature S) [Finite S]
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) (A : SSet S) :
    nabla (Term Sig A) ∈ langCongFormationOf Sig L A := by
  refine ⟨⟨nabla_isCongruence Sig (termAlg Sig A).2, ?_⟩, ?_⟩
  · exact isFiniteIndex_nabla (Term Sig A)
      (Set.finite_univ.subset (Set.subset_univ (supp (Term Sig A))))
  · intro N hN
    exact hL.2.1 A N hN

/-- `B-P038`: `𝔉_𝔏(A)` is up-closed under refinement among congruences (a
coarser congruence has fewer saturated sets, by `B-C001`). -/
theorem langCongFormationOf_up {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))} (A : SSet S) :
    ∀ Φ ∈ langCongFormationOf Sig L A, ∀ Ψ : SortedEqv (Term Sig A),
      IsCongruence Sig (termAlg Sig A).2 Ψ → sortedEqvLe Φ Ψ →
      Ψ ∈ langCongFormationOf Sig L A := by
  intro Φ hΦ Ψ hΨ hle
  exact ⟨⟨hΨ, IsFiniteIndex_of_le hle hΦ.1.2⟩,
    fun N hN => hΦ.2 N (sat_antitone hle hN)⟩

/-- `B-P038`: `𝔉_𝔏(A)` is closed under the pointwise meet. A `(Φ ∩ Ψ)`-saturated
`N` is the finite union of its atoms `δ^{s,[P]_{(Φ∩Ψ)_s}}`; each atom is the
intersection of a `Φ`-atom and a `Ψ`-atom, both in `𝔏(A)`, so the union is too
(`𝔏(A)` is a Boolean algebra and `Φ ∩ Ψ` has finite index). -/
theorem langCongFormationOf_inf {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) (A : SSet S) :
    ∀ Φ ∈ langCongFormationOf Sig L A, ∀ Ψ ∈ langCongFormationOf Sig L A,
      sortedEqvInf Φ Ψ ∈ langCongFormationOf Sig L A := by
  intro Φ hΦ Ψ hΨ
  refine ⟨⟨IsCongruence_inf Sig (termAlg Sig A).2 hΦ.1.1 hΨ.1.1,
    IsFiniteIndex_inf hΦ.1.2 hΨ.1.2⟩, ?_⟩
  intro N hN
  haveI : Finite (Sigma (quot (sortedEqvInf Φ Ψ))) :=
    IsFiniteIndex_inf hΦ.1.2 hΨ.1.2
  let g : {q : Sigma (quot (sortedEqvInf Φ Ψ)) //
      (Quotient.out q.2 : Term Sig A q.1) ∈ N q.1} → Sub (Term Sig A) :=
    fun q => atomOf (sortedEqvInf Φ Ψ) q.1
  have hNunion : N = fun s => ⋃ q, g q s := eq_iUnion_atoms (sortedEqvInf Φ Ψ) N hN
  rw [hNunion]
  apply regularFormation_iUnion_finite Sig hL A g
  intro q
  change atomOf (sortedEqvInf Φ Ψ) q.1 ∈ L A
  rw [atomOf_inf]
  exact regularFormation_inter Sig hL A
    (atomRep Φ q.1.1 (Quotient.out q.1.2))
    (atomRep Ψ q.1.1 (Quotient.out q.1.2))
    (hΦ.2 (atomRep Φ q.1.1 (Quotient.out q.1.2))
      (isSat_atomRep Φ q.1.1 (Quotient.out q.1.2)))
    (hΨ.2 (atomRep Ψ q.1.1 (Quotient.out q.1.2))
      (isSat_atomRep Ψ q.1.1 (Quotient.out q.1.2)))

/-- `B-P038`: `𝔉_𝔏(A)` is closed under the pullback of kernels along
`Θ`-epimorphisms. The saturation step is the manuscript's argument: for a
`Ker(pr^Θ ∘ f)`-saturated `N`, the set `[f[N]]^Θ` lies in `𝔏(B)`, and `N` is
`Ker(pr^{Ω([f[N]]^Θ)} ∘ f)`-saturated, so `𝔏`'s preimage clause applies. -/
theorem langCongFormationOf_ker {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) (A B : SSet S)
    (Θ : SortedEqv (Term Sig B)) (hΘ : IsCongruence Sig (termAlg Sig B).2 Θ)
    (hΘmem : Θ ∈ langCongFormationOf Sig L B)
    (f : SortedMap (Term Sig A) (Term Sig B))
    (hf : IsAlgHom Sig (termAlg Sig A).2 (termAlg Sig B).2 f)
    (hsurj : ∀ s, Function.Surjective
      (fun x => prAlg Sig (termAlg Sig B).2 Θ hΘ s (f s x))) :
    ker (fun s => prAlg Sig (termAlg Sig B).2 Θ hΘ s ∘ f s)
      ∈ langCongFormationOf Sig L A := by
  let g : SortedMap (Term Sig A) (quot Θ) :=
    fun s => (prAlg Sig (termAlg Sig B).2 Θ hΘ s) ∘ (f s)
  change ker g ∈ langCongFormationOf Sig L A
  have hg : IsAlgHom Sig (termAlg Sig A).2 (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 g := by
    intro p σ a
    show prAlg Sig (termAlg Sig B).2 Θ hΘ p.2 (f p.2 ((termAlg Sig A).2 p σ a)) =
      (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 p σ
        (fun i => prAlg Sig (termAlg Sig B).2 Θ hΘ (p.1.get i) (f (p.1.get i) (a i)))
    rw [hf p σ a]
    exact isAlgHom_prAlg Sig (termAlg Sig B).2 Θ hΘ p σ
      (fun i => f (p.1.get i) (a i))
  have hkg : IsCongruence Sig (termAlg Sig A).2 (ker g) :=
    ker_isCongruence Sig (termAlg Sig A).2 (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 g hg
  have hiso := quotAlg_ker_isAlgIso Sig (termAlg Sig A).2
    (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 g hg hsurj
  refine ⟨⟨hkg, ?_⟩, ?_⟩
  · exact finiteSSet_of_isAlgIso Sig
      (isAlgIso_symm Sig (quotAlg Sig (termAlg Sig A).2 (ker g) hkg).2
        (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 hiso) hΘmem.1.2
  · intro N hN
    have hKsat : IsSat Θ (sat Θ (directImage f N)) := sat_idem Θ (directImage f N)
    have hKmem : sat Θ (directImage f N) ∈ L B := hΘmem.2 _ hKsat
    have hΘle : sortedEqvLe Θ
        (congCogenerated Sig (termAlg Sig B) (sat Θ (directImage f N))) :=
      (isSat_iff_le_congCogenerated Sig (termAlg Sig B) (sat Θ (directImage f N))
        hΘ).mp hKsat
    have hsurjΩ : ∀ s, Function.Surjective (fun x =>
        prAlg Sig (termAlg Sig B).2
          (congCogenerated Sig (termAlg Sig B) (sat Θ (directImage f N)))
          (congCogenerated_isCongruence Sig (termAlg Sig B) (sat Θ (directImage f N)))
          s (f s x)) := by
      intro s y
      induction y using Quotient.inductionOn with
      | _ b =>
        obtain ⟨x, hx⟩ := hsurj s (Quotient.mk (Θ s) b)
        refine ⟨x, ?_⟩
        have hxb : (Θ s).r (f s x) b := Quotient.exact hx
        exact Quotient.sound (hΘle s (f s x) b hxb)
    have hNsat : IsSat (ker (fun s => prAlg Sig (termAlg Sig B).2
        (congCogenerated Sig (termAlg Sig B) (sat Θ (directImage f N)))
        (congCogenerated_isCongruence Sig (termAlg Sig B) (sat Θ (directImage f N)))
        s ∘ f s)) N := by
      unfold IsSat
      funext s
      ext y
      constructor
      · rintro ⟨x, hx, hxy⟩
        have hΩrel : (congCogenerated Sig (termAlg Sig B)
            (sat Θ (directImage f N)) s).r (f s x) (f s y) := Quotient.exact hxy
        have hchar := congCogenerated_le_charEqv Sig (termAlg Sig B)
          (sat Θ (directImage f N)) s (f s x) (f s y) hΩrel
        have hfx : f s x ∈ sat Θ (directImage f N) s :=
          ⟨f s x, ⟨x, hx, rfl⟩, (Θ s).refl (f s x)⟩
        have hfy : f s y ∈ sat Θ (directImage f N) s := hchar.mp hfx
        rcases hfy with ⟨R, hR, hRy⟩
        rcases hR with ⟨R', hR', rfl⟩
        have hab : (ker g s).r R' y := by
          change Quotient.mk (Θ s) (f s R') = Quotient.mk (Θ s) (f s y)
          exact Quotient.sound hRy
        rw [← hN]
        exact ⟨R', hR', hab⟩
      · intro hy
        exact ⟨y, hy, rfl⟩
    exact hL.2.2.2 A B (sat Θ (directImage f N)) hKmem f hf hsurjΩ N hNsat

/-- `B-P038` (`Lang2CongEnFinit`): a formation `𝔏` of regular languages yields
a formation `𝔉_𝔏` of finite-index congruences. -/
theorem langCongFormationOf_isFiniteIndexCongruenceFormation {S : Type u}
    (Sig : Signature S) [Finite S]
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) :
    IsFiniteIndexCongruenceFormation Sig (langCongFormationOf Sig L) :=
  ⟨⟨fun A => ⟨⟨nabla (Term Sig A), langCongFormationOf_nabla Sig hL A⟩,
      fun _Φ hΦ => hΦ.1.1,
      fun Φ hΦ Ψ hΨ => langCongFormationOf_inf Sig hL A Φ hΦ Ψ hΨ,
      fun Φ hΦ Ψ hΨc hle => langCongFormationOf_up Sig A Φ hΦ Ψ hΨc hle⟩,
    fun A B Θ hΘ hΘmem f hf hsurj =>
      langCongFormationOf_ker Sig hL A B Θ hΘ hΘmem f hf hsurj⟩,
   fun _ _ hΦ => hΦ.1⟩

/-! ### `B-P039`: `Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)`. -/

/-- `sortedEqvInf` is idempotent. -/
theorem sortedEqvInf_self {S : Type u} {A : SSet S} (Φ : SortedEqv A) :
    sortedEqvInf Φ Φ = Φ :=
  sortedEqvLe_antisymm (fun _ _ _ h => h.1) (fun _ _ _ h => ⟨h, h⟩)

/-- A congruence formation is closed under finite meets (over any finite index). -/
theorem IsCongruenceFormation_finset_inf {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S) {ι : Type u} [Fintype ι]
    (Φ : ι → SortedEqv (Term Sig A)) (h : ∀ i, Φ i ∈ G A) :
    (Finset.univ : Finset ι).inf Φ ∈ G A := by
  classical
  have hstep : ∀ (t : Finset ι), t.inf Φ ∈ G A := by
    intro t
    induction t using Finset.induction with
    | empty =>
        rw [Finset.inf_empty]
        obtain ⟨Ψ₀, hΨ₀⟩ := (hG.1 A).1
        exact (hG.1 A).2.2.2 Ψ₀ hΨ₀ ⊤ (fun _ _ _ _ _ => trivial)
          (fun _ _ _ _ => trivial)
    | insert a t ha ih =>
        rw [Finset.inf_insert]
        exact (hG.1 A).2.2.1 (Φ a) (h a) (t.inf Φ) ih
  exact hstep Finset.univ

/-- `B-P030`: `L_𝔉` is monotone in `𝔉`. -/
theorem langFormationOf_mono {S : Type u} (Sig : Signature S)
    {G G' : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (h : ∀ A, G A ⊆ G' A) :
    ∀ A, langFormationOf Sig G A ⊆ langFormationOf Sig G' A := by
  intro A L hL
  exact h A hL

/-- `B-P038`: `𝔉_𝔏` is monotone in `𝔏`. -/
theorem langCongFormationOf_mono {S : Type u} (Sig : Signature S)
    {L L' : (A : SSet S) → Set (Sub (Term Sig A))}
    (h : ∀ A, L A ⊆ L' A) :
    ∀ A, langCongFormationOf Sig L A ⊆ langCongFormationOf Sig L' A := by
  rintro A Φ ⟨hΦ, hsat⟩
  exact ⟨hΦ, fun N hN => h A (hsat N hN)⟩

/-- `B-P039` (first round trip): `𝔉_{L_𝔉} = 𝔉` for a formation of finite-index
congruences. The substantive direction reduces `Φ ∈ 𝔉_{L_𝔉}(A)` to the finite
meet of the `Ω(δ^{s,[a]_Φ})` over the finitely many `Φ`-classes: each atom is
`Φ`-saturated, hence lies in `L_𝔉(A)`, hence its syntactic congruence is in
`𝔉(A)` by up-closure; `𝔉` is closed under finite meets and that meet refines
`Φ` (every class is one of the atoms), so `Φ ∈ 𝔉(A)` by up-closure. -/
theorem langCongFormationOf_langFormationOf {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsFiniteIndexCongruenceFormation Sig G) :
    langCongFormationOf Sig (langFormationOf Sig G) = G := by
  funext A
  ext Φ
  constructor
  · intro hΦ
    haveI : Finite (Sigma (quot Φ)) := hΦ.1.2
    haveI : Fintype (Sigma (quot Φ)) := Fintype.ofFinite _
    let Ωfun : Sigma (quot Φ) → SortedEqv (Term Sig A) :=
      fun q => congCogenerated Sig (termAlg Sig A) (atomOf Φ q)
    have hΩmem : ∀ q, Ωfun q ∈ G A := by
      intro q
      have hmemL : atomOf Φ q ∈ langFormationOf Sig G A :=
        hΦ.2 (atomOf Φ q) (isSat_atomOf Φ q)
      obtain ⟨Ψ, hΨG, hΨsat⟩ :=
        (mem_langFormationOf_iff Sig hG.1 A (atomOf Φ q)).mp hmemL
      exact (hG.1.1 A).2.2.2 Ψ hΨG (Ωfun q)
        (congCogenerated_isCongruence Sig (termAlg Sig A) (atomOf Φ q))
        ((isSat_iff_le_congCogenerated Sig (termAlg Sig A) (atomOf Φ q)
          ((hG.1.1 A).2.1 Ψ hΨG)).mp hΨsat)
    have hInf : (Finset.univ : Finset (Sigma (quot Φ))).inf Ωfun ∈ G A :=
      IsCongruenceFormation_finset_inf Sig hG.1 A Ωfun (fun q => hΩmem q)
    have hle : sortedEqvLe ((Finset.univ : Finset (Sigma (quot Φ))).inf Ωfun) Φ := by
      intro s x y hxy
      let qx : Sigma (quot Φ) := ⟨s, Quotient.mk (Φ s) x⟩
      have hq : (Ωfun qx s).r x y :=
        (Setoid.le_def.mp ((Pi.le_def.mp (Finset.inf_le (Finset.mem_univ qx))) s)) hxy
      have hxatom : x ∈ atomOf Φ qx s := by
        show x ∈ atomRep Φ s (Quotient.out (Quotient.mk (Φ s) x)) s
        simp only [atomRep, deltaSub, Function.update_self, eqvClass, Set.mem_ofPred_eq]
        exact Quotient.exact (Quotient.out_eq (Quotient.mk (Φ s) x))
      have hsat : IsSat (Ωfun qx) (atomOf Φ qx) :=
        isSat_congCogenerated Sig (termAlg Sig A) (atomOf Φ qx)
      have hyatom : y ∈ atomOf Φ qx s := by
        rw [← hsat]
        exact ⟨x, hxatom, hq⟩
      have hout : (Φ s).r (Quotient.out (Quotient.mk (Φ s) x)) y := by
        simpa only [qx, atomOf, atomRep, deltaSub, Function.update_self, eqvClass,
          Set.mem_ofPred_eq] using hyatom
      exact (Φ s).trans ((Φ s).symm
        (Quotient.exact (Quotient.out_eq (Quotient.mk (Φ s) x)))) hout
    exact (hG.1.1 A).2.2.2 ((Finset.univ : Finset (Sigma (quot Φ))).inf Ωfun) hInf Φ
      hΦ.1.1 hle
  · intro hΦG
    refine ⟨hG.2 A hΦG, ?_⟩
    intro N hN
    exact (mem_langFormationOf_iff Sig hG.1 A N).mpr ⟨Φ, hΦG, hN⟩

/-- `B-P039` (second round trip): `L_{𝔉_𝔏} = 𝔏` for a formation of regular
languages. -/
theorem langFormationOf_langCongFormationOf {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) :
    langFormationOf Sig (langCongFormationOf Sig L) = L := by
  funext A
  ext N
  constructor
  · intro hN
    exact hN.2 N (isSat_congCogenerated Sig (termAlg Sig A) N)
  · intro hN
    refine ⟨⟨congCogenerated_isCongruence Sig (termAlg Sig A) N, hL.1 A hN⟩, ?_⟩
    intro M hM
    have hM' : IsSat (sortedEqvInf (congCogenerated Sig (termAlg Sig A) N)
        (congCogenerated Sig (termAlg Sig A) N)) M := by
      rw [sortedEqvInf_self]
      exact hM
    exact hL.2.2.1 A N N hN hN M hM'

/-- `B-P039`: the order isomorphism `Form_Cgr_fi(Σ) ≃o Form_Lang_r(Σ)` (the
second Eilenberg theorem). `θ : 𝔉 ↦ L_𝔉` (`B-P030`) and
`θ⁻¹ : 𝔏 ↦ 𝔉_𝔏` (`B-P038`) are mutually inverse and preserve/reflect the order. -/
def formCgrFiFormLangRIso {S : Type u} (Sig : Signature S) [Finite S] :
    finiteIndexCongruenceFormations Sig ≃o regularLanguageFormations Sig where
  toFun G := ⟨langFormationOf Sig G.1,
    langFormationOf_isRegularLanguageFormation Sig G.2⟩
  invFun L := ⟨langCongFormationOf Sig L.1,
    langCongFormationOf_isFiniteIndexCongruenceFormation Sig L.2⟩
  left_inv G := Subtype.ext (langCongFormationOf_langFormationOf Sig G.2)
  right_inv L := Subtype.ext (langFormationOf_langCongFormationOf Sig L.2)
  map_rel_iff' := by
    intro G G'
    constructor
    · intro h A Φ hΦ
      rw [← langCongFormationOf_langFormationOf Sig G.2] at hΦ
      have h' : ∀ A, langFormationOf Sig G.1 A ⊆ langFormationOf Sig G'.1 A := h
      have hmono := langCongFormationOf_mono Sig h' A hΦ
      rwa [langCongFormationOf_langFormationOf Sig G'.2] at hmono
    · intro h
      exact langFormationOf_mono Sig h

/-! ### `B-C007`--`B-C010`, `B-R022`/`B-R023`: closure properties of `L_𝔉`. -/

/-- `B-R022`: `L_𝔉(A)` is the union of the saturated sets `Φ-Sat(T_Σ(A))` over
`Φ ∈ 𝔉(A)`. -/
theorem langFormationOf_eq_iUnion_satSets {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S) :
    langFormationOf Sig G A = ⋃ Φ ∈ G A, satSets Φ := by
  ext L
  simp only [Set.mem_iUnion, exists_prop, satSets, Set.mem_ofPred_eq]
  exact mem_langFormationOf_iff Sig hG A L

/-- `B-R023`: if `L ∈ L_𝔉(A)` and `Ω(L) ⊆ Ψ` (with `Ψ` a congruence), then the
saturation `[L]^Ψ` is again in `L_𝔉(A)`. -/
theorem langFormationOf_sat_of_le {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S)
    {L : Sub (Term Sig A)} (hL : L ∈ langFormationOf Sig G A)
    {Ψ : SortedEqv (Term Sig A)}
    (hle : sortedEqvLe (congCogenerated Sig (termAlg Sig A) L) Ψ) :
    sat Ψ L ∈ langFormationOf Sig G A := by
  obtain ⟨Φ, hΦG, hΦsat⟩ := (mem_langFormationOf_iff Sig hG A L).mp hL
  have hΦleΩ : sortedEqvLe Φ (congCogenerated Sig (termAlg Sig A) L) :=
    (isSat_iff_le_congCogenerated Sig (termAlg Sig A) L
      ((hG.1 A).2.1 Φ hΦG)).mp hΦsat
  exact (mem_langFormationOf_iff Sig hG A _).mpr
    ⟨Φ, hΦG, sat_antitone (sortedEqvLe_trans hΦleΩ hle) (sat_idem Ψ L)⟩

/-- `B-C007`: `L_𝔉` is closed under inverse images of translations. -/
theorem langFormationOf_transPreimage {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S)
    {t s : S} {T : Term Sig A t → Term Sig A s}
    (hT : TlGen Sig (termAlg Sig A) t s T) {L : Sub (Term Sig A)}
    (hL : L ∈ langFormationOf Sig G A) :
    transPreimage T L ∈ langFormationOf Sig G A := by
  have hΩG : congCogenerated Sig (termAlg Sig A) L ∈ G A := hL
  have hs : IsSat (congCogenerated Sig (termAlg Sig A) L) (transPreimage T L) :=
    (isSat_iff_le_congCogenerated Sig (termAlg Sig A) (transPreimage T L)
      ((hG.1 A).2.1 _ hΩG)).mpr
      (congCogenerated_le_transPreimage Sig (termAlg Sig A) hT L)
  refine langFormationOf_inf Sig hG A L L hL hL (transPreimage T L) ?_
  rw [sortedEqvInf_self]
  exact hs

/-- `B-C010`: `L_𝔉` is closed under inverse images along `Ω(M)`-epimorphisms. -/
theorem langFormationOf_inverseImage {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A B : SSet S)
    {M : Sub (Term Sig B)} (hM : M ∈ langFormationOf Sig G B)
    {f : SortedMap (Term Sig A) (Term Sig B)}
    (hf : IsAlgHom Sig (termAlg Sig A).2 (termAlg Sig B).2 f)
    (hsurj : ∀ s, Function.Surjective (fun x => prAlg Sig (termAlg Sig B).2
      (congCogenerated Sig (termAlg Sig B) M)
      (congCogenerated_isCongruence Sig (termAlg Sig B) M) s (f s x))) :
    inverseImage f M ∈ langFormationOf Sig G A := by
  let g : SortedMap (Term Sig A) (quotAlg Sig (termAlg Sig B).2
      (congCogenerated Sig (termAlg Sig B) M)
      (congCogenerated_isCongruence Sig (termAlg Sig B) M)).1 :=
    fun s => (prAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
      (congCogenerated_isCongruence Sig (termAlg Sig B) M) s) ∘ (f s)
  have hg : IsAlgHom Sig (termAlg Sig A).2
      (quotAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
        (congCogenerated_isCongruence Sig (termAlg Sig B) M)).2 g := by
    intro p σ a
    show prAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
        (congCogenerated_isCongruence Sig (termAlg Sig B) M) p.2
          (f p.2 ((termAlg Sig A).2 p σ a)) =
      (quotAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
        (congCogenerated_isCongruence Sig (termAlg Sig B) M)).2 p σ
        (fun i => prAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
          (congCogenerated_isCongruence Sig (termAlg Sig B) M) (p.1.get i)
          (f (p.1.get i) (a i)))
    rw [hf p σ a]
    exact isAlgHom_prAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
      (congCogenerated_isCongruence Sig (termAlg Sig B) M) p σ
      (fun i => f (p.1.get i) (a i))
  refine langFormationOf_ker Sig hG A B M hM f hf hsurj (inverseImage f M) ?_
  have hker_le : sortedEqvLe (ker g)
      (congCogenerated Sig (termAlg Sig A) (inverseImage f M)) := by
    intro s x y hxy
    have hpb : (pullbackEqv f (congCogenerated Sig (termAlg Sig B) M) s).r x y := by
      change (congCogenerated Sig (termAlg Sig B) M s).r (f s x) (f s y)
      change Quotient.mk (congCogenerated Sig (termAlg Sig B) M s) (f s x) =
        Quotient.mk (congCogenerated Sig (termAlg Sig B) M s) (f s y) at hxy
      exact Quotient.exact hxy
    exact pullbackEqv_congCogenerated_le Sig hf M s x y hpb
  exact (isSat_iff_le_congCogenerated Sig (termAlg Sig A) (inverseImage f M)
    (ker_isCongruence Sig (termAlg Sig A).2
      (quotAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
        (congCogenerated_isCongruence Sig (termAlg Sig B) M)).2 g hg)).mpr hker_le

/-- `B-C008` (union): `L_𝔉(A)` is closed under binary union. -/
theorem langFormationOf_union {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S)
    {L L' : Sub (Term Sig A)}
    (hL : L ∈ langFormationOf Sig G A) (hL' : L' ∈ langFormationOf Sig G A) :
    (fun s => L s ∪ L' s) ∈ langFormationOf Sig G A := by
  obtain ⟨Φ, hΦG, hΦsat⟩ := (mem_langFormationOf_iff Sig hG A L).mp hL
  obtain ⟨Ψ, hΨG, hΨsat⟩ := (mem_langFormationOf_iff Sig hG A L').mp hL'
  refine (mem_langFormationOf_iff Sig hG A _).mpr
    ⟨sortedEqvInf Φ Ψ, (hG.1 A).2.2.1 Φ hΦG Ψ hΨG, ?_⟩
  exact isSat_union (sat_antitone (sortedEqvInf_le_left Φ Ψ) hΦsat)
    (sat_antitone (sortedEqvInf_le_right Φ Ψ) hΨsat)

/-- `B-C008` (intersection): `L_𝔉(A)` is closed under binary intersection. -/
theorem langFormationOf_inter {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S)
    {L L' : Sub (Term Sig A)}
    (hL : L ∈ langFormationOf Sig G A) (hL' : L' ∈ langFormationOf Sig G A) :
    (fun s => L s ∩ L' s) ∈ langFormationOf Sig G A := by
  obtain ⟨Φ, hΦG, hΦsat⟩ := (mem_langFormationOf_iff Sig hG A L).mp hL
  obtain ⟨Ψ, hΨG, hΨsat⟩ := (mem_langFormationOf_iff Sig hG A L').mp hL'
  refine (mem_langFormationOf_iff Sig hG A _).mpr
    ⟨sortedEqvInf Φ Ψ, (hG.1 A).2.2.1 Φ hΦG Ψ hΨG, ?_⟩
  exact isSat_inter (sat_antitone (sortedEqvInf_le_left Φ Ψ) hΦsat)
    (sat_antitone (sortedEqvInf_le_right Φ Ψ) hΨsat)

/-- `B-C008` (complement): `L_𝔉(A)` is closed under `∁_{T_Σ(A)}`. -/
theorem langFormationOf_compl {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S)
    {L : Sub (Term Sig A)} (hL : L ∈ langFormationOf Sig G A) :
    complA L ∈ langFormationOf Sig G A := by
  obtain ⟨Φ, hΦG, hΦsat⟩ := (mem_langFormationOf_iff Sig hG A L).mp hL
  exact (mem_langFormationOf_iff Sig hG A _).mpr ⟨Φ, hΦG, sat_compl Φ hΦsat⟩

/-- `B-C008` (bottom): `L_𝔉(A)` contains the empty language, so it is a Boolean
subalgebra of `Sub(T_Σ(A))` (not merely closed under ∪, ∩, ∁). -/
theorem langFormationOf_empty {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S) :
    (fun s => (∅ : Set (Term Sig A s))) ∈ langFormationOf Sig G A :=
  langFormationOf_nabla Sig hG A _ nabla_sat_empty

/-- `B-C008` (top): `L_𝔉(A)` contains the full language. -/
theorem langFormationOf_univ {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S) :
    (fun s => (Set.univ : Set (Term Sig A s))) ∈ langFormationOf Sig G A :=
  langFormationOf_nabla Sig hG A _ nabla_sat_univ

/-- `B-C009` (`CorolariAtoms`): the meet of two atoms `δ^{s,[P]_Φ}` and
`δ^{s,[P]_Ψ}` is the atom `δ^{s,[P]_{Φ∩Ψ}}`; if the two factors are in `L_𝔉(A)`
then so is the meet. -/
theorem langFormationOf_atom_inf {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) (A : SSet S)
    {Φ Ψ : SortedEqv (Term Sig A)} {s : S} {P : Term Sig A s}
    (hΦ : atomRep Φ s P ∈ langFormationOf Sig G A)
    (hΨ : atomRep Ψ s P ∈ langFormationOf Sig G A) :
    atomRep (sortedEqvInf Φ Ψ) s P ∈ langFormationOf Sig G A := by
  rw [atomRep_inf]
  exact langFormationOf_inter Sig hG A hΦ hΨ

/-! ### `B-P035` (forward direction): `Def1FRL ⇒ Def2FRL`. -/

/-- `B-P035` (`BPS 3`): a regular-language formation is closed under
complement. -/
theorem regularFormation_compl {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) (A : SSet S)
    {X : Sub (Term Sig A)} (hX : X ∈ L A) :
    complA X ∈ L A := by
  refine hL.2.2.1 A X X hX hX (complA X) ?_
  have hΦ : sortedEqvInf (congCogenerated Sig (termAlg Sig A) X)
      (congCogenerated Sig (termAlg Sig A) X) = congCogenerated Sig (termAlg Sig A) X :=
    sortedEqvLe_antisymm (fun _ _ _ h => h.1) (fun _ _ _ h => ⟨h, h⟩)
  rw [hΦ]
  exact sat_compl _ (isSat_congCogenerated Sig (termAlg Sig A) X)

/-- `B-P035` (`BPS 2`): a regular-language formation is closed under inverse
images of translations. -/
theorem regularFormation_transPreimage {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) (A : SSet S)
    {t s : S} {T : Term Sig A t → Term Sig A s}
    (hT : TlGen Sig (termAlg Sig A) t s T) {X : Sub (Term Sig A)} (hX : X ∈ L A) :
    transPreimage T X ∈ L A := by
  refine hL.2.2.1 A X X hX hX (transPreimage T X) ?_
  have hΦ : sortedEqvInf (congCogenerated Sig (termAlg Sig A) X)
      (congCogenerated Sig (termAlg Sig A) X) = congCogenerated Sig (termAlg Sig A) X :=
    sortedEqvLe_antisymm (fun _ _ _ h => h.1) (fun _ _ _ h => ⟨h, h⟩)
  rw [hΦ]
  exact (isSat_iff_le_congCogenerated Sig (termAlg Sig A) (transPreimage T X)
    (congCogenerated_isCongruence Sig (termAlg Sig A) X)).mpr
    (congCogenerated_le_transPreimage Sig (termAlg Sig A) hT X)

/-- `B-P035` (`BPS 4`): a regular-language formation is closed under inverse
images along `Ω(M)`-epimorphisms. -/
theorem regularFormation_inverseImage {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) (A B : SSet S)
    {M : Sub (Term Sig B)} (hM : M ∈ L B)
    {f : SortedMap (Term Sig A) (Term Sig B)}
    (hf : IsAlgHom Sig (termAlg Sig A).2 (termAlg Sig B).2 f)
    (hsurj : ∀ s, Function.Surjective (fun x => prAlg Sig (termAlg Sig B).2
      (congCogenerated Sig (termAlg Sig B) M)
      (congCogenerated_isCongruence Sig (termAlg Sig B) M) s (f s x))) :
    inverseImage f M ∈ L A := by
  let g : SortedMap (Term Sig A) (quotAlg Sig (termAlg Sig B).2
      (congCogenerated Sig (termAlg Sig B) M)
      (congCogenerated_isCongruence Sig (termAlg Sig B) M)).1 :=
    fun s => (prAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
      (congCogenerated_isCongruence Sig (termAlg Sig B) M) s) ∘ (f s)
  have hg : IsAlgHom Sig (termAlg Sig A).2
      (quotAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
        (congCogenerated_isCongruence Sig (termAlg Sig B) M)).2 g := by
    intro p σ a
    show prAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
        (congCogenerated_isCongruence Sig (termAlg Sig B) M) p.2
          (f p.2 ((termAlg Sig A).2 p σ a)) =
      (quotAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
        (congCogenerated_isCongruence Sig (termAlg Sig B) M)).2 p σ
        (fun i => prAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
          (congCogenerated_isCongruence Sig (termAlg Sig B) M) (p.1.get i)
          (f (p.1.get i) (a i)))
    rw [hf p σ a]
    exact isAlgHom_prAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
      (congCogenerated_isCongruence Sig (termAlg Sig B) M) p σ
      (fun i => f (p.1.get i) (a i))
  have hker_le : sortedEqvLe (ker g)
      (congCogenerated Sig (termAlg Sig A) (inverseImage f M)) := by
    intro s x y hxy
    have hpb : (pullbackEqv f (congCogenerated Sig (termAlg Sig B) M) s).r x y := by
      change (congCogenerated Sig (termAlg Sig B) M s).r (f s x) (f s y)
      change Quotient.mk (congCogenerated Sig (termAlg Sig B) M s) (f s x) =
        Quotient.mk (congCogenerated Sig (termAlg Sig B) M s) (f s y) at hxy
      exact Quotient.exact hxy
    exact pullbackEqv_congCogenerated_le Sig hf M s x y hpb
  exact hL.2.2.2 A B M hM f hf hsurj (inverseImage f M)
    ((isSat_iff_le_congCogenerated Sig (termAlg Sig A) (inverseImage f M)
      (ker_isCongruence Sig (termAlg Sig A).2
        (quotAlg Sig (termAlg Sig B).2 (congCogenerated Sig (termAlg Sig B) M)
          (congCogenerated_isCongruence Sig (termAlg Sig B) M)).2 g hg)).mpr hker_le)

/-- `B-P035` (forward direction): every regular-language formation in the sense
of `Def1FRL` (`IsRegularLanguageFormation`) is one in the sense of `Def2FRL`
(`IsBPSLanguageFormation`). `BPS 1` is the regularity clause, `BPS 2` the
`∇`-clause, `BPS 3` translation preimages (`B-P027`), `BPS 4` Boolean closure,
and `BPS 5` inverse images along `Ω(M)`-epimorphisms. -/
theorem isBPSLanguageFormation_of_isRegularLanguageFormation {S : Type u}
    (Sig : Signature S) {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsRegularLanguageFormation Sig L) :
    IsBPSLanguageFormation Sig L :=
  ⟨hL.1, hL.2.1,
   fun A _ hX _ _ _ hT => regularFormation_transPreimage Sig hL A hT hX,
   fun A X hX Y hY =>
     ⟨regularFormation_union Sig hL A X Y hX hY,
      regularFormation_inter Sig hL A X Y hX hY,
      regularFormation_compl Sig hL A hX⟩,
   fun A B _ hM _ hf hsurj => regularFormation_inverseImage Sig hL A B hM hf hsurj⟩

/-! ### `B-P035` (converse, infrastructure): finiteness and BPS closure. -/

/-- A finite-index congruence has only finitely many saturated componentwise
subsets: a saturated subset is determined by which `Φ`-classes it contains, and
`Σ(A/Φ)` is finite. This is the finiteness input for the `Def2 ⇒ Def1`
direction of `B-P035`. -/
theorem finite_satSets {S : Type u} {A : SSet S} (Φ : SortedEqv A)
    (h : IsFiniteIndex Φ) : Finite {N : Sub A // IsSat Φ N} := by
  classical
  haveI : Finite (Sigma (quot Φ)) := h
  haveI : Fintype (Sigma (quot Φ)) := Fintype.ofFinite _
  refine Finite.of_injective
    (fun N : {N : Sub A // IsSat Φ N} =>
      (fun q : Sigma (quot Φ) =>
        if (Quotient.out q.2 : A q.1) ∈ N.1 q.1 then true else false)) ?_
  intro N M hNM
  apply Subtype.ext
  funext t
  ext a
  have key : ∀ P : Sub A, IsSat Φ P →
      ((Quotient.out (Quotient.mk (Φ t) a) : A t) ∈ P t ↔ a ∈ P t) := by
    intro P hP
    constructor
    · intro hout
      rw [← hP]
      exact ⟨Quotient.out (Quotient.mk (Φ t) a), hout,
        Quotient.exact (Quotient.out_eq (Quotient.mk (Φ t) a))⟩
    · intro ha
      rw [← hP]
      exact ⟨a, ha,
        (Φ t).symm (Quotient.exact (Quotient.out_eq (Quotient.mk (Φ t) a)))⟩
  have hiff : ((Quotient.out (Quotient.mk (Φ t) a) : A t) ∈ N.1 t) ↔
      ((Quotient.out (Quotient.mk (Φ t) a) : A t) ∈ M.1 t) := by
    have h := congrFun hNM ⟨t, Quotient.mk (Φ t) a⟩
    simp only [] at h
    by_cases hp : (Quotient.out (Quotient.mk (Φ t) a) : A t) ∈ N.1 t
    · have hq : (Quotient.out (Quotient.mk (Φ t) a) : A t) ∈ M.1 t := by
        by_contra hq
        rw [if_pos hp, if_neg hq] at h
        exact Bool.noConfusion h
      exact ⟨fun _ => hq, fun _ => hp⟩
    · have hq : ¬ (Quotient.out (Quotient.mk (Φ t) a) : A t) ∈ M.1 t := by
        intro hq
        rw [if_neg hp, if_pos hq] at h
        exact Bool.noConfusion h
      exact ⟨fun hh => absurd hh hp, fun hh => absurd hh hq⟩
  rw [← key N.1 N.2, ← key M.1 M.2]
  exact hiff

/-- `B-P035` (`BPS 1`): a BPS-formation contains the empty language, which is
`∇`-saturated. -/
theorem bpsLanguageFormation_empty {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S) :
    (fun s => (∅ : Set (Term Sig A s))) ∈ L A :=
  hL.2.1 A _ nabla_sat_empty

/-- `B-P035` (`BPS 1`): a BPS-formation contains the full language. -/
theorem bpsLanguageFormation_univ {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S) :
    (fun s => (Set.univ : Set (Term Sig A s))) ∈ L A :=
  hL.2.1 A _ nabla_sat_univ

/-- `B-P035` (`BPS 4`, union). -/
theorem bpsLanguageFormation_union {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S)
    {X Y : Sub (Term Sig A)} (hX : X ∈ L A) (hY : Y ∈ L A) :
    (fun s => X s ∪ Y s) ∈ L A :=
  (hL.2.2.2.1 A X hX Y hY).1

/-- `B-P035` (`BPS 4`, intersection). -/
theorem bpsLanguageFormation_inter {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S)
    {X Y : Sub (Term Sig A)} (hX : X ∈ L A) (hY : Y ∈ L A) :
    (fun s => X s ∩ Y s) ∈ L A :=
  (hL.2.2.2.1 A X hX Y hY).2.1

/-- `B-P035` (`BPS 4`, complement). -/
theorem bpsLanguageFormation_compl {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S)
    {X : Sub (Term Sig A)} (hX : X ∈ L A) :
    complA X ∈ L A :=
  (hL.2.2.2.1 A X hX X hX).2.2

/-- `B-P035`: a BPS-formation is closed under finite unions (the `BPS 4`
Boolean closure by induction). -/
theorem bpsLanguageFormation_finset_biUnion {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S) {ι : Type u}
    [DecidableEq ι] (s : Finset ι) (f : ι → Sub (Term Sig A))
    (hf : ∀ i ∈ s, f i ∈ L A) :
    (fun u => ⋃ i ∈ s, f i u) ∈ L A := by
  classical
  revert hf
  induction s using Finset.induction_on with
  | empty =>
      intro _
      have h : (fun u => ⋃ i ∈ (∅ : Finset ι), f i u)
          = fun u => (∅ : Set (Term Sig A u)) := by
        funext u
        simp
      rw [h]
      exact bpsLanguageFormation_empty Sig hL A
  | insert a s ha ih =>
      intro hf
      have h : (fun u => ⋃ i ∈ insert a s, f i u)
          = fun u => f a u ∪ (⋃ i ∈ s, f i u) := by
        funext u
        rw [Finset.set_biUnion_insert]
      rw [h]
      exact bpsLanguageFormation_union Sig hL A
        (hf a (Finset.mem_insert_self a s))
        (ih (fun i hi => hf i (Finset.mem_insert_of_mem hi)))

/-- `B-P035`: a BPS-formation is closed under unions indexed by any finite type. -/
theorem bpsLanguageFormation_iUnion_finite {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S) {ι : Type u} [Finite ι]
    (f : ι → Sub (Term Sig A)) (hf : ∀ i, f i ∈ L A) :
    (fun s => ⋃ i, f i s) ∈ L A := by
  classical
  haveI : Fintype ι := Fintype.ofFinite ι
  have hEq : (fun s => ⋃ i, f i s)
      = fun s => ⋃ i ∈ (Finset.univ : Finset ι), f i s := by
    funext s
    rw [← Finset.set_biUnion_coe, Finset.coe_univ, Set.biUnion_univ]
  rw [hEq]
  exact bpsLanguageFormation_finset_biUnion Sig hL A Finset.univ f (fun i _ => hf i)

/-- `B-P035`: a BPS-formation is closed under finite intersections. -/
theorem bpsLanguageFormation_finset_biInter {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S) {ι : Type u}
    [DecidableEq ι] (s : Finset ι) (f : ι → Sub (Term Sig A))
    (hf : ∀ i ∈ s, f i ∈ L A) :
    (fun u => ⋂ i ∈ s, f i u) ∈ L A := by
  classical
  revert hf
  induction s using Finset.induction_on with
  | empty =>
      intro _
      have h : (fun u => ⋂ i ∈ (∅ : Finset ι), f i u)
          = fun u => (Set.univ : Set (Term Sig A u)) := by
        funext u
        simp
      rw [h]
      exact bpsLanguageFormation_univ Sig hL A
  | insert a s ha ih =>
      intro hf
      have h : (fun u => ⋂ i ∈ insert a s, f i u)
          = fun u => f a u ∩ (⋂ i ∈ s, f i u) := by
        funext u
        rw [Finset.set_biInter_insert]
      rw [h]
      exact bpsLanguageFormation_inter Sig hL A
        (hf a (Finset.mem_insert_self a s))
        (ih (fun i hi => hf i (Finset.mem_insert_of_mem hi)))

/-- `B-P035`: a BPS-formation is closed under intersections indexed by a finite
type. -/
theorem bpsLanguageFormation_iInter_finite {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S) {ι : Type u} [Finite ι]
    (f : ι → Sub (Term Sig A)) (hf : ∀ i, f i ∈ L A) :
    (fun s => ⋂ i, f i s) ∈ L A := by
  classical
  haveI : Fintype ι := Fintype.ofFinite ι
  have hEq : (fun s => ⋂ i, f i s)
      = fun s => ⋂ i ∈ (Finset.univ : Finset ι), f i s := by
    funext s
    rw [← Finset.set_biInter_coe, Finset.coe_univ, Set.biInter_univ]
  rw [hEq]
  exact bpsLanguageFormation_finset_biInter Sig hL A Finset.univ f (fun i _ => hf i)

/-! ### `B-P035` (converse): the atom claim `δ^{s,[a]_{Ω(X)}} ∈ L(A)`. -/

/-- `δ^{s,A_s}` is `∇`-saturated. -/
theorem isSat_nabla_deltaSub_univ {S : Type u} {A : SSet S} (s : S) :
    IsSat (nabla A) (deltaSub s (Set.univ : Set (A s))) := by
  classical
  unfold IsSat
  funext u
  by_cases hu : u = s
  · subst hu
    ext a
    constructor
    · intro _
      simpa only [deltaSub, Function.update_self] using
        (Set.mem_univ a : a ∈ (Set.univ : Set (A u)))
    · intro _
      exact ⟨a, by
        simpa only [deltaSub, Function.update_self] using
          (Set.mem_univ a : a ∈ (Set.univ : Set (A u))), trivial⟩
  · have hz : deltaSub s (Set.univ : Set (A s)) u = (∅ : Set (A u)) := by
      simp [deltaSub, Function.update_of_ne hu]
    rw [hz]
    simp [sat, hz]

/-- If `U` is `Φ`-saturated, so is any translation preimage `T⁻¹[U]`, because
`Ω(U) ⊆ Ω(T⁻¹[U])` (`B-P027`). -/
theorem isSat_transPreimage {S : Type u} (Sig : Signature S) (A : Alg Sig)
    {t s : S} {T : A.1 t → A.1 s} (hT : TlGen Sig A t s T)
    {Φ : SortedEqv A.1} (hΦ : IsCongruence Sig A.2 Φ) {U : Sub A.1}
    (hU : IsSat Φ U) : IsSat Φ (transPreimage T U) :=
  (isSat_iff_le_congCogenerated Sig A (transPreimage T U) hΦ).mpr
    (sortedEqvLe_trans ((isSat_iff_le_congCogenerated Sig A U hΦ).mp hU)
      (congCogenerated_le_transPreimage Sig A hT U))

/-- The concentrated `s`-component of a language of a BPS-formation is again a
language: `δ^{s,X_s} = X ∩ δ^{s,A_s}` with both factors in `L(A)`. -/
theorem bpsLanguageFormation_deltaSub {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S) {X : Sub (Term Sig A)}
    (hX : X ∈ L A) (s : S) : deltaSub s (X s) ∈ L A := by
  rw [deltaSub_eq_inter]
  exact bpsLanguageFormation_inter Sig hL A hX
    (hL.2.1 A _ (isSat_nabla_deltaSub_univ (A := Term Sig A) s))

/-- If `X` is `Φ`-saturated, so is its concentrated `s`-component. -/
theorem isSat_deltaSub_of_isSat {S : Type u} {A : SSet S} {Φ : SortedEqv A}
    {X : Sub A} (hX : IsSat Φ X) (s : S) : IsSat Φ (deltaSub s (X s)) := by
  rw [deltaSub_eq_inter]
  exact isSat_inter hX
    (sat_antitone (fun _ _ _ _ => trivial) (isSat_nabla_deltaSub_univ (A := A) s))

/-- `B-P035` (`BPS 3`): closure under translation preimages. -/
theorem bpsLanguageFormation_transPreimage {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S)
    {t s : S} {T : Term Sig A t → Term Sig A s}
    (hT : TlGen Sig (termAlg Sig A) t s T) {X : Sub (Term Sig A)} (hX : X ∈ L A) :
    transPreimage T X ∈ L A :=
  hL.2.2.1 A X hX t s T hT

/-- The `δ^{s,Y}` for `Y` in the B-P029 family `𝒳_{X,s,a}` are languages. -/
theorem cogClassSets_deltaSub_mem {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S)
    {X : Sub (Term Sig A)} (hX : X ∈ L A) (s : S) (a : Term Sig A s)
    {Y : Set (Term Sig A s)}
    (hY : Y ∈ cogClassSets Sig (termAlg Sig A) X s a) : deltaSub s Y ∈ L A := by
  obtain ⟨s', T, hT, hYeq, _⟩ := hY
  subst hYeq
  have hU : deltaSub s' (X s') ∈ L A := bpsLanguageFormation_deltaSub Sig hL A hX s'
  have htrans := bpsLanguageFormation_transPreimage Sig hL A hT hU
  have hss : (deltaSub s' (X s')) s' = X s' := by
    classical
    simp only [deltaSub, Function.update_self]
  convert htrans using 1
  unfold transPreimage
  exact (congrArg (fun Z => deltaSub s (T ⁻¹' Z)) hss).symm

/-- The `δ^{s,Y}` for `Y` in the B-P029 family `𝒳_{X,s,a}` are `Ω(X)`-saturated. -/
theorem cogClassSets_deltaSub_isSat {S : Type u} (Sig : Signature S)
    (A : SSet S) {X : Sub (Term Sig A)} (s : S) (a : Term Sig A s)
    {Y : Set (Term Sig A s)}
    (hY : Y ∈ cogClassSets Sig (termAlg Sig A) X s a) :
    IsSat (congCogenerated Sig (termAlg Sig A) X) (deltaSub s Y) := by
  obtain ⟨s', T, hT, hYeq, _⟩ := hY
  subst hYeq
  have hΦ : IsCongruence Sig (termAlg Sig A).2 (congCogenerated Sig (termAlg Sig A) X) :=
    congCogenerated_isCongruence Sig (termAlg Sig A) X
  have hU : IsSat (congCogenerated Sig (termAlg Sig A) X) (deltaSub s' (X s')) :=
    isSat_deltaSub_of_isSat (isSat_congCogenerated Sig (termAlg Sig A) X) s'
  have htrans := isSat_transPreimage Sig (termAlg Sig A) hT hΦ hU
  have hss : (deltaSub s' (X s')) s' = X s' := by
    classical
    simp only [deltaSub, Function.update_self]
  convert htrans using 1
  unfold transPreimage
  exact (congrArg (fun Z => deltaSub s (T ⁻¹' Z)) hss).symm

/-! ### `B-P035` (converse): the class atoms and the assembly. -/

/-- A `δ^{t,T⁻¹[X_s]}` coming from a translation preimage is a language of
`L(A)`. -/
theorem deltaSub_transPreimage_mem {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S)
    {X : Sub (Term Sig A)} (hX : X ∈ L A)
    {t s : S} {T : Term Sig A t → Term Sig A s}
    (hT : TlGen Sig (termAlg Sig A) t s T) :
    deltaSub t (T ⁻¹' (X s)) ∈ L A := by
  have h := bpsLanguageFormation_transPreimage Sig hL A hT hX
  simpa only [transPreimage] using h

/-- A `δ^{t,T⁻¹[X_s]}` coming from a translation preimage is `Ω(X)`-saturated. -/
theorem deltaSub_transPreimage_isSat {S : Type u} (Sig : Signature S) (A : Alg Sig)
    {X : Sub A.1} {t s : S} {T : A.1 t → A.1 s} (hT : TlGen Sig A t s T) :
    IsSat (congCogenerated Sig A X) (deltaSub t (T ⁻¹' (X s))) := by
  have hU : IsSat (congCogenerated Sig A X) (deltaSub s (X s)) :=
    isSat_deltaSub_of_isSat (isSat_congCogenerated Sig A X) s
  have htrans := isSat_transPreimage Sig A hT
    (congCogenerated_isCongruence Sig A X) hU
  convert htrans using 1
  unfold transPreimage
  rw [deltaSub_self]

/-- For a finite-index `Ω(X)`, any family of translation preimages of `X` (a
subset of `Sub(A_t)`) is finite, because `δ^{t,·}` injects it into the finitely
many `Ω(X)`-saturated subsets. -/
theorem covClass_finite {S : Type u} (Sig : Signature S) (A : Alg Sig)
    (X : Sub A.1) (hX : IsFiniteIndex (congCogenerated Sig A X)) (t : S)
    {P : Set (Set (A.1 t))}
    (hP : ∀ Y ∈ P, ∃ (s : S) (T : A.1 t → A.1 s),
      TlGen Sig A t s T ∧ Y = T ⁻¹' (X s)) :
    P.Finite := by
  classical
  haveI : Finite {N : Sub A.1 // IsSat (congCogenerated Sig A X) N} :=
    finite_satSets (congCogenerated Sig A X) hX
  refine Finite.of_injective
    (fun Y : P => (⟨deltaSub t Y.1, ?_⟩ :
      {N : Sub A.1 // IsSat (congCogenerated Sig A X) N})) ?_
  · obtain ⟨s, T, hT, hYeq⟩ := hP Y.1 Y.2
    rw [hYeq]
    exact deltaSub_transPreimage_isSat Sig A hT
  · intro Y Z h
    apply Subtype.ext
    have h2 := congrFun (congrArg Subtype.val h) t
    simpa only [deltaSub_self] using h2

/-- `cogClassSets` is finite when `Ω(X)` has finite index. -/
theorem cogClassSets_finite {S : Type u} (Sig : Signature S) (A : Alg Sig)
    (L : Sub A.1) (h : IsFiniteIndex (congCogenerated Sig A L)) (t : S) (a : A.1 t) :
    (cogClassSets Sig A L t a).Finite :=
  covClass_finite Sig A L h t (fun Y hY => by
    obtain ⟨s, T, hT, hYeq, _⟩ := hY
    exact ⟨s, T, hT, hYeq⟩)

/-- `cogClassSetsCompl` is finite when `Ω(X)` has finite index. -/
theorem cogClassSetsCompl_finite {S : Type u} (Sig : Signature S) (A : Alg Sig)
    (L : Sub A.1) (h : IsFiniteIndex (congCogenerated Sig A L)) (t : S) (a : A.1 t) :
    (cogClassSetsCompl Sig A L t a).Finite :=
  covClass_finite Sig A L h t (fun Y hY => by
    obtain ⟨s, T, hT, hYeq, _⟩ := hY
    exact ⟨s, T, hT, hYeq⟩)

/-- A finite intersection of `δ^{t,·}` of languages is a language. -/
theorem bpsLanguageFormation_sInter {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S) {t : S}
    {𝒳 : Set (Set (Term Sig A t))} (hfin : 𝒳.Finite)
    (hmem : ∀ Y ∈ 𝒳, deltaSub t Y ∈ L A) :
    deltaSub t (⋂₀ 𝒳) ∈ L A := by
  classical
  by_cases hne : 𝒳.Nonempty
  · haveI : Finite 𝒳 := hfin
    have key := bpsLanguageFormation_iInter_finite Sig hL A
      (fun Y : 𝒳 => deltaSub t Y.1) (fun Y => hmem Y.1 Y.2)
    have heq : deltaSub t (⋂₀ 𝒳) = fun u => ⋂ Y : 𝒳, deltaSub t Y.1 u := by
      rw [deltaSub_iInter t 𝒳 hne]
      funext u
      rw [Set.sInter_image, Set.biInter_eq_iInter]
    rw [heq]
    exact key
  · rw [Set.not_nonempty_iff_eq_empty.mp hne, Set.sInter_empty]
    exact hL.2.1 A _ (isSat_nabla_deltaSub_univ (A := Term Sig A) t)

/-- A finite union of `δ^{t,·}` of languages is a language. -/
theorem bpsLanguageFormation_sUnion {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S) {t : S}
    {𝒳 : Set (Set (Term Sig A t))} (hfin : 𝒳.Finite)
    (hmem : ∀ Y ∈ 𝒳, deltaSub t Y ∈ L A) :
    deltaSub t (⋃₀ 𝒳) ∈ L A := by
  classical
  haveI : Finite 𝒳 := hfin
  have key := bpsLanguageFormation_iUnion_finite Sig hL A
    (fun Y : 𝒳 => deltaSub t Y.1) (fun Y => hmem Y.1 Y.2)
  have heq : deltaSub t (⋃₀ 𝒳) = fun u => ⋃ Y : 𝒳, deltaSub t Y.1 u := by
    rw [deltaSub_sUnion t 𝒳]
    funext u
    rw [Set.sUnion_image, Set.biUnion_eq_iUnion]
  rw [heq]
  exact key

/-- `B-P035` (converse atom claim): if `X ∈ L(A)`, then the concentrated class
`δ^{t,[P]_{Ω(X)_t}}` is a language of `L(A)`. The class is written by `B-P029`
as an intersection-minus-union of translation preimages; the family is finite
because `Ω(X)` has finite index, and BPS Boolean closure concludes. -/
theorem atom_deltaSub_mem {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S)
    {X : Sub (Term Sig A)} (hX : X ∈ L A) (t : S) (P : Term Sig A t) :
    deltaSub t (eqvClass (congCogenerated Sig (termAlg Sig A) X) t P) ∈ L A := by
  classical
  have hfinidx : IsFiniteIndex (congCogenerated Sig (termAlg Sig A) X) := hL.1 A hX
  have hfinA : (cogClassSets Sig (termAlg Sig A) X t P).Finite :=
    cogClassSets_finite Sig (termAlg Sig A) X hfinidx t P
  have hfinB : (cogClassSetsCompl Sig (termAlg Sig A) X t P).Finite :=
    cogClassSetsCompl_finite Sig (termAlg Sig A) X hfinidx t P
  have hI : deltaSub t (⋂₀ cogClassSets Sig (termAlg Sig A) X t P) ∈ L A :=
    bpsLanguageFormation_sInter Sig hL A hfinA (fun Y hY => by
      obtain ⟨s, T, hT, hYeq, _⟩ := hY
      subst hYeq
      exact deltaSub_transPreimage_mem Sig hL A hX hT)
  have hU : deltaSub t (⋃₀ cogClassSetsCompl Sig (termAlg Sig A) X t P) ∈ L A :=
    bpsLanguageFormation_sUnion Sig hL A hfinB (fun Y hY => by
      obtain ⟨s, T, hT, hYeq, _⟩ := hY
      subst hYeq
      exact deltaSub_transPreimage_mem Sig hL A hX hT)
  have hc := bpsLanguageFormation_inter Sig hL A hI
    (bpsLanguageFormation_compl Sig hL A hU)
  have hgoal : deltaSub t (⋂₀ cogClassSets Sig (termAlg Sig A) X t P
        \ ⋃₀ cogClassSetsCompl Sig (termAlg Sig A) X t P)
      = fun u => deltaSub t (⋂₀ cogClassSets Sig (termAlg Sig A) X t P) u
          ∩ complA (deltaSub t (⋃₀ cogClassSetsCompl Sig (termAlg Sig A) X t P)) u := by
    rw [deltaSub_sdiff]
    funext u
    ext x
    simp [complA, Set.sdiff_eq]
  rw [eqvClass_congCogenerated Sig (termAlg Sig A) X t P, hgoal]
  exact hc

/-- `B-P035` (converse, `Def1FRL` clause 2): if `X, Y ∈ L(A)` and `N` is
`(Ω(X) ∩ Ω(Y))`-saturated, then `N ∈ L(A)`. `N` is a finite union of `Φ`-classes
over the finite quotient `T_Σ(A)/Φ`; each class atom is a language by
`atom_deltaSub_mem`. -/
theorem bps_sat_inf_mem {S : Type u} (Sig : Signature S)
    {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) (A : SSet S)
    {X Y : Sub (Term Sig A)} (hX : X ∈ L A) (hY : Y ∈ L A) {N : Sub (Term Sig A)}
    (hN : IsSat (sortedEqvInf (congCogenerated Sig (termAlg Sig A) X)
      (congCogenerated Sig (termAlg Sig A) Y)) N) : N ∈ L A := by
  classical
  set Φ : SortedEqv (Term Sig A) := sortedEqvInf (congCogenerated Sig (termAlg Sig A) X)
    (congCogenerated Sig (termAlg Sig A) Y) with hΦdef
  have hΦfin : IsFiniteIndex Φ := by
    rw [hΦdef]
    exact IsFiniteIndex_inf (hL.1 A hX) (hL.1 A hY)
  haveI : Finite (Sigma (fun u => Quotient (Φ u))) := hΦfin
  have hNmem : ∀ {u : S} {a b : Term Sig A u}, (Φ u).r a b → a ∈ N u → b ∈ N u := by
    intro u a b hab ha
    have hb : b ∈ sat Φ N u := ⟨a, ha, hab⟩
    rw [hΦdef] at hb
    rwa [hN] at hb
  have hdecomp : N = fun u => ⋃ p : Sigma (fun u => Quotient (Φ u)),
      deltaSub p.1 (if (Quotient.out p.2 : Term Sig A p.1) ∈ N p.1
        then eqvClass Φ p.1 (Quotient.out p.2) else ∅) u := by
    funext u
    ext a
    constructor
    · intro ha
      refine Set.mem_iUnion.mpr ⟨⟨u, Quotient.mk (Φ u) a⟩, ?_⟩
      have hout : (Quotient.out (Quotient.mk (Φ u) a) : Term Sig A u) ∈ N u :=
        hNmem ((Φ u).symm (Quotient.exact (Quotient.out_eq (Quotient.mk (Φ u) a)))) ha
      have hrel : a ∈ eqvClass Φ u (Quotient.out (Quotient.mk (Φ u) a)) :=
        Quotient.exact (Quotient.out_eq (Quotient.mk (Φ u) a))
      simp only [hout, if_true, deltaSub_self]
      exact hrel
    · intro ha
      rcases Set.mem_iUnion.mp ha with ⟨p, hp⟩
      by_cases hpN : (Quotient.out p.2 : Term Sig A p.1) ∈ N p.1
      · simp only [hpN, if_true] at hp
        by_cases hup : u = p.1
        · subst hup
          rw [deltaSub_self] at hp
          exact hNmem hp hpN
        · rw [deltaSub_of_ne hup] at hp
          exact absurd hp (by simp)
      · simp only [hpN, if_false] at hp
        rw [deltaSub_empty] at hp
        simp at hp
  rw [hdecomp]
  apply bpsLanguageFormation_iUnion_finite Sig hL A
  intro p
  by_cases hpN : (Quotient.out p.2 : Term Sig A p.1) ∈ N p.1
  · simp only [hpN, if_true]
    have hclass : eqvClass Φ p.1 (Quotient.out p.2)
        = eqvClass (congCogenerated Sig (termAlg Sig A) X) p.1 (Quotient.out p.2)
          ∩ eqvClass (congCogenerated Sig (termAlg Sig A) Y) p.1 (Quotient.out p.2) :=
      eqvClass_sortedEqvInf _ _ _ _
    rw [hclass, deltaSub_inter]
    exact bpsLanguageFormation_inter Sig hL A
      (atom_deltaSub_mem Sig hL A hX p.1 (Quotient.out p.2))
      (atom_deltaSub_mem Sig hL A hY p.1 (Quotient.out p.2))
  · simp only [hpN, if_false, deltaSub_empty]
    exact bpsLanguageFormation_empty Sig hL A

/-- `B-P035`: the two definitions of a formation of regular languages
(`Def1FRL` and `Def2FRL`) are equivalent; this is the converse direction
`Def2FRL ⇒ Def1FRL`. Clause 2 is `bps_sat_inf_mem`; clause 3 reduces the kernel
closure to that by saturating the direct image of the saturated language. -/
theorem isRegularLanguageFormation_of_isBPSLanguageFormation {S : Type u}
    (Sig : Signature S) {L : (A : SSet S) → Set (Sub (Term Sig A))}
    (hL : IsBPSLanguageFormation Sig L) :
    IsRegularLanguageFormation Sig L := by
  classical
  refine ⟨hL.1, hL.2.1,
    fun A X Y hX hY N hN => bps_sat_inf_mem Sig hL A hX hY hN, ?_⟩
  intro A B M hM f hf hsurj N hN
  set ΩM := congCogenerated Sig (termAlg Sig B) M with hΩM
  let N' : Sub (Term Sig B) := sat ΩM (fun s => f s '' (N s))
  have hN'sat : IsSat ΩM N' := by
    show sat ΩM N' = N'
    exact sat_idem ΩM (fun s => f s '' (N s))
  have hN'mem : N' ∈ L B :=
    bps_sat_inf_mem Sig hL B hM hM (by rw [sortedEqvInf_self]; exact hN'sat)
  have hker_eq : ker (fun s => prAlg Sig (termAlg Sig B).2 ΩM
        (congCogenerated_isCongruence Sig (termAlg Sig B) M) s ∘ f s)
      = pullbackEqv f ΩM := by
    funext s
    apply Setoid.ext
    intro x y
    change (Quotient.mk (ΩM s) (f s x) = Quotient.mk (ΩM s) (f s y))
      ↔ (ΩM s).r (f s x) (f s y)
    exact ⟨fun h => Quotient.exact h, fun h => Quotient.sound h⟩
  have hNsat : ∀ {u : S} {b a : Term Sig A u},
      (ker (fun s => prAlg Sig (termAlg Sig B).2 ΩM
        (congCogenerated_isCongruence Sig (termAlg Sig B) M) s ∘ f s) u).r b a →
      b ∈ N u → a ∈ N u := by
    intro u b a hba hb
    have ha : a ∈ sat (ker (fun s => prAlg Sig (termAlg Sig B).2 ΩM
        (congCogenerated_isCongruence Sig (termAlg Sig B) M) s ∘ f s)) N u :=
      ⟨b, hb, hba⟩
    rwa [hN] at ha
  have hN'eq : inverseImage f N' = N := by
    funext u
    ext a
    constructor
    · intro ha
      rcases ha with ⟨c, hc, hca⟩
      rcases hc with ⟨b, hb, hbc⟩
      have hpb : (ΩM u).r (f u b) (f u a) := hbc ▸ hca
      have hkerrel : (ker (fun s => prAlg Sig (termAlg Sig B).2 ΩM
          (congCogenerated_isCongruence Sig (termAlg Sig B) M) s ∘ f s) u).r b a := by
        rw [hker_eq]
        exact hpb
      exact hNsat hkerrel hb
    · intro ha
      exact ⟨f u a, ⟨a, ha, rfl⟩, (ΩM u).refl (f u a)⟩
  have hsurj' : ∀ s, Function.Surjective (fun x => prAlg Sig (termAlg Sig B).2
        (congCogenerated Sig (termAlg Sig B) N')
        (congCogenerated_isCongruence Sig (termAlg Sig B) N') s (f s x)) := by
    have hle : sortedEqvLe ΩM (congCogenerated Sig (termAlg Sig B) N') :=
      (isSat_iff_le_congCogenerated Sig (termAlg Sig B) N'
        (congCogenerated_isCongruence Sig (termAlg Sig B) M)).mp hN'sat
    intro s y
    induction y using Quotient.inductionOn with
    | _ b =>
      obtain ⟨x, hx⟩ := hsurj s (Quotient.mk (ΩM s) b)
      exact ⟨x, Quotient.sound (hle s (f s x) b (Quotient.exact hx))⟩
  have hfin := hL.2.2.2.2 A B N' hN'mem f hf hsurj'
  rwa [hN'eq] at hfin

end Mslang
