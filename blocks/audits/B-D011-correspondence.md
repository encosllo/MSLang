# Correspondence audit transcript -- `B-D011`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsCompact`, `Mslang.IsAlgebraicLattice` (`lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D011`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000337`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D011 read-back
>
> Fix a type `L` with a `CompleteLattice L` instance (so `≤`, `sSup`, and arbitrary joins exist).
>
> - `IsCompact (a : L) : Prop` — definitionally
>   `∀ X : Set L, a ≤ sSup X → ∃ Y : Set L, Y ⊆ X ∧ Y.Finite ∧ a ≤ sSup Y`.
>   `a` is **compact** iff for every set `X` whose supremum dominates `a`, there is a *finite* subset `Y ⊆ X` whose supremum already dominates `a`. (This is the standard order-theoretic compactness / finite-subcover property, relativized to order.)
>
> - `IsAlgebraicLattice (L) : Prop` — definitionally
>   `∀ a : L, ∃ X : Set L, (∀ x ∈ X, IsCompact x) ∧ a = sSup X`.
>   `L` is **algebraic** iff every element `a` is the supremum of some set `X` of compact elements. Equivalently (not proven here) each `a` is the join of the compact elements below it.
>
> No theorems; the standard equivalence with "join of compacts below" is not asserted.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D011 verdict
>
> Contract: in a complete lattice `L`, `a` compact if `a ≤ ⋁X ⇒ ∃` finite `Y ⊆ X` with `a ≤ ⋁Y`; `K(L)` = compact elements; `L` algebraic if every `a` is `⋁X` for some `X ⊆ K(L)`.
>
> - Clause "compactness": Lean `IsCompact a := ∀ X, a ≤ sSup X → ∃ Y, Y ⊆ X ∧ Y.Finite ∧ a ≤ sSup Y`. ✓
> - Clause "`K(L)` = compact elements": captured by `IsCompact` (used in `IsAlgebraicLattice`); no separate set literal, which is immaterial. ✓
> - Clause "algebraic lattice": Lean `IsAlgebraicLattice L := ∀ a, ∃ X, (∀ x ∈ X, IsCompact x) ∧ a = sSup X`. ✓
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — compactness and algebraicity match the contract exactly.

