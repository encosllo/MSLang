# Correspondence audit transcript -- `B-P039`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.langCongFormationOf_langFormationOf`,
  `Mslang.langFormationOf_langCongFormationOf`,
  `Mslang.langFormationOf_mono`, `Mslang.langCongFormationOf_mono`,
  `Mslang.formCgrFiFormLangRIso` (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P039`.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `finiteIndexCongruenceFormations Sig` is the set of finite-index congruence
> formations `G`; `regularLanguageFormations Sig` the set of regular-language
> formations `L`. `toFun : G ↦ L_𝔉` with `L_𝔉(A) = {L | Ω(L) ∈ G(A)}`;
> `invFun : L ↦ 𝔉_𝔏` with `𝔉_𝔏(A) = {Φ ∈ Cgr_fi(T_Σ(A)) | every Φ-saturated
> language lies in L(A)}`. The inverse laws are `𝔉_{L_𝔉} = 𝔉` and
> `L_{𝔉_𝔏} = L`, both conditional on the relevant formation hypothesis;
> `map_rel_iff'` gives `G ≤ G' ↔ L_𝔉 ≤ L_{G'}` for the pointwise-inclusion
> order. So the declaration is an order isomorphism `≃o` of the two posets,
> under `[Finite S]`.
>
> Explicitly not claimed: preservation of meets/joins/top/bottom or any lattice
> structure; completeness of either poset; uniqueness of the isomorphism; any
> relation to automata or Myhill--Nerode.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The read-back is exactly the contract's content: the mutual-inverse bijections
> `𝔉 = 𝔉_{L_𝔉}`, `L = L_{𝔉_𝔏}` and order preservation/reflection
> `𝔉 ≤ 𝔊 ↔ θ_Σ(𝔉) ≤ θ_Σ(𝔊)`, i.e. an order isomorphism of the underlying
> posets. The manuscript's lattice structures (completeness) are separate
> results (`B-P018`/`B-C005`, `B-C012`), and an order isomorphism between the
> complete lattices automatically preserves all meets/joins, so the poset-level
> isomorphism matches the proposition as the manuscript proves it. `[Finite S]`
> is the section's standing assumption `B-A001`. Nothing is added, dropped,
> weakened, or reversed.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
