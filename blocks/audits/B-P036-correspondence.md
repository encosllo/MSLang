# Correspondence audit transcript -- `B-P036`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.regularLanguageFormations_completeLattice` (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P036`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000321` (supersedes `E-000252`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is therefore faithful, not a
> weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-P036 — informal read-back
>
> ## Setting
>
> `S` is a fixed type of *sorts* (written `Type u`). Throughout, `SSet S` is the
> type of `S`-sorted sets: a term of `SSet S` is a family `s ↦ A s` of types. A
> `Signature S` is a many-sorted algebraic signature (operation symbols, each with
> a finite list of input sorts and one output sort). `Sub A` is the type of
> sub-sorted-sets of `A` (a family of subsets, one per sort). `SortedMap A B` is
> the type of sort-preserving maps. `SortedEqv A` is a *sorted equivalence*: a
> family, one equivalence relation on `A s` for each sort `s`. `Term Sig X` is the
> inductive type of many-sorted terms built from variables in the sorted set `X`
> and the operation symbols of `Sig`.
>
> The development is organized around an order on sorted equivalences:
> `sortedEqvLe Φ Ψ` means **Φ refines Ψ** (Φ is the finer relation; as relations
> `Φ ⊆ Ψ`). `sortedEqvInf Φ Ψ` is the binary meet (the intersection/refinement
> infimum). `sortedEqvLe_antisymm` makes this a partial order. `IsSat Φ X` means
> the sub-sorted-set `X` is *saturated* by `Φ` (is a union of Φ-classes). `sat Φ X`
> is the saturation of `X` (smallest saturated set containing `X`).
>
> Two notions of "translations" are used: `IsElemTranslation Sig A t s T` says a
> map `T : A t → A s` is an elementary translation of the algebra `A`. `TlGen Sig A
> t s T` is the inductive closure saying `T` is a translation: it contains the
> identities (`refl`), all elementary translations (`elem`), and is closed under
> composition (`comp`).
>
> `AlgStruct Sig A` is an algebra structure on a sorted set `A`. `IsAlgHom Sig FA
> FB f` says `f` is a homomorphism; `IsAlgIso` says it is an isomorphism.
> `IsCongruence Sig F Φ` says `Φ` is a congruence of the algebra `(A,F)`.
> `FiniteSSet A` says `A` is finite (finitely many elements across sorts).
> `supp A` is the support (set of sorts that are nonempty). `IsFiniteIndex Φ` says
> `Φ` has finitely many equivalence classes.
>
> A *formation* is a family `G : (A : SSet S) → Set (SortedEqv (Term Sig A))`,
> i.e. it assigns to each sorted set `A` a set of sorted equivalences on the term
> algebra over `A`. `IsCongruenceFormation Sig G` says `G` is a congruence
> formation. `IsFiniteIndexCongruenceFormation Sig G` strengthens this to
> finite-index congruences. Dually, a *language formation* is a family
> `L : (A : SSet S) → Set (Sub (Term Sig A))` assigning to each `A` a set of
> languages (sub-sorted-sets of the term algebra over `A`);
> `IsRegularLanguageFormation Sig L` says `L` is a regular-language formation.
> `regularLanguageFormations Sig` is the set of all regular-language formations,
> and `regularLanguages Sig A` is the set of regular languages of an algebra `A`.
>
> ## Lattice / completeness results
>
> - `regularLanguageFormations_completeLattice` (requires `[Finite S]`): the
>   collection `regularLanguageFormations Sig` carries a complete lattice
>   structure, obtained from `regularLanguageFormationsCompleteLattice`.
> - `regularLanguageFormationsCompleteLattice` (requires `[Finite S]`): that
>   `CompleteLattice` instance.
> - `finiteIndexCongruenceFormations Sig`: the set of all finite-index congruence
>   formations.
> - `finiteIndexCongruenceFormationsCompleteLattice` (requires `[Finite S]`):
>   complete lattice structure on that set.
> - `finiteIndexCongruenceFormationsInf Sig T`: the infimum of a set `T` of
>   finite-index congruence formations.
> - `finiteIndexCongruenceFormationsTop Sig`: the top element.
> - `finiteIndexCongruenceFormations_isGLB_sInf`: for every `T`, the element
>   `finiteIndexCongruenceFormationsInf Sig T` is the greatest lower bound
>   (`IsGLB T ...`) of `T`. So the infimum computed above is the true meet.
>
> ## Closure of congruence formations
>
> - `IsCongruenceFormation_finset_inf`: if `G` is a congruence formation, `A` is a
>   sorted set, `ι` is a finite index type, and `Φ : ι → SortedEqv (Term Sig A)`
>   satisfies `Φ i ∈ G A` for all `i`, then the finite meet
>   `(Finset.univ).inf Φ` belongs to `G A`. (Closure of each `G A` under finite
>   meets.)
> - `IsCongruence_inf`: for a fixed algebra `(A,F)`, if `Φ` and `Ψ` are
>   congruences then their inf `sortedEqvInf Φ Ψ` is a congruence.
> - `IsFiniteIndex_inf`: if `Φ` and `Ψ` are finite-index sorted equivalences, then
>   `sortedEqvInf Φ Ψ` is finite-index.
> - `IsFiniteIndex_of_le`: if `Φ ≤ Ψ` (Φ refines Ψ) and `Φ` is finite-index, then
>   `Ψ` is finite-index (coarsening a finite-index relation stays finite-index).
>
> ## Translations and congruences
>
> - `closesUnderEtl_of_closesUnderTl`: if `Φ` is closed under all translations
>   (`ClosesUnderTl`), then it is closed under elementary translations
>   (`ClosesUnderEtl`).
> - `closesUnderEtl_of_isCongruence`: a congruence of `A` is Etl-closed.
> - `closesUnderTl_of_closesUnderEtl`: an Etl-closed equivalence is Tl-closed.
> - `congruence_of_closesUnderEtl`: an Etl-closed sorted equivalence is a
>   congruence.
> - `isCongruence_iff_closesUnderEtl`: for any algebra `A` and sorted equivalence
>   `Φ`, `Φ` is a congruence **iff** `Φ` is Etl-closed (combining the two
>   directions above).
>
> ## Cogenerated congruence, characteristic equivalence, saturation
>
> - `charEqv L`: the characteristic sorted equivalence of a sub-sorted-set `L`
>   (the coarsest equivalence making `L` a union of classes).
> - `congCogenerated Sig A L`: the congruence *cogenerated* by `L` (the coarsest
>   congruence saturating `L`).
> - `congCogenerated_isCongruence`: `congCogenerated Sig A L` is a congruence.
> - `congCogenerated_le_charEqv`: `congCogenerated Sig A L ≤ charEqv L` (the
>   coarsest congruence saturating `L` refines the coarsest equivalence saturating
>   `L`).
> - `isSat_iff_le_congCogenerated`: for a **congruence** `Φ` on algebra `A`, `Φ`
>   saturates `L` iff `Φ ≤ congCogenerated Sig A L`.
> - `isSat_iff_sortedEqvLe_charEqv`: for any sorted equivalence `Φ`, `Φ` saturates
>   `L` iff `Φ ≤ charEqv L`.
> - `le_congCogenerated_of_isCongruence`: if `Φ` is a congruence and
>   `Φ ≤ charEqv L`, then `Φ ≤ congCogenerated Sig A L` (the two bounding
>   conditions agree on congruences).
> - `sat_antitone`: if `Φ ≤ Ψ` and `Ψ` saturates `X`, then `Φ` saturates `X`
>   (saturation is antitone in the refinement order).
> - `sat_idem`: `sat Φ (sat Φ X) = sat Φ X` (saturation is idempotent).
> - `IsSat Φ X` is the underlying membership predicate used by `sat`.
>
> ## Quotients and the first isomorphism theorem
>
> - `pr Φ s : A s → Quotient (Φ s)`: projection to the quotient at sort `s`.
> - `quot Φ`: the quotient sorted set of `A` by `Φ`.
> - `quotAlg Sig F Φ hΦ`: the quotient algebra (requiring `hΦ : IsCongruence`).
> - `prAlg Sig F Φ hΦ`: the projection map `A → quotAlg`.
> - `isAlgHom_prAlg`: this projection is an algebra homomorphism.
> - `quotOp Sig F Φ p σ`: the operation induced on the quotient by an operation
>   symbol `σ` of arity `p`.
> - `quotOp_mk`: on representatives, `quotOp ... (fun i => mk (a i)) = mk (F p σ
>   a)`; i.e. the induced operation is well defined and computes as in `A`.
> - `quotLe Φ Ψ h` (for `h : Φ ≤ Ψ`): the canonical map `quot Φ → quot Ψ`.
> - `quotLe_mk`: it sends the class of `a` under `Φ` to the class of `a` under
>   `Ψ`.
> - `quotLift Φ f h` (for `h : Φ ≤ ker f`): the map `quot Φ → B` that factors `f`
>   through the quotient.
> - `quotAlgLift_isAlgHom`: if `f` is an algebra homomorphism and `Φ ≤ ker f`,
>   then the lifted map `quotLift Φ f h` is an algebra homomorphism out of the
>   quotient algebra.
> - `quotAlg_ker_isAlgIso`: **first isomorphism theorem**: if `f : A → B` is a
>   surjective algebra homomorphism, then the lifted map from `A / ker f` to `B`
>   is an algebra isomorphism.
> - `ker f`: the kernel sorted equivalence of a sorted map `f`.
> - `ker_isCongruence`: the kernel of an algebra homomorphism is a congruence.
> - `isFiniteIndex_ker_of_finite`: if `f : A → B` and `B` is a finite sorted set,
>   then `ker f` has finite index.
> - `isFiniteIndex_nabla`: if the support of `A` is finite, then the universal
>   equivalence `nabla A` has finite index.
> - `nabla A`: the universal (coarsest) sorted equivalence on `A` (all elements of
>   each sort related).
> - `nabla_isCongruence`: `nabla A` is a congruence of any algebra structure on
>   `A`.
>
> ## Regularity, formations, and the two translations
>
> - `langCongFormationOf Sig L`: the map taking a language formation `L` to the
>   congruence formation `A ↦ { Φ : Φ is a finite-index congruence on the term
>   algebra over `A`, and every `N` saturated by `Φ` lies in `L A` }`.
> - `langFormationOf Sig G`: the inverse-style construction taking a congruence
>   formation `G` to the language formation `A ↦ { L : ∃ Φ ∈ G A, Φ saturates L }`
>   (this is exactly `mem_langFormationOf_iff`).
> - `mem_langFormationOf_iff`: `L ∈ langFormationOf Sig G A` iff there exists
>   `Φ ∈ G A` such that `IsSat Φ L`.
> - `langFormationOf_isRegularLanguageFormation`: if `G` is a finite-index
>   congruence formation, then `langFormationOf Sig G` is a regular-language
>   formation.
> - `langFormationOf_nabla`: if `G` is a congruence formation, then every language
>   `L` saturated by `nabla (Term Sig A)` belongs to `langFormationOf Sig G A`.
> - `langFormationOf_inf`: if `G` is a congruence formation and `L, L' ∈
>   langFormationOf Sig G A`, then any `N` saturated by the meet of the two
>   cogenerated congruences `congCogenerated (termAlg A) L` and
>   `congCogenerated (termAlg A) L'` belongs to `langFormationOf Sig G A`.
> - `langFormationOf_ker`: if `G` is a congruence formation, `M ∈ langFormationOf
>   Sig G B`, and `f : Term A → Term B` is an algebra homomorphism whose composite
>   with the projection onto `Term B / congCogenerated M` is surjective in every
>   sort, then for any `N` saturated by the kernel of that composite, `N ∈
>   langFormationOf Sig G A`. (Closure under inverse images along surjective
>   homomorphisms.)
> - `langFormationOf_mono`: if `G A ⊆ G' A` for all `A`, then `langFormationOf Sig
>   G A ⊆ langFormationOf Sig G' A` for all `A` (monotonicity).
> - `langFormationOf_langCongFormationOf`: for a regular-language formation `L`,
>   `langFormationOf Sig (langCongFormationOf Sig L) = L`.
> - `langCongFormationOf_isFiniteIndexCongruenceFormation`: if `L` is a
>   regular-language formation, then `langCongFormationOf Sig L` is a finite-index
>   congruence formation.
> - `langCongFormationOf_inf`: if `L` is a regular-language formation, then the
>   set of congruences `langCongFormationOf Sig L A` is closed under binary meets
>   (as a pointwise statement over members).
> - `langCongFormationOf_up`: `langCongFormationOf Sig L A` is upward closed under
>   coarsening by congruences: if `Φ` is a member and `Ψ` is a congruence with
>   `Φ ≤ Ψ`, then `Ψ` is a member.
> - `langCongFormationOf_ker`: closure of `langCongFormationOf Sig L A` under
>   kernels of the appropriate surjective homomorphisms (if `Θ ∈
>   langCongFormationOf Sig L B` and `f` induces a surjection onto the quotient by
>   `Θ`, then the kernel of the composite lies in `langCongFormationOf Sig L A`).
> - `langCongFormationOf_nabla` (requires `[Finite S]`): if `L` is a regular
>   language formation, then `nabla (Term Sig A) ∈ langCongFormationOf Sig L A`.
> - `langCongFormationOf_mono`: monotonicity in `L`: if `L A ⊆ L' A` for all `A`,
>   then `langCongFormationOf Sig L A ⊆ langCongFormationOf Sig L' A` for all `A`.
> - `formCgrFiFormLangRIso` (requires `[Finite S]`): an **order isomorphism**
>   `finiteIndexCongruenceFormations Sig ≃o regularLanguageFormations Sig`. This
>   exhibits the pair `langCongFormationOf` / `langFormationOf` as a
>   Galois/duality correspondence (the Eilenberg-type correspondence at the level
>   of finite-index congruence formations and regular-language formations).
> - `finiteSSet_of_isAlgIso`: if `f` is an algebra isomorphism `A → B` and `A` is
>   finite, then `B` is finite.
> - `isAlgIso_symm`: the pointwise inverse of an algebra isomorphism is again an
>   algebra isomorphism.
>
> ## Auxiliary constructions
>
> - `deltaSub s Y`: the sub-sorted-set supported at sort `s` with value `Y`.
> - `directImage f X`: the image of a sub-sorted-set `X` under a sorted map `f`.
> - `eqvClass Φ s a`: the `Φ`-equivalence class of `a ∈ A s`.
> - `finOp A w s`: the type of operations on `A` with input word `w` and output
>   sort `s`.
> - `wordProd A w`: the product `∏ A (w i)` over a word of sorts `w`.
> - `congFi Sig F`: the set of finite-index congruences on the algebra `F` on `A`
>   (membership carries both congruence and finite-index data).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P036 verdict
>
> Contract clause 1: "Form_{Lang_r}(Σ) is a complete lattice."
>
> - Lean counterpart: `regularLanguageFormations Sig` is the collection
>   Form_{Lang_r}; `regularLanguageFormations_completeLattice` (under the standing
>   `[Finite S]`) supplies the `CompleteLattice` instance, via
>   `regularLanguageFormationsCompleteLattice`. The contract's single clause is
>   matched exactly.
> - The many other read-back declarations (congruence/translation closure,
>   quotients, the order isomorphism, etc.) are surrounding context for the same
>   section and do not modify the clause.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the read-back asserts precisely the claimed complete
> lattice structure on Form_{Lang_r}, with `[Finite S]` from the standing
> assumption.

