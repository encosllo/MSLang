# Correspondence audit transcript -- `B-P016`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.formation_congInf`, with `Mslang.IsCongruence_inf`
  (`lean/Mslang/Formation.lean`)
- **Contract:** Proposition `B-P016`, section "Σ-congruence formations ...".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000125`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `IsAlgebraFormation Sig F` is closure under homomorphic images and finite
> subdirect products. `IsCongruence Sig F Φ` is compatibility with the
> operations; `sortedEqvInf Φ Ψ` is the pointwise meet; `quotAlg Sig F Φ hΦ` is
> `A/Φ`.
>
> **`formation_congInf`.** For a formation `F`, an algebra `A`, and congruences
> `Φ, Ψ`: if `A/Φ ∈ F` and `A/Ψ ∈ F` then `A/(Φ ⊓ Ψ) ∈ F`. Proof idea: the
> comparison map `A/(Φ ⊓ Ψ) → A/Φ × A/Ψ` is a homomorphism (well-defined since
> `Φ ⊓ Ψ` refines each factor), injective (meet of the relations), with
> surjective projections — a subdirect embedding; so `A/(Φ ⊓ Ψ)` is a finite
> subdirect product of `A/Φ, A/Ψ ∈ F`, and `PFsdOperator Sig F ⊆ F` closes it.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> The formation notion, the congruences `Φ, Ψ ∈ Cgr(A)`, the meet
> (`sortedEqvInf` = `Φ ∩ Ψ` for congruences), and the quotients all match; the
> hypotheses and conclusion are identical with no extra or missing assumption.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
