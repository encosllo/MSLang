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

## 4. `PRecLH` (deferred; see the plan below)

- [ ] 4.1 Form `Φ = ⋂_{(x,r)} Ω(δ^{φ(r),{f_r(x)}})` (finite index, using
  `IsFiniteIndex_inter` over the finite `X`) and `Θ = Ω(δ^{s,L})` (finite
  index); prove `Φ` saturates each `{f_r(x)}`.
- [~] 4.2 (Infrastructure done; `Ψ` itself open.) Defined `Subt` (the
  componentwise subterms of a term, `Subt_self`/`Subt_op_mem`/`Subt_finite`),
  the operator `substInto`/`cSubstLang` (`((v_i ↦ A_i))^♯ (R)`). Still to do:
  the occurrence count `bb{R}_{v_i}` (partly available via `countPlaceholder`);
  define `Ψ` (the test space is `Σ p, Σ (σ : Sig p), {R // R ∈ Subt(c(σ))} ×
  ((i) → Quotient (Θ (p.1.get i)))`, finite from `Finite (Sigma Sig)`,
  `Subt_finite`, and `IsFiniteIndex Θ`)
  on `T_Ξ(Y)` (`M Ψ_t N` iff `M Φ_t N` and, for every `(w,r)`, `σ`, subterm `R`
  of `c(σ)` at `t`, and classes `l_i`, membership in
  `((v_i ↦ f♯_{w_i}[[W_{w_i,l_i}]_{Θ_{w_i}}]))^♯_t(R)` agrees); prove `Ψ` is a
  finite-index congruence, using **linearity** so that each placeholder occurs
  once (the paper's cases (a)/(b.1.i)/(b.1.ii)/(b.2)).
- [ ] 4.3 Prove `f♯_s[L]` is `Ψ_{φ(s)}`-saturated and conclude `PRecLH`.

**Deferred.** This is the technical heart of M4 (like `PRecIt` in M3): it needs
a `Subt` subterm collection, its interaction with substitution, and the paper's
long case analysis; it is large enough to be its own follow-up change. The
definitions + `PRecH` are complete and committed (parts 1–3); the change stays
**open** with 4.x unchecked. See `STATE.md` Session 132.

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
