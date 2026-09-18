# Correspondence audit transcript -- `B-P029`

Protocol: Architecture.md Section 11.2, two-stage blind; both stages fresh and
isolated. Stage 1 saw only the Lean declarations and definitions; stage 2 only
the read-back and the contract.

- **Lean declarations:** `Mslang.cogClassSets`, `Mslang.cogClassSetsCompl`,
  `Mslang.eqvClass_congCogenerated` (`lean/Mslang/Translation.lean`)
- **Contract:** Proposition `B-P029` (`DesClasCog`).
- **Outcome:** `equivalent`
- **Independence:** same model (`deepseek-v4.1-flash`); shared blind spots not
  excluded.

## Stage 1 -- read-back

> For a Σ-algebra `A`, `L ⊆ A`, sort `t`, `a ∈ A_t`, define
> `𝒳_{L,t,a} = {T⁻¹[L_s] | T : A_t → A_s translation, T a ∈ L_s}` and
> `𝒳̄_{L,t,a} = {T⁻¹[L_s] | T, T a ∉ L_s}`. Then the `Ω^A(L)_t`-class of `a` is
> `⋂ 𝒳_{L,t,a} \ ⋃ 𝒳̄_{L,t,a}`: `b` is Ω-related to `a` iff no translation
> separates them. No claim that Ω is a congruence or that the class is nonempty.

## Stage 2 -- comparison

> **Outcome: `equivalent`.** Same identity, same definitions of `𝒳`, `𝒳̄`,
> `Tl_t(A)_s` and `[a]_{Ω^A(L)_t}`; the "not claimed" remarks flag properties
> absent from the contract too.

## Residual note

Relative to `representation/pilot-encoding.md` (`E-000040`; residuals
`carrier-model`, `small-large`, `univalence-missing`), inherited by this verdict.
