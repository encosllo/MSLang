# B-R021 correspondence audit (Section 11.2, two-stage blind)

Contract: `B-R021` -- `Ω^A` is the component at `A` of a natural transformation
`Ω : P⁻ ⇒ Cgr` between two contravariant functors on `Alg(Σ)_epi`.

Protocol: two-stage blind, both stages on the project's model
(`deepseek-v4.1-flash`); common blind spots are therefore not excluded.

## Stage 1 -- read-back (fresh context; Lean declarations + glossary only)

The reader was given the `B-R021` declarations (`AlgEpi`, `AlgEpiId`,
`AlgEpiComp`, `AlgEpiExt`, the two identity/associativity laws, `SubMap`,
`CgrMap` and their functor laws, `congCogenerated_natural`, and the supporting
`isAlgHom_id`, `isAlgHom_comp`, `sortedEqvLe_antisymm`) with a self-contained
glossary, and was instructed not to open the manuscript or any project record.

It rendered the formalization as: objects the Σ-algebras; morphisms the
surjective homomorphisms (`AlgEpi`); the category laws (`AlgEpiId`,
`AlgEpiComp`, unit/associativity, `AlgEpiExt`); `P⁻` as `SubMap` (preimage on
componentwise subsets) and `Cgr` as `CgrMap` (pullback `(f×f)⁻¹[·]` on
componentwise equivalences), each contravariant with identity and composition
laws; `Ω` as `congCogenerated`; and naturality as
`CgrMap f (Ω^B(M)) = Ω^A(SubMap f M)`, a propositional equality.

It explicitly listed as **not claimed**: no `Category`/`Functor` typeclass
instances (only the raw operations and their laws); `congCogenerated`'s
universal property is not asserted; surjectivity is a standing hypothesis; and
no version for non-surjective homomorphisms.

## Stage 2 -- comparison (fresh context; read-back + contract only)

The comparator, prompted to be skeptical, returned:

> **`equivalent`** -- "The read-back preserves the exact categorical data: the
> same category `Alg(Σ)_epi` with surjective homomorphisms as morphisms, the two
> contravariant functors `P⁻` (`SubMap`, preimage on subsets) and `Cgr`
> (`CgrMap`, pullback `(f×f)⁻¹`), and `Ω^A : Sub(A) → Cgr(A)`. The naturality
> square is stated in the same direction with the same componentwise instance,
> `CgrMap f (Ω^B M) = Ω^A (SubMap f M)`, i.e. `(f×f)⁻¹[Ω^B(M)] = Ω^A(f⁻¹[M])`,
> and it is claimed as equality rather than inclusion, matching the contract.
> The noted absence of Category/Functor typeclass instances and the standing
> surjectivity hypothesis are formalization details, not weakenings of the
> claim."

## Note on the first pass

An earlier stage-1 read-back, run before the epi category laws were added, listed
as *not claimed* exactly that `AlgEpiComp` has no identity/associativity laws and
that no category is developed. That finding drove the addition of
`AlgEpiComp_id_left`, `AlgEpiComp_id_right`, `AlgEpiComp_assoc`, and the
extensionality lemma `AlgEpiExt` (verification record `E-000163`, superseding
`E-000162`). The audit therefore changed the artifact, not merely recorded it.

## Caveat

Both stages share one model family (`deepseek`); independence is `same_model`,
so the layer reports `provisional` until a cross-model audit or an explicit
`light` tier (Architecture.md Sections 8.3, 9).
