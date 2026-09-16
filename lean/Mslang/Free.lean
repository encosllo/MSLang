import Mslang.Subfinal

/-!
The free `Σ`-algebra layer: the algebra of `Σ`-rows `W_Σ(X)` (`B-D026`) and the
free `Σ`-algebra `T_Σ(X)` with its insertion `η^X` (`B-D027`).
-/

universe u

namespace Mslang

variable {S : Type u}


/-! ### `B-D026`: the algebra of `Σ`-rows `W_Σ(X)`. -/

/-- `∐Σ`, the disjoint union of the operation sets of a signature. -/
abbrev SigElem {S : Type u} (Sig : Signature S) := Σ p : List S × S, Sig p

/-- `∐X`, the disjoint union of the sort components of an `S`-sorted set. -/
abbrev XElem {S : Type u} (X : SSet S) := Σ s : S, X s

/-- The alphabet `∐Σ ⨿ ∐X` of `Σ`-rows. -/
abbrev RowAlpha {S : Type u} (Sig : Signature S) (X : SSet S) := SigElem Sig ⊕ XElem X

/-- `B-D026`: the underlying `S`-sorted set `W_Σ(X)`, constantly the set of words
on the alphabet `∐Σ ⨿ ∐X`. -/
abbrev WSet {S : Type u} (Sig : Signature S) (X : SSet S) : SSet S :=
  fun _ => List (RowAlpha Sig X)

/-- `B-D026`: the algebra of `Σ`-rows `W_Σ(X)`. The structural operation for
`σ : Σ_{w,s}` sends `(P_i)_{i∈|w|}` to the word `σ : P₀ ⧺ … ⧺ P_{|w|-1}`. -/
def WAlg {S : Type u} (Sig : Signature S) (X : SSet S) : Alg Sig :=
  ⟨WSet Sig X,
   fun p σ a => Sum.inl (⟨p, σ⟩ : SigElem Sig) :: (List.ofFn a).flatten⟩

/-- `B-D027`: the generators of `T_Σ(X)` inside `W_Σ(X)`: the one-letter words
`(x) = [(x)]`, at sort `s` for `x : X s`. -/
def genSet {S : Type u} (Sig : Signature S) (X : SSet S) : Sub (WSet Sig X) :=
  fun s P => ∃ x : X s, P = [Sum.inr (⟨s, x⟩ : XElem X)]

/-- `B-D027`: the free `Σ`-algebra `T_Σ(X)`, the subalgebra of `W_Σ(X)` generated
by the generators `(x)`. -/
def TAlg {S : Type u} (Sig : Signature S) (X : SSet S) : Alg Sig :=
  subAlg Sig (WAlg Sig X).2 (Sg Sig (WAlg Sig X).2 (genSet Sig X))
    (Sg_isSubalgebra Sig (WAlg Sig X).2 (genSet Sig X))

/-- `B-D027`: the underlying `S`-sorted set `T_Σ(X)`; its elements are the terms
of `X` with variables in `X`. -/
abbrev TSet {S : Type u} (Sig : Signature S) (X : SSet S) : SSet S :=
  (TAlg Sig X).1

/-- `B-D027`: the insertion of the generators `η^X : X → T_Σ(X)`, `x ↦ (x)`. -/
def etaX {S : Type u} (Sig : Signature S) (X : SSet S) : SortedMap X (TSet Sig X) :=
  fun s x =>
    ⟨[Sum.inr (⟨s, x⟩ : XElem X)],
     subset_Sg Sig (WAlg Sig X).2 (genSet Sig X) s ⟨x, rfl⟩⟩

/-- Lemma `B-L001`: two homomorphisms `T_Σ(X) → A` that agree on the inserted
generators are equal. Every element of `T_Σ(X)` is a generated row, so this is
an induction over `MemSg`: the generator case is the hypothesis, and the
operation case uses the two homomorphism equations and the induction hypothesis. -/
theorem TAlg_hom_ext {S : Type u} (Sig : Signature S) (X : SSet S) {A : SSet S}
    (FA : AlgStruct Sig A) (f g : SortedMap (TAlg Sig X).1 A)
    (hf : IsAlgHom Sig (TAlg Sig X).2 FA f)
    (hg : IsAlgHom Sig (TAlg Sig X).2 FA g)
    (hη : (fun s => f s ∘ etaX Sig X s) = (fun s => g s ∘ etaX Sig X s)) :
    f = g := by
  funext s P
  obtain ⟨P, hP⟩ := P
  induction hP with
  | hyp s P hgen =>
      obtain ⟨x, rfl⟩ := hgen
      have hx := congrFun (congrFun hη s) x
      simp only [Function.comp_apply, etaX] at hx
      convert hx
  | op p σ a hrec ih =>
      have hf' := hf p σ (fun i => (⟨a i, hrec i⟩ : (TAlg Sig X).1 (p.1.get i)))
      have hg' := hg p σ (fun i => (⟨a i, hrec i⟩ : (TAlg Sig X).1 (p.1.get i)))
      rw [show (⟨(WAlg Sig X).2 p σ a, MemSg.op p σ a hrec⟩ : (TAlg Sig X).1 p.2) =
            (TAlg Sig X).2 p σ (fun i => ⟨a i, hrec i⟩) from Subtype.ext rfl,
          hf', hg']
      congr 1
      funext i
      exact ih i

end Mslang
