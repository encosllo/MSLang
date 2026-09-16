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

end Mslang
