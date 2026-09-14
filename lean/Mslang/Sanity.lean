import Mslang.Pilot

/-!
Formal sanity checks (Architecture.md Section 11.3) under the dependent-type
carrier model: a concrete two-sort model (`exA` at both sorts is `Bool`).
-/

universe u

namespace Mslang

/-- Two sorts. -/
abbrev Two : Type := Bool

/-- The discrete (equality) equivalence relation. -/
def discrete {α : Type u} : Setoid α :=
  ⟨Eq, ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => Eq.trans h1 h2⟩⟩

@[simp] theorem discrete_r {α : Type u} (x y : α) :
    (discrete : Setoid α).r x y ↔ x = y := Iff.rfl

/-- A concrete sorted set: the constant type `Bool`. -/
abbrev exA : SSet Two := fun _ => Bool

/-- Definition example: the support of `exA` is every sort. -/
example : supp exA = Set.univ := by
  ext s
  constructor
  · intro _; exact Set.mem_univ s
  · intro _; exact ⟨(true : Bool)⟩

/-- Convention check / negation probe: `exA` is **not** subfinal, because each
component `Bool` has two distinct elements. -/
theorem sanity_not_subfinal : ¬ Subfinal exA := by
  intro h
  have e : (true : Bool) = false :=
    @Subsingleton.elim (exA false) (h false) true false
  exact absurd e (by decide)

/-- Non-vacuity: an instance in which the hypotheses of Corollary `B-C001`
are jointly satisfiable and its conclusion holds. -/
theorem sanity_nonvacuous :
    ∃ (A : SSet Two) (Φ Ψ : SortedEqv A) (X : Sub A),
      sortedEqvLe Φ Ψ ∧ IsSat Ψ X ∧ IsSat Φ X := by
  refine ⟨exA, (fun _ => discrete), (nabla exA), (fun s => (∅ : Set (exA s))),
          ?_, nabla_sat_empty, ?_⟩
  · intro s x y _
    trivial
  · unfold IsSat
    funext s
    ext a
    simp [sat, discrete_r]

/-- Negation probe: the converse inclusion `Φ-Sat ⊆ Ψ-Sat` is false; with `Φ`
discrete and `Ψ` universal, `{true}` is `Φ`-saturated but not `Ψ`-saturated. -/
theorem sanity_converse_counterexample :
    ∃ (Φ Ψ : SortedEqv exA) (X : Sub exA), IsSat Φ X ∧ ¬ IsSat Ψ X := by
  refine ⟨(fun _ => discrete), (nabla exA), (fun s => ({true} : Set (exA s))), ?_, ?_⟩
  · unfold IsSat
    funext s
    ext a
    simp [sat, discrete_r]
  · intro h
    have hf := congrFun h false
    have hmem :
        (false : exA false) ∈
          sat (nabla exA) (fun s => ({true} : Set (exA s))) false :=
      ⟨true, Set.mem_singleton_iff.mpr rfl, trivial⟩
    rw [hf] at hmem
    rw [Set.mem_singleton_iff] at hmem
    exact absurd hmem (by decide)

end Mslang
