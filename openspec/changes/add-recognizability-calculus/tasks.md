# Tasks

## 1. Finite-index congruence calculus

- [ ] 1.1 In `lean/Mscong/Recognizable.lean`, define the finite-index congruence set `Cgr_fi(A)` over `Mslang.IsCongruence`/`Mslang.IsFiniteIndex`; verify it compiles and the definition is the `Ω`-free filter carrier the paper uses.
- [ ] 1.2 Prove upward closure: `Φ ⊆ Ψ`, `Φ` of finite index ⟹ `Ψ` of finite index; verify with a targeted `lake build Mscong.Recognizable`.
- [ ] 1.3 Prove closure under finite nonempty meets of congruences; verify the proof is axiom-clean.
- [ ] 1.4 Prove that `Cgr_fi(A)` is a filter of the congruence lattice when `supp_S(A)` is finite; verify it uses the `B-P031`-style filter shape.

## 2. Recognizability predicates

- [ ] 2.1 Define `Rec_T(A)` (a finite `Σ`-algebra `B`, a homomorphism `f : A → B`, and `M ⊆ B↾_T` with `L = (f↾_T)⁻¹[M]`), using `Mslang.FiniteSSet`, `Mslang.IsAlgHom`, and the restriction/inverse-image maps; verify the general `T`-case compiles.
- [ ] 2.2 Derive `Rec(A)` (`T = univ`) and `Rec_s(A)` (`T = {s}`) as specializations; verify no definition is duplicated.
- [ ] 2.3 Prove the characterization: `L` recognizable iff saturated by a finite-index congruence, iff `Ω^A(L)` has finite index (the `S`-indexed form); verify against the paper's three-way equivalence.
- [ ] 2.4 Prove the `T`-indexed characterization (`Ω^A([L, ∅^{S−T}])` of finite index); verify the `S−T` extension is built with `Mslang`'s delta/empty-family machinery.

## 3. Kronecker-delta bridge and closure properties

- [ ] 3.1 Prove `L ∈ Rec_s(A) ↔ δ^{s,L} ∈ Rec(A)` using `Mslang.deltaSub`/`deltaT`; verify the concentration is the existing one, not re-encoded.
- [ ] 3.2 Prove Boolean closure of `Rec(A)`/`Rec_s(A)` (`∅`/`A_s`, union, intersection, relative complement); verify each clause is axiom-clean.
- [ ] 3.3 Prove closure under translation preimages (`T⁻¹[L]`, `Mslang.transPreimage`/`TlGen`); verify it reuses `Mslang.Translation`.
- [ ] 3.4 Prove closure under inverse images along homomorphisms (`f⁻¹[M]`); verify it reuses `Mslang.inverseImage`/`pullbackEqv`.

## 4. Infrastructure discipline and gate

- [ ] 4.1 Confirm `lean/declarations.mscong.json` still maps no declarations and no evidence is written under `evidence/mscong/`; verify `scripts/projects.py --check` and `--collisions` pass.
- [ ] 4.2 Confirm the default project is untouched: `python3 scripts/projects.py --check-baseline` passes and `scripts/check_all.sh --fast` is green.
- [ ] 4.3 Run the Lean mechanical audit for the second project (`python3 scripts/lean_audit.py --project mscong`) and confirm no warnings, no `sorry`, and permitted axioms only; record the result.

## 5. Docs and state

- [ ] 5.1 Record the M1 session in `STATE.md` (what was formalized, axioms, the deferred mapping/evidence decision, next steps); verify it names `Mscong` and the finite-index scope.
- [ ] 5.2 Note in `STATE.md` that the locally-finite half and the finite-`S` subdirect-product result remain open, with the milestone they belong to.
