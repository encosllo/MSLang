# Correspondence audit transcript -- `B-D002` (cross-model, mixed)

Protocol: Architecture.md Section 11.2, two-stage blind, per the cross-model
audit brief's Tier 4 and Section 6 ingestion pattern. Stage 1 reuses the
existing `deepseek-v4.1-flash` read-back verbatim (from
`blocks/audits/B-D002-correspondence.md`). Stage 2 is a fresh, isolated
`claude-sonnet-5` agent given the stage-1 read-back and the full manuscript
contract text -- no repo access, no expected answer.

- **Lean declarations:** `Mslang.SSet`, `Mslang.SortedMap`, `Mslang.Hom`
  (`lean/Mslang/Prelim.lean`)
- **Contract:** Definition `B-D002`, section "Preliminaries".
- **Outcome:** `formal_weaker` -- confirmed (the definitional core is
  faithful; the closing `Set^S` category clause is not formalized).
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** stage 1 ran on `deepseek-v4.1-flash`, stage 2 on
  `claude-sonnet-5` -- distinct model families.

## Stage 1 -- read-back (reused verbatim, deepseek-v4.1-flash, Lean only)

> `SSet S := S → Type u`: an `S`-sorted set is a family of types indexed by
> the sorts, `A s` being the carrier at sort `s`.
> `SortedMap A B := ∀ s, A s → B s`: an `S`-sorted mapping is a
> sort-preserving family of functions, one per sort (no cross-sort mapping).
> `Hom A B := SortedMap A B` (result type `Type u`): a transparent second
> name for the type of `S`-sorted mappings from `A` to `B`, unfolding
> definitionally to `∀ s, A s → B s`.
>
> There is no Lean declaration of a `Category` instance (objects, morphisms,
> identities, composition, and the category laws) for `S`-sorted sets and
> mappings anywhere in the file or its dependencies.

## Stage 2 -- comparison (fresh agent, claude-sonnet-5, read-back + full contract)

> **VERDICT: formal_weaker**
>
> The data-level definitions line up: `SSet S := S → Type u` matches "an
> S-sorted set is a mapping A from S to a universe," and `SortedMap A B :=
> ∀ s, A s → B s` matches "an S-indexed family f where f_s : A_s → B_s,"
> definitionally the same shape as the contract's `Π_{s∈S} Hom(A_s,B_s)`.
> `Hom A B := SortedMap A B` matches the contract's naming of `Hom(A,B)`.
> However, the contract's final sentence -- "`Set^S` stands for the category
> of `S`-sorted sets and `S`-sorted mappings" -- asserts categorical
> structure: identities, composition, and the associativity/unit laws. The
> read-back confirms no `Category` instance exists anywhere in the file or
> its dependencies. That clause has no Lean counterpart at all, so the
> formalization captures strictly less than the contract asserts.

## Coordinator note

Re-confirms the existing same-model verdict (`E-000274`) with an independent
model family; same gap identified (the `Set^S` category clause).
