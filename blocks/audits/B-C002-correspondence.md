# Correspondence audit transcript -- `B-C002`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declaration:** `Mslang.sat_inf` (`lean/Mslang/Pilot.lean`)
- **Contract:** Corollary `B-C002`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000011`
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `sortedEqvInf Φ Ψ` is the pointwise intersection relation
> `x ~_s^{Φ⊓Ψ} y ↔ x ~_s^Φ y ∧ x ~_s^Ψ y`. `IsSat Φ X` means `sat Φ X = X`
> with `(sat Φ X)_s = { a : ∃ x ∈ X_s, x ~_s^Φ a }`. The statement: if `X` is
> saturated under `Φ` and under `Ψ`, then `X` is saturated under `Φ ⊓ Ψ`. The
> read-back notes the second hypothesis is not needed in the proof, since
> `Φ ⊓ Ψ` is contained in `Φ`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> - The meet is the pointwise intersection, matching the contract's `Φ ∩ Ψ`.
> - Saturation matches `[X]^Θ_s = ⋃_{x∈X_s}[x]_{Θ_s}`; `IsSat` matches
>   `X = [X]^Θ`; the domain matches `Sub(A)`.
> - The contract is `∀X, IsSat Φ X → IsSat Ψ X → IsSat (Φ⊓Ψ) X`; the Lean
>   statement keeps **both** hypotheses. Redundancy of the second *in the
>   derivation* does not change the proposition: `(P ∧ Q → R)` is the
>   contract. Removing the hypothesis would be `formal_stronger`, but the
>   statement does not do that.
> - Degenerate cases (`X = ∅`, empty sorts) agree.

## Residual note

Relative to the pilot encoding (`representation/pilot-encoding.md`,
`faithful-with-caveat`, `E-000002`, residuals D1/D2/D4). The meet is encoded as
the pointwise conjunction of the two relations; exact under the encoding.
