import Mslang.Algebra

/-!
Congruences on a `Σ`-algebra and the quotient `Σ`-algebra, with the kernel and
universal property of the quotient (`B-D024`, `B-D025`, `B-P009`).
-/

universe u

namespace Mslang

variable {S : Type u}


/-! ### `B-D024`/`B-D025`: congruences and quotient `Σ`-algebras. -/

/-- `B-D024`: an `S`-sorted congruence on a `Σ`-algebra `(A, F)` is a sorted
equivalence compatible with every formal operation. -/
def IsCongruence {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) : Prop :=
  ∀ (p : List S × S) (σ : Sig p) (a b : wordProd A p.1),
    (∀ i, (Φ (p.1.get i)).r (a i) (b i)) → (Φ p.2).r (F p σ a) (F p σ b)

/-- The operation induced on `A/Φ` by `F_σ`. Representatives are selected with
`Quotient.out`; the congruence condition makes the result independent of the
selection (`quotOp_mk`). -/
noncomputable def quotOp {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) (p : List S × S) (σ : Sig p) :
    finOp (quot Φ) p.1 p.2 :=
  fun a => Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))

/-- `B-D025`: the quotient `Σ`-algebra `A/Φ`. -/
noncomputable def quotAlg {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) (_hΦ : IsCongruence Sig F Φ) :
    Alg Sig :=
  ⟨quot Φ, fun p σ => quotOp Sig F Φ p σ⟩

/-- `B-D025`: the canonical projection `pr^Φ : A → A/Φ`. -/
def prAlg {S : Type u} (Sig : Signature S) {A : SSet S} (F : AlgStruct Sig A)
    (Φ : SortedEqv A) (hΦ : IsCongruence Sig F Φ) :
    SortedMap A (quotAlg Sig F Φ hΦ).1 :=
  pr Φ

/-- `F^{A/Φ}_σ` on representatives: `F_σ([a]) = [F_σ(a)]`. -/
theorem quotOp_mk {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) (hΦ : IsCongruence Sig F Φ)
    (p : List S × S) (σ : Sig p) (a : wordProd A p.1) :
    quotOp Sig F Φ p σ (fun i => Quotient.mk (Φ (p.1.get i)) (a i)) =
      Quotient.mk (Φ p.2) (F p σ a) := by
  apply Quotient.eq.mpr
  apply hΦ p σ (fun i => Quotient.out (Quotient.mk (Φ (p.1.get i)) (a i))) a
  intro i
  exact Quotient.exact (Quotient.out_eq (Quotient.mk (Φ (p.1.get i)) (a i)))

/-- `B-D025`: `pr^Φ` is a homomorphism of `Σ`-algebras. -/
theorem isAlgHom_prAlg {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) (hΦ : IsCongruence Sig F Φ) :
    IsAlgHom Sig F (quotAlg Sig F Φ hΦ).2 (prAlg Sig F Φ hΦ) := by
  intro p σ a
  show Quotient.mk (Φ p.2) (F p σ a) =
    quotOp Sig F Φ p σ (fun i => Quotient.mk (Φ (p.1.get i)) (a i))
  exact (quotOp_mk Sig F Φ hΦ p σ a).symm

/-! ### `B-P009`: kernel and universal property of the quotient `Σ`-algebra. -/

/-- `B-P009`(1): the kernel of a homomorphism is a congruence. -/
theorem ker_isCongruence {S : Type u} (Sig : Signature S) {A B : SSet S}
    (F : AlgStruct Sig A) (G : AlgStruct Sig B) (f : SortedMap A B)
    (hf : IsAlgHom Sig F G f) : IsCongruence Sig F (ker f) := by
  intro p σ a b h
  show f p.2 (F p σ a) = f p.2 (F p σ b)
  rw [hf p σ a, hf p σ b]
  congr 1
  funext i
  exact h i

/-- `B-P009`(2)(a): the kernel of the canonical projection is the congruence. -/
theorem ker_prAlg {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) (hΦ : IsCongruence Sig F Φ) :
    ker (prAlg Sig F Φ hΦ) = Φ :=
  ker_pr Φ

/-- `B-P009`(2)(b): the induced map `p^{Φ,Ker(f)}` is a homomorphism. -/
theorem quotAlgLift_isAlgHom {S : Type u} (Sig : Signature S) {A B : SSet S}
    (F : AlgStruct Sig A) (G : AlgStruct Sig B) (Φ : SortedEqv A)
    (hΦ : IsCongruence Sig F Φ) (f : SortedMap A B)
    (hf : IsAlgHom Sig F G f) (h : sortedEqvLe Φ (ker f)) :
    IsAlgHom Sig (quotAlg Sig F Φ hΦ).2 G (quotLift Φ f h) := by
  intro p σ a
  show quotLift Φ f h p.2
      (Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))) =
    G p σ (fun i => quotLift Φ f h (p.1.get i) (a i))
  rw [show quotLift Φ f h p.2
        (Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))) =
      f p.2 (F p σ (fun i => Quotient.out (a i))) by
    simp only [quotLift, Quotient.lift_mk]]
  rw [hf p σ (fun i => Quotient.out (a i))]
  congr 1
  funext i
  conv_rhs => rw [quotLift, ← Quotient.out_eq (a i), Quotient.lift_mk]

/-- `B-P009`(2)(b): `f = p^{Φ,Ker(f)} ∘ pr^Φ`. -/
theorem quotAlgLift_comp {S : Type u} (Sig : Signature S) {A B : SSet S}
    (F : AlgStruct Sig A) (G : AlgStruct Sig B) (Φ : SortedEqv A)
    (_hΦ : IsCongruence Sig F Φ) (f : SortedMap A B)
    (_hf : IsAlgHom Sig F G f) (h : sortedEqvLe Φ (ker f)) :
    (fun s => (quotLift Φ f h s) ∘ (prAlg Sig F Φ _hΦ s)) = f :=
  quotLift_comp Φ f h

/-- `B-P009`(2)(b): uniqueness of the induced homomorphism. -/
theorem quotAlgLift_unique {S : Type u} (Sig : Signature S) {A B : SSet S}
    (F : AlgStruct Sig A) (G : AlgStruct Sig B) (Φ : SortedEqv A)
    (_hΦ : IsCongruence Sig F Φ) (f : SortedMap A B)
    (_hf : IsAlgHom Sig F G f) (h : sortedEqvLe Φ (ker f))
    (p : SortedMap (quot Φ) B) (hp : (fun s => p s ∘ pr Φ s) = f) :
    p = quotLift Φ f h :=
  quotLift_unique Φ f h p hp

end Mslang
