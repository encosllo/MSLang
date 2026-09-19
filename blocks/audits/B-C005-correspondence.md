# Correspondence audit transcript -- `B-C005`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and definitions; stage 2 only the
read-back and the contract.

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
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Round 1 (superseded)

The first audit (recorded in the superseded `E-000222`) covered only
`algebraFormations_isAlgebraicLattice`. With the corollary's parenthetical
compact characterization omitted, it returned `formal_weaker`. It is retained in
the superseded record as evidence of the review-queue signal.

## Stage 1 -- read-back (fresh agent, Lean only)

> The complete lattice of formations of `Σ`-algebras (ordered by inclusion,
> joins given by the closure operator) is algebraic: every formation is the
> supremum of a set of compact elements. Moreover, a formation `F` is compact if
> and only if it is finitely generated: there is a finite set `M` of
> `Σ`-algebras whose closure (least formation containing `M`, closed under `H`
> and `P_fsd`) is exactly `F` -- i.e. `F = Fmg_Σ(M)` for some finite `M`; and
> conversely any such finitely generated formation is compact.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> Both assert the same two facts: `Form_Alg(Σ)` is algebraic, and compactness of
> `F` coincides with finite generation `F = Fmg_Σ(M)` for finite `M`. The
> read-back's gloss that `Fmg_Σ(M)` is the least formation containing `M` is a
> consistent unpacking, not a stronger or weaker claim. No divergence in
> content, direction, or well-posedness.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
