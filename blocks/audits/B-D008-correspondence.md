# Correspondence audit transcript -- `B-D008`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.FiniteSSet`, `Mslang.FiniteSub`, `Mslang.finiteSubsets` (`lean/Mslang/Prelim.lean`)
- **Contract:** Definition `B-D008`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000334`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D008 read-back
>
> Fix `S : Type u`.
>
> - `SSet (S) : Type (u+1)` — abbreviation `S → Type u`, an sorted family of types.
> - `Sub {S} (A : SSet S) : Type u` — abbreviation `∀ s, Set (A s)`, a sortwise subset.
> - `FiniteSSet {S} (A : SSet S) : Prop` — definitionally `Finite (Sigma A)`. `A` is finite iff its total space `Σ s, A s` (pairs of a sort together with an element) is a finite type. Thus finiteness is measured by the disjoint union of all sorts, not sortwise.
> - `FiniteSub {S} {B} (X : Sub B) : Prop` — definitionally `Finite (Sigma fun s => {b : B s // b ∈ X s})`. `X` is a finite sub-object iff the total space of the *members of `X`* — pairs `(s, b)` with `b ∈ X s` — is finite.
> - `finiteSubsets {S} (B : SSet S) : Set (Sub B)` — definitionally `{X | FiniteSub X}`. The set of all finite sub-objects of `B`.
>
> No theorems.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D008 verdict
>
> Contract: `A` finite iff `⨿A = ⋃_s (A_s × {s})` finite; `A` finite subset of `B` iff `A` finite and `A ⊆ B`; `Sub_f(B)` = finite members of `Sub(B)`.
>
> - Clause "`A` finite iff `⨿A` finite": Lean `FiniteSSet A := Finite (Sigma A)` — total space `Σ s, A s`, the disjoint union. ✓
> - Clause "finite subset of `B`: finite and `⊆ B`": Lean `FiniteSub X := Finite (Sigma fun s => {b : B s // b ∈ X s})` — `X : Sub B` already encodes `X ⊆ B`, and finiteness is of the total space of its members (`⨿ X`). ✓
> - Clause "`Sub_f(B)`": Lean `finiteSubsets B := {X | FiniteSub X}`. ✓
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — total-space finiteness and the finite-sub-object set match the contract.

