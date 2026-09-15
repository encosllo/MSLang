# Correspondence audit transcript -- `B-C001` (`IncSat`)

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.sat_antitone` (`lean/Mslang/Pilot.lean`)
- **Contract:** Corollary `B-C001`, `\label{IncSat}`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000041`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`
  (supersedes the pre-C6 audit; re-run after the Session 29 representation
  change).
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Fix a type `S` of sorts and an `S`-sorted family of carriers `A : S → Type u`.
> `Sub A` is the family of subsets (one per sort); `SortedEqv A` is the family
> of equivalence relations (setoids), one on each `A s`. The theorem says: given
> two such sorted equivalences `Φ` and `Ψ` with `Φ` pointwise refining `Ψ` --
> every pair identified by `Φ` at every sort is also identified by `Ψ` (this is
> `sortedEqvLe Φ Ψ`) -- any subset `X` that is saturated (closed) with respect
> to `Ψ` is also saturated with respect to `Φ`. Saturation of `X` by `Φ` is the
> componentwise set of all `a` that are `Φ`-equivalent to some `x` in `X`;
> because `Φ` is an equivalence, this is the union of the `Φ`-classes that meet
> `X`. `X` is saturated by `Φ` (`IsSat Φ X`) when this saturation equals `X`,
> i.e. `X` is a union of full `Φ`-classes. So the theorem is the antitonicity of
> "being saturated" in the equivalence relation: a coarser relation's saturated
> sets are saturated for every finer relation.
>
> Quantified objects: an arbitrary sort type `S`; an arbitrary `S`-sorted
> carrier `A`; two sorted equivalences `Φ, Ψ`; a subset `X`; and a proof that
> `Φ` refines `Ψ`. No nonemptiness or inhabitedness assumptions. Direction: from
> `sortedEqvLe Φ Ψ` and `IsSat Ψ X` to `IsSat Φ X`. Degenerate cases: empty `S`
> makes everything vacuous; an empty carrier component has only the empty
> subset; empty and full `X` are trivially saturated.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> The read-back matches the contract exactly in direction and domain.
> Contract: `Φ ⊆ Ψ ⇒ Ψ−Sat(A) ⊆ Φ−Sat(A)`, i.e. from `X = [X]^Ψ` infer
> `X = [X]^Φ`. Read-back: `sortedEqvLe Φ Ψ` is pointwise `Φ ⊆ Ψ`, and the
> conclusion is `IsSat Ψ X → IsSat Φ X`. Same implication direction, same
> quantifier domain (arbitrary `S`, `A`, `Φ`, `Ψ`, `X`, with the refinement
> hypothesis; no extra nonemptiness hypotheses). Saturation is the componentwise
> union of classes meeting `X`, and `IsSat` is equality with that saturation,
> matching `X = [X]^Φ`. Degenerate cases (empty `S` vacuous, empty carrier
> component yielding only `∅`, empty/full `X` saturated) are consistent and
> introduce no strengthening or weakening.

## Residual note

The correspondence is `equivalent` **relative to the pilot encoding**
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
