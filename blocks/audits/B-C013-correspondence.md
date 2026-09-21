# Correspondence audit transcript -- `B-C013`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.regularLanguageFormationsCompleteLattice`, `Mslang.regularLanguageFormations_isAlgebraicLattice` (`lean/Mslang/Regular.lean`)
- **Contract:** Corollary `B-C013`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000294` (supersedes `E-000232`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is therefore faithful, not a
> weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-C013 — informal mathematical read-back
>
> ## 0. Setting and basic objects
>
> `S : Type u` is a fixed type of **sorts**, `Sig : Signature S` a fixed many-sorted
> signature. The ambient objects are:
>
> - `SSet S` — a many-sorted set, i.e. a type family `S → Type u`.
> - `Signature S` — operation symbols indexed by profiles `p : List S × S`; a symbol
>   `σ : Sig p` with `p = (w, s)` has input word `w` and output sort `s`.
> - `wordProd A w` — the product `∏_{i : Fin w.length} A (w.get i)`, and `finOp A w s`
>   is `wordProd A w → A s`.
> - `Alg Sig` — algebras `X = (X.1, X.2)`, with `X.1 : SSet S` the carrier and
>   `X.2 : AlgStruct Sig X.1` the interpretation. `AlgStruct Sig A` is the structure on `A`.
> - `Term Sig X` — the inductive type of terms over generators `X` (free algebra).
> - `SortedEqv A` — a sorted equivalence relation on `A` (a family of equivalence relations
>   on each `A s`).
> - `SortedMap A B` — a sorted map (family `A s → B s`).
> - `Sub A` — a sorted subset (family `Set (A s)`).
> - `supp A` — the support of `A` (sorts with nonempty fiber); `suppAlg X` for an algebra.
>
> This file contains the whole core of `B-C012` (many-sorted algebras, congruences,
> quotients, term algebras, formations and their lattices) **plus** a translation-based and
> a regular-language layer. All of it is restated below so the read-back is self-contained.
>
> ## 1. Homomorphisms, congruences, subalgebras, finiteness
>
> - `IsAlgHom Sig FA FB f` — homomorphism from `(A, FA)` to `(B, FB)`.
> - `IsAlgIso Sig FA FB f` — isomorphism (homomorphism, sortwise bijective; the file uses
>   `hf.2 s`, so bijectivity is the second component).
> - `IsMonoAlg Sig FA FB f` — injective homomorphism. `IsEpiAlg Sig FA FB f` — surjective
>   homomorphism.
> - `IsCongruence Sig F Φ` — `Φ` is a congruence of the algebra `(A, F)`.
> - `IsSubalgebra Sig F X` — sorted subset `X` is a subuniverse (closed under operations).
> - `IsSubdirectEmbedding Sig FA Ai f` — `f` is a subdirect embedding of `A` into a product
>   family `Ai`.
> - `Subfinal A` / `SubfinalAlg Sig X` — subfinal (at most one element per sort, a
>   subalgebra of the terminal algebra); `subfinalAlg_iff` identifies the two.
> - `FiniteAlg X` — the algebra `X` is finite. `FiniteSSet A` — the many-sorted set `A` is
>   finite.
> - `IsFiniteIndex Φ` — the sorted equivalence `Φ` has finitely many classes.
> - `IsCongruenceFormation Sig G` for
>   `G : (A : SSet S) → Set (SortedEqv (Term Sig A))` — `G` is a congruence formation; its
>   concrete closure is fixed by the theorems below (closed under finite infima, upward
>   under coarsening, stable under the term-algebra operations).
> - `IsFiniteIndexCongruenceFormation Sig G` — a congruence formation all of whose members
>   have finite index.
> - `IsAlgebraFormation Sig F` — `F : Set (Alg Sig)` is an algebra formation (closed under
>   homomorphic images and finite subdirect products, and containing the subfinal algebras).
> - `IsFiniteAlgebraFormation Sig F` — a formation of finite algebras.
> - `IsAlgebraicLattice L` (with a `CompleteLattice L`) — `L` is an algebraic lattice.
>   `IsCompact a` — `a` is a compact element.
> - `algebraFinite Sig` — the class of finite algebras.
>
> ## 2. Monotone class operators
>
> - `HOperator Sig F` — homomorphic images of members of `F`.
> - `PFsdOperator Sig F` — finite subdirect products of members of `F`.
> - `HOperator_mono`: `F ⊆ G ⇒ HOperator F ⊆ HOperator G`.
> - `PFsdOperator_mono`: `F ⊆ G ⇒ PFsdOperator F ⊆ PFsdOperator G`.
> - `algebraFinite_closed_HOperator`: `HOperator (algebraFinite) ⊆ algebraFinite`.
> - `algebraFinite_closed_PFsdOperator` (`[Finite S]`):
>   `PFsdOperator (algebraFinite) ⊆ algebraFinite`.
> - `formation_abstract`: if `HOperator F ⊆ F`, `A ∈ F`, and `f : A.1 → B.1` is an algebra
>   isomorphism, then `B ∈ F`.
> - `formation_mem_of_iso`: if `HOperator F ⊆ F`, `X ∈ F`, and `Y ≅ X`, then `Y ∈ F`.
> - `formation_congInf`: if `F` is an algebra formation, `A` an algebra, `Φ, Ψ`
>   congruences of `A` with `A/Φ, A/Ψ ∈ F`, then `A/(Φ ⊓ Ψ) ∈ F`.
> - `subfinalAlg_mem_of_formation`: every algebra formation contains every subfinal algebra.
> - `exists_mem_superset_finset`: if `D` is nonempty and directed (any two members are
>   contained in a third member of `D`), then every finite subfamily of `D` has an upper
>   bound in `D`.
>
> ## 3. Formations from congruence families, and back
>
> - `congFi Sig F` for `F : AlgStruct Sig A` — the set of finite-index congruences of `A`.
> - `congruenceFormationOf Sig F` — for a class of algebras `F`, assigns to `A` the
>   congruences `Θ` on `Term Sig A` with `Term Sig A / Θ ∈ F`.
> - `algebraFormationOfCongruenceFormation Sig G` — for a congruence family `G`, the class
>   of algebras obtained as quotients of their term algebras by congruences of `G`.
>   - `congruenceFormationOf_algebraFormationOfCongruenceFormation`: for a congruence
>     formation `G`, the round trip `congruenceFormationOf (algebraFormationOfCongruenceFormation G) = G`.
>   - `algebraFormationOfCongruenceFormation_congruenceFormationOf`: for an algebra
>     formation `F`, `algebraFormationOfCongruenceFormation (congruenceFormationOf F) = F`.
>   - `algebraFormationOfCongruenceFormation_HOperator` (for congruence formation `G`):
>     the associated class is closed under homomorphic images.
>   - `algebraFormationOfCongruenceFormation_PFsdOperator`: closed under finite subdirect
>     products.
>   - `algebraFormationOfCongruenceFormation_isAlgebraFormation`: it is an algebra
>     formation.
>   - `algebraFormationOfCongruenceFormation_isFiniteAlgebra`: if every `G A` consists of
>     finite-index congruences on the term algebra over `A`, the associated class consists
>     of finite algebras.
>   - `algebraFormationOfCongruenceFormation_mono`: pointwise `G A ⊆ G' A` gives
>     inclusion of the associated classes.
>   - `congruenceFormationOf_isFiniteIndex`: if `F ⊆ algebraFinite`, then every member of
>     `congruenceFormationOf F A` has finite index.
>   - `congruenceFormationOf_mono`: `F ⊆ F'` gives
>     `congruenceFormationOf F A ⊆ congruenceFormationOf F' A`.
>   - `congruenceFormation_isCongruenceFormation`: an algebra formation yields a
>     congruence formation.
>
> ## 4. Translations and the translation characterisation of congruences
>
> - `IsElemTranslation Sig A t s T`, `T : A.1 t → A.1 s`: `T` is an **elementary
>   translation** — a unary derived operation obtained by applying one operation symbol with
>   all but one argument fixed to elements of `A`, varying the remaining one.
> - `TlGen Sig A` is an inductive predicate on maps `A.1 t → A.1 s`:
>   - `refl`: the identity is generated;
>   - `elem`: every elementary translation is generated;
>   - `comp`: generated maps are closed under composition.
>   So `TlGen Sig A t s T` says `T` is a finite composite of elementary translations
>   (a **translation**).
> - `ClosesUnderTl Sig A Φ` — the sorted equivalence `Φ` is compatible with all
>   translations. `ClosesUnderEtl Sig A Φ` — compatible with all extended translations.
> - `closesUnderEtl_of_closesUnderTl`: `ClosesUnderTl ⇒ ClosesUnderEtl`.
> - `closesUnderTl_of_closesUnderEtl`: `ClosesUnderEtl ⇒ ClosesUnderTl`. (The two closure
>   conditions are equivalent.)
> - `closesUnderEtl_of_isCongruence`: every congruence is closed under extended
>   translations.
> - `congruence_of_closesUnderEtl`: a sorted equivalence closed under extended translations
>   is a congruence.
> - `isCongruence_iff_closesUnderEtl`: **`IsCongruence Sig A.2 Φ ↔ ClosesUnderEtl Sig A Φ`**
>   (and, via the preceding, `↔ ClosesUnderTl`). This is the classical result that
>   congruences are exactly the equivalence relations compatible with all translations.
>
> ## 5. Saturation, characteristic equivalence, cogenerated congruence
>
> - `IsSat Φ X`, `X : Sub A`: the subuniverse `X` is **saturated** by `Φ`, i.e. `X` is a
>   union of `Φ`-classes.
> - `charEqv L` for `L : Sub A`: the **characteristic equivalence** of `L`, the sorted
>   equivalence relating two elements exactly when they cannot be separated by membership in
>   `L` under translations.
> - `congCogenerated Sig A L` for `A : Alg Sig`, `L : Sub A.1`: the **congruence cogenerated
>   by `L`**, i.e. the finest congruence saturating `L`.
>   - `congCogenerated_isCongruence`: `congCogenerated Sig A L` is a congruence.
>   - `congCogenerated_le_charEqv`:
>     `congCogenerated Sig A L ≤ charEqv L` (the cogenerated congruence is finer than the
>     characteristic equivalence).
>   - `le_congCogenerated_of_isCongruence`: for a congruence `Φ`, if `Φ ≤ charEqv L` then
>     `Φ ≤ congCogenerated Sig A L`. Hence `congCogenerated L` is the **greatest** congruence
>     below `charEqv L`.
> - `sat Φ X` — the saturation of `X` by `Φ`.
>   - `sat_antitone`: if `Φ ≤ Ψ` and `X` is `Ψ`-saturated, then `X` is `Φ`-saturated
>     (finer relations saturate fewer sets).
>   - `sat_idem`: `sat Φ (sat Φ X) = sat Φ X`.
> - Equivalence-order facts:
>   - `sortedEqvInf_self`: `Φ ⊓ Φ = Φ`.
>   - `sortedEqvLe_antisymm`: `Φ ≤ Ψ` and `Ψ ≤ Φ` imply `Φ = Ψ` (the refinement order is a
>     partial order).
> - Subset helpers: `deltaSub s Y` (the subuniverse concentrated in sort `s` on `Y`),
>   `directImage f X` (direct image under a sorted map), `eqvClass Φ s a` (the `Φ`-class of
>   `a` at sort `s`).
>
> ## 6. Term algebras, quotients, kernels, products
>
> - `termAlg Sig X` — the term algebra on generators `X`; `termEta` the generator insertion;
>   `termEval Sig A : Term Sig A.1 → A.1` the term-evaluation homomorphism.
>   - `termEval_isAlgHom`, `termEval_surjective` (every element is a value of a term).
>   - `termLift Sig X FA g` — the unique homomorphic extension of `g : X → A` (defined by
>     recursion on terms); `termLift_eta` (`termLift ∘ termEta = g`),
>     `termLift_isAlgHom`, `termLift_unique` (universal property).
>   - `term_projective`: if `f : B → C` is a surjective homomorphism and `g : Term Sig X → C`
>     a homomorphism, there is a homomorphism `l : Term Sig X → B` with `f ∘ l = g`.
> - `pr Φ`, `quot Φ`, `prAlg`, `quotAlg` — canonical projection, quotient sorted set, and
>   quotient algebra.
>   - `isAlgHom_prAlg`; `quotOp` and `quotOp_mk` (quotient operations computed on
>     representatives); `quot_nabla_subfinal` (`A/∇_A` is subfinal).
> - `ker f` — kernel; `ker_isCongruence` (kernel of a homomorphism is a congruence);
>   `ker_pr`, `ker_prAlg` (`ker (prAlg Φ) = Φ`); `nabla A` and `nabla_isCongruence`.
> - `quotLift Φ f h` for `h : Φ ≤ ker f` — induced map `A/Φ → B`; `quotLift_comp`
>   (`quotLift ∘ pr = f`); `quotAlgLift_isAlgHom` (it is a homomorphism when `f` is);
>   `quotAlg_ker_isAlgIso` (first isomorphism theorem for surjective homomorphisms).
> - `quotLe Φ Ψ h` for `h : Φ ≤ Ψ` — induced map `A/Φ → A/Ψ`; `quotLe_mk` (sends the
>   `Φ`-class of `a` to the `Ψ`-class of `a`).
> - `iAlg Sig A` — product of a family of algebras; `iPairAlg` the induced map into the
>   product; `isAlgHom_iPairAlg`; `isAlgIso_symm` (isomorphism is symmetric);
>   `suppAlg_iAlg` (support of a product is the intersection of the supports).
> - `subAlg Sig F X hX` — the subalgebra of `(A, F)` with carrier `X`.
> - Relation infrastructure: `sortedEqvInf` (binary infimum), `sortedEqvLe` (refinement
>   order `Φ ≤ Ψ` meaning `Φ` finer than `Ψ`), `IsCongruence_inf`, `IsFiniteIndex_inf`,
>   `IsFiniteIndex_of_le` (if `Φ ≤ Ψ` and `Φ` finite index then `Ψ` finite index),
>   `isFiniteIndex_ker_of_finite` (kernel into a finite set has finite index),
>   `isFiniteIndex_nabla` (if `supp A` finite then `nabla A` finite index),
>   `finiteSSet_iff`, `finiteSSet_of_isAlgIso`.
>
> ## 7. Lattices of formations
>
> - `finalAlg Sig`, `finalSorted S` — terminal algebra and terminal sorted set.
> - `finiteAlgebraFormations Sig` — finite algebra formations, with
>   `finiteAlgebraFormationsCompleteLattice` (`[Finite S]`) making them a complete lattice.
> - `finiteAlgebraFormations_isAlgebraicClosureSystem`: they form an algebraic closure
>   system on `Alg Sig` generated by the finite algebras.
> - `finiteAlgebraFormations_isAlgebraicLattice`: they form an algebraic lattice.
> - `finiteIndexCongruenceFormations Sig` — finite-index congruence formations, with
>   `finiteIndexCongruenceFormationsCompleteLattice`, explicit infimum
>   `finiteIndexCongruenceFormationsInf`, and top `finiteIndexCongruenceFormationsTop`.
>   - `finiteIndexCongruenceFormations_isGLB_sInf`: the explicit infimum of `T` is the
>     greatest lower bound of `T`.
>   - `finiteIndexCongruenceFormations_isAlgebraicLattice`: they form an algebraic lattice.
> - `formAlgFFormCgrFiIso Sig : finiteAlgebraFormations Sig ≃o finiteIndexCongruenceFormations Sig`
>   — order isomorphism between finite algebra formations and finite-index congruence
>   formations.
> - `regularLanguageFormations Sig` — the set of regular-language formations.
>   - `regularLanguageFormationsCompleteLattice` (`[Finite S]`): a complete lattice
>     structure on it, obtained by lifting the complete lattice of finite-index congruence
>     formations along the Galois insertion induced by `formCgrFiFormLangRIso`.
>   - `regularLanguageFormations_isAlgebraicLattice`: `regularLanguageFormations` with that
>     structure is an algebraic lattice (transported from the finite-index congruence
>     formations along the order isomorphism).
> - `regularLanguages Sig A` — the set of regular languages over the algebra `A`.
> - `IsRegularLanguage Sig A L`, `L : Sub A.1` — `L` is a regular language of `A`
>   (recognisable by a finite-index congruence).
> - `IsRegularLanguageFormation Sig L`, `L : (A) → Set (Sub (Term Sig A))` — `L` is a
>   formation of regular languages (closed under the language operations below).
>
> ## 8. The language ↔ congruence formation correspondence
>
> `langFormationOf Sig G` (for a congruence family `G`) assigns to `A` the languages
> saturated by some congruence of `G`:
>
> - `mem_langFormationOf_iff`: **for a congruence formation `G` and `L : Sub (Term Sig A)`,
>   `L ∈ langFormationOf G A ↔ ∃ Φ ∈ G A, IsSat Φ L`.**
>
> `langCongFormationOf Sig L` (for a language family `L`) is the inverse construction,
> assigning to `A` the congruences determined by the languages of `L`.
>
> Theorems:
>
> - `langFormationOf_isRegularLanguageFormation`: if `G` is a finite-index congruence
>   formation, then `langFormationOf G` is a regular-language formation.
> - `langFormationOf_mono`: pointwise `G A ⊆ G' A` gives
>   `langFormationOf G A ⊆ langFormationOf G' A`.
> - `langFormationOf_nabla`: for a congruence formation `G`, if `IsSat (nabla (Term Sig A)) L`
>   then `L ∈ langFormationOf G A`.
> - `langFormationOf_inf`: for `L, L' ∈ langFormationOf G A`, every `N` saturated by the
>   intersection of the two cogenerated congruences `congCogenerated L ⊓ congCogenerated L'`
>   is again in `langFormationOf G A`.
> - `langFormationOf_ker`: if `M ∈ langFormationOf G B` and `f : Term Sig A → Term Sig B`
>   is a homomorphism whose composite with the quotient by `congCogenerated M` is surjective,
>   then every `N` saturated by the kernel of that composite lies in `langFormationOf G A`.
> - `langFormationOf_langCongFormationOf`: for a regular-language formation `L`,
>   `langFormationOf (langCongFormationOf L) = L`.
> - `langCongFormationOf_inf`: if `L` is a regular-language formation, then
>   `langCongFormationOf L A` is closed under binary infima: for all
>   `Φ, Ψ ∈ langCongFormationOf L A`, `Φ ⊓ Ψ ∈ langCongFormationOf L A`.
> - `langCongFormationOf_isFiniteIndexCongruenceFormation` (`[Finite S]`): if `L` is a
>   regular-language formation then `langCongFormationOf L` is a finite-index congruence
>   formation.
> - `langCongFormationOf_ker`: if `Θ ∈ langCongFormationOf L B` is a congruence and
>   `f : Term Sig A → Term Sig B` is a homomorphism whose composite with `prAlg Θ` is
>   surjective, then the kernel of that composite lies in `langCongFormationOf L A`.
> - `langCongFormationOf_langFormationOf`: for a finite-index congruence formation `G`,
>   `langCongFormationOf (langFormationOf G) = G`.
> - `langCongFormationOf_mono`: pointwise `L A ⊆ L' A` gives
>   `langCongFormationOf L A ⊆ langCongFormationOf L' A`.
> - `langCongFormationOf_nabla` (`[Finite S]`): `nabla (Term Sig A) ∈ langCongFormationOf L A`.
> - `langCongFormationOf_up`: `langCongFormationOf L A` is upward closed: if `Φ` is a member
>   and `Ψ` is a congruence with `Φ ≤ Ψ`, then `Ψ` is a member.
> - `formCgrFiFormLangRIso Sig : finiteIndexCongruenceFormations Sig ≃o regularLanguageFormations Sig`
>   — an order isomorphism (equivalently, the two maps above form a Galois insertion),
>   with `langFormationOf` and `langCongFormationOf` as the two directions.
>
> ## 9. Directional conventions
>
> - `sortedEqvLe Φ Ψ` means `Φ` is *finer* than `Ψ` (as relations, `Φ ⊆ Ψ`); this is the
>   order on sorted equivalences, and `IsFiniteIndex_of_le` is consistent with it.
> - All class operators (`HOperator`, `PFsdOperator`, both formation transforms) and both
>   language transforms are monotone for `⊆`/pointwise `⊆`.
> - `IsAlgebraicLattice` and `IsCompact` are the standard order-theoretic notions.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-C013 — correspondence verdict
>
> Contract: `Form_{Lang_r}(Σ) is an algebraic lattice.` (the `%`-commented clause about
> isomorphism to `Form_{Cgr_fi}(Σ)` is not part of the active contract).
>
> ## Clause-by-clause
>
> | Contract clause | Lean read-back counterpart | Status |
> |---|---|---|
> | `Form_{Lang_r}(Σ)` is an algebraic lattice | `regularLanguageFormations_isAlgebraicLattice` (§7), on `regularLanguageFormations Sig`, with the structure from `regularLanguageFormationsCompleteLattice` (lifted along the Galois insertion induced by `formCgrFiFormLangRIso`) | matches |
> | (inactive, commented) isomorphic to `Form_{Cgr_fi}(Σ)` | `formCgrFiFormLangRIso : finiteIndexCongruenceFormations Sig ≃o regularLanguageFormations Sig` exists, so even the commented clause is witnessed | not required |
>
> The read-back identifies the exact object (`Form_{Lang_r}(Σ)`, the regular-language
> formations), the exact property (algebraic lattice), and gives the witnessing theorem
> together with the transport mechanism (order isomorphism from the finite-index congruence
> formations). The `[Finite S]` side-condition on the complete-lattice instance is the same
> ambient finiteness implicit in the paper's fixed signature.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the single active clause is exactly the formalized
> `regularLanguageFormations_isAlgebraicLattice`.

