# Correspondence audit transcript -- `B-P002`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.prop_incSat` (`lean/Mslang/Prelim.lean`)
- **Contract:** Proposition `B-P002`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000295` (supersedes `E-000086`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of B-P002.lean
>
> ## Ambient setting
>
> Fix a type `S`. An `SSet S` assigns to each `s : S` a fiber `A s`. A `Sub A` is a sorted subset: a family with `X s ⊆ A s` for each `s`. A `SortedEqv A` is a sorted equivalence: a family `Φ` of equivalence relations `Φ s` on the fibers. The opaque definitions used are:
>
> - `sat Φ X`: the saturation of `X` by the relation `Φ`, so `a ∈ sat Φ X s` iff there exists `x ∈ X s` with `Φ s x a`.
> - `sortedEqvLe Φ Ψ`: the preorder on sorted equivalences, meaning the pointwise relation-inclusion `Φ s x y → Ψ s x y` (i.e. `Φ` is finer than `Ψ`).
> - `sat_sat_eq h X`: a previously established fact stating that if `h : sortedEqvLe Φ Ψ` then `sat Φ (sat Ψ X) = sat Ψ X`; i.e. every `Ψ`-saturation is already `Φ`-saturated.
>
> Note that `IsSat Φ (sat Ψ X)` is by definition exactly the equation `sat Φ (sat Ψ X) = sat Ψ X`, so the condition on the right-hand side below says precisely that every saturation `sat Ψ X` is saturated by `Φ`.
>
> ## The theorem: `prop_incSat`
>
> Statement. For any `S`, any `A : SSet S`, and any two sorted equivalences `Φ, Ψ : SortedEqv A`,
>
> > `sortedEqvLe Φ Ψ` if and only if `∀ X : Sub A, sat Φ (sat Ψ X) = sat Ψ X`.
>
> Quantifier scoping. `S`, `A`, `Φ`, `Ψ` are fixed parameters. The equivalence (iff) has two directions:
>
> - (⇒) Assume `sortedEqvLe Φ Ψ`. Then for *every* sorted subset `X`, the double saturation `sat Φ (sat Ψ X)` equals `sat Ψ X`. Direction of traversal: saturating first by the coarser `Ψ` and then by the finer `Φ` adds nothing.
> - (⇐) Conversely, assume that for *every* sorted subset `X`, `sat Φ (sat Ψ X) = sat Ψ X`. Then `sortedEqvLe Φ Ψ` holds, i.e. for all `s : S` and all `x, y : A s`, `Φ s x y` implies `Ψ s x y`.
>
> So the preorder `sortedEqvLe` is completely characterized by a *single* universal property about saturation of all sorted subsets: "`Φ`-closure is absorbed by `Ψ`-closure".
>
> ## How the proof proceeds (informal content)
>
> Forward direction: immediate from the cited fact `sat_sat_eq`.
>
> Backward direction: assume the saturation-absorption property for all `X`; we must show `Φ s x y → Ψ s x y`. Fix `s, x, y` with `Φ s x y`. Build the test subset `X` that is empty in every fiber except at `s`, where `X s = {x}` (in Lean, `Function.update (fun t => ∅) s {x}`). Then:
>
> 1. `X s = {x}`, so `x ∈ sat Ψ X s` using the reflexive witness `x`.
> 2. Since `Φ s x y`, we get `y ∈ sat Φ (sat Ψ X) s` (witness `x`, which is in `sat Ψ X s`, related to `y`).
> 3. Applying the assumed equation `h X` at sort `s` rewrites `y ∈ sat Φ (sat Ψ X) s` into `y ∈ sat Ψ X s`, i.e. there is `z ∈ X s` with `Ψ s z y`.
> 4. Since `X s = {x}`, necessarily `z = x`, yielding `Ψ s x y`.
>
> ## Summary
>
> B-P002 is a *characterization theorem*: the refinement order on sorted equivalences is equivalent to the statement that saturating by `Ψ` already produces sets closed under `Φ`. The reverse direction is extracted by a singleton probe concentrated at a single sort.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P002 verdict
>
> ## Clause-by-clause
>
> 1. **Ambient data** — Contract: `A` an `S`-sorted set, `Φ, Ψ ∈ Eqv(A)`. Lean: `S`, `A : SSet S`, `Φ Ψ : SortedEqv A`. Faithful.
> 2. **Left of iff** — Contract: `Φ ⊆ Ψ`. Lean: `sortedEqvLe Φ Ψ`, read-back pins this as pointwise `Φ s x y → Ψ s x y`. Faithful.
> 3. **Right of iff** — Contract: `∀ X ⊆ A, ([X]^Ψ]^Φ = [X]^Ψ`, i.e. `sat Φ (sat Ψ X) = sat Ψ X`. Lean: `∀ X : Sub A, sat Φ (sat Ψ X) = sat Ψ X`. Faithful, including the order of the two nested saturations (`Ψ` first, then `Φ`).
> 4. **Quantification** — Contract: all sorted subsets `X ⊆ A`. Lean: all `X : Sub A` (sorted subsets). Faithful.
> 5. **Biconditional** — Contract states iff; Lean theorem is an iff with both directions (forward from `sat_sat_eq`, reverse via a singleton probe). Faithful.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the iff and both of its sides (`Φ ⊆ Ψ` and `∀ X, sat Φ (sat Ψ X) = sat Ψ X`) are stated verbatim, with matching saturation order and quantifier.

