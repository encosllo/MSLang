# Correspondence audit transcript -- `B-P017`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.shskFormation_mem_of_subdirect_pair`
  (with helpers `Mslang.pairAlgFamily`, `Mslang.isAlgIso_symm`,
  `Mslang.quotAlg_ker_isAlgIso`, `Mslang.formation_mem_of_iso`;
  `lean/Mslang/Formation.lean`)
- **Contract:** Proposition `B-P017`, section "Σ-congruence formations ...".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000129`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `IsShSkFormation Sig F` = `F` is nonempty, closed under homomorphic images
> (`HOperator`, via surjective homomorphisms), and closed under binary meets of
> congruences: `A/Φ, A/Ψ ∈ F ⇒ A/(Φ ⊓ Ψ) ∈ F`.
>
> `pairAlgFamily Sig B C` is the family over `ULift.{u,0} Bool` equal to `B` at
> `⟨false⟩` and `C` at `⟨true⟩`; `iAlg Sig (pairAlgFamily Sig B C)` is the binary
> product `B × C`.
>
> `IsSubdirectEmbedding Sig A.2 (pairAlgFamily Sig B C) f` unfolds to
> `IsMonoAlg ... f ∧ ∀ i s, Surjective (fun a => f s a i)`, i.e. `f` is an
> injective homomorphism whose composites with both product projections are
> surjective.
>
> **`shskFormation_mem_of_subdirect_pair`.** For an ShSk-formation `F` and
> `B, C ∈ F`, if `f : A → B × C` is a subdirect embedding then `A ∈ F`.
> Proof: set `Φ = Ker(pr^B ∘ f)`, `Ψ = Ker(pr^C ∘ f)`; the first isomorphism
> theorem makes `A/Φ ≅ B` and `A/Ψ ≅ C`, so both quotients lie in `F` by
> abstractness; ShSk meet-closure puts `A/(Φ ⊓ Ψ)` in `F`; injectivity of `f`
> gives `Φ ⊓ Ψ = Δ_A`, and the comparison map `A/(Φ ⊓ Ψ) → A` is an
> isomorphism, so `A ∈ F`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> Clause-by-clause: the conclusion `A ∈ F` matches; `{A B C}` are universally
> quantified with `hB : B ∈ F`, `hC : C ∈ F`; `IsShSkFormation` matches the
> contract's nonempty + `H`-closed + meet-closure definition; `IsSubdirectEmbedding`
> is exactly "injective homomorphism whose composites with the two projections
> are surjective" (`f s a i` is `π_i ∘ f`, `i` ranging over the two-element
> index); `pairAlgFamily` realizes the binary product `B × C`; and all carriers
> live in the single universe `u` (the `ULift.{u,0} Bool` index keeps the product
> in `Type u`), with `F.Nonempty` present. No dropped/extra hypothesis, no
> quantifier-order swap, no weakening/strengthening, no size gap.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
