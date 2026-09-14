# Correspondence audit transcript -- `B-R008`

Protocol: Architecture.md Section 11.2, two-stage blind; both stages in fresh
isolated contexts.

- **Lean declarations:** `Mslang.nabla_sat_empty`, `Mslang.nabla_sat_univ`,
  `Mslang.nabla_sat_deltaUnion` (`lean/Mslang/Pilot.lean`)
- **Contract:** Remark `B-R008`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000023`
- **Independence:** both stages share this session's model; shared blind spots
  are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `IsSat (nabla A) X` means each component `X s` is either all of `A s` or
> empty ("all-or-nothing"). The empty family, the all-`A` family, and
> `deltaUnion T A` (all of `A s` for `s ∈ T`, empty otherwise) are each
> `nabla`-saturated; `deltaUnion` is the generic shape, with `T = ∅` and
> `T = S` the boundary cases.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> - `nabla A` = `∇^A` (universal relation); `IsSat (nabla A) X` = membership
>   in `∇^A-Sat(A)`.
> - Read-back statement 2 corresponds to "`A ∈ ∇^A-Sat(A)`" (the component is
>   `univ : Set (A s)`, i.e. all of `A_s`).
> - `deltaUnion T A` = `⋃_{t∈T} δ^{t,A_t}`; `T = ∅` gives `∅^S` and `T = S`
>   gives the all-`A` family, consistent.
> - Empty sorts / empty `A_s` agree (all-or-nothing is trivial there).

## Residual note

Relative to the pilot encoding (`representation/pilot-encoding.md`,
`faithful-with-caveat`, `E-000013`); `nabla` is the universal relation and the
delta-union is the all-or-nothing family, both exact at the support/order level.
