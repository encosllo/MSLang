# Correspondence audit transcript -- `B-P034`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.finiteSSet_of_isAlgIso`,
  `Mslang.congruenceFormationOf_isFiniteIndex`,
  `Mslang.algebraFormationOfCongruenceFormation_isFiniteAlgebra`,
  `Mslang.formAlgFFormCgrFiIso` (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P034` (first half of the second Eilenberg theorem).
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `finiteSSet_of_isAlgIso`: finiteness of the sorted carrier transfers across a
> sortwise bijection. `congruenceFormationOf_isFiniteIndex`: if every member of
> `F` is finite, every `Φ ∈ 𝔉_F(A)` has finite index (`T_Σ(A)/Φ ∈ F ⊆ Alg_f`).
> `algebraFormationOfCongruenceFormation_isFiniteAlgebra`: if every `G(A)` is
> finite index, then `F_𝔉 ⊆ Alg_f` (a quotient by a finite-index congruence is
> finite, and finiteness is isomorphism-invariant). These are the well-definedness
> ("landing") conditions. `formAlgFFormCgrFiIso : finiteAlgebraFormations Sig ≃o
> finiteIndexCongruenceFormations Sig` packages them: `F ↦ 𝔉_F`, inverse
> `𝔉 ↦ F_𝔉`, inverse laws from the `B-P020` round trips, inclusion-reflection
> from monotonicity.
>
> Explicitly not claimed: only the finiteness halves are new here (the closure-
> formation properties and the round trips come from `B-P019`/`B-P015`/`B-P020`);
> order isomorphism, not equality; no existence/nonemptiness of the families.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> An order isomorphism of the posets is exactly a complete-lattice isomorphism
> (it reflects/preserves all joins and meets; completeness makes this arbitrary),
> and the encoding note stipulates that the lattice structure is established
> separately — the contract's own decomposition. Importing the closure-formation
> properties and round trips from `B-P019`/`B-P015`/`B-P020` is legitimate
> modular composition; this block supplies the genuinely new finiteness halves
> that make the maps land in the *finite* subfamilies.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
