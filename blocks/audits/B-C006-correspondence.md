# Correspondence audit transcript -- `B-C006`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declaration:** `Mslang.congruenceFormations_isAlgebraicLattice`
  (`lean/Mslang/Formation.lean`); the generic transport lemmas
  `Mslang.isCompact_of_orderIso_apply`, `Mslang.isCompact_of_orderIso`,
  `Mslang.isAlgebraicLattice_of_orderIso` (`lean/Mslang/Algebra.lean`).
- **Contract:** Corollary `B-C006` (via `B-C005` + the `B-P020` order iso).
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> For any signature `Sig`, the complete lattice of formations of
> `Σ`-congruences (ordered pointwise by inclusion) is an algebraic lattice:
> every congruence formation is the supremum of a set of compact elements. The
> proof transports the corresponding statement for `Form_Alg(Σ)` across the
> order isomorphism `formAlgFormCgrIso` (`B-P020`).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> Both assert that the pointwise-inclusion lattice of formations of
> `Σ`-congruences is algebraic. The read-back's "complete lattice" and the
> unpacking "supremum of compact elements" are the definition of algebraic
> lattice, not extra content. The contract's derivation route (via `B-C005` and
> the `B-P020` isomorphism) is proof-theoretic, not a difference in the claim.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`).
