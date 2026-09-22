# Correspondence audit transcript -- `B-C013` (cross-model, mixed)

Protocol: Architecture.md Section 11.2, two-stage blind, per the cross-model
audit brief's Section 6 ingestion pattern. Stage 1 reuses the existing
Session-119 `deepseek-v4.1-flash` read-back (excerpted to the relevant theorem
and its immediate vocabulary, from `blocks/audits/B-C013-correspondence.md`).
Stage 2 is a fresh, isolated `claude-sonnet-5` agent given the excerpted
stage-1 read-back and the contract, including the standing Assumption
`B-A001` (`S` finite) -- explicitly instructed not to treat an ambient
assumption as absent merely because it is not restated locally (the lesson
from the `B-P034` self-correction in Session 122). No repo access, no
expected answer.

- **Lean declarations:** `Mslang.regularLanguageFormationsCompleteLattice`, `Mslang.regularLanguageFormations_isAlgebraicLattice` (`lean/Mslang/Regular.lean`)
- **Contract:** Corollary `B-C013` (under standing Assumption `B-A001`, `S` finite), section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** stage 1 ran on `deepseek-v4.1-flash`, stage 2 on
  `claude-sonnet-5` -- distinct model families (`deepseek`, `claude`).

## Stage 1 -- read-back (excerpted from the deepseek-v4.1-flash transcript, Lean only)

> `regularLanguageFormations Sig` -- the set of regular-language formations.
> `regularLanguageFormationsCompleteLattice` (needs `[Finite S]`): a complete
> lattice structure on it, obtained by lifting the complete lattice of
> finite-index congruence formations along the Galois insertion induced by
> `formCgrFiFormLangRIso : finiteIndexCongruenceFormations Sig ≃o regularLanguageFormations Sig`
> (with `langFormationOf` and `langCongFormationOf` as the two directions).
>
> Main theorem: `regularLanguageFormations_isAlgebraicLattice`:
> `regularLanguageFormations Sig` with that complete-lattice structure is an
> algebraic lattice, transported from the finite-index congruence formations
> along the order isomorphism `formCgrFiFormLangRIso`. `IsAlgebraicLattice`
> means every element is the join of the compact elements below it.

## Stage 2 -- comparison (fresh agent, claude-sonnet-5, read-back + contract only)

> **VERDICT: equivalent**
>
> The contract's active claim is exactly "Form_Lang_r(Σ) is an algebraic
> lattice," under the standing ambient assumption (from earlier in the
> section, still in force) that S is finite; the commented-out isomorphism
> sentence is inactive and not part of the contract to check. The Lean side's
> `regularLanguageFormationsCompleteLattice` requires `[Finite S]` to even
> define the complete-lattice structure, and the main theorem
> `regularLanguageFormations_isAlgebraicLattice` asserts precisely that
> `regularLanguageFormations Sig` with that structure is an algebraic lattice
> (every element is the join of compact elements below it), which is the
> standard formal meaning of "algebraic lattice." Hypotheses match (finiteness
> of S, present in Lean as an explicit instance argument and in the contract
> as the standing section assumption -- not absent, just inherited), and
> conclusions match (algebraicity of the regular-language-formation lattice).
> The transport route via the order isomorphism to finite-index congruence
> formations is a proof technique/construction detail, not an extra
> hypothesis or a weaker/stronger conclusion -- it does not change what is
> asserted about `regularLanguageFormations Sig` itself. No degenerate-case
> mismatch: both sides are vacuous/trivial together only if S is empty, which
> is consistent under both formulations. Hence this is a direct equivalence,
> no strengthening or weakening in either direction.

## Source verification (coordinator)

`regularLanguageFormationsCompleteLattice` and
`regularLanguageFormations_isAlgebraicLattice` both carry `[Finite S]` in
`lean/Mslang/Regular.lean`, matching Assumption `B-A001`. No gap of the
`B-P034` kind here.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, `E-000389` cross-model). `[Finite S]` is
the standing assumption `B-A001`, correctly carried by both stages. This
cross-model run confirms the existing `equivalent` verdict (`E-000294`); no
discrepancy found.
