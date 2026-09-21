# Correspondence audit transcript -- `B-D007`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.directImage`, `Mslang.inverseImage` (`lean/Mslang/Prelim.lean`)
- **Contract:** Definition `B-D007`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000333`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D007 read-back
>
> Fix `S : Type u`.
>
> - `SSet (S) : Type (u+1)` — abbreviation for `S → Type u`; an `S`-sorted family of types.
> - `Sub {S} (A : SSet S) : Type u` — abbreviation for `∀ s, Set (A s)`; a sortwise subset of `A`.
> - `SortedMap {S} (A B : SSet S)` — abbreviation for `∀ s, A s → B s`. A *sort-preserving* map: for each sort `s`, a function `A s → B s`. It maps elements of sort `s` to elements of the same sort `s` (no reindexing of sorts).
>
> - `directImage {S} {A B} (f : SortedMap A B) (X : Sub A) : Sub B` — definitionally `fun s => f s '' X s`. The sortwise image: at each sort `s`, the image of `X s` under `f s`; i.e. `b ∈ directImage f X s ↔ ∃ a ∈ X s, f s a = b`.
> - `inverseImage {S} {A B} (f : SortedMap A B) (Y : Sub B) : Sub A` — definitionally `fun s => f s ⁻¹' Y s`. The sortwise preimage: at each sort `s`, the preimage of `Y s` under `f s`; i.e. `a ∈ inverseImage f Y s ↔ f s a ∈ Y s`.
>
> No theorems. Both images are *sortwise* (they act at each sort independently).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D007 verdict
>
> Contract: for `f : A → B`, direct image `f[X] = (f_s[X_s])_s` and inverse image `f^{-1}[Y] = (f_s^{-1}[Y_s])_s`.
>
> - Clause "`f[·] : Sub(A) → Sub(B)`, `f[X] = (f_s[X_s])_s`": Lean `directImage f X := fun s => f s '' X s`. ✓
> - Clause "`f^{-1}[·] : Sub(B) → Sub(A)`, `f^{-1}[Y] = (f_s^{-1}[Y_s])_s`": Lean `inverseImage f Y := fun s => f s ⁻¹' Y s`. ✓
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — both sortwise image formations match the contract clause for clause.

