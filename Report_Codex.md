# Report_Codex — contrast of every manuscript block with its Lean formalization

**Author:** Codex, source-and-ledger review.  
**Date:** 2026-09-21.  
**Repository point:** commit `ff31282` plus this report; the pre-existing untracked `Report_Claude.md` was not modified.  
**Scope:** all 129 confirmed blocks in `blocks/registry.json`, their maps in `lean/declarations.json` / `blocks/formal.json`, the current evidence ledger, the actual manuscript text, and targeted Lean-source checks.

## Executive result

The Lean development is mechanically healthy: `blocks/lean_audit.json` records 366 audited declarations, a clean build, no `sorry`, no warnings, no missing axiom reports, and no axioms outside `propext`, `Classical.choice`, and `Quot.sound`. That establishes compilation and local proof soundness for the mapped declarations. It does **not**, by itself, establish that each mapped declaration covers its entire manuscript block.

The exhaustive ledger split is: **129 total = 75 correspondence-audited + 47 mapped/verification-only + 7 unmapped**. Among the 75 current correspondence records, the stored outcomes are **70 `equivalent`, 4 `formal_stronger`, and 1 `formal_weaker`**. All positive correspondence records are same-model evidence and therefore remain `provisional`, not independent passes.

My main findings are:

1. **`B-P001` remains the one acknowledged negative correspondence result.** The Lean formalization is weaker because the dependent-type carrier cannot state arbitrary unions/intersections/differences of unrelated sorted-set carriers.
2. **`B-R001` is a false full-block `equivalent` verdict.** Its map and audit cover only the opening coproduct isomorphism. Five further groups of assertions in the same remark have no mapped Lean counterpart. For the whole block, the faithful verdict is partial / `formal_weaker`.
3. **Several definition blocks are only partially owned by their maps.** The clearest are `B-D002`, `B-D003`, `B-D006`, `B-D014`, and `B-D024`. Some content is assigned to a neighboring block; some is not mapped at all.
4. **The seven unmapped blocks are not all content-free.** `B-R002`, `B-R004`, and `B-R027` state genuine mathematical claims; `B-R015` states a foundational size claim; only `B-R013` and `B-R025` are pure forward references. `B-C003` is a substantive adjunction theorem.
5. **The evidence boundary is narrower than the project’s completion language suggests.** Forty-seven mapped blocks have build/axiom verification but no correspondence audit. Most are definitions, but a build cannot decide whether a definition captured every clause of the prose.
6. **Derived reports understate open audit work.** The dependency discrepancy report has 621 undecided edges; its “mapped blocks” list also omits mapped `B-D001` and `B-D029`. The trust-boundary report propagates representation residuals to only 15 blocks even though all 75 current correspondence records depend on the representation hash, and it lists five bridges as “unproved” although `blocks/bridges.json` marks all five proved.

## Method and evidential meaning

- I treated `blocks/registry.json` as the 129-block universe and `blocks/formal.json` / `lean/declarations.json` as the ownership map.
- I recomputed current correspondence records using the repository’s own hash-resolution logic in `scripts/status.py`, rather than counting historical/stale records.
- I inspected the manuscript bodies and the actual Lean sources for all exceptions and for blocks whose ownership looked incomplete. In particular, I checked `B-R001`, `B-D002`, `B-D003`, `B-D006`, `B-D014`, `B-D024`, `B-P001`, `B-D033`, `B-X001`, and all seven unmapped blocks.
- “Verification-only” below means exactly this: mapped declarations compile and have current mechanical evidence, but the repository has no current correspondence record for the block. It is intentionally **not** called equivalent.
- Stored `equivalent` / `formal_stronger` verdicts are reported as ledger facts. Except where this report flags a defect, they remain subject to the project-wide same-model and representation caveats.

## Material findings

### 1. Open formal weakness: `B-P001`

`E-000236` correctly classifies `B-P001` as `formal_weaker`. Direct/inverse image, surjection, empty/terminal, and product clauses are represented, but the paper’s support-of-arbitrary-union clause has only a coproduct analogue, while intersection and difference are restricted to componentwise subsets of a common carrier. This follows from `SSet S := S → Type u`: unrelated carrier types have no common ambient union/intersection. The project correctly identifies this as a representation decision, not a missing Lean tactic.

### 2. Incorrect full-block equivalence: `B-R001`

The manuscript remark contains the coproduct isomorphism and then asserts that the deltas form a generating family, are the atoms of `Sub(1^S)`, induce `Sub(1^S) ≅ Sub(S)`, are projective, and have only monomorphisms out. The formal map contains `SortedIso`, `iCoprod`, `deltaT`, two elementary equivalences, and `delta_iso_coprod`. The transcript `blocks/audits/B-R001-correspondence.md` reads back only the coproduct isomorphism, yet returns `equivalent` for the whole remark. Searches of `lean/Mslang/*.lean` found no mapped declarations for the other assertions. The evidence should be superseded as partial / `formal_weaker`, or the remark should be split so the audited first sentence is its own block.

### 3. Partial or cross-owned definition maps

| block | contrast |
|---|---|
| `B-D002` | Owns only `SSet`. Its `SortedMap` content is assigned to `B-D015`; the categorical `Set^S` assertion is not formalized as category infrastructure. |
| `B-D003` | Owns product/projection/pairing. `iCoprod` is assigned to `B-R001`. The stated componentwise union/intersection/complement/difference operations for sorted sets are not owned here and are exactly where the dependent-carrier model loses fidelity. |
| `B-D006` | Owns `delta` only. `deltaT`, `deltaEquiv`, and the `delta^t = delta^{t,1}` apparatus are assigned to `B-R001`. Content exists, but the block pointer/facet is incomplete. |
| `B-D014` | Owns `SortedEqv`, `sat`, `IsSat`. `quot` is assigned to `B-R005`; `pr` is not mapped; no mapped theorem establishes the parenthetical algebraic closure-system/lattice claim for `Eqv(A)`. |
| `B-D024` | Owns only `IsCongruence`. `nabla_isCongruence` is assigned to `B-R012` and `IsCongruence_inf` to `B-D033`; no mapped theorem establishes the full algebraic closure-system/lattice claim for `Cgr(A)`. |

These are identity/coverage problems in the block-to-declaration map. The declarations may compile and may be used elsewhere, but the current formal facets do not represent the full source blocks they purport to cover.

### 4. Four benign stronger results

| block | why Lean is stronger |
|---|---|
| `B-P005` | Proves the saturation/intersection clause for every index type, including the empty case; the manuscript assumes nonempty. |
| `B-P015` | Proves abstractness for arbitrary `G`, not merely formations. |
| `B-P026` | Drops the manuscript’s nonempty-index hypothesis; the empty case is valid. |
| `B-C009` | Proves the atom-meet result for arbitrary sorted equivalences, not only congruences. |

### 5. Resolved mathematical errors

- **`B-D033` / `B-C004`:** the pre-correction ShSk definition required only nonemptiness. The Lean counterexample showed this was insufficient because the empty subdirect product forces subfinal algebras. The manuscript now requires `Sf(1) ⊆ F`, matching Lean.
- **`B-X001`:** the original claim that periodic algebras form a formation for arbitrary `S` was false. Lean required finite `S`; the manuscript now includes that hypothesis and the current record `E-000255` is `equivalent`.

### 6. Unmapped frontier reclassified

| block | source claim | Codex classification |
|---|---|---|
| `B-C003` | `T_Σ ⊣ G_Σ` | Substantive theorem; category infrastructure missing. Stored rationale is outdated because term parsing/universal-property work is now present. |
| `B-R002` | finite ⇔ finitary ⇔ strongly finitary in `Set^S` | Substantive categorical theorem, not content-free. |
| `B-R004` | every single-sorted closure operator is uniform | Substantive, likely small, unformalized claim. |
| `B-R013` | promises algebraicity of `Form_Cgr(Σ)` | Pure forward reference; later result supplies the content. |
| `B-R015` | size/legitimacy of `Form_Alg(Σ)` in the Grothendieck-universe foundation | Foundational size claim; intentionally outside the current Lean encoding, but not content-free. |
| `B-R025` | promises algebraicity of `Form_Cgr_fi(Σ)` | Pure forward reference; later result supplies the content. |
| `B-R027` | BPS1 follows from BPS2+BPS3 | Substantive redundancy theorem; no proof is mapped. |

## Full per-block comparison

The Lean map below is exact modulo dropping the `Mslang.` namespace. “Verification-only” is not a correspondence verdict. A dagger (`†`) means the positive correspondence record is same-model/provisional.

### Preliminaries.

| block | kind | line | Lean map | current ledger contrast | finding |
|---|---:|---:|---|---|---|
| `B-D001` | definition | 212 | `Prelim` (3): `Word`, `concat`, `emptyWord` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D002` | definition | 230 | `Prelim` (1): `SSet` | verification-only | PARTIAL MAP: `SSet` is owned here, but the block also defines sorted maps and the category `Set^S`; `SortedMap` is owned by `B-D015`, and no category structure is mapped. |
| `B-D003` | definition | 236 | `Prelim` (3): `iProd`, `iProj`, `iPair` | verification-only | PARTIAL MAP: products/projections/pairing are owned here. Coproduct is owned by `B-R001`; arbitrary sorted-set union/intersection/complement/difference are not captured by this map and are constrained by the dependent-carrier representation. |
| `B-D004` | definition | 254 | `Prelim` (3): `Subfinal`, `finalSorted`, `initialSorted` | `equivalent`† (`E-000085`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D005` | definition | 260 | `Prelim` (2): `Sub`, `Subset` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D006` | definition | 266 | `Prelim` (1): `delta` | verification-only | TRACEABILITY: only `delta` is owned here. The same block defines `delta^{t,X}` and identifies `delta^t = delta^{t,1}`; those declarations are owned by `B-R001`. |
| `B-R001` | remark | 289 | `Prelim` (6): `SortedIso`, `iCoprod`, `deltaT`, `sigmaPUnitEquiv`, `deltaEquiv`, `delta_iso_coprod` | `equivalent`† (`E-000113`) | AUDIT DEFECT: ledger says `equivalent`, but the map/audit covers only `delta^{t,X} ≅ ∐_X delta^t`. The generating-family, atom, Boolean-algebra, projectivity, and monomorphism assertions have no mapped counterpart. Codex classification: partial / `formal_weaker` for the whole block. |
| `B-D007` | definition | 308 | `Prelim` (2): `directImage`, `inverseImage` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D008` | definition | 333 | `Prelim` (3): `FiniteSSet`, `FiniteSub`, `finiteSubsets` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-R002` | remark | 338 | — | unmapped | UNMAPPED SUBSTANTIVE CLAIM: equivalence of finite, finitary, and strongly finitary objects in `Set^S`; not merely a content-free remark. |
| `B-D009` | definition | 345 | `Prelim` (1): `supp` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-R003` | remark | 351 | `Prelim` (1): `finiteSSet_iff` | `equivalent`† (`E-000095`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P001` | proposition | 359 | `Prelim` (11): `nonempty_sortedMap_iff`, `supp_mono_of_injective`, `suppSub_directImage`, `supp_eq_of_surjective`, `suppSub_inverseImage`, `supp_initialSorted`, `supp_finalSorted`, `supp_iCoprod`, `supp_iProd`, `suppSub_iInter_subset`, `suppSub_sdiff_subset` | `formal_weaker` (`E-000236`) | OPEN GAP (`formal_weaker`): coproduct support replaces arbitrary-union support, and intersection/difference are only for subsets of one fixed carrier. Representation-level, not a proof hole. |
| `B-D010` | definition | 376 | `Algebra` (2): `Sub_iInter`, `IsClosureSystem` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D011` | definition | 452 | `Algebra` (2): `IsCompact`, `IsAlgebraicLattice` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D012` | definition | 460 | `Algebra` (2): `Sub_iUnion`, `IsAlgebraicClosureSystem` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D013` | definition | 481 | `Algebra` (2): `IsUniform`, `IsUniformAlgebraicClosureOperator` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-R004` | remark | 487 | — | unmapped | UNMAPPED SUBSTANTIVE CLAIM: every single-sorted closure operator is uniform. |
| `B-D014` | definition | 504 | `Prelim` (3): `SortedEqv`, `sat`, `IsSat` | verification-only | PARTIAL MAP: sorted equivalence and saturation are owned here. Quotient is owned by `B-R005`; `pr` is not mapped; the algebraic-closure-system/lattice assertion for `Eqv(A)` has no mapped proof. |
| `B-R005` | remark | 525 | `Prelim` (2): `quot`, `supp_quot` | `equivalent`† (`E-000093`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R006` | remark | 531 | `Prelim` (2): `sat_eq_preimage`, `isSat_iff_preimage` | `equivalent`† (`E-000088`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P002` | proposition | 538 | `Prelim` (1): `prop_incSat` | `equivalent`† (`E-000086`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-C001` | corollary | 553 | `Prelim` (1): `sat_antitone` | `equivalent`† (`E-000083`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R007` | remark | 573 | `Prelim` (2): `satSets`, `satSets_antitone` | `equivalent`† (`E-000091`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P003` | proposition | 579 | `Prelim` (1): `nabla_sat` | `equivalent`† (`E-000087`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R008` | remark | 591 | `Prelim` (3): `nabla_sat_empty`, `nabla_sat_univ`, `nabla_sat_deltaUnion` | `equivalent`† (`E-000089`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P004` | proposition | 597 | `Prelim` (1): `sat_inf_subset` | `equivalent`† (`E-000090`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-C002` | corollary | 608 | `Prelim` (1): `sat_inf` | `equivalent`† (`E-000084`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P005` | proposition | 639 | `Prelim` (16): `IsClosureOperator`, `IsCompletelyAdditive`, `IsAlgebraic`, `sat_extensive`, `sat_monotone`, `sat_idem`, `sat_isClosureOperator`, `sat_iUnion`, `sat_isCompletelyAdditive`, `sat_isAlgebraic`, `sat_iInter_subset`, `sat_univ`, `sat_compl`, `suppSub_sat`, `sat_uniform`, `satSets_fix` | `formal_stronger`† (`E-000092`) | `formal_stronger`: Lean drops the manuscript’s nonempty-index hypothesis for the saturation/intersection clause. |
| `B-P006` | proposition | 658 | `Regular` (7): `satOfFamily`, `familyOf`, `satSetsFamilyEquiv`, `satSetsCABA`, `familyOf_atomRep`, `satSets_isAtom_iff`, `satSets_eq_sSup_atoms` | `equivalent`† (`E-000234`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D015` | definition | 672 | `Prelim` (2): `SortedMap`, `ker` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-P007` | proposition | 678 | `Prelim` (4): `quotLift`, `ker_pr`, `quotLift_comp`, `quotLift_unique` | `equivalent`† (`E-000094`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D016` | definition | 698 | `Algebra` (1): `Signature` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D017` | definition | 710 | `Algebra` (4): `wordProd`, `finOp`, `AlgStruct`, `IsAlgHom` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D018` | definition | 725 | `Algebra` (1): `suppAlg` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-R009` | remark | 731 | `Algebra` (3): `IsClosureSystemOn`, `suppAlg_iAlg`, `supports_isClosureSystem` | `equivalent`† (`E-000098`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D019` | definition | 737 | `Algebra` (1): `FiniteAlg` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D020` | definition | 767 | `Algebra` (1): `IsSubalgebra` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D021` | definition | 773 | `Algebra` (9): `MemSg`, `Sg`, `IsGenerating`, `subset_Sg`, `Sg_isSubalgebra`, `Sg_least`, `Sg_monotone`, `Sg_idem`, `Sg_isClosureOperator` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-R010` | remark | 780 | `Algebra` (3): `SuppClosure`, `suppSub_Sg`, `suppSub_Sg_uniform` | `equivalent`† (`E-000097`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D022` | definition | 789 | `Algebra` (7): `iAlg`, `iProjAlg`, `isAlgHom_iProjAlg`, `iPairAlg`, `isAlgHom_iPairAlg`, `iProjAlg_iPairAlg`, `iPairAlg_unique` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D023` | definition | 817 | `Subfinal` (4): `finalAlg`, `IsAlgIso`, `subAlg`, `SubfinalAlg` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-P008` | proposition | 823 | `Subfinal` (1): `subfinalAlg_iff` | `equivalent`† (`E-000105`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R011` | remark | 833 | `Subfinal` (1): `hom_unique_of_subfinalAlg` | `equivalent`† (`E-000109`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D024` | definition | 841 | `Congruence` (1): `IsCongruence` | verification-only | PARTIAL MAP: only `IsCongruence` is owned here. The block also asserts that `Cgr(A)` is an algebraic closure system/lattice with top and bottom; no mapped declaration establishes that full claim. |
| `B-D025` | definition | 856 | `Congruence` (5): `quotOp`, `quotAlg`, `prAlg`, `quotOp_mk`, `isAlgHom_prAlg` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-P009` | proposition | 870 | `Congruence` (5): `ker_isCongruence`, `ker_prAlg`, `quotAlgLift_isAlgHom`, `quotAlgLift_comp`, `quotAlgLift_unique` | `equivalent`† (`E-000096`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R012` | remark | 890 | `Subfinal` (2): `nabla_isCongruence`, `quot_nabla_subfinal` | `equivalent`† (`E-000107`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D026` | definition | 899 | `Free` (5): `SigElem`, `XElem`, `RowAlpha`, `WSet`, `WAlg` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D027` | definition | 937 | `Free` (7): `genSet`, `TAlg`, `TSet`, `etaX`, `Term`, `termAlg`, `termEta` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-P010` | proposition | 960 | `Term` (2): `toT_injective`, `term_shape` | `equivalent`† (`E-000242`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P011` | proposition | 984 | `Term` (4): `termLift`, `termLift_isAlgHom`, `termLift_eta`, `exists_unique_termLift` | `equivalent`† (`E-000169`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-C003` | corollary | 1009 | — | unmapped | UNMAPPED SUBSTANTIVE THEOREM: the free/forgetful adjunction. The stored deferral rationale (“needs term characterization / unique parsing”) is stale because `B-P010`–`B-P013` are now mapped; category infrastructure remains the real blocker. |
| `B-L001` | lemma | 1026 | `Term` (1): `termLift_unique` | `equivalent`† (`E-000167`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P012` | proposition | 1032 | `Term` (1): `term_projective` | `equivalent`† (`E-000171`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P013` | proposition | 1038 | `Term` (3): `termEval`, `termEval_isAlgHom`, `termEval_surjective` | `equivalent`† (`E-000173`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D028` | definition | 1046 | `Formation` (5): `IsMonoAlg`, `IsEpiAlg`, `IsSubdirectEmbedding`, `IsSubdirectProduct`, `IsomorphicSubdirectEmbeddings` | verification-only | Mapped and mechanically verified; no current correspondence audit. |

### $\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.

| block | kind | line | Lean map | current ledger contrast | finding |
|---|---:|---:|---|---|---|
| `B-D029` | definition | 1073 | `Formation` (2): `IsLatticeFilter`, `latticeFilters` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D030` | definition | 1089 | `Formation` (1): `IsCongruenceFormation` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-P014` | proposition | 1112 | `Formation` (4): `congruenceFormationsTop`, `congruenceFormationsInf`, `congruenceFormations_isGLB_sInf`, `congruenceFormationsCompleteLattice` | `equivalent`† (`E-000218`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R013` | remark | 1141 | — | unmapped | UNMAPPED META/forward reference; later discharged by the algebraic-lattice result. |
| `B-D031` | definition | 1149 | `Formation` (2): `HOperator`, `PFsdOperator` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-P015` | proposition | 1162 | `Formation` (5): `algebraFormationOfCongruenceFormation`, `algebraFormationOfCongruenceFormation_nonempty`, `algebraFormationOfCongruenceFormation_abstract`, `algebraFormationOfCongruenceFormation_HOperator`, `algebraFormationOfCongruenceFormation_PFsdOperator` | `formal_stronger`† (`E-000178`) | `formal_stronger`: abstractness is proved for arbitrary `G`, not only a formation. |
| `B-D032` | definition | 1214 | `Formation` (2): `IsAlgebraFormation`, `algebraFormations` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-R014` | remark | 1231 | `Formation` (2): `formation_abstract`, `formation_nonempty` | `equivalent`† (`E-000123`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R015` | remark | 1236 | — | unmapped | UNMAPPED FOUNDATIONAL/SIZE CLAIM about `U`-large sets; outside the Lean universe encoding, but mathematically substantive bookkeeping. |
| `B-R016` | remark | 1242 | `Formation` (2): `subfinalAlgebras`, `subfinalAlgebras_isAlgebraFormation` | `equivalent`† (`E-000244`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-X001` | examples | 1248 | `Regular` (6): `IsCyclicSub`, `IsPeriodicAlg`, `periodicAlgebras`, `periodicAlgebras_closed_HOperator`, `periodicAlgebras_closed_PFsdOperator`, `periodicAlgebras_isAlgebraFormation` | `equivalent`† (`E-000255`) | CURRENTLY `equivalent` AFTER CORRECTION: the manuscript now assumes finite `S`, matching Lean. The former unrestricted statement was false for infinite `S` because of the empty subdirect product. |
| `B-R017` | remark | 1298 | `Formation` (1): `subfinalAlg_mem_of_formation` | `equivalent`† (`E-000127`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D033` | definition | 1321 | `Formation` (2): `IsCongruence_inf`, `IsShSkFormation` | verification-only | CURRENTLY CONSISTENT AFTER CORRECTION: the manuscript’s first ShSk clause was strengthened from mere nonemptiness to `Sf(1) ⊆ F`, matching the Lean definition and removing the `B-C004` counterexample. |
| `B-P016` | proposition | 1337 | `Formation` (1): `formation_congInf` | `equivalent`† (`E-000125`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P017` | proposition | 1352 | `Formation` (5): `pairAlgFamily`, `isAlgIso_symm`, `quotAlg_ker_isAlgIso`, `formation_mem_of_iso`, `shskFormation_mem_of_subdirect_pair` | `equivalent`† (`E-000131`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-C004` | corollary | 1362 | `Formation` (4): `algebraFormation_iff_shskFormation`, `shskFormation_mem_of_subdirect`, `sortedEqvLe_refl`, `sortedEqvLe_trans` | `equivalent`† (`E-000133`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P018` | proposition | 1372 | `Formation` (4): `HOperator_mono`, `PFsdOperator_mono`, `exists_mem_superset_finset`, `algebraFormations_isAlgebraicClosureSystem` | `equivalent`† (`E-000146`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D034` | definition | 1390 | `Formation` (1): `formationGenerating` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-C005` | corollary | 1405 | `Formation` (4): `algebraFormationsClosureOperator`, `algebraFormationsCompleteLattice`, `algebraFormations_isAlgebraicLattice`, `algebraFormations_isCompact_iff` | `equivalent`† (`E-000224`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P019` | proposition | 1415 | `Formation` (2): `congruenceFormationOf`, `congruenceFormation_isCongruenceFormation` | `equivalent`† (`E-000176`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P020` | proposition | 1433 | `Formation` (11): `congruenceFormations`, `algebraFormationOfCongruenceFormation_isAlgebraFormation`, `congruenceFormationOf_mono`, `algebraFormationOfCongruenceFormation_mono`, `algebraFormationOfCongruenceFormation_congruenceFormationOf`, `congruenceFormationOf_algebraFormationOfCongruenceFormation`, `thetaSigma`, `thetaSigmaInv`, `thetaSigma_left_inv`, `thetaSigma_right_inv`, `formAlgFormCgrIso` | `equivalent`† (`E-000180`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-C006` | corollary | 1490 | `Formation` (1): `congruenceFormations_isAlgebraicLattice` | `equivalent`† (`E-000226`) | Recorded correspondence outcome; positive result remains same-model/provisional. |

### Elementary translations and translations.

| block | kind | line | Lean map | current ledger contrast | finding |
|---|---:|---:|---|---|---|
| `B-D035` | definition | 1513 | `Translation` (2): `IsElemTranslation`, `Etl` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D036` | definition | 1520 | `Translation` (2): `TlGen`, `Tl` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-R018` | remark | 1527 | `Translation` (7): `TlHom`, `TlId`, `TlComp`, `TlComp_id_left`, `TlComp_id_right`, `TlComp_assoc`, `tlEndMonoid` | `equivalent`† (`E-000144`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D037` | definition | 1552 | `Translation` (5): `deltaSub`, `transImage`, `transPreimage`, `transImageSet`, `transPreimageSet` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-P021` | proposition | 1566 | `Translation` (8): `ClosesUnderEtl`, `ClosesUnderTl`, `closesUnderEtl_of_isCongruence`, `congruence_of_closesUnderEtl`, `closesUnderTl_of_closesUnderEtl`, `closesUnderEtl_of_closesUnderTl`, `isCongruence_iff_closesUnderEtl`, `closesUnderEtl_iff_closesUnderTl` | `equivalent`† (`E-000139`) | Recorded correspondence outcome; positive result remains same-model/provisional. |

### Congruence cogenerated  by an $S$-sorted subset of the underlying $S$-sorted set of a $\Sigma$-algebra.

| block | kind | line | Lean map | current ledger contrast | finding |
|---|---:|---:|---|---|---|
| `B-D038` | definition | 1641 | `Translation` (1): `congCogenerated` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-P022` | proposition | 1656 | `Translation` (4): `charEqv`, `congCogenerated_isCongruence`, `congCogenerated_le_charEqv`, `le_congCogenerated_of_isCongruence` | `equivalent`† (`E-000141`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D039` | definition | 1675 | `Translation` (1): `syntacticCongruence` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-R019` | remark | 1702 | `Translation` (1): `syntacticCongruence_eq_congCogenerated` | `equivalent`† (`E-000250`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P023` | proposition | 1708 | `Translation` (2): `isSat_iff_sortedEqvLe_charEqv`, `isSat_iff_le_congCogenerated` | `equivalent`† (`E-000149`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P024` | proposition | 1724 | `Translation` (1): `isCongruence_eq_iInf_congCogenerated` | `equivalent`† (`E-000159`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R020` | remark | 1740 | `Translation` (2): `deltaEqv`, `deltaEqv_eq_iInf_congCogenerated` | `equivalent`† (`E-000157`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P025` | proposition | 1750 | `Translation` (1): `congCogenerated_compl` | `equivalent`† (`E-000151`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P026` | proposition | 1756 | `Translation` (2): `isCongruence_iInf`, `congCogenerated_iInter_le` | `formal_stronger`† (`E-000153`) | `formal_stronger`: Lean proves the empty-index case too. |
| `B-P027` | proposition | 1766 | `Translation` (1): `congCogenerated_le_transPreimage` | `equivalent`† (`E-000155`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P028` | proposition | 1772 | `Translation` (3): `pullbackEqv`, `pullbackEqv_congCogenerated_le`, `congCogenerated_le_pullback_of_surj` | `equivalent`† (`E-000161`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R021` | remark | 1816 | `Translation` (17): `isAlgHom_id`, `isAlgHom_comp`, `sortedEqvLe_antisymm`, `AlgEpi`, `AlgEpiId`, `AlgEpiComp`, `AlgEpiExt`, `AlgEpiComp_id_left`, `AlgEpiComp_id_right`, `AlgEpiComp_assoc`, `SubMap`, `CgrMap`, `SubMap_id`, `SubMap_comp`, `CgrMap_id`, `CgrMap_comp`, `congCogenerated_natural` | `equivalent`† (`E-000164`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P029` | proposition | 1859 | `Translation` (3): `cogClassSets`, `cogClassSetsCompl`, `eqvClass_congCogenerated` | `equivalent`† (`E-000212`) | Recorded correspondence outcome; positive result remains same-model/provisional. |

### $\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.

| block | kind | line | Lean map | current ledger contrast | finding |
|---|---:|---:|---|---|---|
| `B-P030` | proposition | 1992 | `Regular` (5): `langFormationOf`, `mem_langFormationOf_iff`, `langFormationOf_nabla`, `langFormationOf_inf`, `langFormationOf_ker` | `equivalent`† (`E-000191`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R022` | remark | 2036 | `Regular` (1): `langFormationOf_eq_iUnion_satSets` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-R023` | remark | 2042 | `Regular` (1): `langFormationOf_sat_of_le` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-C007` | corollary | 2048 | `Regular` (1): `langFormationOf_transPreimage` | `equivalent`† (`E-000207`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-C008` | corollary | 2059 | `Regular` (5): `langFormationOf_union`, `langFormationOf_inter`, `langFormationOf_compl`, `langFormationOf_empty`, `langFormationOf_univ` | `equivalent`† (`E-000208`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-C009` | corollary | 2069 | `Regular` (1): `langFormationOf_atom_inf` | `formal_stronger`† (`E-000209`) | `formal_stronger`: proved for arbitrary sorted equivalences, not only congruences. |
| `B-C010` | corollary | 2082 | `Regular` (1): `langFormationOf_inverseImage` | `equivalent`† (`E-000210`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D040` | definition | 2093 | `Regular` (2): `IsFiniteIndex`, `congFi` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-X002` | examples | 2099 | `Regular` (2): `congFi_nonempty_iff`, `congFi_nonempty_of_finite_sorts` | `equivalent`† (`E-000248`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P031` | proposition | 2105 | `Regular` (6): `quotLe`, `quotLe_mk`, `isFiniteIndex_nabla`, `IsFiniteIndex_of_le`, `IsFiniteIndex_inf`, `congFi_filter` | `equivalent`† (`E-000187`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R024` | remark | 2118 | `Regular` (1): `finite_supp_term_iff` | `equivalent`† (`E-000240`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-A001` | assumption | 2124 | `Regular` (1): `FiniteSorts` | `equivalent`† (`E-000239`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D041` | definition | 2130 | `Regular` (2): `IsFiniteIndexCongruenceFormation`, `finiteIndexCongruenceFormations` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-P032` | proposition | 2143 | `Regular` (5): `isFiniteIndex_ker_of_finite`, `finiteIndexCongruenceFormationsTop`, `finiteIndexCongruenceFormationsInf`, `finiteIndexCongruenceFormations_isGLB_sInf`, `finiteIndexCongruenceFormationsCompleteLattice` | `equivalent`† (`E-000220`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-R025` | remark | 2171 | — | unmapped | UNMAPPED META/forward reference; later discharged by the algebraic-lattice result. |
| `B-D042` | definition | 2181 | `Regular` (1): `algebraFinite` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D043` | definition | 2187 | `Regular` (2): `IsFiniteAlgebraFormation`, `finiteAlgebraFormations` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-P033` | proposition | 2197 | `Regular` (3): `algebraFinite_closed_HOperator`, `algebraFinite_closed_PFsdOperator`, `finiteAlgebraFormations_isAlgebraicClosureSystem` | `equivalent`† (`E-000216`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-C011` | corollary | 2207 | `Regular` (2): `finiteAlgebraFormationsCompleteLattice`, `finiteAlgebraFormations_isAlgebraicLattice` | `equivalent`† (`E-000228`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P034` | proposition | 2213 | `Regular` (4): `finiteSSet_of_isAlgIso`, `congruenceFormationOf_isFiniteIndex`, `algebraFormationOfCongruenceFormation_isFiniteAlgebra`, `formAlgFFormCgrFiIso` | `equivalent`† (`E-000189`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-C012` | corollary | 2242 | `Regular` (1): `finiteIndexCongruenceFormations_isAlgebraicLattice` | `equivalent`† (`E-000230`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D044` | definition | 2264 | `Regular` (2): `IsRegularLanguage`, `regularLanguages` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-R026` | remark | 2269 | `Regular` (1): `exists_regular_infinite_language` | `equivalent`† (`E-000254`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-D045` | definition | 2275 | `Regular` (2): `IsRegularLanguageFormation`, `regularLanguageFormations` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-D046` | definition | 2304 | `Regular` (2): `IsBPSLanguageFormation`, `bpsLanguageFormations` | verification-only | Mapped and mechanically verified; no current correspondence audit. |
| `B-R027` | remark | 2326 | — | unmapped | UNMAPPED SUBSTANTIVE REDUNDANCY CLAIM: BPS1 follows from BPS2+BPS3. No mapped proof. |
| `B-P035` | proposition | 2332 | `Regular` (2): `isBPSLanguageFormation_of_isRegularLanguageFormation`, `isRegularLanguageFormation_of_isBPSLanguageFormation` | `equivalent`† (`E-000214`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P036` | proposition | 2414 | `Regular` (1): `regularLanguageFormations_completeLattice` | `equivalent`† (`E-000252`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P037` | proposition | 2423 | `Regular` (1): `langFormationOf_isRegularLanguageFormation` | `equivalent`† (`E-000195`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P038` | proposition | 2437 | `Regular` (6): `langCongFormationOf`, `langCongFormationOf_nabla`, `langCongFormationOf_up`, `langCongFormationOf_inf`, `langCongFormationOf_ker`, `langCongFormationOf_isFiniteIndexCongruenceFormation` | `equivalent`† (`E-000197`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-P039` | proposition | 2473 | `Regular` (7): `sortedEqvInf_self`, `IsCongruenceFormation_finset_inf`, `langFormationOf_mono`, `langCongFormationOf_mono`, `langCongFormationOf_langFormationOf`, `langFormationOf_langCongFormationOf`, `formCgrFiFormLangRIso` | `equivalent`† (`E-000199`) | Recorded correspondence outcome; positive result remains same-model/provisional. |
| `B-C013` | corollary | 2515 | `Regular` (2): `regularLanguageFormationsCompleteLattice`, `regularLanguageFormations_isAlgebraicLattice` | `equivalent`† (`E-000232`) | Recorded correspondence outcome; positive result remains same-model/provisional. |

## Cross-cutting audit limitations

1. **Same-model evidence:** all correspondence, review, and representation audits were produced by the same model family. The repository correctly marks positive layers `provisional`. A second-model or human audit is the highest-leverage confidence improvement.
2. **No correspondence layer for 47 mapped blocks:** this is why the table uses “verification-only.” The five partial-map examples demonstrate that definitions are not automatically safe to exempt.
3. **Dependency comparison unfinished:** `reports/discrepancy.md` contains 621 undecided formal/informal edges. Statement correspondence can be current while dependency traceability is still unresolved.
4. **Trust-boundary under-reporting:** `representation/coverage.json` names only the original 15-block pilot cluster, while all 75 current correspondence records list `representation/encoding` as an input. `reports/trust_boundary.md` therefore displays the residuals on only 15 rows even though the evidence itself binds every audited block to that representation.
5. **Bridge-report contradiction:** `blocks/bridges.json` records all five representation bridges as proved, and `reports/frontier.md` reports none open; `reports/trust_boundary.md` nevertheless lists all five under “Unproved bridge obligations.”
6. **Mapped-universe report omission:** `B-D001` and `B-D029` are present in `blocks/formal.json` and mechanically verified, but are absent from the “Mapped blocks” list in `reports/discrepancy.md`, apparently because they have no relevant graph edges.
7. **Source-level facets:** formal hashes are normalized source text, not elaborated types/proof terms. This is an acknowledged project limitation and makes the block map itself part of the trusted correspondence surface.

## Recommended next actions

1. Supersede `E-000113` for `B-R001` with a full-block partial/`formal_weaker` audit, or split/formalize the additional claims.
2. Keep `B-P001` explicitly open until the author chooses among the representation options in `representation/p001-representation-brief.md`.
3. Add correspondence audits for the 47 verification-only blocks, prioritizing `B-D002`, `B-D003`, `B-D006`, `B-D014`, and `B-D024`; repair ownership before issuing verdicts.
4. Reclassify the unmapped frontier so `B-R002`, `B-R004`, `B-R015`, and `B-R027` are not described as content-free, and refresh `B-C003`’s deferral rationale.
5. Fix the trust-boundary bridge/coverage logic and the discrepancy report’s mapped-universe calculation; then review the 621 undecided dependency edges by impact rather than alphabetically.
6. Run at least one independent model-family or human correspondence pass on the headline theorems and the newly identified partial blocks.

## Bottom line

The project’s Lean core is strong and the three headline isomorphism/lattice results are genuinely machine-checked. The principal mathematical gap remains the openly recorded `B-P001` representation weakness. The principal audit gap is different: block ownership and correspondence coverage are incomplete, and `B-R001` demonstrates that an `equivalent` record can cover only the first claim of a multi-claim block. The appropriate project status is therefore **mechanically verified formal development with substantial, mostly positive correspondence evidence — not yet an exhaustive full-block correspondence proof for all 129 blocks**.
