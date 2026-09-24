# Tasks

## 1. Finite recognizing algebra `2^S`

- [x] 1.1 In `lean/Mscong/BasicTerms.lean`, define the two-element `Σ`-algebra
  `2^S` (carrier `Two` at universe `u`, every operation the constant map to `z`);
  prove `FiniteAlg` of it when `S` is finite. Verified with a targeted
  `lake build Mscong.BasicTerms`. *(Carrier is the inductive `Two : Type u`
  because `Fin 2 : Type 0` cannot inhabit the `Type u`-sorted `SSet`; `Two` has
  a `Fintype`/`Nonempty` instance.)*
- [x] 1.2 Package the recognizing homomorphism as the free extension
  `termLift Sig X B.2 g` of a sorted map `g : X → B`, and record `IsAlgHom` via
  `Mslang.termLift_isAlgHom`. *(Used by `PRecVar` and `PRecConst`; the
  `PRecOp` recognizing algebra is a separate `K`-carrier family, still to be
  finished — see 2.3.)*
- [x] 1.3 Define the σ-discriminating variant (the distinguished constant
  `σ : Σ_{λ,s}` maps `2_λ` to `o`, every other operation to `z`) used by
  `PRecConst`; verified it compiles. *(`twoAlgConst`.)*

## 2. Basic-term recognizability

- [x] 2.1 Prove `PRecVar`: for `x : X s`, `{x} ⊆ T_Σ(X)_s` is recognizable, via
  the characteristic map of `{x}` at `s`; verified the induction
  `termLift … = o ↔ P = var x`. *(`PRecVar`; the induction is a `Term.rec` with
  the dependent motive stated via `HEq` to avoid index casts.)*
- [x] 2.2 Prove `PRecConst`: for a constant `σ : Σ_{λ,s}`, `{σ} ⊆ T_Σ(X)_s` is
  recognizable, via the σ-discriminating algebra; verified the induction.
  *(`PRecConst`.)*
- [x] 2.3 Prove `PRecOp`: for `(w,s)` with `w` nonempty, `σ : Σ_{w,s}`, and
  `(x_i)_{i∈w}` in `X_w`, `{σ((x_i))} ⊆ T_Σ(X)_s` is recognizable, via the
  counting carrier `K`; verified the induction. *(`PRecOp`, via `twoAlgOp`
  and the value lemmas. The index transport under `p = (w,s)` is handled with
  the `▸`-based `finOfEq`/`finOfEq_self_eq` so it reduces definitionally; the
  target tuple is a parameter of `twoOpSig`, avoiding an `Eq.mpr` on the
  variable family.)*
- 2.4 (Optional, not in M2 scope) Derive the full-language forms
  `δ^{s,{t}} ∈ Rec(T_Σ(X))` from `recognizableAt_iff`, if the later milestones
  want them.

## 3. Reuse discipline

- [x] 3.1 The implemented part (`PRecVar`/`PRecConst`) reuses
  `Mslang.Term`/`termAlg`/`termLift` and M1's `RecognizableAt` with no redefined
  terms, free algebra, or recognizability predicate; verified by inspection and
  the build.

## 4. Infrastructure discipline and gate

- [x] 4.1 Confirmed `lean/declarations.mscong.json` still maps no declarations
  and no evidence is written under `evidence/mscong/`; `scripts/projects.py
  --check` and `--collisions` pass.
- [x] 4.2 Confirmed the default project is untouched: `scripts/projects.py
  --check-baseline` passes and `scripts/check_all.sh --fast` is green.
- [x] 4.3 Ran `python3 scripts/lean_audit.py --project mscong`: **0
declarations, 0 warnings, 0 `sorry`, ok=True** (the module is unmapped, so there
are no declarations to audit; the `sorry` scan is clean).

## 5. Docs and state

- [x] 5.1 Recorded the (partial) M2 session in `STATE.md` (what was formalized, axioms, the
  deferred mapping/evidence decision, next steps); verify it names `Mscong` and
  the free-algebra scope.
- [x] 5.2 Noted in `STATE.md` that `PRecOp` remains open and that
substitutions/iterations/quotients (M3) and tree homomorphisms (M4) follow.
