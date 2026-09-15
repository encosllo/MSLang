import Mathlib

/-!
Pilot encoding for `MSEilenberg.tex` under the **dependent-type carrier model**
(see `representation/pilot-encoding.md`): an `S`-sorted set is a family of
types `S → Type u`, not a family of subsets of a fixed ambient `U`.  This makes
`δ^t` a genuine one-element/empty family (residual `R-delta`) and keeps `A/Φ` in
the object class (residual `R-quotient`).

Object class: `SSet S := S → Type u`; componentwise subsets (`Sub`) are
families of predicates `∀ s, Set (A s)`.
-/

universe u

namespace Mslang

variable {S : Type u}

/-- An `S`-sorted set is a family of types indexed by the sorts. -/
abbrev SSet (S : Type u) : Type (u + 1) := S → Type u

/-- The componentwise subsets `Sub(A)` (`B-D005`): a family of predicates. -/
abbrev Sub {S : Type u} (A : SSet S) : Type u := ∀ s, Set (A s)

/-- Pointwise inclusion of componentwise subsets. -/
def Subset {S : Type u} {A : SSet S} (X Y : Sub A) : Prop := ∀ s, X s ⊆ Y s

/-- A sorted equivalence on `A`: a componentwise `Setoid`. -/
abbrev SortedEqv {S : Type u} (A : SSet S) : Type u := ∀ s, Setoid (A s)

/-- Pointwise refinement of sorted equivalences: the paper's `Φ ⊆ Ψ`. -/
def sortedEqvLe {S : Type u} {A : SSet S} (Φ Ψ : SortedEqv A) : Prop :=
  ∀ s (x y : A s), (Φ s).r x y → (Ψ s).r x y

/-- Saturation `[X]^Φ` of a componentwise `X ⊆ A`. -/
def sat {S : Type u} {A : SSet S} (Φ : SortedEqv A) (X : Sub A) : Sub A :=
  fun s => {a | ∃ x ∈ X s, (Φ s).r x a}

/-- `X` is `Φ`-saturated. -/
def IsSat {S : Type u} {A : SSet S} (Φ : SortedEqv A) (X : Sub A) : Prop :=
  sat Φ X = X

/-- Corollary `B-C001` (`IncSat`). -/
theorem sat_antitone {S : Type u} {A : SSet S} {Φ Ψ : SortedEqv A}
    (h : sortedEqvLe Φ Ψ) {X : Sub A} (hX : IsSat Ψ X) : IsSat Φ X := by
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

/-- `Φ-Sat(A)`, the set of `Φ`-saturated subsets. -/
def satSets {S : Type u} {A : SSet S} (Φ : SortedEqv A) : Set (Sub A) :=
  {X | IsSat Φ X}

/-- Remark `B-R007`: the map `Φ ↦ Φ-Sat(A)` is antitone (order-reversing). -/
theorem satSets_antitone {S : Type u} {A : SSet S} {Φ Ψ : SortedEqv A}
    (h : sortedEqvLe Φ Ψ) : satSets Ψ ⊆ satSets Φ :=
  fun _X hX => sat_antitone h hX

/-- Proposition `B-P002` (`PropIncSat`), forward direction. -/
theorem sat_sat_eq {S : Type u} {A : SSet S} {Φ Ψ : SortedEqv A}
    (h : sortedEqvLe Φ Ψ) (X : Sub A) : sat Φ (sat Ψ X) = sat Ψ X := by
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

/-- Bridge `setoid_le_iff`. -/
theorem setoid_le_iff {S : Type u} {A : SSet S} (Φ Ψ : SortedEqv A) :
    sortedEqvLe Φ Ψ ↔
      ∀ s (x y : A s), (Φ s).r x y → (Ψ s).r x y :=
  Iff.rfl

/-- Proposition `B-P002` (`PropIncSat`), full statement. -/
theorem prop_incSat {S : Type u} {A : SSet S} (Φ Ψ : SortedEqv A) :
    sortedEqvLe Φ Ψ ↔
      ∀ X : Sub A, sat Φ (sat Ψ X) = sat Ψ X := by
  classical
  constructor
  · intro h X
    exact sat_sat_eq h X
  · intro h s x y hxy
    let X : Sub A :=
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

/-- `∇^A`: the greatest sorted equivalence (the universal relation). -/
@[instance_reducible]
def nabla {S : Type u} (A : SSet S) : SortedEqv A :=
  fun _ =>
    ⟨fun _ _ => True,
     ⟨fun _ => trivial, fun _ => trivial, fun _ _ => trivial⟩⟩

/-- Support of an `S`-sorted set (Definition `B-D009`). -/
def supp {S : Type u} (A : SSet S) : Set S := {s | Nonempty (A s)}

/-- Support of a componentwise subset `X : Sub A`. -/
def suppSub {S : Type u} {A : SSet S} (X : Sub A) : Set S :=
  {s | (X s).Nonempty}

/-- Proposition `B-P003` (`NablaSat`). -/
theorem nabla_sat {S : Type u} {A : SSet S} (X : Sub A) :
    IsSat (nabla A) X ↔ ∀ s, s ∈ suppSub X → X s = Set.univ := by
  unfold IsSat
  constructor
  · intro h s hs
    have hsat : (sat (nabla A) X) s = X s :=
      congrArg (fun Y : Sub A => Y s) h
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
def sortedEqvInf {S : Type u} {A : SSet S} (Φ Ψ : SortedEqv A) : SortedEqv A :=
  fun s =>
    ⟨fun x y => (Φ s).r x y ∧ (Ψ s).r x y,
     ⟨fun x => ⟨(Φ s).refl x, (Ψ s).refl x⟩,
      fun h => ⟨(Φ s).symm h.1, (Ψ s).symm h.2⟩,
      fun hab hbc => ⟨(Φ s).trans hab.1 hbc.1, (Ψ s).trans hab.2 hbc.2⟩⟩⟩

theorem sortedEqvInf_le_left {S : Type u} {A : SSet S} (Φ Ψ : SortedEqv A) :
    sortedEqvLe (sortedEqvInf Φ Ψ) Φ := fun _ _ _ h => h.1

theorem sortedEqvInf_le_right {S : Type u} {A : SSet S} (Φ Ψ : SortedEqv A) :
    sortedEqvLe (sortedEqvInf Φ Ψ) Ψ := fun _ _ _ h => h.2

/-- Proposition `B-P004`: saturation by a meet is contained in the meet of the
saturations. -/
theorem sat_inf_subset {S : Type u} {A : SSet S} (Φ Ψ : SortedEqv A) (X : Sub A) :
    Subset (sat (sortedEqvInf Φ Ψ) X) (fun s => sat Φ X s ∩ sat Ψ X s) := by
  intro s b hb
  rcases hb with ⟨a, ha, hab⟩
  exact ⟨⟨a, ha, hab.1⟩, ⟨a, ha, hab.2⟩⟩

/-- Corollary `B-C002`. -/
theorem sat_inf {S : Type u} {A : SSet S} {Φ Ψ : SortedEqv A} {X : Sub A}
    (hΦ : IsSat Φ X) (_hΨ : IsSat Ψ X) :
    IsSat (sortedEqvInf Φ Ψ) X :=
  sat_antitone (sortedEqvInf_le_left Φ Ψ) hΦ

/-- Delta of Kronecker (Definition `B-D006`): one element at `t`, empty
elsewhere -- a faithful encoding of the terminal/initial components. -/
noncomputable def delta {S : Type u} (t : S) : SSet S :=
  by classical exact fun s => if s = t then PUnit.{u+1} else PEmpty.{u+1}

/-- Bridge `delta_support`: `supp_S(δ^t) = {t}`. -/
theorem supp_delta {S : Type u} (t : S) : supp (delta (S := S) t) = {t} := by
  classical
  ext s
  constructor
  · intro hs
    change Nonempty (delta (S := S) t s) at hs
    by_contra h
    have hne : ¬ (s = t) := by simpa using h
    have hz : delta (S := S) t s = PEmpty.{u+1} := by simp [delta, hne]
    rw [hz] at hs
    rcases hs with ⟨x⟩
    exact x.elim
  · intro hs
    have hst : s = t := by simpa using hs
    rw [hst]
    change Nonempty (delta (S := S) t t)
    have hd : delta (S := S) t t = PUnit.{u+1} := by simp [delta]
    rw [hd]
    exact ⟨PUnit.unit⟩

/-- Definition `B-D004`: subfinal (`card ≤ 1`), and the terminal/initial
`S`-sorted sets. -/
def Subfinal {S : Type u} (A : SSet S) : Prop := ∀ s, Subsingleton (A s)

def finalSorted (S : Type u) : SSet S := fun _ => PUnit.{u+1}

def initialSorted (S : Type u) : SSet S := fun _ => PEmpty.{u+1}

/-- Bridge `card_le_one_iff`. -/
theorem card_le_one_iff {S : Type u} (A : SSet S) :
    Subfinal A ↔ ∀ s, (Set.univ : Set (A s)).encard ≤ 1 := by
  simp only [Subfinal]
  constructor
  · intro h s
    rw [Set.encard_le_one_iff_subsingleton]
    exact @Set.subsingleton_univ (A s) (h s)
  · intro h s
    have hs := (Set.encard_le_one_iff_subsingleton).mp (h s)
    exact ⟨fun a b => hs (Set.mem_univ a) (Set.mem_univ b)⟩

theorem supp_finalSorted {S : Type u} :
    supp (finalSorted S) = Set.univ := by
  ext s
  constructor
  · intro _; exact Set.mem_univ s
  · intro _; exact ⟨PUnit.unit⟩

theorem supp_initialSorted {S : Type u} :
    supp (initialSorted S) = ∅ := by
  ext s
  constructor
  · intro hs
    change Nonempty (initialSorted S s) at hs
    rcases hs with ⟨x⟩
    exact x.elim
  · intro hs
    simp at hs

/-- Relative complement `∁_A X`, componentwise inside `A`. -/
def complA {S : Type u} {A : SSet S} (X : Sub A) : Sub A := fun s => (X s)ᶜ

theorem complA_bridge {S : Type u} {A : SSet S} (X : Sub A) (s : S) (a : A s) :
    a ∈ complA X s ↔ a ∉ X s := by
  simp [complA]

/-- Projection `pr^Φ`, sortwise. -/
def pr {S : Type u} {A : SSet S} (Φ : SortedEqv A) (s : S) :
    A s → Quotient (Φ s) :=
  fun x => Quotient.mk (Φ s) x

/-- Bridge `sat_eq_preimage` (`B-R006`). -/
theorem sat_eq_preimage {S : Type u} {A : SSet S} (Φ : SortedEqv A) (X : Sub A) :
    sat Φ X = fun s => (pr Φ s) ⁻¹' ((pr Φ s) '' X s) := by
  funext s
  ext a
  simp only [sat, pr, Set.mem_preimage, Set.mem_image, Set.mem_ofPred_eq]
  constructor
  · rintro ⟨x, hx, hxa⟩
    exact ⟨x, hx, Quotient.eq.mpr hxa⟩
  · rintro ⟨x, hx, h⟩
    exact ⟨x, hx, Quotient.eq.mp h⟩

/-- Bridge `sat_eq_preimage`, second part (`B-R006`). -/
theorem isSat_iff_preimage {S : Type u} {A : SSet S} (Φ : SortedEqv A)
    (X : Sub A) :
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

/-- The `Φ`-equivalence class of `a` (element-level counterpart of
`Quotient (Φ s)`). -/
def eqvClass {S : Type u} {A : SSet S} (Φ : SortedEqv A) (s : S) (a : A s) :
    Set (A s) :=
  {b | (Φ s).r a b}

theorem mem_eqvClass {S : Type u} {A : SSet S} (Φ : SortedEqv A) (s : S)
    (a b : A s) :
    b ∈ eqvClass Φ s a ↔ (Φ s).r a b := Iff.rfl

/-- Bridge `quot_class_bridge` (element level): classes are equal iff their
representatives are related. -/
theorem eqvClass_eq_iff {S : Type u} {A : SSet S} (Φ : SortedEqv A) (s : S)
    (a b : A s) :
    eqvClass Φ s a = eqvClass Φ s b ↔ (Φ s).r a b := by
  constructor
  · intro h
    have ha : a ∈ eqvClass Φ s a := (Φ s).refl a
    rw [h] at ha
    exact (Φ s).symm ha
  · intro h
    ext c
    constructor
    · intro hac
      exact (Φ s).trans ((Φ s).symm h) hac
    · intro hbc
      exact (Φ s).trans h hbc

/-- An `S`-sorted mapping `f : A → B` (Definition `B-D002`). -/
abbrev SortedMap {S : Type u} (A B : SSet S) := ∀ s, A s → B s

/-- Definition `B-D015`: the kernel of an `S`-sorted mapping. -/
@[instance_reducible]
def ker {S : Type u} {A B : SSet S} (f : SortedMap A B) : SortedEqv A :=
  fun s =>
    ⟨fun x y => f s x = f s y,
     ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩⟩

theorem ker_iff {S : Type u} {A B : SSet S} (f : SortedMap A B) (s : S)
    (x y : A s) :
    (ker f s).r x y ↔ f s x = f s y := Iff.rfl

/-- The family `⋃_{t∈T} δ^{t,A_t}`. -/
noncomputable def deltaUnion {S : Type u} (T : Set S) (A : SSet S) : Sub A :=
  by classical exact fun s => if s ∈ T then (Set.univ : Set (A s)) else ∅

/-- Remark `B-R008`. -/
theorem nabla_sat_empty {S : Type u} {A : SSet S} :
    IsSat (nabla A) (fun s => (∅ : Set (A s))) := by
  unfold IsSat
  funext s
  ext a
  simp [sat]

theorem nabla_sat_univ {S : Type u} {A : SSet S} :
    IsSat (nabla A) (fun s => (Set.univ : Set (A s))) := by
  unfold IsSat
  funext s
  ext a
  simp only [sat]
  constructor
  · intro _; exact Set.mem_univ a
  · intro _
    exact ⟨a, Set.mem_univ a, trivial⟩

theorem nabla_sat_deltaUnion {S : Type u} {A : SSet S} (T : Set S) :
    IsSat (nabla A) (deltaUnion T A) := by
  rw [nabla_sat]
  intro s hs
  by_cases hT : s ∈ T
  · simp [deltaUnion, hT]
  · simp [deltaUnion, suppSub, hT] at hs

/-! ### `B-P005` (`SatOperator`): `[·]^Φ` is a completely additive closure
operator. -/

/-- A closure operator on `Sub(A)`: extensive, monotone, and idempotent. -/
def IsClosureOperator {S : Type u} {A : SSet S} (c : Sub A → Sub A) : Prop :=
  (∀ X, Subset X (c X)) ∧
    (∀ X Y, Subset X Y → Subset (c X) (c Y)) ∧
    (∀ X, c (c X) = c X)

/-- Completely additive: preservation of arbitrary unions. -/
def IsCompletelyAdditive {S : Type u} {A : SSet S} (c : Sub A → Sub A) : Prop :=
  ∀ {ι : Type u} (X : ι → Sub A),
    c (fun s => ⋃ i, X i s) = fun s => ⋃ i, c (X i) s

/-- Algebraic (finitary): every element of `c X` already lies in `c F` for some
componentwise-finite `F ⊆ X`. -/
def IsAlgebraic {S : Type u} {A : SSet S} (c : Sub A → Sub A) : Prop :=
  ∀ (X : Sub A) (s : S) (a : A s), a ∈ c X s →
    ∃ F : Sub A, Subset F X ∧ (∀ t, (F t).Finite) ∧ a ∈ c F s

theorem sat_extensive {S : Type u} {A : SSet S} (Φ : SortedEqv A) (X : Sub A) :
    Subset X (sat Φ X) :=
  fun s x hx => ⟨x, hx, (Φ s).refl x⟩

theorem sat_monotone {S : Type u} {A : SSet S} (Φ : SortedEqv A) {X Y : Sub A}
    (h : Subset X Y) : Subset (sat Φ X) (sat Φ Y) := by
  intro s a ha
  rcases ha with ⟨x, hx, hxa⟩
  exact ⟨x, h s hx, hxa⟩

theorem sat_idem {S : Type u} {A : SSet S} (Φ : SortedEqv A) (X : Sub A) :
    sat Φ (sat Φ X) = sat Φ X := by
  funext s
  ext a
  constructor
  · rintro ⟨y, ⟨x, hx, hxy⟩, hya⟩
    exact ⟨x, hx, (Φ s).trans hxy hya⟩
  · intro ha
    exact ⟨a, ha, (Φ s).refl a⟩

theorem sat_isClosureOperator {S : Type u} {A : SSet S} (Φ : SortedEqv A) :
    IsClosureOperator (sat Φ) :=
  ⟨sat_extensive Φ, (fun _ _ h => sat_monotone Φ h), sat_idem Φ⟩

theorem sat_iUnion {S : Type u} {A : SSet S} (Φ : SortedEqv A) {ι : Type u}
    (X : ι → Sub A) :
    sat Φ (fun s => ⋃ i, X i s) = fun s => ⋃ i, sat Φ (X i) s := by
  funext s
  ext a
  simp only [sat, Set.mem_ofPred_eq, Set.mem_iUnion]
  constructor
  · rintro ⟨x, ⟨i, hxi⟩, hxa⟩
    exact ⟨i, x, hxi, hxa⟩
  · rintro ⟨i, x, hxi, hxa⟩
    exact ⟨x, ⟨i, hxi⟩, hxa⟩

theorem sat_isCompletelyAdditive {S : Type u} {A : SSet S} (Φ : SortedEqv A) :
    IsCompletelyAdditive (sat Φ) :=
  fun X => sat_iUnion Φ X

theorem sat_isAlgebraic {S : Type u} {A : SSet S} (Φ : SortedEqv A) :
    IsAlgebraic (sat Φ) := by
  classical
  intro X s a ha
  rcases ha with ⟨x, hx, hxa⟩
  let F : Sub A := Function.update (fun t => (∅ : Set (A t))) s {x}
  have hFs : F s = ({x} : Set (A s)) := by simp [F]
  have hFt : ∀ t, t ≠ s → F t = (∅ : Set (A t)) := by
    intro t ht
    simp [F, Function.update_of_ne ht]
  refine ⟨F, ?_, ?_, ?_⟩
  · intro t y hy
    by_cases ht : t = s
    · subst t
      rw [hFs] at hy
      rw [Set.mem_singleton_iff] at hy
      subst hy
      exact hx
    · rw [hFt t ht] at hy
      simp at hy
  · intro t
    by_cases ht : t = s
    · subst t
      rw [hFs]
      exact Set.finite_singleton x
    · rw [hFt t ht]
      exact Set.finite_empty
  · exact ⟨x, by rw [hFs]; exact Set.mem_singleton x, hxa⟩

theorem sat_iInter_subset {S : Type u} {A : SSet S} (Φ : SortedEqv A) {ι : Type u}
    (X : ι → Sub A) :
    Subset (sat Φ (fun s => ⋂ i, X i s)) (fun s => ⋂ i, sat Φ (X i) s) := by
  intro s a ha
  rcases ha with ⟨x, hx, hxa⟩
  simp only [Set.mem_iInter] at hx ⊢
  exact fun i => ⟨x, hx i, hxa⟩

theorem sat_univ {S : Type u} {A : SSet S} (Φ : SortedEqv A) :
    sat Φ (fun _ => (Set.univ : Set (A _))) = fun _ => Set.univ := by
  funext s
  ext a
  simp only [sat, Set.mem_ofPred_eq, Set.mem_univ, true_and]
  exact ⟨fun _ => trivial, fun _ => ⟨a, (Φ s).refl a⟩⟩

theorem sat_compl {S : Type u} {A : SSet S} (Φ : SortedEqv A) {X : Sub A}
    (hX : IsSat Φ X) : IsSat Φ (complA X) := by
  unfold IsSat at *
  funext s
  ext a
  constructor
  · rintro ⟨x, hx, hxa⟩
    simp only [complA, Set.mem_compl_iff] at hx ⊢
    intro haX
    exact hx (by rw [← hX]; exact ⟨a, haX, (Φ s).symm hxa⟩)
  · intro ha
    simp only [complA, Set.mem_compl_iff] at ha ⊢
    exact ⟨a, ha, (Φ s).refl a⟩

theorem suppSub_sat {S : Type u} {A : SSet S} (Φ : SortedEqv A) (X : Sub A) :
    suppSub (sat Φ X) = suppSub X := by
  ext s
  constructor
  · rintro ⟨a, x, hx, _⟩
    exact ⟨x, hx⟩
  · rintro ⟨x, hx⟩
    exact ⟨x, x, hx, (Φ s).refl x⟩

theorem sat_uniform {S : Type u} {A : SSet S} (Φ : SortedEqv A) {X Y : Sub A}
    (h : suppSub X = suppSub Y) : suppSub (sat Φ X) = suppSub (sat Φ Y) := by
  rw [suppSub_sat Φ X, suppSub_sat Φ Y, h]

/-- `B-P005` (`Fix` clause): the `Φ`-saturated subsets are exactly the fixed
points of `[·]^Φ`. -/
theorem satSets_fix {S : Type u} {A : SSet S} (Φ : SortedEqv A) :
    satSets Φ = {X : Sub A | sat Φ X = X} := rfl

end Mslang
