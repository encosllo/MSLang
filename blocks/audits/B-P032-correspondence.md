# Correspondence audit transcript -- `B-P032`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and definitions; stage 2 only the
read-back and the contract.

- **Lean declarations:** `Mslang.isFiniteIndex_ker_of_finite`,
  `Mslang.finiteIndexCongruenceFormationsTop`,
  `Mslang.finiteIndexCongruenceFormationsInf`,
  `Mslang.finiteIndexCongruenceFormations_isGLB_sInf`,
  `Mslang.finiteIndexCongruenceFormationsCompleteLattice`
  (`lean/Mslang/Regular.lean`).
- **Contract:** Proposition `B-P032` (under `B-A001`, `S` finite).
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `finiteIndexCongruenceFormations Sig` is the poset of finite-index congruence
> formations `G` (each `G A` a nonempty set of finite-index congruences of
> `T_Σ(A)`, meet-closed, up-closed under refinement, kernel-closed along
> quotient-surjective homomorphisms), ordered pointwise by inclusion. The top is
> `A ↦ Cgr_fi(T_Σ(A))`. The infimum of a set `T` is `A ↦ ⋂ G ∈ insert top T, G A`
> (pointwise intersection with the top folded in), and it is the greatest lower
> bound; `finiteIndexCongruenceFormationsCompleteLattice` packages this as a
> `CompleteLattice`. Auxiliary: any sorted map into a finite `S`-set has
> finite-index kernel.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> Order (pointwise inclusion) and top (`A ↦ Cgr_fi(T_Σ(A))`) are identical. For
> nonempty `T` the inserted top is a no-op, so the formal infimum coincides with
> the manuscript's pointwise intersection; for empty `T` it gives the top, which
> is what a complete lattice forces. The smallest formation exists via
> `CompleteLattice`, and the auxiliary finite-kernel fact matches "the finiteness
> condition on the supports of the free algebras guarantees existence". No
> divergence in order, top, infimum, or boundary behaviour.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
