# Correspondence audit transcript -- `B-C010`

Protocol: Architecture.md Section 11.2, two-stage blind; both stages fresh and
isolated. Stage 1 saw only the Lean declaration and definitions; stage 2 only the
read-back and the contract.

- **Lean declaration:** `Mslang.langFormationOf_inverseImage`
  (`lean/Mslang/Regular.lean`)
- **Contract:** Corollary `B-C010` (`CorolariAntiimatge`).
- **Outcome:** `equivalent`
- **Independence:** same model (`deepseek-v4.1-flash`); shared blind spots not
  excluded.

## Stage 1 -- read-back

> For a congruence formation `G` and `L_𝔉(A) = {L | Ω(L) ∈ G A}`: let
> `M ∈ L_𝔉(B)` and let `f : T_Σ(A) → T_Σ(B)` be a homomorphism whose composite
> with the projection onto `T_Σ(B)/Ω(M)` is sortwise surjective (an
> `Ω(M)`-epimorphism). Then `f⁻¹[M] ∈ L_𝔉(A)`. No claim that `Ω` commutes with
> inverse image; no surjectivity of `f` itself; no converse.

## Stage 2 -- comparison

> **Outcome: `equivalent`.** Hypotheses (sortwise `M ∈ L_𝔉(B)`, the
> `Ω(M)`-epimorphism condition) and conclusion match exactly. The manuscript's
> proof observation `(f×f)⁻¹[Ω^B(M)] ∈ 𝔉(A)` is not part of the stated contract.

## Residual note

Relative to `representation/pilot-encoding.md` (`E-000040`); inherited.
