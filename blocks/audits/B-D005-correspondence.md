# Correspondence audit transcript -- `B-D005`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.Sub`, `Mslang.Subset` (`lean/Mslang/Prelim.lean`)
- **Contract:** Definition `B-D005`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000332`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D005 read-back
>
> Fix `S : Type u`.
>
> - `SSet (S : Type u) : Type (u+1)` — abbreviation for `S → Type u`. An `S`-sorted set (an `S`-indexed family of types). For each `s : S`, `A s : Type u` is the type of elements of sort `s`.
> - `Sub {S} (A : SSet S) : Type u` — abbreviation for `∀ s, Set (A s)`. A sub-object of a sorted set `A`: a choice, for each sort `s`, of a subset `X s ⊆ A s`. (Universe note: declared `Type u` though `Set (A s)` lives in `Type u`, so this is the type of a dependent function into `Type u`.)
> - `Subset {S} {A : SSet S} (X Y : Sub A) : Prop` — definitionally `∀ s, X s ⊆ Y s`. `X` is contained in `Y` iff for every sort `s`, every `a ∈ X s` is in `Y s`. Note: it is a *sortwise* inclusion, not a pointwise one across all sorts at once.
>
> No theorems; the content is entirely the two abbreviations `SSet`, `Sub` and the relation `Subset`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D005 verdict
>
> Contract: `A ⊆ B` iff for every `s ∈ S`, `A_s ⊆ B_s`; `Sub(A)` = all `S`-sorted sets `X` with `X ⊆ A`.
>
> - Clause "`A ⊆ B` iff `∀ s, A_s ⊆ B_s`": Lean `Subset X Y := ∀ s, X s ⊆ Y s`. ✓
> - Clause "`Sub(A)` = `{X | X ⊆ A}`": Lean `Sub A := ∀ s, Set (A s)`, i.e. sortwise subsets of `A`, each automatically satisfying `X ⊆ A`. ✓
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — sortwise inclusion and the type of sortwise subsets of `A` match the contract exactly.

