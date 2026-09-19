import Mslang.Free

/-!
The term algebra `Term_Σ(X)` (`B-D027`): genuine `Σ`-terms over a sorted set of
variables, as an inductive family with a recursor, giving the free `Σ`-algebra
its universal property.

The word-based `TAlg` (`Free.lean`) is a `Sg`-generated subalgebra of `W_Σ(X)`,
and `MemSg` is a `Prop`, so it supports only the *uniqueness* half of the free
universal property (`TAlg_hom_ext`). `Term` is the same free `Σ`-algebra
presented as an inductive `Type`, which has a recursor, and therefore also
supplies the *existence* half: every sorted map `X → A` extends to a
`Σ`-homomorphism `Term_Σ(X) → A`, uniquely. This is the infrastructure `B-P020`
needs (a quotient of a free algebra; projectivity of the free algebra).
-/

universe u

namespace Mslang

variable {S : Type u}

/-- `B-D027`: the inductive family of `Σ`-terms over an `S`-sorted set `X` of
variables. A term is either a variable `x : X s`, or a formal application
`F_σ(t_i)_{i<|w|}` of an operation `σ : Σ_{w,s}` to terms of the required sorts.
This is the free `Σ`-algebra `T_Σ(X)` presented as a `Type` with a recursor. -/
inductive Term (Sig : Signature S) (X : SSet S) : S → Type u
  | var {s : S} (x : X s) : Term Sig X s
  | op (p : List S × S) (σ : Sig p)
      (a : (i : Fin p.1.length) → Term Sig X (p.1.get i)) : Term Sig X p.2

/-- `B-D027`: `Term_Σ(X)` as a `Σ`-algebra; the operation `σ` is the `op`
constructor. -/
@[reducible]
def termAlg {S : Type u} (Sig : Signature S) (X : SSet S) : Alg Sig :=
  ⟨Term Sig X, fun p σ a => Term.op p σ a⟩

/-- `B-D027`: the insertion `η^X : X → Term_Σ(X)`. -/
def termEta {S : Type u} (Sig : Signature S) (X : SSet S) :
    SortedMap X (Term Sig X) :=
  fun _ x => Term.var x

/-- The homomorphic extension `Term_Σ(X) → A` of a sorted map `g : X → A`, by
recursion on the term. This is the *existence* half of the free-algebra
universal property, unavailable for the word-based `TAlg`. -/
def termLift {S : Type u} (Sig : Signature S) (X : SSet S) {A : SSet S}
    (FA : AlgStruct Sig A) (g : SortedMap X A) : (s : S) → Term Sig X s → A s
  | _, .var x => g _ x
  | _, .op p σ a => FA p σ (fun i => termLift Sig X FA g _ (a i))

/-- `B-D027`: the extension of `g` is a `Σ`-homomorphism. -/
theorem termLift_isAlgHom {S : Type u} (Sig : Signature S) (X : SSet S)
    {A : SSet S} (FA : AlgStruct Sig A) (g : SortedMap X A) :
    IsAlgHom Sig (termAlg Sig X).2 FA (termLift Sig X FA g) := by
  intro p σ a
  rfl

/-- `B-D027`: the extension of `g` agrees with `g` on the inserted generators. -/
theorem termLift_eta {S : Type u} (Sig : Signature S) (X : SSet S)
    {A : SSet S} (FA : AlgStruct Sig A) (g : SortedMap X A) :
    (fun s => termLift Sig X FA g s ∘ termEta Sig X s) = g := by
  funext s x
  rfl

/-- `B-D027` (universal property, existence and uniqueness): for every sorted
map `g : X → A` there is exactly one homomorphism `f : Term_Σ(X) → A` with
`f ∘ η^X = g`, namely `termLift g`. -/
theorem termLift_unique {S : Type u} (Sig : Signature S) (X : SSet S)
    {A : SSet S} (FA : AlgStruct Sig A) (g : SortedMap X A)
    (f : SortedMap (Term Sig X) A) (hf : IsAlgHom Sig (termAlg Sig X).2 FA f)
    (hη : (fun s => f s ∘ termEta Sig X s) = g) :
    f = termLift Sig X FA g := by
  funext s t
  induction t with
  | var x =>
      have h := congrFun (congrFun hη _) x
      simpa [termEta, termLift] using h
  | op p σ a ih =>
      rw [show f p.2 (Term.op p σ a) =
        FA p σ (fun i => f (p.1.get i) (a i)) from hf p σ a]
      show FA p σ (fun i => f (p.1.get i) (a i)) =
        FA p σ (fun i => termLift Sig X FA g (p.1.get i) (a i))
      congr 1
      funext i
      exact ih i

/-- `B-P011` (free-algebra universal property, existence and uniqueness): for
every `Σ`-algebra `A` and every sorted map `g : X → A` there is a *unique*
homomorphism `f♯ : T_Σ(X) → A` with `f♯ ∘ η^X = g`. Existence is the recursive
`termLift`; uniqueness is `termLift_unique` (`B-L001`). -/
theorem exists_unique_termLift {S : Type u} (Sig : Signature S) (X : SSet S)
    {A : SSet S} (FA : AlgStruct Sig A) (g : SortedMap X A) :
    ∃! f : SortedMap (Term Sig X) A,
      IsAlgHom Sig (termAlg Sig X).2 FA f ∧ (fun s => f s ∘ termEta Sig X s) = g := by
  refine ⟨termLift Sig X FA g,
    ⟨⟨termLift_isAlgHom Sig X FA g, termLift_eta Sig X FA g⟩, ?_⟩⟩
  intro f hf
  exact termLift_unique Sig X FA g f hf.1 hf.2

/-- `B-D027`: the evaluation `Term_Σ(A) → A` of a `Σ`-algebra on its own
underlying sorted set, the extension of the identity map. -/
def termEval {S : Type u} (Sig : Signature S) (A : Alg Sig) :
    SortedMap (Term Sig A.1) A.1 :=
  termLift Sig A.1 A.2 (fun _ a => a)

/-- `B-D027`: the evaluation is a `Σ`-homomorphism. -/
theorem termEval_isAlgHom {S : Type u} (Sig : Signature S) (A : Alg Sig) :
    IsAlgHom Sig (termAlg Sig A.1).2 A.2 (termEval Sig A) :=
  termLift_isAlgHom Sig A.1 A.2 (fun _ a => a)

/-- `B-D027`: the evaluation `Term_Σ(A) → A` is surjective — every element of `A`
is the value of a term, namely the generator `(a)`. Hence every `Σ`-algebra is a
quotient of a free `Σ`-algebra, which is the first input to `B-P020`. -/
theorem termEval_surjective {S : Type u} (Sig : Signature S) (A : Alg Sig) :
    ∀ s, Function.Surjective (termEval Sig A s) :=
  fun _s a => ⟨Term.var a, rfl⟩

/-- The canonical `Σ`-homomorphism `Term_Σ(X) → T_Σ(X)` (`B-D027`): it extends
`η^X` by the universal property, i.e. it sends each variable term to the
one-letter row `(x)`. This is the comparison map between the inductive free
algebra (`Term`) and the row presentation (`TAlg`). It is surjective (see
`toT_surjective`); injectivity is the term-characterization proposition
`B-P010` (unique parsing), which is not yet formalized. -/
def toT {S : Type u} (Sig : Signature S) (X : SSet S) :
    SortedMap (Term Sig X) (TSet Sig X) :=
  termLift Sig X (TAlg Sig X).2 (etaX Sig X)

/-- The comparison map `toT` is a `Σ`-homomorphism. -/
theorem toT_isAlgHom {S : Type u} (Sig : Signature S) (X : SSet S) :
    IsAlgHom Sig (termAlg Sig X).2 (TAlg Sig X).2 (toT Sig X) :=
  termLift_isAlgHom Sig X (TAlg Sig X).2 (etaX Sig X)

/-- The comparison map `toT` agrees with the insertions on generators. -/
theorem toT_eta {S : Type u} (Sig : Signature S) (X : SSet S) :
    (fun s => toT Sig X s ∘ termEta Sig X s) = etaX Sig X :=
  termLift_eta Sig X (TAlg Sig X).2 (etaX Sig X)

/-- The comparison map `toT : Term_Σ(X) → T_Σ(X)` is surjective: its image is a
subalgebra of `W_Σ(X)` containing the generators `(x)`, so it contains
`Sg_{W_Σ(X)}(genSet) = T_Σ(X)`. This expresses `T_Σ(X)` as a quotient of the
inductive free algebra; the missing injectivity is `B-P010`. -/
theorem toT_surjective {S : Type u} (Sig : Signature S) (X : SSet S) :
    ∀ s, Function.Surjective (toT Sig X s) := by
  classical
  intro s P
  let im : Sub (WSet Sig X) := fun s P => ∃ t : Term Sig X s, (toT Sig X s t).1 = P
  have hgen : Subset (genSet Sig X) im := by
    intro s P hP
    obtain ⟨x, rfl⟩ := hP
    exact ⟨Term.var x, rfl⟩
  have him : IsSubalgebra Sig (WAlg Sig X).2 im := by
    intro p σ a ha
    choose t ht using ha
    refine ⟨Term.op p σ t, ?_⟩
    show (toT Sig X p.2 (Term.op p σ t)).1 = (WAlg Sig X).2 p σ a
    rw [show toT Sig X p.2 (Term.op p σ t) =
        (TAlg Sig X).2 p σ (fun i => toT Sig X (p.1.get i) (t i)) from rfl]
    show (WAlg Sig X).2 p σ (fun i => (toT Sig X (p.1.get i) (t i)).1) =
      (WAlg Sig X).2 p σ a
    rw [show (fun i => (toT Sig X (p.1.get i) (t i)).1) = a from funext ht]
  have hSg := Sg_least Sig (WAlg Sig X).2 him hgen
  exact ⟨Classical.choose (hSg s P.2),
    Subtype.ext (Classical.choose_spec (hSg s P.2))⟩

/-- `B-D027` (projectivity of the free `Σ`-algebra): given an epimorphism
`f : B → C` and a homomorphism `g : Term_Σ(X) → C`, there is a homomorphism
`l : Term_Σ(X) → B` with `f ∘ l = g`. The lift chooses preimages of the images
of the generators and extends by the universal property; the equation `f ∘ l = g`
follows from uniqueness. This is the second input to `B-P020`. -/
theorem term_projective {S : Type u} (Sig : Signature S) (X : SSet S)
    {B C : SSet S} (FB : AlgStruct Sig B) (FC : AlgStruct Sig C)
    (f : SortedMap B C) (hf : IsAlgHom Sig FB FC f)
    (hsurj : ∀ s, Function.Surjective (f s))
    (g : SortedMap (Term Sig X) C)
    (hg : IsAlgHom Sig (termAlg Sig X).2 FC g) :
    ∃ l : SortedMap (Term Sig X) B,
      IsAlgHom Sig (termAlg Sig X).2 FB l ∧ (fun s => f s ∘ l s) = g := by
  classical
  have hpre : ∀ s (x : X s), ∃ b : B s, f s b = g s (termEta Sig X s x) :=
    fun s x => hsurj s (g s (termEta Sig X s x))
  let g' : SortedMap X B := fun s x => Classical.choose (hpre s x)
  have hg' : (fun s => f s ∘ g' s) = fun s => g s ∘ termEta Sig X s := by
    funext s x
    exact Classical.choose_spec (hpre s x)
  refine ⟨termLift Sig X FB g', termLift_isAlgHom Sig X FB g', ?_⟩
  let fl : SortedMap (Term Sig X) C := fun s t => f s (termLift Sig X FB g' s t)
  have hfl : IsAlgHom Sig (termAlg Sig X).2 FC fl := by
    intro p σ a
    show f p.2 (termLift Sig X FB g' p.2 (Term.op p σ a)) =
      FC p σ (fun i => f (p.1.get i) (termLift Sig X FB g' (p.1.get i) (a i)))
    rw [show termLift Sig X FB g' p.2 (Term.op p σ a) =
      FB p σ (fun i => termLift Sig X FB g' (p.1.get i) (a i)) from rfl]
    exact hf p σ (fun i => termLift Sig X FB g' (p.1.get i) (a i))
  have hfle : (fun s => fl s ∘ termEta Sig X s) =
      (fun s x => g s (termEta Sig X s x)) := by
    funext s x
    show f s (termLift Sig X FB g' s (termEta Sig X s x)) = g s (termEta Sig X s x)
    rw [show termLift Sig X FB g' s (termEta Sig X s x) = g' s x from
      congrFun (congrFun (termLift_eta Sig X FB g') s) x]
    exact congrFun (congrFun hg' s) x
  let g0 : SortedMap X C := fun s x => g s (termEta Sig X s x)
  have hfl_eq : fl = termLift Sig X FC g0 :=
    termLift_unique Sig X FC g0 fl hfl hfle
  have hgl : g = termLift Sig X FC g0 :=
    termLift_unique Sig X FC g0 g hg (by funext s x; rfl)
  calc (fun s => f s ∘ termLift Sig X FB g' s) = fl := rfl
    _ = termLift Sig X FC g0 := hfl_eq
    _ = g := hgl.symm

end Mslang
