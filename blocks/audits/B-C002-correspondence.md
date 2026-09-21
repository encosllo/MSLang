# Correspondence audit transcript -- `B-C002`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.sat_inf` (`lean/Mslang/Prelim.lean`)
- **Contract:** Corollary `B-C002`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000286` (supersedes `E-000084`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of B-C002.lean
>
> ## Ambient setting
>
> Fix a type `S`. An `SSet S` is a structure `A` giving a fiber `A s` for each index `s : S`. A `Sub A` is a sorted subset, i.e. a family of subsets `X s ⊆ A s`. A `SortedEqv A` is a sorted equivalence: a family `Φ` of equivalence relations, one on each fiber `A s`, written `Φ s x y`. The opaque definitions reused here are:
>
> - `sat Φ X`: the saturation of `X` by `Φ`, so that `a ∈ sat Φ X s` iff some `x ∈ X s` satisfies `Φ s x a`.
> - `IsSat Φ X`: `X` is saturated by `Φ`, i.e. `sat Φ X = X` pointwise.
> - `sortedEqvLe Φ Ψ`: the preorder on sorted equivalences, meaning pointwise relation-inclusion: `Φ s x y → Ψ s x y` for all `s, x, y`.
> - `sortedEqvInf Φ Ψ`: the binary infimum (meet) of `Φ` and `Ψ` in this preorder.
> - `sortedEqvInf_le_left Φ Ψ`: the left projection of the meet, i.e. `sortedEqvLe (sortedEqvInf Φ Ψ) Φ` (the meet is below / finer than `Φ`). This is used as a previously established fact.
>
> The file also restates the theorem `sat_antitone`: if `Φ ≤ Ψ` and `X` is `Ψ`-saturated then `X` is `Φ`-saturated.
>
> ## The theorem: `sat_inf`
>
> Statement. For any `S`, any `A : SSet S`, any sorted equivalences `Φ`, `Ψ`, and any sorted subset `X : Sub A`, if `hΦ` asserts `IsSat Φ X` and `hΨ` asserts `IsSat Ψ X`, then `IsSat (sortedEqvInf Φ Ψ) X` holds.
>
> Quantifier scoping. `S`, `A`, `Φ`, `Ψ`, `X` are all fixed as parameters; the result is the implication `IsSat Φ X → IsSat Ψ X → IsSat (sortedEqvInf Φ Ψ) X`. The hypothesis `hΨ` is *not used* in the proof (it is named with a leading underscore, marking it as deliberately unused). The theorem remains valid with only `hΦ`.
>
> ## How the proof proceeds (informal content)
>
> By `sortedEqvInf_le_left`, the meet `sortedEqvInf Φ Ψ` is below `Φ` in the refinement order. Apply `sat_antitone` with `h := sortedEqvInf_le_left Φ Ψ` to the hypothesis `hΦ : IsSat Φ X`: since `X` is saturated by `Φ` and the meet is finer than `Φ`, `X` is saturated by the meet. Hence `IsSat (sortedEqvInf Φ Ψ) X`.
>
> ## Summary
>
> B-C002 says that the infimum (meet) of two sorted equivalences still saturates any set that is saturated by one of them; because the meet is finer than each factor, antitonicity of saturation gives the result. The second saturation hypothesis is stated but mathematically redundant.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-C002 verdict
>
> ## Clause-by-clause
>
> 1. **Ambient data** — Contract: `A` an `S`-sorted set, `Φ, Ψ ∈ Eqv(A)`. Lean: `S`, `A : SSet S`, `Φ Ψ : SortedEqv A`. Faithful.
> 2. **Object `Φ ∩ Ψ`** — Contract: the pointwise intersection of the two equivalence relations (the meet of `Φ, Ψ` in the refinement order). Lean: `sortedEqvInf Φ Ψ`, read-back states it is the binary infimum in the preorder of pointwise relation-inclusion. In that order the infimum is pointwise relation intersection, so `Φ ∩ Ψ` is matched. Faithful.
> 3. **Left side** — Contract: `Φ-Sat(A) ∩ Ψ-Sat(A)`, the collection of subsets saturated by both, i.e. `X` with `IsSat Φ X` and `IsSat Ψ X`. Lean hypotheses: `hΦ : IsSat Φ X` and `hΨ : IsSat Ψ X`, both present in the statement. Faithful.
> 4. **Conclusion** — Contract: `(Φ∩Ψ)-Sat(A)`, i.e. `IsSat (Φ∩Ψ) X`. Lean conclusion: `IsSat (sortedEqvInf Φ Ψ) X`. Faithful.
> 5. **Shape** — Contract asserts containment of collections; Lean asserts the corresponding pointwise implication over `X`. The Lean proof uses only `hΦ` (the `hΨ` hypothesis is named `_hΨ`), but the *statement* still carries both hypotheses, so no hypothesis is dropped from the contract.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the statement `IsSat Φ X → IsSat Ψ X → IsSat (sortedEqvInf Φ Ψ) X` is exactly the membership form of `Φ-Sat(A) ∩ Ψ-Sat(A) ⊆ (Φ∩Ψ)-Sat(A)`; the unused second hypothesis is a proof economy, not a change to the claimed proposition.

