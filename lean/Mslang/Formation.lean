import Mslang.Free

/-!
The formation-theoretic layer: subdirect products (`B-D028`), filters of a
lattice (`B-D029`), and formations of `Σ`-congruences (`B-D030`).
-/

universe u

namespace Mslang

variable {S : Type u}

/-! ### `B-D029`: filters of a lattice. -/

/-- `B-D029`: a *filter* of a lattice `L` is a nonempty up-set closed under
meets: `F ≠ ∅`, `x ⊓ y ∈ F` for `x, y ∈ F`, and `y ∈ F` whenever `x ∈ F` and
`x ≤ y`. -/
def IsLatticeFilter {L : Type u} [Lattice L] (F : Set L) : Prop :=
  F.Nonempty ∧
    (∀ x ∈ F, ∀ y ∈ F, x ⊓ y ∈ F) ∧
    (∀ x ∈ F, ∀ y : L, x ≤ y → y ∈ F)

/-- `B-D029`: `Filt(L)`, the set of all filters of the lattice `L`. -/
def latticeFilters (L : Type u) [Lattice L] : Set (Set L) :=
  {F | IsLatticeFilter F}

/-! ### `B-D028`: subdirect products and embeddings. -/

/-- `B-D028` (preliminary, Section 5): a monomorphism of `Σ`-algebras is an
injective homomorphism. -/
def IsMonoAlg {S : Type u} (Sig : Signature S) {A B : SSet S}
    (FA : AlgStruct Sig A) (FB : AlgStruct Sig B) (f : SortedMap A B) : Prop :=
  IsAlgHom Sig FA FB f ∧ ∀ s, Function.Injective (f s)

/-- `B-D028` (preliminary): an epimorphism of `Σ`-algebras is a surjective
homomorphism. -/
def IsEpiAlg {S : Type u} (Sig : Signature S) {A B : SSet S}
    (FA : AlgStruct Sig A) (FB : AlgStruct Sig B) (f : SortedMap A B) : Prop :=
  IsAlgHom Sig FA FB f ∧ ∀ s, Function.Surjective (f s)

/-- `B-D028`: a *subdirect embedding* `f : A → ∏_i A^i` is an injective
homomorphism whose composite with every canonical projection `pr^i` is
surjective. -/
def IsSubdirectEmbedding {S : Type u} (Sig : Signature S) {A : SSet S}
    (FA : AlgStruct Sig A) {ι : Type u} (Ai : ι → Alg Sig)
    (f : SortedMap A (iAlg Sig Ai).1) : Prop :=
  IsMonoAlg Sig FA (iAlg Sig Ai).2 f ∧
    ∀ i : ι, ∀ s : S, Function.Surjective (fun a : A s => f s a i)

/-- `B-D028`: `A` is a *subdirect product* of a family `(A^i)` when it admits a
subdirect embedding into `∏_i A^i` (equivalently, in the paper's first
formulation, it is a subalgebra of the product over which every projection is
surjective). -/
def IsSubdirectProduct {S : Type u} (Sig : Signature S) (A : Alg Sig)
    {ι : Type u} (Ai : ι → Alg Sig) : Prop :=
  ∃ f : SortedMap A.1 (iAlg Sig Ai).1, IsSubdirectEmbedding Sig A.2 Ai f

/-- `B-D028`: two subdirect embeddings `f : A → ∏_i A^i` and `g : A → ∏_i B^i`
are *isomorphic* when a family of isomorphisms of the factors intertwines them:
`h^i ∘ pr^{A^i} ∘ f = pr^{B^i} ∘ g` for every `i`. -/
def IsomorphicSubdirectEmbeddings {S : Type u} (Sig : Signature S) {A : SSet S}
    {ι : Type u} {Ai Bi : ι → Alg Sig}
    (f : SortedMap A (iAlg Sig Ai).1) (g : SortedMap A (iAlg Sig Bi).1) : Prop :=
  ∃ h : ∀ i, SortedMap (Ai i).1 (Bi i).1,
    (∀ i, IsAlgIso Sig (Ai i).2 (Bi i).2 (h i)) ∧
      ∀ (i : ι) (s : S) (a : A s), h i s (f s a i) = g s a i

/-! ### `B-D030`: formations of `Σ`-congruences. -/

/-- `B-D030`: a *formation of congruences* with respect to `Σ` is a choice
function `F` sending each `S`-sorted set `A` to a filter of the congruence
lattice `Cgr(T_Σ(A))` (nonempty, a set of congruences, closed under pointwise
meet, and up-closed under refinement) that is closed under the pullback of
kernels along `Θ`-epimorphisms: for every `Θ ∈ F(B)` and every homomorphism
`f : T_Σ(A) → T_Σ(B)` whose composite with the projection `pr^Θ` is surjective,
the kernel `Ker(pr^Θ ∘ f)` lies in `F(A)`. -/
def IsCongruenceFormation {S : Type u} (Sig : Signature S)
    (F : (A : SSet S) → Set (SortedEqv (TAlg Sig A).1)) : Prop :=
  (∀ A : SSet S,
      (F A).Nonempty ∧
      (∀ Φ ∈ F A, IsCongruence Sig (TAlg Sig A).2 Φ) ∧
      (∀ Φ ∈ F A, ∀ Ψ ∈ F A, sortedEqvInf Φ Ψ ∈ F A) ∧
      (∀ Φ ∈ F A, ∀ Ψ : SortedEqv (TAlg Sig A).1,
        IsCongruence Sig (TAlg Sig A).2 Ψ → sortedEqvLe Φ Ψ → Ψ ∈ F A)) ∧
  (∀ (A B : SSet S) (Θ : SortedEqv (TAlg Sig B).1)
      (hΘ : IsCongruence Sig (TAlg Sig B).2 Θ),
      Θ ∈ F B →
      ∀ f : SortedMap (TAlg Sig A).1 (TAlg Sig B).1,
        IsAlgHom Sig (TAlg Sig A).2 (TAlg Sig B).2 f →
        (∀ s : S, Function.Surjective
          (fun x => prAlg Sig (TAlg Sig B).2 Θ hΘ s (f s x))) →
        ker (fun s => prAlg Sig (TAlg Sig B).2 Θ hΘ s ∘ f s) ∈ F A)

/-! ### `B-D031`: the operators `H` and `P_fsd`. -/

/-- `B-D031`: `H(F)`, the homomorphic images of the members of `F`: the
`Σ`-algebras `A` admitting an epimorphism `B → A` from some `B ∈ F`. -/
def HOperator {S : Type u} (Sig : Signature S) (F : Set (Alg Sig)) : Set (Alg Sig) :=
  {A | ∃ B ∈ F, ∃ f : SortedMap B.1 A.1, IsEpiAlg Sig B.2 A.2 f}

/-- `B-D031`: `P_fsd(F)`, the finite subdirect products of members of `F`: the
`Σ`-algebras `A` admitting a subdirect embedding into `∏_{α∈n} C^α` for some
`n : ℕ` and family `(C^α) ∈ F^n`. -/
def PFsdOperator {S : Type u} (Sig : Signature S) (F : Set (Alg Sig)) : Set (Alg Sig) :=
  {A | ∃ (ι : Type u) (_ : Fintype ι) (C : ι → Alg Sig), (∀ i, C i ∈ F) ∧
      ∃ f : SortedMap A.1 (iAlg Sig C).1, IsSubdirectEmbedding Sig A.2 C f}

/-! ### `B-D032`: formations of `Σ`-algebras. -/

/-- `B-D032`: a *formation of `Σ`-algebras* is a set `F` of `Σ`-algebras closed
under homomorphic images (`H(F) ⊆ F`) and under finite subdirect products
(`P_fsd(F) ⊆ F`). -/
def IsAlgebraFormation {S : Type u} (Sig : Signature S) (F : Set (Alg Sig)) : Prop :=
  HOperator Sig F ⊆ F ∧ PFsdOperator Sig F ⊆ F

/-- `B-D032`: `Form_Alg(Σ)`, the set of all formations of `Σ`-algebras. -/
def algebraFormations {S : Type u} (Sig : Signature S) : Set (Set (Alg Sig)) :=
  {F | IsAlgebraFormation Sig F}

/-! ### `B-D033`: ShSk-formations of `Σ`-algebras. -/

/-- The pointwise meet `Φ ⊓ Ψ` of two congruences is a congruence. -/
theorem IsCongruence_inf {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) {Φ Ψ : SortedEqv A}
    (hΦ : IsCongruence Sig F Φ) (hΨ : IsCongruence Sig F Ψ) :
    IsCongruence Sig F (sortedEqvInf Φ Ψ) := by
  intro p σ a b h
  exact ⟨hΦ p σ a b (fun i => (h i).1), hΨ p σ a b (fun i => (h i).2)⟩

/-- `B-D033`: an *ShSk-formation* of `Σ`-algebras is a nonempty set `F` of
`Σ`-algebras closed under homomorphic images and under the meet of congruences:
if `A/Φ` and `A/Ψ` lie in `F` then so does `A/(Φ ⊓ Ψ)`. -/
def IsShSkFormation {S : Type u} (Sig : Signature S) (F : Set (Alg Sig)) : Prop :=
  F.Nonempty ∧
  HOperator Sig F ⊆ F ∧
  (∀ (A : Alg Sig) (Φ Ψ : SortedEqv A.1)
      (hΦ : IsCongruence Sig A.2 Φ) (hΨ : IsCongruence Sig A.2 Ψ),
      quotAlg Sig A.2 Φ hΦ ∈ F → quotAlg Sig A.2 Ψ hΨ ∈ F →
      quotAlg Sig A.2 (sortedEqvInf Φ Ψ) (IsCongruence_inf Sig A.2 hΦ hΨ) ∈ F)

/-! ### `B-R014`: consequences of the formation axioms. -/

/-- `B-R014`(1): if `F` is closed under homomorphic images, it is *abstract*:
any algebra isomorphic to a member is again a member. (A bijective homomorphism
is in particular an epimorphism.) -/
theorem formation_abstract {S : Type u} (Sig : Signature S) {F : Set (Alg Sig)}
    (hH : HOperator Sig F ⊆ F) {A B : Alg Sig} (hA : A ∈ F)
    (f : SortedMap A.1 B.1) (hf : IsAlgIso Sig A.2 B.2 f) : B ∈ F :=
  hH ⟨A, hA, f, ⟨hf.1, fun s => (hf.2 s).2⟩⟩

/-- `B-R014`(2): if `F` is closed under finite subdirect products then `F` is
nonempty, because the empty product (`n = 0`) is the final algebra `1`, which
is its own subdirect product. -/
theorem formation_nonempty {S : Type u} (Sig : Signature S) {F : Set (Alg Sig)}
    (hP : PFsdOperator Sig F ⊆ F) : F.Nonempty := by
  classical
  let C : PEmpty.{u+1} → Alg Sig := fun i => i.elim
  have hmem : iAlg (ι := PEmpty.{u+1}) Sig C ∈ PFsdOperator Sig F := by
    refine ⟨PEmpty.{u+1}, inferInstance, C, ?_⟩
    refine ⟨fun i => i.elim, ?_⟩
    refine ⟨(fun _ a => a), ?_⟩
    exact ⟨⟨fun _ _ _ => rfl, fun _ _ _ h => h⟩, fun i => i.elim⟩
  exact ⟨iAlg (ι := PEmpty.{u+1}) Sig C, hP hmem⟩

/-! ### `B-P016`: a formation satisfies the `B-D033` intersection closure. -/

theorem formation_congInf {S : Type u} (Sig : Signature S) {F : Set (Alg Sig)}
    (hF : IsAlgebraFormation Sig F) (A : Alg Sig)
    (Φ Ψ : SortedEqv A.1) (hΦ : IsCongruence Sig A.2 Φ) (hΨ : IsCongruence Sig A.2 Ψ)
    (hΦF : quotAlg Sig A.2 Φ hΦ ∈ F) (hΨF : quotAlg Sig A.2 Ψ hΨ ∈ F) :
    quotAlg Sig A.2 (sortedEqvInf Φ Ψ) (IsCongruence_inf Sig A.2 hΦ hΨ) ∈ F := by
  classical
  let hInf := IsCongruence_inf Sig A.2 hΦ hΨ
  have hleΦ : sortedEqvLe (sortedEqvInf Φ Ψ) (ker (prAlg Sig A.2 Φ hΦ)) := by
    rw [ker_prAlg Sig A.2 Φ hΦ]; exact sortedEqvInf_le_left Φ Ψ
  have hleΨ : sortedEqvLe (sortedEqvInf Φ Ψ) (ker (prAlg Sig A.2 Ψ hΨ)) := by
    rw [ker_prAlg Sig A.2 Ψ hΨ]; exact sortedEqvInf_le_right Φ Ψ
  let Qinf := quotAlg Sig A.2 (sortedEqvInf Φ Ψ) hInf
  let QΦ := quotAlg Sig A.2 Φ hΦ
  let QΨ := quotAlg Sig A.2 Ψ hΨ
  let pΦ : SortedMap Qinf.1 QΦ.1 := quotLift (sortedEqvInf Φ Ψ) (prAlg Sig A.2 Φ hΦ) hleΦ
  let pΨ : SortedMap Qinf.1 QΨ.1 := quotLift (sortedEqvInf Φ Ψ) (prAlg Sig A.2 Ψ hΨ) hleΨ
  have hcompΦ : ∀ (s : S) (a : A.1 s),
      pΦ s (Quotient.mk ((sortedEqvInf Φ Ψ) s) a) = Quotient.mk (Φ s) a := by
    intro s a
    have h := congrFun (congrFun (quotLift_comp (sortedEqvInf Φ Ψ) (prAlg Sig A.2 Φ hΦ) hleΦ) s) a
    simpa [pΦ, prAlg, pr, Function.comp] using h
  have hcompΨ : ∀ (s : S) (a : A.1 s),
      pΨ s (Quotient.mk ((sortedEqvInf Φ Ψ) s) a) = Quotient.mk (Ψ s) a := by
    intro s a
    have h := congrFun (congrFun (quotLift_comp (sortedEqvInf Φ Ψ) (prAlg Sig A.2 Ψ hΨ) hleΨ) s) a
    simpa [pΨ, prAlg, pr, Function.comp] using h
  let B2 := ULift.{u, 0} Bool
  let C : B2 → Alg Sig := fun b => Bool.rec QΦ QΨ b.down
  let g : ∀ b : B2, SortedMap Qinf.1 (C b).1 := by
    rintro ⟨bb⟩
    cases bb
    · exact pΦ
    · exact pΨ
  have hgHom : ∀ b : B2, IsAlgHom Sig Qinf.2 (C b).2 (g b) := by
    rintro ⟨bb⟩
    cases bb
    · exact quotAlgLift_isAlgHom Sig A.2 QΦ.2 (sortedEqvInf Φ Ψ) hInf
        (prAlg Sig A.2 Φ hΦ) (isAlgHom_prAlg Sig A.2 Φ hΦ) hleΦ
    · exact quotAlgLift_isAlgHom Sig A.2 QΨ.2 (sortedEqvInf Φ Ψ) hInf
        (prAlg Sig A.2 Ψ hΨ) (isAlgHom_prAlg Sig A.2 Ψ hΨ) hleΨ
  let f : SortedMap Qinf.1 (iAlg (ι := B2) Sig C).1 := iPairAlg Sig C g
  apply hF.2
  refine ⟨B2, inferInstance, C, ?_, ?_⟩
  · rintro ⟨bb⟩
    cases bb
    · exact hΦF
    · exact hΨF
  · refine ⟨f, ?_⟩
    refine ⟨⟨?_, ?_⟩, ?_⟩
    · exact isAlgHom_iPairAlg Sig Qinf.2 g hgHom
    · intro s x y hxy
      have hf : pΦ s x = pΦ s y := congrFun hxy ⟨false⟩
      have ht : pΨ s x = pΨ s y := congrFun hxy ⟨true⟩
      induction x using Quotient.inductionOn with
      | _ a =>
        induction y using Quotient.inductionOn with
        | _ b =>
          have hΦab : (Φ s).r a b := by
            have h := hf
            rw [show pΦ s (Quotient.mk ((sortedEqvInf Φ Ψ) s) a) = Quotient.mk (Φ s) a from hcompΦ s a,
                show pΦ s (Quotient.mk ((sortedEqvInf Φ Ψ) s) b) = Quotient.mk (Φ s) b from hcompΦ s b] at h
            exact Quotient.exact h
          have hΨab : (Ψ s).r a b := by
            have h := ht
            rw [show pΨ s (Quotient.mk ((sortedEqvInf Φ Ψ) s) a) = Quotient.mk (Ψ s) a from hcompΨ s a,
                show pΨ s (Quotient.mk ((sortedEqvInf Φ Ψ) s) b) = Quotient.mk (Ψ s) b from hcompΨ s b] at h
            exact Quotient.exact h
          exact Quotient.sound (show (Φ s).r a b ∧ (Ψ s).r a b from ⟨hΦab, hΨab⟩)
    · rintro ⟨bb⟩ s y
      cases bb
      · induction y using Quotient.inductionOn with
        | _ a =>
          refine ⟨Quotient.mk ((sortedEqvInf Φ Ψ) s) a, ?_⟩
          change pΦ s (Quotient.mk ((sortedEqvInf Φ Ψ) s) a) = Quotient.mk (Φ s) a
          exact hcompΦ s a
      · induction y using Quotient.inductionOn with
        | _ a =>
          refine ⟨Quotient.mk ((sortedEqvInf Φ Ψ) s) a, ?_⟩
          change pΨ s (Quotient.mk ((sortedEqvInf Φ Ψ) s) a) = Quotient.mk (Ψ s) a
          exact hcompΨ s a

/-! ### `B-R017`: subfinal algebras lie in every formation. -/

/-- `B-R017`: for the empty family (`n = 0`) the product is the final algebra
`1`, so every subfinal `Σ`-algebra — being isomorphic to a subalgebra of `1` —
admits a subdirect embedding into an empty product, hence lies in every
formation (`P_fsd`-closure). -/
theorem subfinalAlg_mem_of_formation {S : Type u} (Sig : Signature S) {F : Set (Alg Sig)}
    (hF : IsAlgebraFormation Sig F) {A : Alg Sig} (hA : SubfinalAlg Sig A) : A ∈ F := by
  apply hF.2
  let C : PEmpty.{u+1} → Alg Sig := fun i => i.elim
  refine ⟨PEmpty.{u+1}, inferInstance, C, ?_, ?_⟩
  · intro i; exact i.elim
  · refine ⟨(fun _s _a i => i.elim), ?_⟩
    have hSub : Subfinal A.1 := (subfinalAlg_iff Sig A).1 hA
    refine ⟨⟨?_, ?_⟩, ?_⟩
    · intro p σ a
      funext i
      exact i.elim
    · intro s x y _
      exact @Subsingleton.elim (A.1 s) (hSub s) x y
    · intro i
      exact i.elim

end Mslang
