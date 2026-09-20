# Correspondence audit transcript -- `B-C012`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declaration:** `Mslang.finiteIndexCongruenceFormations_isAlgebraicLattice`
  (`lean/Mslang/Regular.lean`); the transported source
  `Mslang.finiteAlgebraFormations_isAlgebraicLattice` and the order isomorphism
  `Mslang.formAlgFFormCgrFiIso` (`B-P034`).
- **Contract:** Corollary `B-C012` (`FormCgrfiAlg`, under `B-A001`, `S` finite),
  via `B-P032` and `B-P034`.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Fix a signature `Sig` over a sort set `S`. An element of
> `finiteIndexCongruenceFormations Sig` is a function `G` assigning to each
> `A : SSet S` a set `G A` of sorted equivalences on the term algebra
> `Term Sig A` such that `G` is a congruence formation (nonempty filter closed
> under binary meet, up-closed under refinement, and closed under pullback of
> kernels along `Θ`-epimorphisms) and `G A ⊆ Cgr_fi(T_Σ(A))` for every `A`.
> The order is pointwise inclusion: `G ≤ H` iff `∀ A, G A ⊆ H A`.
> `finiteAlgebraFormations Sig` is the analogous subtype of formations of finite
> `Σ`-algebras, and `formAlgFFormCgrFiIso Sig` is an order isomorphism between
> the two.
>
> The only hypothesis is `[Finite S]` and `Sig : Signature S`.
> `finiteIndexCongruenceFormations_isAlgebraicLattice` asserts
> `IsAlgebraicLattice` for the instance
> `finiteIndexCongruenceFormationsCompleteLattice` (infimum = pointwise
> intersection, with a top formation): every element is the supremum of some set
> of compact elements, where compact means every covering by a supremum has a
> finite subcover. The theorem is obtained by transporting the corresponding
> result for finite algebra formations across the order isomorphism.
> The packaging splits the `CompleteLattice` structure into a separate instance
> and the algebraicness into a separate `Prop`-valued theorem.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> Carrier: both are functions from algebras to sets of congruences of the term
> algebra, subject to being a congruence formation and contained in the
> finite-index congruences; the formal `G A ⊆ Cgr_fi(T_Σ(A))` matches the
> contract's `𝔉(A) ⊆ Cgr_fi(T_Σ(A))`. Order: pointwise inclusion in both.
> Hypotheses: both assume exactly `[Finite S]` and a signature, no extra side
> conditions. Conclusion: `IsAlgebraicLattice` (every element is the sup of
> compact elements) with the separate complete-lattice instance is exactly the
> contract's "complete lattice in which every element is the join of compact
> elements"; infimum = pointwise intersection is an ordinary consequence, not an
> added assumption. Degenerate cases: the bottom as the supremum of the empty
> set of compact elements is covered identically. No added assumptions, no
> weakened conclusion, same domain and order; the only difference is packaging.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). `[Finite S]` is
the standing assumption `B-A001`. Those residuals are inherited by this verdict;
a representation change (class C6) stales it.
