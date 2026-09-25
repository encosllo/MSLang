import Mscong.BasicTerms

/-!
# `Mscong.Substitution` -- substitution operators and `PRecSubs` (`MSCong` §3.2)

Milestone **M3** of the MSCong project (OpenSpec change
`add-substitution-recognizability`): the substitution operators on the free
`Σ`-algebra `T_Σ(X)` and the recognizability result `PRecSubs`.

Following the paper, the codomain of the substitution operators is the **subset
algebra** `A^℘` (`MSCong` Prop. `subsetalg`): carrier `fun s => Set (A s)`, with
the operation for `σ : Σ_{w,s}` sending `(L_i)` to the direct image
`{F_σ(a_i) | a_i ∈ L_i}`. The induced substitution homomorphism is the free
extension `termLift` of an assignment `X → A^℘`.

This is **unmapped infrastructure**: no block IDs, no evidence; `mscong` stays
`ingested: false` (see `design.md`, D5).
-/

namespace Mscong

open Mslang

attribute [local instance] Classical.propDecidable

universe u

variable {S : Type u}

/-! ### The subset algebra `A^℘` -/

/-- The carrier of the subset algebra `A^℘`: the `S`-sorted set of subsets. -/
abbrev pCarrier (A : SSet S) : SSet S := fun s => Set (A s)

/-- `MSCong` Prop. `subsetalg`: the subset `Σ`-algebra `A^℘` associated to `A`.
The operation for `σ : Σ_{w,s}` maps `(L_i)` to the direct image
`{F_σ(a_i) | a_i ∈ L_i}`. -/
noncomputable def pAlg (Sig : Signature S) (A : SSet S) (F : AlgStruct Sig A) : Alg Sig :=
  ⟨pCarrier A, fun p σ L => fun y =>
    ∃ (a : wordProd A p.1), (∀ i, a i ∈ L i) ∧ F p σ a = y⟩

/-- The insertion `{·}^Σ : A → A^℘`, `a ↦ {a}`. -/
def pEta {S : Type u} (A : SSet S) : SortedMap A (pCarrier A) :=
  fun _ a => {a}

/-- `MSCong` §3.2: the substitution homomorphism induced by an `S`-sorted
assignment `L : X → T_Σ(X)^℘`; the free extension of `L` from `T_Σ(X)` to the
subset algebra of `T_Σ(X)`. -/
noncomputable def substHom (Sig : Signature S) (X : SSet S)
    (L : SortedMap X (pCarrier (Term Sig X))) :
    SortedMap (Term Sig X) (pCarrier (Term Sig X)) :=
  termLift Sig X (pAlg Sig (Term Sig X) (termAlg Sig X).2).2 L

/-- The substitution homomorphism is a `Σ`-homomorphism (task 1.4). -/
theorem substHom_isAlgHom (Sig : Signature S) (X : SSet S)
    (L : SortedMap X (pCarrier (Term Sig X))) :
    IsAlgHom Sig (termAlg Sig X).2 (pAlg Sig (Term Sig X) (termAlg Sig X).2).2
      (substHom Sig X L) :=
  termLift_isAlgHom Sig X _ L

/-- The substitution homomorphism agrees with `L` on the generators `η^X`. -/
theorem substHom_eta (Sig : Signature S) (X : SSet S)
    (L : SortedMap X (pCarrier (Term Sig X))) :
    (fun s => substHom Sig X L s ∘ termEta Sig X s) = L :=
  termLift_eta Sig X _ L

/-- The substituted language of a language `K`: the union of the substitution
images `substHom L P` over `P ∈ K`. -/
noncomputable def substLang (Sig : Signature S) (X : SSet S)
    (L : SortedMap X (pCarrier (Term Sig X))) (s : S) (K : Set (Term Sig X s)) :
    Set (Term Sig X s) :=
  ⋃ P ∈ K, substHom Sig X L s P

/-! ### Single-variable substitution -/

/-- The single-variable substitution `(z\Q)(P)`: replace every occurrence of `z`
in `P` by `Q`. -/
noncomputable def subst1 (Sig : Signature S) (X : SSet S) {t : S} (z : X t)
    (Q : Term Sig X t) : (s : S) → Term Sig X s → Term Sig X s
  | s, Term.var y =>
      if h : s = t then
        (if (h ▸ y) = z then h.symm ▸ Q else Term.var y) else Term.var y
  | _, Term.op p σ a => Term.op p σ (fun i => subst1 Sig X z Q (p.1.get i) (a i))

theorem subst1_var_self (Sig : Signature S) (X : SSet S) {t : S} (z : X t)
    (Q : Term Sig X t) : subst1 Sig X z Q t (Term.var z) = Q := by
  simp only [subst1, dif_pos trivial, if_pos trivial]

theorem subst1_var_of_ne_sort (Sig : Signature S) (X : SSet S) {t s : S} {z : X t}
    (Q : Term Sig X t) (y : X s) (h : s ≠ t) :
    subst1 Sig X z Q s (Term.var y) = Term.var y := by
  simp only [subst1, dif_neg h]

theorem subst1_var_of_ne (Sig : Signature S) (X : SSet S) {t : S} {z : X t}
    (Q : Term Sig X t) (y : X t) (hy : y ≠ z) :
    subst1 Sig X z Q t (Term.var y) = Term.var y := by
  simp only [subst1, dif_pos trivial, if_neg hy]

theorem subst1_op (Sig : Signature S) (X : SSet S) {t : S} (z : X t)
    (Q : Term Sig X t) (p : List S × S) (σ : Sig p)
    (a : (i : Fin p.1.length) → Term Sig X (p.1.get i)) :
    subst1 Sig X z Q p.2 (Term.op p σ a)
      = Term.op p σ (fun i => subst1 Sig X z Q (p.1.get i) (a i)) := rfl

/-! ### Reusable finite-index tooling -/

set_option warn.classDefReducibility false
set_option linter.style.haveILetI false

/-- The pointwise intersection of a family of sorted equivalences. -/
noncomputable def sortedEqvInter {ι : Type u} {A : SSet S} (Φ : ι → SortedEqv A) : SortedEqv A :=
  fun s => { r := fun x y => ∀ i, (Φ i s).r x y,
             iseqv := ⟨fun x => fun _ => (Φ _ s).refl x,
                       fun h => fun i => (Φ i s).symm (h i),
                       fun h1 h2 => fun i => (Φ i s).trans (h1 i) (h2 i)⟩ }

theorem sortedEqvInter_le {ι : Type u} {A : SSet S} (Φ : ι → SortedEqv A) (i : ι) :
    sortedEqvLe (sortedEqvInter Φ) (Φ i) := fun _ _ _ h => h i

/-- The pointwise intersection of finitely many finite-index equivalences has
finite index (the quotient injects into the product of the quotients). -/
theorem IsFiniteIndex_inter {ι : Type u} [Fintype ι] [Nonempty ι]
    {A : SSet S} {Φ : ι → SortedEqv A}
    (h : ∀ i, IsFiniteIndex (Φ i)) : IsFiniteIndex (sortedEqvInter Φ) := by
  haveI : ∀ i, Finite (Sigma (fun s => Quotient (Φ i s))) := fun i => h i
  unfold IsFiniteIndex FiniteSSet at h ⊢
  apply Finite.of_injective
    (f := fun p : Sigma (fun s => Quotient ((sortedEqvInter Φ) s)) =>
      fun i => (⟨p.1, quotLe (sortedEqvInter Φ) (Φ i) (sortedEqvInter_le Φ i) p.1 p.2⟩ :
        Sigma (fun s => Quotient (Φ i s))))
  rintro ⟨s, q1⟩ ⟨t, q2⟩ hp
  obtain ⟨i0⟩ := (inferInstance : Nonempty ι)
  have hst : s = t := (Sigma.mk.inj_iff.mp (congrFun hp i0)).1
  subst hst
  refine Sigma.mk.inj_iff.mpr ⟨rfl, heq_of_eq ?_⟩
  induction q1 using Quotient.inductionOn with
  | _ a =>
    induction q2 using Quotient.inductionOn with
    | _ b =>
      apply Quotient.sound
      intro i
      have he : quotLe (sortedEqvInter Φ) (Φ i) (sortedEqvInter_le Φ i) s
            (Quotient.mk _ a)
          = quotLe (sortedEqvInter Φ) (Φ i) (sortedEqvInter_le Φ i) s
            (Quotient.mk _ b) :=
        eq_of_heq (Sigma.mk.inj_iff.mp (congrFun hp i)).2
      rw [quotLe_mk, quotLe_mk] at he
      exact Quotient.exact he

/-! ### The substitution image of a `Φ`-class and the refinement `Ψ` -/

/-- `substClass L Φ r q`, the substitution image of the `Φ`-class `q`: the union
of the substitution images `substHom L P` over the terms `P` of class `q`. -/
noncomputable def substClass {S : Type u} (Sig : Signature S) (X : SSet S)
    (L : SortedMap X (pCarrier (Term Sig X))) (Φ : SortedEqv (Term Sig X))
    (r : S) (q : Quotient (Φ r)) : Set (Term Sig X r) :=
  {W | ∃ P : Term Sig X r, Quotient.mk (Φ r) P = q ∧ W ∈ substHom Sig X L r P}

theorem mem_substClass {S : Type u} {Sig : Signature S} {X : SSet S} {L}
    {Φ : SortedEqv (Term Sig X)} {r : S} {W P : Term Sig X r} {q : Quotient (Φ r)}
    (hq : Quotient.mk (Φ r) P = q) (hW : W ∈ substHom Sig X L r P) :
    W ∈ substClass Sig X L Φ r q :=
  ⟨P, hq, hW⟩

/-- `Ψ`, the refinement of `Φ` by agreement on membership in every
`substClass`: the reusable core of `PRecSubs` (`design.md`, D3). -/
noncomputable def substRefine {S : Type u} (Sig : Signature S) (X : SSet S)
    (L : SortedMap X (pCarrier (Term Sig X))) (Φ : SortedEqv (Term Sig X)) :
    SortedEqv (Term Sig X) :=
  fun r =>
    { r := fun x y => (Φ r).r x y ∧
        ∀ q : Quotient (Φ r),
          (x ∈ substClass Sig X L Φ r q ↔ y ∈ substClass Sig X L Φ r q)
      iseqv :=
        ⟨fun x => ⟨(Φ r).refl x, fun _ => Iff.rfl⟩,
         fun h => ⟨(Φ r).symm h.1, fun q => (h.2 q).symm⟩,
         fun h1 h2 => ⟨(Φ r).trans h1.1 h2.1, fun q => (h1.2 q).trans (h2.2 q)⟩⟩ }

theorem substRefine_le {S : Type u} (Sig : Signature S) (X : SSet S) (L)
    (Φ : SortedEqv (Term Sig X)) :
    sortedEqvLe (substRefine Sig X L Φ) Φ :=
  fun _ _ _ h => h.1

theorem substRefine_agree {S : Type u} (Sig : Signature S) (X : SSet S) (L)
    {Φ : SortedEqv (Term Sig X)} {r : S} {x y : Term Sig X r}
    (h : ((substRefine Sig X L Φ) r).r x y) (q : Quotient (Φ r)) :
    (x ∈ substClass Sig X L Φ r q ↔ y ∈ substClass Sig X L Φ r q) :=
  h.2 q

/-- `IsSat` from pointwise membership. -/
theorem isSat_of_forall_mem {S : Type u} {A : SSet S} {Φ : SortedEqv A} {X : Sub A}
    (h : ∀ (s : S) (x y : A s), x ∈ X s → (Φ s).r x y → y ∈ X s) : IsSat Φ X := by
  unfold IsSat
  funext s
  ext y
  exact ⟨fun hy => by rcases hy with ⟨x, hx, hxy⟩; exact h s x y hx hxy,
    fun hy => ⟨y, hy, (Φ s).refl y⟩⟩

/-- Membership of a `Φ`-related element in a `Φ`-saturated subset. -/
theorem isSat_mem {S : Type u} {A : SSet S} {Φ : SortedEqv A} {X : Sub A}
    (h : IsSat Φ X) {s : S} {x y : A s} (hx : x ∈ X s) (hxy : (Φ s).r x y) :
    y ∈ X s := by
  have h' := congrFun h s
  rw [← h']
  exact ⟨x, hx, hxy⟩

/-- The pointwise intersection of congruences is a congruence. -/
theorem IsCongruence_inter {S : Type u} (Sig : Signature S) {A : SSet S}
    (F : AlgStruct Sig A) {ι : Type u} (Φ : ι → SortedEqv A)
    (h : ∀ i, IsCongruence Sig F (Φ i)) :
    IsCongruence Sig F (sortedEqvInter Φ) := by
  intro p σ a b hab i
  exact h i p σ a b (fun j => hab j i)

/-! ### `substHom` at a variable and at an operation -/

theorem substHom_var {S : Type u} (Sig : Signature S) (X : SSet S) (L)
    (t : S) (x : X t) : substHom Sig X L t (Term.var x) = L t x := rfl

theorem mem_substHom_op {S : Type u} (Sig : Signature S) (X : SSet S) (L)
    {p' : List S × S} (σ' : Sig p')
    (T : (i : Fin p'.1.length) → Term Sig X (p'.1.get i)) (W : Term Sig X p'.2) :
    W ∈ substHom Sig X L p'.2 (Term.op p' σ' T) ↔
      ∃ a : wordProd (Term Sig X) p'.1,
        (∀ i, a i ∈ substHom Sig X L (p'.1.get i) (T i)) ∧
          Term.op p' σ' a = W :=
  Iff.rfl

theorem mem_substLang {S : Type u} (Sig : Signature S) (X : SSet S) (L)
    {r : S} {K : Set (Term Sig X r)} {W : Term Sig X r} :
    W ∈ substLang Sig X L r K ↔ ∃ P ∈ K, W ∈ substHom Sig X L r P := by
  unfold substLang
  constructor
  · intro hW
    rw [Set.mem_iUnion] at hW
    obtain ⟨P, hP⟩ := hW
    rw [Set.mem_iUnion] at hP
    obtain ⟨hPK, hP⟩ := hP
    exact ⟨P, hPK, hP⟩
  · rintro ⟨P, hPK, hW⟩
    rw [Set.mem_iUnion]
    exact ⟨P, Set.mem_iUnion.mpr ⟨hPK, hW⟩⟩

/-! ### The refinement `Ψ` is a congruence of finite index (the core of `PRecSubs`) -/

/-- The forward step of the congruence proof: if `(P_i, Q_i)` agree under `Ψ`,
then membership of `σ((P_i))` in a `substClass` transfers to `σ((Q_i))`. -/
theorem substClass_op_imp {S : Type u} (Sig : Signature S) (X : SSet S) (L)
    {Φ : SortedEqv (Term Sig X)}
    (hΦc : IsCongruence Sig (termAlg Sig X).2 Φ)
    (hΦsat : ∀ (t : S) (x : X t), IsSat Φ (deltaSub t (L t x)))
    {p : List S × S} (σ : Sig p) (P Q : wordProd (Term Sig X) p.1)
    (hPQ : ∀ i, ((substRefine Sig X L Φ) (p.1.get i)).r (P i) (Q i)) :
    ∀ q : Quotient (Φ p.2),
      Term.op p σ P ∈ substClass Sig X L Φ p.2 q →
      Term.op p σ Q ∈ substClass Sig X L Φ p.2 q := by
  intro q hP
  rw [substClass] at hP ⊢
  obtain ⟨T, hTq, hPT⟩ := hP
  have opcase : ∀ (w : List S) (σ' : Sig (w, p.2))
      (a : (i : Fin w.length) → Term Sig X (w.get i)),
      T = Term.op (w, p.2) σ' a →
      Term.op p σ P ∈ substHom Sig X L p.2 T →
      ∃ T' : Term Sig X p.2, Quotient.mk (Φ p.2) T' = q ∧
        Term.op p σ Q ∈ substHom Sig X L p.2 T' := by
    intro w σ' a hT hPT
    have hstep := (mem_substHom_op Sig X L σ' a (Term.op p σ P)).mp (hT ▸ hPT)
    obtain ⟨b, hb, hbeq⟩ := hstep
    injection hbeq with h1 h2 h3
    have hweq : w = p.1 := congrArg Prod.fst h1
    subst hweq
    have hσe : σ' = σ := eq_of_heq h2
    cases hσe
    have hbPe : b = P := eq_of_heq h3
    cases hbPe
    have hQmem : ∀ i, Q i ∈ substClass Sig X L Φ (p.1.get i)
        (Quotient.mk (Φ (p.1.get i)) (a i)) := by
      intro i
      exact ((hPQ i).2 _).mp (mem_substClass rfl (hb i))
    choose a' ha'mk ha'mem using hQmem
    refine ⟨Term.op p σ a', ?_, ?_⟩
    · rw [← hTq, hT]
      exact Quotient.sound (hΦc p σ a' a (fun i => Quotient.exact (ha'mk i)))
    · rw [mem_substHom_op]
      exact ⟨Q, ha'mem, rfl⟩
  rcases term_shape Sig X p.2 T with ⟨x, hx⟩ | ⟨σ₀, hσ₀⟩ | ⟨w, _hw, σ', a, hTa⟩
  · subst hx
    refine mem_substClass hTq ?_
    have hrel : (Φ p.2).r (Term.op p σ P) (Term.op p σ Q) :=
      hΦc p σ P Q (fun i => (hPQ i).1)
    have hx' : Term.op p σ P ∈ (deltaSub p.2 (L p.2 x)) p.2 := by
      rw [deltaSub_self, ← substHom_var Sig X L p.2 x]
      exact hPT
    have hQ' : Term.op p σ Q ∈ (deltaSub p.2 (L p.2 x)) p.2 :=
      isSat_mem (hΦsat p.2 x) hx' hrel
    rw [deltaSub_self] at hQ'
    rw [substHom_var Sig X L p.2 x]
    exact hQ'
  · exact opcase [] σ₀ (fun i => i.elim0) hσ₀ hPT
  · exact opcase w σ' a hTa hPT

/-- `deltaSub s (substLang L s K)` is `Ψ`-saturated: every `W` in the substitution
image of `K` has the same `Ψ`-class as the members of every input class it
touches, so `Ψ`-related `W` stay in the image. -/
theorem isSat_deltaSub_of_sat_hom {S : Type u} (Sig : Signature S) (X : SSet S) (L)
    {Φ : SortedEqv (Term Sig X)} {s : S} {K : Set (Term Sig X s)}
    (hΦsatK : IsSat Φ (deltaSub s K)) :
    IsSat (substRefine Sig X L Φ) (deltaSub s (substLang Sig X L s K)) := by
  classical
  refine isSat_of_forall_mem ?_
  intro u x y hx hxy
  by_cases hu : u = s
  · subst hu
    rw [deltaSub_self] at hx ⊢
    rw [mem_substLang] at hx ⊢
    obtain ⟨P, hPK, hP⟩ := hx
    have hxclass : x ∈ substClass Sig X L Φ u (Quotient.mk (Φ u) P) :=
      mem_substClass rfl hP
    have hyclass : y ∈ substClass Sig X L Φ u (Quotient.mk (Φ u) P) :=
      (substRefine_agree (Sig := Sig) (X := X) (L := L) (Φ := Φ) hxy _).mp hxclass
    rw [substClass] at hyclass
    obtain ⟨P', hP'mk, hP'⟩ := hyclass
    have hPK' : P ∈ (deltaSub u K) u := by simpa [deltaSub_self] using hPK
    have hP'K' : P' ∈ (deltaSub u K) u :=
      isSat_mem hΦsatK hPK' ((Φ u).symm (Quotient.exact hP'mk))
    exact ⟨P', by simpa [deltaSub_self] using hP'K', hP'⟩
  · rw [deltaSub_of_ne hu] at hx
    exact absurd hx (Set.notMem_empty x)

/-- The refinement `Ψ` of a congruence `Φ` that saturates the assigned languages
is itself a congruence (`PRecSubs`, `design.md` D3). -/
theorem substRefine_isCongruence {S : Type u} (Sig : Signature S) (X : SSet S) (L)
    {Φ : SortedEqv (Term Sig X)}
    (hΦc : IsCongruence Sig (termAlg Sig X).2 Φ)
    (hΦsat : ∀ (t : S) (x : X t), IsSat Φ (deltaSub t (L t x))) :
    IsCongruence Sig (termAlg Sig X).2 (substRefine Sig X L Φ) := by
  intro p σ P Q hPQ
  refine ⟨hΦc p σ P Q (fun i => (hPQ i).1), fun q => ?_⟩
  exact ⟨substClass_op_imp Sig X L hΦc hΦsat σ P Q hPQ q,
    substClass_op_imp Sig X L hΦc hΦsat σ Q P
      (fun i => ((substRefine Sig X L Φ) (p.1.get i)).symm (hPQ i)) q⟩

/-- `Ψ` has finite index whenever `Φ` does: its quotient injects into the
product of `T_Σ(X)/Φ` with the (finite) set of membership sign vectors over the
finitely many `Φ`-classes, giving the paper's bound `k_r · 2^{k_r}`. -/
theorem isFiniteIndex_substRefine {S : Type u} (Sig : Signature S) (X : SSet S) (L)
    {Φ : SortedEqv (Term Sig X)} (hΦ : IsFiniteIndex Φ) :
    IsFiniteIndex (substRefine Sig X L Φ) := by
  classical
  set Ψ := substRefine Sig X L Φ with hΨdef
  have hle : sortedEqvLe Ψ Φ := by
    rw [hΨdef]
    exact substRefine_le Sig X L Φ
  obtain ⟨hsuppΦ, hfibΦ⟩ := (finiteSSet_iff (quot Φ)).mp hΦ
  rw [IsFiniteIndex, finiteSSet_iff]
  have hsub : supp (quot Ψ) ⊆ supp (quot Φ) := by
    rintro r ⟨q⟩
    exact ⟨quotLe Ψ Φ hle r q⟩
  refine ⟨hsuppΦ.subset hsub, ?_⟩
  intro r _hr
  haveI : Finite (quot Φ r) := hfibΦ r (hsub _hr)
  haveI : Finite (Quotient (Φ r)) := hfibΦ r (hsub _hr)
  haveI : Fintype (quot Φ r) := Fintype.ofFinite _
  haveI : Fintype (Quotient (Φ r)) := Fintype.ofFinite _
  haveI : Fintype (Quotient (Φ r) → Bool) := inferInstance
  haveI : Fintype (quot Φ r × (Quotient (Φ r) → Bool)) := inferInstance
  refine Finite.of_injective
    (f := fun q : Quotient (Ψ r) =>
      (quotLe Ψ Φ hle r q,
       Quotient.lift
         (fun P : Term Sig X r => fun (c : Quotient (Φ r)) =>
           if P ∈ substClass Sig X L Φ r c then true else false)
         (fun P Q hPQ => funext fun c => by
           have hiff := hPQ.2 c
           by_cases hPc : P ∈ substClass Sig X L Φ r c
           · have hQc : Q ∈ substClass Sig X L Φ r c := hiff.mp hPc
             simp [hPc, hQc]
           · have hQc : ¬ Q ∈ substClass Sig X L Φ r c := fun hq => hPc (hiff.mpr hq)
             simp [hPc, hQc]) q)) ?_
  rintro q1 q2 h
  induction q1 using Quotient.inductionOn with
  | h P =>
    induction q2 using Quotient.inductionOn with
    | h Q =>
      simp only [Prod.mk.injEq] at h
      obtain ⟨h1, h2⟩ := h
      have hΦrel : (Φ r).r P Q := by
        have h1' := h1
        simp only [quotLe_mk] at h1'
        exact Quotient.exact h1'
      refine Quotient.sound ⟨hΦrel, fun c => ?_⟩
      have hc := congrFun h2 c
      simp only [Quotient.lift_mk] at hc
      by_cases hPc : P ∈ substClass Sig X L Φ r c <;>
        by_cases hQc : Q ∈ substClass Sig X L Φ r c <;>
        simp_all

/-! ### `PRecSubs` (`MSCong` §3.2) -/

/-- `PRecSubs` (`MSCong` Prop. `PRecSubs`): for a sort `s`, a recognizable
language `K ⊆ T_Σ(X)_s`, and an `S`-sorted assignment `L` of recognizable
languages, the substituted language is recognizable. The proof fixes the
synactic congruence `Φ` of the inputs (finite index by `congFi_filter`) and
saturates by the finite-index refinement `Ψ` (`substRefine`). -/
theorem PRecSubs {S : Type u} (Sig : Signature S) (X : SSet S) [Finite S]
    (hX : FiniteSSet X) (s : S) (K : Set (Term Sig X s))
    (L : SortedMap X (pCarrier (Term Sig X)))
    (hK : RecognizableAt Sig (termAlg Sig X) s K)
    (hL : ∀ (t : S) (x : X t), RecognizableAt Sig (termAlg Sig X) t (L t x)) :
    RecognizableAt Sig (termAlg Sig X) s (substLang Sig X L s K) := by
  classical
  have hSX : Finite (Sigma X) := hX
  haveI : Fintype (Sigma X) := Fintype.ofFinite (Sigma X)
  haveI : Nonempty ((Σ t : S, X t) ⊕ Unit) := ⟨Sum.inr ()⟩
  let Ω : (t : S) → X t → SortedEqv (Term Sig X) :=
    fun t x => congCogenerated Sig (termAlg Sig X) (deltaSub t (L t x))
  let ΩK : SortedEqv (Term Sig X) :=
    congCogenerated Sig (termAlg Sig X) (deltaSub s K)
  let fam : ((Σ t : S, X t) ⊕ Unit) → SortedEqv (Term Sig X) := fun i =>
    match i with
    | Sum.inl tx => Ω tx.1 tx.2
    | Sum.inr _ => ΩK
  let Φ : SortedEqv (Term Sig X) := sortedEqvInter fam
  have hΦc : IsCongruence Sig (termAlg Sig X).2 Φ := by
    refine IsCongruence_inter Sig (termAlg Sig X).2 fam ?_
    intro i
    cases i with
    | inl tx =>
        exact congCogenerated_isCongruence Sig (termAlg Sig X) (deltaSub tx.1 (L tx.1 tx.2))
    | inr _ =>
        exact congCogenerated_isCongruence Sig (termAlg Sig X) (deltaSub s K)
  have hΩfin : ∀ i, IsFiniteIndex (fam i) := by
    intro i
    cases i with
    | inl tx =>
        exact recognizable_isRegularLanguage Sig (termAlg Sig X) (deltaSub tx.1 (L tx.1 tx.2))
          ((recognizableAt_iff Sig (termAlg Sig X) tx.1 (L tx.1 tx.2)).mp (hL tx.1 tx.2))
    | inr _ =>
        exact recognizable_isRegularLanguage Sig (termAlg Sig X) (deltaSub s K)
          ((recognizableAt_iff Sig (termAlg Sig X) s K).mp hK)
  have hΦf : IsFiniteIndex Φ :=
    IsFiniteIndex_inter (ι := (Σ t : S, X t) ⊕ Unit) hΩfin
  have hΦsat : ∀ (t : S) (x : X t), IsSat Φ (deltaSub t (L t x)) := by
    intro t x
    exact sat_antitone (sortedEqvInter_le fam (Sum.inl ⟨t, x⟩))
      (isSat_congCogenerated Sig (termAlg Sig X) (deltaSub t (L t x)))
  have hΦsatK : IsSat Φ (deltaSub s K) :=
    sat_antitone (sortedEqvInter_le fam (Sum.inr ()))
      (isSat_congCogenerated Sig (termAlg Sig X) (deltaSub s K))
  let Ψ : SortedEqv (Term Sig X) := substRefine Sig X L Φ
  have hΨc : IsCongruence Sig (termAlg Sig X).2 Ψ :=
    substRefine_isCongruence Sig X L hΦc hΦsat
  have hΨf : IsFiniteIndex Ψ := isFiniteIndex_substRefine Sig X L hΦf
  have hΨsat : IsSat Ψ (deltaSub s (substLang Sig X L s K)) :=
    isSat_deltaSub_of_sat_hom Sig X L (K := K) hΦsatK
  exact (recognizableAt_iff Sig (termAlg Sig X) s (substLang Sig X L s K)).mpr
    ((recognizable_iff_exists_finiteIndex_sat Sig (termAlg Sig X)
      (deltaSub s (substLang Sig X L s K))).mpr ⟨Ψ, hΨc, hΨf, hΨsat⟩)

end Mscong

