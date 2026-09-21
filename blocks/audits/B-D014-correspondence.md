# Correspondence audit transcript -- `B-D014`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.SortedEqv`, `Mslang.sat`, `Mslang.IsSat`,
  `Mslang.quot`, `Mslang.pr`, `Mslang.eqvClass`, `Mslang.nabla`,
  `Mslang.satSets`, `Mslang.sortedEqvLe`, `Mslang.sortedEqvInf`,
  `Mslang.sortedEqv_iInf`, `Mslang.deltaEqv`, `Mslang.le_nabla`,
  `Mslang.deltaEqv_le`, `Mslang.PairSpace`, `Mslang.EqvOn`,
  `Mslang.univ_mem_EqvOn`, `Mslang.sInter_mem_EqvOn`, `Mslang.sUnion_mem_EqvOn`,
  `Mslang.eqvToSet`, `Mslang.eqvToSet_mem_EqvOn`, `Mslang.setToEqv`,
  `Mslang.eqvToSet_subset_iff`, `Mslang.EqvOn_isAlgebraicClosureSystemOn`,
  `Mslang.eqvClosureOperator`, `Mslang.eqvClosedSets_isAlgebraicLattice`,
  `Mslang.eqvOrderIso`, `Mslang.SortedEqv_isAlgebraicLattice`
  (`lean/Mslang/Prelim.lean`, `lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D014`, section "Preliminaries".
- **Outcome:** `equivalent` (re-run in Session 119 after the `Eqv(A)` structure
  was formalized; supersedes the Session 118 `formal_weaker` verdict)
- **Recorded as:** `E-000279` (supersedes `E-000277`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `SortedEqv A` is a family of `Setoid`s, one on each component `A s`;
> `sortedEqvLe Φ Ψ` is pointwise refinement (`Φ` finer than `Ψ`). `sat Φ X` is
> the sortwise union of `Φ`-classes meeting `X`; `IsSat Φ X` is `sat Φ X = X`;
> `satSets Φ` collects the `Φ`-saturated sub-sorted-sets. `nabla A` is the
> universal sorted equivalence and `deltaEqv A` the equality one. `quot Φ`,
> `pr Φ s`, and `eqvClass Φ s a` are the quotient sorted set, the quotient map,
> and the ordinary class. `sortedEqvInf`/`sortedEqv_iInf` are the pointwise
> binary/indexed conjunctions.
>
> `PairSpace A = Σ s, A s × A s`. `EqvOn A` is the set of pair-sets whose
> per-sort relation is an equivalence, i.e. the graphs of sorted equivalences;
> `eqvToSet` and `setToEqv` are the two directions of that identification, and
> `eqvToSet_subset_iff` makes them an order isomorphism.
>
> Asserted: `nabla` is greatest (`le_nabla`) and `deltaEqv` least
> (`deltaEqv_le`); `EqvOn A` contains the whole space and is closed under
> arbitrary intersections (empty included) and under directed unions of nonempty
> families (`EqvOn_isAlgebraicClosureSystemOn`), hence is an algebraic closure
> system on `PairSpace A`; its closed sets form an algebraic lattice
> (`eqvClosedSets_isAlgebraicLattice`); and `SortedEqv A` under refinement is an
> algebraic lattice (`SortedEqv_isAlgebraicLattice`, via `eqvOrderIso`).
> Conspicuously not asserted: an explicit join construction, lemmas identifying
> `sortedEqvInf`/`iInf` as the actual infima, non-directed-union closure,
> order lemmas for `sortedEqvLe`, or properties of `quot`/`pr` beyond their
> definitions.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The per-sort definitions (sorted equivalence, quotient `A/Φ`, projection `pr`,
> saturation `[X]^Φ`, saturatedness, `Φ-Sat(A)`) have faithful Lean
> counterparts. `Eqv(A)` is exactly `EqvOn A` under the standard Σ-encoding of
> the sorted product `A×A`, and `EqvOn_isAlgebraicClosureSystemOn` is the
> contract's "algebraic closure system on `A×A`". `eqvOrderIso` +
> `eqvToSet_subset_iff` transport inclusion to refinement, so
> `SortedEqv_isAlgebraicLattice` is the contract's algebraic lattice
> `(Eqv(A), ⊆)`. `nabla`/`deltaEqv` with `le_nabla`/`deltaEqv_le` are the
> greatest/least elements `∇^A`/`Δ^A`.
>
> The items the read-back flags as absent (join construction, infima
> identification, order lemmas, quotient properties) are not clauses of this
> contract; the contract asserts only the closure-system/lattice structure, the
> extremal elements, the quotient/projection definition, and saturation.
>
> **Contract clauses with no Lean counterpart:** none.

## Note (Session 119 re-run)

This supersedes the Session 118 audit, whose declaration set stopped at
`sortedEqv_iInf` and therefore returned `formal_weaker`: the `Eqv(A)` closure
system, the algebraic lattice, and `Δ^A` were then unmapped. Session 119
formalized them (`EqvOn`, `EqvOn_isAlgebraicClosureSystemOn`,
`eqvOrderIso`, `SortedEqv_isAlgebraicLattice`, `deltaEqv`, `le_nabla`,
`deltaEqv_le`), and the re-run returns `equivalent`.

## Residual note

The record inherits the pilot-encoding residuals (`carrier-model`,
`small-large`, `univalence-missing`).
