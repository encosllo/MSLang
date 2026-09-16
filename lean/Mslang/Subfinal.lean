import Mslang.Congruence

/-!
Subfinal `Σ`-algebras: the final algebra `1`, algebra isomorphisms, subalgebras
as algebras, and the subfinal results `B-D023`, `B-P008`, `B-R011`, `B-R012`.
-/

universe u

-- The `haveI`s in `subfinalAlg_iff` (`B-P008`) install `Subsingleton`
-- instances used by the following tactic; the style linter's `have`
-- suggestion would not register them, so it is a false positive here.
set_option linter.style.haveILetI false

namespace Mslang

variable {S : Type u}


/-! ### `B-D023`: subfinal `Σ`-algebras (and the algebra-local vocabulary). -/

/-- The final `Σ`-algebra `1 = (1^S, F)`: the constant one-element sorted set
with the unique operations. -/
def finalAlg {S : Type u} (Sig : Signature S) : Alg Sig :=
  ⟨finalSorted S, fun _ _ _ => PUnit.unit⟩

/-- An isomorphism of `Σ`-algebras: a sortwise-bijective homomorphism. (Its
inverse is automatically a homomorphism.) -/
def IsAlgIso {S : Type u} (Sig : Signature S) {A B : SSet S}
    (FA : AlgStruct Sig A) (FB : AlgStruct Sig B) (f : SortedMap A B) : Prop :=
  IsAlgHom Sig FA FB f ∧ ∀ s, Function.Bijective (f s)

/-- A subalgebra `X ≤ A`, regarded as a `Σ`-algebra in its own right. -/
def subAlg {S : Type u} (Sig : Signature S) {A : SSet S} (F : AlgStruct Sig A)
    (X : Sub A) (hX : IsSubalgebra Sig F X) : Alg Sig :=
  ⟨fun s => {a : A s // a ∈ X s},
   fun p σ b => ⟨F p σ (fun i => (b i).1),
     hX p σ (fun i => (b i).1) (fun i => (b i).2)⟩⟩

/-- `B-D023`: a `Σ`-algebra is subfinal when it is isomorphic to a subalgebra
of the final `Σ`-algebra `1`. -/
def SubfinalAlg {S : Type u} (Sig : Signature S) (X : Alg Sig) : Prop :=
  ∃ (Y : Sub (finalAlg Sig).1) (hY : IsSubalgebra Sig (finalAlg Sig).2 Y)
    (f : SortedMap X.1 (subAlg Sig (finalAlg Sig).2 Y hY).1),
    IsAlgIso Sig X.2 (subAlg Sig (finalAlg Sig).2 Y hY).2 f

/-- Proposition `B-P008`: a `Σ`-algebra is subfinal if and only if its
underlying `S`-sorted set is subfinal (`card ≤ 1` componentwise). -/
theorem subfinalAlg_iff {S : Type u} (Sig : Signature S) (X : Alg Sig) :
    SubfinalAlg Sig X ↔ Subfinal X.1 := by
  constructor
  · rintro ⟨_Y, _hY, f, hf⟩ s
    haveI : Subsingleton ((finalAlg Sig).1 s) := inferInstanceAs (Subsingleton PUnit)
    refine ⟨fun a b => (hf.2 s).1 ?_⟩
    exact Subtype.ext (Subsingleton.elim (f s a).1 (f s b).1)
  · intro hX
    let Y : Sub (finalAlg Sig).1 := fun s => {q : PUnit | Nonempty (X.1 s)}
    have hY : IsSubalgebra Sig (finalAlg Sig).2 Y := by
      intro p σ _b hb
      exact ⟨X.2 p σ (fun i =>
        Classical.choice (show Nonempty (X.1 (p.1.get i)) from hb i))⟩
    refine ⟨Y, hY, (fun _s a => ⟨PUnit.unit, ⟨a⟩⟩), ?_⟩
    refine ⟨?_, ?_⟩
    · intro p σ a
      exact Subtype.ext rfl
    · intro s
      haveI : Subsingleton (X.1 s) := hX s
      haveI : Subsingleton ((finalAlg Sig).1 s) := inferInstanceAs (Subsingleton PUnit)
      refine ⟨fun a b _ => Subsingleton.elim a b, ?_⟩
      intro y
      exact ⟨Classical.choice (show Nonempty (X.1 s) from y.2),
             Subtype.ext (Subsingleton.elim _ _)⟩

/-- `∇^A` (the greatest sorted equivalence) is a congruence on any
`Σ`-algebra. -/
theorem nabla_isCongruence {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) : IsCongruence Sig F (nabla A) := by
  intro _p _σ _a _b _
  trivial

/-- Remark `B-R012`: the quotient of `A` by the greatest congruence `∇^A` is
subfinal (`A/∇^A` is isomorphic to a subalgebra of `1`). -/
theorem quot_nabla_subfinal {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) :
    SubfinalAlg Sig (quotAlg Sig F (nabla A) (nabla_isCongruence Sig F)) := by
  rw [subfinalAlg_iff]
  intro s
  refine ⟨fun x y => ?_⟩
  induction x using Quotient.inductionOn with
  | _ a =>
    induction y using Quotient.inductionOn with
    | _ b => exact Quotient.sound trivial

/-- Remark `B-R011`: if `A` is subfinal, then for every `Σ`-algebra `B` there is
at most one homomorphism from `B` to `A`. (Any two sort-preserving maps already
agree, since every component of `A` is a subsingleton; the homomorphism
hypotheses make the statement the contract's.) -/
theorem hom_unique_of_subfinalAlg {S : Type u} (Sig : Signature S) {A B : SSet S}
    (FA : AlgStruct Sig A) (FB : AlgStruct Sig B)
    (hA : SubfinalAlg Sig ⟨A, FA⟩) (f g : SortedMap B A)
    (_hf : IsAlgHom Sig FB FA f) (_hg : IsAlgHom Sig FB FA g) : f = g := by
  rw [subfinalAlg_iff] at hA
  funext s x
  haveI : Subsingleton (A s) := hA s
  exact Subsingleton.elim (f s x) (g s x)

end Mslang
