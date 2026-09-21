# Correspondence audit transcript -- `B-D002`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.SSet`, `Mslang.SortedMap`, `Mslang.Hom`
  (`lean/Mslang/Prelim.lean`)
- **Contract:** Definition `B-D002`, section "Preliminaries".
- **Outcome:** `formal_weaker` (the definitional core is faithful; the closing
  `Set^S` category clause is not formalized)
- **Recorded as:** `E-000274`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `SSet S := S → Type u`: an `S`-sorted set is a family of types indexed by the
> sorts, `A s` being the carrier at sort `s`.
> `SortedMap A B := ∀ s, A s → B s`: an `S`-sorted mapping is a sort-preserving
> family of functions, one per sort (no cross-sort mapping).
> `Hom A B := SortedMap A B` (result type `Type u`): a transparent second name
> for the type of `S`-sorted mappings from `A` to `B`, unfolding definitionally
> to `∀ s, A s → B s`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `formal_weaker`.**
>
> The read-back matches the contract's definitional claims exactly: `SSet`
> realizes the mapping `S → U`; `SortedMap` is the element of
> `∏_s Hom(A_s, B_s)`; `Hom(A,B)` is literally denoted as the set of all sorted
> mappings. The only mismatch is the final clause: the contract's `Set^S`
> category of `S`-sorted sets and mappings has no Lean counterpart (no objects,
> morphisms, composition, or identities).
>
> **Contract clauses with no Lean counterpart:** the `Set^S` category.

## Residual note

This is the same foundational limitation as `B-C003` (the adjunction needs
category-theory infrastructure) and `B-R015` (universe bookkeeping): a
`Category` instance requires the `CategoryTheory` layer the project has not
built. The category clause is therefore a candidate for an explicit
`formalization_scope` / `scope_decisions.json` disposition rather than a Lean
repair. The definitional content of the block is faithful and machine-checked.
The record inherits the pilot-encoding residuals (`carrier-model`,
`small-large`, `univalence-missing`).
