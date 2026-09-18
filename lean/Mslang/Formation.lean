import Mslang.Term

/-!
The formation-theoretic layer: subdirect products (`B-D028`), filters of a
lattice (`B-D029`), and formations of `Σ`-congruences (`B-D030`).
-/

universe u

-- The `haveI`s below install `IsEmpty`/`Subsingleton`/`Fintype` instances used
-- by `isEmptyElim`/`Subsingleton.elim`/instance synthesis; the style linter's
-- `have` suggestion would not register them, so it is a false positive here.
set_option linter.style.haveILetI false

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
the kernel `Ker(pr^Θ ∘ f)` lies in `F(A)`.

`T_Σ(A)` is the inductive free algebra `Term Sig A` (the adopted encoding of
`B-D027`; see `B-P010` for the open equivalence with the row presentation). -/
def IsCongruenceFormation {S : Type u} (Sig : Signature S)
    (F : (A : SSet S) → Set (SortedEqv (Term Sig A))) : Prop :=
  (∀ A : SSet S,
      (F A).Nonempty ∧
      (∀ Φ ∈ F A, IsCongruence Sig (termAlg Sig A).2 Φ) ∧
      (∀ Φ ∈ F A, ∀ Ψ ∈ F A, sortedEqvInf Φ Ψ ∈ F A) ∧
      (∀ Φ ∈ F A, ∀ Ψ : SortedEqv (Term Sig A),
        IsCongruence Sig (termAlg Sig A).2 Ψ → sortedEqvLe Φ Ψ → Ψ ∈ F A)) ∧
  (∀ (A B : SSet S) (Θ : SortedEqv (Term Sig B))
      (hΘ : IsCongruence Sig (termAlg Sig B).2 Θ),
      Θ ∈ F B →
      ∀ f : SortedMap (Term Sig A) (Term Sig B),
        IsAlgHom Sig (termAlg Sig A).2 (termAlg Sig B).2 f →
        (∀ s : S, Function.Surjective
          (fun x => prAlg Sig (termAlg Sig B).2 Θ hΘ s (f s x))) →
        ker (fun s => prAlg Sig (termAlg Sig B).2 Θ hΘ s ∘ f s) ∈ F A)

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

/-- `B-D033`: an *ShSk-formation* of `Σ`-algebras is a set `F` of `Σ`-algebras
containing every subfinal `Σ`-algebra (`Sf(1) ⊆ F`, which subsumes nonemptiness),
closed under homomorphic images and under the meet of congruences: if `A/Φ` and
`A/Ψ` lie in `F` then so does `A/(Φ ⊓ Ψ)`. -/
def IsShSkFormation {S : Type u} (Sig : Signature S) (F : Set (Alg Sig)) : Prop :=
  (∀ A : Alg Sig, SubfinalAlg Sig A → A ∈ F) ∧
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

/-! ### `B-P017`: an ShSk-formation is closed under binary subdirect products. -/

/-- The two-element family `{B, C}` indexing the binary product `B × C`
(`B-D022`). The index is lifted to `Type u` because `iAlg`'s index lives in
`Type u` while `Bool` is `Type 0` (the same convention as `B-P016`). -/
def pairAlgFamily {S : Type u} (Sig : Signature S) (B C : Alg Sig) :
    ULift.{u, 0} Bool → Alg Sig :=
  fun b => Bool.rec B C b.down

/-- The inverse of a bijective homomorphism is a homomorphism, so `IsAlgIso` is
symmetric: if `f : A → B` is an isomorphism then so is its inverse. -/
theorem isAlgIso_symm {S : Type u} (Sig : Signature S) {A B : SSet S}
    (FA : AlgStruct Sig A) (FB : AlgStruct Sig B) {f : SortedMap A B}
    (hf : IsAlgIso Sig FA FB f) :
    IsAlgIso Sig FB FA (fun s => (Equiv.ofBijective (f s) (hf.2 s)).symm) := by
  refine ⟨?_, fun s => (Equiv.ofBijective (f s) (hf.2 s)).symm.bijective⟩
  intro p σ a
  apply (hf.2 p.2).1
  rw [Equiv.ofBijective_apply_symm_apply (f p.2) (hf.2 p.2)]
  rw [hf.1 p σ (fun i => (Equiv.ofBijective (f (p.1.get i)) (hf.2 (p.1.get i))).symm (a i))]
  exact (congrArg (FB p σ) (funext fun i =>
    Equiv.ofBijective_apply_symm_apply (f (p.1.get i)) (hf.2 (p.1.get i)) (a i))).symm

/-- The first isomorphism theorem for `Σ`-algebras: a surjective homomorphism
`f : A → B` induces an isomorphism `A/Ker(f) → B`. -/
theorem quotAlg_ker_isAlgIso {S : Type u} (Sig : Signature S) {A B : SSet S}
    (FA : AlgStruct Sig A) (FB : AlgStruct Sig B) (f : SortedMap A B)
    (hf : IsAlgHom Sig FA FB f) (hsurj : ∀ s, Function.Surjective (f s)) :
    IsAlgIso Sig (quotAlg Sig FA (ker f) (ker_isCongruence Sig FA FB f hf)).2 FB
      (quotLift (ker f) f (fun _ _ _ h => h)) := by
  refine ⟨quotAlgLift_isAlgHom Sig FA FB (ker f)
    (ker_isCongruence Sig FA FB f hf) f hf (fun _ _ _ h => h), ?_⟩
  intro s
  constructor
  · intro x y hxy
    induction x using Quotient.inductionOn with
    | _ a =>
      induction y using Quotient.inductionOn with
      | _ b =>
        have h : f s a = f s b := by simpa only [quotLift, Quotient.lift_mk] using hxy
        exact Quotient.sound h
  · intro b
    rcases hsurj s b with ⟨a, ha⟩
    exact ⟨Quotient.mk (ker f s) a, by
      simp only [quotLift, Quotient.lift_mk]
      exact ha⟩

/-- Converse direction of `formation_abstract`: if `X ∈ F` and `F` is closed
under homomorphic images, then every algebra isomorphic to `X` lies in `F`. -/
theorem formation_mem_of_iso {S : Type u} (Sig : Signature S) {F : Set (Alg Sig)}
    (hH : HOperator Sig F ⊆ F) {X Y : Alg Sig} (hX : X ∈ F)
    {f : SortedMap Y.1 X.1} (hf : IsAlgIso Sig Y.2 X.2 f) : Y ∈ F :=
  formation_abstract Sig hH hX (fun s => (Equiv.ofBijective (f s) (hf.2 s)).symm)
    (isAlgIso_symm Sig Y.2 X.2 hf)

/-- `B-P017`: an ShSk-formation `F` is closed under binary subdirect products:
for every `Σ`-algebra `A`, every `B, C ∈ F`, and every subdirect embedding `f`
of `A` into `B × C`, we have `A ∈ F`. -/
theorem shskFormation_mem_of_subdirect_pair {S : Type u} (Sig : Signature S)
    {F : Set (Alg Sig)} (hF : IsShSkFormation Sig F) {A B C : Alg Sig}
    (hB : B ∈ F) (hC : C ∈ F)
    (f : SortedMap A.1 (iAlg Sig (pairAlgFamily Sig B C)).1)
    (hf : IsSubdirectEmbedding Sig A.2 (pairAlgFamily Sig B C) f) : A ∈ F := by
  classical
  let pB : SortedMap (iAlg Sig (pairAlgFamily Sig B C)).1 B.1 :=
    iProjAlg Sig (pairAlgFamily Sig B C) ⟨false⟩
  let pC : SortedMap (iAlg Sig (pairAlgFamily Sig B C)).1 C.1 :=
    iProjAlg Sig (pairAlgFamily Sig B C) ⟨true⟩
  let φ : SortedMap A.1 B.1 := fun s a => pB s (f s a)
  let ψ : SortedMap A.1 C.1 := fun s a => pC s (f s a)
  have hφhom : IsAlgHom Sig A.2 B.2 φ := by
    intro p σ a
    show f p.2 (A.2 p σ a) ⟨false⟩ = B.2 p σ (fun i => f (p.1.get i) (a i) ⟨false⟩)
    rw [hf.1.1 p σ a]
    rfl
  have hψhom : IsAlgHom Sig A.2 C.2 ψ := by
    intro p σ a
    show f p.2 (A.2 p σ a) ⟨true⟩ = C.2 p σ (fun i => f (p.1.get i) (a i) ⟨true⟩)
    rw [hf.1.1 p σ a]
    rfl
  have hΦc : IsCongruence Sig A.2 (ker φ) := ker_isCongruence Sig A.2 B.2 φ hφhom
  have hΨc : IsCongruence Sig A.2 (ker ψ) := ker_isCongruence Sig A.2 C.2 ψ hψhom
  have hφsurj : ∀ s, Function.Surjective (φ s) :=
    fun s => hf.2 ⟨false⟩ s
  have hψsurj : ∀ s, Function.Surjective (ψ s) :=
    fun s => hf.2 ⟨true⟩ s
  have hAΦF : quotAlg Sig A.2 (ker φ) hΦc ∈ F :=
    formation_mem_of_iso Sig hF.2.1 hB (quotAlg_ker_isAlgIso Sig A.2 B.2 φ hφhom hφsurj)
  have hAΨF : quotAlg Sig A.2 (ker ψ) hΨc ∈ F :=
    formation_mem_of_iso Sig hF.2.1 hC (quotAlg_ker_isAlgIso Sig A.2 C.2 ψ hψhom hψsurj)
  have hInfF : quotAlg Sig A.2 (sortedEqvInf (ker φ) (ker ψ))
      (IsCongruence_inf Sig A.2 hΦc hΨc) ∈ F :=
    hF.2.2 A (ker φ) (ker ψ) hΦc hΨc hAΦF hAΨF
  let idA : SortedMap A.1 A.1 := fun _ a => a
  have hidA : IsAlgHom Sig A.2 A.2 idA := fun _ _ _ => rfl
  have hle : sortedEqvLe (sortedEqvInf (ker φ) (ker ψ)) (ker idA) := by
    intro s x y hxy
    show x = y
    apply hf.1.2 s
    funext i
    rcases i with ⟨b⟩
    cases b
    · exact hxy.1
    · exact hxy.2
  have hqhom : IsAlgHom Sig
      (quotAlg Sig A.2 (sortedEqvInf (ker φ) (ker ψ))
        (IsCongruence_inf Sig A.2 hΦc hΨc)).2 A.2
      (quotLift (sortedEqvInf (ker φ) (ker ψ)) idA hle) :=
    quotAlgLift_isAlgHom Sig A.2 A.2 (sortedEqvInf (ker φ) (ker ψ))
      (IsCongruence_inf Sig A.2 hΦc hΨc) idA hidA hle
  have hqbij : ∀ s, Function.Bijective
      ((quotLift (sortedEqvInf (ker φ) (ker ψ)) idA hle) s) := by
    intro s
    constructor
    · intro x y hxy
      induction x using Quotient.inductionOn with
      | _ a =>
        induction y using Quotient.inductionOn with
        | _ b =>
          have hab : a = b := by simpa only [quotLift, Quotient.lift_mk, idA] using hxy
          subst hab
          rfl
    · intro b
      exact ⟨Quotient.mk (sortedEqvInf (ker φ) (ker ψ) s) b, by
        simp only [quotLift, Quotient.lift_mk, idA]⟩
  exact formation_abstract Sig hF.2.1 hInfF
    (quotLift (sortedEqvInf (ker φ) (ker ψ)) idA hle) ⟨hqhom, hqbij⟩

/-! ### `B-C004`: the two definitions of a formation are equivalent. -/

/-- Reflexivity of pointwise refinement of sorted equivalences. -/
theorem sortedEqvLe_refl {S : Type u} {A : SSet S} (Φ : SortedEqv A) :
    sortedEqvLe Φ Φ := fun _ _ _ h => h

/-- Transitivity of pointwise refinement of sorted equivalences. -/
theorem sortedEqvLe_trans {S : Type u} {A : SSet S} {Φ Ψ Χ : SortedEqv A}
    (h1 : sortedEqvLe Φ Ψ) (h2 : sortedEqvLe Ψ Χ) : sortedEqvLe Φ Χ :=
  fun s x y h => h2 s x y (h1 s x y h)

/-- `B-C004` (backward half): an ShSk-formation is closed under finite subdirect
products. Given a finite family `(C i)` in `F` and a subdirect embedding
`f : A → ∏ i, C i`, take the congruences `ker(pr^i ∘ f)` — each quotient is
isomorphic to `C i ∈ F` by the first isomorphism theorem. Their finite meet `Ψ`
is assembled by iterating the binary meet-closure, and `Ψ ⊆ Δ_A` because `f` is
injective, so the comparison map `A/Ψ → A` is an isomorphism and `A ∈ F`. The
empty index is the `n = 0` case: `A` is subfinal, hence in `F` by the
`Sf(1) ⊆ F` clause. -/
theorem shskFormation_mem_of_subdirect {S : Type u} (Sig : Signature S)
    {F : Set (Alg Sig)} (hF : IsShSkFormation Sig F) {ι : Type u} [Fintype ι]
    (C : ι → Alg Sig) (hC : ∀ i, C i ∈ F) {A : Alg Sig}
    (f : SortedMap A.1 (iAlg Sig C).1)
    (hf : IsSubdirectEmbedding Sig A.2 C f) : A ∈ F := by
  classical
  let φ : ∀ i : ι, SortedMap A.1 (C i).1 := fun i s a => f s a i
  have hφhom : ∀ i, IsAlgHom Sig A.2 (C i).2 (φ i) := fun i => by
    intro p σ a
    show f p.2 (A.2 p σ a) i = (C i).2 p σ (fun j => f (p.1.get j) (a j) i)
    rw [hf.1.1 p σ a]
    rfl
  have hφc : ∀ i, IsCongruence Sig A.2 (ker (φ i)) := fun i =>
    ker_isCongruence Sig A.2 (C i).2 (φ i) (hφhom i)
  have hφF : ∀ i, quotAlg Sig A.2 (ker (φ i)) (hφc i) ∈ F := fun i =>
    formation_mem_of_iso Sig hF.2.1 (hC i)
      (quotAlg_ker_isAlgIso Sig A.2 (C i).2 (φ i) (hφhom i) (hf.2 i))
  by_cases hι : Nonempty ι
  · let i₀ : ι := Classical.choice hι
    have hstep : ∀ s : Finset ι,
        ∃ (Ψ : SortedEqv A.1) (hΨ : IsCongruence Sig A.2 Ψ),
          quotAlg Sig A.2 Ψ hΨ ∈ F ∧ sortedEqvLe Ψ (ker (φ i₀)) ∧
            ∀ i ∈ s, sortedEqvLe Ψ (ker (φ i)) := by
      intro s
      induction s using Finset.induction_on with
      | empty =>
        exact ⟨ker (φ i₀), hφc i₀, hφF i₀, sortedEqvLe_refl _,
          fun i hi => absurd hi (Finset.notMem_empty i)⟩
      | insert i s _hi ih =>
        rcases ih with ⟨Ψ, hΨc, hΨF, hΨi₀, hΨs⟩
        refine ⟨sortedEqvInf Ψ (ker (φ i)),
          IsCongruence_inf Sig A.2 hΨc (hφc i),
          hF.2.2 A Ψ (ker (φ i)) hΨc (hφc i) hΨF (hφF i),
          sortedEqvLe_trans (sortedEqvInf_le_left Ψ (ker (φ i))) hΨi₀, ?_⟩
        intro j hj
        rw [Finset.mem_insert] at hj
        rcases hj with h_eq | hj
        · rw [h_eq]
          exact sortedEqvInf_le_right Ψ (ker (φ i))
        · exact sortedEqvLe_trans (sortedEqvInf_le_left Ψ (ker (φ i))) (hΨs j hj)
    obtain ⟨Ψ, hΨc, hΨF, hΨi₀, hΨle⟩ := hstep (Finset.univ.erase i₀)
    let idA : SortedMap A.1 A.1 := fun _ a => a
    have hleDelta : sortedEqvLe Ψ (ker idA) := by
      intro s x y hxy
      show x = y
      apply hf.1.2 s
      funext i
      by_cases hi : i = i₀
      · subst hi
        exact hΨi₀ s x y hxy
      · exact hΨle i (Finset.mem_erase.mpr ⟨hi, Finset.mem_univ i⟩) s x y hxy
    have hqhom : IsAlgHom Sig (quotAlg Sig A.2 Ψ hΨc).2 A.2
        (quotLift Ψ idA hleDelta) :=
      quotAlgLift_isAlgHom Sig A.2 A.2 Ψ hΨc idA (fun _ _ _ => rfl) hleDelta
    have hqbij : ∀ s, Function.Bijective ((quotLift Ψ idA hleDelta) s) := by
      intro s
      constructor
      · intro x y hxy
        induction x using Quotient.inductionOn with
        | _ a =>
          induction y using Quotient.inductionOn with
          | _ b =>
            have hab : a = b := by
              simpa only [quotLift, Quotient.lift_mk, idA] using hxy
            subst hab
            rfl
      · intro b
        exact ⟨Quotient.mk (Ψ s) b, by
          simp only [quotLift, Quotient.lift_mk, idA]⟩
    exact formation_abstract Sig hF.2.1 hΨF (quotLift Ψ idA hleDelta)
      ⟨hqhom, hqbij⟩
  · haveI : IsEmpty ι := not_nonempty_iff.mp hι
    refine hF.1 A ((subfinalAlg_iff Sig A).mpr fun s => ⟨fun a b => ?_⟩)
    haveI : Subsingleton ((iAlg Sig C).1 s) :=
      ⟨fun x y => funext fun i => isEmptyElim i⟩
    exact hf.1.2 s (Subsingleton.elim (f s a) (f s b))

/-- `B-C004`: the two definitions of a formation of `Σ`-algebras are
equivalent. For the empty index (`n = 0`) the `P_fsd`-closure is exactly
`Sf(1) ⊆ F`, which is the first clause of `IsShSkFormation`; for `n ≥ 1` it is
`shskFormation_mem_of_subdirect`. -/
theorem algebraFormation_iff_shskFormation {S : Type u} (Sig : Signature S)
    (F : Set (Alg Sig)) :
    IsAlgebraFormation Sig F ↔ IsShSkFormation Sig F := by
  constructor
  · intro hF
    exact ⟨fun A hA => subfinalAlg_mem_of_formation Sig hF hA, hF.1,
      fun A Φ Ψ hΦ hΨ h1 h2 => formation_congInf Sig hF A Φ Ψ hΦ hΨ h1 h2⟩
  · intro hF
    refine ⟨hF.2.1, ?_⟩
    rintro A ⟨ι, hιfin, C, hC, f, hf⟩
    haveI := hιfin
    exact shskFormation_mem_of_subdirect Sig hF C hC f hf

/-! ### `B-P018`: `Form_Alg(Σ)` is an algebraic closure system. -/

/-- `B-D031`: `H` is monotone in the family. -/
theorem HOperator_mono {S : Type u} (Sig : Signature S) {F G : Set (Alg Sig)}
    (h : F ⊆ G) : HOperator Sig F ⊆ HOperator Sig G :=
  fun _ ⟨B, hB, f, hf⟩ => ⟨B, h hB, f, hf⟩

/-- `B-D031`: `P_fsd` is monotone in the family. -/
theorem PFsdOperator_mono {S : Type u} (Sig : Signature S) {F G : Set (Alg Sig)}
    (h : F ⊆ G) : PFsdOperator Sig F ⊆ PFsdOperator Sig G :=
  fun _ ⟨ι, hι, C, hC, f, hf⟩ => ⟨ι, hι, C, fun i => h (hC i), f, hf⟩

/-- In a directed family of sets, any finite subfamily has a common upper bound
in the family (the finite-index form of directedness). -/
theorem exists_mem_superset_finset {S : Type u} (Sig : Signature S)
    {D : Set (Set (Alg Sig))} (hD : D.Nonempty)
    (hdir : ∀ A ∈ D, ∀ B ∈ D, ∃ E ∈ D, A ⊆ E ∧ B ⊆ E)
    {ι : Type u} (s : Finset ι) (F : ι → Set (Alg Sig))
    (hF : ∀ i ∈ s, F i ∈ D) : ∃ G ∈ D, ∀ i ∈ s, F i ⊆ G := by
  classical
  revert hF
  refine Finset.induction_on s ?_ ?_
  · intro _
    obtain ⟨G, hG⟩ := hD
    exact ⟨G, hG, by simp⟩
  · intro a s ha ih hF
    have hF' : ∀ i ∈ s, F i ∈ D := fun i hi => hF i (Finset.mem_insert_of_mem hi)
    obtain ⟨G, hG, hGs⟩ := ih hF'
    have haD : F a ∈ D := hF a (Finset.mem_insert_self a s)
    obtain ⟨E, hE, hGE, haE⟩ := hdir G hG (F a) haD
    refine ⟨E, hE, ?_⟩
    intro i hi
    rw [Finset.mem_insert] at hi
    rcases hi with rfl | hi
    · exact haE
    · exact fun x hx => hGE (hGs i hi hx)

/-- `B-P018` (`FormAlgAlgLat`): `Form_Alg(Σ) ⊆ Sub(Alg(Σ))` is an algebraic
closure system. `Alg(Σ)` is a formation; a nonempty intersection of formations is
a formation (each `H`/`P_fsd` witness lands in every member of the family); and a
nonempty directed union of formations is a formation (the finitely many witnesses
for `P_fsd` are combined by directedness). -/
theorem algebraFormations_isAlgebraicClosureSystem {S : Type u} (Sig : Signature S) :
    IsAlgebraicClosureSystemOn (Alg Sig) (algebraFormations Sig) := by
  refine ⟨?_, ?_, ?_⟩
  · exact ⟨fun _ _ => trivial, fun _ _ => trivial⟩
  · intro D hD _
    constructor
    · intro A hA
      rw [Set.mem_sInter]
      intro G hG
      exact (hD hG).1 (HOperator_mono Sig (fun B hB => Set.mem_sInter.mp hB G hG) hA)
    · intro A hA
      rw [Set.mem_sInter]
      intro G hG
      exact (hD hG).2 (PFsdOperator_mono Sig (fun B hB => Set.mem_sInter.mp hB G hG) hA)
  · intro D hD hne hdir
    constructor
    · intro A hA
      rw [Set.mem_sUnion]
      obtain ⟨B, hB, f, hf⟩ := hA
      obtain ⟨F, hF, hBF⟩ := Set.mem_sUnion.mp hB
      exact ⟨F, hF, (hD hF).1 (⟨B, hBF, f, hf⟩ : A ∈ HOperator Sig F)⟩
    · intro A hA
      rw [Set.mem_sUnion]
      obtain ⟨ι, hιfin, C, hC, f, hf⟩ := hA
      classical
      have hCF : ∀ i, ∃ F ∈ D, C i ∈ F := fun i => Set.mem_sUnion.mp (hC i)
      let Fi : ι → Set (Alg Sig) := fun i => Classical.choose (hCF i)
      have hFiD : ∀ i, Fi i ∈ D := fun i => (Classical.choose_spec (hCF i)).1
      have hCFi : ∀ i, C i ∈ Fi i := fun i => (Classical.choose_spec (hCF i)).2
      obtain ⟨G, hG, hFG⟩ :=
        exists_mem_superset_finset Sig hne hdir Finset.univ Fi (fun i _ => hFiD i)
      have hCG : ∀ i, C i ∈ G := fun i => hFG i (Finset.mem_univ i) (hCFi i)
      exact ⟨G, hG, (hD hG).2
        (⟨ι, hιfin, C, hCG, f, hf⟩ : A ∈ PFsdOperator Sig G)⟩

/-! ### `B-D034`: the formation generating operator `Fmg_Σ`. -/

/-- `B-D034`: the *formation generating operator* `Fmg_Σ` associated to the
algebraic closure system `Form_Alg(Σ)`: `Fmg_Σ(M)` is the intersection of all
formations of `Σ`-algebras containing `M` (the least such formation). -/
def formationGenerating {S : Type u} (Sig : Signature S) (M : Set (Alg Sig)) :
    Set (Alg Sig) :=
  ⋂₀ {F | IsAlgebraFormation Sig F ∧ M ⊆ F}

/-! ### `B-P019`: `𝔉_F` is a formation of congruences. -/

/-- `B-P019`: for a formation `F` of `Σ`-algebras, the function `𝔉_F` sending
each `S`-sorted set `A` to `{Φ ∈ Cgr(T_Σ(A)) | T_Σ(A)/Φ ∈ F}`, a subset of
`Cgr(T_Σ(A))`. Membership is the `Σ`-form `∃ hΦ, quotAlg … Φ hΦ ∈ F`, since
`IsCongruence` is a proposition. -/
def congruenceFormationOf {S : Type u} (Sig : Signature S) (F : Set (Alg Sig)) :
    (A : SSet S) → Set (SortedEqv (Term Sig A)) :=
  fun A => {Φ | ∃ hΦ : IsCongruence Sig (termAlg Sig A).2 Φ,
                  quotAlg Sig (termAlg Sig A).2 Φ hΦ ∈ F}

/-- `B-P019` (`FormAlgentailsCgrForm`): if `F` is a formation of `Σ`-algebras,
then `𝔉_F` is a formation of congruences. Each `𝔉_F(A)` is a filter of
`Cgr(T_Σ(A))` — non-empty by `∇^{T_Σ(A)}` (its quotient is subfinal, hence in
`F`), closed under `⊓` by `B-P016`, and up-closed because a coarser congruence
gives a quotient — and the formation clause holds by the first isomorphism
theorem (`B-P017`): `T_Σ(A)/Ker(pr^Θ ∘ f) ≅ T_Σ(B)/Θ ∈ F`. -/
theorem congruenceFormation_isCongruenceFormation {S : Type u} (Sig : Signature S)
    {F : Set (Alg Sig)} (hF : IsAlgebraFormation Sig F) :
    IsCongruenceFormation Sig (congruenceFormationOf Sig F) := by
  classical
  constructor
  · intro A
    refine ⟨?_, ?_, ?_, ?_⟩
    · exact ⟨nabla (Term Sig A), nabla_isCongruence Sig (termAlg Sig A).2,
        subfinalAlg_mem_of_formation Sig hF (quot_nabla_subfinal Sig (termAlg Sig A).2)⟩
    · rintro Φ ⟨hΦ, _⟩
      exact hΦ
    · rintro Φ ⟨hΦ, hΦF⟩ Ψ ⟨hΨ, hΨF⟩
      exact ⟨IsCongruence_inf Sig (termAlg Sig A).2 hΦ hΨ,
        formation_congInf Sig hF (termAlg Sig A) Φ Ψ hΦ hΨ hΦF hΨF⟩
    · rintro Φ ⟨hΦ, hΦF⟩ Ψ hΨ hle
      have hle' : sortedEqvLe Φ (ker (prAlg Sig (termAlg Sig A).2 Ψ hΨ)) :=
        (congrArg (fun R => sortedEqvLe Φ R)
          (ker_prAlg Sig (termAlg Sig A).2 Ψ hΨ)).symm.mp hle
      let p : SortedMap (quotAlg Sig (termAlg Sig A).2 Φ hΦ).1
          (quotAlg Sig (termAlg Sig A).2 Ψ hΨ).1 :=
        quotLift Φ (prAlg Sig (termAlg Sig A).2 Ψ hΨ) hle'
      have hp_hom : IsAlgHom Sig (quotAlg Sig (termAlg Sig A).2 Φ hΦ).2
          (quotAlg Sig (termAlg Sig A).2 Ψ hΨ).2 p :=
        quotAlgLift_isAlgHom Sig (termAlg Sig A).2 (quotAlg Sig (termAlg Sig A).2 Ψ hΨ).2
          Φ hΦ (prAlg Sig (termAlg Sig A).2 Ψ hΨ)
          (isAlgHom_prAlg Sig (termAlg Sig A).2 Ψ hΨ) hle'
      have hp_surj : ∀ s, Function.Surjective (p s) := by
        intro s y
        induction y using Quotient.inductionOn with
        | _ a =>
          refine ⟨Quotient.mk (Φ s) a, ?_⟩
          exact Quotient.lift_mk (prAlg Sig (termAlg Sig A).2 Ψ hΨ s)
            (fun a b hab => hle' s a b hab) a
      exact ⟨hΨ, hF.1 ⟨quotAlg Sig (termAlg Sig A).2 Φ hΦ, hΦF, p, hp_hom, hp_surj⟩⟩
  · rintro A B Θ hΘ hΘF f hf hsurj
    obtain ⟨_, hΘFmem⟩ := hΘF
    let g : SortedMap (Term Sig A) (quotAlg Sig (termAlg Sig B).2 Θ hΘ).1 :=
      fun s => (prAlg Sig (termAlg Sig B).2 Θ hΘ s) ∘ (f s)
    have hg : IsAlgHom Sig (termAlg Sig A).2
        (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 g := by
      intro p σ a
      show prAlg Sig (termAlg Sig B).2 Θ hΘ p.2 (f p.2 ((termAlg Sig A).2 p σ a)) =
        (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 p σ
          (fun i => prAlg Sig (termAlg Sig B).2 Θ hΘ (p.1.get i) (f (p.1.get i) (a i)))
      rw [hf p σ a]
      exact isAlgHom_prAlg Sig (termAlg Sig B).2 Θ hΘ p σ
        (fun i => f (p.1.get i) (a i))
    have hiso := quotAlg_ker_isAlgIso Sig (termAlg Sig A).2
      (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 g hg hsurj
    exact ⟨ker_isCongruence Sig (termAlg Sig A).2 (quotAlg Sig (termAlg Sig B).2 Θ hΘ).2 g hg,
      formation_mem_of_iso Sig hF.1 hΘFmem hiso⟩

/-! ### `B-P020`: the Galois correspondence `𝔉_F ↔ F_𝔉`. -/

/-- The canonical projection `pr^Φ : A → A/Φ` is surjective. -/
theorem pr_surjective {S : Type u} {A : SSet S} (Φ : SortedEqv A) :
    ∀ s, Function.Surjective (pr Φ s) :=
  fun _s y => Quotient.inductionOn y (fun a => ⟨a, rfl⟩)

/-- If `f` is injective, precomposing with `f` does not change a kernel:
`Ker(f ∘ h) = Ker(h)`. -/
theorem ker_comp_of_injective {S : Type u} {A B C : SSet S} (h : SortedMap A B)
    (f : SortedMap B C) (hf : ∀ s, Function.Injective (f s)) :
    ker (fun s => f s ∘ h s) = ker h := by
  funext s
  refine Setoid.ext ?_
  intro a b
  exact ⟨fun hab => hf s hab, fun hab => congrArg (f s) hab⟩

/-- `B-P020`: the direct image `F_𝔉` of a congruence formation `𝔉`: the
`Σ`-algebras isomorphic to a quotient `T_Σ(A)/Φ` with `Φ ∈ 𝔉(A)`. -/
def algebraFormationOfCongruenceFormation {S : Type u} (Sig : Signature S)
    (G : (A : SSet S) → Set (SortedEqv (Term Sig A))) : Set (Alg Sig) :=
  {C | ∃ (A : SSet S) (Φ : SortedEqv (Term Sig A))
        (hΦ : IsCongruence Sig (termAlg Sig A).2 Φ),
        Φ ∈ G A ∧ ∃ f : SortedMap C.1 (quotAlg Sig (termAlg Sig A).2 Φ hΦ).1,
          IsAlgIso Sig C.2 (quotAlg Sig (termAlg Sig A).2 Φ hΦ).2 f}

/-- `B-P020` (first round trip): for an algebra formation `F`,
`F = F_{𝔉_F}`. The `⊆` direction uses that every `Σ`-algebra is a quotient of a
free `Σ`-algebra (`B-P013`), taking `Φ = Ker(termEval)`; the `⊇` direction is
abstractness of `F` (`B-R014`). -/
theorem algebraFormationOfCongruenceFormation_congruenceFormationOf {S : Type u}
    (Sig : Signature S) {F : Set (Alg Sig)} (hF : IsAlgebraFormation Sig F) :
    algebraFormationOfCongruenceFormation Sig (congruenceFormationOf Sig F) = F := by
  ext C
  constructor
  · rintro ⟨A, Φ, hΦ, hΦF, f, hf⟩
    obtain ⟨hΦ', hΦ'F⟩ := hΦF
    exact formation_mem_of_iso Sig hF.1 hΦ'F hf
  · intro hC
    let hker := ker_isCongruence Sig (termAlg Sig C.1).2 C.2 (termEval Sig C)
      (termEval_isAlgHom Sig C)
    let Q := quotAlg Sig (termAlg Sig C.1).2 (ker (termEval Sig C)) hker
    let hiso : IsAlgIso Sig Q.2 C.2
        (quotLift (ker (termEval Sig C)) (termEval Sig C) (fun _ _ _ h => h)) :=
      quotAlg_ker_isAlgIso Sig (termAlg Sig C.1).2 C.2 (termEval Sig C)
        (termEval_isAlgHom Sig C) (termEval_surjective Sig C)
    refine ⟨C.1, ker (termEval Sig C), hker, ?_, ?_⟩
    · refine ⟨hker, ?_⟩
      exact formation_mem_of_iso Sig hF.1 hC hiso
    · exact ⟨_, isAlgIso_symm Sig Q.2 C.2 hiso⟩

/-- `B-P020` (second round trip): for a congruence formation `𝔉`,
`𝔉 = 𝔉_{F_𝔉}`. The `⊆` direction is the substantive one: a quotient
`T_Σ(A)/Φ ∈ F_𝔉` comes from `T_Σ(B)/Ψ` with `Ψ ∈ 𝔉(B)`, and projectivity of the
free algebra (`B-P012`) lifts the isomorphism to a homomorphism `g : T_Σ(A) →
T_Σ(B)`; the formation clause of `𝔉` then gives
`Ker(pr^Ψ ∘ g) ∈ 𝔉(A)`, and `Ker(pr^Ψ ∘ g) = Φ` because the isomorphism is
injective. -/
theorem congruenceFormationOf_algebraFormationOfCongruenceFormation {S : Type u}
    (Sig : Signature S) {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) :
    congruenceFormationOf Sig (algebraFormationOfCongruenceFormation Sig G) = G := by
  classical
  funext A
  ext Φ
  constructor
  · rintro ⟨hΦ, hΦF⟩
    obtain ⟨B, Ψ, hΨ, hΨG, f, hf⟩ := hΦF
    let FA : AlgStruct Sig (Term Sig A) := (termAlg Sig A).2
    let FB : AlgStruct Sig (Term Sig B) := (termAlg Sig B).2
    let QA := quotAlg Sig FA Φ hΦ
    let QB := quotAlg Sig FB Ψ hΨ
    let prA : SortedMap (Term Sig A) QA.1 := prAlg Sig FA Φ hΦ
    let prB : SortedMap (Term Sig B) QB.1 := prAlg Sig FB Ψ hΨ
    have hprA : ∀ s, Function.Surjective (prA s) := fun s => pr_surjective Φ s
    have hprB : ∀ s, Function.Surjective (prB s) := fun s => pr_surjective Ψ s
    have hcomp : IsAlgHom Sig FA QB.2 (fun s => f s ∘ prA s) := by
      intro p σ a
      show f p.2 (prA p.2 (FA p σ a)) =
        QB.2 p σ (fun i => f (p.1.get i) (prA (p.1.get i) (a i)))
      rw [show prA p.2 (FA p σ a) = QA.2 p σ (fun i => prA (p.1.get i) (a i)) from
        isAlgHom_prAlg Sig FA Φ hΦ p σ a]
      exact hf.1 p σ (fun i => prA (p.1.get i) (a i))
    obtain ⟨g, hg_hom, hg_comp⟩ :=
      term_projective Sig A FB QB.2 prB (isAlgHom_prAlg Sig FB Ψ hΨ) hprB
        (fun s => f s ∘ prA s) hcomp
    have hsurj_g : ∀ s, Function.Surjective (prB s ∘ g s) := by
      intro s y
      obtain ⟨y', hy'⟩ := (hf.2 s).2 y
      obtain ⟨x, hx⟩ := hprA s y'
      exact ⟨x, (congrFun (congrFun hg_comp s) x).trans
        ((congrArg (f s) hx).trans hy')⟩
    have hmem : (ker fun s => prB s ∘ g s) ∈ G A :=
      hG.2 A B Ψ hΨ hΨG g hg_hom hsurj_g
    have hker_eq : ker (fun s => prB s ∘ g s) = Φ := by
      have h1 : ker (fun s => prB s ∘ g s) = ker (fun s => f s ∘ prA s) :=
        congrArg ker hg_comp
      have h2 : ker (fun s => f s ∘ prA s) = ker prA :=
        ker_comp_of_injective prA f (fun s => (hf.2 s).1)
      have h3 : ker prA = Φ := ker_prAlg Sig FA Φ hΦ
      rw [h1, h2, h3]
    rw [hker_eq] at hmem
    exact hmem
  · intro hΦG
    have hΦ : IsCongruence Sig (termAlg Sig A).2 Φ := (hG.1 A).2.1 Φ hΦG
    refine ⟨hΦ, ?_⟩
    exact ⟨A, Φ, hΦ, hΦG, (fun _s => id),
      ⟨(by intro p σ a; rfl), fun _s => Function.bijective_id⟩⟩

/-! ### `B-P015`: `F_𝔉` is a formation of `Σ`-algebras. -/

/-- Composition of `Σ`-algebra isomorphisms. -/
theorem isAlgIso_comp {S : Type u} (Sig : Signature S) {A B C : SSet S}
    (FA : AlgStruct Sig A) (FB : AlgStruct Sig B) (FC : AlgStruct Sig C)
    {f : SortedMap A B} {g : SortedMap B C}
    (hf : IsAlgIso Sig FA FB f) (hg : IsAlgIso Sig FB FC g) :
    IsAlgIso Sig FA FC (fun s => g s ∘ f s) := by
  refine ⟨?_, fun s => (hg.2 s).comp (hf.2 s)⟩
  intro p σ a
  show g p.2 (f p.2 (FA p σ a)) =
    FC p σ (fun i => g (p.1.get i) (f (p.1.get i) (a i)))
  rw [hf.1 p σ a]
  exact hg.1 p σ (fun i => f (p.1.get i) (a i))

/-- `B-P015`(1): `F_𝔉` is non-empty: the final algebra `1` is
`T_Σ(1)/∇^{T_Σ(1)}` (up to isomorphism), and `∇ ∈ 𝔉(1)` by up-closure. -/
theorem algebraFormationOfCongruenceFormation_nonempty {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))} (hG : IsCongruenceFormation Sig G) :
    (algebraFormationOfCongruenceFormation Sig G).Nonempty := by
  classical
  let A₀ : SSet S := (finalAlg Sig).1
  obtain ⟨Ψ, hΨG⟩ := (hG.1 A₀).1
  have hnablaG : nabla (Term Sig A₀) ∈ G A₀ :=
    (hG.1 A₀).2.2.2 Ψ hΨG (nabla (Term Sig A₀))
      (nabla_isCongruence Sig (termAlg Sig A₀).2) (fun _ _ _ _ => trivial)
  let Q := quotAlg Sig (termAlg Sig A₀).2 (nabla (Term Sig A₀))
    (nabla_isCongruence Sig (termAlg Sig A₀).2)
  have hsub : ∀ s, Subsingleton (Q.1 s) := fun s =>
    ⟨fun x y => Quotient.inductionOn₂ x y (fun _ _ => Quotient.sound trivial)⟩
  have hne : ∀ s, Nonempty (Q.1 s) := fun s =>
    ⟨Quotient.mk _ (Term.var (s := s) PUnit.unit)⟩
  refine ⟨finalAlg Sig, A₀, nabla (Term Sig A₀),
    nabla_isCongruence Sig (termAlg Sig A₀).2, hnablaG, ?_⟩
  change ∃ f : SortedMap (finalAlg Sig).1 Q.1, IsAlgIso Sig (finalAlg Sig).2 Q.2 f
  refine ⟨fun s _ => Classical.choice (hne s), ?_, fun s => ?_⟩
  · intro p σ a
    exact @Subsingleton.elim (Q.1 p.2) (hsub p.2) _ _
  · haveI : Subsingleton ((finalAlg Sig).fst s) := inferInstanceAs (Subsingleton PUnit)
    refine ⟨fun x y _ => Subsingleton.elim x y, fun y => ?_⟩
    exact ⟨PUnit.unit, @Subsingleton.elim (Q.1 s) (hsub s) _ _⟩

/-- `B-P015`(2): `F_𝔉` is abstract (closed under isomorphism): composition of
isomorphisms. -/
theorem algebraFormationOfCongruenceFormation_abstract {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))} :
    ∀ {C D : Alg Sig}, C ∈ algebraFormationOfCongruenceFormation Sig G →
      (∃ f : SortedMap C.1 D.1, IsAlgIso Sig C.2 D.2 f) →
      D ∈ algebraFormationOfCongruenceFormation Sig G := by
  rintro C D ⟨A, Φ, hΦ, hΦG, f, hf⟩ ⟨k, hk⟩
  let k' : SortedMap D.1 C.1 := fun s => (Equiv.ofBijective (k s) (hk.2 s)).symm
  have hk' : IsAlgIso Sig D.2 C.2 k' := isAlgIso_symm Sig C.2 D.2 hk
  exact ⟨A, Φ, hΦ, hΦG, fun s => f s ∘ k' s,
    isAlgIso_comp Sig D.2 C.2 (quotAlg Sig (termAlg Sig A).2 Φ hΦ).2 hk' hf⟩

/-- `B-P015`(3): `F_𝔉` is closed under homomorphic images. The epimorphism
`C ↠ D` composes with `T_Σ(A) ↠ C` (the inverse of `C ≅ T_Σ(A)/Φ`) to an
epimorphism `T_Σ(A) ↠ D` whose kernel contains `Φ`; up-closure puts it in
`𝔉(A)`, and the first isomorphism theorem identifies `D` with its quotient. -/
theorem algebraFormationOfCongruenceFormation_HOperator {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))} (hG : IsCongruenceFormation Sig G) :
    HOperator Sig (algebraFormationOfCongruenceFormation Sig G) ⊆
      algebraFormationOfCongruenceFormation Sig G := by
  classical
  rintro D ⟨C, hC, f, hf_hom, hf_surj⟩
  obtain ⟨A, Φ, hΦ, hΦG, g, hg⟩ := hC
  let FA := (termAlg Sig A).2
  let QA := quotAlg Sig FA Φ hΦ
  let g' : SortedMap QA.1 C.1 := fun s => (Equiv.ofBijective (g s) (hg.2 s)).symm
  have hg' : IsAlgIso Sig QA.2 C.2 g' := isAlgIso_symm Sig C.2 QA.2 hg
  let k : SortedMap QA.1 D.1 := fun s => f s ∘ g' s
  have hk_hom : IsAlgHom Sig QA.2 D.2 k := by
    intro p σ a
    show f p.2 (g' p.2 (QA.2 p σ a)) = D.2 p σ (fun i => f (p.1.get i) (g' (p.1.get i) (a i)))
    rw [hg'.1 p σ a]
    exact hf_hom p σ (fun i => g' (p.1.get i) (a i))
  have hk_surj : ∀ s, Function.Surjective (k s) := fun s =>
    (hf_surj s).comp (hg'.2 s).2
  let prA : SortedMap (Term Sig A) QA.1 := prAlg Sig FA Φ hΦ
  have hprA : ∀ s, Function.Surjective (prA s) := fun s => pr_surjective Φ s
  let kk : SortedMap (Term Sig A) D.1 := fun s => k s ∘ prA s
  have hkk_hom : IsAlgHom Sig FA D.2 kk := by
    intro p σ a
    show k p.2 (prA p.2 (FA p σ a)) = D.2 p σ (fun i => k (p.1.get i) (prA (p.1.get i) (a i)))
    rw [show prA p.2 (FA p σ a) = QA.2 p σ (fun i => prA (p.1.get i) (a i)) from
      isAlgHom_prAlg Sig FA Φ hΦ p σ a]
    exact hk_hom p σ (fun i => prA (p.1.get i) (a i))
  have hkk_surj : ∀ s, Function.Surjective (kk s) := fun s =>
    (hk_surj s).comp (hprA s)
  have hle : sortedEqvLe Φ (ker kk) := by
    intro s a b hab
    show kk s a = kk s b
    have hpr : prA s a = prA s b := by
      have hk := ker_prAlg Sig FA Φ hΦ
      change (ker (prAlg Sig FA Φ hΦ) s).r a b
      rw [hk]
      exact hab
    rw [show kk s a = k s (prA s a) from rfl, show kk s b = k s (prA s b) from rfl, hpr]
  have hkerG : ker kk ∈ G A :=
    (hG.1 A).2.2.2 Φ hΦG (ker kk) (ker_isCongruence Sig FA D.2 kk hkk_hom) hle
  refine ⟨A, ker kk, ker_isCongruence Sig FA D.2 kk hkk_hom, hkerG, ?_⟩
  exact ⟨_, isAlgIso_symm Sig
    (quotAlg Sig FA (ker kk) (ker_isCongruence Sig FA D.2 kk hkk_hom)).2 D.2
    (quotAlg_ker_isAlgIso Sig FA D.2 kk hkk_hom hkk_surj)⟩

/-- `B-P015`(4): `F_𝔉` is closed under finite subdirect products. A finite
subdirect product `A` of members `C^i ≅ T_Σ(A^i)/Φ^i` is a quotient of a free
algebra `T_Σ(B)` (take `B = A` and `g = termEval`). For each `i`, projectivity
of `T_Σ(B)` lifts `pr^i ∘ f ∘ g` to `h^i : T_Σ(B) → T_Σ(A^i)`; the formation
clause puts `Ker(pr^{Φ^i} ∘ h^i)` in `𝔉(B)`, so their finite meet is in `𝔉(B)`;
that meet refines `Ker(g)` (because the `f ∘ g`-images agree on every projection
and `f` is injective), so `Ker(g) ∈ 𝔉(B)`, and `T_Σ(B)/Ker(g) ≅ A`. -/
theorem algebraFormationOfCongruenceFormation_PFsdOperator {S : Type u} (Sig : Signature S)
    {G : (A : SSet S) → Set (SortedEqv (Term Sig A))} (hG : IsCongruenceFormation Sig G) :
    PFsdOperator Sig (algebraFormationOfCongruenceFormation Sig G) ⊆
      algebraFormationOfCongruenceFormation Sig G := by
  classical
  rintro A ⟨ι, hι, C, hC, f, hf⟩
  haveI := hι
  choose Ai hAi using hC
  choose Φi hΦi using hAi
  choose hΦic hrest using hΦi
  have hΦiG : ∀ i, Φi i ∈ G (Ai i) := fun i => (hrest i).1
  choose gi hgi using fun i => (hrest i).2
  let B : SSet S := A.1
  let g : SortedMap (Term Sig B) B := termEval Sig A
  have hg_hom : IsAlgHom Sig (termAlg Sig B).2 A.2 g := termEval_isAlgHom Sig A
  have hg_surj : ∀ s, Function.Surjective (g s) := termEval_surjective Sig A
  let ki : (i : ι) → SortedMap (Term Sig B)
      (quotAlg Sig (termAlg Sig (Ai i)).2 (Φi i) (hΦic i)).1 :=
    fun i s x => gi i s (f s (g s x) i)
  have hki_hom : ∀ i, IsAlgHom Sig (termAlg Sig B).2
      (quotAlg Sig (termAlg Sig (Ai i)).2 (Φi i) (hΦic i)).2 (ki i) := by
    intro i p σ a
    show gi i p.2 (f p.2 (g p.2 ((termAlg Sig B).2 p σ a)) i) =
      (quotAlg Sig (termAlg Sig (Ai i)).2 (Φi i) (hΦic i)).2 p σ
        (fun j => gi i (p.1.get j) (f (p.1.get j) (g (p.1.get j) (a j)) i))
    rw [show g p.2 ((termAlg Sig B).2 p σ a) = A.2 p σ (fun j => g (p.1.get j) (a j)) from
      hg_hom p σ a]
    rw [show f p.2 (A.2 p σ (fun j => g (p.1.get j) (a j))) =
        (iAlg Sig C).2 p σ (fun j => f (p.1.get j) (g (p.1.get j) (a j))) from
      hf.1.1 p σ (fun j => g (p.1.get j) (a j))]
    exact (hgi i).1 p σ (fun j => f (p.1.get j) (g (p.1.get j) (a j)) i)
  have hki_surj : ∀ i s, Function.Surjective (ki i s) := by
    intro i s y
    obtain ⟨c, hc⟩ := (hgi i).2 s |>.2 y
    obtain ⟨a, ha⟩ := hf.2 i s c
    obtain ⟨x, hx⟩ := hg_surj s a
    refine ⟨x, ?_⟩
    show gi i s (f s (g s x) i) = y
    have ha' : f s a i = c := by simpa using ha
    rw [hx, ha', hc]
  have hproj : ∀ i, ∃ hi : SortedMap (Term Sig B) (Term Sig (Ai i)),
      IsAlgHom Sig (termAlg Sig B).2 (termAlg Sig (Ai i)).2 hi ∧
      (fun s => (prAlg Sig (termAlg Sig (Ai i)).2 (Φi i) (hΦic i)) s ∘ hi s) = ki i :=
    fun i => term_projective Sig B (termAlg Sig (Ai i)).2
      (quotAlg Sig (termAlg Sig (Ai i)).2 (Φi i) (hΦic i)).2
      (prAlg Sig (termAlg Sig (Ai i)).2 (Φi i) (hΦic i))
      (isAlgHom_prAlg Sig (termAlg Sig (Ai i)).2 (Φi i) (hΦic i))
      (fun s => pr_surjective (Φi i) s) (ki i) (hki_hom i)
  choose hi hhi_hom hhi_comp using hproj
  let Φ : ι → SortedEqv (Term Sig B) := fun i =>
    ker (fun s => (prAlg Sig (termAlg Sig (Ai i)).2 (Φi i) (hΦic i)) s ∘ hi i s)
  have hΦmem : ∀ i, Φ i ∈ G B := by
    intro i
    have hsurj : ∀ s, Function.Surjective
        (fun x => (prAlg Sig (termAlg Sig (Ai i)).2 (Φi i) (hΦic i)) s (hi i s x)) := by
      intro s y
      obtain ⟨x, hx⟩ := hki_surj i s y
      exact ⟨x, (congrFun (congrFun (hhi_comp i) s) x).trans hx⟩
    exact hG.2 B (Ai i) (Φi i) (hΦic i) (hΦiG i) (hi i) (hhi_hom i) hsurj
  have hInf : Finset.inf Finset.univ Φ ∈ G B := by
    have hstep : ∀ (t : Finset ι), Finset.inf t Φ ∈ G B := by
      intro t
      induction t using Finset.induction with
      | empty =>
          rw [Finset.inf_empty]
          obtain ⟨Ψ₀, hΨ₀⟩ := (hG.1 B).1
          exact (hG.1 B).2.2.2 Ψ₀ hΨ₀ ⊤ (fun _ _ _ _ _ => trivial) (fun _ _ _ _ => trivial)
      | insert a t ha ih =>
          rw [Finset.inf_insert]
          exact (hG.1 B).2.2.1 (Φ a) (hΦmem a) (Finset.inf t Φ) ih
    exact hstep Finset.univ
  have hle : sortedEqvLe (Finset.inf Finset.univ Φ) (ker g) := by
    intro s x y hxy
    have hproj_eq : f s (g s x) = f s (g s y) := by
      funext i
      have h1 : ki i s x = ki i s y := by
        have h3 : (Φ i s).r x y :=
          (Setoid.le_def.mp ((Pi.le_def.mp (Finset.inf_le (Finset.mem_univ i))) s)) hxy
        change (fun s => (prAlg Sig (termAlg Sig (Ai i)).2 (Φi i) (hΦic i)) s ∘ hi i s) s x =
          (fun s => (prAlg Sig (termAlg Sig (Ai i)).2 (Φi i) (hΦic i)) s ∘ hi i s) s y at h3
        rw [hhi_comp i] at h3
        exact h3
      exact ((hgi i).2 s).1 h1
    exact hf.1.2 s hproj_eq
  have hkerG : ker g ∈ G B :=
    (hG.1 B).2.2.2 (Finset.inf Finset.univ Φ) hInf (ker g)
      (ker_isCongruence Sig (termAlg Sig B).2 A.2 g hg_hom) hle
  refine ⟨B, ker g, ker_isCongruence Sig (termAlg Sig B).2 A.2 g hg_hom, hkerG, ?_⟩
  exact ⟨_, isAlgIso_symm Sig
    (quotAlg Sig (termAlg Sig B).2 (ker g) (ker_isCongruence Sig (termAlg Sig B).2 A.2 g hg_hom)).2 A.2
    (quotAlg_ker_isAlgIso Sig (termAlg Sig B).2 A.2 g hg_hom hg_surj)⟩

/-! ### `B-P020`: `Form_Alg(Σ) ≅ Form_Cgr(Σ)`. -/

/-- `B-P015` gives that `F_𝔉` is an algebra formation when `𝔉` is a congruence
formation, so `θ_Σ⁻¹` maps into `Form_Alg(Σ)`. -/
theorem algebraFormationOfCongruenceFormation_isAlgebraFormation {S : Type u}
    (Sig : Signature S) {G : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (hG : IsCongruenceFormation Sig G) :
    IsAlgebraFormation Sig (algebraFormationOfCongruenceFormation Sig G) :=
  ⟨algebraFormationOfCongruenceFormation_HOperator Sig hG,
   algebraFormationOfCongruenceFormation_PFsdOperator Sig hG⟩

/-- `B-P020`: `𝔉_F` is monotone in `F` (order preservation of `θ_Σ`). -/
theorem congruenceFormationOf_mono {S : Type u} (Sig : Signature S)
    {F F' : Set (Alg Sig)} (h : F ⊆ F') :
    ∀ A, congruenceFormationOf Sig F A ⊆ congruenceFormationOf Sig F' A := by
  rintro A Φ ⟨hΦ, hΦF⟩
  exact ⟨hΦ, h hΦF⟩

/-- `B-P020`: `F_𝔉` is monotone in `𝔉` (order preservation of `θ_Σ⁻¹`). -/
theorem algebraFormationOfCongruenceFormation_mono {S : Type u} (Sig : Signature S)
    {G G' : (A : SSet S) → Set (SortedEqv (Term Sig A))}
    (h : ∀ A, G A ⊆ G' A) :
    algebraFormationOfCongruenceFormation Sig G ⊆
      algebraFormationOfCongruenceFormation Sig G' := by
  rintro C ⟨A, Φ, hΦ, hΦG, f, hf⟩
  exact ⟨A, Φ, hΦ, h A hΦG, f, hf⟩

/-- `Form_Cgr(Σ)`, the set of formations of `Σ`-congruences. -/
def congruenceFormations {S : Type u} (Sig : Signature S) :
    Set ((A : SSet S) → Set (SortedEqv (Term Sig A))) :=
  {G | IsCongruenceFormation Sig G}

/-- `B-P020`: `θ_Σ : Form_Alg(Σ) → Form_Cgr(Σ)`, `F ↦ 𝔉_F` (`B-P019`). -/
def thetaSigma {S : Type u} (Sig : Signature S) :
    algebraFormations Sig → congruenceFormations Sig :=
  fun F => ⟨congruenceFormationOf Sig F.1,
    congruenceFormation_isCongruenceFormation Sig F.2⟩

/-- `B-P020`: `θ_Σ⁻¹ : Form_Cgr(Σ) → Form_Alg(Σ)`, `𝔉 ↦ F_𝔉` (`B-P015`). -/
def thetaSigmaInv {S : Type u} (Sig : Signature S) :
    congruenceFormations Sig → algebraFormations Sig :=
  fun G => ⟨algebraFormationOfCongruenceFormation Sig G.1,
    algebraFormationOfCongruenceFormation_isAlgebraFormation Sig G.2⟩

theorem thetaSigma_left_inv {S : Type u} (Sig : Signature S) (F : algebraFormations Sig) :
    thetaSigmaInv Sig (thetaSigma Sig F) = F :=
  Subtype.ext (algebraFormationOfCongruenceFormation_congruenceFormationOf Sig F.2)

theorem thetaSigma_right_inv {S : Type u} (Sig : Signature S) (G : congruenceFormations Sig) :
    thetaSigma Sig (thetaSigmaInv Sig G) = G :=
  Subtype.ext (congruenceFormationOf_algebraFormationOfCongruenceFormation Sig G.2)

/-- `B-P020` (`FormAlgFormCgrIso`): `Form_Alg(Σ)` and `Form_Cgr(Σ)`, ordered by
inclusion (pointwise for congruence formations), are isomorphic. The bijection is
`θ_Σ : F ↦ 𝔉_F` with inverse `𝔉 ↦ F_𝔉` (the two round trips); both directions are
order-preserving, hence (the posets being the complete lattices of `B-P018` /
`B-C005`) the complete lattices are isomorphic. -/
def formAlgFormCgrIso {S : Type u} (Sig : Signature S) :
    algebraFormations Sig ≃o congruenceFormations Sig where
  toFun := thetaSigma Sig
  invFun := thetaSigmaInv Sig
  left_inv := thetaSigma_left_inv Sig
  right_inv := thetaSigma_right_inv Sig
  map_rel_iff' := by
    intro F F'
    constructor
    · intro h
      have h' : ∀ A, congruenceFormationOf Sig F.1 A ⊆ congruenceFormationOf Sig F'.1 A := h
      have h1 := algebraFormationOfCongruenceFormation_mono Sig h'
      rw [algebraFormationOfCongruenceFormation_congruenceFormationOf Sig F.2,
          algebraFormationOfCongruenceFormation_congruenceFormationOf Sig F'.2] at h1
      exact h1
    · intro h
      exact congruenceFormationOf_mono Sig h

end Mslang
