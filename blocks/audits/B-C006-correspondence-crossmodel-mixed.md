# Correspondence audit transcript -- `B-C006` (cross-model, mixed)

Protocol: Architecture.md Section 11.2, two-stage blind, per the cross-model
audit brief's Section 6 ingestion pattern. Stage 1 reuses the existing
Session-119 `deepseek-v4.1-flash` read-back (excerpted to the relevant theorem
and its immediate vocabulary, from `blocks/audits/B-C006-correspondence.md`).
Stage 2 is a fresh, isolated `claude-sonnet-5` agent given only the excerpted
stage-1 read-back and the contract -- no repo access, no expected answer.

- **Lean declarations:** `Mslang.congruenceFormations_isAlgebraicLattice` (`lean/Mslang/Formation.lean`)
- **Contract:** Corollary `B-C006`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** stage 1 ran on `deepseek-v4.1-flash`, stage 2 on
  `claude-sonnet-5` -- distinct model families (`deepseek`, `claude`).

## Stage 1 -- read-back (excerpted from the deepseek-v4.1-flash transcript, Lean only)

> Main proved theorem: `congruenceFormations_isAlgebraicLattice`. For every
> signature Sig, the complete lattice of congruence formations (under
> `congruenceFormationsCompleteLattice`) is an algebraic lattice: every element
> is the join of the compact elements below it (compact meaning: for every
> directed set D, a ≤ ⨆D implies a ≤ d for some d ∈ D). The proof transports
> algebraicity from the algebra formations across the order isomorphism
> `formAlgFormCgrIso` (using the fact that algebra formations form an algebraic
> lattice, declared as `algebraFormations_isAlgebraicLattice`). No hypothesis
> beyond the ambient signature Sig is imposed.

## Stage 2 -- comparison (fresh agent, claude-sonnet-5, read-back + contract only)

> **VERDICT: equivalent**
>
> The contract asserts a single unconditional statement -- Form_Cgr(Σ) is an
> algebraic lattice, for the ambient signature Σ -- with the
> isomorphism-to-Form_Alg(Σ) sentence explicitly inactive (LaTeX-commented)
> and thus not part of what must be checked. The Lean theorem
> `congruenceFormations_isAlgebraicLattice` matches this exactly: universally
> quantified over Sig, no extra hypotheses, concluding algebraicity (every
> element is the join of the compact elements below it, with the standard
> directed-set compactness definition) of the same complete lattice structure
> (`congruenceFormationsCompleteLattice`). The proof method -- transporting
> algebraicity across `formAlgFormCgrIso` from the already-established
> algebraicity of algebra formations -- is proof strategy, not part of the
> statement, so it doesn't affect the correspondence verdict; the isomorphism
> is used internally but not asserted as part of this theorem's conclusion,
> consistent with the contract's commented-out clause being inactive. There is
> no hidden restriction on Σ (e.g., finiteness, nontriviality) on either side,
> and no quantifier mismatch (both are stated for a generic/all Σ). Hypotheses,
> quantification, and conclusion all line up one-to-one, so the formalization
> is neither stronger nor weaker than the contract -- it is equivalent.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, `E-000389` cross-model). This cross-model
run confirms the existing `equivalent` verdict (`E-000288`); no discrepancy
found.
