# Correspondence audit transcript -- `B-C011` (cross-model, mixed)

Protocol: Architecture.md Section 11.2, two-stage blind, per the cross-model
audit brief's Section 6 ingestion pattern. Stage 1 reuses the existing
`deepseek-v4.1-flash` read-back verbatim (from
`blocks/audits/B-C011-correspondence.md`). Stage 2 is a fresh, isolated
`claude-sonnet-5` agent given the stage-1 read-back and the contract,
including the standing Assumption `B-A001` (`S` finite) that governs this
block -- explicitly instructed not to treat an ambient assumption as absent
merely because it is not restated locally (the lesson from the `B-P034`
self-correction in Session 122). No repo access, no expected answer.

- **Lean declarations:** `Mslang.finiteAlgebraFormationsCompleteLattice`,
  `Mslang.finiteAlgebraFormations_isAlgebraicLattice`
  (`lean/Mslang/Regular.lean`); the generic carrier bridge
  `Mslang.carrierImage`, `Mslang.isAlgebraicClosureSystemOn_carrierImage`,
  `Mslang.carrierClosureOperator`, `Mslang.isAlgebraicLattice_carrierImage`,
  `Mslang.carrierOrderIso` (`lean/Mslang/Algebra.lean`).
- **Contract:** Corollary `B-C011` (under standing Assumption `B-A001`, `S` finite).
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** stage 1 ran on `deepseek-v4.1-flash`, stage 2 on
  `claude-sonnet-5` -- distinct model families (`deepseek`, `claude`).

## Stage 1 -- read-back (reused verbatim, deepseek-v4.1-flash, Lean only)

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

## Stage 2 -- comparison (fresh agent, claude-sonnet-5, read-back + contract only)

> **VERDICT: equivalent**
>
> The contract's ambient hypothesis (S finite, inherited from the standing
> section-wide Assumption) matches exactly the Lean hypothesis [Finite S] on
> `finiteAlgebraFormations_isAlgebraicLattice`. The contract's conclusion --
> that Form_Alg_f(Σ), the lattice of finite-algebra formations, is an
> algebraic lattice -- matches the Lean statement's assertion of
> `IsAlgebraicLattice` for the `CompleteLattice` instance on
> `finiteAlgebraFormations Sig`, which is precisely the formalized carrier for
> finite-algebra formations. The read-back confirms this lattice structure and
> its algebraicity are obtained by transport along an order isomorphism to
> closed sets of the closure operator on the finite-algebra carrier, using
> exactly the closure-system fact (closed under nonempty intersections and
> nonempty directed unions) that the finiteness of S is needed for -- the same
> fact underlying the informal corollary in this section. No extra hypotheses
> are added and no weaker conclusion is drawn on the Lean side; the object
> quantified over (compact elements, arbitrary suprema) matches the standard
> definition of algebraic lattice used informally. Both sides state the same
> theorem under the same standing/local hypothesis with no degenerate-case
> mismatch (S finite is required and used identically on both sides).

## Source verification (coordinator)

Unlike `B-P034`'s sibling declaration `formAlgFFormCgrFiIso`, the two
declarations backing this block (`finiteAlgebraFormationsCompleteLattice`,
`finiteAlgebraFormations_isAlgebraicLattice` in `lean/Mslang/Regular.lean`)
both carry an explicit `[Finite S]` instance argument, matching Assumption
`B-A001`. No gap of the `B-P034` kind here.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, `E-000389` cross-model). `[Finite S]` is
the standing assumption `B-A001`, correctly carried by both stages. This
cross-model run confirms the existing `equivalent` verdict (`E-000228`); no
discrepancy found.
