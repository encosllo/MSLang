# Correspondence audit transcript -- `B-P004`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.sat_inf_subset` (`lean/Mslang/Prelim.lean`)
- **Contract:** Proposition `B-P004`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000297` (supersedes `E-000090`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of B-P004.lean
>
> ## Ambient setting
>
> Fix a type `S`. An `SSet S` assigns a fiber `A s` to each `s : S`. A `Sub A` is a sorted subset: a family with `X s ⊆ A s`. A `SortedEqv A` is a sorted equivalence, a family `Φ` of equivalence relations on the fibers, written `Φ s x y`.
>
> - `Subset X Y` is the pointwise inclusion relation between sorted subsets: `Subset X Y` iff for every `s`, `X s ⊆ Y s`.
> - `sat Φ X` is the saturation of `X` by `Φ`: `b ∈ sat Φ X s` iff there exists `a ∈ X s` with `Φ s a b`.
> - `sortedEqvInf Φ Ψ` is the binary infimum (meet) of the two sorted equivalences in the refinement preorder.
>
> Note that the right-hand family `fun s => sat Φ X s ∩ sat Ψ X s` is a sorted subset whose `s`-fiber is the intersection of the two saturations at `s`.
>
> ## The theorem: `sat_inf_subset`
>
> Statement. For any `S`, any `A : SSet S`, any sorted equivalences `Φ, Ψ : SortedEqv A`, and any sorted subset `X : Sub A`,
>
> > `Subset (sat (sortedEqvInf Φ Ψ) X) (fun s => sat Φ X s ∩ sat Ψ X s)`.
>
> Quantifier scoping. `S`, `A`, `Φ`, `Ψ`, `X` are fixed parameters. The assertion is a pointwise inclusion, one inclusion only (see below), holding for this `X`.
>
> ## Direction and content
>
> This is a *one-sided* inclusion claim:
>
> > saturating `X` by the meet `sortedEqvInf Φ Ψ` yields a subset contained in the intersection of the two individual saturations `sat Φ X` and `sat Ψ X` (computed fiberwise).
>
> The inclusion direction is `sat(inf) X ⊆ sat Φ X ∩ sat Ψ X`; no reverse inclusion is stated, and none is claimed. The strictness in general reflects the fact that the meet relation is finer than each factor, so its saturation is the smallest of the three.
>
> ## How the proof proceeds (informal content)
>
> Let `s : S` and `b ∈ sat (sortedEqvInf Φ Ψ) X s`. By definition of saturation there is a witness `⟨a, ha, hab⟩` where `a ∈ X s` and `hab` relates `a` to `b` under the meet relation at `s`. The meet implies each component relation, so `hab.1 : Φ s a b` and `hab.2 : Ψ s a b` are available. Therefore:
>
> - `b ∈ sat Φ X s`, using witness `a` and `hab.1`;
> - `b ∈ sat Ψ X s`, using witness `a` and `hab.2`.
>
> Hence `b` lies in the intersection `sat Φ X s ∩ sat Ψ X s`, which is exactly the required pointwise membership.
>
> ## Summary
>
> B-P004 records that saturation by the infimum of two sorted equivalences is contained in the fiberwise intersection of the two saturations. It relies only on the defining projections of the meet relation into its two factors and the definition of saturation.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P004 verdict
>
> ## Clause-by-clause
>
> 1. **Ambient data** — Contract: `A` an `S`-sorted set, `X ⊆ A`, `Φ, Ψ ∈ Eqv(A)`. Lean: `S`, `A : SSet S`, `Φ Ψ : SortedEqv A`, `X : Sub A`. Faithful.
> 2. **`Φ ∩ Ψ`** — Contract: pointwise intersection of the two equivalences. Lean: `sortedEqvInf Φ Ψ`, the infimum in the refinement preorder, which is pointwise relation intersection. Faithful.
> 3. **Left side** — Contract: `[X]^{Φ∩Ψ}`, saturation of `X` by the meet. Lean: `sat (sortedEqvInf Φ Ψ) X`. Faithful.
> 4. **Right side** — Contract: `[X]^Φ ∩ [X]^Ψ`, the fiberwise intersection of the two saturations. Lean: `fun s => sat Φ X s ∩ sat Ψ X s`. Faithful.
> 5. **Inclusion direction** — Contract: one-sided `⊆` pointing from the meet-saturation into the intersection. Lean: `Subset (sat (sortedEqvInf Φ Ψ) X) (fun s => sat Φ X s ∩ sat Ψ X s)`, a pointwise one-way inclusion in the same direction; no reverse inclusion claimed. Faithful.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the one-sided inclusion of the meet-saturation in the fiberwise intersection of the two saturations is stated with matching direction, operands, and no extra or missing hypothesis.

