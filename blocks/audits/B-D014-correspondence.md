# Correspondence audit transcript -- `B-D014`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.SortedEqv`, `Mslang.sat`, `Mslang.IsSat`,
  `Mslang.quot`, `Mslang.pr`, `Mslang.eqvClass`, `Mslang.nabla`,
  `Mslang.satSets`, `Mslang.sortedEqvLe`, `Mslang.sortedEqvInf`,
  `Mslang.sortedEqv_iInf` (`lean/Mslang/Prelim.lean`)
- **Contract:** Definition `B-D014`, section "Preliminaries".
- **Outcome:** `formal_weaker` (the per-sort definitions are faithful; the
  `Eqv(A)` algebraic-lattice/closure-system claims and `Δ^A` are not formalized)
- **Recorded as:** `E-000277`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `SortedEqv A` (abbrev): a family of `Setoid`s, one on each component `A s`.
> `sat Φ X` (def): saturation of `X : Sub A` by `Φ`, sortwise
> `{a | ∃ x ∈ X s, (Φ s).r x a}`; `IsSat Φ X` (def): `sat Φ X = X`.
> `quot Φ` (def): the quotient sorted set, sortwise `Quotient (Φ s)`;
> `pr Φ s` (def): the projection `A s → Quotient (Φ s)`;
> `eqvClass Φ s a` (def): `{b | (Φ s).r a b}`.
> `nabla A` (def): the universal (greatest) sorted equivalence.
> `satSets Φ` (def): `{X | IsSat Φ X}`. `sortedEqvLe Φ Ψ` (def): pointwise
> refinement. `sortedEqvInf Φ Ψ` / `sortedEqv_iInf Φ` (defs): binary and indexed
> componentwise meets of sorted equivalences. No declaration asserts that the
> collection of sorted equivalences forms a lattice or closure system, nor
> states a top/bottom extremal property.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `formal_weaker`.**
>
> The per-sort definitions (equivalence relation, quotient `A/Φ`, projection
> `pr`, saturation `[X]^Φ`, saturatedness, `Φ-Sat(A)`, and `∇^A` as greatest)
> have faithful Lean counterparts. However, the reified set `Eqv(A)`, its
> algebraic-closure-system and algebraic-lattice structure, and the least
> element `Δ^A` have no Lean declaration.
>
> **Contract clauses with no Lean counterpart:**
> - `Eqv(A)`, the set of all `S`-sorted equivalences, as a named object.
> - `Eqv(A)` is an algebraic closure system on `A×A`.
> - `Eqv(A)` is the algebraic lattice `(Eqv(A), ⊆)`.
> - `Δ^A`, the least element of `Eqv(A)`.

## Note on ownership

This audit follows a class C5 declaration remap: `quot` (from `B-R005`),
`satSets` (from `B-R007`), and the previously unowned `pr`, `eqvClass`,
`nabla`, `sortedEqvLe`, `sortedEqvInf`, `sortedEqv_iInf` are registered under
`B-D014`, the block that introduces them. The blocked clauses are substantive
(order/lattice theory for `SortedEqv A`), not notational.

## Residual note

The record inherits the pilot-encoding residuals (`carrier-model`,
`small-large`, `univalence-missing`).
