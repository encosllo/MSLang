# Correspondence audit transcript -- `B-C005` (cross-model, mixed)

Protocol: Architecture.md Section 11.2, two-stage blind, per the cross-model
audit brief's Section 6 ingestion pattern. Stage 1 reuses the existing
Session-119 `deepseek-v4.1-flash` read-back verbatim (unchanged from
`blocks/audits/B-C005-correspondence.md`). Stage 2 is a fresh,
isolated `claude-sonnet-5` agent given only the stage-1 read-back and the
contract -- no repo access, no expected answer.

- **Lean declarations:** `Mslang.algebraFormationsClosureOperator`,
  `Mslang.algebraFormationsCompleteLattice`,
  `Mslang.algebraFormations_isAlgebraicLattice`, `Mslang.algebraFormations_isCompact_iff`
  (`lean/Mslang/Formation.lean`); the generic lemmas
  `Mslang.closure_finite_character`, `Mslang.closure_finite_compact`,
  `Mslang.closure_sSup_finite`, `Mslang.isAlgebraicLattice_of_isAlgebraicClosureOperator`,
  `Mslang.isCompact_iff_exists_finite_closure` (`lean/Mslang/Algebra.lean`).
- **Contract:** Corollary `B-C005` (`FormAlgAlgLat`), both clauses.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** stage 1 ran on `deepseek-v4.1-flash`, stage 2 on
  `claude-sonnet-5` -- distinct model families (`deepseek`, `claude`).

## Stage 1 -- read-back (reused verbatim, deepseek-v4.1-flash, Lean only)

> The complete lattice of formations of `Σ`-algebras (ordered by inclusion,
> joins given by the closure operator) is algebraic: every formation is the
> supremum of a set of compact elements. Moreover, a formation `F` is compact if
> and only if it is finitely generated: there is a finite set `M` of
> `Σ`-algebras whose closure (least formation containing `M`, closed under `H`
> and `P_fsd`) is exactly `F` -- i.e. `F = Fmg_Σ(M)` for some finite `M`; and
> conversely any such finitely generated formation is compact.

## Stage 2 -- comparison (fresh agent, claude-sonnet-5, read-back + contract only)

> **VERDICT: equivalent**
>
> Both statements assert the same two-part claim: (1) the lattice of
> formations of Σ-algebras is algebraic, and (2) for every formation F, F is
> compact iff there is a finite set M of Σ-algebras with F = Fmg_Σ(M) (the
> least formation containing M, closed under H and P_fsd). The read-back's
> quantifier structure ("a formation F is compact if and only if it is
> finitely generated... and conversely") matches the contract's "for every
> formation F, F is compact if and only if there exists a finite subset M of
> Alg(Σ) such that F = Fmg_Σ(M)" -- same universal quantification over F, same
> existential over finite M, same biconditional, same witnessing closure
> operator Fmg_Σ. No asymmetry in hypotheses or conclusions in either
> direction, so neither is stronger/weaker. The inactive, commented-out remark
> about directed joins in the LaTeX source is explicitly not part of the
> active contract and so is correctly irrelevant to the comparison. No
> degenerate-case discrepancies (e.g., trivial/empty formation) are introduced
> by either formulation's phrasing.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, `E-000389` cross-model). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
This cross-model run confirms the existing `equivalent` verdict
(`E-000224`); no discrepancy found.
