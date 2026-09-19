# Correspondence audit transcript -- `B-P035`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:**
  `Mslang.isBPSLanguageFormation_of_isRegularLanguageFormation`,
  `Mslang.isRegularLanguageFormation_of_isBPSLanguageFormation`
  (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P035` (`Def1FRL` and `Def2FRL` are equivalent).
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> For an arbitrary signature `Sig` and a family `L` assigning to each carrier
> `A` a set of subsets of the term algebra `Term Sig A`, the two theorems
> together assert that `IsRegularLanguageFormation Sig L` holds exactly when
> `IsBPSLanguageFormation Sig L` holds (one direction each). Both predicates
> share two clauses: (i) every set in `L A` is regular; (ii) every
> `nabla (Term Sig A)`-saturated subset lies in `L A`. They differ in the
> remaining clauses. `IsRegularLanguageFormation` adds: (iii) for `X, Y ∈ L A`,
> every subset saturated for the meet of the cogenerated congruences
> `Ω(X) ∩ Ω(Y)` lies in `L A`; (iv) for `M ∈ L B` and a homomorphism `f` that is
> surjective after quotienting by `Ω(M)`, every subset saturated for the kernel
> `Ker(pr ∘ f)` lies in `L A`. `IsBPSLanguageFormation` instead adds: (iii') for
> `X ∈ L A` and a translation `T`, `transPreimage T X ∈ L A`; (iv') for
> `X, Y ∈ L A`, the pointwise union, intersection and complement are in `L A`;
> (v') for `M ∈ L B` and such a quotient-surjective homomorphism `f`,
> `inverseImage f M ∈ L A`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The two formal predicates reproduce the contract's clause lists without
> addition or omission. Shared clauses (i)/(ii) match the regularity clause and
> Def1FRL(1)/BPS1; (iii) matches Def1FRL(2) (saturation under the meet
> `Ω(L) ∩ Ω(L')`); (iv) matches Def1FRL(3) (`Ker(pr^{Ω(M)} ∘ f)`-saturation
> along `Ω(M)`-epimorphisms, with "surjective modulo `Ω(M)`" rendered as
> surjectivity of the composite with the quotient projection); (iii') matches
> BPS2 (`transPreimage T X` is `T⁻¹[L]`); (iv') matches BPS3 (sortwise union,
> intersection, `complA`); (v') matches BPS4 (`inverseImage f M` for the same
> epimorphism class). Every inverse-image direction is preserved, and boundary
> cases (empty carrier, empty language, all sorts, `∇`-saturation) agree. No
> clause is strengthened, weakened, or reversed.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
