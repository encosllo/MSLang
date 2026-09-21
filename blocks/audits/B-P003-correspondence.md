# Correspondence audit transcript -- `B-P003`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.nabla_sat` (`lean/Mslang/Prelim.lean`)
- **Contract:** Proposition `B-P003`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000296` (supersedes `E-000087`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of B-P003.lean
>
> ## Ambient setting
>
> Fix a type `S`. An `SSet S` assigns a fiber `A s` to each `s : S`. A `Sub A` is a sorted subset, i.e. a family of subsets `X s ⊆ A s`. A `SortedEqv A` is a family `Φ` of equivalence relations, one on each fiber. The objects used here are:
>
> - `nabla A`: a distinguished sorted equivalence associated with `A` (the "nabla" equivalence). Informally it behaves as the indiscrete/top equivalence, so that `sat (nabla A) X` fills each nonempty fiber `X s` up to the whole fiber.
> - `suppSub X`: the *support* of the sorted subset `X`, namely the set of indices `s : S` at which the fiber `X s` is nonempty. Membership `s ∈ suppSub X` is witnessed by a pair `⟨x, hx⟩` with `hx : x ∈ X s`.
> - `sat Φ X`: saturation of `X` by `Φ`: `a ∈ sat Φ X s` iff some `x ∈ X s` is `Φ s`-related to `a`.
> - `IsSat Φ X`: `X` is saturated by `Φ`, i.e. `sat Φ X = X` pointwise.
>
> ## The theorem: `nabla_sat`
>
> Statement. For any `S`, any `A : SSet S`, and any sorted subset `X : Sub A`,
>
> > `IsSat (nabla A) X` if and only if, for every `s : S`, if `s` lies in the support of `X` then `X s = Set.univ`.
>
> Quantifier scoping. `S`, `A`, and `X` are fixed parameters; the equivalence holds for this `X`. The right-hand condition is `∀ s, s ∈ suppSub X → X s = Set.univ`, where `Set.univ` is the full fiber `A s` (all elements of the sort-`s` fiber). Note the conditional structure: at indices where `X` is empty there is *no* requirement; at every index where `X` is inhabited, the fiber must already be the whole fiber.
>
> ## Meaning of both directions
>
> - (⇒) Suppose `X` is `nabla A`-saturated, i.e. `sat (nabla A) X = X`. Take any `s` in the support of `X`, witnessed by some `x ∈ X s`. Because `sat (nabla A) X` and `X` agree at `s`, and because saturation by `nabla` puts every element of `A s` into the saturation as soon as `X s` is nonempty, one gets `X s = Set.univ`. Concretely: for any `a`, `a ∈ X s` since `a ∈ sat(nabla) X s` (witness `x` and the universal `nabla` relation) and this set equals `X s`.
> - (⇐) Conversely, suppose every inhabited fiber of `X` is full. We must prove `sat (nabla A) X = X` pointwise. The inclusion `X s ⊆ sat (nabla A) X s` is automatic (reflexivity). For the reverse, take `a ∈ sat (nabla A) X s`, witnessed by `x ∈ X s`. Then `s` is in the support, so by hypothesis `X s = Set.univ`, hence `a ∈ X s`.
>
> ## Summary
>
> B-P003 characterizes `nabla`-saturation: a sorted subset is saturated by the `nabla` equivalence exactly when it is "trivially thick", namely each of its nonempty fibers is the entire fiber `A s`. Outside the support there is no constraint.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P003 verdict
>
> ## Clause-by-clause
>
> 1. **Ambient data** — Contract: `A` an `S`-sorted set, `X ⊆ A` a sorted subset. Lean: `S`, `A : SSet S`, `X : Sub A`. Faithful.
> 2. **Left of iff** — Contract: `X ∈ ∇^A-Sat(A)`, i.e. `X` is saturated by the `nabla` equivalence. Lean: `IsSat (nabla A) X`, with `nabla A` read-back as the distinguished `nabla` equivalence on `A` and `IsSat` the pointwise `sat = X`. Faithful.
> 3. **Right of iff** — Contract: for every `s ∈ S`, if `s ∈ supp_S(X)` then `X_s = A_s`. Lean: `∀ s, s ∈ suppSub X → X s = Set.univ`, with `suppSub X` exactly the support (indices with `X s` nonempty) and `Set.univ` the full fiber `A s`. Faithful.
> 4. **Conditional at empty fibers** — Contract imposes no condition when `s ∉ supp_S(X)`. Lean's hypothesis is conditional `s ∈ suppSub X → ...`, giving no obligation outside the support. Faithful.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the iff between `nabla`-saturation and "every inhabited fiber is full" matches clause for clause, including the support restriction and the identification `X_s = A_s` with `Set.univ`.

