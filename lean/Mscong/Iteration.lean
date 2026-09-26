import Mscong.Substitution

/-!
# `Mscong.Iteration` -- the `z`-iteration of a language (`MSCong` §3.3)

Milestone **M3** of the MSCong project (OpenSpec change
`add-substitution-recognizability`): the `z`-iteration `L^{⋆z}` of a language.

The paper defines `L^{0,z} = {z}` and `L^{j+1,z} = L^{j,z} ∪ (z\L^{j,z})^♯_s(L)`,
and then `L^{⋆z} = ⋃_{j∈ℕ} L^{j,z}`. We encode `(z\Q)^♯_s(L)` directly as the
direct image `{P[z:=U] | P ∈ L, U ∈ Q}` (`iterImage`), reusing the
single-variable substitution `subst1`.

This module provides the definitions and the elementary chain facts
(`L^{1,z} = L ∪ {z}`, monotonicity). The **recognizability** result `PRecIt`
(`MSCong` Prop. `PRecIt`) is *not* proved here: the paper's proof refines the
syntactic congruence of `L` and `{z}` by agreement on the substituted images of
the `Φ`-classes, with a minimality induction on the construction of `L^{⋆z}`,
and it is deferred to a follow-up change (see `STATE.md` and `tasks.md`, 4.2).

This is **unmapped infrastructure**: no block IDs, no evidence; `mscong` stays
`ingested = false` (see `design.md`, D5).
-/

namespace Mscong

open Mslang

attribute [local instance] Classical.propDecidable

set_option linter.style.haveILetI false

universe u

variable {S : Type u}

/-- The `S`-sorted assignment that substitutes the language `Q` for the variable
`z` and fixes every other variable to its own singleton (the assignment whose
subset-hom is `(z\Q)^♯`). -/
noncomputable def iterAssign (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (Q : Set (Term Sig X s)) : SortedMap X (pCarrier (Term Sig X)) :=
  fun r y =>
    if h : r = s then
      (if (h ▸ y) = z then h.symm ▸ Q else {Term.var y})
    else {Term.var y}

/-- `(z\Q)^♯_s(L)`: the image of `L` under substituting, in every occurrence
independently, an element of `Q` for the variable `z` (the paper's subset-hom
applied to `L`). -/
noncomputable def iterImage (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (Q L : Set (Term Sig X s)) : Set (Term Sig X s) :=
  substLang Sig X (iterAssign Sig X s z Q) s L

theorem substHom_iterAssign_self (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (Q : Set (Term Sig X s)) :
    substHom Sig X (iterAssign Sig X s z Q) s (Term.var z) = Q := by
  rw [substHom_var]
  simp [iterAssign]

theorem substHom_iterAssign_ne (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (Q : Set (Term Sig X s)) (y : X s) (hy : y ≠ z) :
    substHom Sig X (iterAssign Sig X s z Q) s (Term.var y) = {Term.var y} := by
  rw [substHom_var]
  simp [iterAssign, hy]

theorem substHom_iterAssign_ne_sort (Sig : Signature S) (X : SSet S) (s : S)
    (z : X s) (Q : Set (Term Sig X s)) {r : S} (y : X r) (hr : r ≠ s) :
    substHom Sig X (iterAssign Sig X s z Q) r (Term.var y) = {Term.var y} := by
  rw [substHom_var]
  simp [iterAssign, hr]

/-- Transporting `{z}` along `h : u = s` when `h ▸ y = z` recovers `{y}`. -/
theorem iterAssign_cast_singleton {Sig : Signature S} {X : SSet S} {s u : S} {z : X s}
    (y : X u) (h : u = s) (he : (h ▸ y) = z) :
    h.symm ▸ ({Term.var z} : Set (Term Sig X s)) = ({Term.var y} : Set (Term Sig X u)) := by
  subst h
  simp at he
  subst he
  rfl

/-- With `Q = {z}` the assignment is the identity, so the subset-hom returns the
singleton `{P}` at every term. -/
theorem substHom_iterAssign_singleton (Sig : Signature S) (X : SSet S) (s : S)
    (z : X s) :
    ∀ (r : S) (P : Term Sig X r),
      substHom Sig X (iterAssign Sig X s z ({Term.var z} : Set (Term Sig X s))) r P
        = {P} := by
  intro r P
  induction P using Term.rec with
  | var y =>
      rename_i u
      rw [substHom_var]
      unfold iterAssign
      split_ifs with hu hy
      · exact iterAssign_cast_singleton (Sig := Sig) (X := X) y hu hy
      · rfl
      · rfl
  | op p σ b ih =>
      ext W
      rw [mem_substHom_op]
      constructor
      · rintro ⟨c, hc, hW⟩
        have hcb : c = b := by
          funext i
          have hi := hc i
          rw [ih i, Set.mem_singleton_iff] at hi
          exact hi
        rw [← hW, hcb]
        exact rfl
      · intro hW
        rw [Set.mem_singleton_iff] at hW
        subst hW
        exact ⟨b, fun i => by rw [ih i]; exact rfl, rfl⟩

/-- The recursively defined family `(L^{j,z})_{j∈ℕ}`: `L^{0,z} = {z}` and
`L^{j+1,z} = L^{j,z} ∪ (z\L^{j,z})^♯_s(L)`. -/
noncomputable def iterLevel (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (L : Set (Term Sig X s)) : ℕ → Set (Term Sig X s)
  | 0 => {Term.var z}
  | n + 1 => iterLevel Sig X s z L n ∪ iterImage Sig X s z (iterLevel Sig X s z L n) L

/-- `MSCong` §3.3: the `z`-iteration `L^{⋆z} = ⋃_{j∈ℕ} L^{j,z}`. -/
noncomputable def iterLang (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (L : Set (Term Sig X s)) : Set (Term Sig X s) :=
  ⋃ n, iterLevel Sig X s z L n

/-! ### Elementary facts -/

/-- Substituting `z` for itself is the identity on every term. -/
theorem subst1_self (Sig : Signature S) (X : SSet S) (s : S) (z : X s) :
    ∀ (u : S) (P : Term Sig X u), subst1 Sig X z (Term.var z) u P = P := by
  intro u P
  induction P using Term.rec with
  | var y =>
      rename_i w
      by_cases hw : w = s
      · subst hw
        by_cases hy : y = z
        · subst hy; rw [subst1_var_self]
        · rw [subst1_var_of_ne Sig X (Term.var z) y hy]
      · rw [subst1_var_of_ne_sort Sig X (Term.var z) y hw]
  | op p σ b ih =>
      rw [subst1_op]
      congr 1
      funext i
      exact ih i

/-- `(z\{z})^♯_s(L) = L`: substituting the singleton `{z}` for `z` is the
identity. -/
theorem iterImage_self (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (L : Set (Term Sig X s)) :
    iterImage Sig X s z ({Term.var z} : Set (Term Sig X s)) L = L := by
  unfold iterImage
  ext W
  rw [mem_substLang]
  constructor
  · rintro ⟨P, hP, hW⟩
    rw [substHom_iterAssign_singleton Sig X s z s P, Set.mem_singleton_iff] at hW
    rw [hW]
    exact hP
  · intro hW
    exact ⟨W, hW, by rw [substHom_iterAssign_singleton Sig X s z s W]; exact rfl⟩

/-- The paper's remark: `L^{1,z} = L ∪ {z}`. -/
theorem iterLevel_one (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (L : Set (Term Sig X s)) :
    iterLevel Sig X s z L 1 = {Term.var z} ∪ L := by
  show iterLevel Sig X s z L 0 ∪ iterImage Sig X s z (iterLevel Sig X s z L 0) L
      = {Term.var z} ∪ L
  rw [show iterLevel Sig X s z L 0 = ({Term.var z} : Set (Term Sig X s)) from rfl,
    iterImage_self]

/-- The paper's remark: `(L^{j,z})_{j∈ℕ}` is an ascending chain. -/
theorem iterLevel_subset_succ (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (L : Set (Term Sig X s)) (n : ℕ) :
    iterLevel Sig X s z L n ⊆ iterLevel Sig X s z L (n + 1) := by
  intro x hx
  exact Or.inl hx

/-- The chain `(L^{j,z})_{j∈ℕ}` is monotone. -/
theorem iterLevel_mono (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (L : Set (Term Sig X s)) {m n : ℕ} (h : m ≤ n) :
    iterLevel Sig X s z L m ⊆ iterLevel Sig X s z L n := by
  induction h with
  | refl => exact Set.Subset.refl _
  | step _ ih => exact Set.Subset.trans ih (iterLevel_subset_succ Sig X s z L _)

/-- Every level is contained in the iteration. -/
theorem iterLevel_subset_iterLang (Sig : Signature S) (X : SSet S) (s : S)
    (z : X s) (L : Set (Term Sig X s)) (n : ℕ) :
    iterLevel Sig X s z L n ⊆ iterLang Sig X s z L := by
  intro W hW
  exact Set.mem_iUnion.mpr ⟨n, hW⟩

end Mscong
