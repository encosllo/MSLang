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

- [ ] 4.1 Form `Φ = ⋂_{(x,r)} Ω(δ^{φ(r),{f_r(x)}})` (finite index) and
  `Θ = Ω(δ^{s,L})` (finite index); prove `Φ` saturates each `{f_r(x)}`.
- [ ] 4.2 Define `Ψ` on `T_Ξ(Y)` (agreement on the direct images of the
  `Θ_r`-classes) and prove it is a finite-index congruence, using linearity for
  the operation case.
- [ ] 4.3 Prove `f♯_s[L]` is `Ψ_{φ(s)}`-saturated and conclude `PRecLH`.

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
