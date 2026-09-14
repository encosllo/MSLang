import Mathlib

/-!
Pilot encoding for `MSEilenberg.tex`, following
`representation/pilot-encoding.md` (Architecture.md Sections 6, 11.5).

The paper's foundation (ZFSK + a Grothendieck universe) is encoded against a
**fixed ambient** `U`: an `S`-sorted set is a family of subsets of `U`, and a
sorted equivalence is a componentwise `Setoid`.  This is the `faithful-with-caveat`
carrier model (residual D2 of the encoding audit `E-000002`).

What is here:

* the pilot definitions (`SSorted`, `SortedEqv`, pointwise inclusion, saturated
  sets `Sat`);
* the first formal target, Corollary `B-C001` / `sat_antitone`:
  `Φ ⊆ Ψ → Ψ-Sat(A) ⊆ Φ-Sat(A)`;
* the forward direction of Proposition `B-P002` (`sat_sat_eq`), used by the
  manuscript's own proof of `B-C001`.

The converse of `B-P002` and the remaining bridge obligations
(`sat_eq_preimage`, `card_le_one_iff`, `delta_support`) are not yet proved.
-/

universe u

namespace Mslang

variable {S : Type u} {U : Type u}

/-- An `S`-sorted set as a family of subsets of a fixed ambient `U`
(encoding caveat D2: components are not arbitrary small carriers). -/
abbrev SSorted (S : Type u) (U : Type u) := S → Set U

/-- Pointwise (componentwise) inclusion of `S`-sorted sets. -/
def le (A B : SSorted S U) : Prop := ∀ s, A s ⊆ B s

/-- A sorted equivalence on `A`: a componentwise `Setoid` on each `A s`. -/
abbrev SortedEqv (A : SSorted S U) := ∀ s, Setoid (A s)

/-- Pointwise refinement of sorted equivalences: the paper's `Φ ⊆ Ψ`. -/
def sortedEqvLe {A : SSorted S U} (Φ Ψ : SortedEqv A) : Prop :=
  ∀ s (x y : A s), (Φ s).r x y → (Ψ s).r x y

/-- Saturation `[X]^Φ` of a componentwise `X ⊆ A`, as a componentwise set. -/
def sat {A : SSorted S U} (Φ : SortedEqv A) (X : ∀ s, Set (A s)) :
    ∀ s, Set (A s) :=
  fun s => {a | ∃ x ∈ X s, (Φ s).r x a}

/-- `X` is `Φ`-saturated, i.e. `X = [X]^Φ`. -/
def IsSat {A : SSorted S U} (Φ : SortedEqv A) (X : ∀ s, Set (A s)) : Prop :=
  sat Φ X = X

/-- Corollary `B-C001` (`IncSat`): `Φ ⊆ Ψ` implies `Ψ-Sat(A) ⊆ Φ-Sat(A)`.

Paper proof (via `B-P002`) and direct proof both work; this is the direct one.
If `X` is `Ψ`-saturated then `[X]^Φ ⊆ [X]^Ψ = X`, and `X ⊆ [X]^Φ` by
reflexivity, so `X` is `Φ`-saturated. -/
theorem sat_antitone {A : SSorted S U} {Φ Ψ : SortedEqv A}
    (h : sortedEqvLe Φ Ψ) {X : ∀ s, Set (A s)} (hX : IsSat Ψ X) :
    IsSat Φ X := by
  unfold IsSat at *
  funext s
  ext a
  constructor
  · intro ha
    rcases ha with ⟨x, hx, hxr⟩
    rw [← hX]
    exact ⟨x, hx, h s x a hxr⟩
  · intro ha
    exact ⟨a, ha, (Φ s).refl a⟩

/-- Proposition `B-P002` (`PropIncSat`), forward direction:
if `Φ ⊆ Ψ` then `[[X]^Ψ]^Φ = [X]^Ψ` for every `X`. -/
theorem sat_sat_eq {A : SSorted S U} {Φ Ψ : SortedEqv A}
    (h : sortedEqvLe Φ Ψ) (X : ∀ s, Set (A s)) :
    sat Φ (sat Ψ X) = sat Ψ X := by
  funext s
  ext a
  constructor
  · intro ha
    rcases ha with ⟨y, hy, hyr⟩
    rcases hy with ⟨x, hx, hxr⟩
    exact ⟨x, hx, (Ψ s).trans hxr (h s y a hyr)⟩
  · intro ha
    rcases ha with ⟨x, hx, hxr⟩
    exact ⟨a, ⟨x, hx, hxr⟩, (Φ s).refl a⟩

/-- Bridge `setoid_le_iff`: under this encoding, pointwise setoid refinement
`sortedEqvLe` *is* inclusion of the underlying relations, so the paper's
`Φ ⊆ Ψ` is the Lean order definitionally. -/
theorem setoid_le_iff {A : SSorted S U} (Φ Ψ : SortedEqv A) :
    sortedEqvLe Φ Ψ ↔
      ∀ s (x y : A s), (Φ s).r x y → (Ψ s).r x y :=
  Iff.rfl

/-- Proposition `B-P002` (`PropIncSat`), full statement:
`Φ ⊆ Ψ` iff `[[X]^Ψ]^Φ = [X]^Ψ` for every `X`.

The converse uses a singleton test family at the sort `s` in question:
`sortedEqvLe Φ Ψ` follows by applying the hypothesis to `X` with
`X s = {x}`, so that `sat Ψ X s` is the `Ψ s`-class of `x`. -/
theorem prop_incSat {A : SSorted S U} (Φ Ψ : SortedEqv A) :
    sortedEqvLe Φ Ψ ↔
      ∀ X : ∀ s, Set (A s), sat Φ (sat Ψ X) = sat Ψ X := by
  classical
  constructor
  · intro h X
    exact sat_sat_eq h X
  · intro h s x y hxy
    let X : ∀ t, Set (A t) :=
      Function.update (fun t => (∅ : Set (A t))) s {x}
    have hXs : X s = {x} := by simp [X]
    have hx : x ∈ sat Ψ X s :=
      ⟨x, by rw [hXs]; exact Set.mem_singleton_iff.mpr rfl, (Ψ s).refl x⟩
    have hy : y ∈ sat Φ (sat Ψ X) s := ⟨x, hx, hxy⟩
    rw [h X] at hy
    rcases hy with ⟨z, hz, hzy⟩
    rw [hXs, Set.mem_singleton_iff] at hz
    subst hz
    exact hzy

/-- `∇^A`: the greatest sorted equivalence on `A` (the universal relation). -/
@[instance_reducible]
def nabla (A : SSorted S U) : SortedEqv A :=
  fun _ =>
    ⟨fun _ _ => True,
     ⟨fun _ => trivial, fun _ => trivial, fun _ _ => trivial⟩⟩

/-- Support of an `S`-sorted set (Definition `B-D009`):
`supp_S(A) = {s ∈ S | A_s ≠ ∅}`. -/
def supp (A : SSorted S U) : Set S := {s | (A s).Nonempty}

/-- Support of a componentwise `X ⊆ A` (the `Sub(A)` presentation of `B-D009`). -/
def suppSub {A : SSorted S U} (X : ∀ s, Set (A s)) : Set S :=
  {s | (X s).Nonempty}

/-- Proposition `B-P003` (`NablaSat`): `X ∈ ∇^A-Sat(A)` if and only if every
sort in the support of `X` carries all of `A`. Under the universal relation the
saturation of `X_s` is `A_s` when `X_s ≠ ∅` and `∅` otherwise, so `X` is
`∇`-saturated exactly when each nonempty component is full. -/
theorem nabla_sat {A : SSorted S U} (X : ∀ s, Set (A s)) :
    IsSat (nabla A) X ↔ ∀ s, s ∈ suppSub X → X s = Set.univ := by
  unfold IsSat
  constructor
  · intro h s hs
    have hsat : (sat (nabla A) X) s = X s :=
      congrArg (fun Y : ∀ s, Set (A s) => Y s) h
    ext a
    constructor
    · intro _
      exact Set.mem_univ a
    · intro _
      rcases hs with ⟨x, hx⟩
      rw [← hsat]
      exact ⟨x, hx, trivial⟩
  · intro h
    funext s
    ext a
    constructor
    · intro ha
      rcases ha with ⟨x, hx, _⟩
      have hXs : X s = Set.univ := h s ⟨x, hx⟩
      rw [hXs]
      exact Set.mem_univ a
    · intro ha
      exact ⟨a, ha, trivial⟩

end Mslang
