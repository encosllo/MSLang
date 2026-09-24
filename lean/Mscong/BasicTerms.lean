import Mscong.Recognizable
import Mslang.Term

/-!
# `Mscong.BasicTerms` -- basic-term recognizability (`MSCong` §3.1)

Milestone **M2** of the MSCong project (OpenSpec change
`add-basic-terms-recognizability`): the propositions `PRecVar`, `PRecConst`, and
`PRecOp` of `MSCong.tex` §3.1 over the free `Σ`-algebra `T_Σ(X)` as presented
by the inductive family `Mslang.Term`.

Following the paper, each proof exhibits a **finite** recognising `Σ`-algebra
`B` and the free extension `g♯ : T_Σ(X) → B` of a sorted map `g : X → B`, such
that the singleton language is the fibre of a distinguished value of `B`.

This is **unmapped infrastructure**: no block IDs, no evidence; `mscong` stays
`ingested: false` (see `design.md`, D4).
-/

namespace Mscong

open Mslang

universe u

variable {S : Type u}

/-- The two-element type at universe `u` used as the carrier of `2^S`. -/
inductive Two : Type u where
  | z : Two
  | o : Two
  deriving DecidableEq

instance : Fintype Two := ⟨{Two.z, Two.o}, by intro x; cases x <;> simp⟩

instance : Nonempty Two := ⟨Two.z⟩

/-! ### The finite recognizing algebra `2^S` -/

/-- The two-element `Σ`-algebra `2^S` (`MSCong` §3.1): carrier `Two` at every
sort and every operation the constant map to `z`. -/
noncomputable def twoAlg (Sig : Signature S) : Alg Sig :=
  ⟨fun _ => Two, fun _ _ _ => Two.z⟩

/-- `2^S` is finite when the sort set `S` is finite (`MSCong` §3.1, Assumption). -/
theorem finiteAlg_twoAlg (Sig : Signature S) [Finite S] : FiniteAlg (twoAlg Sig) := by
  rw [FiniteAlg, finiteSSet_iff]
  refine ⟨?_, fun _s _ => inferInstanceAs (Finite Two)⟩
  have hsupp : supp (twoAlg Sig).1 = Set.univ := by
    ext s
    constructor
    · intro _; trivial
    · intro _; exact ⟨Two.z⟩
  rw [hsupp]
  exact Set.finite_univ

/-- `PRecVar` (`MSCong` §3.1): for a variable `x : X s`, the singleton language
`{x} ⊆ T_Σ(X)_s` is recognizable. -/
theorem PRecVar (Sig : Signature S) (X : SSet S) [Finite S] (s : S) (x : X s) :
    RecognizableAt Sig (termAlg Sig X) s ({Term.var x} : Set (Term Sig X s)) := by
  classical
  let g : SortedMap X (fun _ => Two) := fun t y =>
    if ht : t = s then (if ht ▸ y = x then Two.o else Two.z) else Two.z
  have hgx : g s x = Two.o := by simp only [g, dif_pos rfl, if_true]
  refine ⟨twoAlg Sig, finiteAlg_twoAlg Sig, termLift Sig X (twoAlg Sig).2 g,
    termLift_isAlgHom Sig X (twoAlg Sig).2 g, {Two.o}, ?_⟩
  ext P
  simp only [Set.mem_singleton_iff, Set.mem_preimage]
  constructor
  · rintro rfl
    exact hgx
  · intro h
    suffices ∀ (t : S) (P : Term Sig X t),
        termLift Sig X (twoAlg Sig).2 g t P = Two.o →
          HEq P (Term.var x) by
      exact eq_of_heq (this s P h)
    exact fun t P =>
      Term.rec (motive := fun t P =>
          termLift Sig X (twoAlg Sig).2 g t P = Two.o → HEq P (Term.var x))
        (fun {u : S} (y : X u) => fun hy => by
          change g u y = Two.o at hy
          by_cases ht : u = s
          · subst ht
            have hy' : (if y = x then Two.o else Two.z) = Two.o := by
              simpa only [g, dif_pos rfl] using hy
            by_cases hxy : y = x
            · subst hxy; exact HEq.refl _
            · rw [if_neg hxy] at hy'
              exact absurd hy' (by decide)
          · simp only [g, dif_neg ht] at hy
            exact absurd hy (by decide))
        (fun p τ a ih => fun hy => by
          change Two.z = Two.o at hy
          exact absurd hy (by decide))
        P

/-! ### `PRecConst` -/

/-- The `2^S`-variant used by `PRecConst`: the distinguished constant
`σ : Σ_{λ,s}` maps the unique element of `2_{λ}` to `o`, every other operation
to `z`. -/
noncomputable def twoAlgConst (Sig : Signature S) {s : S} (σ : Sig ([], s)) : Alg Sig := by
  classical
  exact ⟨fun _ => Two, fun p τ _ =>
    if h : p = ([], s) then
      (if (Eq.mp (congrArg Sig h) τ : Sig ([], s)) = σ then Two.o else Two.z)
    else Two.z⟩

/-- `PRecConst` (`MSCong` §3.1): for a constant `σ : Σ_{λ,s}`, the singleton
language `{σ} ⊆ T_Σ(X)_s` is recognizable. -/
theorem PRecConst (Sig : Signature S) (X : SSet S) [Finite S] (s : S) (σ : Sig ([], s)) :
    RecognizableAt Sig (termAlg Sig X) s
      ({Term.op ([], s) σ (fun i => i.elim0)} : Set (Term Sig X s)) := by
  classical
  let g : SortedMap X (fun _ => Two) := fun _ _ => Two.z
  have hσ : (Eq.mp (congrArg Sig rfl) σ : Sig ([], s)) = σ := rfl
  have hT0 : termLift Sig X (twoAlgConst Sig σ).2 g s
      (Term.op ([], s) σ (fun i => i.elim0)) = Two.o := by
    change (if h : ([], s) = ([], s) then
        (if (Eq.mp (congrArg Sig h) σ : Sig ([], s)) = σ then Two.o else Two.z)
        else Two.z) = Two.o
    rw [dif_pos rfl, if_pos hσ]
  refine ⟨twoAlgConst Sig σ, finiteAlg_twoAlg Sig, termLift Sig X (twoAlgConst Sig σ).2 g,
    termLift_isAlgHom Sig X (twoAlgConst Sig σ).2 g, {Two.o}, ?_⟩
  ext P
  simp only [Set.mem_singleton_iff, Set.mem_preimage]
  constructor
  · rintro rfl
    exact hT0
  · intro h
    suffices ∀ (t : S) (P : Term Sig X t),
        termLift Sig X (twoAlgConst Sig σ).2 g t P = Two.o →
          HEq P (Term.op ([], s) σ (fun i => i.elim0)) by
      exact eq_of_heq (this s P h)
    exact fun t P =>
      Term.rec (motive := fun t P =>
          termLift Sig X (twoAlgConst Sig σ).2 g t P = Two.o →
            HEq P (Term.op ([], s) σ (fun i => i.elim0)))
        (fun {u : S} (y : X u) => fun hy => by
          change g u y = Two.o at hy
          simp only [g] at hy
          exact absurd hy (by decide))
        (fun p τ a ih => fun hy => by
          change (if h : p = ([], s) then
              (if (Eq.mp (congrArg Sig h) τ : Sig ([], s)) = σ then Two.o else Two.z)
              else Two.z) = Two.o at hy
          by_cases hp : p = ([], s)
          · rw [dif_pos hp] at hy
            by_cases hτ : (Eq.mp (congrArg Sig hp) τ : Sig ([], s)) = σ
            · rw [if_pos hτ] at hy
              subst hp
              change τ = σ at hτ
              subst hτ
              apply heq_of_eq
              have hargs : a = (fun i : Fin ([].length) => i.elim0) :=
                funext (fun i => i.elim0)
              rw [hargs]
            · rw [if_neg hτ] at hy
              exact absurd hy (by decide)
          · rw [dif_neg hp] at hy
            exact absurd hy (by decide))
        P

/-! ### `PRecOp` -/

/-- The finite carrier for `PRecOp`: a default, one value per position of the
arity word (the variable read there), and a distinguished marker. -/
inductive K (n : Nat) : Type u where
  | default : K n
  | var (i : Fin n) : K n
  | mark : K n
  deriving DecidableEq

instance (n : Nat) : Fintype (K n) where
  elems := ({K.default, K.mark} : Finset (K n)) ∪ (Finset.univ.image K.var)
  complete := by intro x; cases x <;> simp

theorem K.default_ne_mark {n : Nat} : (K.default : K n) ≠ K.mark := by
  intro h; cases h

/-- The carrier of the `PRecOp` recognizing algebra. -/
abbrev kCarrier (w : List S) : SSet S := fun _ => K w.length

/-- Transport a `Fin` along an equality of lengths; definitionally the identity
at `rfl` (`▸` rather than `Fin.cast`). -/
def finOfEq {n m : Nat} (h : n = m) (i : Fin n) : Fin m := h ▸ i

theorem finOfEq_self_eq {n : Nat} (h : n = n) (i : Fin n) : finOfEq h i = i := by
  cases h; rfl

/-- The position selected for the variable `x i` by `gOp`. -/
noncomputable def pickVar {w : List S} {X : SSet S}
    (x : (i : Fin w.length) → X (w.get i)) (i : Fin w.length) : Fin w.length :=
  Classical.choose (show ∃ i' : Fin w.length, w.get i' = w.get i ∧ HEq (x i') (x i) from
    ⟨i, rfl, HEq.refl _⟩)

/-- `g` for `PRecOp`: a variable in the image of `(x_i)` maps to its (chosen)
position, every other variable to the default. -/
noncomputable def gOp {w : List S} {X : SSet S}
    (x : (i : Fin w.length) → X (w.get i)) : SortedMap X (kCarrier w) := by
  classical
  exact fun t y =>
    if h : ∃ i : Fin w.length, w.get i = t ∧ HEq (x i) y then
      K.var (Classical.choose h)
    else K.default

theorem gOp_ne_mark {w : List S} {X : SSet S}
    (x : (i : Fin w.length) → X (w.get i)) (t : S) (y : X t) :
    gOp x t y ≠ K.mark := by
  classical
  unfold gOp
  split <;> (intro h; cases h)

theorem gOp_eq_var {w : List S} {X : SSet S}
    (x : (i : Fin w.length) → X (w.get i)) {t : S} {y : X t} {j : Fin w.length}
    (h : gOp x t y = K.var j) : HEq (x j) y := by
  classical
  simp only [gOp] at h
  split at h
  · rename_i hex
    injection h with hji
    subst hji
    exact (Classical.choose_spec hex).2
  · exact absurd h (by intro hh; cases hh)

theorem gOp_self {w : List S} {X : SSet S}
    (x : (i : Fin w.length) → X (w.get i)) (i : Fin w.length) :
    gOp x (w.get i) (x i) = K.var (pickVar x i) := by
  classical
  simp only [gOp, pickVar]
  rw [dif_pos (show ∃ i' : Fin w.length, w.get i' = w.get i ∧ HEq (x i') (x i) from
    ⟨i, rfl, HEq.refl _⟩)]

/-- The structural operations of the `PRecOp` recognizing algebra: `tgt` is the
target tuple of variable-values. -/
@[reducible] noncomputable def twoOpSig (Sig : Signature S) {w : List S} (s : S)
    (σ : Sig (w, s)) (tgt : (i : Fin w.length) → K w.length) :
    AlgStruct Sig (kCarrier w) := by
  classical
  exact fun p τ a =>
    if hp : p = (w, s) then
      (if hσ : Eq.mp (congrArg Sig hp) τ = σ then
        (if (∀ i : Fin w.length,
              a (finOfEq (congrArg List.length (congrArg Prod.fst hp).symm) i) = tgt i)
          then K.mark else K.default)
        else K.default)
      else K.default

/-- The finite `Σ`-algebra used by `PRecOp`. -/
@[reducible] noncomputable def twoAlgOp (Sig : Signature S) {w : List S} {X : SSet S}
    (s : S) (σ : Sig (w, s)) (x : (i : Fin w.length) → X (w.get i)) : Alg Sig :=
  ⟨kCarrier w, twoOpSig Sig s σ (fun i => gOp x (w.get i) (x i))⟩

theorem finiteAlg_twoAlgOp (Sig : Signature S) [Finite S] {w : List S} {X : SSet S}
    (s : S) (σ : Sig (w, s)) (x : (i : Fin w.length) → X (w.get i)) :
    FiniteAlg (twoAlgOp Sig s σ x) := by
  rw [FiniteAlg, finiteSSet_iff]
  refine ⟨?_, fun _s _ => inferInstanceAs (Finite (K w.length))⟩
  have hsupp : supp (twoAlgOp Sig s σ x).1 = Set.univ := by
    ext t
    constructor
    · intro _; trivial
    · intro _; exact ⟨K.default⟩
  rw [hsupp]
  exact Set.finite_univ

theorem twoAlgOp_ne_var (Sig : Signature S) {w : List S} {X : SSet S} (s : S)
    (σ : Sig (w, s)) (x : (i : Fin w.length) → X (w.get i))
    (p : List S × S) (τ : Sig p) (a : wordProd (kCarrier w) p.1)
    (j : Fin w.length) : (twoAlgOp Sig s σ x).2 p τ a ≠ K.var j := by
  change twoOpSig Sig s σ (fun i => gOp x (w.get i) (x i)) p τ a ≠ K.var j
  unfold twoOpSig
  split <;> rename_i hp
  · split <;> rename_i hσ
    · split <;> rename_i hm
      · intro h; cases h
      · intro h; cases h
    · intro h; cases h
  · intro h; cases h

theorem termLift_eq_var (Sig : Signature S) {w : List S} {X : SSet S} (s : S)
    (σ : Sig (w, s)) (x : (i : Fin w.length) → X (w.get i)) :
    ∀ (t : S) (P : Term Sig X t) (j : Fin w.length),
      termLift Sig X (twoAlgOp Sig s σ x).2 (gOp x) t P = K.var j →
        ∃ y : X t, P = Term.var y ∧ gOp x t y = K.var j := by
  intro t P
  exact Term.rec (motive := fun t P => ∀ j : Fin w.length,
      termLift Sig X (twoAlgOp Sig s σ x).2 (gOp x) t P = K.var j →
        ∃ y : X t, P = Term.var y ∧ gOp x t y = K.var j)
    (fun {u : S} (y : X u) j h => ⟨y, rfl, h⟩)
    (fun p τ a ih j h => absurd h
      (twoAlgOp_ne_var Sig s σ x p τ
        (fun i => termLift Sig X (twoAlgOp Sig s σ x).2 (gOp x) (p.1.get i) (a i)) j))
    P

/-- `PRecOp` (`MSCong` §3.1). -/
theorem PRecOp (Sig : Signature S) (X : SSet S) [Finite S]
    {w : List S} (s : S) (σ : Sig (w, s)) (x : (i : Fin w.length) → X (w.get i)) :
    RecognizableAt Sig (termAlg Sig X) s
      ({Term.op (w, s) σ (fun i => Term.var (x i))} : Set (Term Sig X s)) := by
  classical
  let g : SortedMap X (kCarrier w) := gOp x
  have hσ0 : (Eq.mp (congrArg Sig rfl) σ : Sig (w, s)) = σ := rfl
  have hT0 : termLift Sig X (twoAlgOp Sig s σ x).2 g s
      (Term.op (w, s) σ (fun i => Term.var (x i))) = K.mark := by
    have hval := show termLift Sig X (twoAlgOp Sig s σ x).2 g s
        (Term.op (w, s) σ (fun i => Term.var (x i)))
        = twoOpSig Sig s σ (fun i => gOp x (w.get i) (x i)) (w, s) σ
            (fun i => termLift Sig X (twoAlgOp Sig s σ x).2 g (w.get i) (Term.var (x i)))
        from rfl
    rw [hval]
    unfold twoOpSig
    rw [dif_pos rfl, dif_pos hσ0]
    rw [if_pos (by intro i; rw [finOfEq_self_eq]; rfl)]
  refine ⟨twoAlgOp Sig s σ x, finiteAlg_twoAlgOp Sig s σ x,
    termLift Sig X (twoAlgOp Sig s σ x).2 g,
    termLift_isAlgHom Sig X (twoAlgOp Sig s σ x).2 g, {K.mark}, ?_⟩
  ext P
  simp only [Set.mem_singleton_iff, Set.mem_preimage]
  constructor
  · rintro rfl
    exact hT0
  · intro h
    suffices ∀ (t : S) (P : Term Sig X t),
        termLift Sig X (twoAlgOp Sig s σ x).2 g t P = K.mark →
          HEq P (Term.op (w, s) σ (fun i => Term.var (x i))) by
      exact eq_of_heq (this s P h)
    exact fun t P =>
      Term.rec (motive := fun t P =>
          termLift Sig X (twoAlgOp Sig s σ x).2 g t P = K.mark →
            HEq P (Term.op (w, s) σ (fun i => Term.var (x i))))
        (fun {u : S} (y : X u) => fun hy => by
          change g u y = K.mark at hy
          exact absurd hy (gOp_ne_mark x u y))
        (fun p τ a ih => fun hy => by
          have hval := show termLift Sig X (twoAlgOp Sig s σ x).2 g p.2 (Term.op p τ a)
              = twoOpSig Sig s σ (fun i => gOp x (w.get i) (x i)) p τ
                  (fun i => termLift Sig X (twoAlgOp Sig s σ x).2 g (p.1.get i) (a i))
              from rfl
          rw [hval] at hy
          unfold twoOpSig at hy
          by_cases hp : p = (w, s)
          · rw [dif_pos hp] at hy
            by_cases hσ : Eq.mp (congrArg Sig hp) τ = σ
            · rw [dif_pos hσ] at hy
              by_cases hm : (∀ i : Fin w.length,
                    termLift Sig X (twoAlgOp Sig s σ x).2 g
                        (p.1.get (finOfEq (congrArg List.length (congrArg Prod.fst hp).symm) i))
                        (a (finOfEq (congrArg List.length (congrArg Prod.fst hp).symm) i))
                      = gOp x (w.get i) (x i))
              · rw [if_pos hm] at hy
                subst hp
                change τ = σ at hσ
                subst τ
                apply heq_of_eq
                have ha : a = (fun i => Term.var (x i)) := by
                  funext i
                  have hm' : termLift Sig X (twoAlgOp Sig s σ x).2 g (w.get i) (a i)
                      = gOp x (w.get i) (x i) := by
                    have h2 := hm i
                    rw [finOfEq_self_eq] at h2
                    exact h2
                  obtain ⟨y, hy', hgy⟩ := termLift_eq_var Sig s σ x (w.get i) (a i)
                    (pickVar x i) (hm'.trans (gOp_self x i))
                  have hyx : y = x i :=
                    eq_of_heq ((gOp_eq_var x hgy).symm.trans (gOp_eq_var x (gOp_self x i)))
                  subst hyx
                  exact hy'
                rw [ha]
              · rw [if_neg hm] at hy
                exact absurd hy K.default_ne_mark
            · rw [dif_neg hσ] at hy
              exact absurd hy K.default_ne_mark
          · rw [dif_neg hp] at hy
            exact absurd hy K.default_ne_mark)
        P

end Mscong
