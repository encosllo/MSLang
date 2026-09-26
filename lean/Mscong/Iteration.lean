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

/-- Substitution into a singleton language. -/
theorem substLang_singleton (Sig : Signature S) (X : SSet S)
    (A : SortedMap X (pCarrier (Term Sig X))) (s : S) (P : Term Sig X s) :
    substLang Sig X A s ({P} : Set (Term Sig X s)) = substHom Sig X A s P := by
  ext W
  rw [mem_substLang]
  constructor
  · rintro ⟨P', hP', hW⟩
    rw [Set.mem_singleton_iff] at hP'
    subst hP'
    exact hW
  · intro hW
    exact ⟨P, rfl, hW⟩

/-- The subset-hom `substHom` is monotone in the assigned family. -/
theorem substHom_mono (Sig : Signature S) (X : SSet S)
    {L L' : SortedMap X (pCarrier (Term Sig X))}
    (h : ∀ r y, L r y ⊆ L' r y) :
    ∀ (r : S) (P : Term Sig X r), substHom Sig X L r P ⊆ substHom Sig X L' r P := by
  intro r P
  induction P using Term.rec with
  | var y =>
      rename_i u
      rw [substHom_var, substHom_var]
      exact h u y
  | op p σ a ih =>
      intro W hW
      rw [mem_substHom_op] at hW
      obtain ⟨b, hb, rfl⟩ := hW
      rw [mem_substHom_op]
      exact ⟨b, fun i => ih i (hb i), rfl⟩

/-- The iteration assignment is monotone in the assigned language. -/
theorem iterAssign_mono (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    {Q Q' : Set (Term Sig X s)} (h : Q ⊆ Q') :
    ∀ r y, iterAssign Sig X s z Q r y ⊆ iterAssign Sig X s z Q' r y := by
  intro r y W hW
  unfold iterAssign at hW ⊢
  split_ifs at hW ⊢ with h1 h2
  · subst h1
    simpa using h hW
  · exact hW
  · exact hW

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

/-- `substHom` of a monotone family of iteration assignments. -/
theorem substHom_iterAssign_mono (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    {Q Q' : Set (Term Sig X s)} (h : Q ⊆ Q') :
    ∀ (u : S) (W : Term Sig X u),
      substHom Sig X (iterAssign Sig X s z Q) u W
        ⊆ substHom Sig X (iterAssign Sig X s z Q') u W :=
  substHom_mono Sig X (iterAssign_mono Sig X s z h)

/-- `⋃_j substHom (iterAssign z L^{j,z}) (var z) = L^{⋆z}`. -/
theorem iUnion_substHom_iterAssign_var (Sig : Signature S) (X : SSet S) (s : S)
    (z : X s) (L : Set (Term Sig X s)) :
    (⋃ j, substHom Sig X (iterAssign Sig X s z (iterLevel Sig X s z L j)) s
        (Term.var z)) = iterLang Sig X s z L := by
  rw [show (fun j => substHom Sig X
        (iterAssign Sig X s z (iterLevel Sig X s z L j)) s (Term.var z))
      = (fun j => iterLevel Sig X s z L j) from by
      funext j
      exact substHom_iterAssign_self Sig X s z (iterLevel Sig X s z L j)]
  rfl

/-- **Level-lifting identity.** The subset-hom with the assignment that
substitutes the whole iteration `L^{⋆z}` agrees, coefficientwise, with the union
over the levels `L^{j,z}`: for every term `W`,
`substHom (iterAssign z L^{⋆z}) W = ⋃_j substHom (iterAssign z L^{j,z}) W`.
The operation case needs a maximum over the finitely many arguments of `W`. -/
theorem substHom_iterAssign_iUnion (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (L : Set (Term Sig X s)) :
    ∀ (u : S) (W : Term Sig X u),
      substHom Sig X (iterAssign Sig X s z (iterLang Sig X s z L)) u W
        = ⋃ j, substHom Sig X (iterAssign Sig X s z (iterLevel Sig X s z L j)) u W := by
  intro u W
  induction W using Term.rec with
  | var y =>
      rename_i v
      by_cases hv : v = s
      · cases hv
        by_cases hy : y = z
        · cases hy
          rw [substHom_iterAssign_self, iUnion_substHom_iterAssign_var]
        · ext W'
          rw [substHom_iterAssign_ne (hy := hy)]
          simp only [Set.mem_iUnion]
          constructor
          · intro h
            exact ⟨0, by rwa [substHom_iterAssign_ne (hy := hy)]⟩
          · rintro ⟨j, hj⟩
            rwa [substHom_iterAssign_ne (hy := hy)] at hj
      · ext W'
        rw [substHom_iterAssign_ne_sort (hr := hv)]
        simp only [Set.mem_iUnion]
        constructor
        · intro h
          exact ⟨0, by rwa [substHom_iterAssign_ne_sort (hr := hv)]⟩
        · rintro ⟨j, hj⟩
          rwa [substHom_iterAssign_ne_sort (hr := hv)] at hj
  | op p σ b ih =>
      ext W'
      simp only [mem_substHom_op, Set.mem_iUnion, ih]
      constructor
      · rintro ⟨c, hc, rfl⟩
        choose J hJ using hc
        refine ⟨Finset.univ.sup J, c, fun i => ?_, rfl⟩
        exact substHom_iterAssign_mono Sig X s z
          (iterLevel_mono Sig X s z L (Finset.le_sup (Finset.mem_univ i)))
          (p.1.get i) (b i) (hJ i)
      · rintro ⟨j, c, hc, rfl⟩
        exact ⟨c, fun i => ⟨j, hc i⟩, rfl⟩

/-- `L^{⋆z}` is closed under substituting `L^{⋆z}` for `z` in `L`. -/
theorem iterImage_iterLang_subset (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (L : Set (Term Sig X s)) :
    iterImage Sig X s z (iterLang Sig X s z L) L ⊆ iterLang Sig X s z L := by
  intro W hW
  unfold iterImage at hW
  rw [mem_substLang] at hW
  obtain ⟨P, hP, hPW⟩ := hW
  rw [substHom_iterAssign_iUnion Sig X s z L s P] at hPW
  obtain ⟨j, hj⟩ := Set.mem_iUnion.mp hPW
  refine iterLevel_subset_iterLang Sig X s z L (j + 1) (Or.inr ?_)
  show W ∈ substLang Sig X (iterAssign Sig X s z (iterLevel Sig X s z L j)) s L
  exact (mem_substLang (Sig := Sig) (X := X)
    (L := iterAssign Sig X s z (iterLevel Sig X s z L j))
    (r := s) (K := L)).mpr ⟨P, hP, hj⟩

/-! ### The refinement `Ψ` for the iteration and `PRecIt` -/

/-- The assignment substituting the whole iteration `L^{⋆z}` for `z`. -/
noncomputable abbrev iterStarAssign (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (L : Set (Term Sig X s)) : SortedMap X (pCarrier (Term Sig X)) :=
  iterAssign Sig X s z (iterLang Sig X s z L)

/-- The refinement `Ψ` of the iteration proof: agreement on the substituted
images of the `Ω(δ^{s,L}) ∩ Ω(δ^{s,z})`-classes. -/
noncomputable abbrev iterStarRefine (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (L : Set (Term Sig X s)) (Φ : SortedEqv (Term Sig X)) : SortedEqv (Term Sig X) :=
  substRefine Sig X (iterStarAssign Sig X s z L) Φ

/-- **Lemma A** of the `PRecIt` proof: if an operation term lies in `L^{⋆z}` and
its arguments agree with `Q`'s under `Ψ`, then the `Q`-term lies in `L^{⋆z}`.
Proved by induction on the level (`MSCong` §3.3), using the `Ψ` class-agreement
and the `Φ`-saturation of `L`. -/
theorem iterStar_op_mem (Sig : Signature S) (X : SSet S) (s : S) (z : X s)
    (L : Set (Term Sig X s))
    {Φ : SortedEqv (Term Sig X)} (hΦc : IsCongruence Sig (termAlg Sig X).2 Φ)
    (hLsat : IsSat Φ (deltaSub s L))
    {w : List S} (σ : Sig (w, s)) (P Q : wordProd (Term Sig X) w)
    (hPQ : ∀ i, (iterStarRefine Sig X s z L Φ (w.get i)).r (P i) (Q i))
    (hP : Term.op (w, s) σ P ∈ iterLang Sig X s z L) :
    Term.op (w, s) σ Q ∈ iterLang Sig X s z L := by
  classical
  have hlevel : ∀ j, Term.op (w, s) σ P ∈ iterLevel Sig X s z L j →
      Term.op (w, s) σ Q ∈ iterLang Sig X s z L := by
    intro j
    induction j with
    | zero =>
        intro h
        rw [iterLevel, Set.mem_singleton_iff] at h
        exact absurd h (by intro hh; cases hh)
    | succ j ih =>
        intro h
        rw [iterLevel] at h
        rcases h with h | h
        · exact ih h
        · unfold iterImage at h
          rw [mem_substLang] at h
          obtain ⟨W, hWL, hPW⟩ := h
          have opcase : ∀ (w' : List S) (σ' : Sig (w', s))
              (a : (i : Fin w'.length) → Term Sig X (w'.get i)),
              W = Term.op (w', s) σ' a →
              Term.op (w, s) σ P ∈
                substHom Sig X (iterAssign Sig X s z (iterLevel Sig X s z L j)) s W →
              Term.op (w, s) σ Q ∈ iterLang Sig X s z L := by
            intro w' σ' a hWeq hPW
            subst hWeq
            have hstep := (mem_substHom_op Sig X
              (iterAssign Sig X s z (iterLevel Sig X s z L j)) σ' a
              (Term.op (w, s) σ P)).mp hPW
            obtain ⟨b, hb, hbeq⟩ := hstep
            injection hbeq with h1 h2 h3
            have hweq : w' = w := congrArg Prod.fst h1
            cases hweq
            have hσe : σ' = σ := eq_of_heq h2
            cases hσe
            have hbPe : b = P := eq_of_heq h3
            cases hbPe
            have hPmem : ∀ i, P i ∈ substClass Sig X
                (iterStarAssign Sig X s z L) Φ (w.get i)
                (Quotient.mk (Φ (w.get i)) (a i)) := by
              intro i
              exact mem_substClass rfl
                (substHom_iterAssign_mono Sig X s z
                  (iterLevel_subset_iterLang Sig X s z L j) (w.get i) (a i) (hb i))
            have hQmem : ∀ i, Q i ∈ substClass Sig X
                (iterStarAssign Sig X s z L) Φ (w.get i)
                (Quotient.mk (Φ (w.get i)) (a i)) :=
              fun i => ((hPQ i).2 _).mp (hPmem i)
            choose a' ha'mk ha'mem using hQmem
            have hT'L : Term.op (w, s) σ a' ∈ L := by
              have hWd : Term.op (w, s) σ a ∈ (deltaSub s L) s := by rwa [deltaSub_self]
              have hrel : (Φ s).r (Term.op (w, s) σ a) (Term.op (w, s) σ a') :=
                hΦc (w, s) σ a a' (fun i => (Φ (w.get i)).symm (Quotient.exact (ha'mk i)))
              have h' := isSat_mem hLsat hWd hrel
              rwa [deltaSub_self] at h'
            refine iterImage_iterLang_subset Sig X s z L ?_
            unfold iterImage
            rw [mem_substLang]
            refine ⟨Term.op (w, s) σ a', hT'L, ?_⟩
            exact (mem_substHom_op Sig X (iterStarAssign Sig X s z L) σ a'
              (Term.op (w, s) σ Q)).mpr ⟨Q, ha'mem, rfl⟩
          rcases term_shape Sig X s W with ⟨x, hx⟩ | ⟨σ₀, hσ₀⟩ | ⟨w', _hw, σ', a, hTa⟩
          · cases hx
            by_cases hx2 : x = z
            · cases hx2
              rw [substHom_iterAssign_self] at hPW
              exact ih hPW
            · rw [substHom_iterAssign_ne (hy := hx2)] at hPW
              exact absurd hPW (by
                intro hh; rw [Set.mem_singleton_iff] at hh; cases hh)
          · exact opcase [] σ₀ (fun i => i.elim0) hσ₀ hPW
          · exact opcase w' σ' a hTa hPW
  obtain ⟨j, hj⟩ := Set.mem_iUnion.mp hP
  exact hlevel j hj

/-- `PRecIt` (`MSCong` Prop. `PRecIt`): if `L ⊆ T_Σ(X)_s` is `s`-recognizable
then its `z`-iteration `L^{⋆z}` is `s`-recognizable. The proof refines
`Φ = Ω(δ^{s,L}) ∩ Ω(δ^{s,z})` by `Ψ` (`iterStarRefine`), whose class-agreement
is Lemma A on the `z`-case of the operation compatibility. -/
theorem PRecIt (Sig : Signature S) (X : SSet S) [Finite S] (s : S) (z : X s)
    (L : Set (Term Sig X s))
    (hL : RecognizableAt Sig (termAlg Sig X) s L) :
    RecognizableAt Sig (termAlg Sig X) s (iterLang Sig X s z L) := by
  classical
  rw [recognizableAt_iff] at hL ⊢
  let Φ : SortedEqv (Term Sig X) :=
    sortedEqvInf (congCogenerated Sig (termAlg Sig X) (deltaSub s L))
      (congCogenerated Sig (termAlg Sig X) (deltaSub s {Term.var z}))
  have hΦc : IsCongruence Sig (termAlg Sig X).2 Φ :=
    IsCongruence_inf Sig (termAlg Sig X).2
      (congCogenerated_isCongruence Sig (termAlg Sig X) (deltaSub s L))
      (congCogenerated_isCongruence Sig (termAlg Sig X) (deltaSub s {Term.var z}))
  have hΦf : IsFiniteIndex Φ :=
    IsFiniteIndex_inf
      ((recognizable_iff_isRegularLanguage Sig (termAlg Sig X) (deltaSub s L)).mp hL)
      ((recognizable_iff_isRegularLanguage Sig (termAlg Sig X)
        (deltaSub s {Term.var z})).mp
        ((recognizableAt_iff Sig (termAlg Sig X) s {Term.var z}).mp
          (PRecVar Sig X s z)))
  have hΦsatL : IsSat Φ (deltaSub s L) :=
    sat_antitone (sortedEqvInf_le_left _ _)
      (isSat_congCogenerated Sig (termAlg Sig X) (deltaSub s L))
  have hΦsatZ : IsSat Φ (deltaSub s {Term.var z}) :=
    sat_antitone (sortedEqvInf_le_right _ _)
      (isSat_congCogenerated Sig (termAlg Sig X) (deltaSub s {Term.var z}))
  have hΨf : IsFiniteIndex (iterStarRefine Sig X s z L Φ) :=
    isFiniteIndex_substRefine Sig X (iterStarAssign Sig X s z L) hΦf
  have hΨsat : IsSat (iterStarRefine Sig X s z L Φ) (deltaSub s (iterLang Sig X s z L)) := by
    have h := isSat_deltaSub_of_sat_hom Sig X (iterStarAssign Sig X s z L)
      (s := s) (K := ({Term.var z} : Set (Term Sig X s))) hΦsatZ
    rwa [substLang_singleton, substHom_iterAssign_self] at h
  have hΨc : IsCongruence Sig (termAlg Sig X).2 (iterStarRefine Sig X s z L Φ) := by
    intro p σ P Q hPQ
    obtain ⟨w, r⟩ := p
    have hvarP : ∀ x : X r,
        Term.op (w, r) σ P ∈ substHom Sig X (iterStarAssign Sig X s z L) r (Term.var x) →
        Term.op (w, r) σ Q ∈ substHom Sig X (iterStarAssign Sig X s z L) r (Term.var x) := by
      intro x hPT
      by_cases hr : r = s
      · cases hr
        by_cases hx : x = z
        · cases hx
          rw [substHom_iterAssign_self] at hPT
          rw [substHom_iterAssign_self]
          exact iterStar_op_mem Sig X s z L hΦc hΦsatL σ P Q hPQ hPT
        · rw [substHom_iterAssign_ne (hy := hx)] at hPT
          exact absurd hPT (by
            intro hh; rw [Set.mem_singleton_iff] at hh; cases hh)
      · rw [substHom_iterAssign_ne_sort (hr := hr)] at hPT
        exact absurd hPT (by
          intro hh; rw [Set.mem_singleton_iff] at hh; cases hh)
    have hvarQ : ∀ x : X r,
        Term.op (w, r) σ Q ∈ substHom Sig X (iterStarAssign Sig X s z L) r (Term.var x) →
        Term.op (w, r) σ P ∈ substHom Sig X (iterStarAssign Sig X s z L) r (Term.var x) := by
      intro x hPT
      by_cases hr : r = s
      · cases hr
        by_cases hx : x = z
        · cases hx
          rw [substHom_iterAssign_self] at hPT
          rw [substHom_iterAssign_self]
          exact iterStar_op_mem Sig X s z L hΦc hΦsatL σ Q P
            (fun i => (iterStarRefine Sig X s z L Φ (w.get i)).symm (hPQ i)) hPT
        · rw [substHom_iterAssign_ne (hy := hx)] at hPT
          exact absurd hPT (by
            intro hh; rw [Set.mem_singleton_iff] at hh; cases hh)
      · rw [substHom_iterAssign_ne_sort (hr := hr)] at hPT
        exact absurd hPT (by
          intro hh; rw [Set.mem_singleton_iff] at hh; cases hh)
    refine ⟨hΦc (w, r) σ P Q (fun i => (hPQ i).1), fun q => ?_⟩
    constructor
    · exact (substClass_op_imp_of Sig X (iterStarAssign Sig X s z L) hΦc
        (σ := σ) (P := P) (Q := Q) hPQ hvarP) q
    · exact (substClass_op_imp_of Sig X (iterStarAssign Sig X s z L) hΦc
        (σ := σ) (P := Q) (Q := P)
        (fun i => (iterStarRefine Sig X s z L Φ (w.get i)).symm (hPQ i)) hvarQ) q
  exact (recognizable_iff_exists_finiteIndex_sat Sig (termAlg Sig X)
    (deltaSub s (iterLang Sig X s z L))).mpr
    ⟨iterStarRefine Sig X s z L Φ, hΨc, hΨf, hΨsat⟩

end Mscong
