# Correspondence audit transcript -- `B-R006`

Protocol: Architecture.md Section 11.2, two-stage blind; both stages in fresh
isolated contexts.

- **Lean declarations:** `Mslang.sat_eq_preimage`, `Mslang.isSat_iff_preimage`
  (`lean/Mslang/Pilot.lean`)
- **Contract:** Remark `B-R006`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000022`
- **Independence:** both stages share this session's model; shared blind spots
  are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `sat Φ X s = { a : ∃ x ∈ X s, x ~_s a }`; `IsSat Φ X` is `sat Φ X = X`;
> `pr Φ s : A s → Quotient (Φ s)` sends `x` to its class.
> `sat_eq_preimage`: the saturation equals `pr⁻¹' (pr '' X)`.
> `isSat_iff_preimage`: `X` is saturated iff `X = pr⁻¹[Y]` for some family `Y`
> of subsets of the quotient.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> - The read-back gives contract sentences 1 and 3 explicitly; contract
>   sentence 2 (`X ⊇ [X]^Φ`) is not separate but is a one-line consequence of
>   `IsSat := (sat Φ X = X)` plus reflexivity (`X ⊆ [X]^Φ` always), so no
>   content is lost.
> - Objects match: `Quotient (Φ s)` = `A/Φ`; `Y s ⊆ Quotient (Φ s)` =
>   `𝒴 ⊆ A/Φ`; `pr '' X` = `pr^Φ[X]`.
> - Edge cases (`X = ∅`, `X = A`, empty sorts) agree; the `⊇` phrasing is
>   well-behaved because `Φ ∈ Eqv(A)` (reflexive).

## Residual note

Relative to the pilot encoding (`representation/pilot-encoding.md`,
`faithful-with-caveat`, `E-000013`). The quotient is `Quotient` (residual
`R-quotient`); the theorem is stated at the class level, which is exactly what
the contract uses.
