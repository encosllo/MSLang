# Correspondence audit transcript -- `B-P002` (`PropIncSat`)

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.prop_incSat` (`lean/Mslang/Pilot.lean`)
- **Contract:** Proposition `B-P002`, `\label{PropIncSat}`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000006`
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Fix a type `S` of sorts and a fixed ambient type `U`. A sorted set `A` is a
> family `(A_s)_{s∈S}` with `A_s ⊆ U`; a sorted equivalence `Φ` assigns to each
> sort `s` an equivalence relation `(Φ_s).r` on `A_s`. `sortedEqvLe Φ Ψ` means
> `∀ s x y, (Φ_s).r x y → (Ψ_s).r x y` (`Φ` finer than `Ψ`). `sat Φ X` has
> `s`-th component `{ a : ∃ x ∈ X_s, (Φ_s).r x a }`.
>
> The statement: `Φ` is finer than `Ψ` **iff** for every family `X` of subsets
> `X_s ⊆ A_s`, the inner saturation by `Ψ` followed by the outer saturation by
> `Φ` equals the `Ψ`-saturation alone, i.e. `sat Φ ∘ sat Ψ = sat Ψ`. The
> refinement direction and the composition order are both unambiguous from the
> text.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> - Refinement direction: `sortedEqvLe Φ Ψ` is `Φ_s.r ⊆ Ψ_s.r`, matching the
>   contract's `Φ ⊆ Ψ`.
> - Saturation order: `sat Φ (sat Ψ X)` is `Ψ` first (inner), `Φ` second
>   (outer), matching `[[X]^Ψ]^Φ`.
> - Quantifier domain and sortwise equality match `∀ X ⊆ A`.
> - Converse: taking `X_s = {x}`, any `Φ_s x y` lies in `sat Φ (sat Ψ X)_s`,
>   hence in `sat Ψ X_s`, so `Φ ⊆ Ψ`; uses reflexivity.
> - Forward: `sat Φ (sat Ψ X) ⊆ sat Ψ X` by transitivity of `Ψ`, reverse
>   inclusion by reflexivity; non-vacuous.
> - Degenerate cases (`X_s = ∅`, empty sorts) hold on both sides.
>
> The Lean statement is the standard closure-operator characterization of
> relation inclusion for equivalence relations, coinciding with `PropIncSat`.

## Residual note

The verdict is relative to the pilot encoding
(`representation/pilot-encoding.md`, `faithful-with-caveat`, `E-000002`,
residuals D1/D2/D4). The converse of `B-P002` is where the encoding's
fixed-ambient model and the arbitrary sort set force `Classical.choice`
(`DecidableEq S` for the singleton test family); the Lean proof uses it.
