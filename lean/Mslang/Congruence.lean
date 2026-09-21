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

/-! ### `B-D024`: `Cgr(A)` is an algebraic closure system and algebraic lattice. -/

/-- `B-D024`: the diagonal `Δ^A` is a congruence (equality respects operations). -/
theorem deltaEqv_isCongruence {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) : IsCongruence Sig F (deltaEqv A) := by
  intro p σ a b h
  exact congrArg (F p σ) (funext fun i => h i)

/-- `B-D024`: `Cgr(A)`, the congruences on `A`, as per-sort relations on the
total space `A × A`. -/
def CongOn {S : Type u} (Sig : Signature S) (A : Alg Sig) : Set (Set (PairSpace A.1)) :=
  {P | P ∈ EqvOn A.1 ∧
    ∀ (p : List S × S) (σ : Sig p) (a b : wordProd A.1 p.1),
      (∀ i, (⟨p.1.get i, a i, b i⟩ : PairSpace A.1) ∈ P) →
      (⟨p.2, A.2 p σ a, A.2 p σ b⟩ : PairSpace A.1) ∈ P}

theorem sInter_mem_CongOn {S : Type u} (Sig : Signature S) (A : Alg Sig)
    {D : Set (Set (PairSpace A.1))} (hD : D ⊆ CongOn Sig A) :
    ⋂₀ D ∈ CongOn Sig A := by
  refine ⟨sInter_mem_EqvOn A.1 fun P hP => (hD hP).1, ?_⟩
  intro p σ a b h
  refine Set.mem_sInter.mpr fun Q hQ => ?_
  exact (hD hQ).2 p σ a b fun i => Set.mem_sInter.mp (h i) Q hQ

theorem sUnion_mem_CongOn {S : Type u} (Sig : Signature S) (A : Alg Sig)
    {D : Set (Set (PairSpace A.1))} (hD : D ⊆ CongOn Sig A) (hne : D.Nonempty)
    (hdir : ∀ P ∈ D, ∀ Q ∈ D, ∃ R ∈ D, P ⊆ R ∧ Q ⊆ R) :
    ⋃₀ D ∈ CongOn Sig A := by
  classical
  refine ⟨sUnion_mem_EqvOn A.1 (fun P hP => (hD hP).1) hne hdir, ?_⟩
  intro p σ a b h
  let f : Fin p.1.length → Set (PairSpace A.1) := fun i => Classical.choose (h i)
  have hfD : ∀ i, f i ∈ D := fun i => (Classical.choose_spec (h i)).1
  have hfp : ∀ i, (⟨p.1.get i, a i, b i⟩ : PairSpace A.1) ∈ f i :=
    fun i => (Classical.choose_spec (h i)).2
  have hfin : ∀ t : Finset (Fin p.1.length), ∃ R ∈ D, ∀ i ∈ t, f i ⊆ R := by
    intro t
    induction t using Finset.induction with
    | empty =>
        obtain ⟨R₀, hR₀⟩ := hne
        exact ⟨R₀, hR₀, by simp⟩
    | insert i t _ ih =>
        obtain ⟨R, hR, hRt⟩ := ih
        obtain ⟨Z, hZ, hfZ, hRZ⟩ := hdir (f i) (hfD i) R hR
        refine ⟨Z, hZ, ?_⟩
        intro j hj
        rw [Finset.mem_insert] at hj
        rcases hj with rfl | hj
        · exact hfZ
        · exact (hRt j hj).trans hRZ
  obtain ⟨R, hR, hRall⟩ := hfin Finset.univ
  exact Set.mem_sUnion.mpr
    ⟨R, hR, (hD hR).2 p σ a b fun i => hRall i (Finset.mem_univ i) (hfp i)⟩

/-- `B-D024`: `Cgr(A)` is an algebraic closure system on `A × A`. -/
theorem CongOn_isAlgebraicClosureSystemOn {S : Type u} (Sig : Signature S) (A : Alg Sig) :
    IsAlgebraicClosureSystemOn (PairSpace A.1) (CongOn Sig A) :=
  ⟨⟨univ_mem_EqvOn A.1, fun _ _ _ _ _ => trivial⟩,
   fun _D hD _ => sInter_mem_CongOn Sig A hD,
   fun _D hD hne hdir => sUnion_mem_CongOn Sig A hD hne hdir⟩

/-- The closure operator whose closed sets are `Cgr(A)`. -/
noncomputable def congClosureOperator {S : Type u} (Sig : Signature S) (A : Alg Sig) :
    ClosureOperator (Set (PairSpace A.1)) :=
  ClosureOperator.ofCompletePred (CongOn Sig A) fun D hD => by
    show ⋂₀ D ∈ CongOn Sig A
    exact sInter_mem_CongOn Sig A fun P hP => hD P hP

/-- `B-D024`: the lattice `(Cgr(A), ⊆)` is algebraic. -/
theorem congClosedSets_isAlgebraicLattice {S : Type u} (Sig : Signature S) (A : Alg Sig) :
    @IsAlgebraicLattice (congClosureOperator Sig A).Closeds
      (congClosureOperator Sig A).gi.liftCompleteLattice :=
  isAlgebraicLattice_of_isAlgebraicClosureOperator (congClosureOperator Sig A)
    fun _D hD hne hdir => sUnion_mem_CongOn Sig A (fun P hP => hD P hP) hne hdir

/-- `B-D024`: the algebraic lattice `(Cgr(A), ⊆)`, transported to the
congruences. -/
noncomputable def congOrderIso {S : Type u} (Sig : Signature S) (A : Alg Sig) :
    (congClosureOperator Sig A).Closeds ≃o
      {Φ : SortedEqv A.1 // IsCongruence Sig A.2 Φ} where
  toFun P := ⟨setToEqv P.2.1, P.2.2⟩
  invFun Φ := ⟨eqvToSet Φ.1, eqvToSet_mem_EqvOn Φ.1, fun p σ a b h => Φ.2 p σ a b h⟩
  left_inv _P := by
    apply Subtype.ext
    apply Set.ext
    intro p
    rcases p with ⟨s, x, y⟩
    exact Iff.rfl
  right_inv _Φ := by
    apply Subtype.ext
    funext s
    apply Setoid.ext
    intro x y
    exact Iff.rfl
  map_rel_iff' := by
    intro _ _
    constructor
    · intro h p hp
      rcases p with ⟨s, x, y⟩
      exact h s hp
    · intro h s x y hxy
      exact h hxy

/-- `B-D024`: the congruences carry the complete-lattice structure of `Cgr(A)`. -/
@[instance_reducible]
noncomputable def congSubtypeCompleteLattice {S : Type u} (Sig : Signature S)
    (A : Alg Sig) : CompleteLattice {Φ : SortedEqv A.1 // IsCongruence Sig A.2 Φ} :=
  letI := (congClosureOperator Sig A).gi.liftCompleteLattice
  (congOrderIso Sig A).toGaloisInsertion.liftCompleteLattice

attribute [instance] congSubtypeCompleteLattice

/-- `B-D024`: `Cgr(A)` under inclusion is an algebraic lattice. -/
theorem Cgr_isAlgebraicLattice {S : Type u} (Sig : Signature S) (A : Alg Sig) :
    IsAlgebraicLattice {Φ : SortedEqv A.1 // IsCongruence Sig A.2 Φ} :=
  @isAlgebraicLattice_of_orderIso _ _
    ((congClosureOperator Sig A).gi.liftCompleteLattice)
    (congSubtypeCompleteLattice Sig A)
    (congOrderIso Sig A) (@congClosedSets_isAlgebraicLattice S Sig A)

end Mslang
