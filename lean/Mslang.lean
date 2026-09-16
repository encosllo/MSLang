import Mslang.Free
import Mslang.Sanity

/-!
Environment smoke test and axiom audit for the MSLang pilot (Architecture.md
Sections 10.6 item 4 and 15.5). The pilot theory is split by dependency layer
across `Mslang/Prelim.lean`, `Mslang/Algebra.lean`, `Mslang/Congruence.lean`,
`Mslang/Subfinal.lean`, and `Mslang/Free.lean` (Section 10.2).

`#print axioms` must report only `propext`, `Classical.choice`, and
`Quot.sound` (the three Mathlib axioms); anything else is a trust-boundary
finding.
-/

theorem mslang_smoke : 1 + 1 = 2 := rfl

#print axioms mslang_smoke
#print axioms Mslang.sat_antitone
#print axioms Mslang.satSets_antitone
#print axioms Mslang.sat_sat_eq
#print axioms Mslang.prop_incSat
#print axioms Mslang.setoid_le_iff
#print axioms Mslang.nabla_sat
#print axioms Mslang.sat_inf_subset
#print axioms Mslang.sat_inf
#print axioms Mslang.supp_delta
#print axioms Mslang.card_le_one_iff
#print axioms Mslang.sat_eq_preimage
#print axioms Mslang.isSat_iff_preimage
#print axioms Mslang.nabla_sat_empty
#print axioms Mslang.nabla_sat_deltaUnion
#print axioms Mslang.sanity_not_subfinal
#print axioms Mslang.sanity_nonvacuous
#print axioms Mslang.sanity_converse_counterexample
#print axioms Mslang.eqvClass_eq_iff
#print axioms Mslang.ker_iff
#print axioms Mslang.sat_isClosureOperator
#print axioms Mslang.sat_isCompletelyAdditive
#print axioms Mslang.sat_isAlgebraic
#print axioms Mslang.sat_compl
#print axioms Mslang.satSets_fix
#print axioms Mslang.supp_quot
#print axioms Mslang.ker_pr
#print axioms Mslang.quotLift_comp
#print axioms Mslang.quotLift_unique
#print axioms Mslang.finiteSSet_iff
#print axioms Mslang.ker_isCongruence
#print axioms Mslang.quotOp_mk
#print axioms Mslang.isAlgHom_prAlg
#print axioms Mslang.quotAlgLift_isAlgHom
#print axioms Mslang.quotAlgLift_comp
#print axioms Mslang.quotAlgLift_unique
#print axioms Mslang.suppAlg_iAlg
#print axioms Mslang.supports_isClosureSystem
#print axioms Mslang.Sg_idem
#print axioms Mslang.Sg_isClosureOperator
#print axioms Mslang.suppSub_Sg
#print axioms Mslang.suppSub_Sg_uniform
#print axioms Mslang.isAlgHom_iProjAlg
#print axioms Mslang.isAlgHom_iPairAlg
#print axioms Mslang.iProjAlg_iPairAlg
#print axioms Mslang.iPairAlg_unique
#print axioms Mslang.subfinalAlg_iff
#print axioms Mslang.nabla_isCongruence
#print axioms Mslang.quot_nabla_subfinal
#print axioms Mslang.hom_unique_of_subfinalAlg
#print axioms Mslang.delta_iso_coprod
