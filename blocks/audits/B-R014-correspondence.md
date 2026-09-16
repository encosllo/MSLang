# Correspondence audit transcript -- `B-R014`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.formation_abstract`,
  `Mslang.formation_nonempty` (`lean/Mslang/Formation.lean`)
- **Contract:** Remark `B-R014`, section "Σ-congruence formations ...".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000123`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `HOperator Sig F` is the homomorphic images of members of `F`;
> `PFsdOperator Sig F` the finite subdirect products. `IsAlgIso` is a bijective
> homomorphism.
>
> **`formation_abstract`.** Given `HOperator Sig F ⊆ F`, if `A ∈ F` and there is
> a bijective homomorphism `f : A → B`, then `B ∈ F` (a bijective hom is an
> epimorphism, so `B` is a homomorphic image of `A`).
>
> **`formation_nonempty`.** Given `PFsdOperator Sig F ⊆ F`, `F` is nonempty: the
> empty product (`iAlg` over an empty finite index) is its own subdirect product,
> hence lies in `PFsdOperator Sig F ⊆ F`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> Abstractness: a bijective hom is an isomorphism, and isomorphism is symmetric,
> so assuming the map in the `A → B` direction does not change the contract's
> `B ≅ A`. The "`F` is a formation" datum is idle — only `H`-closure is used, and
> the contract already phrases each consequence under its own hypothesis, so
> splitting into two lemmas loses nothing. Nonemptiness: same hypothesis and
> conclusion; the empty product witnesses it, matching the contract's `n = 0`
> convention. No divergence.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
