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

/-- Pointwise meet of two sorted equivalences (the paper's `Φ ∩ Ψ`). -/
@[instance_reducible]
def sortedEqvInf {A : SSorted S U} (Φ Ψ : SortedEqv A) : SortedEqv A :=
  fun s =>
    ⟨fun x y => (Φ s).r x y ∧ (Ψ s).r x y,
     ⟨fun x => ⟨(Φ s).refl x, (Ψ s).refl x⟩,
      fun h => ⟨(Φ s).symm h.1, (Ψ s).symm h.2⟩,
      fun hab hbc => ⟨(Φ s).trans hab.1 hbc.1, (Ψ s).trans hab.2 hbc.2⟩⟩⟩

theorem sortedEqvInf_le_left {A : SSorted S U} (Φ Ψ : SortedEqv A) :
    sortedEqvLe (sortedEqvInf Φ Ψ) Φ := fun _ _ _ h => h.1

theorem sortedEqvInf_le_right {A : SSorted S U} (Φ Ψ : SortedEqv A) :
    sortedEqvLe (sortedEqvInf Φ Ψ) Ψ := fun _ _ _ h => h.2

/-- Corollary `B-C002`: `Φ-Sat(A) ∩ Ψ-Sat(A) ⊆ (Φ ∩ Ψ)-Sat(A)`.

Since `Φ ∩ Ψ` refines `Φ`, a `Φ`-saturated set is `(Φ ∩ Ψ)`-saturated by
`sat_antitone`. -/
theorem sat_inf {A : SSorted S U} {Φ Ψ : SortedEqv A} {X : ∀ s, Set (A s)}
    (hΦ : IsSat Φ X) (_hΨ : IsSat Ψ X) :
    IsSat (sortedEqvInf Φ Ψ) X :=
  sat_antitone (sortedEqvInf_le_left Φ Ψ) hΦ

/-- Delta of Kronecker (Definition `B-D006`): `δ^t_s = 1` if `s = t`, `∅`
otherwise. Following the encoding, `1` is the whole ambient `U`, so this is
faithful for the support (with `U` nonempty) but the component is the whole
ambient, not a chosen singleton (residual D2). -/
noncomputable def delta (t : S) : SSorted S U :=
  by classical exact fun s => if s = t then Set.univ else ∅

/-- Bridge `delta_support`: `supp_S(δ^t) = {t}` (requires the ambient `U` to be
nonempty, as the paper's universe is). -/
theorem supp_delta {U' : Type u} [Nonempty U'] (t : S) :
    supp (delta (U := U') t) = {t} := by
  classical
  ext s
  constructor
  · intro hs
    change (delta (U := U') t s).Nonempty at hs
    by_contra h
    have hne : ¬ (s = t) := by simpa using h
    have hz : delta (U := U') t s = ∅ := by simp [delta, hne]
    rw [hz] at hs
    exact Set.not_nonempty_empty hs
  · intro hs
    have hst : s = t := by simpa using hs
    rw [hst]
    change (delta (U := U') t t).Nonempty
    have hd : delta (U := U') t t = (Set.univ : Set U') := by simp [delta]
    rw [hd]
    exact ⟨Classical.choice (inferInstance : Nonempty U'), Set.mem_univ _⟩

/-- Definition `B-D004`: an `S`-sorted set is *subfinal* when every component
has at most one element; `1^S` and `∅^S` are the final and initial `S`-sorted
sets. -/
def Subfinal (A : SSorted S U) : Prop := ∀ s, (A s).Subsingleton

def finalSorted : SSorted S U := fun _ => Set.univ

def initialSorted : SSorted S U := fun _ => ∅

/-- Bridge `card_le_one_iff`: subfinality coincides with every component having
cardinality at most one (`encard` covers the infinite case). -/
theorem card_le_one_iff (A : SSorted S U) :
    Subfinal A ↔ ∀ s, (A s).encard ≤ 1 := by
  simp [Subfinal, Set.encard_le_one_iff_subsingleton]

theorem supp_finalSorted [Nonempty U] :
    supp (finalSorted (S := S) (U := U)) = Set.univ := by
  ext s
  constructor
  · intro _; exact Set.mem_univ s
  · intro _
    exact ⟨Classical.choice (inferInstance : Nonempty U), Set.mem_univ _⟩

theorem supp_initialSorted :
    supp (initialSorted (S := S) (U := U)) = ∅ := by
  ext s
  simp [supp, initialSorted]

/-- Projection `pr^Φ` to the quotient, sortwise. -/
def pr {A : SSorted S U} (Φ : SortedEqv A) (s : S) : A s → Quotient (Φ s) :=
  fun x => Quotient.mk (Φ s) x

/-- Bridge `sat_eq_preimage` (Remark `B-R006`): the `Φ`-saturation of `X` is
`(pr^Φ)⁻¹[pr^Φ[X]]`. -/
theorem sat_eq_preimage {A : SSorted S U} (Φ : SortedEqv A) (X : ∀ s, Set (A s)) :
    sat Φ X = fun s => (pr Φ s) ⁻¹' ((pr Φ s) '' X s) := by
  funext s
  ext a
  simp only [sat, pr, Set.mem_preimage, Set.mem_image, Set.mem_ofPred_eq]
  constructor
  · rintro ⟨x, hx, hxa⟩
    exact ⟨x, hx, Quotient.eq.mpr hxa⟩
  · rintro ⟨x, hx, h⟩
    exact ⟨x, hx, Quotient.eq.mp h⟩

/-- Bridge `sat_eq_preimage`, second part (Remark `B-R006`): `X` is
`Φ`-saturated if and only if it is the preimage under `pr^Φ` of some family
`Y ⊆ A/Φ`. -/
theorem isSat_iff_preimage {A : SSorted S U} (Φ : SortedEqv A)
    (X : ∀ s, Set (A s)) :
    IsSat Φ X ↔
      ∃ Y : ∀ s, Set (Quotient (Φ s)), X = fun s => (pr Φ s) ⁻¹' (Y s) := by
  constructor
  · intro h
    refine ⟨fun s => (pr Φ s) '' X s, ?_⟩
    unfold IsSat at h
    rw [← sat_eq_preimage Φ X]
    exact h.symm
  · rintro ⟨Y, hX⟩
    unfold IsSat
    rw [sat_eq_preimage, hX]
    funext s
    ext a
    constructor
    · intro ha
      rcases (Set.mem_image _ _ _).mp (Set.mem_preimage.mp ha) with ⟨x, hx, hxeq⟩
      exact Set.mem_preimage.mpr (hxeq ▸ Set.mem_preimage.mp hx)
    · intro ha
      exact Set.mem_preimage.mpr
        ((Set.mem_image _ _ _).mpr
          ⟨a, Set.mem_preimage.mpr (Set.mem_preimage.mp ha), rfl⟩)

/-- The family `⋃_{t∈T} δ^{t,A_t}`: at sort `s` it is all of `A_s` when `s ∈ T`,
and empty otherwise. -/
noncomputable def deltaUnion (T : Set S) (A : SSorted S U) : ∀ s, Set (A s) :=
  by classical exact fun s => if s ∈ T then (Set.univ : Set (A s)) else ∅

/-- Remark `B-R008`: `∅^S`, `A ∈ ∇^A-Sat(A)`, and `⋃_{t∈T} δ^{t,A_t} ∈
∇^A-Sat(A)` for every `T ⊆ S`. -/
theorem nabla_sat_empty {A : SSorted S U} :
    IsSat (nabla A) (fun s => (∅ : Set (A s))) := by
  unfold IsSat
  funext s
  ext a
  simp [sat]

theorem nabla_sat_univ {A : SSorted S U} :
    IsSat (nabla A) (fun s => (Set.univ : Set (A s))) := by
  unfold IsSat
  funext s
  ext a
  simp only [sat]
  constructor
  · intro _; exact Set.mem_univ a
  · intro _
    exact ⟨a, Set.mem_univ a, trivial⟩

theorem nabla_sat_deltaUnion {A : SSorted S U} (T : Set S) :
    IsSat (nabla A) (deltaUnion T A) := by
  rw [nabla_sat]
  intro s hs
  by_cases hT : s ∈ T
  · simp [deltaUnion, hT]
  · simp [deltaUnion, suppSub, hT] at hs

/-- Relative complement `∁_A X`, componentwise inside `A` -- addressing the
`R-complement` residual: complement is taken in `A_s` (`Set.compl` on the
subtype), never in the ambient `U`. -/
def complA {A : SSorted S U} (X : ∀ s, Set (A s)) : ∀ s, Set (A s) :=
  fun s => (X s)ᶜ

theorem complA_bridge {A : SSorted S U} (X : ∀ s, Set (A s)) (s : S) (a : A s) :
    a ∈ complA X s ↔ a ∉ X s := by
  simp [complA]

end Mslang
