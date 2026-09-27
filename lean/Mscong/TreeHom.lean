import Mscong.Substitution

/-!
# `Mscong.TreeHom` -- hyperderivors and tree homomorphisms (`MSCong` §3.5)

Milestone **M4** of the MSCong project (OpenSpec change
`add-tree-homomorphisms-recognizability`): the base change `Δ_φ`, hyperderivors,
the induced `Σ`-algebra `c(T_Ξ(Y))`, tree homomorphisms, and the recognizability
results `PRecH` (inverse image) and `PRecLH` (direct image of a linear tree
homomorphism).

Following the paper, a **hyperderivor** from `(Σ, X)` to `(Ξ, Y)` is a sort map
`φ : S → T`, an `S⋆ × S`-indexed map `c` sending `σ : Σ_{w,s}` to a term in
`T_Ξ(Y ∪ ↓φ*(w))_{φ(s)}` (the fresh placeholders `↓φ*(w)`, one per argument
position), and a sorted map `f : X → T_Ξ(Y)_φ`. We encode `Y ∪ ↓φ*(w)` as the
coproduct `Yplus φ Y w t = Y t ⊕ {i : Fin w.length // φ (w.get i) = t}`; the
`σ`-operation of `c(T_Ξ(Y))` substitutes the argument family into `c(σ)` along
the universal property, and the tree homomorphism is the free extension of `f`.

This is **unmapped infrastructure**: no block IDs, no evidence; `mscong` stays
`ingested: false` (see `design.md`).
-/

namespace Mscong

open Mslang

attribute [local instance] Classical.propDecidable

set_option linter.style.haveILetI false
set_option warn.classDefReducibility false

universe u

variable {S T : Type u}

/-! ### Base change `Δ_φ` -/

/-- The base change `Δ_φ(A) = A ∘ φ` of a `T`-sorted set along `φ : S → T`. -/
abbrev Delta (φ : S → T) (A : SSet T) : SSet S := fun s => A (φ s)

/-! ### Hyperderivors -/

/-- The paper's `Y ∪ ↓φ*(w)`: the `T`-sorted set of the variables `Y` together
with the fresh placeholders, one per argument position `i < |w|`, placed at sort
`φ(w_i)`. -/
abbrev Yplus (φ : S → T) (Y : SSet T) (w : List S) : SSet T :=
  fun t => Y t ⊕ {i : Fin w.length // φ (w.get i) = t}

/-- A **hyperderivor** from `(Σ, X)` to `(Ξ, Y)` (`MSCong` §3.5): the
`S⋆ × S`-indexed `c` (a term in `T_Ξ(Y ∪ ↓φ*(w))_{φ(s)}` for `σ : Σ_{w,s}`),
and `f : X → T_Ξ(Y)_φ`, along a sort map `φ`. -/
structure Hyperderivor (φ : S → T) (Sig : Signature S) (Xi : Signature T)
    (X : SSet S) (Y : SSet T) where
  /-- The term assigned to each operation symbol `σ : Σ_{w,s}`. -/
  c : (p : List S × S) → Sig p → Term Xi (Yplus φ Y p.1) (φ p.2)
  /-- The sorted map on the generators. -/
  f : SortedMap X (fun s => Term Xi Y (φ s))

/-- The number of occurrences of the placeholder at position `i` in a term with
the variable set `Yplus φ Y w`. -/
def countPlaceholder {Xi : Signature T} {Y : SSet T} (φ : S → T) (w : List S)
    (i : Fin w.length) : {u : T} → Term Xi (Yplus φ Y w) u → ℕ
  | _, Term.var v =>
      match v with
      | Sum.inl _ => 0
      | Sum.inr q => if (q.1 : Fin w.length) = i then 1 else 0
  | _, Term.op _ _ a => Finset.univ.sum (fun j => countPlaceholder φ w i (a j))

/-- A hyperderivor is **linear** when every placeholder occurs at most once
(`MSCong` §3.5). -/
def Hyperderivor.IsLinear {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) : Prop :=
  ∀ (p : List S × S) (σ : Sig p) (i : Fin p.1.length),
    countPlaceholder φ p.1 i (H.c p σ) ≤ 1

/-! ### The induced `Σ`-algebra `c(T_Ξ(Y))` -/

/-- The assignment substituting the argument family `P` for the placeholders:
`Sum.inl y ↦ η(y)`, `Sum.inr i ↦ P i`. -/
def cSubstAssign (p : List S × S)
    (P : (i : Fin p.1.length) → Term Xi Y (φ (p.1.get i))) :
    SortedMap (Yplus φ Y p.1) (Term Xi Y) :=
  fun _ v =>
    match v with
    | Sum.inl y => Term.var y
    | Sum.inr q => q.2 ▸ P q.1

/-- Substituting the argument family `a` into the term `c(σ)`: the paper's
`S^w_{(a_i)}(c(σ))`. -/
noncomputable def cSubst {φ : S → T} (H : Hyperderivor φ Sig Xi X Y)
    (p : List S × S) (σ : Sig p)
    (a : (i : Fin p.1.length) → Term Xi Y (φ (p.1.get i))) :
    Term Xi Y (φ p.2) :=
  termLift Xi (Yplus φ Y p.1) (termAlg Xi Y).2 (cSubstAssign p a)
    (φ p.2) (H.c p σ)

/-- The `Σ`-algebra structure `c(T_Ξ(Y))` on `T_Ξ(Y)_φ` (`MSCong` §3.5): the
operation for `σ` substitutes the arguments into `c(σ)`. -/
noncomputable def cAlg {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) :
    AlgStruct Sig (fun s => Term Xi Y (φ s)) :=
  fun p σ a => cSubst H p σ a

/-- The **tree homomorphism** `f♯ : T_Σ(X) → c(T_Ξ(Y))` determined by a
hyperderivor `(c, f)`: the free extension of `f`. -/
noncomputable def treeHom {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) :
    SortedMap (Term Sig X) (fun s => Term Xi Y (φ s)) :=
  termLift Sig X (cAlg H) H.f

/-- The tree homomorphism is a `Σ`-homomorphism. -/
theorem treeHom_isAlgHom {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) :
    IsAlgHom Sig (termAlg Sig X).2 (cAlg H) (treeHom H) :=
  termLift_isAlgHom Sig X (cAlg H) H.f

/-- The tree homomorphism agrees with `f` on the generators. -/
theorem treeHom_eta {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) :
    (fun s => treeHom H s ∘ termEta Sig X s) = H.f :=
  termLift_eta Sig X (cAlg H) H.f

/-- The tree homomorphism on an operation: `f♯(σ((P_i))) = cSubst(σ, (f♯(P_i)))`. -/
theorem treeHom_op {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) (p : List S × S)
    (σ : Sig p) (P : (i : Fin p.1.length) → Term Sig X (p.1.get i)) :
    treeHom H p.2 (Term.op p σ P)
      = cSubst H p σ (fun i => treeHom H (p.1.get i) (P i)) :=
  treeHom_isAlgHom H p σ P

/-! ### Composition of homomorphisms and transport coherence -/

/-- Composition of `Σ`-homomorphisms. -/
theorem IsAlgHom_comp {Sig : Signature S} {A B C : SSet S} {FA : AlgStruct Sig A}
    {FB : AlgStruct Sig B} {FC : AlgStruct Sig C} {f : SortedMap A B}
    {g : SortedMap B C} (hf : IsAlgHom Sig FA FB f) (hg : IsAlgHom Sig FB FC g) :
    IsAlgHom Sig FA FC (fun s a => g s (f s a)) := by
  intro p σ a
  change g p.2 (f p.2 (FA p σ a)) = FC p σ (fun i => g (p.1.get i) (f (p.1.get i) (a i)))
  rw [hf p σ a, hg p σ (fun i => f (p.1.get i) (a i))]

/-- Transport coherence for a sorted map: applying `g` after transporting an
argument along a sort equality is the same as transporting the result. -/
theorem sortedMap_cast {A B : SSet S} {g : SortedMap A B} {a b : S} (e : a = b)
    (x : A a) : g b (e ▸ x) = e ▸ (g a x) := by
  cases e; rfl

/-! ### The induced `Σ`-algebra `c(A)` and `PRecH` (Theorem `IndAlgStrucImHom`) -/

/-- `cSubst` respects the equivalence induced by a homomorphism `g`: if the
argument families agree under `g`, so do the substituted terms. -/
theorem cSubst_congr {φ : S → T} (H : Hyperderivor φ Sig Xi X Y)
    {B : SSet T} {FB : AlgStruct Xi B} {g : SortedMap (Term Xi Y) B}
    (hg : IsAlgHom Xi (termAlg Xi Y).2 FB g) {p : List S × S} {σ : Sig p}
    {P P' : (i : Fin p.1.length) → Term Xi Y (φ (p.1.get i))}
    (h : ∀ i, g (φ (p.1.get i)) (P i) = g (φ (p.1.get i)) (P' i)) :
    g (φ p.2) (cSubst H p σ P) = g (φ p.2) (cSubst H p σ P') := by
  have hlift : ∀ (Q : (i : Fin p.1.length) → Term Xi Y (φ (p.1.get i))),
      (fun t a => g t (termLift Xi (Yplus φ Y p.1) (termAlg Xi Y).2
          (cSubstAssign p Q) t a))
        = termLift Xi (Yplus φ Y p.1) FB
            (fun t v => g t (cSubstAssign p Q t v)) := by
    intro Q
    exact termLift_unique Xi (Yplus φ Y p.1) FB
      (fun t v => g t (cSubstAssign p Q t v))
      (fun t a => g t (termLift Xi (Yplus φ Y p.1) (termAlg Xi Y).2
        (cSubstAssign p Q) t a))
      (IsAlgHom_comp
        (termLift_isAlgHom Xi (Yplus φ Y p.1) (termAlg Xi Y).2 (cSubstAssign p Q)) hg)
      (by funext t v; rfl)
  have hassign : (fun t v => g t (cSubstAssign p P t v))
      = (fun t v => g t (cSubstAssign p P' t v)) := by
    funext t v
    cases v with
    | inl y => rfl
    | inr q =>
        simp only [cSubstAssign]
        rw [sortedMap_cast (g := g) q.2 (P q.1), h q.1, sortedMap_cast (g := g) q.2 (P' q.1)]
  have eP : g (φ p.2) (termLift Xi (Yplus φ Y p.1) (termAlg Xi Y).2
        (cSubstAssign p P) (φ p.2) (H.c p σ))
      = termLift Xi (Yplus φ Y p.1) FB (fun t v => g t (cSubstAssign p P t v))
        (φ p.2) (H.c p σ) :=
    congrFun (congrFun (hlift P) (φ p.2)) (H.c p σ)
  have eP' : g (φ p.2) (termLift Xi (Yplus φ Y p.1) (termAlg Xi Y).2
        (cSubstAssign p P') (φ p.2) (H.c p σ))
      = termLift Xi (Yplus φ Y p.1) FB (fun t v => g t (cSubstAssign p P' t v))
        (φ p.2) (H.c p σ) :=
    congrFun (congrFun (hlift P') (φ p.2)) (H.c p σ)
  rw [cSubst, cSubst, eP, eP', hassign]

/-! ### Subterms and substituting language families into them (`PRecLH` infrastructure) -/

/-- The componentwise set of subterms of a term: `Subt P t` is the set of
subterms of `P` of sort `t` (`MSCong` §3.5, `Subt(c_{w,r}(σ))_t`). -/
def Subt {Z : SSet T} : {u : T} → Term Xi Z u → Sub (Term Xi Z)
  | u, Term.var v => fun t => if h : u = t then {h ▸ Term.var v} else ∅
  | _, Term.op p σ a => fun t =>
      (if h : p.2 = t then {h ▸ Term.op p σ a} else ∅)
        ∪ ⋃ i, Subt (a i) t

/-- Every term is a subterm of itself. -/
theorem Subt_self {Z : SSet T} {u : T} (P : Term Xi Z u) : P ∈ Subt P u := by
  cases P with
  | var v => simp [Subt]
  | op p σ a => simp [Subt]

/-- The arguments of an operation are subterms of it. -/
theorem Subt_op_mem {Z : SSet T} {p : List T × T} (σ : Xi p)
    (a : (i : Fin p.1.length) → Term Xi Z (p.1.get i)) (i : Fin p.1.length)
    {t : T} {Q : Term Xi Z t} (hQ : Q ∈ Subt (a i) t) :
    Q ∈ Subt (Term.op p σ a) t := by
  simp only [Subt]
  exact Or.inr (Set.mem_iUnion.mpr ⟨i, hQ⟩)

/-- Subterms are transitive: a subterm of a subterm is a subterm. -/
theorem Subt_trans {Z : SSet T} :
    ∀ {A : T} (P : Term Xi Z A) {B : T} {Q : Term Xi Z B} {C : T}
      {R : Term Xi Z C},
      Q ∈ Subt P B → R ∈ Subt Q C → R ∈ Subt P C := by
  intro A P
  induction P using Term.rec with
  | var v =>
      rename_i A'
      intro B Q C R hQ hR
      by_cases hAB : A' = B
      · subst hAB
        simp only [Subt, dif_pos trivial, Set.mem_singleton_iff] at hQ
        subst hQ
        exact hR
      · simp only [Subt, dif_neg hAB] at hQ
        exact absurd hQ (Set.notMem_empty _)
  | op p σ a ih =>
      intro B Q C R hQ hR
      by_cases hB : p.2 = B
      · subst hB
        simp only [Subt, dif_pos trivial] at hQ
        rcases hQ with hQ | hQ
        · rw [Set.mem_singleton_iff] at hQ
          subst hQ
          exact hR
        · rw [Set.mem_iUnion] at hQ
          obtain ⟨i, hQi⟩ := hQ
          exact Subt_op_mem σ a i (ih i hQi hR)
      · simp only [Subt, dif_neg hB, Set.empty_union] at hQ
        rw [Set.mem_iUnion] at hQ
        obtain ⟨i, hQi⟩ := hQ
        exact Subt_op_mem σ a i (ih i hQi hR)

/-- A term has finitely many subterms at each sort. -/
theorem Subt_finite {Z : SSet T} :
    ∀ {u : T} (P : Term Xi Z u) (t : T), (Subt P t).Finite := by
  intro u P
  induction P using Term.rec with
  | var v =>
      rename_i u'
      intro t
      simp only [Subt]
      split_ifs with h
      · exact Set.finite_singleton _
      · exact Set.finite_empty
  | op p σ a ih =>
      intro t
      simp only [Subt]
      split_ifs with h
      · exact (Set.finite_singleton _).union
          (Set.finite_iUnion (fun i => ih i t))
      · exact Set.finite_empty.union (Set.finite_iUnion (fun i => ih i t))

/-! ### The subterm automaton: singleton term languages are recognizable

The finite-index congruence `Φ` of `PRecLH` is the intersection of the syntactic
congruences `Ω(δ^{φ(r),{f_r(x)}})` of the **singleton** languages `{f_r(x)}`; to
show it is of finite index we need `{f_r(x)} ∈ Rec`. More generally, every
singleton `{P} ⊆ T_Ξ(Z)` of a term is recognizable: it is recognized by the
*subterm automaton* of `P`, whose states at each sort are the subterms of `P`
together with a dead value. -/

/-- The arguments of an operation that is a subterm are themselves subterms. -/
theorem Subt_op_arg {Z : SSet T} {A : T} (P : Term Xi Z A) {p : List T × T}
    (σ : Xi p) (a : (i : Fin p.1.length) → Term Xi Z (p.1.get i))
    (h : Term.op p σ a ∈ Subt P p.2) (i : Fin p.1.length) :
    a i ∈ Subt P (p.1.get i) :=
  Subt_trans P h (Subt_op_mem σ a i (Subt_self (a i)))

/-- Candidate carrier of the subterm automaton of `P`: a subterm of `P` at the
given sort, or the dead value. -/
abbrev SubtermState {Z : SSet T} {A : T} (P : Term Xi Z A) : SSet T :=
  fun t => Option (Subt P t)

/-- Insertion of the variables into the subterm automaton: a variable term goes to
itself when it is a subterm of `P`, and to the dead value otherwise. -/
noncomputable def subtermEta {Z : SSet T} {A : T} (P : Term Xi Z A) :
    SortedMap Z (SubtermState P) :=
  fun t y =>
    if h : (Term.var y : Term Xi Z t) ∈ Subt P t then some ⟨Term.var y, h⟩
    else none

/-- The operation of the subterm automaton: apply `ξ` when every argument is a
subterm of `P` and the result is again one, and return the dead value
otherwise. -/
noncomputable def subtermAlg {Z : SSet T} {A : T} (P : Term Xi Z A) :
    AlgStruct Xi (SubtermState P) :=
  fun p σ a =>
    if h : ∀ i, (a i).isSome = true then
      let Q : Term Xi Z p.2 := Term.op p σ (fun i => ((a i).get (h i)).1)
      if hQ : Q ∈ Subt P p.2 then some ⟨Q, hQ⟩ else none
    else none

theorem subtermAlg_of_allSome {Z : SSet T} {A : T} (P : Term Xi Z A)
    {p : List T × T} (σ : Xi p)
    (a : (i : Fin p.1.length) → SubtermState P (p.1.get i))
    (h : ∀ i, (a i).isSome = true)
    (hQ : Term.op p σ (fun i => ((a i).get (h i)).1) ∈ Subt P p.2) :
    subtermAlg P p σ a
      = some ⟨Term.op p σ (fun i => ((a i).get (h i)).1), hQ⟩ := by
  unfold subtermAlg
  rw [dif_pos h, dif_pos hQ]

theorem subtermAlg_of_not_allSome {Z : SSet T} {A : T} (P : Term Xi Z A)
    {p : List T × T} (σ : Xi p)
    (a : (i : Fin p.1.length) → SubtermState P (p.1.get i))
    (h : ¬ ∀ i, (a i).isSome = true) : subtermAlg P p σ a = none := by
  unfold subtermAlg
  rw [dif_neg h]

theorem subtermAlg_of_notMem {Z : SSet T} {A : T} (P : Term Xi Z A)
    {p : List T × T} (σ : Xi p)
    (a : (i : Fin p.1.length) → SubtermState P (p.1.get i))
    (h : ∀ i, (a i).isSome = true)
    (hQ : Term.op p σ (fun i => ((a i).get (h i)).1) ∉ Subt P p.2) :
    subtermAlg P p σ a = none := by
  unfold subtermAlg
  rw [dif_pos h, dif_neg hQ]

/-- The subterm automaton sends a term `Q` to `some q` only when `q` is `Q`
itself. -/
theorem termLift_subtermAlg_fst {Z : SSet T} {A : T} (P : Term Xi Z A) :
    ∀ {t : T} (Q : Term Xi Z t) (q : Subt P t),
      termLift Xi Z (subtermAlg P) (subtermEta P) t Q = some q → q.1 = Q := by
  intro t Q
  refine Term.rec (motive := fun t Q => ∀ (q : Subt P t),
      termLift Xi Z (subtermAlg P) (subtermEta P) t Q = some q → q.1 = Q)
    ?var ?op Q
  case var =>
    intro s y q h
    change subtermEta P s y = some q at h
    unfold subtermEta at h
    split at h
    · injection h with hq
      subst hq
      rfl
    · exact absurd h (by simp)
  case op =>
    intro p σ a ih q h
    change subtermAlg P p σ
      (fun i => termLift Xi Z (subtermAlg P) (subtermEta P) (p.1.get i) (a i))
      = some q at h
    by_cases hall : ∀ i, (termLift Xi Z (subtermAlg P) (subtermEta P)
      (p.1.get i) (a i)).isSome = true
    · by_cases hQ : (Term.op p σ (fun i =>
          ((termLift Xi Z (subtermAlg P) (subtermEta P) (p.1.get i) (a i)).get
            (hall i)).1))
          ∈ Subt P p.2
      · rw [subtermAlg_of_allSome P σ
          (fun i => termLift Xi Z (subtermAlg P) (subtermEta P) (p.1.get i) (a i))
          hall hQ] at h
        have hq : (⟨Term.op p σ (fun i =>
            ((termLift Xi Z (subtermAlg P) (subtermEta P) (p.1.get i) (a i)).get
              (hall i)).1), hQ⟩ : Subt P p.2) = q :=
          (Option.some.injEq _ _).mp h
        rw [← hq]
        exact congrArg (Term.op p σ)
          (funext (fun i => ih i _ (Option.some_get (hall i)).symm))
      · rw [subtermAlg_of_notMem P σ
          (fun i => termLift Xi Z (subtermAlg P) (subtermEta P) (p.1.get i) (a i))
          hall hQ] at h
        exact absurd h (by simp)
    · rw [subtermAlg_of_not_allSome P σ
        (fun i => termLift Xi Z (subtermAlg P) (subtermEta P) (p.1.get i) (a i))
        hall] at h
      exact absurd h (by simp)

/-- The subterm automaton sends each subterm of `P` to itself. -/
theorem termLift_subtermAlg_mem {Z : SSet T} {A : T} (P : Term Xi Z A) :
    ∀ {t : T} (Q : Term Xi Z t), Q ∈ Subt P t →
      ∃ h : Q ∈ Subt P t,
        termLift Xi Z (subtermAlg P) (subtermEta P) t Q = some ⟨Q, h⟩ := by
  intro t Q
  refine Term.rec (motive := fun t Q => Q ∈ Subt P t →
      ∃ h : Q ∈ Subt P t,
        termLift Xi Z (subtermAlg P) (subtermEta P) t Q = some ⟨Q, h⟩)
    ?var ?op Q
  case var =>
    intro s y h
    exact ⟨h, by
      change subtermEta P s y = some ⟨Term.var y, h⟩
      unfold subtermEta
      rw [dif_pos h]⟩
  case op =>
    intro p σ a ih h
    have harg : ∀ i, a i ∈ Subt P (p.1.get i) := fun i => Subt_op_arg P σ a h i
    choose hh hEq using fun i => ih i (harg i)
    have hall : ∀ i, (termLift Xi Z (subtermAlg P) (subtermEta P)
        (p.1.get i) (a i)).isSome = true := by
      intro i; rw [hEq i]; rfl
    have hget : ∀ i, ((termLift Xi Z (subtermAlg P) (subtermEta P)
          (p.1.get i) (a i)).get (hall i))
        = (⟨a i, hh i⟩ : Subt P (p.1.get i)) := by
      intro i
      simp only [hEq i, Option.get_some]
    have hQeq : (fun i => ((termLift Xi Z (subtermAlg P) (subtermEta P)
          (p.1.get i) (a i)).get (hall i)).1) = a := by
      funext i; rw [hget i]
    have hQmem : (Term.op p σ (fun i => ((termLift Xi Z (subtermAlg P) (subtermEta P)
          (p.1.get i) (a i)).get (hall i)).1)) ∈ Subt P p.2 := by
      rw [hQeq]; exact h
    refine ⟨h, ?_⟩
    change subtermAlg P p σ
        (fun i => termLift Xi Z (subtermAlg P) (subtermEta P) (p.1.get i) (a i))
      = some ⟨Term.op p σ a, h⟩
    rw [subtermAlg_of_allSome P σ
      (fun i => termLift Xi Z (subtermAlg P) (subtermEta P) (p.1.get i) (a i))
      hall hQmem]
    exact congrArg some (Subtype.ext (congrArg (Term.op p σ) hQeq))

/-- Every singleton language of a term is recognizable (`MSCong` §3.5): the
subterm automaton of `P` recognizes `{P}` as the fibre of `P` itself. -/
theorem recognizableAt_term {Z : SSet T} [Finite T] {A : T} (P : Term Xi Z A) :
    RecognizableAt Xi (termAlg Xi Z) A ({P} : Set (Term Xi Z A)) := by
  classical
  refine ⟨⟨SubtermState P, subtermAlg P⟩, ?_,
    termLift Xi Z (subtermAlg P) (subtermEta P),
    termLift_isAlgHom Xi Z (subtermAlg P) (subtermEta P),
    {some ⟨P, Subt_self P⟩}, ?_⟩
  · show FiniteSSet (SubtermState P)
    haveI : Fintype T := Fintype.ofFinite T
    haveI : ∀ t, Fintype (Subt P t) := fun t => (Subt_finite P t).fintype
    exact Finite.of_fintype _
  · ext Q
    simp only [Set.mem_singleton_iff, Set.mem_preimage]
    constructor
    · intro hQP
      rw [hQP]
      obtain ⟨h, hh⟩ := termLift_subtermAlg_mem P P (Subt_self P)
      rw [hh]
    · intro h
      exact (termLift_subtermAlg_fst P Q ⟨P, Subt_self P⟩ h).symm

/-- Substituting a language family for the placeholders of `w` into any term:
the paper's operator `((v_i ↦ A_i))^♯(R)`. -/
noncomputable def substInto {φ : S → T} (w : List S)
    (A : (i : Fin w.length) → Set (Term Xi Y (φ (w.get i)))) :
    SortedMap (Term Xi (Yplus φ Y w)) (pCarrier (Term Xi Y)) :=
  termLift Xi (Yplus φ Y w) (pAlg Xi (Term Xi Y) (termAlg Xi Y).2).2
    (fun _ v =>
      match v with
      | Sum.inl y => ({Term.var y} : Set (Term Xi Y _))
      | Sum.inr q => q.2 ▸ A q.1)

/-- `((v_i ↦ A_i))^♯_t(R)`: the set of terms obtained by substituting the
languages `A_i` for the placeholders of `w` in `R`. -/
noncomputable def cSubstLang {φ : S → T} (w : List S)
    (A : (i : Fin w.length) → Set (Term Xi Y (φ (w.get i)))) {t : T}
    (R : Term Xi (Yplus φ Y w) t) : Set (Term Xi Y t) :=
  substInto w A t R

/-- The forward membership direction for `substInto`: any assignment-consistent
map `τ` (identity on `Y`, sending each placeholder into its language) realises
`termLift τ R` as a member of `((v_i ↦ A_i))^♯(R)`. No linearity is needed for
this direction. (The converse, which extracts `τ` from a member, is where the
linearity of `c(σ)` enters `PRecLH`.) -/
theorem mem_substInto_of_termLift {φ : S → T} (w : List S)
    (A : (i : Fin w.length) → Set (Term Xi Y (φ (w.get i))))
    (τ : SortedMap (Yplus φ Y w) (Term Xi Y))
    (hinl : ∀ (u : T) (y : Y u), τ u (Sum.inl y) = Term.var y)
    (hinr : ∀ (u : T) (q : {i : Fin w.length // φ (w.get i) = u}),
      τ u (Sum.inr q) ∈ q.2 ▸ A q.1) :
    ∀ {t : T} (R : Term Xi (Yplus φ Y w) t),
      termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ t R ∈ substInto w A t R := by
  intro t R
  refine Term.rec (motive := fun t R =>
      termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ t R ∈ substInto w A t R) ?var ?op R
  case var =>
    intro u v
    cases v with
    | inl y =>
        rw [show termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ u (Term.var (Sum.inl y))
              = Term.var y from hinl u y]
        exact Set.mem_singleton _
    | inr q => exact hinr u q
  case op =>
    intro p ξ a ih
    change (∃ b : (i : Fin p.1.length) → Term Xi Y (p.1.get i),
      (∀ i, b i ∈ substInto w A (p.1.get i) (a i)) ∧
        Term.op p ξ b = Term.op p ξ (fun i => termLift Xi (Yplus φ Y w)
          (termAlg Xi Y).2 τ (p.1.get i) (a i)))
    exact ⟨fun i => termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ (p.1.get i) (a i),
      ih, rfl⟩

/-! ### Linearity, `Occurs`, and the extraction of substitution coordinates

The converse of `mem_substInto_of_termLift` -- recovering the family `P` from a
member of `((v_i ↦ A_i))^♯(R)` -- needs `R` linear. In the operation case of the
induction the assignments of the arguments must be glued, and linearity
(`∑_j count_i(a_j) ≤ 1`) makes their placeholder occurrences disjoint, so the
choices for the same index agree. This is the step `PRecLH` relies on. -/

/-- The placeholder of index `i` occurs in a term over `Yplus φ Y w`. -/
def Occurs {φ : S → T} (w : List S) (i : Fin w.length) :
    {u : T} → Term Xi (Yplus φ Y w) u → Prop
  | _, Term.var v =>
      match v with
      | Sum.inl _ => False
      | Sum.inr q => (q.1 : Fin w.length) = i
  | _, Term.op _ _ a => ∃ j, Occurs w i (a j)

/-- An occurring placeholder is counted. -/
theorem countPlaceholder_pos_of_occurs {φ : S → T} {w : List S} {i : Fin w.length} :
    ∀ {u : T} {R : Term Xi (Yplus φ Y w) u}, Occurs w i R →
      0 < countPlaceholder φ w i R := by
  intro u R
  refine Term.rec (motive := fun u R => Occurs w i R → 0 < countPlaceholder φ w i R)
    ?var ?op R
  case var =>
    intro u v
    cases v with
    | inl y => intro h; exact h.elim
    | inr q =>
        intro h
        change (q.1 : Fin w.length) = i at h
        rw [← h]
        simp [countPlaceholder]
  case op =>
    intro p ξ a ih h
    change (∃ j, Occurs w i (a j)) at h
    obtain ⟨j, hj⟩ := h
    change 0 < Finset.univ.sum (fun j => countPlaceholder φ w i (a j))
    exact lt_of_lt_of_le (ih j hj)
      (Finset.single_le_sum (f := fun j => countPlaceholder φ w i (a j))
        (fun _ _ => Nat.zero_le _) (Finset.mem_univ j))

/-- `countPlaceholder` is invariant under a transport of the sort. -/
theorem countPlaceholder_cast {φ : S → T} {w : List S} (i : Fin w.length) {u v : T}
    (e : u = v) (R : Term Xi (Yplus φ Y w) u) :
    countPlaceholder φ w i (e ▸ R) = countPlaceholder φ w i R := by cases e; rfl

/-- A subterm is not counted more than the term: linearity of `P` implies linearity
of every subterm of `P`. -/
theorem countPlaceholder_le_of_mem_Subt {φ : S → T} (w : List S) (i : Fin w.length) :
    ∀ {u : T} (P : Term Xi (Yplus φ Y w) u) {t : T} {Q : Term Xi (Yplus φ Y w) t},
      Q ∈ Subt P t → countPlaceholder φ w i Q ≤ countPlaceholder φ w i P := by
  intro u P
  induction P using Term.rec with
  | var v =>
      intro t Q hQ
      simp only [Subt] at hQ
      split_ifs at hQ with h
      · rw [Set.mem_singleton_iff] at hQ
        subst hQ
        rw [countPlaceholder_cast]
      · exact absurd hQ (Set.notMem_empty Q)
  | op p ξ a ih =>
      intro t Q hQ
      simp only [Subt] at hQ
      rw [Set.mem_union, Set.mem_iUnion] at hQ
      rcases hQ with hQ | ⟨j, hQj⟩
      · split_ifs at hQ with h
        · rw [Set.mem_singleton_iff] at hQ
          subst hQ
          rw [countPlaceholder_cast]
        · exact absurd hQ (Set.notMem_empty Q)
      · calc countPlaceholder φ w i Q
            ≤ countPlaceholder φ w i (a j) := ih j hQj
          _ ≤ countPlaceholder φ w i (Term.op p ξ a) := by
              simp only [countPlaceholder]
              exact Finset.single_le_sum (f := fun j => countPlaceholder φ w i (a j))
                (fun _ _ => Nat.zero_le _) (Finset.mem_univ j)

/-- A subterm of a term produced by a linear hyperderivor is linear. -/
theorem linear_of_mem_Subt {φ : S → T} {H : Hyperderivor φ Sig Xi X Y}
    (hirr : Hyperderivor.IsLinear H) (p : List S × S) (σ : Sig p) {t : T}
    {R : Term Xi (Yplus φ Y p.1) t} (hR : R ∈ Subt (H.c p σ) t) (i : Fin p.1.length) :
    countPlaceholder φ p.1 i R ≤ 1 :=
  le_trans (countPlaceholder_le_of_mem_Subt p.1 i (H.c p σ) hR) (hirr p σ i)

/-- Membership under a transported set (element cast along `e`). -/
theorem mem_cast_set {ι : Type u} {F : ι → Type u} {a b : ι} (e : a = b)
    (S : Set (F a)) (x : F a) :
    e ▸ x ∈ (e ▸ S : Set (F b)) ↔ x ∈ S := by cases e; rfl

/-- Membership under a transported set (element on the codomain side). -/
theorem mem_cast_set' {ι : Type u} {F : ι → Type u} {a b : ι} (e : a = b)
    (S : Set (F a)) (x : F b) :
    x ∈ (e ▸ S : Set (F b)) ↔ e.symm ▸ x ∈ S := by cases e; rfl

/-- `e ▸ e.symm ▸ x = x`. -/
theorem eqRec_symm_eqRec_self {ι : Type u} {F : ι → Type u} {a b : ι} (e : a = b)
    (x : F b) : e ▸ (e.symm ▸ x) = x := by cases e; rfl

/-- `e.symm ▸ e ▸ x = x`. -/
theorem eqRec_eqRec_symm_self {ι : Type u} {F : ι → Type u} {a b : ι} (e : a = b)
    (x : F a) : e.symm ▸ (e ▸ x) = x := by cases e; rfl

/-- The placeholder assignment `inl y ↦ η(y)`, `inr q ↦ P q.1` as a sorted map on
`Yplus φ Y w` (the second component of `cSubstAssign` is never used, so this
avoids needing a sort of `S`). -/
def substAssign {φ : S → T} (w : List S)
    (P : (i : Fin w.length) → Term Xi Y (φ (w.get i))) :
    SortedMap (Yplus φ Y w) (Term Xi Y) :=
  fun _ v =>
    match v with
    | Sum.inl y => Term.var y
    | Sum.inr q => q.2 ▸ P q.1

/-- The forward membership direction for `substAssign`: a family `P` with
`P i ∈ A i` realises `termLift (substAssign w P) R ∈ ((v_i ↦ A_i))^♯(R)`. -/
theorem mem_substInto_substAssign {φ : S → T} (w : List S)
    (A : (i : Fin w.length) → Set (Term Xi Y (φ (w.get i))))
    (P : (i : Fin w.length) → Term Xi Y (φ (w.get i)))
    (hP : ∀ i, P i ∈ A i) :
    ∀ {t : T} (R : Term Xi (Yplus φ Y w) t),
      termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 (substAssign w P) t R
        ∈ substInto w A t R := by
  intro t R
  exact mem_substInto_of_termLift w A (substAssign w P) (fun _ _ => rfl)
    (fun _ q => (mem_cast_set q.2 (A q.1) (P q.1)).mpr (hP q.1)) R

/-- `termLift` over `Yplus φ Y w` depends only on the assignment's values on the
occurring placeholders (both assignments are the identity on `Y`). -/
theorem termLift_eq_of_agree {φ : S → T} {w : List S}
    (τ τ' : SortedMap (Yplus φ Y w) (Term Xi Y))
    (hinl : ∀ (u : T) (y : Y u), τ u (Sum.inl y) = τ' u (Sum.inl y)) :
    ∀ {u : T} (R : Term Xi (Yplus φ Y w) u),
      (∀ (v : T) (q : {i : Fin w.length // φ (w.get i) = v}),
        Occurs w q.1 R → τ v (Sum.inr q) = τ' v (Sum.inr q)) →
      termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ u R
        = termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ' u R := by
  intro u R
  refine Term.rec (motive := fun u R =>
      (∀ (v : T) (q : {i : Fin w.length // φ (w.get i) = v}),
        Occurs w q.1 R → τ v (Sum.inr q) = τ' v (Sum.inr q)) →
      termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ u R
        = termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ' u R) ?var ?op R
  case var =>
    intro u v hag
    cases v with
    | inl y => exact hinl u y
    | inr q =>
        exact hag u q (by change (q.1 : Fin w.length) = q.1; rfl)
  case op =>
    intro p ξ a ih hag
    change Term.op p ξ (fun j => termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ
        (p.1.get j) (a j))
      = Term.op p ξ (fun j => termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ'
        (p.1.get j) (a j))
    have hfun : (fun j => termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ (p.1.get j) (a j))
        = (fun j => termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 τ' (p.1.get j) (a j)) := by
      funext j
      exact ih j (fun v q hq => hag v q (by
        change (∃ j', Occurs w q.1 (a j')); exact ⟨j, hq⟩))
    rw [hfun]

/-- Extraction of substitution coordinates (the converse of
`mem_substInto_substAssign`) for a **linear** term: a member of
`((v_i ↦ A_i))^♯(R)` is `termLift (substAssign w P) R` for a family `P` with
`P i ∈ A i`. -/
theorem exists_eq_substAssign_of_mem_substInto {φ : S → T} (w : List S)
    (A : (i : Fin w.length) → Set (Term Xi Y (φ (w.get i))))
    (hA : ∀ i, (A i).Nonempty) :
    ∀ {t : T} (R : Term Xi (Yplus φ Y w) t),
      (∀ i, countPlaceholder φ w i R ≤ 1) →
      ∀ {W : Term Xi Y t}, W ∈ substInto w A t R →
        ∃ P : (i : Fin w.length) → Term Xi Y (φ (w.get i)),
          (∀ i, P i ∈ A i) ∧
          termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 (substAssign w P) t R = W := by
  intro t R
  refine Term.rec (motive := fun t R =>
      (∀ i, countPlaceholder φ w i R ≤ 1) →
      ∀ {W : Term Xi Y t}, W ∈ substInto w A t R →
        ∃ P : (i : Fin w.length) → Term Xi Y (φ (w.get i)),
          (∀ i, P i ∈ A i) ∧
          termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 (substAssign w P) t R = W)
    ?var ?op R
  case var =>
    intro u v hlin W hW
    cases v with
    | inl y =>
        have hW' : W = Term.var y := by
          have h := hW
          change W ∈ ({Term.var y} : Set (Term Xi Y u)) at h
          simpa using h
        subst hW'
        exact ⟨fun i => Classical.choose (hA i),
          (fun i => Classical.choose_spec (hA i)), rfl⟩
    | inr q0 =>
        change W ∈ (q0.2 ▸ A q0.1 : Set (Term Xi Y u)) at hW
        have hWmem : q0.2.symm ▸ W ∈ A q0.1 := (mem_cast_set' q0.2 (A q0.1) W).mp hW
        refine ⟨fun i => if h : i = q0.1 then
            ((congrArg (fun j => φ (w.get j)) h).symm ▸ (q0.2.symm ▸ W))
          else Classical.choose (hA i), ?_, ?_⟩
        · intro i
          change (if h : i = q0.1 then
              ((congrArg (fun j => φ (w.get j)) h).symm ▸ (q0.2.symm ▸ W))
            else Classical.choose (hA i)) ∈ A i
          split
          · rename_i h
            subst h
            exact hWmem
          · exact Classical.choose_spec (hA i)
        · change q0.2 ▸ (if h : q0.1 = q0.1 then
              ((congrArg (fun j => φ (w.get j)) h).symm ▸ (q0.2.symm ▸ W))
            else Classical.choose (hA q0.1)) = W
          rw [dif_pos rfl]
          exact eqRec_symm_eqRec_self q0.2 W
  case op =>
    intro p ξ a ih hlin W hW
    change (∃ b : (i : Fin p.1.length) → Term Xi Y (p.1.get i),
      (∀ i, b i ∈ substInto w A (p.1.get i) (a i)) ∧ Term.op p ξ b = W) at hW
    obtain ⟨b, hb, hbW⟩ := hW
    have hlinj : ∀ j, ∀ i, countPlaceholder φ w i (a j) ≤ 1 := by
      intro j i
      have h := hlin i
      rw [show countPlaceholder φ w i (Term.op p ξ a)
          = Finset.univ.sum (fun j => countPlaceholder φ w i (a j)) from rfl] at h
      exact le_trans (Finset.single_le_sum (f := fun j => countPlaceholder φ w i (a j))
        (fun _ _ => Nat.zero_le _) (Finset.mem_univ j)) h
    choose Pj hPj hPjlift using fun j => ih j (hlinj j) (hb j)
    have huniq : ∀ (i : Fin w.length) (j1 j2 : Fin p.1.length),
        Occurs w i (a j1) → Occurs w i (a j2) → j1 = j2 := by
      intro i j1 j2 hj1 hj2
      by_contra hne
      have hsumle : Finset.univ.sum (fun j => countPlaceholder φ w i (a j)) ≤ 1 := by
        have h := hlin i
        rwa [show countPlaceholder φ w i (Term.op p ξ a)
            = Finset.univ.sum (fun j => countPlaceholder φ w i (a j)) from rfl] at h
      have hp1 := countPlaceholder_pos_of_occurs hj1
      have hp2 := countPlaceholder_pos_of_occurs hj2
      have hpair : countPlaceholder φ w i (a j1) + countPlaceholder φ w i (a j2)
          ≤ Finset.univ.sum (fun j => countPlaceholder φ w i (a j)) := by
        have hs : ({j1, j2} : Finset (Fin p.1.length)).sum
              (fun x => countPlaceholder φ w i (a x))
            ≤ (Finset.univ : Finset (Fin p.1.length)).sum
              (fun x => countPlaceholder φ w i (a x)) :=
          Finset.sum_le_sum_of_subset_of_nonneg
            (by intro x _; exact Finset.mem_univ x)
            (by intro x _ _; exact Nat.zero_le _)
        rwa [Finset.sum_pair hne] at hs
      omega
    let P : (i : Fin w.length) → Term Xi Y (φ (w.get i)) := fun i =>
      if h : ∃ j, Occurs w i (a j) then Pj h.choose i else Classical.choose (hA i)
    have hPin : ∀ i, P i ∈ A i := by
      intro i
      change (if h : ∃ j, Occurs w i (a j) then Pj h.choose i
        else Classical.choose (hA i)) ∈ A i
      split
      · rename_i h; exact hPj h.choose i
      · exact Classical.choose_spec (hA i)
    have hglue : ∀ j, termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 (substAssign w P)
        (p.1.get j) (a j) = b j := by
      intro j
      rw [← hPjlift j]
      refine termLift_eq_of_agree (substAssign w P)
        (substAssign w (Pj j)) (fun u y => rfl) (a j) (fun v q hq => ?_)
      have hPval : P q.1 = Pj j q.1 := by
        have hex : ∃ j', Occurs w q.1 (a j') := ⟨j, hq⟩
        change (if h : ∃ j', Occurs w q.1 (a j') then Pj h.choose q.1
          else Classical.choose (hA q.1)) = Pj j q.1
        rw [dif_pos hex]
        exact congrArg (fun j' => Pj j' q.1)
          (huniq q.1 hex.choose j (Classical.choose_spec hex) hq)
      change q.2 ▸ P q.1 = q.2 ▸ Pj j q.1
      rw [hPval]
    refine ⟨P, hPin, ?_⟩
    change Term.op p ξ (fun j => termLift Xi (Yplus φ Y w) (termAlg Xi Y).2
        (substAssign w P) (p.1.get j) (a j)) = W
    rw [show (fun j => termLift Xi (Yplus φ Y w) (termAlg Xi Y).2
        (substAssign w P) (p.1.get j) (a j)) = b from funext hglue]
    exact hbW

/-- Gluing per-argument assignments into a single one: linearity makes the
placeholder occurrences of the arguments of an operation disjoint, so families
realising the targets of each argument on the codomain side can be combined. -/
theorem exists_glue_substAssign {φ : S → T} (w : List S)
    (A : (i : Fin w.length) → Set (Term Xi Y (φ (w.get i))))
    (hA : ∀ i, (A i).Nonempty)
    {u : List T} {t : T} (ξ : Xi (u, t))
    (Rj : (j : Fin u.length) → Term Xi (Yplus φ Y w) (u.get j))
    (hlin : ∀ i, countPlaceholder φ w i (Term.op (u, t) ξ Rj) ≤ 1)
    (b : (j : Fin u.length) → Term Xi Y (u.get j))
    (h : ∀ j, ∃ P : (i : Fin w.length) → Term Xi Y (φ (w.get i)),
        (∀ i, P i ∈ A i) ∧ termLift Xi (Yplus φ Y w) (termAlg Xi Y).2
          (substAssign w P) (u.get j) (Rj j) = b j) :
    ∃ P : (i : Fin w.length) → Term Xi Y (φ (w.get i)),
      (∀ i, P i ∈ A i) ∧
      ∀ j, termLift Xi (Yplus φ Y w) (termAlg Xi Y).2 (substAssign w P)
        (u.get j) (Rj j) = b j := by
  choose Pj hPj hPjlift using h
  have huniq : ∀ (i : Fin w.length) (j1 j2 : Fin u.length),
      Occurs w i (Rj j1) → Occurs w i (Rj j2) → j1 = j2 := by
    intro i j1 j2 hj1 hj2
    by_contra hne
    have hsumle : Finset.univ.sum (fun j => countPlaceholder φ w i (Rj j)) ≤ 1 := by
      have h := hlin i
      rwa [show countPlaceholder φ w i (Term.op (u, t) ξ Rj)
          = Finset.univ.sum (fun j => countPlaceholder φ w i (Rj j)) from rfl] at h
    have hp1 := countPlaceholder_pos_of_occurs hj1
    have hp2 := countPlaceholder_pos_of_occurs hj2
    have hpair : countPlaceholder φ w i (Rj j1) + countPlaceholder φ w i (Rj j2)
        ≤ Finset.univ.sum (fun j => countPlaceholder φ w i (Rj j)) := by
      have hs : ({j1, j2} : Finset (Fin u.length)).sum
            (fun x => countPlaceholder φ w i (Rj x))
          ≤ (Finset.univ : Finset (Fin u.length)).sum
            (fun x => countPlaceholder φ w i (Rj x)) :=
        Finset.sum_le_sum_of_subset_of_nonneg
          (by intro x _; exact Finset.mem_univ x)
          (by intro x _ _; exact Nat.zero_le _)
      rwa [Finset.sum_pair hne] at hs
    omega
  let P : (i : Fin w.length) → Term Xi Y (φ (w.get i)) := fun i =>
    if h : ∃ j, Occurs w i (Rj j) then Pj h.choose i else Classical.choose (hA i)
  have hPin : ∀ i, P i ∈ A i := by
    intro i
    change (if h : ∃ j, Occurs w i (Rj j) then Pj h.choose i
      else Classical.choose (hA i)) ∈ A i
    split
    · rename_i h; exact hPj h.choose i
    · exact Classical.choose_spec (hA i)
  refine ⟨P, hPin, fun j => ?_⟩
  rw [← hPjlift j]
  refine termLift_eq_of_agree (substAssign w P) (substAssign w (Pj j))
    (fun u y => rfl) (Rj j) (fun v q hq => ?_)
  have hPval : P q.1 = Pj j q.1 := by
    have hex : ∃ j', Occurs w q.1 (Rj j') := ⟨j, hq⟩
    change (if h : ∃ j', Occurs w q.1 (Rj j') then Pj h.choose q.1
      else Classical.choose (hA q.1)) = Pj j q.1
    rw [dif_pos hex]
    exact congrArg (fun j' => Pj j' q.1)
      (huniq q.1 hex.choose j (Classical.choose_spec hex) hq)
  change q.2 ▸ P q.1 = q.2 ▸ Pj j q.1
  rw [hPval]

/-- `cSubstAssign` is `substAssign` on its first component. -/
theorem cSubstAssign_eq_substAssign {φ : S → T} (p : List S × S)
    (P : (i : Fin p.1.length) → Term Xi Y (φ (p.1.get i))) :
    cSubstAssign p P = substAssign p.1 P := by
  funext u v
  cases v <;> rfl

/-- `cSubst` in terms of `substAssign`. -/
theorem cSubst_eq {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) (p : List S × S)
    (σ : Sig p) (P : (i : Fin p.1.length) → Term Xi Y (φ (p.1.get i))) :
    cSubst H p σ P
      = termLift Xi (Yplus φ Y p.1) (termAlg Xi Y).2 (substAssign p.1 P) (φ p.2)
          (H.c p σ) := by
  rw [cSubst, cSubstAssign_eq_substAssign]

/-- Membership in `((v_i ↦ A_i))^♯(c(σ))` is exactly being `cSubst(σ, P)` for a
family `P` with `P i ∈ A i`, when `c(σ)` is linear. -/
theorem mem_cSubstLang_iff {φ : S → T} (H : Hyperderivor φ Sig Xi X Y)
    (p : List S × S) (σ : Sig p)
    (A : (i : Fin p.1.length) → Set (Term Xi Y (φ (p.1.get i))))
    (hA : ∀ i, (A i).Nonempty)
    (hlin : ∀ i, countPlaceholder φ p.1 i (H.c p σ) ≤ 1) {W : Term Xi Y (φ p.2)} :
    W ∈ cSubstLang p.1 A (H.c p σ) ↔
      ∃ P : (i : Fin p.1.length) → Term Xi Y (φ (p.1.get i)),
        (∀ i, P i ∈ A i) ∧ cSubst H p σ P = W := by
  constructor
  · intro hW
    obtain ⟨P, hP, hPw⟩ :=
      exists_eq_substAssign_of_mem_substInto p.1 A hA (H.c p σ) hlin hW
    refine ⟨P, hP, ?_⟩
    rw [cSubst, cSubstAssign_eq_substAssign]
    exact hPw
  · rintro ⟨P, hP, rfl⟩
    rw [cSubst, cSubstAssign_eq_substAssign]
    exact mem_substInto_substAssign p.1 A P hP (H.c p σ)

/-- The range of a homomorphism is a subalgebra. -/
theorem isSubalgebra_range {B : SSet T} {FB : AlgStruct Xi B}
    {g : SortedMap (Term Xi Y) B} (hg : IsAlgHom Xi (termAlg Xi Y).2 FB g) :
    IsSubalgebra Xi FB (fun t => Set.range (g t)) := by
  classical
  intro p σ b hb
  choose P hP using fun i => hb i
  refine ⟨Term.op p σ P, ?_⟩
  rw [hg p σ P]
  congr 1
  funext i
  exact hP i

/-- The corestriction of `g` to its range. -/
def rangeHom {B : SSet T} (g : SortedMap (Term Xi Y) B) :
    SortedMap (Term Xi Y) (fun t => {b : B t // b ∈ Set.range (g t)}) :=
  fun t a => ⟨g t a, ⟨a, rfl⟩⟩

/-- The corestriction of `g` to its range is a homomorphism. -/
theorem rangeHom_isAlgHom {B : SSet T} {FB : AlgStruct Xi B}
    {g : SortedMap (Term Xi Y) B} (hg : IsAlgHom Xi (termAlg Xi Y).2 FB g) :
    IsAlgHom Xi (termAlg Xi Y).2
      (subAlg Xi FB (fun t => Set.range (g t)) (isSubalgebra_range hg)).2
      (rangeHom g) := by
  intro p σ a
  exact Subtype.ext (hg p σ a)

/-- The corestriction of `g` to its range is surjective. -/
theorem rangeHom_surjective {B : SSet T} (g : SortedMap (Term Xi Y) B) :
    ∀ t, Function.Surjective (rangeHom g t) := by
  intro t b
  obtain ⟨a, ha⟩ := b.2
  exact ⟨a, Subtype.ext ha⟩

/-- The induced `Σ`-algebra structure `c(A)` on `A_φ` (`MSCong` §3.5,
`IndAlgStrucImHom`): defined on representatives using the surjectivity of `g`,
well-defined by `cSubst_congr`. -/
noncomputable def cStruct {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) {B : SSet T}
    (FB : AlgStruct Xi B) (g : SortedMap (Term Xi Y) B)
    (_hg : IsAlgHom Xi (termAlg Xi Y).2 FB g) (hsurj : ∀ t, Function.Surjective (g t)) :
    AlgStruct Sig (fun s => B (φ s)) :=
  fun p σ a =>
    g (φ p.2) (cSubst H p σ (fun i => Classical.choose (hsurj (φ (p.1.get i)) (a i))))

/-- The defining property of `c(A)` on actual images: substituting then applying
`g` is applying `g` after substituting. -/
theorem cStruct_eval {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) {B : SSet T}
    {FB : AlgStruct Xi B} {g : SortedMap (Term Xi Y) B}
    (hg : IsAlgHom Xi (termAlg Xi Y).2 FB g) (hsurj : ∀ t, Function.Surjective (g t))
    (p : List S × S) (σ : Sig p)
    (P : (i : Fin p.1.length) → Term Xi Y (φ (p.1.get i))) :
    cStruct H FB g hg hsurj p σ (fun i => g (φ (p.1.get i)) (P i))
      = g (φ p.2) (cSubst H p σ P) := by
  unfold cStruct
  exact cSubst_congr H hg
    (fun i => Classical.choose_spec (hsurj (φ (p.1.get i)) (g (φ (p.1.get i)) (P i))))

/-- `g_φ` is a `Σ`-homomorphism `c(T_Ξ(Y)) → c(A)`. -/
theorem cAlg_to_cStruct {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) {B : SSet T}
    {FB : AlgStruct Xi B} {g : SortedMap (Term Xi Y) B}
    (hg : IsAlgHom Xi (termAlg Xi Y).2 FB g) (hsurj : ∀ t, Function.Surjective (g t)) :
    IsAlgHom Sig (cAlg H) (cStruct H FB g hg hsurj) (fun s P => g (φ s) P) := by
  intro p σ a
  change g (φ p.2) (cSubst H p σ a)
    = cStruct H FB g hg hsurj p σ (fun i => g (φ (p.1.get i)) (a i))
  rw [cStruct_eval H hg hsurj p σ a]

/-! ### The refinement `Ψ` for `PRecLH` -/

/-- The factors of `Φ`: the syntactic congruence `Ω(δ^{φ(r),{f_r(x)}})` of the
generator `(r,x) ∈ ∐X`, together with a harmless top factor at the extra `Unit`
index. The extra index makes the family nonempty (as in `PRecSubs`), so
`IsFiniteIndex_inter` applies even when `X` is empty; `nabla` is the top relation
and does not change the intersection. -/
noncomputable def treePhiFac {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) :
    (Sigma X ⊕ Unit) → SortedEqv (Term Xi Y) :=
  fun i =>
    match i with
    | Sum.inl x => congCogenerated Xi (termAlg Xi Y)
        (deltaSub (φ x.1) ({H.f x.1 x.2} : Set (Term Xi Y (φ x.1))))
    | Sum.inr _ => nabla (Term Xi Y)

/-- `Φ` (`MSCong` §3.5, `PRecLH`): the intersection, over the generators
`(x,r) ∈ ∐X`, of the syntactic congruences `Ω(δ^{φ(r),{f_r(x)}})` on
`T_Ξ(Y)` (the extra `Unit` factor of `treePhiFac` is top and harmless). -/
noncomputable def treePhi {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) :
    SortedEqv (Term Xi Y) :=
  sortedEqvInter (treePhiFac H)

/-- `Φ` is of finite index when `X` and the sort set `T` are finite: it is the
intersection of the finitely many syntactic congruences of the singleton
generators (`recognizableAt_term`) and `nabla`. -/
theorem isFiniteIndex_treePhi {φ : S → T} (H : Hyperderivor φ Sig Xi X Y)
    [Fintype (Sigma X)] [Finite T] : IsFiniteIndex (treePhi H) := by
  classical
  haveI : Nonempty (Sigma X ⊕ Unit) := ⟨Sum.inr ()⟩
  show IsFiniteIndex (sortedEqvInter (treePhiFac H))
  refine IsFiniteIndex_inter (Φ := treePhiFac H) (fun i => ?_)
  cases i with
  | inl x =>
      exact recognizable_isRegularLanguage Xi (termAlg Xi Y)
        (deltaSub (φ x.1) ({H.f x.1 x.2} : Set (Term Xi Y (φ x.1))))
        ((recognizableAt_iff Xi (termAlg Xi Y) (φ x.1)
          ({H.f x.1 x.2} : Set (Term Xi Y (φ x.1)))).mp
            (recognizableAt_term (H.f x.1 x.2)))
  | inr _ =>
      exact isFiniteIndex_nabla (Term Xi Y)
        ((finite_supp_term_iff Xi).mpr ‹Finite T› Y)

/-- Each singleton generator `{f_r(x)}` is `Φ`-saturated: it is saturated by its
own syntactic factor, which refines `Φ`. -/
theorem isSat_treePhi_singleton {φ : S → T} (H : Hyperderivor φ Sig Xi X Y)
    (r : S) (x : X r) :
    IsSat (treePhi H) (deltaSub (φ r) ({H.f r x} : Set (Term Xi Y (φ r)))) :=
  sat_antitone (sortedEqvInter_le (treePhiFac H) (Sum.inl ⟨r, x⟩))
    (isSat_congCogenerated Xi (termAlg Xi Y) (deltaSub (φ r) {H.f r x}))

/-- `Φ` is a congruence: the intersection of the cogenerated congruences of the
singleton generators and the top relation. -/
theorem isCongruence_treePhi {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) :
    IsCongruence Xi (termAlg Xi Y).2 (treePhi H) := by
  show IsCongruence Xi (termAlg Xi Y).2 (sortedEqvInter (treePhiFac H))
  refine IsCongruence_inter Xi (termAlg Xi Y).2 (treePhiFac H) (fun i => ?_)
  cases i with
  | inl x => exact congCogenerated_isCongruence Xi (termAlg Xi Y) _
  | inr _ => exact nabla_isCongruence Xi (termAlg Xi Y).2

/-- `Θ` (`MSCong` §3.5, `PRecLH`): the syntactic congruence `Ω(δ^{s,L})` on
`T_Σ(X)`. -/
noncomputable def treeTheta (Sig : Signature S) (X : SSet S) (s : S)
    (L : Set (Term Sig X s)) : SortedEqv (Term Sig X) :=
  congCogenerated Sig (termAlg Sig X) (deltaSub s L)

/-- `Θ` is of finite index when `L` is `s`-recognizable. -/
theorem isFiniteIndex_treeTheta (Sig : Signature S) (X : SSet S) (s : S)
    (L : Set (Term Sig X s))
    (hL : RecognizableAt Sig (termAlg Sig X) s L) :
    IsFiniteIndex (treeTheta Sig X s L) :=
  recognizable_isRegularLanguage Sig (termAlg Sig X) (deltaSub s L)
    ((recognizableAt_iff Sig (termAlg Sig X) s L).mp hL)

/-- The direct image of the `l`-class of `Θ_r` under `f♯_r` (the paper's
`f♯_r[[W_{r,l}]_{Θ_r}]`). -/
noncomputable def treeClassImage {φ : S → T} (H : Hyperderivor φ Sig Xi X Y)
    (s : S) (L : Set (Term Sig X s)) (r : S)
    (l : Quotient (treeTheta Sig X s L r)) : Set (Term Xi Y (φ r)) :=
  treeHom H r '' {W | Quotient.mk (treeTheta Sig X s L r) W = l}

/-- The finite test space indexing `Ψ`'s second condition: an operation `σ`, a
subterm `R ∈ Subt(c(σ))` of sort `t`, and a family of `Θ`-classes (one per
argument position of `σ`). -/
abbrev TreeTest {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) (s : S)
    (L : Set (Term Sig X s)) (t : T) : Type u :=
  Σ pσ : Sigma Sig,
    {R : Term Xi (Yplus φ Y pσ.1.1) t // R ∈ Subt (H.c pσ.1 pσ.2) t} ×
      ((i : Fin pσ.1.1.length) → Quotient (treeTheta Sig X s L (pσ.1.1.get i)))

/-- The set tested by a point of the test space: the substituted image
`((v_i ↦ f♯_{w_i}[[W_{w_i,l_i}]_{Θ_{w_i}}]))^♯(R)`. -/
noncomputable def treeTestSet {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) (s : S)
    (L : Set (Term Sig X s)) (t : T) (χ : TreeTest H s L t) :
    Set (Term Xi Y t) :=
  cSubstLang χ.1.1.1
    (fun i => treeClassImage H s L (χ.1.1.1.get i) (χ.2.2 i)) χ.2.1.1

/-- `Ψ` (`MSCong` §3.5, `PRecLH`): the refinement of `Φ` by agreement on the
substituted images `((v_i ↦ f♯_{w_i}[[W_{w_i,l_i}]_{Θ_{w_i}}]))^♯(R)` of every
subterm `R` of every `c_{w,r}(σ)`. -/
noncomputable def treeRefine {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) (s : S)
    (L : Set (Term Sig X s)) : SortedEqv (Term Xi Y) :=
  fun t =>
    { r := fun M N =>
        (treePhi H t).r M N ∧
          ∀ χ : TreeTest H s L t,
            (M ∈ treeTestSet H s L t χ ↔ N ∈ treeTestSet H s L t χ)
      iseqv :=
        ⟨fun M => ⟨(treePhi H t).refl M, fun _ => Iff.rfl⟩,
         fun h => ⟨(treePhi H t).symm h.1, fun χ => (h.2 χ).symm⟩,
         fun h1 h2 => ⟨(treePhi H t).trans h1.1 h2.1,
           fun χ => (h1.2 χ).trans (h2.2 χ)⟩⟩ }

/-- `Ψ` refines `Φ`. -/
theorem treeRefine_le_phi {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) (s : S)
    (L : Set (Term Sig X s)) :
    sortedEqvLe (treeRefine H s L) (treePhi H) :=
  fun _ _ _ h => h.1

/-- The test space is finite when `Σ` and the `Θ`-quotient are. -/
noncomputable def treeTest_fintype {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) (s : S)
    (L : Set (Term Sig X s)) (t : T) [Finite (Sigma Sig)]
    (hΘ : IsFiniteIndex (treeTheta Sig X s L)) : Fintype (TreeTest H s L t) := by
  haveI : Fintype (Sigma Sig) := Fintype.ofFinite _
  haveI : Finite (Sigma (fun r => Quotient (treeTheta Sig X s L r))) := hΘ
  haveI : ∀ r, Finite (Quotient (treeTheta Sig X s L r)) := fun r =>
    Finite.of_injective
      (fun q => (⟨r, q⟩ : Sigma (fun r => Quotient (treeTheta Sig X s L r))))
      (fun a b h => by simpa using h)
  haveI : ∀ r, Fintype (Quotient (treeTheta Sig X s L r)) := fun r => Fintype.ofFinite _
  haveI : ∀ pσ : Sigma Sig, Fintype
      ({R : Term Xi (Yplus φ Y pσ.1.1) t // R ∈ Subt (H.c pσ.1 pσ.2) t} ×
        ((i : Fin pσ.1.1.length) → Quotient (treeTheta Sig X s L (pσ.1.1.get i)))) := by
    intro pσ
    haveI : Fintype {R : Term Xi (Yplus φ Y pσ.1.1) t // R ∈ Subt (H.c pσ.1 pσ.2) t} :=
      (Subt_finite (H.c pσ.1 pσ.2) t).fintype
    haveI : Fintype ((i : Fin pσ.1.1.length) →
        Quotient (treeTheta Sig X s L (pσ.1.1.get i))) := inferInstance
    exact inferInstance
  haveI : Finite (TreeTest H s L t) := inferInstance
  exact Fintype.ofFinite _

/-- `Ψ` has finite index: its quotient injects into the quotient of `Φ` times
the (finite) set of membership sign vectors over the test space. -/
theorem isFiniteIndex_treeRefine {φ : S → T} (H : Hyperderivor φ Sig Xi X Y) (s : S)
    (L : Set (Term Sig X s)) [Finite (Sigma Sig)]
    (hΦ : IsFiniteIndex (treePhi H)) (hΘ : IsFiniteIndex (treeTheta Sig X s L)) :
    IsFiniteIndex (treeRefine H s L) := by
  classical
  set Ψ := treeRefine H s L with hΨdef
  have hle : sortedEqvLe Ψ (treePhi H) := by
    rw [hΨdef]; exact treeRefine_le_phi H s L
  obtain ⟨hsuppΦ, hfibΦ⟩ := (finiteSSet_iff (quot (treePhi H))).mp hΦ
  rw [IsFiniteIndex, finiteSSet_iff]
  have hsub : supp (quot Ψ) ⊆ supp (quot (treePhi H)) := by
    rintro t ⟨q⟩
    exact ⟨quotLe Ψ (treePhi H) hle t q⟩
  refine ⟨hsuppΦ.subset hsub, ?_⟩
  intro t _ht
  haveI : Finite (Quotient (treePhi H t)) := hfibΦ t (hsub _ht)
  haveI : Finite (quot (treePhi H) t) := hfibΦ t (hsub _ht)
  haveI : Fintype (Quotient (treePhi H t)) := Fintype.ofFinite _
  haveI : Fintype (TreeTest H s L t) := treeTest_fintype H s L t hΘ
  refine Finite.of_injective
    (f := fun q : Quotient (Ψ t) =>
      (quotLe Ψ (treePhi H) hle t q,
       Quotient.lift (fun M : Term Xi Y t => fun (χ : TreeTest H s L t) =>
          if M ∈ treeTestSet H s L t χ then true else false)
        (fun M N hMN => funext fun χ => by
          have hiff := hMN.2 χ
          by_cases hM : M ∈ treeTestSet H s L t χ
          · have hN : N ∈ treeTestSet H s L t χ := hiff.mp hM
            simp [hM, hN]
          · have hN : ¬ N ∈ treeTestSet H s L t χ := fun hN => hM (hiff.mpr hN)
            simp [hM, hN]) q)) ?_
  rintro q1 q2 h
  induction q1 using Quotient.inductionOn with
  | h M =>
    induction q2 using Quotient.inductionOn with
    | h N =>
      simp only [Prod.mk.injEq] at h
      obtain ⟨h1, h2⟩ := h
      have hΦrel : (treePhi H t).r M N := by
        have h1' := h1
        simp only [quotLe_mk] at h1'
        exact Quotient.exact h1'
      refine Quotient.sound ⟨hΦrel, fun χ => ?_⟩
      have hc := congrFun h2 χ
      simp only [Quotient.lift_mk] at hc
      by_cases hM : M ∈ treeTestSet H s L t χ <;>
        by_cases hN : N ∈ treeTestSet H s L t χ <;> simp_all

/-- Task 4.3 of `PRecLH`: the direct image `f♯_s[L]` is `Ψ_{φ(s)}`-saturated.
Case (a) uses `Φ`'s saturation of the singleton generators; case (b) uses the
second condition of `Ψ` at the test `(σ, c(σ), ([P_i]_{Θ}))` together with the
linearity of `c(σ)` (via `mem_cSubstLang_iff`). -/
theorem isSat_treeRefine_image {φ : S → T} (H : Hyperderivor φ Sig Xi X Y)
    (hirr : Hyperderivor.IsLinear H) (s : S) (L : Set (Term Sig X s)) :
    IsSat (treeRefine H s L) (deltaSub (φ s) (treeHom H s '' L)) := by
  classical
  refine isSat_of_forall_mem ?_
  intro u x y hx hxy
  by_cases hu : u = φ s
  · subst hu
    rw [deltaSub_self] at hx ⊢
    obtain ⟨P, hPL, hPx⟩ := hx
    subst hPx
    have opcase : ∀ (w : List S) (σ₀ : Sig (w, s))
        (Q : (i : Fin w.length) → Term Sig X (w.get i)),
        Term.op (w, s) σ₀ Q ∈ L →
        (treeRefine H s L (φ s)).r (treeHom H s (Term.op (w, s) σ₀ Q)) y →
        y ∈ treeHom H s '' L := by
      intro w σ₀ Q hPL hxy
      let l : (i : Fin w.length) → Quotient (treeTheta Sig X s L (w.get i)) :=
        fun i => Quotient.mk (treeTheta Sig X s L (w.get i)) (Q i)
      let A : (i : Fin w.length) → Set (Term Xi Y (φ (w.get i))) :=
        fun i => treeClassImage H s L (w.get i) (l i)
      let χ : TreeTest H s L (φ s) :=
        ⟨⟨(w, s), σ₀⟩, ⟨H.c (w, s) σ₀, Subt_self (H.c (w, s) σ₀)⟩, fun i => l i⟩
      have hfam : ∀ i, treeHom H (w.get i) (Q i) ∈ A i := fun i => ⟨Q i, rfl, rfl⟩
      have hχ : treeTestSet H s L (φ s) χ = cSubstLang w A (H.c (w, s) σ₀) := rfl
      have hXmem : treeHom H s (Term.op (w, s) σ₀ Q) ∈ treeTestSet H s L (φ s) χ := by
        rw [show treeHom H s (Term.op (w, s) σ₀ Q)
              = cSubst H (w, s) σ₀ (fun i => treeHom H (w.get i) (Q i))
            from treeHom_op H (w, s) σ₀ Q,
            cSubst_eq, hχ]
        exact mem_substInto_substAssign w A (fun i => treeHom H (w.get i) (Q i)) hfam
          (H.c (w, s) σ₀)
      have hymem : y ∈ treeTestSet H s L (φ s) χ := (hxy.2 χ).mp hXmem
      rw [hχ] at hymem
      obtain ⟨P', hP', hP'y⟩ :=
        (mem_cSubstLang_iff H (w, s) σ₀ A
          (fun i => ⟨treeHom H (w.get i) (Q i), hfam i⟩) (hirr (w, s) σ₀)).mp hymem
      have hP'img : ∀ i, ∃ W : Term Sig X (w.get i),
          Quotient.mk (treeTheta Sig X s L (w.get i)) W = l i ∧
            treeHom H (w.get i) W = P' i := by
        intro i
        have h := hP' i
        change P' i ∈ treeClassImage H s L (w.get i) (l i) at h
        exact (Set.mem_image _ _ _).mp h
      choose Q' hQ'cl hQ'eq using hP'img
      have hrel : ∀ i, (treeTheta Sig X s L (w.get i)).r (Q' i) (Q i) := by
        intro i
        have h := hQ'cl i
        rw [show l i = Quotient.mk (treeTheta Sig X s L (w.get i)) (Q i) from rfl] at h
        exact Quotient.exact h
      have hΘc := (congCogenerated_isCongruence Sig (termAlg Sig X) (deltaSub s L))
        (w, s) σ₀ Q' Q hrel
      have hLmem : Term.op (w, s) σ₀ Q' ∈ L := by
        have hsat := isSat_congCogenerated Sig (termAlg Sig X) (deltaSub s L)
        have hx0 : Term.op (w, s) σ₀ Q ∈ deltaSub s L s := by
          rw [deltaSub_self]; exact hPL
        have h := isSat_mem hsat hx0 ((treeTheta Sig X s L s).symm hΘc)
        rw [deltaSub_self] at h
        exact h
      refine ⟨Term.op (w, s) σ₀ Q', hLmem, ?_⟩
      rw [show treeHom H s (Term.op (w, s) σ₀ Q')
            = cSubst H (w, s) σ₀ (fun i => treeHom H (w.get i) (Q' i))
          from treeHom_op H (w, s) σ₀ Q']
      rw [show (fun i => treeHom H (w.get i) (Q' i)) = P' from funext hQ'eq]
      exact hP'y
    rcases term_shape Sig X s P with ⟨x0, rfl⟩ | ⟨σ₀, rfl⟩ | ⟨w, _hw, σ₀, Q, rfl⟩
    · have hrel : (treePhi H (φ s)).r (H.f s x0) y := hxy.1
      have hx0 : H.f s x0 ∈ deltaSub (φ s) ({H.f s x0} : Set (Term Xi Y (φ s))) (φ s) := by
        rw [deltaSub_self]; exact Set.mem_singleton _
      have hy := isSat_mem (isSat_treePhi_singleton H s x0) hx0 hrel
      rw [deltaSub_self] at hy
      exact ⟨Term.var x0, hPL, by rw [Set.mem_singleton_iff.mp hy]; rfl⟩
    · exact opcase [] σ₀ (fun i => i.elim0) hPL hxy
    · exact opcase w σ₀ Q hPL hxy
  · rw [deltaSub_of_ne hu] at hx
    exact absurd hx (Set.notMem_empty x)

/-- `PRecH` (`MSCong` Prop. `PRecH`): the inverse image of a recognizable language
under a tree homomorphism is recognizable. The proof passes to the range of the
recognizing homomorphism (making it surjective) and applies `cAlg_to_cStruct`.

Hypothesis `[Finite S]`: our `FiniteAlg` is *finite total* (`FiniteSSet`), so the
induced recognizing algebra `s ↦ Br_{φ(s)}` is finite only when the sort set is;
the paper omits this, but its finiteness notion is coarser. -/
theorem PRecH {φ : S → T} [Finite S] (H : Hyperderivor φ Sig Xi X Y) (s : S)
    (L : Set (Term Xi Y (φ s)))
    (hL : RecognizableAt Xi (termAlg Xi Y) (φ s) L) :
    RecognizableAt Sig (termAlg Sig X) s ((treeHom H s) ⁻¹' L) := by
  classical
  obtain ⟨B, hB, g, hg, M, hM⟩ := hL
  let Yr : Sub B.1 := fun t => Set.range (g t)
  have hYr : IsSubalgebra Xi B.2 Yr := isSubalgebra_range hg
  let Br : Alg Xi := subAlg Xi B.2 Yr hYr
  let g' : SortedMap (Term Xi Y) Br.1 := rangeHom g
  have hg' : IsAlgHom Xi (termAlg Xi Y).2 Br.2 g' := rangeHom_isAlgHom hg
  have hg'surj : ∀ t, Function.Surjective (g' t) := rangeHom_surjective g
  haveI : Finite (Sigma B.1) := hB
  have hfib : ∀ t, Finite (B.1 t) := fun t =>
    Finite.of_injective (fun b : B.1 t => (⟨t, b⟩ : Sigma B.1))
      (fun a b h => by simpa using h)
  have hBrfin : FiniteAlg ⟨fun s => Br.1 (φ s), cStruct H Br.2 g' hg' hg'surj⟩ := by
    show FiniteSSet (fun s => Br.1 (φ s))
    rw [finiteSSet_iff]
    refine ⟨Set.Finite.subset (Set.finite_univ) (fun _ _ => trivial), ?_⟩
    intro s _
    haveI : Finite (B.1 (φ s)) := hfib (φ s)
    exact Finite.of_injective (fun b : Br.1 (φ s) => b.1)
      (fun a b h => Subtype.ext h)
  let M' : Set (Br.1 (φ s)) := {b | b.1 ∈ M}
  refine ⟨⟨fun s => Br.1 (φ s), cStruct H Br.2 g' hg' hg'surj⟩, hBrfin,
    (fun s a => g' (φ s) (treeHom H s a)), ?_, M', ?_⟩
  · exact IsAlgHom_comp (treeHom_isAlgHom H) (cAlg_to_cStruct H hg' hg'surj)
  · ext a
    rw [Set.mem_preimage, Set.mem_preimage, hM]
    rfl

end Mscong
