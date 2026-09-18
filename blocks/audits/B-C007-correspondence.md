# Correspondence audit transcript -- `B-C007`

Protocol: Architecture.md Section 11.2, two-stage blind; both stages fresh and
isolated. Stage 1 saw only the Lean declaration and definitions; stage 2 only the
read-back and the contract.

- **Lean declaration:** `Mslang.langFormationOf_transPreimage`
  (`lean/Mslang/Regular.lean`)
- **Contract:** Corollary `B-C007`.
- **Outcome:** `equivalent`
- **Independence:** same model (`deepseek-v4.1-flash`); shared blind spots not
  excluded.

## Stage 1 -- read-back

> For a congruence formation `G` and `L_𝔉(A) = {L | Ω(L) ∈ G A}`: if
> `T : T_Σ(A)_t → T_Σ(A)_s` is a generated translation (`TlGen`) and
> `L ∈ L_𝔉(A)`, then the concentrated preimage `T^{-1}[L] = δ^{t,T^{-1}[L_s]}`
> lies in `L_𝔉(A)`. No converse; only generated translations.

## Stage 2 -- comparison

> **Outcome: `equivalent`.** The conclusion is exactly the contract's closure
> under translation preimages; the restriction to generated translations matches
> `Tl_t(T_Σ(A))_s`; the `Ω(L)-Sat ⊆ L_𝔉(A)` premise is the derivation context,
> not added strength.

## Residual note

Relative to `representation/pilot-encoding.md` (`E-000040`; residuals
`carrier-model`, `small-large`, `univalence-missing`), inherited by this verdict.
