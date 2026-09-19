# Correspondence audit transcript -- `B-P033`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and definitions (no manuscript, no project
record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.algebraFinite_closed_HOperator`,
  `Mslang.algebraFinite_closed_PFsdOperator`,
  `Mslang.finiteAlgebraFormations_isAlgebraicClosureSystem`
  (`lean/Mslang/Regular.lean`); the predicate
  `Mslang.IsAlgebraicClosureSystemOnCarrier` (`lean/Mslang/Algebra.lean`).
- **Contract:** Proposition `B-P033` (under `B-A001`, `S` finite).
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> For any finite sort type `S` and signature `Sig`, the triple
> `(Alg Sig; algebraFinite Sig; finiteAlgebraFormations Sig)` satisfies
> `IsAlgebraicClosureSystemOnCarrier`. `algebraFinite Sig` is the set of finite
> `Σ`-algebras (finite disjoint union `∐A`); `finiteAlgebraFormations Sig` is
> the set of sets `F` of `Σ`-algebras closed under homomorphic images and finite
> subdirect products and with `F ⊆ algebraFinite Sig`. The four conjuncts:
> (1) `algebraFinite Sig` is itself such a formation; (2) every member is a
> subset of `algebraFinite Sig`; (3) a nonempty family of members has its
> intersection in the family; (4) a nonempty directed family of members has its
> union in the family.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> Both restrict to finite `S` and the same carrier content: the read-back's
> ambient `Alg Sig` paired with `C₀ = algebraFinite Sig`, and conjuncts (1) and
> (2), exactly reproduce the closure system on `X = Alg_f(Σ)`. The formation
> conditions (`H(F) ⊆ F`, `P_fsd(F) ⊆ F`, `F ⊆ Alg_f`), the nonempty-intersection
> clause, and the nonempty-directed-union clause match verbatim. The empty-index
> finite product boundary is handled identically (the empty subdirect product is
> the finite terminal algebra, already in `C₀`), so there is no carrier or
> membership discrepancy. `[Finite S]` is the standing assumption `B-A001`.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
