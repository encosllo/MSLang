# Correspondence audit transcript -- `B-R009`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsClosureSystemOn`, `Mslang.iAlg`,
  `Mslang.suppAlg_iAlg`, `Mslang.supports_isClosureSystem`
  (`lean/Mslang/Pilot.lean`)
- **Contract:** Remark `B-R009`, section "Preliminaries".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000075`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> **Setup.** `S` is a set of sorts; a sorted set is a family of types
> `A : S → Type`; `supp A = {s | A s nonempty}`; a Σ-algebra is a carrier
> sorted set plus an interpretation of each operation symbol; `suppAlg A` is
> the support of the carrier.
>
> **`IsClosureSystemOn S C`.** A family `C` of subsets of `S` is a closure
> system when (1) `Set.univ ∈ C`, and (2) for every nonempty family `D ⊆ C` of
> subsets of `S`, the intersection `⋂₀ D ∈ C`.
>
> **`iAlg Sig A`.** The product of a family of Σ-algebras: carrier at `s` is
> `∀ i, (A i).1 s`, operations pointwise (`σ` sends `b` to
> `fun i => (A i).2 p σ (fun j => b j i)`).
>
> **`suppAlg_iAlg`.** `suppAlg (iAlg Sig A) = {s | ∀ i, s ∈ suppAlg (A i)}`:
> a sort lies in the support of the product exactly when it lies in the support
> of every factor (forward by evaluation; backward by `Classical.choice`).
>
> **`supports_isClosureSystem`.** The family of all supports of Σ-algebras,
> `Set.range (fun A : Alg Sig => suppAlg A)`, is a closure system on `S`.
> Universe clause: the constant one-element algebra `fun _ => PUnit` has
> support `Set.univ`. Intersection clause: for a nonempty family `D` of
> supports, choose an algebra `A X` with `suppAlg (A X) = X` for each
> `X : ↥D`, form the product `iAlg Sig A`; by `suppAlg_iAlg` its support is
> `{s | ∀ X : ↥D, s ∈ suppAlg (A X)}`, which rewrites to `⋂₀ D`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> The closure-system axioms match clause for clause: `Set.univ ∈ C` is `S ∈ C`,
> and closure under nonempty intersections is the same, with the same nonempty
> restriction. The family tested is identical (`range suppAlg` is
> `{supp_S(A) | A ∈ Alg(Σ)}`). The universe clause is witnessed by the constant
> one-element algebra; the intersection clause by the product algebra, whose
> support is the intersection of the factors' supports. The formal statement is
> quantified over every signature `Sig` (a harmless generalization of a fixed
> `Σ`), and the type/`Set.range` framing is the standard universe handling for
> the many-sorted setting, not a change in mathematical content. No missing
> clause, no stricter or looser closure requirement.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
The quantitative encoding choice `IsClosureSystemOn` packages the ordinary
one-sorted closure system (the paper's `B-D010` applied to the set of sorts);
the paper's many-sorted `ClSy(A)` is not separately formalized here.
