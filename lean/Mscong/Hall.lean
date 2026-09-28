import Mslang.Term

/-!
# `Mscong.Hall` -- Hall algebras and derivors (`MSCong` §6)

Milestone **M5** of the MSCong project (OpenSpec change
`add-derivors-hall-algebras`): the algebraic core of `MSCong.tex` §6. A **Hall
algebra** for a sort set `S` is an `S⋆ × S`-indexed set equipped with
projections `π^w_i` and substitution operators `ξ_{u,w,s}`, subject to the
projection `H1`, identity `H2`, and associativity `H3` equations. We build the
two canonical Hall algebras `Op_H(A)` (operations with composition) and
`Ter_H(Σ)` (terms with substitution), the derived `Σ`-algebra `A^{f,u}`, and
Lemma `L:aux`.

This is **unmapped infrastructure**: no block IDs, no evidence; `mscong` stays
`ingested: false` (see `design.md`). The free-Hall-algebra isomorphism and the
category-theoretic layer (`Sig_d`, `Alg_d`, the Grothendieck construction) are
deliberately out of scope.
-/

namespace Mscong

open Mslang

universe u

variable {S : Type u}

/-! ### The placeholder set `↓φ*(w)` -/

/-- The paper's `↓φ*(w)`: the `T`-sorted set with one placeholder in each
argument position `i < |w|`, placed at sort `φ(w_i)`. Its underlying index type
is the raw subtype `{i : Fin w.length // φ (w.get i) = t}`, lifted to `Type u`
so it lives in `SSet T`; it corresponds to the `Sum.inr` summand of M4's
`Yplus φ Y w = fun t => Y t ⊕ {i : Fin w.length // φ (w.get i) = t}`. -/
abbrev derivPlace {S T : Type u} (φ : S → T) (w : List S) : SSet T :=
  fun t => ULift {i : Fin w.length // φ (w.get i) = t}

/-! ### Hall algebras -/

/-- A **Hall algebra** for `S` (`MSCong` §6): an `S⋆ × S`-indexed carrier with
projections `π^w_i : carrier (w, w_i)` and substitution operators
`ξ_{u,w,s}`, satisfying the equations `H1` (projection), `H2` (identity), and
`H3` (associativity). -/
structure HallAlg (S : Type u) where
  /-- The underlying `S⋆ × S`-indexed set. -/
  carrier : List S × S → Type u
  /-- The projection `π^w_i` (`HS₁`). -/
  pi : (w : List S) → (i : Fin w.length) → carrier (w, w.get i)
  /-- The substitution operator `ξ_{u,w,s}` (`HS₂`). -/
  xi : (u w : List S) → (s : S) → carrier (w, s) →
    ((i : Fin w.length) → carrier (u, w.get i)) → carrier (u, s)
  /-- `H1`: `ξ_{u,w,w_i}(π^w_i, g) = g_i` (projection). -/
  H1 : ∀ (u w : List S) (i : Fin w.length)
    (g : (j : Fin w.length) → carrier (u, w.get j)),
    xi u w (w.get i) (pi w i) g = g i
  /-- `H2`: `ξ_{u,u,u_j}(a, π^u) = a` (identity). -/
  H2 : ∀ (u : List S) (j : Fin u.length) (a : carrier (u, u.get j)),
    xi u u (u.get j) a (fun i => pi u i) = a
  /-- `H3`: associativity of substitution. -/
  H3 : ∀ (u v w : List S) (s : S) (x : carrier (w, s))
    (g : (j : Fin w.length) → carrier (v, w.get j))
    (h : (k : Fin v.length) → carrier (u, v.get k)),
    xi u v s (xi v w s x g) h
      = xi u w s x (fun j => xi u v (w.get j) (g j) h)

attribute [simp] HallAlg.H1 HallAlg.H2 HallAlg.H3

/-! ### The Hall algebra of operations `Op_H(A)` -/

/-- The **Hall algebra of operations** `Op_{H_S}(A)` (`MSCong` §6): the
`S⋆ × S`-sorted set `(A_w → A_s)` with the true projections and substitution as
generalized composition `f ∘ ⟨g_i⟩`. -/
def OpH {S : Type u} (A : SSet S) : HallAlg S where
  carrier := fun p => ((i : Fin p.1.length) → A (p.1.get i)) → A p.2
  pi := fun _ i => fun f => f i
  xi := fun _ _ _ f g => fun a => f (fun i => g i a)
  H1 := fun _ _ _ _ => rfl
  H2 := fun _ _ _ => rfl
  H3 := fun _ _ _ _ _ _ _ => rfl

/-! ### Substitution on terms -/

/-- The free extension of a sorted map `f : X → T_Σ(Z)`: the term obtained from
`t : T_Σ(X)` by substituting each variable `x` by the term `f x`. -/
def termSubst {S : Type u} (Sig : Signature S) {X Z : SSet S}
    (f : SortedMap X (Term Sig Z)) (s : S) (t : Term Sig X s) : Term Sig Z s :=
  termLift Sig X (termAlg Sig Z).2 f s t

@[simp] theorem termSubst_var {S : Type u} (Sig : Signature S) {X Z : SSet S}
    (f : SortedMap X (Term Sig Z)) (s : S) (x : X s) :
    termSubst Sig f s (Term.var x) = f s x := rfl

@[simp] theorem termSubst_op {S : Type u} (Sig : Signature S) {X Z : SSet S}
    (f : SortedMap X (Term Sig Z)) (p : List S × S) (σ : Sig p)
    (a : (i : Fin p.1.length) → Term Sig X (p.1.get i)) :
    termSubst Sig f p.2 (Term.op p σ a)
      = Term.op p σ (fun i => termSubst Sig f (p.1.get i) (a i)) := rfl

/-- Substitution commutes with a transport of the sort. -/
theorem termSubst_cast {S : Type u} (Sig : Signature S) {X Z : SSet S}
    (f : SortedMap X (Term Sig Z)) {a b : S} (e : a = b) (t : Term Sig X a) :
    termSubst Sig f b (e ▸ t) = e ▸ termSubst Sig f a t := by cases e; rfl

/-- Substitution is associative: substituting `f` then `g` equals substituting
the composite map `x ↦ g(f x)`. -/
theorem termSubst_comp {S : Type u} (Sig : Signature S) {X Z W : SSet S}
    (f : SortedMap X (Term Sig Z)) (g : SortedMap Z (Term Sig W)) (s : S)
    (t : Term Sig X s) :
    termSubst Sig g s (termSubst Sig f s t)
      = termSubst Sig (fun r x => termSubst Sig g r (f r x)) s t := by
  induction t with
  | var x => rfl
  | op p σ a ih =>
      rw [termSubst_op, termSubst_op, termSubst_op]
      congr 1
      funext i
      exact ih i

/-- `Term.var` commutes with a transport of the sort. -/
theorem term_var_cast {S : Type u} (Sig : Signature S) {X : SSet S}
    {a b : S} (e : a = b) (x : X a) :
    (e ▸ Term.var x : Term Sig X b) = Term.var (e ▸ x) := by cases e; rfl

/-- `termLift` along `η` is the identity (the identity substitution). -/
theorem termLift_id {S : Type u} (Sig : Signature S) (X : SSet S) :
    termLift Sig X (termAlg Sig X).2 (termEta Sig X) = (fun _ t => t) := by
  symm
  refine termLift_unique Sig X (termAlg Sig X).2 (termEta Sig X) (fun _ t => t) ?_ ?_
  · intro p σ a; rfl
  · rfl

theorem termSubst_id {S : Type u} (Sig : Signature S) (X : SSet S) :
    termSubst Sig (termEta Sig X) = (fun _ (t : Term Sig X _) => t) := by
  funext s t
  exact congrFun (congrFun (termLift_id Sig X) s) t

/-! ### The Hall algebra of terms `Ter_H(Σ)` -/

/-- The sorted map substituting the argument family `Q` for the placeholders
`↓w`: the placeholder `⟨i, _⟩` is sent to `Q i`. -/
def substMap {S : Type u} (Sig : Signature S) (u w : List S)
    (Q : (i : Fin w.length) → Term Sig (derivPlace (id : S → S) u) (w.get i)) :
    SortedMap (derivPlace (id : S → S) w) (Term Sig (derivPlace (id : S → S) u)) :=
  fun _ v => v.down.2 ▸ Q v.down.1

/-- Substituting the identity argument family is the identity. -/
theorem substMap_pi {S : Type u} (Sig : Signature S) (u : List S) :
    substMap Sig u u (fun i => Term.var (ULift.up ⟨i, rfl⟩))
      = termEta Sig (derivPlace (id : S → S) u) := by
  funext t v
  simp only [substMap]
  rw [term_var_cast]
  congr 1
  cases v with
  | up vd =>
    cases vd with
    | mk i h =>
      cases h
      rfl

/-- The **Hall algebra of terms** `Ter_{H_S}(Σ)` (`MSCong` §6): the terms
`(T_Σ(↓w)_s)` with the placeholder projections `π^w_i = v_i` and substitution. -/
def TerH {S : Type u} (Sig : Signature S) : HallAlg S where
  carrier := fun p => Term Sig (derivPlace (id : S → S) p.1) p.2
  pi := fun w i => Term.var (ULift.up ⟨i, rfl⟩)
  xi := fun u w s P Q => termSubst Sig (substMap Sig u w Q) s P
  H1 := by
    intro u w i Q
    show termSubst Sig (substMap Sig u w Q) (w.get i)
        (Term.var (ULift.up ⟨i, rfl⟩)) = Q i
    rw [termSubst_var]
    rfl
  H2 := by
    intro u j a
    show termSubst Sig (substMap Sig u u (fun i => Term.var (ULift.up ⟨i, rfl⟩)))
        (u.get j) a = a
    rw [substMap_pi]
    exact congrFun (congrFun (termSubst_id Sig (derivPlace (id : S → S) u)) (u.get j)) a
  H3 := by
    intro u v w s x g h
    show termSubst Sig (substMap Sig u v h) s
          (termSubst Sig (substMap Sig v w g) s x)
        = termSubst Sig
            (substMap Sig u w
              (fun j => termSubst Sig (substMap Sig u v h) (w.get j) (g j))) s x
    have hmap : (fun r y => termSubst Sig (substMap Sig u v h) r
            (substMap Sig v w g r y))
        = substMap Sig u w
            (fun j => termSubst Sig (substMap Sig u v h) (w.get j) (g j)) := by
      funext t y
      simp only [substMap, termSubst_cast, id_eq]
    rw [termSubst_comp, hmap]

/-! ### The derived `Σ`-algebra `A^{f,u}` and Lemma `L:aux` -/

/-- The **derived `Σ`-algebra** `A^{f,u}` of a Hall algebra `A` (`MSCong` §6):
the `S`-sorted set `s ↦ A_{u,s}` with `σ`-operation
`(a_i) ↦ ξ^A_{u,w,s}(f_{w,s}(σ), a)`. -/
def derivedAlg {S : Type u} (A : HallAlg S) (Sig : Signature S)
    (f : (p : List S × S) → Sig p → A.carrier p) (u : List S) : Alg Sig :=
  ⟨fun s => A.carrier (u, s), fun p σ a => A.xi u p.1 p.2 (f p σ) a⟩

/-- The map `p^u : ↓u → A^{f,u}` sending the placeholder `⟨i, _⟩` to the
projection `π^u_i`. -/
def pMap {S : Type u} (A : HallAlg S) (u : List S) :
    SortedMap (derivPlace (id : S → S) u) (fun s => A.carrier (u, s)) :=
  fun _ v => v.down.2 ▸ A.pi u v.down.1

/-- The extension `(p^u)^♯ : T_Σ(↓u) → A^{f,u}` of the projections. -/
def pSharp {S : Type u} (A : HallAlg S) (Sig : Signature S)
    (f : (p : List S × S) → Sig p → A.carrier p) (u : List S) :
    (s : S) → Term Sig (derivPlace (id : S → S) u) s → A.carrier (u, s) :=
  termLift Sig (derivPlace (id : S → S) u) (derivedAlg A Sig f u).2 (pMap A u)

/-- **Lemma `L:aux`** (`MSCong` §6): the interpretation of `P` in the derived
algebra `A^{f,u}` equals `ξ^A_{u,w,s}((p^w)^♯(P), a)`. -/
theorem derivedAlg_eval {S : Type u} (A : HallAlg S) (Sig : Signature S)
    (f : (p : List S × S) → Sig p → A.carrier p) (u w : List S) (s : S)
    (P : Term Sig (derivPlace (id : S → S) w) s)
    (a : SortedMap (derivPlace (id : S → S) w) (fun t => A.carrier (u, t))) :
    termLift Sig (derivPlace (id : S → S) w) (derivedAlg A Sig f u).2 a s P
      = A.xi u w s (pSharp A Sig f w s P)
          (fun i => a (w.get i) (ULift.up ⟨i, rfl⟩)) := by
  induction P with
  | var x =>
      obtain ⟨⟨i, h⟩⟩ := x
      cases h
      simp only [termLift, pSharp, pMap, derivedAlg, id_eq, HallAlg.H1]
  | op p σ args ih =>
      show A.xi u p.1 p.2 (f p σ)
            (fun i => termLift Sig (derivPlace (id : S → S) w)
              (derivedAlg A Sig f u).2 a (p.1.get i) (args i))
          = A.xi u w p.2 (pSharp A Sig f w p.2 (Term.op p σ args))
              (fun i => a (w.get i) (ULift.up ⟨i, rfl⟩))
      have hp : pSharp A Sig f w p.2 (Term.op p σ args)
          = A.xi w p.1 p.2 (f p σ)
              (fun i => pSharp A Sig f w (p.1.get i) (args i)) := rfl
      rw [hp, HallAlg.H3 A u w p.1 p.2 (f p σ)
            (fun i => pSharp A Sig f w (p.1.get i) (args i))
            (fun k => a (w.get k) (ULift.up ⟨k, rfl⟩))]
      congr 1
      funext i
      exact ih i

end Mscong
