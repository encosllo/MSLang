import Mslang.Prelim

/-!
`Σ`-algebras: signatures, word products, structures, homomorphisms, supports and
finiteness of algebras, products of algebras, subalgebras and the generating
operator `Sg`, and the many-sorted closure-system vocabulary (`B-D010`-`B-D013`).
-/

universe u v

namespace Mslang

variable {S : Type u}

-- `letI` installs the `CompleteLattice` instance consumed by the proof below;
-- the style linter's `let` suggestion would not register it as an instance.
set_option linter.style.haveILetI false


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

/-- An algebraic closure system on a plain type `X` (the one-sorted instance of
`IsAlgebraicClosureSystem`, used for `Sub(Alg(Σ))` in `B-P018`): a family of
subsets of `X` containing `X`, closed under nonempty intersections and under
nonempty directed unions. -/
def IsAlgebraicClosureSystemOn (X : Type v) (C : Set (Set X)) : Prop :=
  Set.univ ∈ C ∧
    (∀ D : Set (Set X), D ⊆ C → D.Nonempty → ⋂₀ D ∈ C) ∧
    (∀ D : Set (Set X), D ⊆ C → D.Nonempty →
      (∀ A ∈ D, ∀ B ∈ D, ∃ E ∈ D, A ⊆ E ∧ B ⊆ E) → ⋃₀ D ∈ C)

/-- An algebraic closure system on a plain type `X` with a fixed **carrier**
`C₀` (the instance needed by `B-P033`, where the ambient class is the *finite*
algebras `Alg_f(Σ)` rather than all of `Alg(Σ)`): a family `C` of subsets of
`C₀`, containing `C₀`, closed under nonempty intersections and nonempty directed
unions. -/
def IsAlgebraicClosureSystemOnCarrier (X : Type v) (C₀ : Set X) (C : Set (Set X)) :
    Prop :=
  C₀ ∈ C ∧
    (∀ F ∈ C, F ⊆ C₀) ∧
    (∀ D : Set (Set X), D ⊆ C → D.Nonempty → ⋂₀ D ∈ C) ∧
    (∀ D : Set (Set X), D ⊆ C → D.Nonempty →
      (∀ A ∈ D, ∀ B ∈ D, ∃ E ∈ D, A ⊆ E ∧ B ⊆ E) → ⋃₀ D ∈ C)

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

/-- The bridge used by `B-C005`/`B-C011`: the closed sets of an **algebraic**
closure operator (one whose closed sets are closed under directed unions) form an
algebraic lattice. The compact elements are the closures `c F` of finite sets
`F`. The key input is the finite character of `c` (an element of `c U` lies in
`c F` for some finite `F ⊆ U`), which follows from directed-union closure, and
the fact that every closed set is the supremum of the closures of its finite
subsets. -/
theorem isAlgebraicLattice_of_isAlgebraicClosureOperator {X : Type v}
    (c : ClosureOperator (Set X))
    (halg : ∀ s : Set (Set X), (∀ a ∈ s, c.IsClosed a) → s.Nonempty →
      (∀ a ∈ s, ∀ b ∈ s, ∃ d ∈ s, a ⊆ d ∧ b ⊆ d) → c.IsClosed (⋃₀ s)) :
    letI := c.gi.liftCompleteLattice
    IsAlgebraicLattice c.Closeds := by
  letI := c.gi.liftCompleteLattice
  have hsSup_val : ∀ s : Set c.Closeds, (sSup s).1 = c (⋃₀ (Subtype.val '' s)) := by
    intro s
    show c (sSup (Subtype.val '' s)) = c (⋃₀ (Subtype.val '' s))
    rfl
  have finite_character : ∀ {U : Set X} {x : X}, x ∈ c U →
      ∃ F : Set X, F.Finite ∧ F ⊆ U ∧ x ∈ c F := by
    intro U x hx
    let D : Set (Set X) := {T | c.IsClosed T ∧ ∃ F : Set X, F.Finite ∧ F ⊆ U ∧ T = c F}
    have hDsub : D ⊆ {T | c.IsClosed T} := fun T hT => hT.1
    have hDne : D.Nonempty :=
      ⟨c ∅, c.isClosed_closure ∅, ∅, Set.finite_empty, Set.empty_subset U, rfl⟩
    have hDdir : ∀ A ∈ D, ∀ B ∈ D, ∃ E ∈ D, A ⊆ E ∧ B ⊆ E := by
      rintro A ⟨-, FA, hFA, hFAU, rfl⟩ B ⟨-, FB, hFB, hFBU, rfl⟩
      refine ⟨c (FA ∪ FB), ⟨c.isClosed_closure _, FA ∪ FB, hFA.union hFB,
        Set.union_subset hFAU hFBU, rfl⟩, ?_, ?_⟩
      · intro y hy; exact c.monotone Set.subset_union_left hy
      · intro y hy; exact c.monotone Set.subset_union_right hy
    have hUnionClosed : c.IsClosed (⋃₀ D) := halg D hDsub hDne hDdir
    have hUsub : U ⊆ ⋃₀ D := by
      intro y hy
      exact ⟨c {y}, ⟨c.isClosed_closure {y}, {y}, Set.finite_singleton y,
        Set.singleton_subset_iff.mpr hy, rfl⟩, c.le_closure {y} (Set.mem_singleton y)⟩
    have hcU : c U ⊆ ⋃₀ D := c.closure_min hUsub hUnionClosed
    obtain ⟨T, hTD, hxT⟩ := hcU hx
    obtain ⟨-, F, hFfin, hFU, rfl⟩ := hTD
    exact ⟨F, hFfin, hFU, hxT⟩
  have compact_closure : ∀ F : Set X, F.Finite → IsCompact (c.toCloseds F) := by
    intro F hF S hSF
    classical
    change c F ≤ c (⋃₀ (Subtype.val '' S)) at hSF
    have hFU : F ⊆ c (⋃₀ (Subtype.val '' S)) := fun x hx => hSF (c.le_closure F hx)
    have hchoice : ∀ x ∈ F, ∃ G : Set X, G.Finite ∧ G ⊆ ⋃₀ (Subtype.val '' S) ∧ x ∈ c G :=
      fun x hx => finite_character (hFU hx)
    let Fx : X → Set X := fun x => if hx : x ∈ F then Classical.choose (hchoice x hx) else ∅
    have hFxfin : ∀ x ∈ F, (Fx x).Finite := by
      intro x hx
      have := (Classical.choose_spec (hchoice x hx)).1
      simpa only [Fx, dif_pos hx] using this
    have hFxsub : ∀ x ∈ F, Fx x ⊆ ⋃₀ (Subtype.val '' S) := by
      intro x hx
      have := (Classical.choose_spec (hchoice x hx)).2.1
      simpa only [Fx, dif_pos hx] using this
    have hxFx : ∀ x ∈ F, x ∈ c (Fx x) := by
      intro x hx
      have := (Classical.choose_spec (hchoice x hx)).2.2
      simpa only [Fx, dif_pos hx] using this
    let F' : Set X := ⋃ x ∈ F, Fx x
    have hF'fin : F'.Finite := hF.biUnion hFxfin
    have hF'sub : F' ⊆ ⋃₀ (Subtype.val '' S) := by
      intro y hy
      rcases Set.mem_iUnion.mp hy with ⟨x, hy⟩
      rcases Set.mem_iUnion.mp hy with ⟨hx, hyx⟩
      exact hFxsub x hx hyx
    have hFsub : F ⊆ c F' := by
      intro x hx
      exact c.monotone (fun y hy => Set.mem_iUnion.mpr ⟨x, Set.mem_iUnion.mpr ⟨hx, hy⟩⟩)
        (hxFx x hx)
    have hcFF' : c F ⊆ c F' := c.closure_min hFsub (c.isClosed_closure F')
    have hSy : ∀ y ∈ F', ∃ B ∈ S, y ∈ B.1 := by
      intro y hy
      rcases Set.mem_sUnion.mp (hF'sub hy) with ⟨T, ⟨B, hB, rfl⟩, hyT⟩
      exact ⟨B, hB, hyT⟩
    let g : X → c.Closeds :=
      fun y => if hy : y ∈ F' then Classical.choose (hSy y hy) else c.toCloseds ∅
    let Y : Set c.Closeds := g '' F'
    have hYfin : Y.Finite := hF'fin.image g
    have hYsub : Y ⊆ S := by
      rintro B ⟨y, hy, rfl⟩
      simp only [g, dif_pos hy]
      exact (Classical.choose_spec (hSy y hy)).1
    refine ⟨Y, hYsub, hYfin, ?_⟩
    change c F ≤ c (⋃₀ (Subtype.val '' Y))
    refine hcFF'.trans (c.monotone ?_)
    intro y hy
    refine Set.mem_sUnion.mpr ⟨(g y).1, ⟨g y, Set.mem_image_of_mem g hy, rfl⟩, ?_⟩
    simp only [g, dif_pos hy]
    exact (Classical.choose_spec (hSy y hy)).2
  intro A
  refine ⟨{B : c.Closeds | ∃ F : Set X, F.Finite ∧ F ⊆ A.1 ∧ B = c.toCloseds F}, ?_, ?_⟩
  · rintro B ⟨F, hF, -, rfl⟩
    exact compact_closure F hF
  · apply Subtype.ext
    change A.1 = c (⋃₀ (Subtype.val '' {B : c.Closeds | ∃ F : Set X,
      F.Finite ∧ F ⊆ A.1 ∧ B = c.toCloseds F}))
    apply le_antisymm
    · intro x hx
      exact c.le_closure _ (Set.mem_sUnion.mpr ⟨c {x},
        ⟨c.toCloseds {x}, ⟨{x}, Set.finite_singleton x,
          (fun y hy => by rw [Set.mem_singleton_iff] at hy; subst hy; exact hx), rfl⟩, rfl⟩,
        c.le_closure {x} (Set.mem_singleton x)⟩)
    · apply c.closure_min _ A.2
      intro y hy
      rcases Set.mem_sUnion.mp hy with ⟨_, ⟨B, ⟨F, hF, hFA, rfl⟩, rfl⟩, hyB⟩
      exact c.closure_min hFA A.2 hyB

end Mslang
