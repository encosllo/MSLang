# Correspondence audit transcript -- `B-C009`

Protocol: Architecture.md Section 11.2, two-stage blind; both stages fresh and
isolated. Stage 1 saw only the Lean declaration and definitions; stage 2 only the
read-back and the contract.

- **Lean declaration:** `Mslang.langFormationOf_atom_inf`
  (`lean/Mslang/Regular.lean`)
- **Contract:** Corollary `B-C009` (`CorolariAtoms`).
- **Outcome:** `formal_stronger`
- **Independence:** same model (`deepseek-v4.1-flash`); shared blind spots not
  excluded.

## Stage 1 -- read-back

> For a congruence formation `G` and `L_𝔉(A) = {L | Ω(L) ∈ G A}`: for any two
> sorted equivalences `Φ, Ψ` on `T_Σ(A)`, any sort `s` and `P ∈ T_Σ(A)_s`, if the
> atoms `δ^{s,[P]_Φ}` and `δ^{s,[P]_Ψ}` lie in `L_𝔉(A)`, then the atom
> `δ^{s,[P]_{Φ∩Ψ}}` of the pointwise meet lies in `L_𝔉(A)`. No converse.

## Stage 2 -- comparison

> **Outcome: `formal_stronger`.** Same conclusion, but the read-back quantifies
> over arbitrary sorted equivalences `Φ, Ψ`, whereas the contract restricts to
> congruences. Since every congruence is a sorted equivalence, the formalization
> strictly generalizes the corollary (a positive divergence; recorded, not folded
> into `equivalent`).

## Residual note

Relative to `representation/pilot-encoding.md` (`E-000040`); inherited.
