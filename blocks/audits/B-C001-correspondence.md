# Correspondence audit transcript -- `B-C001`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.sat_antitone` (`lean/Mslang/Prelim.lean`)
- **Contract:** Corollary `B-C001`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000285` (supersedes `E-000083`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of B-C001.lean
>
> ## Ambient setting
>
> Fix a type `S` (the index/sort set). An `SSet S` is a structure `A` that assigns to each index `s : S` a fiber, written `A s` (a type/set). A `Sub A` is a *sorted subset*: a family `X` that assigns to each `s : S` a subset `X s` of the fiber `A s`. A `SortedEqv A` is a *sorted equivalence*, i.e. a family `Φ` assigning to each `s : S` an equivalence relation on `A s`; when we write `Φ s x a` we mean "`x` and `a` are related by the equivalence at sort `s`", and `(Φ s).refl a` witnesses that `a` is related to itself.
>
> Several objects are declared without bodies (opaque definitions), but their meaning is fixed by how the theorem uses them:
>
> - `sat Φ X` is the *saturation* of the sorted subset `X` by the equivalence `Φ`. Pointwise it is the set of elements of `A s` that are `Φ s`-equivalent to some element of `X s`.
> - `IsSat Φ X` is the proposition that `X` is saturated by `Φ`, i.e. the pointwise equality `sat Φ X = X`. (As a family of subsets this is equality at every sort `s`.)
> - `sortedEqvLe Φ Ψ` is a preorder relation on sorted equivalences. The theorem below shows it has the pointwise-implication meaning: `sortedEqvLe Φ Ψ` if and only if, for every sort `s` and all `x, y : A s`, `Φ s x y` implies `Ψ s x y`. In other words `Φ`'s relation is contained in (finer than) `Ψ`'s relation.
>
> ## The theorem: `sat_antitone`
>
> Statement. For any `S`, any `A : SSet S`, any two sorted equivalences `Φ` and `Ψ`, suppose `h` asserts `sortedEqvLe Φ Ψ` (so `Φ` is the finer relation). Let `X : Sub A` be any sorted subset and suppose `hX` asserts `IsSat Ψ X` (that is, `X` is saturated by `Ψ`). Then `IsSat Φ X` holds: `X` is also saturated by the finer equivalence `Φ`.
>
> Quantifier scoping. `S`, `A`, `Φ`, `Ψ` are fixed; `h : sortedEqvLe Φ Ψ` is a hypothesis for the whole theorem. Then, for *every* `X : Sub A`, the implication "if `IsSat Ψ X` then `IsSat Φ X`" holds. So the statement is `sortedEqvLe Φ Ψ → ∀ X, IsSat Ψ X → IsSat Φ X`.
>
> Direction. This is an *antitonicity* property: making the equivalence finer (moving down the `sortedEqvLe` order) can only make *more* subsets saturated. Equivalently, the predicate `IsSat · X` is order-reversing in the equivalence argument: `Φ ≤ Ψ` implies `IsSat Ψ X → IsSat Φ X`.
>
> ## How the proof proceeds (informal content)
>
> Unfolding `IsSat` reduces the goal to the pointwise equality `sat Φ X = X`. Since `X` is always contained in its own saturation (each point of `X s` is related to itself), it suffices to prove the inclusion `sat Φ X ⊆ X` sort by sort and element by element. Take `a` in `sat Φ X` at sort `s`; by definition there is `x ∈ X s` with `Φ s x a`. Using `h` (fineness: `Φ` implies `Ψ`) we get `Ψ s x a`, so `a ∈ sat Ψ X`. Since `hX` says `sat Ψ X = X`, we conclude `a ∈ X s`. Conversely, any `a ∈ X s` lies in `sat Φ X s` via the reflexive witness `a` itself.
>
> ## Summary
>
> B-C001 establishes that saturation is monotone in the *opposite* direction of the refinement order on sorted equivalences, and pins down `sortedEqvLe Φ Ψ` as the pointwise relation-inclusion `Φ ⊆ Ψ`. It needs only reflexivity of `Φ` and the defining property of `sat`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-C001 verdict
>
> ## Clause-by-clause
>
> 1. **Ambient data** — Contract: `A` an `S`-sorted set, `Φ, Ψ ∈ Eqv(A)` (sorted equivalences). Lean: `S` a type, `A : SSet S`, `Φ Ψ : SortedEqv A`. Faithful.
> 2. **Hypothesis** — Contract: `Φ ⊆ Ψ`. Lean: `h : sortedEqvLe Φ Ψ`, read-back pins `sortedEqvLe Φ Ψ` as exactly the pointwise relation-inclusion `Φ s x y → Ψ s x y`, i.e. `Φ ⊆ Ψ`. Faithful.
> 3. **Conclusion** — Contract: `Ψ-Sat(A) ⊆ Φ-Sat(A)`, i.e. every `Ψ`-saturated sorted subset is also `Φ`-saturated. Lean: `IsSat Ψ X → IsSat Φ X`, universally over `X : Sub A`, with `IsSat` the pointwise equality `sat Φ X = X` and `sat` the saturation. This is precisely membership-wise containment of the two collections of saturated subsets. Faithful.
> 4. **Quantifier scoping** — Contract leaves `A, Φ, Ψ` fixed and asserts containment of collections. Lean fixes `S, A, Φ, Ψ` and quantifies `X`. Matches.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the single hypothesis `Φ ⊆ Ψ` and the conclusion `Ψ-Sat ⊆ Φ-Sat` correspond exactly to `sortedEqvLe Φ Ψ → ∀ X, IsSat Ψ X → IsSat Φ X`.

