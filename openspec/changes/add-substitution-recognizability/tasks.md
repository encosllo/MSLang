# Tasks

## 1. Substitution operators

- [ ] 1.1 In `lean/Mscong/Substitution.lean`, define the subset algebra on
  `Sub (Term Sig X)` (the operation for `σ` maps `(A_i)` to the direct image
  `{σ(a_i) | a_i ∈ A_i}`; constants to singletons); verify it compiles.
- [ ] 1.2 Define the single-variable substitution `(z\Q)(P)` by recursion on
  `P` (or as the subset-hom value with all other variables fixed to
  singletons); verify `(z\Q)(z) = Q` and `(z\Q)(σ(P_i)) = σ((z\Q)(P_i))`.
- [ ] 1.3 Define the simultaneous substitution and the induced homomorphism
  `substHom L := termLift Sig X (subsetAlg).2 L`; verify its value at `P` is the
  set of simultaneously substituted terms (the paper's
  `Im((x,t)\·)(P)↾∏ L_x^{P_x})`, and that single-variable substitution is the
  specialization with the other variables fixed to `{z}`.
- [ ] 1.4 Verify the substitution is compatible with the free-algebra structure
  (a `Mslang` homomorphism), reusing `termLift_isAlgHom`.

## 2. Reusable finite-index / transversal API

- [ ] 2.1 Provide, for a finite-index sorted equivalence `Φ`, a finite
  transversal of `T_Σ(X)/Φ` (a `Fintype`/`Finset` enumeration) and the index
  `k_r` per sort; verify the index of a refinement bounded by `k_r · 2^{k_r}` is
  finite.
- [ ] 2.2 Provide the `Ψ`-refinement lemma: given `Φ` and a finite family of
  languages, the relation refining `Φ` by agreement on class membership is a
  congruence of finite index saturating the target. Verify it is the shared core
  of the three proofs.

## 3. `PRecSubs`

- [ ] 3.1 Form `Φ = ⋂ (⋃_{t,x} {Ω(δ^{t,L_x})} ∪ {Ω(δ^{s,K})})` and prove it has
  finite index (filter property + `S`,`X` finite).
- [ ] 3.2 Apply the `Ψ`-refinement lemma to show the substituted language is
  saturated by a finite-index congruence; conclude `PRecSubs` via
  `recognizable_iff_exists_finiteIndex_sat`. Verify the `S`,`X` finite
  hypotheses and that it is axiom-clean.

## 4. `PRecIt`

- [ ] 4.1 Define the `z`-iteration `L^{⋆z}` (the union of the recursively defined
  `L^{j,z}`, `L^{0,z} = {z}`); verify `L^{1,z} = L ∪ {z}` and monotonicity.
- [ ] 4.2 Form `Φ = Ω(δ^{s,L}) ∩ Ω(δ^{s,z})` (finite index, using M2's
  `PRecVar` for `{z}`) and apply the refinement lemma to conclude `PRecIt`.

## 5. `PRecQ`

- [ ] 5.1 Define the `z`-quotient `K^{-z}L = {U | (z\K)^♯_s(U) ∩ L ≠ ∅}`.
- [ ] 5.2 Form `Φ = Ω(δ^{s,L})` and apply the refinement lemma to conclude
  `PRecQ` (recognizability), and prove the set of `z`-quotients of a fixed
  recognizable `L` is finite.

## 6. Infrastructure discipline and gate

- [ ] 6.1 Confirm `lean/declarations.mscong.json` still maps no declarations and
  no evidence is written under `evidence/mscong/`; verify `scripts/projects.py
  --check` and `--collisions` pass.
- [ ] 6.2 Confirm the default project is untouched: `scripts/projects.py
  --check-baseline` passes and `scripts/check_all.sh --fast` is green.
- [ ] 6.3 Run `python3 scripts/lean_audit.py --project mscong` and confirm no
  warnings, no `sorry`, and permitted axioms only; record the result.

## 7. Docs and state

- [ ] 7.1 Record the M3 session in `STATE.md` (what was formalized, axioms, the
  deferred mapping/evidence decision, next steps); verify it names `Mscong` and
  the free-algebra scope.
- [ ] 7.2 Note in `STATE.md` that tree homomorphisms (M4) and derivors (M5)
  remain open, with the milestone they belong to. If M3 is split, record which
  of substitution/iteration/quotient is deferred and to which follow-up change.
