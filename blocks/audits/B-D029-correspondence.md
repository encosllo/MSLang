# Correspondence audit transcript -- `B-D029`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsLatticeFilter`, `Mslang.latticeFilters` (`lean/Mslang/Formation.lean`)
- **Contract:** Definition `B-D029`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000353`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D029 read-back
>
> Fixed ambient data: a type `L` with a `Lattice L` instance. A "filter" is a set of
> elements of `L`.
>
> ## `IsLatticeFilter {L : Type u} [Lattice L] (F : Set L) : Prop`
>
> `IsLatticeFilter F` is the conjunction of exactly three clauses:
>
> 1. `F.Nonempty`: the set `F` is nonempty.
> 2. Meet-closure: for all `x` and `y`, if `x ∈ F` and `y ∈ F`, then `x ⊓ y ∈ F`.
>    Written `∀ x ∈ F, ∀ y ∈ F, x ⊓ y ∈ F`, so both `x` and `y` are universally
>    quantified elements of `L`; the binders for `x` and `y` are independent.
> 3. Upward closure: for all `x` and all `y : L`, if `x ∈ F` and `x ≤ y`, then
>    `y ∈ F`.
>
> In words: `F` is a nonempty subset of `L` closed under binary meet and closed
> upward under the lattice order. (This is the standard notion of a lattice filter,
> with the order `≤` and meet `⊓` those supplied by the `Lattice L` instance.)
>
> ## `latticeFilters (L : Type u) [Lattice L] : Set (Set L)`
>
> `latticeFilters L := {F | IsLatticeFilter F}`: the set of all lattice filters on
> `L`, i.e. the collection of all subsets of `L` satisfying the predicate above.
>
> ## Summary
>
> Nothing else is defined; there are no theorems, so this file fixes the notion of
> a lattice filter and the set of all such filters.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D029 clause-by-clause
>
> Contract: a lattice `L = (L,∨,∧)`; `F ⊆ L` is a filter of `L` iff:
> 1. `F ≠ ∅`.
> 2. `∀ x, y ∈ F, x ∧ y ∈ F`.
> 3. `∀ x ∈ F, ∀ y ∈ L, x ≤ y → y ∈ F`.
> Then `Filt(L)` is the set of all filters.
>
> - Clause 1 ↔ Lean `IsLatticeFilter` conjunct `F.Nonempty`. Match.
> - Clause 2 ↔ Lean `∀ x ∈ F, ∀ y ∈ F, x ⊓ y ∈ F` (binary meet-closure). Match.
> - Clause 3 ↔ Lean `∀ x, x ∈ F → ∀ y : L, x ≤ y → y ∈ F` (upward closure in the
>   `Lattice` order). Match.
> - `Filt(L)` ↔ `latticeFilters L := {F | IsLatticeFilter F}`. Match.
> - The lattice structure (`Lattice L`, supplying `⊓` and `≤`) matches
>   `(L, ∨, ∧)`; all three defining conditions are present, with no extra or dropped
>   hypotheses.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — Lean states exactly the three filter clauses (nonempty, meet-closed, upward-closed) and the set of all filters, matching the contract verbatim.

