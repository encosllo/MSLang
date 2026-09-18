import Mslang.Free
import Mslang.Term
import Mslang.Formation
import Mslang.Sanity
import Mslang.Translation
import Mslang.Regular

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
#print axioms Mslang.TAlg_hom_ext
#print axioms Mslang.termLift_isAlgHom
#print axioms Mslang.termLift_unique
#print axioms Mslang.exists_unique_termLift
#print axioms Mslang.termEval_surjective
#print axioms Mslang.term_projective
#print axioms Mslang.IsCongruence_inf
#print axioms Mslang.formation_abstract
#print axioms Mslang.formation_nonempty
#print axioms Mslang.formation_congInf
#print axioms Mslang.subfinalAlg_mem_of_formation
#print axioms Mslang.isAlgIso_symm
#print axioms Mslang.quotAlg_ker_isAlgIso
#print axioms Mslang.formation_mem_of_iso
#print axioms Mslang.shskFormation_mem_of_subdirect_pair
#print axioms Mslang.sortedEqvLe_refl
#print axioms Mslang.sortedEqvLe_trans
#print axioms Mslang.shskFormation_mem_of_subdirect
#print axioms Mslang.algebraFormation_iff_shskFormation
#print axioms Mslang.IsElemTranslation
#print axioms Mslang.Etl
#print axioms Mslang.TlGen
#print axioms Mslang.Tl
#print axioms Mslang.deltaSub
#print axioms Mslang.transImage
#print axioms Mslang.transPreimage
#print axioms Mslang.transImageSet
#print axioms Mslang.transPreimageSet
#print axioms Mslang.congCogenerated
#print axioms Mslang.ClosesUnderEtl
#print axioms Mslang.ClosesUnderTl
#print axioms Mslang.isCongruence_iff_closesUnderEtl
#print axioms Mslang.closesUnderEtl_iff_closesUnderTl
#print axioms Mslang.congCogenerated_isCongruence
#print axioms Mslang.congCogenerated_le_charEqv
#print axioms Mslang.le_congCogenerated_of_isCongruence
#print axioms Mslang.TlHom
#print axioms Mslang.TlComp
#print axioms Mslang.TlComp_assoc
#print axioms Mslang.tlEndMonoid
#print axioms Mslang.algebraFormations_isAlgebraicClosureSystem
#print axioms Mslang.formationGenerating
#print axioms Mslang.congruenceFormationOf
#print axioms Mslang.congruenceFormation_isCongruenceFormation
#print axioms Mslang.algebraFormationOfCongruenceFormation
#print axioms Mslang.algebraFormationOfCongruenceFormation_nonempty
#print axioms Mslang.algebraFormationOfCongruenceFormation_abstract
#print axioms Mslang.algebraFormationOfCongruenceFormation_HOperator
#print axioms Mslang.algebraFormationOfCongruenceFormation_PFsdOperator
#print axioms Mslang.congruenceFormations
#print axioms Mslang.algebraFormationOfCongruenceFormation_isAlgebraFormation
#print axioms Mslang.algebraFormationOfCongruenceFormation_congruenceFormationOf
#print axioms Mslang.congruenceFormationOf_algebraFormationOfCongruenceFormation
#print axioms Mslang.thetaSigma
#print axioms Mslang.thetaSigmaInv
#print axioms Mslang.formAlgFormCgrIso
#print axioms Mslang.IsFiniteIndex
#print axioms Mslang.congFi
#print axioms Mslang.algebraFinite
#print axioms Mslang.IsFiniteAlgebraFormation
#print axioms Mslang.finiteAlgebraFormations
#print axioms Mslang.IsFiniteIndexCongruenceFormation
#print axioms Mslang.finiteIndexCongruenceFormations
#print axioms Mslang.IsRegularLanguage
#print axioms Mslang.regularLanguages
#print axioms Mslang.quotLe
#print axioms Mslang.isFiniteIndex_nabla
#print axioms Mslang.IsFiniteIndex_of_le
#print axioms Mslang.IsFiniteIndex_inf
#print axioms Mslang.congFi_filter
#print axioms Mslang.finiteSSet_of_isAlgIso
#print axioms Mslang.congruenceFormationOf_isFiniteIndex
#print axioms Mslang.algebraFormationOfCongruenceFormation_isFiniteAlgebra
#print axioms Mslang.formAlgFFormCgrFiIso
#print axioms Mslang.isSat_iff_le_congCogenerated
#print axioms Mslang.congCogenerated_compl
#print axioms Mslang.congCogenerated_iInter_le
#print axioms Mslang.congCogenerated_le_transPreimage
#print axioms Mslang.deltaEqv_eq_iInf_congCogenerated
#print axioms Mslang.isCongruence_eq_iInf_congCogenerated
#print axioms Mslang.pullbackEqv_congCogenerated_le
#print axioms Mslang.congCogenerated_le_pullback_of_surj
