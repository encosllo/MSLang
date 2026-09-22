# Correspondence audit transcript -- `B-C012` (cross-model, mixed)

Protocol: Architecture.md Section 11.2, two-stage blind, per the cross-model
audit brief's Section 6 ingestion pattern. Stage 1 reuses the existing
Session-119 `deepseek-v4.1-flash` read-back (excerpted to the relevant theorem
and its immediate vocabulary, from `blocks/audits/B-C012-correspondence.md`).
Stage 2 is a fresh, isolated `claude-sonnet-5` agent given the excerpted
stage-1 read-back and the contract, including the standing Assumption
`B-A001` (`S` finite) -- explicitly instructed not to treat an ambient
assumption as absent merely because it is not restated locally (the lesson
from the `B-P034` self-correction in Session 122). No repo access, no
expected answer.

- **Lean declarations:** `Mslang.finiteIndexCongruenceFormations_isAlgebraicLattice` (`lean/Mslang/Regular.lean`)
- **Contract:** Corollary `B-C012` (under standing Assumption `B-A001`, `S` finite), section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** stage 1 ran on `deepseek-v4.1-flash`, stage 2 on
  `claude-sonnet-5` -- distinct model families (`deepseek`, `claude`).

## Stage 1 -- read-back (excerpted from the deepseek-v4.1-flash transcript, Lean only)

> `finiteIndexCongruenceFormations Sig` -- the set of finite-index congruence
> formations. `finiteIndexCongruenceFormationsCompleteLattice` (needs
> `[Finite S]`) is a complete lattice structure on it, with explicit infimum
> `finiteIndexCongruenceFormationsInf` and top
> `finiteIndexCongruenceFormationsTop`; `finiteIndexCongruenceFormations_isGLB_sInf`
> confirms the explicit infimum is the greatest lower bound.
>
> Main theorem: `finiteIndexCongruenceFormations_isAlgebraicLattice`:
> `finiteIndexCongruenceFormations Sig` (with the complete lattice structure
> above, which requires `[Finite S]`) is an algebraic lattice, obtained by
> transporting algebraicity from `finiteAlgebraFormations` (finite algebra
> formations) across the order isomorphism
> `formAlgFFormCgrFiIso : finiteAlgebraFormations Sig ≃o finiteIndexCongruenceFormations Sig`.
> `IsAlgebraicLattice` means every element is the join of the compact elements
> below it.

## Stage 2 -- comparison (fresh agent, claude-sonnet-5, read-back + contract only)

> **VERDICT: equivalent**
>
> Both sides carry the same ambient hypothesis: the contract's standing
> Assumption fixes S finite for the whole section, and the Lean statement's
> complete-lattice structure on `finiteIndexCongruenceFormations Sig` (needed
> to even state "algebraic lattice") is only available given `[Finite S]`,
> matching exactly. Both sides assert the identical conclusion -- that the
> lattice of finite-index congruence formations is algebraic (every element is
> the join of compact elements below it) -- with no strengthening or weakening
> of scope on either side. The proof route via the order isomorphism
> `formAlgFFormCgrFiIso` to `finiteAlgebraFormations` is merely the internal
> justification/witness, not part of the stated theorem, so it doesn't affect
> correspondence; likewise the commented-out isomorphism sentence in the
> contract is explicitly inactive and correctly excluded from consideration.
> No degenerate-case mismatch: an empty or trivial S is still finite and both
> formulations degrade the same way (lattice is trivially algebraic). Hence
> the formal statement and the active contract assert the same proposition
> under the same hypothesis.

## Source verification (coordinator)

`finiteIndexCongruenceFormations_isAlgebraicLattice` and the complete-lattice
instance it depends on both carry `[Finite S]` in `lean/Mslang/Regular.lean`,
matching Assumption `B-A001`. No gap of the `B-P034` kind here.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, `E-000389` cross-model). `[Finite S]` is
the standing assumption `B-A001`, correctly carried by both stages. This
cross-model run confirms the existing `equivalent` verdict (`E-000293`); no
discrepancy found.
