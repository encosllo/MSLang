import Mslang.Pilot

/-!
Environment smoke test and axiom audit for the MSLang pilot (Architecture.md
Sections 10.6 item 4 and 15.5). The pilot definitions and the first formal
target live in `Mslang/Pilot.lean`.

`#print axioms` must report only `propext`, `Classical.choice`, and
`Quot.sound` (the three Mathlib axioms); anything else is a trust-boundary
finding.
-/

theorem mslang_smoke : 1 + 1 = 2 := rfl

#print axioms mslang_smoke
#print axioms Mslang.sat_antitone
#print axioms Mslang.sat_sat_eq
#print axioms Mslang.prop_incSat
#print axioms Mslang.setoid_le_iff
#print axioms Mslang.nabla_sat
#print axioms Mslang.sat_inf
#print axioms Mslang.supp_delta
#print axioms Mslang.card_le_one_iff
#print axioms Mslang.sat_eq_preimage
#print axioms Mslang.isSat_iff_preimage
#print axioms Mslang.nabla_sat_empty
#print axioms Mslang.nabla_sat_deltaUnion
