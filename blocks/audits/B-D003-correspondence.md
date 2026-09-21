# Correspondence audit transcript -- `B-D003`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.iProd`, `Mslang.iProj`, `Mslang.iPair`,
  `Mslang.iPair_unique`, `Mslang.prod2`, `Mslang.coprod2`, `Mslang.iCoprod`,
  `Mslang.complA`, `Mslang.Sub_iUnion`, `Mslang.Sub_iInter`, `Mslang.Sub_union`,
  `Mslang.Sub_inter`, `Mslang.Sub_sdiff`
  (`lean/Mslang/Prelim.lean`, `lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D003`, section "Preliminaries".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000275`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `iProd A` is the family product, sortwise `∀ i, A i s`; `iProj A i` is the
> `i`-th projection `iProd A → A i` (sortwise evaluation at `i`); `iPair A f` is
> the pairing `B → iProd A`, sortwise `b ↦ (i ↦ f i s b)`; `iPair_unique` states
> that any `g : SortedMap B (iProd A)` with `∀ i s b,
> iProj A i s (g s b) = f i s b` equals `iPair A f`.
> `prod2 A B` and `coprod2 A B` are the binary product (`A s × B s`) and binary
> coproduct (`A s ⊕ B s`); `iCoprod A` is the family coproduct
> (`Σ i, A i s`). `complA X` is the complement of a componentwise subset inside
> `A`. `Sub_iUnion D` and `Sub_iInter D` take a set `D : Set (Sub A)` of
> componentwise subsets and return, sortwise, `⋃_{X∈D} X s` and `⋂_{X∈D} X s`;
> `Sub_union`, `Sub_inter`, `Sub_sdiff` are the binary union, intersection, and
> difference of componentwise subsets of a common `A`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> `iProd`/`iProj`/`iPair` with `iPair_unique` reproduce the contract's family
> product, its canonical projections, and the unique pairing with
> `pr^i ∘ f = f^i`. The remaining componentwise operations match one-to-one:
> `prod2`/`coprod2`/`iCoprod` for `×`/`amalg`/`coprod`, `Sub_iUnion`/`Sub_iInter`
> for `bigcup`/`bigcap`, `Sub_union`/`Sub_inter`/`Sub_sdiff` for `∪`/`∩`/`−`,
> and `complA` for `complement_A`.
>
> **Contract clauses with no Lean counterpart:** none.

## Note on ownership

This audit follows a class C5 declaration remap: `iCoprod` (from `B-R001`) and
`iPair_unique`, `prod2`, `coprod2`, `Sub_union`, `Sub_inter`, `Sub_sdiff` (new)
and `Sub_iUnion`/`Sub_iInter` (from `B-D010`/`B-D012`) are registered under
`B-D003`, the block that introduces the operations. Indexed union/intersection
are defined on componentwise subsets of a common carrier, which is the ambient
the type encoding supports (see `B-P001`).

## Residual note

The record inherits the pilot-encoding residuals (`carrier-model`,
`small-large`, `univalence-missing`).
