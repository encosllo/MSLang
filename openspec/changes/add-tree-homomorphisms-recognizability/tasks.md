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

## 4. `PRecLH` (in progress; see the plan below)

- [x] 4.1 Form `Φ = ⋂_{(x,r)} Ω(δ^{φ(r),{f_r(x)}})` (finite index, using
  `IsFiniteIndex_inter` over the finite `X`) and `Θ = Ω(δ^{s,L})` (finite
  index); prove `Φ` saturates each `{f_r(x)}`. Done in `Mscong.TreeHom`:
  every singleton term language is recognizable (`recognizableAt_term`, via the
  **subterm automaton** `SubtermState`/`subtermAlg`), so each factor is of finite
  index; `treePhi` carries a harmless top (`nabla`) `Unit` factor so the index is
  non-empty even when `X` is (as in `PRecSubs`); `isFiniteIndex_treePhi`,
  `isSat_treePhi_singleton`, and `isFiniteIndex_treeTheta` are proved.
- [~] 4.2 (Infrastructure done; only the second condition of the congruence
  open.) Defined `Subt` (`Subt_self`/`Subt_op_mem`/`Subt_finite`/`Subt_trans`),
  `substInto`/`cSubstLang`, `treePhi`/`treeTheta`/`treeClassImage`,
  `TreeTest`/`treeTestSet`, `treeRefine` (`Ψ`), `treeRefine_le_phi`,
  `treeTest_fintype`, `isFiniteIndex_treeRefine`. The **first** component of the
  congruence is done (`isCongruence_treePhi`). The **linear extraction** needed
  for the second condition is done: `Occurs`, `countPlaceholder_pos_of_occurs`,
  `substAssign`, `mem_substInto_substAssign`, `termLift_eq_of_agree`,
  `exists_eq_substAssign_of_mem_substInto`, `mem_cSubstLang_iff`. **Still to
  do:** the second-condition case analysis (the paper's (a)/(b.1.i)/(b.1.ii)/(b.2),
  using linearity so that each placeholder occurs once).
- [~] 4.3 Saturation done; conclusion pending 4.2. `isSat_treeRefine_image` is
  proved (the paper's final step: case (a) via `isSat_treePhi_singleton` on the
  singleton generators, case (b) via the second condition of `Ψ` at the test
  `(σ, c(σ), ([P_i]_{Θ}))` and `mem_cSubstLang_iff`). **Still to do:** assemble
  `PRecLH` from `Ψ = treeRefine` once `IsCongruence (treeRefine H s L)` is
  available.

**Remaining.** The single open item is the **second condition of `Ψ`'s
congruence** (`IsCongruence (treeRefine H s L)` under `H.IsLinear`). Its forward
step is: from `ξ(a) ∈ ((v_i ↦ A_i))^♯(R)` (a test set), extract
`ξ(a) = termLift (substAssign w P) R` (`P i = f♯(W_i)`, `W_i ∈ [W_{l_i}]_Θ`), then
case on `R`: (a) no placeholders; (b.1) `R = v_{i₀}` or (b.2) `R = ξ(R_j)`; the
placeholder case (b.1) is further split on whether `W_{i₀}` is a variable
(use `Φ`-saturation of `{f(x)}`) or an operation `ν(Q)` (use the test at
`R_j ∈ Subt(c(ν))` and `Θ`-congruence). See `STATE.md` Sessions 132–133.

## 5. Infrastructure discipline and gate

- [ ] 5.1 Confirm `lean/declarations.mscong.json` still maps no declarations and
  no evidence is written under `evidence/mscong/`; verify `scripts/projects.py
  --check` and `--collisions` pass.
- [ ] 5.2 Confirm the default project is untouched: `scripts/projects.py
  --check-baseline` passes and `scripts/check_all.sh --fast` is green.
- [ ] 5.3 Run `python3 scripts/lean_audit.py --project mscong` and confirm no
  warnings, no `sorry`, and permitted axioms only; record the result.

## 6. Docs and state

- [ ] 6.1 Record the M4 session in `STATE.md` (what was formalized, axioms, the
  deferred mapping/evidence decision, next steps).
- [ ] 6.2 Note in `STATE.md` that derivors / Hall algebras (M5) and the
  correspondence audit (M6) remain open. If M4 is split, record whether `PRecH`
  or `PRecLH` is deferred and to which follow-up change.
