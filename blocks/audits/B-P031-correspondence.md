# Correspondence audit transcript -- `B-P031`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.quotLe`, `Mslang.quotLe_mk`,
  `Mslang.isFiniteIndex_nabla`, `Mslang.IsFiniteIndex_of_le`,
  `Mslang.IsFiniteIndex_inf`, `Mslang.congFi_filter`
  (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P031`: `Cgr_fi(A)` is a filter of `Cgr(A)` when
  `supp_S(A)` is finite.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `quotLe Φ Ψ h : A/Φ → A/Ψ` is the canonical surjection when `Φ ⊆ Ψ`, with the
> representative equation `quotLe_mk`. `isFiniteIndex_nabla`: if `supp A` is
> finite then `∇` has finite index (`A/∇ ≃ supp A`). `IsFiniteIndex_of_le`:
> finite index transfers from a finer to a coarser relation.
> `IsFiniteIndex_inf`: finite index is preserved by the pointwise meet
> (`A/(Φ∩Ψ) ↪ A/Φ × A/Ψ`). `congFi_filter`: with finite support, `Cgr_fi(A)` is
> nonempty, closed under pointwise meet, and up-closed along refinement among
> congruences.
>
> Explicitly not claimed: not a bundled `Filter`/lattice object (the three
> properties are conjoined); no properness/maximality; `A/∇ ≃ supp A` and the
> embeddings into products are proof comments, not stated equivalences.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> A filter of a lattice is *defined* as a nonempty up-set closed under meets;
> the read-back conjoins exactly those three properties over `Cgr_fi(A)` (with
> `⊆` the congruence-lattice order, and the pointwise meet the lattice inf). The
> only difference is representational: properties conjoined rather than a bundled
> `Filter` object — a packaging choice, not part of the proposition's content
> (the encoding note treats the lattice structure of `Cgr(A)` separately). No
> properness is implied by the contract, and `∇ ∈ Cgr_fi(A)` is correctly
> derivable.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
