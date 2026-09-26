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

set_option linter.style.haveILetI false

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
