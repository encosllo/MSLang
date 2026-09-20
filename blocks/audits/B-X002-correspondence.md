# Correspondence audit transcript -- `B-X002`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declarations:** `Mslang.congFi_nonempty_iff`,
  `Mslang.congFi_nonempty_of_finite_sorts` (`lean/Mslang/Regular.lean`).
- **Contract:** Example `B-X002`: `Cgr_fi(A) ≠ ∅` iff `supp_S(A)` is finite;
  hence if `card(S) < ℵ₀`, then `Cgr_fi(A) ≠ ∅` for every `A`.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `supp_S(A) = {s : A_s nonempty}`; `Cgr_fi(A)` is the set of congruences `Φ`
> of `A` whose quotient `A/Φ` has finite total carrier `Σ_s (A_s/Φ_s)`.
> Quotienting preserves support (`supp(A/Φ) = supp(A)`).
> (1) `Cgr_fi(A) ≠ ∅ ↔ supp_S(A)` finite. (2) If `S` is finite, then
> `Cgr_fi(A) ≠ ∅` for every `A`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The finite-index machinery (finite total quotient carrier) and both claims
> match the contract exactly. Quotienting preserves support, so a congruence has
> finite index precisely when only finitely many sorts are occupied, making
> `Cgr_fi(A) ≠ ∅ ↔ supp_S(A)` finite faithful. The second statement is literally
> the contract's "therefore" clause and is a valid corollary (a finite `S` forces
> `supp_S(A) ⊆ S` finite). No added or dropped strength.

## Residual note

The forward direction uses `supp_quot` (`B-R005`) and `finiteSSet_iff`
(`B-R003`); the backward direction uses `nabla_isCongruence` and
`isFiniteIndex_nabla` (`B-P031`'s ingredients). The record inherits the
pilot-encoding residuals (`carrier-model`, `small-large`, `univalence-missing`).
