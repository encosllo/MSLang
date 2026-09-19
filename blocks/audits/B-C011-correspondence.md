# Correspondence audit transcript -- `B-C011`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declarations:** `Mslang.finiteAlgebraFormationsCompleteLattice`,
  `Mslang.finiteAlgebraFormations_isAlgebraicLattice`
  (`lean/Mslang/Regular.lean`); the generic carrier bridge
  `Mslang.carrierImage`, `Mslang.isAlgebraicClosureSystemOn_carrierImage`,
  `Mslang.carrierClosureOperator`, `Mslang.isAlgebraicLattice_carrierImage`,
  `Mslang.carrierOrderIso` (`lean/Mslang/Algebra.lean`).
- **Contract:** Corollary `B-C011` (under `B-A001`, `S` finite), via `B-P033`.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Fix a finite sort set `S` (`[Finite S]`) and a signature `Sig`. `Alg Sig` is
> the type of `Σ`-algebras; a `Σ`-algebra is finite when its underlying S-set is
> finite, and `algebraFinite Sig` is the set of all finite `Σ`-algebras regarded
> as the carrier `C₀`. A set `F` of `Σ`-algebras is a finite-algebra formation
> when it is an algebra formation and every member is finite;
> `finiteAlgebraFormations Sig` is the set (and the subtype) of such formations.
>
> `finiteAlgebraFormationsCompleteLattice Sig` installs a `CompleteLattice`
> instance on `finiteAlgebraFormations Sig`, obtained by transporting, across
> the order isomorphism that identifies each formation `F` with its preimage in
> the carrier `algebraFinite Sig` (preserving and reflecting inclusion), the
> complete lattice of closed sets of the closure operator attached to the
> algebraic closure system on that carrier.
> `finiteAlgebraFormations_isAlgebraicLattice Sig` asserts `IsAlgebraicLattice`
> for that instance: every element is the supremum of a set of compact elements,
> where compact means every covering by a supremum has a finite subcover.
> The only hypothesis is `[Finite S]`; it feeds the cited closure-system fact
> that `Form_Alg_f(Σ)` is closed under nonempty intersections and nonempty
> directed unions.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> Order: both use inclusion, and the read-back's order isomorphism preserves and
> reflects inclusion, so the transported lattice inherits the same order, not a
> dual. Carrier: the read-back's members all lie in `algebraFinite Sig`, exactly
> the contract's `F ⊆ Alg_f(Σ)`, not the ambient class of all `Σ`-algebras.
> Quantifiers/assumption: the only hypothesis is `[Finite S]`, corresponding
> exactly to Assumption `B-A001`; no extra side conditions are imposed.
> Content: `CompleteLattice` plus the "every element is a supremum of compact
> elements" condition is exactly "algebraic lattice" as the contract defines it.
> Degenerate cases: the empty sort set is still finite, and the closure-system
> clauses (nonempty intersections, nonempty directed unions) supply the lattice
> including bottom/top, so empty formations and empty directed families are
> covered. The only difference is packaging: the Lean split into a
> `CompleteLattice` instance and a separate algebraicness theorem.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). `[Finite S]` is
the standing assumption `B-A001`. Those residuals are inherited by this verdict;
a representation change (class C6) stales it.
