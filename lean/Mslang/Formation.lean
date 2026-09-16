import Mslang.Subfinal

/-!
Subdirect products and subdirect embeddings of `Σ`-algebras (`B-D028`), the
opening of the formation-theoretic layer.
-/

universe u

namespace Mslang

variable {S : Type u}

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

end Mslang
