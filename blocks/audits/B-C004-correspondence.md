# Correspondence audit transcript -- `B-C004`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.algebraFormation_iff_shskFormation`
  (with `Mslang.shskFormation_mem_of_subdirect`, and the existing helpers
  `Mslang.subfinalAlg_mem_of_formation`, `Mslang.formation_congInf`;
  `lean/Mslang/Formation.lean`)
- **Contract:** Corollary `B-C004` (Definitions `DefFormAlg` `B-D032` and
  `ShSkFormAlg` `B-D033` are equivalent).
- **Outcome:** `equivalent`
- **Recorded as:** `E-000133`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `IsAlgebraFormation Sig F` = `HOperator Sig F ⊆ F ∧ PFsdOperator Sig F ⊆ F`.
> `HOperator` is homomorphic-image closure via surjective homs. `PFsdOperator`
> is closure under subdirect products over an arbitrary finite index
> `ι : Type u` (possibly **empty**): from a family `C : ι → Alg Sig` with all
> `C i ∈ F` and a subdirect embedding `A → ∏_i C i`, conclude `A ∈ F`.
>
> `IsShSkFormation Sig F` = `(∀ A, SubfinalAlg Sig A → A ∈ F) ∧
> HOperator Sig F ⊆ F ∧ (binary meet-of-congruences closure)`, with
> `SubfinalAlg Sig X ↔ ∀ s, Subsingleton (X.1 s)`.
>
> `shskFormation_mem_of_subdirect` proves finite subdirect-product closure for an
> ShSk-formation. It splits on `Nonempty ι`: for nonempty `ι` it iterates the
> binary meet-closure on the kernels `ker(pr^i ∘ f)` (each `A/ker(pr^i ∘ f) ≅ C i`
> in `F` by the first isomorphism theorem), ending at `Δ_A` because `f` is
> injective; for empty `ι` the product is the terminal algebra, so `A` is
> subfinal and lies in `F` by the `Sf(1) ⊆ F` clause.
>
> `algebraFormation_iff_shskFormation Sig F : IsAlgebraFormation Sig F ↔
> IsShSkFormation Sig F`. Forward: `subfinalAlg_mem_of_formation` supplies the
> `Sf(1) ⊆ F` clause as the `n = 0` instance of `P_fsd`-closure, `H`-closure is
> shared verbatim, and `formation_congInf` supplies the meet-clause by viewing
> `A/(Φ ⊓ Ψ)` as a subdirect subalgebra of `(A/Φ) × (A/Ψ)`. Backward:
> `H`-closure verbatim plus `P_fsd`-closure via `shskFormation_mem_of_subdirect`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> Clause-by-clause: the `H(F) ⊆ F` clause is identical on both sides
> (`IsEpiAlg` = hom + componentwise surjective). The two remaining axiom sets are
> bridged in both directions: `A ⇒ Sf(1)` is the `n = 0` instance of `P_fsd`
> (`subfinalAlg_mem_of_formation`); `A ⇒` meet is the `n = 2` instance on
> `A/(Φ ⊓ Ψ) ↪_sd (A/Φ) × (A/Ψ)` (`formation_congInf`); and `ShSk ⇒ P_fsd` is
> `shskFormation_mem_of_subdirect`, which closes arbitrary finite subdirect
> products by iterating the binary meet on the kernel congruences, with the empty
> index falling back to the `Sf(1) ⊆ F` clause. The empty-index (`n = 0`) case is
> present on both sides; the manuscript's commented-out `F ≠ ∅` is not part of
> either definition and neither system requires it. The contract indexes families
> by `n ∈ N` whereas Lean uses an arbitrary finite `ι : Type u`; products over
> equinumerous finite index types are canonically isomorphic, a formalization
> choice, not a semantic difference. `algebraFormation_iff_shskFormation` is a
> biconditional over the same `F`, exactly asserting DefFormAlg ⟺ ShSkFormAlg.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.

## Provenance note

This corollary is the target of the Session 71 falsification probe
(`blocks/audits/B-C004-counterexample.md`): under the old `B-D033` clause 1
(`F.Nonempty`), `algebraFormation_iff_shskFormation` was **false** (an
ShSk-formation need not contain the subfinal algebras, so need not be closed
under the empty subdirect product). The author fixed clause 1 to `Sf(1) ⊆ F`;
this verdict is for the fixed pair of definitions.
