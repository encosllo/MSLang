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

end Mslang
