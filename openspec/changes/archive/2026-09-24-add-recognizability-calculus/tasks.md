# Tasks

## 1. Finite-index congruence calculus

- [x] 1.1 In `lean/Mscong/Recognizable.lean`, define the finite-index congruence set `Cgr_fi(A)` over `Mslang.IsCongruence`/`Mslang.IsFiniteIndex`; verify it compiles and the definition is the `Ω`-free filter carrier the paper uses. *(Reused: `Mslang.congFi` already defines it; no redefinition, per design D1.)*
- [x] 1.2 Prove upward closure: `Φ ⊆ Ψ`, `Φ` of finite index ⟹ `Ψ` of finite index; verify with a targeted `lake build Mscong.Recognizable`. *(Reused: `Mslang.IsFiniteIndex_of_le`.)*
- [x] 1.3 Prove closure under finite nonempty meets of congruences; verify the proof is axiom-clean. *(Reused: `Mslang.IsFiniteIndex_inf`.)*
- [x] 1.4 Prove that `Cgr_fi(A)` is a filter of the congruence lattice when `supp_S(A)` is finite; verify it uses the `B-P031`-style filter shape. *(Reused: `Mslang.congFi_filter`.)*

## 2. Recognizability predicates

- [x] 2.1 Define `Rec_T(A)` (a finite `Σ`-algebra `B`, a homomorphism `f : A → B`, and `M ⊆ B↾_T` with `L = (f↾_T)⁻¹[M]`), using `Mslang.FiniteSSet`, `Mslang.IsAlgHom`, and the restriction/inverse-image maps; verify the general `T`-case compiles. *(Implemented for `T = S` as `Recognizable`; the general `T ⊆ S` restriction encoding is task 2.4.)*
- [x] 2.2 Derive `Rec(A)` (`T = univ`) and `Rec_s(A` (`T = {s}`) as specializations; verify no definition is duplicated. *(`Recognizable` and `RecognizableAt`.)*
- [x] 2.3 Prove the characterization: `L` recognizable iff saturated by a finite-index congruence, iff `Ω^A(L)` has finite index (the `S`-indexed form); verify against the paper's three-way equivalence. *(`recognizable_iff_isRegularLanguage` for `(1) ⟺ (3)` and `recognizable_iff_exists_finiteIndex_sat` for `(2)`.)*
- [x] 2.4 Prove the `T`-indexed characterization (`Ω^A([L, ∅^{S−T}])` of finite index); verify the `S−T` extension is built with `Mslang`'s delta/empty-family machinery. *(`RecognizableOn` + `zeroExtension`; `recognizableOn_iff_zeroExtension` is the restriction-free bridge — the zero-extension absorbs `f↾_T` — and `recognizableOn_iff_finiteIndex_zeroExtension` / `recognizableOn_iff_exists_finiteIndex_sat` are the two characterizations.)*

## 3. Kronecker-delta bridge and closure properties

- [x] 3.1 Prove `L ∈ Rec_s(A) ↔ δ^{s,L} ∈ Rec(A)` using `Mslang.deltaSub`/`deltaT`; verify the concentration is the existing one, not re-encoded. *(`recognizableAt_iff`.)*
- [x] 3.2 Prove Boolean closure of `Rec(A)`/`Rec_s(A)` (`∅`/`A_s`, union, intersection, relative complement); verify each clause is axiom-clean. *(Union/intersection/complement done (`recognizable_union`/`_inter`/`_compl`); the `∅`/`A_s` bounds are `recognizable_empty`/`recognizable_univ`/`recognizableAt_empty`/`recognizableAt_univ`, carried under the **necessary** finite-support hypothesis `(supp A).Finite` — a finite recognizing algebra forces `supp(A) ⊆ supp(B)`, so the paper's hypothesis-free statement is false for infinite `S`; flagged to the author in `STATE.md`.)*
- [x] 3.3 Prove closure under translation preimages (`T⁻¹[L]`, `Mslang.transPreimage`/`TlGen`); verify it reuses `Mslang.Translation`. *(`recognizable_transPreimage`.)*
- [x] 3.4 Prove closure under inverse images along homomorphisms (`f⁻¹[M]`); verify it reuses `Mslang.inverseImage`/`pullbackEqv`. *(`recognizable_inverseImage`, via `finite_quot_pullback`/`isFiniteIndex_pullback`.)*

## 4. Infrastructure discipline and gate

- [x] 4.1 Confirm `lean/declarations.mscong.json` still maps no declarations and no evidence is written under `evidence/mscong/`; verify `scripts/projects.py --check` and `--collisions` pass.
- [x] 4.2 Confirm the default project is untouched: `python3 scripts/projects.py --check-baseline` passes and `scripts/check_all.sh --fast` is green.
- [x] 4.3 Run the Lean mechanical audit for the second project (`python3 scripts/lean_audit.py --project mscong`) and confirm no warnings, no `sorry`, and permitted axioms only; record the result. *(0 declarations, 0 warnings, 0 `sorry`, ok=True.)*

## 5. Docs and state

- [x] 5.1 Record the M1 session in `STATE.md` (what was formalized, axioms, the deferred mapping/evidence decision, next steps); verify it names `Mscong` and the finite-index scope.
- [x] 5.2 Note in `STATE.md` that the locally-finite half and the finite-`S` subdirect-product result remain open, with the milestone they belong to.
