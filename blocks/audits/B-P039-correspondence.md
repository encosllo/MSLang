# Correspondence audit transcript -- `B-P039`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.sortedEqvInf_self`, `Mslang.IsCongruenceFormation_finset_inf`, `Mslang.langFormationOf_mono`, `Mslang.langCongFormationOf_mono`, `Mslang.langCongFormationOf_langFormationOf`, `Mslang.langFormationOf_langCongFormationOf`, `Mslang.formCgrFiFormLangRIso` (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P039`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000324` (supersedes `E-000199`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is therefore faithful, not a
> weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back: B-P039
>
> ## Setting
>
> Fix a universe `u` and a type `S` of *sorts*. The development has the following
> basic objects (some are abbreviations, declared here without bodies):
>
> - `SSet S` — a *sorted set* over `S`: an `S`-indexed family of types (the carrier
>   of sort `s` is written `A s`).
> - `Sub A` — a *sub-sorted-set* of `A`: an `S`-indexed family of subsets
>   `(s : S) → Set (A s)`.
> - `SortedMap A B` — a *sorted map* from `A` to `B`, i.e. a family of functions
>   `(s : S) → A s → B s`.
> - `SortedEqv A` — a *sorted equivalence relation* on `A`, i.e. a family of
>   setoids `(s : S) → Setoid (A s)`. Its relation at sort `s` is written `(Φ s).r`.
> - `Signature S` — a signature whose operation symbols are indexed by an arity
>   `(p : List S × S)`: `p.1` is the list of input sorts, `p.2` is the output
>   sort. The set of symbols of arity `p` is `Sig p`.
> - `Term Sig X` — the sorted term algebra over a sorted set `X` of variables:
>   an inductive family indexed by output sort. Constructors: `var x` for
>   `x : X s`, and `op p σ a` where `σ : Sig p` and `a i : Term Sig X (p.1.get i)`
>   for each `i : Fin p.1.length`, giving a term of sort `p.2`.
> - `wordProd A w` — the product of the carriers along a word `w : List S`
>   (dependent product `(i : Fin w.length) → A (w.get i)`).
> - `finOp A w s` — the type of `w`-ary operations `wordProd A w → A s`.
> - `Alg Sig` — a sorted algebra; it is used as a structure with `.1 : SSet S`
>   (its carrier) and `.2 : AlgStruct Sig A.1` (its operation interpretation).
> - `AlgStruct Sig A` — an algebra structure (interpretation of the signature's
>   symbols as `finOp` operations) on the sorted set `A`.
> - `supp A : Set S` — the *support* of `A`: the set of sorts with an inhabited
>   carrier.
> - `FiniteSSet A : Prop` — `A` is a finite sorted set.
>
> Two order-theoretic primitives on `SortedEqv A` are declared:
>
> - `sortedEqvLe Φ Ψ : Prop`. Read off from the proofs that use it
>   (`sat_antitone`, `isSat_iff_sortedEqvLe_charEqv`, the antisymmetry theorem
>   and `quotLe`), `sortedEqvLe Φ Ψ` says that every pair related by `Φ` is
>   related by `Ψ`, at each sort: `∀ s x y, (Φ s).r x y → (Ψ s).r x y`. Thus it is
>   the pointwise inclusion/refinement order; *smaller means finer*.
> - `sortedEqvInf Φ Ψ : SortedEqv A` — the binary meet under this order, i.e.
>   the relation whose classes are the common refinement (the intersection) of
>   the `Φ`- and `Ψ`-relations. The theorems below (`sortedEqvInf_self`,
>   `IsCongruence_inf`, `IsFiniteIndex_inf`, `langCongFormationOf_inf`,
>   `langFormationOf_inf`) treat it as the meet of a lattice-like structure.
> - `nabla A : SortedEqv A` — the *universal* (coarsest) sorted equivalence on
>   `A`: all elements of a given inhabited sort are equivalent. It is used as the
>   top element of the order.
>
> Two constructions attached to a sub-sorted-set / relation:
>
> - `pr Φ s : A s → Quotient (Φ s)` — the canonical projection to the quotient by
>   `Φ` at sort `s`. `quot Φ : SSet S` is the quotient sorted set.
> - `prAlg Sig F Φ hΦ : SortedMap A (quotAlg Sig F Φ hΦ).1` — projection to the
>   quotient algebra, where `quotAlg Sig F Φ hΦ : Alg Sig` is the quotient
>   algebra of `A` by the congruence `Φ`. `quotOp Sig F Φ p σ` is the induced
>   operation on the quotient, and `quotOp_mk` records its value on
>   representatives.
> - `quotLift Φ f h : SortedMap (quot Φ) B`, for `h : sortedEqvLe Φ (ker f)`,
>   is the map induced by `f` on the quotient; `quotLe Φ Ψ h : SortedMap (quot Φ)
>   (quot Ψ)` for `h : sortedEqvLe Φ Ψ` is the comparison map between two
>   quotients.
> - `sat Φ X : Sub A` — the saturation of a sub-sorted-set `X` under `Φ` (the
>   union of the `Φ`-classes meeting `X`).
> - `charEqv L : SortedEqv A` — the *characteristic equivalence* of a
>   sub-sorted-set `L`; it is the largest sorted equivalence under which `L` is
>   saturated.
> - `congCogenerated Sig A L : SortedEqv A.1` — the *coarsest congruence* under
>   which `L` is saturated (a congruence is generated from `L`).
> - `congFi Sig F : Set (SortedEqv A)` — the set of *finite-index congruences*
>   on `A`: those `Φ` that are both congruences and of finite index.
> - `deltaSub s Y : Sub A` — the sub-sorted-set concentrated at sort `s` (equal
>   to `Y` at `s`, empty at the other sorts).
> - `directImage f X : Sub B` — image of a sub-sorted-set under a sorted map.
> - `eqvClass Φ s a : Set (A s)` — the equivalence class of `a` in `Φ` at `s`.
> - `ker f : SortedEqv A` — the sorted equivalence kernel of a sorted map
>   `f : SortedMap A B`.
> - `charEqv`, `congCogenerated`, `nabla`, `congFi`, etc. are the objects
>   characterised by the lemmas below.
>
> Predicates:
>
> - `IsSat Φ X : Prop` — `X` is *saturated* by `Φ`, i.e. a union of `Φ`-classes.
> - `IsElemTranslation Sig A t s T : Prop` — the map `T : A.1 t → A.1 s` is an
>   *elementary translation* of the algebra `A` (a unary derived operation: all
>   variables but one are instantiated by elements).
> - `ClosesUnderEtl Sig A Φ : Prop` — `Φ` is compatible with all elementary
>   translations.
> - `TlGen Sig A t s T : Prop` — the inductive class of *translations* generated
>   by: `refl` (the identity), `elem` (every elementary translation is a
>   translation), and `comp` (composition of translations is a translation). Thus
>   `TlGen` is the smallest class of translations containing identities and the
>   elementary translations and closed under composition.
> - `ClosesUnderTl Sig A Φ : Prop` — `Φ` is compatible with all translations.
> - `IsCongruence Sig F Φ : Prop` — `Φ` is a congruence of the algebra `A` (with
>   structure `F`).
> - `IsCongruenceFormation Sig F : Prop` — `F` is a *congruence formation*: for
>   each sorted set `A`, a nonempty set of congruences of the term algebra
>   `Term Sig A`, closed under finite meets. (The proof of
>   `IsCongruenceFormation_finset_inf` uses that `F A` is nonempty and closed
>   under binary meet; the meet of the empty index set is the top relation.)
> - `IsFiniteIndexCongruenceFormation Sig G : Prop` — a congruence formation in
>   which every member has finite index.
> - `IsFiniteIndex Φ : Prop` — `Φ` has finitely many equivalence classes (its
>   quotient is a finite sorted set).
> - `IsAlgHom Sig FA FB f : Prop` — `f` is a homomorphism of sorted algebras.
> - `IsAlgIso Sig FA FB f : Prop` — `f` is an isomorphism of sorted algebras:
>   a homomorphism whose components are bijections (used as `hf.2 s` giving
>   bijectivity of `f s`).
> - `IsRegularLanguage Sig A L : Prop` — the sub-sorted-set `L` of the algebra
>   `A` is regular. From the proof of `exists_regular_infinite_language` this
>   unfolds to `IsFiniteIndex (congCogenerated Sig A L)`.
> - `IsRegularLanguageFormation Sig L : Prop` — `L` is a formation of regular
>   languages: for each `A`, a set of sub-sorted-sets of `Term Sig A`, each
>   regular, closed under the operation that replaces `N, N'` by any `M`
>   saturated by `congCogenerated N ⊓ congCogenerated N'` (used as `hL.2.2.1`).
>
> The two operator families converted into one another:
>
> - `langFormationOf Sig G A` — the set of sub-sorted-sets `L` of `Term Sig A`
>   such that some `Φ ∈ G A` saturates `L` (see `mem_langFormationOf_iff`).
> - `langCongFormationOf Sig L A` — the set of congruences `Φ` of the term
>   algebra over `A` such that every `N ∈ L A` is saturated by `Φ` (its members
>   are pairs: a congruence together with the saturation property).
> - `finiteIndexCongruenceFormations Sig` — the set of all finite-index
>   congruence formations.
> - `regularLanguageFormations Sig` — the set of all regular language
>   formations.
> - `regularLanguages Sig A` — the set of regular languages on `A`.
>
> ## Theorem-by-theorem read-back
>
> 1. `sortedEqvInf_self (Φ : SortedEqv A)`:
>    `sortedEqvInf Φ Φ = Φ`. The meet of a sorted equivalence with itself is
>    itself. (Proved by antisymmetry from the two inclusions, using
>    `sortedEqvLe_antisymm`.)
>
> 2. `IsCongruenceFormation_finset_inf`: Let `Sig` be a signature, `G` a
>    congruence formation, `A` a sorted set, `ι` a finite index type, and
>    `Φ : ι → SortedEqv (Term Sig A)` a family of sorted equivalences with
>    `Φ i ∈ G A` for every `i`. Then the finite meet
>    `(Finset.univ).inf Φ` of the family belongs to `G A`. I.e. congruence
>    formations are closed under finite meets (including the empty meet, which is
>    the top relation, using nonemptiness of `G A`).
>
> 3. `langFormationOf_mono`: If `G A ⊆ G' A` for every sorted set `A`
>    (pointwise inclusion of families of congruences), then
>    `langFormationOf Sig G A ⊆ langFormationOf Sig G' A` for every `A`.
>    Monotonicity of `langFormationOf`.
>
> 4. `langCongFormationOf_mono`: If `L A ⊆ L' A` for every `A` (pointwise
>    inclusion of families of languages), then
>    `langCongFormationOf Sig L A ⊆ langCongFormationOf Sig L' A` for every `A`.
>    Monotonicity of `langCongFormationOf`.
>
> 5. `langCongFormationOf_langFormationOf`: If `G` is a finite-index congruence
>    formation, then
>    `langCongFormationOf Sig (langFormationOf Sig G) = G` (equality of
>    `(A : SSet S) → Set (SortedEqv (Term Sig A))`). The forward inclusion is
>    obtained by taking, for each quotient class `q` of `Φ`, the congruence
>    cogenerated by the atom of `q`; these lie in `G A`, their finite meet (over
>    the finite quotient) lies in `G A` by closure under finite meets, and this
>    meet is below `Φ`, so `Φ ∈ G A` by closure under coarsening.
>
> 6. `langFormationOf_langCongFormationOf`: If `L` is a regular language
>    formation, then
>    `langFormationOf Sig (langCongFormationOf Sig L) = L`. For a language `N`,
>    the forward direction says that `N` is saturated by some congruence in
>    `langCongFormationOf L`; the backward direction constructs the finite-index
>    congruence `congCogenerated N` and uses the regularity/closure of `L`.
>
> 7. `formCgrFiFormLangRIso (hS : Finite S)`:
>    `finiteIndexCongruenceFormations Sig ≃o regularLanguageFormations Sig`, an
>    *order isomorphism* between the two collections. On objects it sends a
>    finite-index congruence formation `G` to `langFormationOf Sig G` and a
>    regular language formation `L` to `langCongFormationOf Sig L`. The two
>    inverse laws are the two equalities above. `map_rel_iff'` states that the
>    order is preserved and reflected: for finite-index formations `G, G'`,
>    `G ≤ G'` (pointwise `⊆`) holds if and only if
>    `langFormationOf G ≤ langFormationOf G'`. Thus the two constructions are an
>    order-theoretic isomorphism, and each operator is monotone in both
>    directions.
>
> 8. `IsCongruence_inf (hΦ : IsCongruence Sig F Φ) (hΨ : IsCongruence Sig F Ψ)`:
>    `IsCongruence Sig F (sortedEqvInf Φ Ψ)`. Congruences are closed under
>    binary meet.
>
> 9. `IsFiniteIndex_inf (hΦ : IsFiniteIndex Φ) (hΨ : IsFiniteIndex Ψ)`:
>    `IsFiniteIndex (sortedEqvInf Φ Ψ)`. Finite-index relations are closed under
>    meet.
>
> 10. `IsFiniteIndex_of_le (h : sortedEqvLe Φ Ψ) (hΦ : IsFiniteIndex Φ)`:
>     `IsFiniteIndex Ψ`. If `Φ` is finer than `Ψ` and `Φ` has finite index, then
>     the coarser `Ψ` has finite index as well.
>
> 11. `closesUnderEtl_of_closesUnderTl (h : ClosesUnderTl Sig A Φ)`:
>     `ClosesUnderEtl Sig A Φ`. Compatibility with all translations implies
>     compatibility with the elementary ones.
>
> 12. `closesUnderEtl_of_isCongruence (h : IsCongruence Sig A.2 Φ)`:
>     `ClosesUnderEtl Sig A Φ`. Every congruence is compatible with elementary
>     translations.
>
> 13. `closesUnderTl_of_closesUnderEtl (h : ClosesUnderEtl Sig A Φ)`:
>     `ClosesUnderTl Sig A Φ`. Compatibility with elementary translations
>     propagates to all translations. (Together, 11 and 13 show the two closure
>     conditions are equivalent.)
>
> 14. `congCogenerated_isCongruence (L : Sub A.1)`:
>     `IsCongruence Sig A.2 (congCogenerated Sig A L)`. The congruence
>     cogenerated by a language is a congruence.
>
> 15. `congCogenerated_le_charEqv`: `sortedEqvLe (congCogenerated Sig A L)
>     (charEqv L)`. The cogenerated congruence refines the characteristic
>     equivalence of `L` (it is contained in it).
>
> 16. `congruence_of_closesUnderEtl (h : ClosesUnderEtl Sig A Φ)`:
>     `IsCongruence Sig A.2 Φ`. Since `Φ` is already a sorted equivalence (a
>     setoid family), closure under elementary translations (combined with 11–13)
>     makes it a congruence.
>
> 17. `finiteSSet_of_isAlgIso (hf : IsAlgIso Sig FA FB f) (hA : FiniteSSet A)`:
>     `FiniteSSet B`. Finiteness of sorted sets is invariant under algebra
>     isomorphism.
>
> 18. `isAlgHom_prAlg (hΦ : IsCongruence Sig F Φ)`:
>     `IsAlgHom Sig F (quotAlg Sig F Φ hΦ).2 (prAlg Sig F Φ hΦ)`. The projection
>     onto the quotient algebra by a congruence is an algebra homomorphism.
>
> 19. `isAlgIso_symm (hf : IsAlgIso Sig FA FB f)`:
>     `IsAlgIso Sig FB FA (fun s => (Equiv.ofBijective (f s) (hf.2 s)).symm)`.
>     The inverse (componentwise inverse bijection) of an algebra isomorphism is
>     again an isomorphism.
>
> 20. `isCongruence_iff_closesUnderEtl`:
>     `IsCongruence Sig A.2 Φ ↔ ClosesUnderEtl Sig A Φ`. A sorted equivalence is
>     a congruence exactly when it is compatible with every elementary
>     translation.
>
> 21. `isFiniteIndex_nabla (h : (supp A).Finite)`:
>     `IsFiniteIndex (nabla A)`. If the support of `A` is finite, the universal
>     sorted equivalence on `A` has finite index (one class per inhabited sort).
>
> 22. `isSat_iff_le_congCogenerated (hΦ : IsCongruence Sig A.2 Φ)`:
>     `IsSat Φ L ↔ sortedEqvLe Φ (congCogenerated Sig A L)`. For a *congruence*
>     `Φ`, saturation of `L` is equivalent to `Φ` being contained in the
>     congruence cogenerated by `L`. This characterises `congCogenerated`
>     as the largest congruence saturating `L`.
>
> 23. `isSat_iff_sortedEqvLe_charEqv`:
>     `IsSat Φ L ↔ sortedEqvLe Φ (charEqv L)`. Saturation by `Φ` is equivalent
>     to `Φ` refining the characteristic equivalence of `L`; this characterises
>     `charEqv L` as the largest sorted equivalence saturating `L`.
>
> 24. `ker_isCongruence (hf : IsAlgHom Sig F G f)`:
>     `IsCongruence Sig F (ker f)`. The kernel of an algebra homomorphism is a
>     congruence on the source.
>
> 25. `langCongFormationOf_inf (hL : IsRegularLanguageFormation Sig L) (A)`:
>     for all `Φ, Ψ ∈ langCongFormationOf Sig L A`, also
>     `sortedEqvInf Φ Ψ ∈ langCongFormationOf Sig L A`. `langCongFormationOf L`
>     is closed under binary meet, when `L` is a regular language formation.
>
> 26. `langCongFormationOf_isFiniteIndexCongruenceFormation (hS : Finite S)
>     (hL : IsRegularLanguageFormation Sig L)`:
>     `IsFiniteIndexCongruenceFormation Sig (langCongFormationOf Sig L)`. For
>     finitely many sorts and a regular language formation `L`, the construction
>     yields a finite-index congruence formation.
>
> 27. `langCongFormationOf_ker (hL : IsRegularLanguageFormation Sig L)
>     (hΘ : IsCongruence Sig (termAlg Sig B).2 Θ) (hΘmem : Θ ∈
>     langCongFormationOf Sig L B) (hf : IsAlgHom Sig ... f)
>     (hsurj : ∀ s, Function.Surjective (fun x => prAlg Sig ... Θ hΘ s (f s x)))`:
>     `ker (fun s => prAlg Sig ... Θ hΘ s ∘ f s) ∈ langCongFormationOf Sig L A`.
>     Transport of membership in `langCongFormationOf` along a surjective
>     homomorphism: if the composite `f` followed by the projection
>     `B → B/Θ` is componentwise onto, then the kernel of that composite belongs
>     to `langCongFormationOf L A`.
>
> 28. `langCongFormationOf_nabla (hS : Finite S) (hL : IsRegularLanguageFormation
>     Sig L) (A)`: `nabla (Term Sig A) ∈ langCongFormationOf Sig L A`. With
>     finitely many sorts, the universal relation on the term algebra lies in
>     `langCongFormationOf L A`.
>
> 29. `langCongFormationOf_up (A)`: for all `Φ ∈ langCongFormationOf Sig L A` and
>     all `Ψ : SortedEqv (Term Sig A)`, if `Ψ` is a congruence and `sortedEqvLe Φ
>     Ψ`, then `Ψ ∈ langCongFormationOf Sig L A`. The set is upward closed under
>     coarsening within the congruences.
>
> 30. `langFormationOf_inf (hG : IsCongruenceFormation Sig G) (A)`: for all
>     `L, L' ∈ langFormationOf Sig G A` and every `N : Sub (Term Sig A)`, if
>     `IsSat (sortedEqvInf (congCogenerated ... L) (congCogenerated ... L')) N`
>     then `N ∈ langFormationOf Sig G A`. The languages in `langFormationOf G A`
>     are closed under the operation of saturating by the meet of two
>     cogenerated congruences.
>
> 31. `langFormationOf_isRegularLanguageFormation (hG :
>     IsFiniteIndexCongruenceFormation Sig G)`:
>     `IsRegularLanguageFormation Sig (langFormationOf Sig G)`. The language
>     formation produced from a finite-index congruence formation is a regular
>     language formation.
>
> 32. `langFormationOf_ker (hG : IsCongruenceFormation Sig G) (A B)`: for all
>     `M ∈ langFormationOf Sig G B` and all algebra homomorphisms `f : Term Sig A
>     → Term Sig B` whose composite with the projection to
>     `B / congCogenerated M` is componentwise surjective, and for every
>     `N : Sub (Term Sig A)` saturated by `ker (pr ∘ f)`, `N ∈ langFormationOf
>     Sig G A`. A transport (kernels of quotients) closure property.
>
> 33. `langFormationOf_nabla (hG : IsCongruenceFormation Sig G) (A)`: for every
>     `L : Sub (Term Sig A)`, if `IsSat (nabla (Term Sig A)) L` then
>     `L ∈ langFormationOf Sig G A`. Any language saturated by the universal
>     relation (i.e. each sort's part is empty or full) lies in
>     `langFormationOf G A`.
>
> 34. `le_congCogenerated_of_isCongruence (hΦ : IsCongruence Sig A.2 Φ)
>     (h : sortedEqvLe Φ (charEqv L))`:
>     `sortedEqvLe Φ (congCogenerated Sig A L)`. Every congruence below the
>     characteristic equivalence of `L` lies below the congruence cogenerated by
>     `L`; hence `congCogenerated` is the greatest congruence refining
>     `charEqv L`.
>
> 35. `mem_langFormationOf_iff (hG : IsCongruenceFormation Sig G) (A) (L)`:
>     `L ∈ langFormationOf Sig G A ↔ ∃ Φ ∈ G A, IsSat Φ L`. Membership
>     characterisation of `langFormationOf`: a language is in it exactly when some
>     congruence in `G A` saturates it.
>
> 36. `nabla_isCongruence (F : AlgStruct Sig A)`:
>     `IsCongruence Sig F (nabla A)`. The universal relation is a congruence of
>     any algebra structure on `A`.
>
> 37. `quotAlgLift_isAlgHom (hΦ : IsCongruence Sig F Φ) (hf : IsAlgHom Sig F G f)
>     (h : sortedEqvLe Φ (ker f))`:
>     `IsAlgHom Sig (quotAlg Sig F Φ hΦ).2 G (quotLift Φ f h)`. The universal
>     property of the quotient: a homomorphism `f` that coarsens `Φ` factors
>     through the quotient as a homomorphism.
>
> 38. `quotAlg_ker_isAlgIso (hf : IsAlgHom Sig FA FB f)
>     (hsurj : ∀ s, Function.Surjective (f s))`:
>     `IsAlgIso Sig (quotAlg Sig FA (ker f) (ker_isCongruence ...)).2 FB
>     (quotLift (ker f) f (fun _ _ _ h => h))`. The first isomorphism theorem:
>     a surjective homomorphism induces an isomorphism from the quotient by its
>     kernel onto the target.
>
> 39. `quotLe_mk (h : sortedEqvLe Φ Ψ) (s) (a : A s)`:
>     `quotLe Φ Ψ h s (Quotient.mk (Φ s) a) = Quotient.mk (Ψ s) a`. The
>     comparison map between quotients sends the `Φ`-class of `a` to the
>     `Ψ`-class of `a`.
>
> 40. `quotOp_mk (hΦ : IsCongruence Sig F Φ) (p) (σ : Sig p)
>     (a : wordProd A p.1)`:
>     `quotOp Sig F Φ p σ (fun i => Quotient.mk (Φ (p.1.get i)) (a i)) =
>     Quotient.mk (Φ p.2) (F p σ a)`. The induced operation on the quotient
>     computed on representatives equals the class of the original operation
>     applied to the representatives; i.e. `quotOp` is the well-defined
>     representative-level interpretation.
>
> 41. `sat_antitone (h : sortedEqvLe Φ Ψ) (hX : IsSat Ψ X)`:
>     `IsSat Φ X`. Saturation is antitone in the relation: if `Φ` is finer than
>     `Ψ` and `X` is `Ψ`-saturated, then `X` is `Φ`-saturated.
>
> 42. `sat_idem (Φ) (X)`: `sat Φ (sat Φ X) = sat Φ X`. Saturation is idempotent.
>
> ## Summary of the mathematical content
>
> Sorted sets, sorted maps, sorted equivalence relations, sub-sorted-sets and
> sorted algebras with signatures are set up. `SortedEqv A` carries a partial
> order `sortedEqvLe` (pointwise relation inclusion, finer = smaller), with meet
> `sortedEqvInf` and a top element `nabla`; `sortedEqvLe_antisymm` makes it a
> partial order. Congruences (equivalently, sorted equivalences closed under
> elementary translations) are closed under meet; finite-index relations are
> closed under meet and under coarsening. The quotient construction is developed
> with the expected universal property and first isomorphism theorem.
>
> Two operators are related by an adjunction-like/order-isomorphism pair: from a
> finite-index congruence formation `G` one builds the regular language formation
> `langFormationOf G`, and from a regular language formation `L` one builds the
> finite-index congruence formation `langCongFormationOf L`; each is monotone,
> they are mutually inverse, and for finitely many sorts they form an order
> isomorphism `formCgrFiFormLangRIso`. Membership in `langFormationOf G A` is
> exactly "saturated by some member of `G A`". Several closure/transport
> properties of both constructions are established (closure under meet, upward
> closure under coarsening, behaviour under kernels of surjective homomorphisms,
> and inclusion of the universal-relation-saturated languages).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P039 verdict
>
> Contract clause 1: "The complete lattices Form_{Cgr_fi}(Σ) and Form_{Lang_r}(Σ)
> are isomorphic."
>
> - Lean counterpart: `formCgrFiFormLangRIso` (under the standing `[Finite S]`)
>   is an order isomorphism
>   `finiteIndexCongruenceFormations Sig ≃o regularLanguageFormations Sig`,
>   i.e. between Form_{Cgr_fi} and Form_{Lang_r}. By `map_rel_iff'` it preserves
>   and reflects the pointwise-inclusion order, with the two inverse laws supplied
>   by `langCongFormationOf_langFormationOf` and
>   `langFormationOf_langCongFormationOf`.
> - Both sides are complete lattices (`finiteIndexCongruenceFormationsCompleteLattice`,
>   `regularLanguageFormations_completeLattice`), so an order isomorphism between
>   them is exactly a complete-lattice isomorphism (an order isomorphism preserves
>   all joins and meets). The clause is matched.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the read-back yields an order isomorphism of the two
> complete lattices, which is precisely their isomorphism as complete lattices,
> with `[Finite S]` from the standing assumption.

