# Correspondence audit transcript -- `B-C012`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.finiteIndexCongruenceFormations_isAlgebraicLattice` (`lean/Mslang/Regular.lean`)
- **Contract:** Corollary `B-C012`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000293` (supersedes `E-000230`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is therefore faithful, not a
> weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-C012 — informal mathematical read-back
>
> ## 0. Setting and basic objects
>
> Throughout, `S : Type u` is a fixed type of **sorts** and `Sig : Signature S` is a fixed
> many-sorted signature. Concretely:
>
> - `SSet S` is a many-sorted set: a type family indexed by sorts, `A : S → Type u`.
> - `Signature S` is a signature whose operation symbols are indexed by a *profile*
>   `p : List S × S`: a symbol `σ : Sig p` with `p = (w, s)` has input word `w` (a list of
>   sorts) and output sort `s`.
> - `wordProd A w` is the product of the fibers `A` over the entries of the word `w`
>   (`∏_{i : Fin w.length} A (w.get i)`), and `finOp A w s` is `wordProd A w → A s`, the
>   shape of an operation of profile `(w, s)`.
> - `Alg Sig` is the type of **algebras**: a pair `X = (X.1, X.2)` where `X.1 : SSet S` is
>   the underlying many-sorted set and `X.2 : AlgStruct Sig X.1` interprets each symbol.
>   `AlgStruct Sig A` is the structure/interpreting datum on a many-sorted set `A`.
> - `Term Sig X` is the inductive type of **terms** over generators `X` (constructors `var`
>   and `op`), i.e. the free algebra on `X`.
> - `SortedEqv A` is a *sorted equivalence relation* on `A`: a family of equivalence
>   relations `Φ s` on each `A s`. It is the type of candidate congruences/relations.
> - `SortedMap A B` is a sorted function: a family `A s → B s`.
> - `Sub A` is a sorted subset: a family `Sub A s = Set (A s)`.
> - `supp A` is the **support** of `A`: the set of sorts whose fiber is nonempty.
>   `suppAlg X` is the support of the algebra `X`.
>
> ## 1. Homomorphisms, isomorphisms, congruences, subalgebras
>
> - `IsAlgHom Sig FA FB f` — `f` is a homomorphism from `(A, FA)` to `(B, FB)`: a sorted
>   map commuting with every operation symbol.
> - `IsAlgIso Sig FA FB f` — `f` is an algebra isomorphism: a homomorphism that is
>   sortwise bijective. (The file uses `hf.2 s`, so it is `IsAlgHom … ∧ ∀ s, Bijective (f s)`.)
> - `IsMonoAlg Sig FA FB f` — `f` is a monomorphism (injective homomorphism).
> - `IsEpiAlg Sig FA FB f` — `f` is an epimorphism (surjective homomorphism).
> - `IsCongruence Sig F Φ` — `Φ` is a congruence of the algebra `(A, F)`: a sorted
>   equivalence relation compatible with all operations.
> - `IsSubalgebra Sig F X` — the sorted subset `X` is a subalgebra (a subuniverse closed
>   under all operations).
> - `IsSubdirectEmbedding Sig FA Ai f` — `f` is a subdirect embedding of `A` into the
>   product family `Ai`: an injective homomorphism whose projections are jointly surjective.
> - `Subfinal A` / `SubfinalAlg Sig X` — `A` (resp. `X`) is *subfinal*: intuitively a
>   subalgebra of the terminal (one-point-per-sort) algebra, i.e. each sort carries at most
>   one element. `subfinalAlg_iff` confirms the two notions coincide on an algebra's carrier.
> - `IsFiniteIndex Φ` — the sorted equivalence `Φ` has finitely many classes (each fiber is
>   a finite quotient); this is the "finite index" condition.
> - `IsCongruenceFormation Sig G`, where
>   `G : (A : SSet S) → Set (SortedEqv (Term Sig A))`, is the abstract predicate that a
>   family of sets of congruences on the term algebras is a *congruence formation*
>   (closed under finite infima, upward under coarsening, and stable under the term-algebra
>   operations used below). The closure content is characterised by the theorems of §5–§7.
> - `IsAlgebraFormation Sig F`, `F : Set (Alg Sig)`, is the predicate that `F` is an
>   **algebra formation**: a class of algebras closed under homomorphic images, finite
>   subdirect products, and containing the trivial algebra, hence closed under isomorphism.
> - `IsFiniteAlgebraFormation Sig F` — `F` is a formation consisting of finite algebras.
> - `IsFiniteIndexCongruenceFormation Sig G` — `G` is a congruence formation all of whose
>   congruences have finite index.
> - `IsAlgebraicLattice L` (with a `CompleteLattice L` instance) — `L` is an **algebraic
>   lattice**: every element is the join of the compact elements below it.
> - `IsCompact a` — `a` is a **compact element** of the lattice `L`.
>
> ## 2. Operators on classes of algebras
>
> - `HOperator Sig F` — the class of homomorphic images of algebras in `F`.
> - `PFsdOperator Sig F` — the class of finite subdirect products of algebras in `F`
>   (algebras that embed subdirectly into a finite product of members of `F`).
> - `HOperator_mono`: for `F ⊆ G`, `HOperator Sig F ⊆ HOperator Sig G`. (monotone)
> - `PFsdOperator_mono`: for `F ⊆ G`, `PFsdOperator Sig F ⊆ PFsdOperator Sig G`. (monotone)
> - `algebraFinite Sig` — the class of finite algebras.
> - `algebraFinite_closed_HOperator`:
>   `HOperator Sig (algebraFinite Sig) ⊆ algebraFinite Sig` (homomorphic images of finite
>   algebras are finite).
> - `algebraFinite_closed_PFsdOperator` (assumes `[Finite S]`):
>   `PFsdOperator Sig (algebraFinite Sig) ⊆ algebraFinite Sig` (finite subdirect products
>   of finite algebras are finite).
> - `formation_abstract`: if `HOperator Sig F ⊆ F`, `A ∈ F`, `f : A.1 → B.1` is an algebra
>   isomorphism, then `B ∈ F`. (closure under isomorphism, derived from H-closure)
> - `formation_mem_of_iso`: if `HOperator Sig F ⊆ F`, `X ∈ F`, and `Y ≅ X`, then `Y ∈ F`.
> - `formation_congInf`: if `F` is an algebra formation, `A` is an algebra, `Φ, Ψ` are
>   congruences of `A`, and the quotients `A/Φ` and `A/Ψ` both lie in `F`, then
>   `A/(Φ ⊓ Ψ) ∈ F`. (closure under finite infima of congruences)
> - `subfinalAlg_mem_of_formation`: if `F` is an algebra formation and `A` is subfinal,
>   then `A ∈ F`. (Every formation contains the trivial/subfinal algebras.)
>
> ## 3. Term algebras and free-algebra structure
>
> - `termAlg Sig X` — the term algebra of `Term Sig X`, the free algebra on generators `X`.
> - `termEta Sig X : X → Term Sig X` — the insertion of generators.
> - `termEval Sig A : Term Sig A.1 → A.1` — the evaluation map interpreting terms of the
>   algebra `A` by elements of `A` (the unique homomorphic extension of the identity on
>   generators).
>   - `termEval_isAlgHom`: `termEval` is a homomorphism from the term algebra to `A`.
>   - `termEval_surjective`: for every sort `s`, `termEval … s` is surjective; every element
>     of `A` is the value of some term.
> - `termLift Sig X FA g` — for `g : X → A`, the unique homomorphic extension of `g` to a
>   map `Term Sig X → A`, defined recursively on terms. Theorems:
>   - `termLift_eta`: `(termLift … g) ∘ termEta = g` (pointwise).
>   - `termLift_isAlgHom`: `termLift … g` is a homomorphism.
>   - `termLift_unique`: if `f : Term Sig X → A` is a homomorphism with `f ∘ termEta = g`,
>     then `f = termLift … g`. (This is the universal property of the term algebra.)
> - `term_projective`: if `f : B → C` is a surjective homomorphism and `g : Term Sig X → C`
>   is a homomorphism, then there exists a homomorphism `l : Term Sig X → B` with
>   `f ∘ l = g`. (The term algebra is projective.)
>
> ## 4. Quotients, kernels, and the isomorphism theorems
>
> - `pr Φ : A → quot Φ` — the canonical projection onto the quotient many-sorted set by `Φ`.
> - `quot Φ` — the quotient sorted set `A/Φ` (family of quotients `Quotient (Φ s)`).
> - `quotAlg Sig F Φ hΦ` — the quotient algebra `A/Φ` for a congruence `Φ` of `(A, F)`.
> - `prAlg Sig F Φ hΦ : A → A/Φ` — the canonical projection homomorphism.
>   - `isAlgHom_prAlg`: `prAlg` is a homomorphism.
> - `quotOp Sig F Φ p σ` — the interpretation of the operation symbol `σ` of profile `p`
>   in the quotient algebra; `quotOp_mk` states it is computed on representatives:
>   for a tuple `a` of `wordProd A p.1`,
>   `quotOp (fun i => mk (a i)) = mk (F p σ a)`.
> - `ker f` — the kernel sorted equivalence of a sorted map `f`.
>   - `ker_isCongruence`: the kernel of a homomorphism is a congruence.
>   - `ker_pr`: `ker (pr Φ) = Φ`.
>   - `ker_prAlg`: `ker (prAlg … Φ hΦ) = Φ`.
> - `quotLift Φ f h` — for `f : A → B` with `Φ ≤ ker f` (i.e. `Φ` refines `ker f`), the
>   induced map `A/Φ → B`.
>   - `quotLift_comp`: `(quotLift Φ f h) ∘ (pr Φ) = f` (pointwise).
>   - `quotAlgLift_isAlgHom`: if additionally `f` is a homomorphism, the induced map is a
>     homomorphism.
> - `quotAlg_ker_isAlgIso` — **first isomorphism theorem**: if `f : A → B` is a surjective
>   homomorphism, then `A/ker f ≅ B`, via the lifted map.
> - `quotLe Φ Ψ h` for `h : Φ ≤ Ψ` — the induced map `A/Φ → A/Ψ`; `quotLe_mk` says it sends
>   each `Φ`-class of `a` to the `Ψ`-class of `a`.
> - `quot_nabla_subfinal`: for any algebra `(A, F)`, the quotient `A/∇_A` by the universal
>   relation is subfinal.
> - `isAlgIso_symm`: algebra isomorphism is symmetric; the inverse is built sortwise.
>
> ## 5. Products
>
> - `iAlg Sig A` — the product of a family of algebras `A : ι → Alg Sig`.
> - `iPairAlg Sig A f` — for a family of sorted maps `f i : B → A i`, the induced map
>   `B → ∏ i, A i`.
>   - `isAlgHom_iPairAlg`: if each `f i` is a homomorphism, the induced map is a
>     homomorphism.
> - `suppAlg_iAlg`: for a family of algebras `A`, the support of their product is the
>   intersection of supports: `s ∈ supp (∏ i, A i) ↔ ∀ i, s ∈ supp (A i)`.
>
> ## 6. Equivalence-relation infrastructure
>
> - `sortedEqvInf Φ Ψ` — the infimum (intersection) of two sorted equivalences.
> - `sortedEqvLe Φ Ψ` — the refinement order: `Φ` refines `Ψ` (every `Φ`-class lies inside
>   a `Ψ`-class), written `Φ ≤ Ψ`. This is the order used throughout, and matches the
>   existence of the map `quot Φ → quot Ψ` in `quotLe`.
> - `nabla A` — the universal (coarsest) sorted equivalence on `A`.
> - `IsCongruence_inf`: if `Φ` and `Ψ` are congruences of `(A, F)`, then `Φ ⊓ Ψ`
>   (`sortedEqvInf`) is a congruence.
> - `nabla_isCongruence`: `nabla A` is always a congruence, for any structure `F`.
> - `IsFiniteIndex_inf`: the infimum of two finite-index sorted equivalences has finite
>   index.
> - `IsFiniteIndex_of_le`: **if `Φ ≤ Ψ` and `Φ` has finite index, then `Ψ` has finite index**
>   (coarsening a finite-index relation stays finite index).
> - `isFiniteIndex_ker_of_finite`: for `f : A → B` with `B` finite, `ker f` has finite
>   index.
> - `isFiniteIndex_nabla`: if `supp A` is finite then `nabla A` has finite index.
> - `finiteSSet_iff`: `FiniteSSet A ↔ (supp A).Finite ∧ ∀ s ∈ supp A, Finite (A s)`.
> - `finiteSSet_of_isAlgIso`: if `A` is finite and `A ≅ B` as algebras, then `B` is finite.
>
> ## 7. The two formations and the Galois/order structure
>
> - `congFi Sig F` for `F : AlgStruct Sig A` — the set of finite-index congruences of the
>   algebra `A`.
> - `congruenceFormationOf Sig F` — from a class of algebras `F`, the congruence family
>   assigning to each sorted set `A` the congruences `Θ` on the term algebra `Term Sig A`
>   whose quotient `Term Sig A / Θ` lies in `F`.
> - `algebraFormationOfCongruenceFormation Sig G` — from a congruence family `G`, the class
>   of algebras presented as quotients of their term algebras by congruences belonging to
>   `G` (i.e. `A` belongs iff the kernel of `termEval_A` lies in `G A.1`).
> - `congruenceFormationOf_algebraFormationOfCongruenceFormation`: for a congruence
>   formation `G`, `congruenceFormationOf (algebraFormationOfCongruenceFormation G) = G`.
> - `algebraFormationOfCongruenceFormation_congruenceFormationOf`: for an algebra formation
>   `F`, `algebraFormationOfCongruenceFormation (congruenceFormationOf F) = F`. (The two
>   constructions are mutually inverse.)
> - `algebraFormationOfCongruenceFormation_HOperator` (for `G` a congruence formation):
>   the associated algebra class is closed under homomorphic images.
> - `algebraFormationOfCongruenceFormation_PFsdOperator`: it is closed under finite
>   subdirect products.
> - `algebraFormationOfCongruenceFormation_isAlgebraFormation`: it is an algebra formation.
> - `algebraFormationOfCongruenceFormation_isFiniteAlgebra`: if every `G A` consists of
>   finite-index congruences on the term algebra over `A`, then the associated algebra class
>   consists of finite algebras.
> - `algebraFormationOfCongruenceFormation_mono`: pointwise `G A ⊆ G' A` implies
>   `algebraFormationOfCongruenceFormation G ⊆ algebraFormationOfCongruenceFormation G'`.
> - `congruenceFormationOf_isFiniteIndex`: if `F ⊆ algebraFinite`, then for every `A` all
>   members of `congruenceFormationOf F A` have finite index.
> - `congruenceFormationOf_mono`: `F ⊆ F'` implies
>   `congruenceFormationOf F A ⊆ congruenceFormationOf F' A` for all `A`.
> - `congruenceFormation_isCongruenceFormation`: if `F` is an algebra formation then
>   `congruenceFormationOf F` is a congruence formation.
> - `exists_mem_superset_finset`: if `D` is a nonempty directed family of sets of algebras
>   (for `A, B ∈ D` there is `E ∈ D` with `A ⊆ E` and `B ⊆ E`), then any finite subfamily
>   `{F i : i ∈ s}` with all `F i ∈ D` has an upper bound in `D`. (Directedness for finite
>   sets.)
>
> ## 8. Lattices of formations
>
> - `finalAlg Sig` — the terminal (one-point-per-sort) algebra; `finalSorted S` the
>   corresponding sorted set.
> - `finiteAlgebraFormations Sig` — the set of finite algebra formations, i.e. the
>   subcollection of `Set (Alg Sig)` satisfying `IsFiniteAlgebraFormation`.
> - `finiteAlgebraFormationsCompleteLattice` (needs `[Finite S]`) — a complete lattice
>   structure on the finite algebra formations.
> - `finiteAlgebraFormations_isAlgebraicClosureSystem`: the finite algebra formations form
>   an algebraic closure system on the carrier `Alg Sig`, generated by the finite algebras
>   `algebraFinite Sig` (each formation is the union of the closures of its finite
>   subcollections).
> - `finiteAlgebraFormations_isAlgebraicLattice`: `finiteAlgebraFormations Sig` with that
>   complete lattice is an algebraic lattice.
> - `finiteIndexCongruenceFormations Sig` — the set of finite-index congruence formations.
> - `finiteIndexCongruenceFormationsCompleteLattice` (needs `[Finite S]`), with explicit
>   infimum `finiteIndexCongruenceFormationsInf` and top `finiteIndexCongruenceFormationsTop`.
> - `finiteIndexCongruenceFormations_isGLB_sInf`: for any `T`, the explicit infimum
>   `finiteIndexCongruenceFormationsInf Sig T` is the **greatest lower bound** of `T` in the
>   lattice.
> - `finiteIndexCongruenceFormations_isAlgebraicLattice` (the file's opening theorem):
>   `finiteIndexCongruenceFormations Sig` is an algebraic lattice, obtained by transporting
>   algebraicity from `finiteAlgebraFormations` across the order isomorphism below.
> - `formAlgFFormCgrFiIso Sig : finiteAlgebraFormations Sig ≃o finiteIndexCongruenceFormations`
>   — an **order isomorphism** (order-preserving bijection with order-preserving inverse)
>   between finite algebra formations and finite-index congruence formations, given by the
>   two mutually inverse constructions of §7.
> - `subAlg Sig F X hX` — the subalgebra of `(A, F)` with carrier `X`.
>
> ## 9. Note on direction conventions
>
> - `sortedEqvLe Φ Ψ` means `Φ` is *finer* than `Ψ` (contained in `Ψ` as a relation);
>   the resulting monotonicity (`IsFiniteIndex_of_le`) says a coarsening of a finite-index
>   relation has finite index.
> - All class operators `HOperator`, `PFsdOperator`, both formation maps, and the congruence
>   families are monotone with respect to `⊆` of classes and pointwise `⊆` of congruence
>   families.
> - `IsAlgebraicLattice` and `IsCompact` are the standard order-theoretic notions: an
>   algebraic lattice and its compact elements.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-C012 — correspondence verdict
>
> Contract: `Form_{Cgr_fi}(Σ) is an algebraic lattice.` (the `%`-commented clause about
> isomorphism to `Form_{Alg_f}(Σ)` is not part of the active contract).
>
> ## Clause-by-clause
>
> | Contract clause | Lean read-back counterpart | Status |
> |---|---|---|
> | `Form_{Cgr_fi}(Σ)` is an algebraic lattice | `finiteIndexCongruenceFormations_isAlgebraicLattice` (§8), on `finiteIndexCongruenceFormations Sig` with the complete-lattice structure from `finiteIndexCongruenceFormationsCompleteLattice`, obtained by transporting algebraicity from `finiteAlgebraFormations` along `formAlgFFormCgrFiIso` | matches |
> | (inactive, commented) isomorphic to `Form_{Alg_f}(Σ)` | `formAlgFFormCgrFiIso : finiteAlgebraFormations Sig ≃o finiteIndexCongruenceFormations` exists, so even the commented clause is witnessed | not required |
>
> The read-back identifies the exact object `Form_{Cgr_fi}(Σ)` (finite-index congruence
> formations), the exact property (algebraic lattice), and provides the witnessing theorem
> with the stated construction. No hypothesis is added or dropped relative to the paper's
> ambient many-sorted setting; the `[Finite S]` requirement on the lattice instances is the
> same ambient finiteness implicit in a fixed finite-sorted signature.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the single active clause is exactly the formalized
> `finiteIndexCongruenceFormations_isAlgebraicLattice`.

