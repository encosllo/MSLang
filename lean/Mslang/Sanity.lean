import Mslang.Pilot

/-!
Formal sanity checks (Architecture.md Section 11.3): read-back alone misses
errors where a formal statement *reads* correctly but means something
degenerate.  Each audited block therefore also carries lightweight formal
checks:

* **Non-vacuity** -- an explicit instance showing the hypotheses are jointly
  satisfiable, so a theorem is not vacuously true.
* **Definition examples** -- concrete evaluations of the new definitions.
* **Negation probes** -- a bounded attempt to disprove; a found counterexample
  to a plausible-but-false variant is a positive result.
* **Convention checks** -- degenerate/edge cases (empty components, two-element
  components).

A fixed two-sort, two-element model keeps the checks concrete.
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

/-- A concrete sorted set: singleton at `true`, two-element at `false`. -/
def exA : SSorted Two Bool := fun b => if b then {true} else {true, false}

/-- Definition example: the support of `exA` is every sort. -/
example : supp exA = Set.univ := by
  ext b
  cases b <;> simp [exA, supp]

/-- Convention check / negation probe: `exA` is **not** subfinal, because the
`false` component has two distinct elements. -/
theorem sanity_not_subfinal : ¬ Subfinal exA := by
  intro h
  have hf : (exA false).Subsingleton := h false
  have h1 : (true : Bool) ∈ exA false := by simp [exA]
  have h2 : (false : Bool) ∈ exA false := by simp [exA]
  exact absurd (hf h1 h2) (by decide)

/-- Non-vacuity: an instance in which the hypotheses of Corollary `B-C001`
(`sat_antitone`) are jointly satisfiable and its conclusion holds -- so the
corollary is not vacuously true. -/
theorem sanity_nonvacuous :
    ∃ (A : SSorted Two Bool) (Φ Ψ : SortedEqv A) (X : ∀ s, Set (A s)),
      sortedEqvLe Φ Ψ ∧ IsSat Ψ X ∧ IsSat Φ X := by
  refine ⟨exA, (fun _ => discrete), (nabla exA),
          (fun s => (∅ : Set (exA s))), ?_, nabla_sat_empty, ?_⟩
  · intro s x y _
    trivial
  · unfold IsSat
    funext s
    ext a
    simp [sat, discrete_r]

/-- Negation probe: `sat_antitone`'s implication is one-directional. With `Φ`
discrete (finest) and `Ψ` universal (coarsest), a family can be `Φ`-saturated
but not `Ψ`-saturated -- so the converse inclusion `Φ-Sat ⊆ Ψ-Sat` is false. -/
theorem sanity_converse_counterexample :
    ∃ (Φ Ψ : SortedEqv exA) (X : ∀ s, Set (exA s)),
      IsSat Φ X ∧ ¬ IsSat Ψ X := by
  refine ⟨(fun _ => discrete), (nabla exA),
          (fun s => {⟨true, by cases s <;> simp [exA]⟩}), ?_, ?_⟩
  · unfold IsSat
    funext s
    ext a
    simp [sat, discrete_r]
  · intro h
    have hf := congrFun h false
    have hmem :
        (⟨false, by simp [exA]⟩ : exA false) ∈
          sat (nabla exA) (fun s => {⟨true, by cases s <;> simp [exA]⟩}) false := by
      refine ⟨⟨true, by simp [exA]⟩, ?_, trivial⟩
      simp
    rw [hf] at hmem
    simp only [Set.mem_singleton_iff, Subtype.ext_iff] at hmem
    exact absurd hmem (by decide)

end Mslang
