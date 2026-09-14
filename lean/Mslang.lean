import Mathlib

/-!
Environment smoke test for the MSLang pilot (Architecture.md Sections 10.6
item 4 and 15.5). This file exists to confirm, once the pinned Mathlib has been
fetched, that the project builds cleanly, is `sorry`-free, and rests only on the
permitted axioms.

Run after bootstrap:
    cd lean && lake exe cache get && lake build
    lake env lean Mslang.lean

`#print axioms` must report only `propext`, `Classical.choice`, and
`Quot.sound` (the three Mathlib axioms); anything else is a trust-boundary
finding.
-/

theorem mslang_smoke : 1 + 1 = 2 := rfl

#print axioms mslang_smoke
