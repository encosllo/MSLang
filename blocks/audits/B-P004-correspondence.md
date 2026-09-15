# Correspondence audit transcript -- `B-P004`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.sat_inf_subset` (`lean/Mslang/Pilot.lean`)
- **Contract:** Proposition `B-P004`, section "Preliminaries".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000049`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Quantified objects: an arbitrary type (index set of sorts) `S`; an `S`-sorted
> set `A`, i.e. a type `A s` for each `s : S`; a componentwise equivalence
> relation `Φ` on `A`, meaning a setoid `(A s, Φ s)` on each component `A s`; a
> second such componentwise equivalence relation `Ψ` on `A`; and a componentwise
> subset `X` of `A`, i.e. a set `X s ⊆ A s` for every sort `s`.
>
> Hypotheses: none beyond the objects being of the stated kinds. There is no
> nonemptiness, inhabitedness, or other side condition on `S`, on any `A s`, or
> on `X`, and `Φ` and `Ψ` are arbitrary.
>
> Conclusion: the componentwise inclusion, for every sort `s`, of the saturation
> of `X` under the pointwise meet `Φ ∩ Ψ` into the intersection of the
> `Φ`-saturation of `X` with the `Ψ`-saturation of `X`:
> `[X]^(Φ∩Ψ) ⊆ ([X]^Φ ∩ [X]^Ψ)` holds at each sort. Here `[X]^Φ` at `s` is the
> set of `b : A s` such that there exist `a ∈ X s` with `(Φ s).r a b` (and
> likewise for `Ψ`), and `Φ ∩ Ψ` is the relation that holds of a pair exactly
> when both `Φ` and `Ψ` hold of it. Concretely, the theorem states that if `b` is
> obtained from some `a ∈ X s` via the conjunction relation
> `(Φ s).r a b ∧ (Ψ s).r a b`, then `b` belongs both to the `Φ`-saturation of `X`
> at `s` and to the `Ψ`-saturation of `X` at `s`.
>
> Direction and strength: this is a one-directional inclusion (⊆) only; it does
> not assert the reverse inclusion nor equality of the two sets. The proof takes
> an element `b` of the left set, extracts a witness `a ∈ X s` together with both
> relations, and projects each conjunct to obtain membership in the two
> right-hand sets respectively.
>
> Degenerate/edge cases covered: the statement is uniform over all sorts,
> including any sort `s` with `A s` empty (then all sides are empty) or with
> `X s` empty (then all saturations are empty); since the relations are arbitrary
> componentwise setoids, the statement holds with no
> reflexivity/symmetry/transitivity-related extra assumptions used beyond the
> stated structure. Covered are exactly the pointwise-in-`s` inclusion; not
> covered are any claim of the converse inclusion, equality, or behavior under
> unions, intersections, or other operations beyond the meet of relations.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> Direction: the contract asserts the one-way inclusion
> `[X]^{Φ∩Ψ} ⊆ [X]^Φ ∩ [X]^Ψ`, and the read-back asserts exactly the same
> inclusion, componentwise at each sort `s`, with no reverse inclusion or
> equality added. Quantifier domain: both quantify over an arbitrary index set
> `S`, an arbitrary `S`-sorted set `A`, an arbitrary componentwise subset `X` of
> `A`, and arbitrary componentwise equivalences `Φ, Ψ` on `A` -- matching, with
> no extra nonemptiness/inhabitedness restrictions. Hypotheses: both have none
> beyond the objects being of the stated kinds. Operation `∩`: in both, it is
> the pointwise meet of relations, so `[X]^{Φ∩Ψ}` requires a witness `a ∈ X s`
> with `Φ s a b ∧ Ψ s a b`; the read-back defines the saturations existentially
> precisely this way and obtains the two memberships by projecting the conjuncts,
> which is exactly the contract's content. Differences are purely notational
> (componentwise `s`-indexing and `.r` notation), so the statements coincide.

## Residual note

The correspondence is `equivalent` **relative to the pilot encoding**
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
