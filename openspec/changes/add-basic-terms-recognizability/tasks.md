# Tasks

## 1. Finite recognizing algebra `2^S`

- [ ] 1.1 In `lean/Mscong/BasicTerms.lean`, define the two-element `Σ`-algebra
  `2^S` (carrier `Fin 2` at every sort, every operation the constant map to `0`);
  prove `FiniteAlg` of it when `S` is finite. Verify with a targeted
  `lake build Mscong.BasicTerms`.
- [ ] 1.2 Package the recognizing homomorphism as the free extension
  `termLift Sig X (2^S).2 g` of a sorted map `g : X → 2^S`, and record
  `IsAlgHom` via `Mslang.termLift_isAlgHom`.
- [ ] 1.3 Define the σ-discriminating variant (the distinguished constant
  `σ : Σ_{λ,s}` maps `2_λ` to `1`, every other operation to `0`) used by
  `PRecConst`; verify it compiles.

## 2. Basic-term recognizability

- [ ] 2.1 Prove `PRecVar`: for `x : X s`, `{x} ⊆ T_Σ(X)_s` is recognizable, via
  the characteristic map of `{x}` at `s`; verify the induction `termLift … = 1 ↔
  P = var x`.
- [ ] 2.2 Prove `PRecConst`: for a constant `σ : Σ_{λ,s}`, `{σ} ⊆ T_Σ(X)_s` is
  recognizable, via the σ-discriminating algebra; verify the induction.
- [ ] 2.3 Prove `PRecOp`: for `(w,s)` with `w` nonempty, `σ : Σ_{w,s}`, and
  `(x_i)_{i∈w}` in `X_w`, `{σ((x_i))} ⊆ T_Σ(X)_s` is recognizable, via the
  counting algebra `K`; verify the induction. *(Open question: `Fintype (Im x)`
  vs the paper's explicit `k_t`.)*
- [ ] 2.4 (Optional) Derive the full-language forms `δ^{s,{t}} ∈ Rec(T_Σ(X))`
  from `recognizableAt_iff`, if the later milestones want them.

## 3. Reuse discipline

- [ ] 3.1 Confirm the development reuses `Mslang.Term`/`termAlg`/`termLift` and
  M1's `Recognizable`/`RecognizableAt`, with no redefined terms, free algebra,
  or recognizability predicate; verify by inspection and the build.

## 4. Infrastructure discipline and gate

- [ ] 4.1 Confirm `lean/declarations.mscong.json` still maps no declarations and
  no evidence is written under `evidence/mscong/`; verify `scripts/projects.py
  --check` and `--collisions` pass.
- [ ] 4.2 Confirm the default project is untouched: `scripts/projects.py
  --check-baseline` passes and `scripts/check_all.sh --fast` is green.
- [ ] 4.3 Run `python3 scripts/lean_audit.py --project mscong` and confirm no
  warnings, no `sorry`, and permitted axioms only; record the result.

## 5. Docs and state

- [ ] 5.1 Record the M2 session in `STATE.md` (what was formalized, axioms, the
  deferred mapping/evidence decision, next steps); verify it names `Mscong` and
  the free-algebra scope.
- [ ] 5.2 Note in `STATE.md` that substitutions/iterations/quotients (M3) and
  tree homomorphisms (M4) remain open, with the milestone they belong to.
