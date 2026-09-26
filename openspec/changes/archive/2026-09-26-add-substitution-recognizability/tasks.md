# Tasks

## 1. Substitution operators

- [x] 1.1 In `lean/Mscong/Substitution.lean`, define the subset algebra on
  `Sub (Term Sig X)` (the operation for `σ` maps `(A_i)` to the direct image
  `{σ(a_i) | a_i ∈ A_i}`; constants to singletons); verify it compiles.
- [x] 1.2 Defined the single-variable substitution `(z\Q)(P)` by recursion on
  `P` (or as the subset-hom value with all other variables fixed to
  singletons); verify `(z\Q)(z) = Q` and `(z\Q)(σ(P_i)) = σ((z\Q)(P_i))`.
- [x] 1.3 Defined the simultaneous substitution and the induced homomorphism
  `substHom L := termLift Sig X (subsetAlg).2 L`; verify its value at `P` is the
  set of simultaneously substituted terms (the paper's
  `Im((x,t)\·)(P)↾∏ L_x^{P_x})`, and that single-variable substitution is the
  specialization with the other variables fixed to `{z}`.
- [x] 1.4 Verified the substitution is compatible with the free-algebra structure
  (a `Mslang` homomorphism), reusing `termLift_isAlgHom`.

## 2. Reusable finite-index / transversal API

- [x] 2.1 **Resolved by 2.2 (scope decision, not built).** The explicit finite
  transversal of `T_Σ(X)/Φ` and the `k_r · 2^{k_r}` index bound were found
  unnecessary: `isFiniteIndex_substRefine` proves finiteness of the refinement
  directly by an injection into `T_Σ(X)/Φ × (T_Σ(X)/Φ → Bool)`, the same
  counting argument. The explicit `Finset` transversal/`k_r` are not built.
- [x] 2.2 Provided the `Ψ`-refinement lemma (`substRefine` +
  `isFiniteIndex_substRefine`): a sorted equivalence refining a congruence `Φ`
  by agreement on `substClass` membership is a congruence of finite index. It is
  the shared core of the `PRecSubs` proof.

## 3. `PRecSubs`

- [x] 3.1 Formed `Φ = ⋂ (⋃_{t,x} {Ω(δ^{t,L_x})} ∪ {Ω(δ^{s,K})})` as
  `sortedEqvInter` over the finite index `(Σ t, X t) ⊕ Unit`, proved it is a
  congruence (`IsCongruence_inter`) of finite index (`IsFiniteIndex_inter`) and
  that it saturates every `δ^{t,L_x}` and `δ^{s,K}` (via `sat_antitone` +
  `isSat_congCogenerated`).
- [x] 3.2 Applied the `Ψ`-refinement lemma (`substRefine_isCongruence`,
  `isFiniteIndex_substRefine`, `isSat_deltaSub_of_sat_hom`) to show the
  substituted language is saturated by a finite-index congruence; concluded
  `PRecSubs` via `recognizable_iff_exists_finiteIndex_sat`. Axiom-clean
  (`propext`, `Classical.choice`, `Quot.sound`), no `sorry`.

## 4. `PRecIt`

- [x] 4.1 Defined the `z`-iteration in `lean/Mscong/Iteration.lean`
  (`iterAssign`, `iterImage`, `iterLevel`, `iterLang`); verified
  `L^{1,z} = L ∪ {z}` (`iterLevel_one`) and monotonicity
  (`iterLevel_subset_succ`, `iterLevel_mono`). `iterImage` uses the paper's
  **independent** per-occurrence subset-hom
  (`substLang (iterAssign z Q) L`), not a single substituted term. Supporting
  lemmas: `substLang_singleton`, `substHom_mono`, `iterAssign_mono`.
- [x] 4.2 Proved `PRecIt` (`lean/Mscong/Iteration.lean`). Formed
  `Φ = Ω(δ^{s,L}) ∩ Ω(δ^{s,z})` (finite index via M2's `PRecVar` for `{z}`) and
  the refinement `Ψ = iterStarRefine` by agreement on the substituted images of
  the `Φ`-classes. The refinement is *not* plain `substRefine`: `Φ` does not
  saturate `L^{⋆z}` (e.g. `L = {f(z)}` with a constant `c` gives
  `f(f(z)) Φ f(f(c))` with `f(f(z)) ∈ L^{⋆z}`, `f(f(c)) ∉ L^{⋆z}`). Pieces:
  (a) Lemma A `iterStar_op_mem` (`op P ∈ L^{⋆z}` + `P i Ψ Q i` ⇒ `op Q ∈ L^{⋆z}`,
  by level induction); (b) closure `iterImage_iterLang_subset`
  (`(z\L^{⋆z})^♯(L) ⊆ L^{⋆z}`, via the level-lifting identity
  `substHom_iterAssign_iUnion`, a max over the finitely many arguments);
  (c) `/Psi` is a congruence via `substClass_op_imp_of` with the variable case
  from Lemma A. Axioms `[propext, Classical.choice, Quot.sound]`, no `sorry`.

## 5. `PRecQ`

- [x] 5.1 Defined the `z`-quotient in `lean/Mscong/Quotient.lean`
  (`quotLang`, `mem_quotLang`).
- [x] 5.2 Proved `PRecQ` (`lean/Mscong/Quotient.lean`) and the finiteness clause
  (`quotLang_range_finite`). The proof differs from the paper's `Ψ`-refinement:
  it decomposes `K^{-z}L = ⋃_{V∈K} (subst1 z V)⁻¹[L]`, observes that
  `(subst1 z V)⁻¹[L]` depends only on the `Ω(δ^{s,L})`-class of `V`
  (`subst1_mem_iff_of_rel`), and takes the finite union over the classes met by
  `K`. Each term is recognizable by `recognizable_inverseImage` (the
  substitution is a `Σ`-endomorphism, `subst1_isAlgHom`); finite unions are
  closed (`recognizable_finset_iUnion`).

## 6. Infrastructure discipline and gate

- [x] 6.1 Confirmed `lean/declarations.mscong.json` still maps no declarations
  and no evidence is written under `evidence/mscong/`; `scripts/projects.py
  --check` and `--collisions` pass.
- [x] 6.2 Confirmed the default project is untouched: `scripts/projects.py
  --check-baseline` passes and `scripts/check_all.sh --fast` is green.
- [x] 6.3 Ran `python3 scripts/lean_audit.py --project mscong`: 0 declarations,
  0 warnings, 0 `sorry`, `ok=True`.

## 7. Docs and state

- [x] 7.1 Recorded the M3 session in `STATE.md` (what was formalized, axioms, the
  deferred mapping/evidence decision, next steps); it names `Mscong` and the
  free-algebra scope.
- [x] 7.2 Noted in `STATE.md` that tree homomorphisms (M4) and derivors (M5)
  remain open, and that M3 is split: substitution (`PRecSubs`) and quotient
  (`PRecQ`) are complete, `PRecIt` is deferred to a follow-up change.
