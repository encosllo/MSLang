# Correspondence audit transcript -- `B-P020`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.congruenceFormations`,
  `..._isAlgebraFormation`, the monotonicity lemmas, the two round trips,
  `thetaSigma`, `thetaSigmaInv`, `thetaSigma_left_inv`/`_right_inv`,
  `formAlgFormCgrIso` (`lean/Mslang/Formation.lean`)
- **Contract:** Proposition `B-P020` (`FormAlgFormCgrIso`).
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`;
  `T_Σ(A)` is the inductive `Term Sig A`; `≃o` is an `OrderIso`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `congruenceFormationOf Sig F` (B-P019) is `𝔉_F = {Φ on T_Σ(A) | T_Σ(A)/Φ ∈ F}`;
> `algebraFormationOfCongruenceFormation Sig G` (B-P015) is
> `F_𝔉 = {C | ∃ A, Φ ∈ 𝔉(A), C ≅ T_Σ(A)/Φ}`. Declared: `F_𝔉` is an algebra
> formation when `𝔉` is a congruence formation; both constructions are monotone;
> the round trips `F_{𝔉_F} = F` and `𝔉_{F_𝔉} = 𝔉` hold as equalities. Lifting to
> `θ_Σ : F ↦ 𝔉_F` and `θ_Σ⁻¹ : 𝔉 ↦ F_𝔉` on the formation families, the inverse laws
> hold, and `formAlgFormCgrIso` packages them as an order isomorphism
> `algebraFormations Sig ≃o congruenceFormations Sig`.
>
> Explicitly not claimed: **no completeness/lattice structure is asserted** for
> either family; no preservation of joins/meets/top/bottom; only the order
> isomorphism (with `map_rel_iff'`) is established.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> An order isomorphism between two complete lattices is automatically a
> complete-lattice isomorphism: it preserves all existing joins and meets
> (the preimage of any subset has a sup/inf in the complete source lattice, which
> the isomorphism carries to the sup/inf of the subset). `formAlgFormCgrIso` is
> exactly such an order isomorphism, and completeness of `Form_Alg(Σ)` is
> established separately (`B-P018`, algebraic closure system); transport along
> the isomorphism yields completeness of `Form_Cgr(Σ)` and the preservation of
> arbitrary joins/meets for free. The missing lattice content is therefore not
> independent of the order isomorphism once one side is complete, so no part of
> `B-P020` is left unbacked — and nothing beyond an order isomorphism is
> asserted, so it is not stronger either.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
