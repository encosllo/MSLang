# Correspondence audit transcript -- `B-P014`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and definitions; stage 2 only the
read-back and the contract.

- **Lean declarations:** `Mslang.congruenceFormationsTop`,
  `Mslang.congruenceFormationsInf`, `Mslang.congruenceFormations_isGLB_sInf`,
  `Mslang.congruenceFormationsCompleteLattice` (`lean/Mslang/Formation.lean`).
- **Contract:** Proposition `B-P014`.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `congruenceFormations Sig` is the type of congruence formations `F` (each
> `F A` a nonempty set of congruences on `T_Σ(A)`, closed under pointwise meet,
> up-closed under refinement, closed under kernels of quotient-surjective
> homomorphisms). The order is pointwise inclusion `F A ⊆ G A`.
> `congruenceFormationsTop Sig` sends `A` to the set of all congruences on
> `T_Σ(A)`. `congruenceFormationsInf Sig T` sends `A` to the pointwise
> intersection of the members of `T` together with the all-congruences formation
> (top inserted so the family is nonempty). The theorem says this is the greatest
> lower bound of `T`; `congruenceFormationsCompleteLattice` packages the order,
> top, and arbitrary infima into a `CompleteLattice`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> Order (pointwise inclusion) and top (all-congruences formation) agree. The
> formal infimum intersects the family together with the top formation, which
> reduces to the manuscript's pointwise intersection `⋂_j 𝔉_j(A)` for nonempty
> families and gives the top for the empty family, matching the complete-lattice
> semantics. The least upper bounds (meet of the upper bounds) and the derived
> smallest formation `{∇}` match as well. No strength or boundary discrepancy.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
