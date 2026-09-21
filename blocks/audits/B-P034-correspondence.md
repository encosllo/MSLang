# Correspondence audit transcript -- `B-P034`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.finiteSSet_of_isAlgIso`, `Mslang.congruenceFormationOf_isFiniteIndex`, `Mslang.algebraFormationOfCongruenceFormation_isFiniteAlgebra`, `Mslang.formAlgFFormCgrFiIso` (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P034`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000319` (supersedes `E-000189`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is therefore faithful, not a
> weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-P034 — read-back (informal mathematics)
>
> ## Ambient setting
>
> `S` is a type of **sorts**; `SSet S` is a sorted set (a family of types over
> sorts); `Sub A` is a sorted family of subsets; `Signature S` is a many-sorted
> signature with operation symbols indexed by `p = (w, s)` (`w : List S` input
> word, `s` result sort); `Term Sig X` is the many-sorted term algebra over
> variables `X`; `termAlg Sig X` packages it as an algebra. `SortedEqv A` is a
> sorted equivalence relation. `Alg Sig` is the category/set of algebras;
> `SortedMap A B` is a sort-preserving function.
>
> Basic predicates/constructions appearing in the interface:
>
> * `AlgStruct Sig A`: algebra structure on `A`; `Alg Sig = Σ A, AlgStruct Sig A`.
> * `IsAlgHom Sig FA FB f`: `f` is an algebra homomorphism; `IsAlgIso Sig FA FB f`:
>   `f` is an algebra isomorphism (a bijective homomorphism); `IsEpiAlg`,
>   `IsMonoAlg`: `f` is an epimorphism/monomorphism of algebras.
> * `IsCongruence Sig F Φ`: `Φ` is a congruence of the algebra `(A,F)`;
>   `IsCongruence_inf` (`:75`): the meet of two congruences is a congruence.
> * `sortedEqvInf` (meet/intersection), `sortedEqvLe` (refinement order).
> * `nabla A` (`:230`): the universal relation; `nabla_isCongruence` (`:232`): it
>   is a congruence.
> * `ker f` (`:217`): kernel relation; `ker_isCongruence` (`:219`): kernel of a
>   homomorphism is a congruence.
> * `quot Φ`, `quotOp`, `quotAlg`, `pr Φ`, `prAlg`, `quotLift`: the quotient
>   sorted set/algebra by `Φ`, its operations, the projection, and the unique lift
>   of a map killing `Φ`. `quotOp_mk` (`:271`): operations on classes are computed
>   from representatives. `ker_pr` (`:223`): `ker (pr Φ) = Φ`; `ker_prAlg`
>   (`:226`): `ker (prAlg … Φ …) = Φ`; `isAlgHom_prAlg` (`:208`): the projection
>   is a homomorphism; `quotAlgLift_isAlgHom` (`:248`): the lift is a
>   homomorphism; `quotAlg_ker_isAlgIso` (`:254`): the first isomorphism theorem
>   (a surjective homomorphism `f : A → B` induces an isomorphism
>   `A / ker f ≅ B`); `quotLift_comp` (`:263`): the lift satisfies
>   `(quotLift Φ f h) ∘ (pr Φ) = f`.
> * `IsFiniteIndex Φ` (`:85`): the quotient `quot Φ` is finite; `congFi Sig F`
>   (`:151`): the set of congruences of the algebra `(A,F)` of finite index.
> * `FiniteAlg` (`:55`): `X` is a finite algebra; `FiniteSSet` (`:57`): the total
>   carrier is finite. `algebraFinite Sig` (`:121`): the class of finite algebras.
> * `HOperator Sig F` (`:59`): closure of a class of algebras under homomorphic
>   images; `PFsdOperator Sig F` (`:100`): closure under subdirect products.
> * `IsAlgebraFormation Sig F` (`:67`): `F` is a class of algebras closed under
>   homomorphic images, subdirect products, etc. (an algebra formation);
>   `IsFiniteAlgebraFormation` (`:83`): a finite algebra formation (all members
>   finite). `finiteAlgebraFormations Sig` (`:176`): the set of such `F`.
> * `IsCongruenceFormation Sig G` (`:72`) for
>   `G : (A : SSet S) → Set (SortedEqv (Term Sig A))`: `G` is a congruence
>   formation (pointwise nonempty, of congruences, meet-closed, upward closed,
>   kernel-closed). `IsFiniteIndexCongruenceFormation` (`:87`): additionally every
>   member has finite index. `finiteIndexCongruenceFormations Sig` (`:178`): the
>   set of these.
> * `IsSubalgebra` (`:93`), `IsSubdirectEmbedding` (`:96`), `Subfinal` (`:112`)
>   (sorted set that is subterminal: each sort has at most one element),
>   `SubfinalAlg` (`:114`) (its algebra is subfinal), `finalSorted` (`:174`),
>   `finalAlg` (`:172`) (terminal objects).
> * `termEta` (`:296`): the inclusion of variables into the term algebra;
>   `termEval` (`:299`): evaluation of terms in an algebra; `termLift` (`:308`):
>   the recursive extension of a sorted-map. `iAlg` (`:195`), `iPairAlg` (`:198`):
>   the product of a family of algebras and the canonical map into it.
>
> ## Definitions generated in this file
>
> * `congruenceFormationOf Sig F` (`:154`): the congruence formation associated
>   with a class `F` of algebras,
>   `A ↦ { Φ : SortedEqv (Term Sig A) : Φ is a congruence of termAlg Sig A and
>   quotAlg (termAlg Sig A) Φ ∈ F }`.
> * `algebraFormationOfCongruenceFormation Sig G` (`:123`): the algebra class
>   associated with a congruence formation `G`: the algebras isomorphic to
>   quotients `quotAlg (termAlg Sig A) Φ` for some `A` and some `Φ ∈ G A`.
>
> ## Proved theorems
>
> 1. `finiteSSet_of_isAlgIso` (`:1`).
>    Hypotheses: `hf : IsAlgIso Sig FA FB f`; `hA : FiniteSSet A`.
>    Conclusion: `FiniteSSet B`.
>    In words: finiteness of the carrier is transported across an algebra
>    isomorphism (surjectivity of `f` gives a surjection `Σ A → Σ B`).
>
> 2. `congruenceFormationOf_isFiniteIndex` (`:12`).
>    Hypothesis: `hF : F ⊆ algebraFinite Sig` (every algebra in `F` is finite).
>    Conclusion: `∀ A, congruenceFormationOf Sig F A ⊆ congFi Sig (termAlg Sig A).2`.
>    In words: if every algebra in `F` is finite, then every congruence `Φ` of a
>    term algebra whose quotient lies in `F` has finite index.
>
> 3. `algebraFormationOfCongruenceFormation_isFiniteAlgebra` (`:19`).
>    Hypothesis: `hfi : ∀ A, G A ⊆ congFi Sig (termAlg Sig A).2` (all `G`-members
>    have finite index).
>    Conclusion: `algebraFormationOfCongruenceFormation Sig G ⊆ algebraFinite Sig`.
>    In words: if every congruence in `G` has finite index, then every algebra
>    built as a quotient of a term algebra by a `G`-congruence is finite
>    (transporting finiteness across the isomorphism by
>    `finiteSSet_of_isAlgIso`).
>
> 4. `formAlgFFormCgrFiIso` (`:28`).
>    An **order isomorphism**
>    `finiteAlgebraFormations Sig ≃o finiteIndexCongruenceFormations Sig`.
>    * Forward map: a finite algebra formation `F ↦ congruenceFormationOf Sig F`
>      (which is a congruence formation by `congruenceFormation_isCongruenceFormation`
>      and finite-index by `congruenceFormationOf_isFiniteIndex`).
>    * Inverse map: a finite-index congruence formation
>      `G ↦ algebraFormationOfCongruenceFormation Sig G` (an algebra formation by
>      `algebraFormationOfCongruenceFormation_isAlgebraFormation` and finite by
>      `algebraFormationOfCongruenceFormation_isFiniteAlgebra`).
>    * Left/right inverses: the round-trip identities
>      `algebraFormationOfCongruenceFormation (congruenceFormationOf F) = F`
>      (for algebra formations `F`) and
>      `congruenceFormationOf (algebraFormationOfCongruenceFormation G) = G`
>      (for congruence formations `G`).
>    * Order reflection: for formations `F, F'`,
>      `F ≤ F' ↔ congruenceFormationOf F ≤ congruenceFormationOf F'`
>      (pointwise inclusion on each side), using
>      `congruenceFormationOf_mono` and
>      `algebraFormationOfCongruenceFormation_mono`.
>
> ## Interface statements (declared, used as context)
>
> * Round-trip / structural theorems: `algebraFormationOfCongruenceFormation_congruenceFormationOf`
>   (`:136`, algebra formation round-trip), `congruenceFormationOf_algebraFormationOfCongruenceFormation`
>   (`:157`, congruence formation round-trip),
>   `algebraFormationOfCongruenceFormation_isAlgebraFormation` (`:140`),
>   `congruenceFormation_isCongruenceFormation` (`:166`).
> * Monotonicity: `algebraFormationOfCongruenceFormation_mono` (`:145`),
>   `congruenceFormationOf_mono` (`:162`).
> * Closure of the associated algebra class:
>   `algebraFormationOfCongruenceFormation_HOperator` (`:126`): under homomorphic
>   images; `algebraFormationOfCongruenceFormation_PFsdOperator` (`:131`): under
>   subdirect products.
> * `formation_abstract` (`:181`): if `HOperator F ⊆ F`, `A ∈ F`, and `f : A → B`
>   is an algebra isomorphism, then `B ∈ F`.
> * `formation_congInf` (`:185`): if `F` is an algebra formation and `Φ`, `Ψ` are
>   congruences of `A` whose quotients lie in `F`, then the quotient of `A` by
>   `sortedEqvInf Φ Ψ` also lies in `F`.
> * `formation_mem_of_iso` (`:191`): if `HOperator F ⊆ F`, `X ∈ F`, and
>   `f : Y → X` is an algebra isomorphism, then `Y ∈ F`.
> * Products: `isAlgHom_iPairAlg` (`:202`): the canonical map into a product is a
>   homomorphism.
> * Isomorphism algebra: `isAlgIso_symm` (`:212`): the inverse of an algebra
>   isomorphism is an algebra isomorphism.
> * Subfinality: `subfinalAlg_iff` (`:288`): an algebra is subfinal iff its
>   underlying sorted set is subfinal; `subfinalAlg_mem_of_formation` (`:291`):
>   every subfinal algebra belongs to every algebra formation;
>   `quot_nabla_subfinal` (`:277`): the quotient by the universal relation is
>   subfinal.
> * Term algebra universal property: `termEval_isAlgHom` (`:302`),
>   `termEval_surjective` (`:305`), `termLift_eta` (`:313`),
>   `termLift_isAlgHom` (`:317`), `termLift_unique` (`:321`): evaluation of terms
>   is a surjective homomorphism, and `termLift` is the unique homomorphism
>   extending a given sorted map on the variables.
> * Projectivity: `term_projective` (`:327`): given a surjective homomorphism
>   `f : B → C` and a homomorphism `g : Term X → C`, there exists a homomorphism
>   `l : Term X → B` with `f ∘ l = g`. Thus term algebras are **projective**.
> * `wordProd`, `finOp` (`:336`, `:170`): the arity/product types.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P034 verdict
>
> ## Clause-by-clause
>
> **Objects: `Form_{Alg_f}(Σ)` and `Form_{Cgr_fi}(Σ)`.**
> Contract: the complete lattices of finite algebra formations and of finite-index
> congruence formations over Σ. Lean: `finiteAlgebraFormations Sig` and
> `finiteIndexCongruenceFormations Sig`. Match.
>
> **Clause: the two complete lattices are isomorphic.**
> Lean `formAlgFFormCgrFiIso` gives an **order isomorphism**
> `finiteAlgebraFormations Sig ≃o finiteIndexCongruenceFormations Sig`, with:
> - forward map `congruenceFormationOf` (finite-index by
>   `congruenceFormationOf_isFiniteIndex`),
> - inverse map `algebraFormationOfCongruenceFormation` (finite by
>   `algebraFormationOfCongruenceFormation_isFiniteAlgebra`),
> - both round-trip identities, and
> - order reflection `F ≤ F' ↔ congruenceFormationOf F ≤ congruenceFormationOf F'`.
>
> An order isomorphism between two complete lattices is a complete-lattice
> isomorphism (it preserves all existing joins/meets), so this realizes the
> contract's "complete lattices are isomorphic". Match.
>
> Contract clauses with no Lean counterpart: none.
>
> Verdict: equivalent — the order isomorphism with the two inverse maps and the
> order-reflection law is exactly a complete-lattice isomorphism of
> `Form_{Alg_f}(Σ)` and `Form_{Cgr_fi}(Σ)`.

