# Correspondence audit transcript -- `B-R007`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.satSets`, `Mslang.satSets_antitone`
  (`lean/Mslang/Pilot.lean`)
- **Contract:** Remark `B-R007`, section "Preliminaries".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000052`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Fix a sort type `S`. An `S`-sorted set `A` is a family of types
> `A : S → Type u`. A componentwise subset `X` of `A` assigns to each sort `s` a
> subset `X_s ⊆ A_s`. A componentwise equivalence `Φ` on `A` assigns to each
> sort `s` an equivalence relation `Φ_s` on `A_s`. The `Φ`-saturation is
> `[X]^Φ_s = { a ∈ A_s | ∃ x ∈ X_s, x ~ Φ_s a }`, and `X` is `Φ`-saturated when
> `[X]^Φ = X`.
>
> `satSets Φ` is defined as the set of all componentwise subsets `X` of `A`
> that are `Φ`-saturated, i.e. `satSets Φ = { X | X is Φ-saturated }`.
>
> Refinement: `sortedEqvLe Φ Ψ` means `Φ` is finer than `Ψ`: for every sort `s`
> and all `x, y ∈ A_s`, `x ~ Φ_s y ⇒ x ~ Ψ_s y`.
>
> Theorem: Let `A` be an `S`-sorted set and `Φ, Ψ` componentwise equivalences on
> `A`. Assume `sortedEqvLe Φ Ψ` (i.e. `Φ` finer than `Ψ`). Then
> `satSets Ψ ⊆ satSets Φ`, i.e. every `Ψ`-saturated subset is `Φ`-saturated. So
> the map `Φ ↦ satSets Φ` is order-antitone: making the equivalence finer can
> only add saturated subsets, so the family for the coarser relation is
> contained in the family for the finer one. If `Φ = Ψ` the inclusion is an
> equality.
>
> Edge cases: the statement is purely componentwise and holds vacuously per sort
> if the types `A_s` are empty or if the relations identify nothing; when `Φ`
> identifies no distinct pairs, `Φ`-saturation is the identity, so `satSets Φ`
> is all of `Sub(A)` and the inclusion is trivial. If `Φ` and `Ψ` coincide, the
> inclusion is an equality.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> The contract asserts that `(·)-Sat(A)` is an antitone map
> `(Eqv(A), ⊆) → (Sub(Sub(A)), ⊆)`, where `Φ ⊆ Ψ` is explicitly labelled
> "`Φ` finer than `Ψ`" and `Sub(Sub(A))` carries inclusion. Antitone means
> exactly: `Φ ⊆ Ψ ⇒ f(Ψ) ⊆ f(Φ)`.
>
> - Direction/variance: `sortedEqvLe Φ Ψ` (i.e. `x ~_Φ y ⇒ x ~_Ψ y`, which is
>   precisely `Φ ⊆ Ψ`, "`Φ` finer") yields `satSets Ψ ⊆ satSets Φ`, the required
>   reversal. Source and target ordered sets match (equivalences by pointwise
>   inclusion = finer; saturated families by subset inclusion). The variance of
>   "antitone" is captured correctly (coarser relation → larger saturated
>   family).
> - Quantifiers/domain: universally over `A`, all componentwise equivalences
>   `Φ, Ψ`, all sorts -- same domain as the contract.
> - Content: the underlying saturation matches `X = [X]^Φ`, and the map
>   `Φ ↦ satSets Φ` is the same `Φ ↦ Φ-Sat(A)`. The equality case `Φ = Ψ` is a
>   harmless consistent addendum.
>
> Same statement, only notational differences (`satSets` vs `(·)-Sat(A)`), so it
> is equivalent.

## Residual note

The correspondence is `equivalent` **relative to the pilot encoding**
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
