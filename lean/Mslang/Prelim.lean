import Mathlib

/-!
Pilot encoding for `MSEilenberg.tex` under the **dependent-type carrier model**
(see `representation/pilot-encoding.md`): an `S`-sorted set is a family of
types `S → Type u`. This module holds the sorted-set layer: supports, the
Kronecker deltas, saturation by an `S`-sorted equivalence, quotients of sorted
sets, finiteness, the free monoid on `S`, direct/inverse images, products, and
the delta copower `B-R001`.
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

/-- The componentwise meet `⋂_i Φ_i` of a family of sorted equivalences. -/
@[instance_reducible]
def sortedEqv_iInf {S : Type u} {A : SSet S} {ι : Type u} (Φ : ι → SortedEqv A) :
    SortedEqv A :=
  fun s =>
    ⟨fun x y => ∀ i, (Φ i s).r x y,
     ⟨fun x => fun i => (Φ i s).refl x,
      fun h => fun i => (Φ i s).symm (h i),
      fun h1 h2 => fun i => (Φ i s).trans (h1 i) (h2 i)⟩⟩

/-- The meet `⋂_i Φ_i` refines each `Φ_i`. -/
theorem sortedEqv_iInf_le {S : Type u} {A : SSet S} {ι : Type u}
    (Φ : ι → SortedEqv A) (i : ι) : sortedEqvLe (sortedEqv_iInf Φ) (Φ i) :=
  fun _ _ _ h => h i

/-- The meet is the greatest lower bound: any `Ψ` refining every `Φ_i` refines
`⋂_i Φ_i`. -/
theorem le_sortedEqv_iInf {S : Type u} {A : SSet S} {ι : Type u}
    {Φ : ι → SortedEqv A} {Ψ : SortedEqv A}
    (h : ∀ i, sortedEqvLe Ψ (Φ i)) : sortedEqvLe Ψ (sortedEqv_iInf Φ) :=
  fun s x y hxy i => h i s x y hxy

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
