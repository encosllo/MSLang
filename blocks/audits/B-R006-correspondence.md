# Correspondence audit transcript -- `B-R006`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.sat_eq_preimage`, `Mslang.isSat_iff_preimage` (`lean/Mslang/Prelim.lean`)
- **Contract:** Remark `B-R006`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000325` (supersedes `E-000088`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-R006.lean`
>
> ## Setting
>
> Fix sorts `S`, a sorted set `A` (family of types `(A s)`), a sorted equivalence `Φ` (a family of
> equivalence relations `Φ s` on `A s`), and the quotient map `pr Φ s : A s → Quotient (Φ s)`.
> A subobject `X : Sub A` is a family of subsets `X s ⊆ A s`. `sat Φ X` is the saturation of `X`: at each
> sort it adds every element `Φ s`-equivalent to something in `X s`. `IsSat Φ X` means `X` is saturated,
> i.e. `sat Φ X = X`.
>
> ## Theorems
>
> - **`sat_eq_preimage`**: for every `Φ` and `X`,
>   `sat Φ X = fun s => (pr Φ s) ⁻¹' ((pr Φ s) '' X s)`.
>   Pointwise: `a ∈ sat Φ X s` iff `a` is `Φ s`-equivalent to some `x ∈ X s`, i.e. iff the class
>   `pr Φ s a` lies in the image `pr Φ s '' X s`. Equivalently, the saturation is the preimage under the
>   quotient map of the image of `X` under that same map. The two directions use `Quotient.eq.mpr` and
>   `Quotient.eq.mp` respectively.
>
> - **`isSat_iff_preimage`**: for every `Φ` and `X`,
>   `IsSat Φ X ↔ ∃ Y : ∀ s, Set (Quotient (Φ s)), X = fun s => (pr Φ s) ⁻¹' (Y s)`.
>   A subobject is `Φ`-saturated if and only if it is the full preimage, sort by sort, of some family of
>   subsets `Y s` of the quotients. Forward direction: take `Y s = pr Φ s '' X s` and use
>   `sat_eq_preimage` together with `sat Φ X = X`. Backward direction: if `X` is such a preimage, then
>   `sat Φ X = X`; the proof computes `sat` via `sat_eq_preimage` and checks both inclusions of the
>   preimage-of-preimage identity (an element is in the image of the preimage of a set iff it is in the
>   preimage-of-that-set's-image of the same set).
>
> ## Declarations stated without bodies in this file
>
> `IsSat`, `SSet`, `SortedEqv`, `Sub`, `pr`, `sat` are introduced here as declarations without bodies; the
> meanings are those described in the setting. In particular `IsSat Φ X` is the property `sat Φ X = X`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-R006 verdict
>
> Contract: Remark. (a) `[X]^Φ = (pr^Φ)^{-1}[pr^Φ[X]]`; (b) `X` is `Φ`-saturated iff `X ⊇ [X]^Φ`; (c) `X` is `Φ`-saturated iff `X = (pr^Φ)^{-1}[Y]` for some `Y ⊆ A/Φ`.
>
> ## Clause-by-clause
>
> 1. **(a) Saturation is the preimage of the image.** Lean `sat_eq_preimage`: `sat Φ X = fun s => (pr Φ s) ⁻¹' ((pr Φ s) '' X s)`. Match.
> 2. **(b) `X` saturated iff `X ⊇ [X]^Φ`.** Lean defines `IsSat Φ X` as `sat Φ X = X`. The contract's `X ⊇ [X]^Φ` is the same predicate: `[·]^Φ` is extensive (`sat_extensive`, B-P005), so `sat Φ X = X ↔ X ⊇ sat Φ X`. Match (definitional, given extensiveness; no separately named theorem).
> 3. **(c) Saturated iff a preimage family.** Lean `isSat_iff_preimage`: `IsSat Φ X ↔ ∃ Y : ∀ s, Set (Quotient (Φ s)), X = fun s => (pr Φ s) ⁻¹' (Y s)`. Match.
>
> ## Contract clauses with no Lean counterpart:
>
> none (clause (b) has no separately named declaration, but it is the definition `IsSat Φ X := sat Φ X = X` together with `sat_extensive`)
>
> Verdict: equivalent
> All three contract clauses are present: `sat_eq_preimage` gives (a), `isSat_iff_preimage` gives (c), and (b) is the definition of `IsSat` together with the already-established extensiveness of saturation.

