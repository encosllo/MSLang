# Correspondence audit transcript -- `B-C005`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and definitions; stage 2 only the
read-back and the contract.

- **Lean declarations:** `Mslang.algebraFormationsClosureOperator`,
  `Mslang.algebraFormationsCompleteLattice`,
  `Mslang.algebraFormations_isAlgebraicLattice` (`lean/Mslang/Formation.lean`);
  the generic bridge `Mslang.isAlgebraicLattice_of_isAlgebraicClosureOperator`
  (`lean/Mslang/Algebra.lean`).
- **Contract:** Corollary `B-C005` (`FormAlgAlgLat`).
- **Outcome:** `formal_weaker`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> The declarations equip `algebraFormations Sig` (formations of `Σ`-algebras,
> ordered by inclusion) with a complete lattice structure and prove it is an
> algebraic lattice: every formation is the supremum of a set of compact
> elements, compactness being the finite-subcover condition. The read-back
> states explicitly that **no characterization of which formations are compact
> is given**.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `formal_weaker`.**
>
> The contract is a conjunction: (i) `Form_Alg(Σ)` is an algebraic lattice, and
> (ii) `F` is compact iff `F = Fmg_Σ(M)` for some finite `M ⊆ Alg(Σ)`. The
> formalization supplies (i) but not (ii), and (ii) is a genuine additional
> claim (in the proof, the compact elements are `c(M)` = the formation generated
> by a finite `M`; the characterization is not stated). Missing clause (ii) makes
> the formal statement strictly weaker.

## Follow-up

The compact characterization (ii) is provable from the same construction
(`isCompact (c.toCloseds M)` for finite `M`, and conversely a compact formation
is `c(M)` for finite `M`), but was not stated in this session. It is recorded
here as an open correspondence gap rather than silently dropped.

## Residual note

The correspondence is relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`).
