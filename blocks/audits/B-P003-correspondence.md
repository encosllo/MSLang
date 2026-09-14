# Correspondence audit transcript -- `B-P003` (`NablaSat`)

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.nabla_sat` (`lean/Mslang/Pilot.lean`)
- **Contract:** Proposition `B-P003`, `\label{NablaSat}`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000008`
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `nabla A` is the universal (coarsest) sorted equivalence: at every sort the
> total relation. `sat (nabla A) X` has `s`-component `A_s` when `X_s ≠ ∅` and
> `∅` otherwise. So `IsSat (nabla A) X` (the fixed-point condition
> `sat (nabla A) X = X`) means each nonempty component `X_s` equals all of
> `A_s`, while empty components pass trivially. `suppSub X = {s | X_s ≠ ∅}`,
> and `X s = Set.univ` means `X_s = A_s` (the whole component, not all of `U`).
>
> Statement: `X` is `nabla A`-saturated iff for every `s`, if `X_s ≠ ∅` then
> `X_s = A_s`. No premises beyond the biconditional's own left side.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> - `nabla A` is the total relation at each sort, matching `∇^A` as the
>   greatest element of `Eqv(A)` (coarsest under refinement).
> - Saturation: with `Φ = ∇`, `[x]_{∇_s} = A_s` when `A_s ≠ ∅`, so
>   `(sat ∇ X)_s = A_s` iff `X_s ≠ ∅`, else `∅`; matches `B-D014`.
> - `IsSat` = fixed point matches `X ∈ ∇^A-Sat(A)`.
> - `X_s = A_s` correctly means the whole component.
> - Degenerate cases (`X = ∅`, empty `A_s`, `S = ∅`) consistent on both sides;
>   no hidden strengthening/weakening.

## Residual note

Relative to the pilot encoding (`representation/pilot-encoding.md`,
`faithful-with-caveat`, `E-000002`, residuals D1/D2/D4). The component
`X_s = A_s` is rendered as `X s = Set.univ : Set (A s)`, i.e. the whole subtype
component; this is exact for the fixed-ambient model (D2).
