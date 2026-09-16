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

-- The `haveI`s in `finiteSSet_iff` (`B-R003`) register `Fintype`/`Finite`
-- instances consumed by later instance synthesis; the style linter's `have`
-- suggestion would not register them, so it is a false positive here.
set_option linter.style.haveILetI false

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

/-- The quotient `A/Φ` as an `S`-sorted set. -/
def quot {S : Type u} {A : SSet S} (Φ : SortedEqv A) : SSet S :=
  fun s => Quotient (Φ s)

/-- Remark `B-R005`: `supp_S(A) = supp_S(A/Φ)`. -/
theorem supp_quot {S : Type u} {A : SSet S} (Φ : SortedEqv A) :
    supp (quot Φ) = supp A := by
  ext s
  constructor
  · rintro ⟨q⟩
    obtain ⟨x, _⟩ := Quotient.exists_rep q
    exact ⟨x⟩
  · rintro ⟨x⟩
    exact ⟨Quotient.mk (Φ s) x⟩

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

/-! ### `B-P007`: kernel and universal property of the quotient. -/

/-- The map `p^{Φ,Ker(f)} : A/Φ → B` induced by `f` when `Φ ⊆ Ker(f)`. -/
def quotLift {S : Type u} {A B : SSet S} (Φ : SortedEqv A) (f : SortedMap A B)
    (h : sortedEqvLe Φ (ker f)) : SortedMap (quot Φ) B :=
  fun s => Quotient.lift (f s) (fun a b hab => h s a b hab)

/-- `B-P007`(1): `Ker(pr^Φ) = Φ`. -/
theorem ker_pr {S : Type u} {A : SSet S} (Φ : SortedEqv A) :
    ker (pr Φ) = Φ := by
  funext s
  exact Setoid.ext (fun x y => Quotient.eq)

/-- `B-P007`(2): the induced map factors the projection: `f = p^{Φ,Ker(f)} ∘ pr^Φ`. -/
theorem quotLift_comp {S : Type u} {A B : SSet S} (Φ : SortedEqv A)
    (f : SortedMap A B) (h : sortedEqvLe Φ (ker f)) :
    (fun s => (quotLift Φ f h s) ∘ (pr Φ s)) = f := by
  funext s x
  exact Quotient.lift_mk (f s) (fun a b hab => h s a b hab) x

/-- `B-P007`(2): uniqueness of the induced map. -/
theorem quotLift_unique {S : Type u} {A B : SSet S} (Φ : SortedEqv A)
    (f : SortedMap A B) (h : sortedEqvLe Φ (ker f)) (p : SortedMap (quot Φ) B)
    (hp : (fun s => p s ∘ pr Φ s) = f) : p = quotLift Φ f h := by
  funext s q
  induction q using Quotient.inductionOn with
  | _ x =>
    have hx : p s (Quotient.mk (Φ s) x) = f s x := by
      have h' := congrFun (congrFun hp s) x
      exact h'
    rw [hx]
    exact (Quotient.lift_mk (f s) (fun a b hab => h s a b hab) x).symm

/-! ### `B-D007`: direct and inverse image formation. -/

/-- Direct image formation `f[X]` (`B-D007`). -/
def directImage {S : Type u} {A B : SSet S} (f : SortedMap A B) (X : Sub A) : Sub B :=
  fun s => f s '' X s

/-- Inverse image formation `f⁻¹[Y]` (`B-D007`). -/
def inverseImage {S : Type u} {A B : SSet S} (f : SortedMap A B) (Y : Sub B) : Sub A :=
  fun s => f s ⁻¹' Y s

/-! ### `B-D003`: products of sorted sets. -/

/-- The product `∏_{i∈I} A^i` of an `I`-indexed family of sorted sets. -/
def iProd {S : Type u} {ι : Type u} (A : ι → SSet S) : SSet S :=
  fun s => ∀ i, A i s

/-- The `i`-th canonical projection `pr^i` (`B-D003`). -/
def iProj {S : Type u} {ι : Type u} (A : ι → SSet S) (i : ι) :
    SortedMap (iProd A) (A i) :=
  fun _ a => a i

/-- The pairing `<f^i> : B → ∏_i A^i` (`B-D003`). -/
def iPair {S : Type u} {ι : Type u} {B : SSet S} (A : ι → SSet S)
    (f : ∀ i, SortedMap B (A i)) : SortedMap B (iProd A) :=
  fun s b i => f i s b

/-! ### `B-D008`: finite sorted sets. -/

/-- `B-D008`: an `S`-sorted set is finite when its disjoint union
`∐A = Σ s, A s` is finite. -/
def FiniteSSet {S : Type u} (A : SSet S) : Prop := Finite (Sigma A)

/-- A componentwise subset is finite when its disjoint union is finite. -/
def FiniteSub {S : Type u} {B : SSet S} (X : Sub B) : Prop :=
  Finite (Sigma fun s => {b : B s // b ∈ X s})

/-- `Sub_f(B)`: the finite componentwise subsets of `B`. -/
def finiteSubsets {S : Type u} (B : SSet S) : Set (Sub B) := {X | FiniteSub X}

/-! ### `B-D001`: the free monoid on `S` (words). -/

/-- `B-D001`: the set of words `S*` on `S`, encoded as `List S`. -/
abbrev Word (S : Type u) : Type u := List S

/-- Concatenation of words (`B-D001`). -/
def concat {S : Type u} (w v : Word S) : Word S := w ++ v

/-- The empty word (`B-D001`). -/
def emptyWord (S : Type u) : Word S := []

/-! ### `B-D016`: `S`-sorted signatures. -/

/-- `B-D016`: an `S`-sorted signature `Σ : S* × S → 𝒰`, with `Σ_{w,s}` the set of
formal operations of arity `w` and coarity `s`. -/
abbrev Signature (S : Type u) := List S × S → Type u

/-! ### `B-D017`: `Σ`-algebras and `Σ`-homomorphisms. -/

/-- The word product `A_w = ∏_{i<|w|} A_{w_i}` (`B-D017`). -/
def wordProd {S : Type u} (A : SSet S) (w : List S) : Type u :=
  (i : Fin w.length) → A (w.get i)

/-- The finitary operations `Hom(A_w, A_s)` (`B-D017`). -/
def finOp {S : Type u} (A : SSet S) (w : List S) (s : S) : Type u :=
  wordProd A w → A s

/-- A structure of `Σ`-algebra on `A`: `F_{w,s} : Σ_{w,s} → Hom(A_w, A_s)`
(`B-D017`). -/
def AlgStruct {S : Type u} (Sig : Signature S) (A : SSet S) :=
  (p : List S × S) → Sig p → finOp A p.1 p.2

/-- The `Σ`-homomorphism condition (`B-D017`): `f ∘ F_σ = G_σ ∘ f_w`, i.e.
`f_s(F_σ(a)) = G_σ(f_w(a))`. -/
def IsAlgHom {S : Type u} (Sig : Signature S) {A B : SSet S}
    (FA : AlgStruct Sig A) (FB : AlgStruct Sig B) (f : SortedMap A B) : Prop :=
  ∀ (p : List S × S) (σ : Sig p) (a : wordProd A p.1),
    f p.2 (FA p σ a) = FB p σ (fun i => f (p.1.get i) (a i))

/-! ### `B-D018`/`B-D019`: support and finiteness of `Σ`-algebras. -/

/-- A `Σ`-algebra is a pair `(A, F)`: underlying sorted set plus structure. -/
abbrev Alg {S : Type u} (Sig : Signature S) := Σ A : SSet S, AlgStruct Sig A

/-- `B-D018`: the support of a `Σ`-algebra is the support of its underlying
`S`-sorted set. -/
def suppAlg {S : Type u} {Sig : Signature S} (X : Alg Sig) : Set S := supp X.1

/-- `B-D019`: a `Σ`-algebra is finite when its underlying sorted set is
finite (`B-D008`). -/
def FiniteAlg {S : Type u} {Sig : Signature S} (X : Alg Sig) : Prop :=
  FiniteSSet X.1

/-! ### `B-D024`/`B-D025`: congruences and quotient `Σ`-algebras. -/

/-- `B-D024`: an `S`-sorted congruence on a `Σ`-algebra `(A, F)` is a sorted
equivalence compatible with every formal operation. -/
def IsCongruence {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) : Prop :=
  ∀ (p : List S × S) (σ : Sig p) (a b : wordProd A p.1),
    (∀ i, (Φ (p.1.get i)).r (a i) (b i)) → (Φ p.2).r (F p σ a) (F p σ b)

/-- The operation induced on `A/Φ` by `F_σ`. Representatives are selected with
`Quotient.out`; the congruence condition makes the result independent of the
selection (`quotOp_mk`). -/
noncomputable def quotOp {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) (p : List S × S) (σ : Sig p) :
    finOp (quot Φ) p.1 p.2 :=
  fun a => Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))

/-- `B-D025`: the quotient `Σ`-algebra `A/Φ`. -/
noncomputable def quotAlg {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) (_hΦ : IsCongruence Sig F Φ) :
    Alg Sig :=
  ⟨quot Φ, fun p σ => quotOp Sig F Φ p σ⟩

/-- `B-D025`: the canonical projection `pr^Φ : A → A/Φ`. -/
def prAlg {S : Type u} (Sig : Signature S) {A : SSet S} (F : AlgStruct Sig A)
    (Φ : SortedEqv A) (hΦ : IsCongruence Sig F Φ) :
    SortedMap A (quotAlg Sig F Φ hΦ).1 :=
  pr Φ

/-- `F^{A/Φ}_σ` on representatives: `F_σ([a]) = [F_σ(a)]`. -/
theorem quotOp_mk {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) (hΦ : IsCongruence Sig F Φ)
    (p : List S × S) (σ : Sig p) (a : wordProd A p.1) :
    quotOp Sig F Φ p σ (fun i => Quotient.mk (Φ (p.1.get i)) (a i)) =
      Quotient.mk (Φ p.2) (F p σ a) := by
  apply Quotient.eq.mpr
  apply hΦ p σ (fun i => Quotient.out (Quotient.mk (Φ (p.1.get i)) (a i))) a
  intro i
  exact Quotient.exact (Quotient.out_eq (Quotient.mk (Φ (p.1.get i)) (a i)))

/-- `B-D025`: `pr^Φ` is a homomorphism of `Σ`-algebras. -/
theorem isAlgHom_prAlg {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) (hΦ : IsCongruence Sig F Φ) :
    IsAlgHom Sig F (quotAlg Sig F Φ hΦ).2 (prAlg Sig F Φ hΦ) := by
  intro p σ a
  show Quotient.mk (Φ p.2) (F p σ a) =
    quotOp Sig F Φ p σ (fun i => Quotient.mk (Φ (p.1.get i)) (a i))
  exact (quotOp_mk Sig F Φ hΦ p σ a).symm

/-! ### `B-P009`: kernel and universal property of the quotient `Σ`-algebra. -/

/-- `B-P009`(1): the kernel of a homomorphism is a congruence. -/
theorem ker_isCongruence {S : Type u} (Sig : Signature S) {A B : SSet S}
    (F : AlgStruct Sig A) (G : AlgStruct Sig B) (f : SortedMap A B)
    (hf : IsAlgHom Sig F G f) : IsCongruence Sig F (ker f) := by
  intro p σ a b h
  show f p.2 (F p σ a) = f p.2 (F p σ b)
  rw [hf p σ a, hf p σ b]
  congr 1
  funext i
  exact h i

/-- `B-P009`(2)(a): the kernel of the canonical projection is the congruence. -/
theorem ker_prAlg {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (Φ : SortedEqv A) (hΦ : IsCongruence Sig F Φ) :
    ker (prAlg Sig F Φ hΦ) = Φ :=
  ker_pr Φ

/-- `B-P009`(2)(b): the induced map `p^{Φ,Ker(f)}` is a homomorphism. -/
theorem quotAlgLift_isAlgHom {S : Type u} (Sig : Signature S) {A B : SSet S}
    (F : AlgStruct Sig A) (G : AlgStruct Sig B) (Φ : SortedEqv A)
    (hΦ : IsCongruence Sig F Φ) (f : SortedMap A B)
    (hf : IsAlgHom Sig F G f) (h : sortedEqvLe Φ (ker f)) :
    IsAlgHom Sig (quotAlg Sig F Φ hΦ).2 G (quotLift Φ f h) := by
  intro p σ a
  show quotLift Φ f h p.2
      (Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))) =
    G p σ (fun i => quotLift Φ f h (p.1.get i) (a i))
  rw [show quotLift Φ f h p.2
        (Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))) =
      f p.2 (F p σ (fun i => Quotient.out (a i))) by
    simp only [quotLift, Quotient.lift_mk]]
  rw [hf p σ (fun i => Quotient.out (a i))]
  congr 1
  funext i
  conv_rhs => rw [quotLift, ← Quotient.out_eq (a i), Quotient.lift_mk]

/-- `B-P009`(2)(b): `f = p^{Φ,Ker(f)} ∘ pr^Φ`. -/
theorem quotAlgLift_comp {S : Type u} (Sig : Signature S) {A B : SSet S}
    (F : AlgStruct Sig A) (G : AlgStruct Sig B) (Φ : SortedEqv A)
    (_hΦ : IsCongruence Sig F Φ) (f : SortedMap A B)
    (_hf : IsAlgHom Sig F G f) (h : sortedEqvLe Φ (ker f)) :
    (fun s => (quotLift Φ f h s) ∘ (prAlg Sig F Φ _hΦ s)) = f :=
  quotLift_comp Φ f h

/-- `B-P009`(2)(b): uniqueness of the induced homomorphism. -/
theorem quotAlgLift_unique {S : Type u} (Sig : Signature S) {A B : SSet S}
    (F : AlgStruct Sig A) (G : AlgStruct Sig B) (Φ : SortedEqv A)
    (_hΦ : IsCongruence Sig F Φ) (f : SortedMap A B)
    (_hf : IsAlgHom Sig F G f) (h : sortedEqvLe Φ (ker f))
    (p : SortedMap (quot Φ) B) (hp : (fun s => p s ∘ pr Φ s) = f) :
    p = quotLift Φ f h :=
  quotLift_unique Φ f h p hp

/-- Remark `B-R003`: an `S`-sorted set is finite if and only if its support is
finite and every component over the support is finite. -/
theorem finiteSSet_iff {S : Type u} (A : SSet S) :
    FiniteSSet A ↔ (supp A).Finite ∧ ∀ s, s ∈ supp A → Finite (A s) := by
  constructor
  · intro h
    haveI : Finite (Sigma A) := h
    have hfib : ∀ s, Finite (A s) := fun s =>
      Finite.of_injective (fun a : A s => (⟨s, a⟩ : Sigma A))
        (fun a b hab => eq_of_heq (Sigma.mk.inj_iff.mp hab).2)
    refine ⟨?_, fun s _ => hfib s⟩
    rw [← Set.finite_coe_iff]
    exact Finite.of_injective
      (fun x : ↥(supp A) => (⟨x.1, Classical.choice x.2⟩ : Sigma A))
      (fun x y hxy => Subtype.ext (Sigma.mk.inj_iff.mp hxy).1)
  · rintro ⟨hsupp, hfib⟩
    haveI : Fintype ↥(supp A) := hsupp.fintype
    haveI : ∀ s : ↥(supp A), Fintype (A s.1) :=
      fun s => @Fintype.ofFinite (A s.1) (hfib s.1 s.2)
    haveI : Finite (Σ s : ↥(supp A), A s.1) := Finite.of_fintype _
    exact Finite.of_surjective
      (fun y : (Σ s : ↥(supp A), A s.1) => (⟨y.1.1, y.2⟩ : Sigma A))
      (fun x => ⟨⟨⟨x.1, ⟨x.2⟩⟩, x.2⟩, rfl⟩)

/-! ### `B-D022`: products of `Σ`-algebras. -/

/-- `B-D022`: the product `∏_i A_i` of a family of `Σ`-algebras, componentwise
on carriers and operations. -/
noncomputable def iAlg {S : Type u} (Sig : Signature S) {ι : Type u}
    (A : ι → Alg Sig) : Alg Sig :=
  ⟨fun s => ∀ i, (A i).1 s,
   fun p σ b => fun i => (A i).2 p σ (fun j => b j i)⟩

/-- `B-D022`: the `i`-th canonical projection `pr^i : ∏_i A_i → A_i`. -/
def iProjAlg {S : Type u} (Sig : Signature S) {ι : Type u} (A : ι → Alg Sig)
    (i : ι) : SortedMap (iAlg Sig A).1 (A i).1 :=
  fun _ a => a i

/-- `B-D022`: the canonical projections are homomorphisms. -/
theorem isAlgHom_iProjAlg {S : Type u} (Sig : Signature S) {ι : Type u}
    (A : ι → Alg Sig) (i : ι) :
    IsAlgHom Sig (iAlg Sig A).2 (A i).2 (iProjAlg Sig A i) := by
  intro p σ a
  rfl

/-- `B-D022`: the pairing `<f^i> : B → ∏_i A_i`. -/
def iPairAlg {S : Type u} (Sig : Signature S) {ι : Type u} {B : SSet S}
    (A : ι → Alg Sig) (f : ∀ i, SortedMap B (A i).1) :
    SortedMap B (iAlg Sig A).1 :=
  fun s b i => f i s b

/-- `B-D022`: the pairing of homomorphisms is a homomorphism. -/
theorem isAlgHom_iPairAlg {S : Type u} (Sig : Signature S) {ι : Type u}
    {B : SSet S} (FB : AlgStruct Sig B) {A : ι → Alg Sig}
    (f : ∀ i, SortedMap B (A i).1)
    (hf : ∀ i, IsAlgHom Sig FB (A i).2 (f i)) :
    IsAlgHom Sig FB (iAlg Sig A).2 (iPairAlg Sig A f) := by
  intro p σ a
  funext i
  exact hf i p σ a

/-- `B-D022`: `pr^i ∘ <f^i> = f^i`. -/
theorem iProjAlg_iPairAlg {S : Type u} (Sig : Signature S) {ι : Type u}
    {B : SSet S} (A : ι → Alg Sig) (f : ∀ i, SortedMap B (A i).1) (i : ι) :
    (fun s => (iProjAlg Sig A i s) ∘ (iPairAlg Sig A f s)) = f i := by
  funext s b
  rfl

/-- `B-D022`: `<f^i>` is the unique map with `pr^i ∘ f = f^i` for all `i`. -/
theorem iPairAlg_unique {S : Type u} (Sig : Signature S) {ι : Type u}
    {B : SSet S} (A : ι → Alg Sig) (f : ∀ i, SortedMap B (A i).1)
    (p : SortedMap B (iAlg Sig A).1)
    (hp : ∀ i, (fun s => (iProjAlg Sig A i s) ∘ (p s)) = f i) :
    p = iPairAlg Sig A f := by
  funext s b i
  exact congrFun (congrFun (hp i) s) b

/-! ### `B-R009`: the supports of `Σ`-algebras form a closure system on `S`. -/

/-- An ordinary closure system on a set `S` (the paper's `B-D010` in the
one-sorted case, applied to the set of sorts `S`): a family of subsets of `S`
containing `S` and closed under nonempty intersections. -/
def IsClosureSystemOn (S : Type u) (C : Set (Set S)) : Prop :=
  Set.univ ∈ C ∧ ∀ D : Set (Set S), D ⊆ C → D.Nonempty → ⋂₀ D ∈ C

/-- The support of a product of `Σ`-algebras is the intersection of the
supports. -/
theorem suppAlg_iAlg {S : Type u} (Sig : Signature S) {ι : Type u}
    (A : ι → Alg Sig) :
    suppAlg (iAlg Sig A) = {s | ∀ i, s ∈ suppAlg (A i)} := by
  ext s
  show Nonempty (∀ i, (A i).1 s) ↔ ∀ i, Nonempty ((A i).1 s)
  constructor
  · rintro ⟨x⟩ i
    exact ⟨x i⟩
  · intro h
    exact ⟨fun i => Classical.choice (h i)⟩

/-- Remark `B-R009`: the supports of the `Σ`-algebras form a closure system on
the set of sorts `S`. `S` itself is the support of a constant one-element
algebra, and a nonempty intersection of supports is realized by the product
algebra. -/
theorem supports_isClosureSystem {S : Type u} (Sig : Signature S) :
    IsClosureSystemOn S (Set.range (fun A : Alg Sig => suppAlg A)) := by
  constructor
  · refine ⟨⟨fun _ => PUnit, fun _ _ _ => PUnit.unit⟩, ?_⟩
    ext s
    exact iff_true_intro ⟨PUnit.unit⟩
  · intro D hD _
    let A : ↥D → Alg Sig := fun X => Classical.choose (Set.mem_range.mp (hD X.2))
    have hA : ∀ X : ↥D, suppAlg (A X) = X.1 := fun X =>
      Classical.choose_spec (Set.mem_range.mp (hD X.2))
    refine ⟨iAlg Sig A, ?_⟩
    change suppAlg (iAlg Sig A) = ⋂₀ D
    rw [suppAlg_iAlg]
    ext s
    rw [Set.mem_sInter]
    constructor
    · intro h X hX
      have := h ⟨X, hX⟩
      rwa [hA ⟨X, hX⟩] at this
    · intro h X
      rw [hA X]
      exact h X.1 X.2

/-! ### `B-D020`/`B-D021`: subalgebras and the generating operator `Sg`. -/

/-- `B-D020`: a componentwise subset `X` is a subalgebra of `(A,F)` when it is
closed under every formal operation. -/
def IsSubalgebra {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (X : Sub A) : Prop :=
  ∀ (p : List S × S) (σ : Sig p) (a : wordProd A p.1),
    (∀ i, a i ∈ X (p.1.get i)) → F p σ a ∈ X p.2

/-- The inductive generation relation (`B-D021`): the elements of `A`
obtainable from `X` by finitely many applications of the operations. -/
inductive MemSg {S : Type u} (Sig : Signature S) {A : SSet S} (F : AlgStruct Sig A)
    (X : Sub A) : (s : S) → A s → Prop
  | hyp : ∀ (s : S) (a : A s), a ∈ X s → MemSg Sig F X s a
  | op : ∀ (p : List S × S) (σ : Sig p) (a : wordProd A p.1),
      (∀ i, MemSg Sig F X (p.1.get i) (a i)) → MemSg Sig F X p.2 (F p σ a)

/-- `B-D021`: the subalgebra of `(A,F)` generated by `X`, i.e. `Sg_A(X)`. -/
def Sg {S : Type u} (Sig : Signature S) {A : SSet S} (F : AlgStruct Sig A)
    (X : Sub A) : Sub A :=
  fun s => {a | MemSg Sig F X s a}

/-- `B-D021`: `X` is a generating subset of `(A,F)`, i.e. `Sg_A(X) = A`. -/
def IsGenerating {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (X : Sub A) : Prop :=
  ∀ s, Sg Sig F X s = Set.univ

theorem subset_Sg {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (X : Sub A) : Subset X (Sg Sig F X) :=
  fun s _a ha => MemSg.hyp s _a ha

theorem Sg_isSubalgebra {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (X : Sub A) : IsSubalgebra Sig F (Sg Sig F X) :=
  fun p σ a ha => MemSg.op p σ a ha

theorem Sg_least {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) {X Y : Sub A} (hY : IsSubalgebra Sig F Y)
    (hXY : Subset X Y) : Subset (Sg Sig F X) Y := by
  intro s a ha
  induction ha with
  | hyp s a hx => exact hXY s hx
  | op p σ a _ ih => exact hY p σ a ih

theorem Sg_monotone {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) {X Y : Sub A} (h : Subset X Y) :
    Subset (Sg Sig F X) (Sg Sig F Y) :=
  Sg_least Sig F (Sg_isSubalgebra Sig F Y) fun s _a ha => subset_Sg Sig F Y s (h s ha)

theorem Sg_idem {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (X : Sub A) : Sg Sig F (Sg Sig F X) = Sg Sig F X := by
  funext s
  exact Set.Subset.antisymm
    (Sg_least Sig F (Sg_isSubalgebra Sig F X) (fun _s _a ha => ha) s)
    (Sg_monotone Sig F (subset_Sg Sig F X) s)

/-- `B-D021`: `Sg_A` is a closure operator on `Sub(A)`. -/
theorem Sg_isClosureOperator {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) : IsClosureOperator (Sg Sig F) :=
  ⟨subset_Sg Sig F, fun _X _Y h => Sg_monotone Sig F h, Sg_idem Sig F⟩

/-! ### `B-R010`: uniformity of `Sg`. -/

/-- The sorts reachable from `T` by the arities of the operations: the
support-level closure underlying the support of `Sg`. -/
inductive SuppClosure {S : Type u} (Sig : Signature S) (T : Set S) : Set S
  | hyp : ∀ s, s ∈ T → SuppClosure Sig T s
  | op : ∀ (p : List S × S) (_σ : Sig p),
      (∀ i, SuppClosure Sig T (p.1.get i)) → SuppClosure Sig T p.2

/-- The support of `Sg_A(X)` is exactly the support-level closure of the
support of `X`, so it depends only on `supp_S(X)`. -/
theorem suppSub_Sg {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) (X : Sub A) :
    suppSub (Sg Sig F X) = SuppClosure Sig (suppSub X) := by
  ext s
  constructor
  · rintro ⟨a, ha⟩
    induction ha with
    | hyp s a hx => exact SuppClosure.hyp s ⟨a, hx⟩
    | op p σ a _ ih => exact SuppClosure.op p σ ih
  · intro h
    induction h with
    | hyp s hs =>
        rcases hs with ⟨a, ha⟩
        exact ⟨a, MemSg.hyp s a ha⟩
    | op p σ _ ih =>
        let a : wordProd A p.1 := fun i => Classical.choose (ih i)
        exact ⟨F p σ a, MemSg.op p σ a fun i => Classical.choose_spec (ih i)⟩

/-- Remark `B-R010`: `Sg_A` is uniform — if `supp_S(X) = supp_S(Y)` then
`supp_S(Sg_A(X)) = supp_S(Sg_A(Y))`. -/
theorem suppSub_Sg_uniform {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) {X Y : Sub A} (h : suppSub X = suppSub Y) :
    suppSub (Sg Sig F X) = suppSub (Sg Sig F Y) := by
  rw [suppSub_Sg, suppSub_Sg, h]

/-! ### `B-D010`-`B-D013`: many-sorted closure systems and operators. -/

/-- The componentwise intersection of a family of componentwise subsets
(`B-D010`). -/
def Sub_iInter {S : Type u} {A : SSet S} (D : Set (Sub A)) : Sub A :=
  fun s a => ∀ X : Sub A, X ∈ D → a ∈ X s

/-- `B-D010`: an `S`-closure system on `A` — a family of componentwise subsets
of `A` containing `A` and closed under nonempty intersections. The
`S`-closure *operator* half of `B-D010` (extensive, isotone, idempotent) is
`IsClosureOperator` (`B-P005`). -/
def IsClosureSystem {S : Type u} {A : SSet S} (C : Set (Sub A)) : Prop :=
  (fun s => (Set.univ : Set (A s))) ∈ C ∧
    ∀ D : Set (Sub A), D ⊆ C → D.Nonempty → Sub_iInter D ∈ C

/-- The componentwise union of a family of componentwise subsets (`B-D012`). -/
def Sub_iUnion {S : Type u} {A : SSet S} (D : Set (Sub A)) : Sub A :=
  fun s a => ∃ X : Sub A, X ∈ D ∧ a ∈ X s

/-- `B-D012`: an algebraic `S`-closure system — a closure system closed under
directed unions. (The algebraic *operator* half of `B-D012` is `IsAlgebraic`,
`B-P005`.) -/
def IsAlgebraicClosureSystem {S : Type u} {A : SSet S} (C : Set (Sub A)) : Prop :=
  IsClosureSystem C ∧
    ∀ D : Set (Sub A), D ⊆ C → D.Nonempty →
      (∀ X ∈ D, ∀ Y ∈ D, ∃ Z ∈ D, Subset X Z ∧ Subset Y Z) →
      Sub_iUnion D ∈ C

/-- `B-D011`: a compact element of a complete lattice. -/
def IsCompact {L : Type u} [CompleteLattice L] (a : L) : Prop :=
  ∀ X : Set L, a ≤ sSup X → ∃ Y : Set L, Y ⊆ X ∧ Y.Finite ∧ a ≤ sSup Y

/-- `B-D011`: an algebraic lattice — every element is the supremum of a set of
compact elements. -/
def IsAlgebraicLattice (L : Type u) [CompleteLattice L] : Prop :=
  ∀ a : L, ∃ X : Set L, (∀ x ∈ X, IsCompact x) ∧ a = sSup X

/-- `B-D013`: an operator on `Sub(A)` is uniform when the support of its value
depends only on the support of its argument. -/
def IsUniform {S : Type u} {A : SSet S} (c : Sub A → Sub A) : Prop :=
  ∀ X Y : Sub A, suppSub X = suppSub Y → suppSub (c X) = suppSub (c Y)

/-- `B-D013`: a uniform algebraic `S`-closure operator. -/
def IsUniformAlgebraicClosureOperator {S : Type u} {A : SSet S}
    (c : Sub A → Sub A) : Prop :=
  IsAlgebraic c ∧ IsUniform c

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

/-! ### `B-R001`: `δ^{t,X}` is a copower of the delta `δ^t`. -/

/-- An isomorphism of `S`-sorted sets: a sortwise-bijective sorted map. -/
def SortedIso {S : Type u} (A B : SSet S) : Prop :=
  ∃ f : SortedMap A B, ∀ s, Function.Bijective (f s)

/-- The coproduct `∐_i A^i` of a family of `S`-sorted sets. -/
abbrev iCoprod {S : Type u} {ι : Type u} (A : ι → SSet S) : SSet S :=
  fun s => Σ i, A i s

/-- `B-R001` (with `B-D006`): `δ^{t,X}` — the set `X` at sort `t`, empty
elsewhere. -/
noncomputable def deltaT {S : Type u} (t : S) (X : Type u) : SSet S :=
  by classical exact fun s => if s = t then X else PEmpty.{u+1}

/-- `(Σ _ : X, PUnit) ≃ X`. -/
def sigmaPUnitEquiv (X : Type u) : (Σ _ : X, PUnit.{u+1}) ≃ X where
  toFun p := p.1
  invFun x := ⟨x, PUnit.unit⟩
  left_inv p := by rcases p with ⟨a, b⟩; cases b; rfl
  right_inv _x := rfl

/-- The sortwise equivalence underlying `B-R001`. -/
noncomputable def deltaEquiv {S : Type u} (t : S) (X : Type u) (s : S) :
    deltaT t X s ≃ iCoprod (fun _ : X => delta t) s := by
  classical
  by_cases h : s = t
  · rw [show deltaT t X s = X from if_pos h]
    change X ≃ (Σ _x : X, delta t s)
    rw [show delta t s = PUnit from if_pos h]
    exact (sigmaPUnitEquiv X).symm
  · rw [show deltaT t X s = PEmpty from if_neg h]
    change PEmpty ≃ (Σ _x : X, delta t s)
    rw [show delta t s = PEmpty from if_neg h]
    exact ⟨fun e => e.elim, fun e => e.2.elim, fun e => e.elim, fun e => e.2.elim⟩

/-- Remark `B-R001`: `δ^{t,X}` is isomorphic to the coproduct `∐_{x∈X} δ^t`. -/
theorem delta_iso_coprod {S : Type u} (t : S) (X : Type u) :
    SortedIso (deltaT t X) (iCoprod (fun _ : X => delta t)) :=
  ⟨fun s => (deltaEquiv t X s).toFun, fun s => (deltaEquiv t X s).bijective⟩

end Mslang
