# Correspondence audit transcript -- `B-R008`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.nabla_sat_empty`, `Mslang.nabla_sat_univ`, `Mslang.nabla_sat_deltaUnion` (`lean/Mslang/Prelim.lean`)
- **Contract:** Remark `B-R008`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000326` (supersedes `E-000089`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-R008.lean`
>
> ## Setting
>
> Fix sorts `S` and a sorted set `A` (family of types `(A s)`). For a sorted equivalence `Φ`, `sat Φ X` is
> the saturation of a subobject `X` (a family `X s ⊆ A s`) and `IsSat Φ X` means `sat Φ X = X`.
> `nabla A` is the *universal (coarsest) sorted equivalence* on `A`: at every sort `s`, all elements of
> `A s` are equivalent. `suppSub X` is the support of `X`, the set of sorts `s` at which `X s` is nonempty.
> `deltaUnion T A` is the subobject that at sorts `s ∈ T` is all of `A s` and at sorts `s ∉ T` is empty.
> For the universal relation, saturation is trivial: `sat (nabla A) X` is `X` with every nonempty fiber
> filled to the whole fiber. This is captured by the cited theorem `nabla_sat`: for every `X`,
> `IsSat (nabla A) X ↔ ∀ s, s ∈ suppSub X → X s = Set.univ`.
>
> ## Theorems
>
> - **`nabla_sat_empty`**: `IsSat (nabla A) (fun s => ∅)`. The everywhere-empty subobject is saturated for
>   the universal relation. (Equivalently, its support is empty, so the condition `nabla_sat` is vacuous;
>   the proof computes `sat` directly.)
>
> - **`nabla_sat_univ`**: `IsSat (nabla A) (fun s => Set.univ)`. The everywhere-full subobject is
>   saturated. (Every nonempty fiber is already `univ`, and `sat_univ` keeps it so.)
>
> - **`nabla_sat_deltaUnion T`** (for an arbitrary set of sorts `T : Set S`): `IsSat (nabla A) (deltaUnion T A)`.
>   The subobject that is full at sorts in `T` and empty elsewhere is saturated for the universal relation.
>   Proof: invoke `nabla_sat`, take a sort `s ∈ suppSub (deltaUnion T A)`; if `s ∈ T` then the fiber is
>   `Set.univ` by definition, and if `s ∉ T` then `s` is not in the support, contradiction.
>
> ## Declarations stated without bodies in this file
>
> `IsSat`, `SSet`, `SortedEqv`, `Sub`, `nabla`, `sat` are introduced here as declarations without bodies,
> and `nabla_sat` is cited as a previously established theorem; the meanings are those described in the
> setting. Note the direction and quantifier scope of `nabla_sat`: it holds for *all* sorts `s`, with the
> hypothesis `s ∈ suppSub X` (i.e. `X s ≠ ∅`), and concludes `X s` is the entire fiber.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-R008 verdict
>
> Contract: Remark. `∅^S, A ∈ ∇^A-Sat(A)`, and for every `T ⊆ S`, `⋃_{t∈T} δ^{t,A_t} ∈ ∇^A-Sat(A)`.
>
> ## Clause-by-clause
>
> 1. **`∅^S ∈ ∇^A-Sat(A)`.** Lean `nabla_sat_empty`: `IsSat (nabla A) (fun s => ∅)`. Match.
> 2. **`A ∈ ∇^A-Sat(A)`.** Lean `nabla_sat_univ`: `IsSat (nabla A) (fun s => Set.univ)`. Match.
> 3. **`⋃_{t∈T} δ^{t,A_t} ∈ ∇^A-Sat(A)` for every `T ⊆ S`.** Lean `nabla_sat_deltaUnion T`: `IsSat (nabla A) (deltaUnion T A)`, with `deltaUnion T A` = full at `s ∈ T` and empty otherwise. Match.
>
> ## Contract clauses with no Lean counterpart:
>
> none
>
> Verdict: equivalent
> The Lean read-back proves saturation of the empty subobject, the top subobject, and the delta-union over an arbitrary set `T` of sorts for the universal relation, exactly matching the remark.

