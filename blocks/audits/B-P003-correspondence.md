# Correspondence audit transcript -- `B-P003` (`NablaSat`)

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.nabla_sat` (`lean/Mslang/Pilot.lean`)
- **Contract:** Proposition `B-P003`, `\label{NablaSat}`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000045`
- **Encoding:** dependent-type carrier model (`representation/pilot-encoding.md`);
  re-run after the Session 29 representation change.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Fix a type `S` of sorts and an `S`-sorted carrier `A : S → Type u`. `Sub A` is
> the per-sort subset family; `SortedEqv A` is the per-sort setoid family;
> `sat Φ X s = {a | ∃ x ∈ X s, (Φ s).r x a}`; `IsSat Φ X := sat Φ X = X`.
> `nabla A` is the universal sorted equivalence, whose relation at every sort
> relates every pair. `suppSub X := {s | (X s).Nonempty}` is the support of `X`.
> The theorem `nabla_sat` states: for arbitrary `X`, `IsSat (nabla A) X` if and
> only if for every sort `s`, if `s ∈ suppSub X` then `X s = Set.univ` (the whole
> type `A s`). Direction `⇐`: if every support sort has `X s = univ`, then
> saturation under the universal relation equals `X`. Direction `⇒`: if
> saturation under the universal relation equals `X`, then any sort with `X s`
> nonempty has `X s = univ`. Degenerate cases: empty `S` gives the unique
> subset, empty support, and the condition holds vacuously; an empty carrier
> component forces `X s = ∅`, which is outside the support.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> The read-back reproduces the contract faithfully. `IsSat` sets the saturation
> equal to `X`, matching `X = [X]^{∇^A}`. For the universal relation,
> `sat (nabla A) X s = univ` exactly when `X s` is nonempty and `∅` otherwise,
> so `IsSat (nabla A) X` unfolds to: for every `s`, `X s ≠ ∅ → X s = univ`. The
> Lean RHS `∀ s, s ∈ suppSub X → X s = Set.univ` is the identical statement,
> since `suppSub X = {s | (X s).Nonempty}` and `Set.univ : Set (A s)` is the
> whole component `A_s`. Both directions are described correctly. Quantifier
> domains agree (`X` arbitrary, all sorts `s`), and the degenerate cases line up:
> empty `S` gives the unique subset with vacuous both sides; an empty carrier
> component forces `X s = ∅`, off-support, satisfying every clause trivially. No
> direction is strengthened or weakened.

## Residual note

Inherits the pilot encoding's residuals (see `E-000040`); a representation change
(class C6) stales this verdict.
