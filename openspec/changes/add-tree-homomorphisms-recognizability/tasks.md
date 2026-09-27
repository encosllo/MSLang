# Tasks

## 1. Base change and hyperderivor

- [x] 1.1 In `lean/Mscong/TreeHom.lean`, define `Delta` (`A ∘ φ`) and the
  per-arity variable set `Yplus` (`Y t ⊕ {i // φ (w.get i) = t}`); verify it
  compiles.
- [x] 1.2 Define `Hyperderivor Sig Xi X Y` (`phi`, `c`, `f`) and the placeholder
  occurrence count; verify linearity is expressible and compiles.

## 2. Induced algebra and tree homomorphism

- [x] 2.1 Define `cSubst`/`cAlg` (the `Σ`-algebra `c(T_Ξ(Y))`) and prove
  `treeHom := termLift ...` is a `Σ`-homomorphism (`treeHom_isAlgHom`).
- [x] 2.2 Prove the tree homomorphism agrees with `f` on generators
  (`treeHom_eta`).

## 3. `PRecH`

- [x] 3.1 Defined `cStruct` (the induced structure `c(A)` on `A_φ`) via the
  range subalgebra of `g` (`isSubalgebra_range`, `rangeHom`), proved
  well-definedness (`cSubst_congr`, `cStruct_eval`) and `g_φ` is a hom
  (`cAlg_to_cStruct`).
- [x] 3.2 Proved `PRecH`: `(f♯_{φ(s)})⁻¹[L] ∈ Rec_s(T_Σ(X))` for
  `L ∈ Rec_{φ(s)}(T_Ξ(Y))`. **Caveat:** carries `[Finite S]`: our `FiniteAlg` is
  *finite total* (`FiniteSSet`), so the induced recognizing algebra
  `s ↦ Br_{φ(s)}` is finite-total only when the sort set is; the paper omits
  this because its finiteness notion is coarser.

## 4. `PRecLH`

- [x] 4.1 Form `Φ = ⋂_{(x,r)} Ω(δ^{φ(r),{f_r(x)}})` (finite index, using
  `IsFiniteIndex_inter` over the finite `X`) and `Θ = Ω(δ^{s,L})` (finite
  index); prove `Φ` saturates each `{f_r(x)}`. Done in `Mscong.TreeHom`:
  every singleton term language is recognizable (`recognizableAt_term`, via the
  **subterm automaton** `SubtermState`/`subtermAlg`), so each factor is of finite
  index; `treePhi` carries a harmless top (`nabla`) `Unit` factor so the index is
  non-empty even when `X` is (as in `PRecSubs`); `isFiniteIndex_treePhi`,
  `isSat_treePhi_singleton`, and `isFiniteIndex_treeTheta` are proved.
- [x] 4.2 Proved `Ψ = treeRefine` is a **finite-index congruence**. The
  **linear extraction** (`Occurs`, `countPlaceholder_pos_of_occurs`,
  `substAssign`, `mem_substInto_substAssign`, `termLift_eq_of_agree`,
  `exists_eq_substAssign_of_mem_substInto`, `mem_cSubstLang_iff`) and the
  **gluing** lemma `exists_glue_substAssign` (with `updateTerm`) feed the
  second-condition proof `treeTestSet_op_imp`; the first component is
  `isCongruence_treePhi`; the case (b.1) heart is `treeClassImage_congr`, a
  **structural induction on the domain term `W`** (variable → `Φ`-saturation of
  the generator singleton; operation → test at the subterms of `c(ν)` when `c(ν)`
  is an operation, or recursion on `Q` when `c(ν)` is a placeholder). Finite
  index is `isFiniteIndex_treeRefine`.
- [x] 4.3 Proved `isSat_treeRefine_image` (`f♯_s[L]` is `Ψ_{φ(s)}`-saturated) and
  concluded **`PRecLH`** via `recognizable_iff_exists_finiteIndex_sat`. Caveat:
  carries the paper's finiteness hypotheses `[Finite S] [Finite T]
  [Finite (Sigma Sig)]` and `FiniteSSet X`.

## 5. Infrastructure discipline and gate

- [x] 5.1 `lean/declarations.mscong.json` still maps no declarations, no evidence
  is written under `evidence/mscong/`; `scripts/projects.py --check` and
  `--collisions` pass.
- [x] 5.2 The default project is untouched: `scripts/projects.py
  --check-baseline` passes and `scripts/check_all.sh --fast` is green.
- [x] 5.3 `python3 scripts/lean_audit.py --project mscong`: **0 declarations, 0
  warnings, 0 `sorry`, ok=True**.

## 6. Docs and state

- [x] 6.1 Recorded the M4 session in `STATE.md` (what was formalized, axioms, the
  unmapped-infrastructure decision, next steps).
- [x] 6.2 Noted in `STATE.md` that derivors / Hall algebras (M5) and the
  correspondence audit (M6) remain open. M4 is **not** split: `PRecH` and
  `PRecLH` are both complete. `PRecILH` remains out of scope (commented out in
  `MSCong.tex`).
