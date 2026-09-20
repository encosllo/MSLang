# Correspondence audit transcript -- `B-C013`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declarations:** `Mslang.regularLanguageFormationsCompleteLattice`,
  `Mslang.regularLanguageFormations_isAlgebraicLattice`
  (`lean/Mslang/Regular.lean`); the transported source
  `Mslang.finiteIndexCongruenceFormations_isAlgebraicLattice` and the order
  isomorphism `Mslang.formCgrFiFormLangRIso` (`B-P039`).
- **Contract:** Corollary `B-C013` (under `B-A001`, `S` finite), via `B-P039` and
  `B-C012`.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Fix a finite sort set `S` (`[Finite S]`) and a signature `Sig`. For each
> `S`-sorted set `A`, `Term Sig A` is the term algebra and `Sub (Term Sig A)` is
> the family of subsets ("languages") of it. A regular-language formation is a
> choice function `L : (A : SSet S) → Set (Sub (Term Sig A))` satisfying
> `IsRegularLanguageFormation Sig L`: (i) `L A ⊆ Lang_r(T_Σ(A))`, i.e. every
> chosen language is regular, meaning its cogenerated congruence `Ω^{T_Σ(A)}(X)`
> has finite index; (ii) every `∇`-saturated language lies in `L A`; (iii) `L A`
> is closed under `(Ω(X) ∩ Ω(Y))`-saturation; and (iv) `L A` is closed under
> `Ker(pr^{Ω(M)} ∘ f)`-saturation along `Ω(M)`-epimorphisms of term algebras.
> `regularLanguageFormations Sig` is the set (subtype) of all such `L`, ordered
> pointwise by inclusion: `L ≤ L'` iff `L A ⊆ L' A` for every `A`. The order
> isomorphism `formCgrFiFormLangRIso Sig` identifies it with
> `finiteIndexCongruenceFormations Sig`.
>
> The only hypothesis is `[Finite S]` and `Sig : Signature S`.
> `regularLanguageFormations_isAlgebraicLattice` asserts `IsAlgebraicLattice`
> for the instance `regularLanguageFormationsCompleteLattice` (supplied by
> `liftCompleteLattice` along the Galois insertion of the order iso): every
> element is the supremum of a set of compact elements, where compact means
> every covering by a supremum has a finite subcover. Algebraicness is
> transported through `formCgrFiFormLangRIso` from the finite-index congruence
> formations.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> Both fix exactly the same hypotheses (`[Finite S]` plus a signature), the same
> carrier (functions on `Σ`-algebras with values in subsets of `Lang_r(T_Σ(A))`),
> the same order (pointwise inclusion), and the same closure clauses
> (`∇`-saturated containment, `(Ω(L) ∩ Ω(L'))`-saturation, kernel-of-`Ω`-
> epimorphism closure), with the regularity requirement `𝔏(A) ⊆ Lang_r(T_Σ(A))`
> present in both. The conclusion matches: the formal statement asserts
> `IsAlgebraicLattice` under a `CompleteLattice` structure, and the contract
> asserts the same algebraic-lattice property (complete lattice where every
> element is the join of compact elements). No extra hypotheses, stronger
> assumptions, weaker conclusions, or domain/order mismatches appear; the only
> difference is packaging detail (a transported instance plus a separate `Prop`),
> which does not change strength.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). `[Finite S]` is
the standing assumption `B-A001`. Those residuals are inherited by this verdict;
a representation change (class C6) stales it.
