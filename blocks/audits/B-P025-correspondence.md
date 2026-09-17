# Correspondence audit transcript -- `B-P025`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.congCogenerated_compl`
  (`lean/Mslang/Translation.lean`).
- **Contract:** Proposition `B-P025` (`Compl`), section "Congruence cogenerated
  by an `S`-sorted subset ...".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000151`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `congCogenerated_compl Sig A L : congCogenerated Sig A L =
> congCogenerated Sig A (complA L)` — an equality of sorted equivalences, with no
> hypotheses beyond `Sig, A, L`. `congCogenerated Sig A L` relates `x y` at `t`
> iff `∀ s (T : A_t → A_s), TlGen Sig A t s T → (T x ∈ L s ↔ T y ∈ L s)`;
> `complA L = fun s => (L s)ᶜ` with `complA_bridge : a ∈ complA L s ↔ a ∉ L s`.
> Proof: `funext t`, `Setoid.ext`, then the pointwise iff. Forward: `Iff.not`
> negates both sides. Backward: `Iff.not` plus double-negation elimination
> (`not_not`). The complement bridge exposes the negation.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> The left side is `Ω^A(L)` and the right is `Ω^A(∁_A L)`. `complA` is the
> componentwise complement inside `A`; the relations differ only by replacing
> `∈ L s` with `∉ L s`. `funext t` + `Setoid.ext` gives a pointwise iff, so both
> inclusions are established — an equality of sorted equivalences, matching the
> contract. No hypotheses beyond `Sig, A, L`; no dropped/added hypothesis, no
> weakening/strengthening, no size mismatch. The forward direction is
> constructive and the backward uses double-negation elimination; since the
> contract is ordinary classical mathematics, this is a proof-method difference
> only.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
