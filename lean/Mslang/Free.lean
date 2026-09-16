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

end Mslang
