# Correspondence audit transcript -- `B-C006`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.congruenceFormations_isAlgebraicLattice` (`lean/Mslang/Formation.lean`)
- **Contract:** Corollary `B-C006`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000288` (supersedes `E-000226`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Informal read-back of `B-C006.lean`
>
> ## Setting (what the vocabulary means)
>
> Throughout, `S` is a fixed type of **sorts**. A **many-sorted signature** `Sig`
> assigns to every profile `p = (w, s)` — a finite list `w : List S` of input sorts
> and an output sort `s : S` — a type `Sig p` of operation symbols of that profile.
>
> * `SSet S = (s : S) → Type u` — an `S`-sorted set (a family of carrier sets).
> * `SortedEqv A` — an `S`-sorted equivalence: a family, over `s : S`, of equivalence
>   relations on `A s`.
> * `SortedMap A B = (s : S) → A s → B s` — an `S`-sorted family of functions.
> * `Sub A = (s : S) → Set (A s)` — an `S`-sorted family of subsets.
> * `wordProd A w = (i : Fin w.length) → A (w.get i)` — the product of the carriers
>   indexed by a word `w`; and `finOp A w s = wordProd A w → A s`.
> * `Term Sig X : S → Type u` — the sorted set of terms with variables in `X`,
>   built inductively by `var x` and by `op p σ a` for `σ : Sig p` and a tuple `a`
>   of subterms of the input sorts of `p`.
> * `AlgStruct Sig A` — an interpretation of every operation symbol `σ : Sig p` as a
>   function `wordProd A p.1 → A p.2`. An algebra `Alg Sig` is a pair `⟨A, F⟩` of a
>   sorted set `A` and a structure `F` on it.
>
> Order-theoretic vocabulary on `SortedEqv A`:
>
> * `sortedEqvLe Φ Ψ` means **Φ refines Ψ**, i.e. every pair related by Φ is related
>   by Ψ (Φ ⊆ Ψ as sorted relations). It is a preorder; `sortedEqvLe_antisymm` says
>   `sortedEqvLe Φ Ψ` and `sortedEqvLe Ψ Φ` together force `Φ = Ψ`.
> * `sortedEqvInf Φ Ψ` is the pointwise intersection of the two equivalences — the
>   infimum (finest equivalence coarser-refined... precisely: the greatest lower
>   bound) of `Φ` and `Ψ`.
> * `nabla A` is the top (universal) sorted equivalence on `A`: all elements of
>   `A s` are equivalent, for every `s`.
>
> Auxiliary predicates and families:
>
> * `IsSat Φ X` — the subfamily `X` is **saturated** by `Φ` (a union of `Φ`-classes):
>   membership is invariant under `Φ`.
> * `IsCongruence Sig F Φ` — `Φ` is a congruence of the algebra `⟨A, F⟩`: a sorted
>   equivalence compatible with all operations.
> * `IsAlgHom Sig FA FB f` — `f` is a homomorphism; `IsAlgIso Sig FA FB f` — `f` is a
>   bijective homomorphism.
> * `IsAlgebraFormation Sig F` — `F` is a *formation* of algebras (a class of
>   algebras subject to the closure conditions made explicit by the theorems below).
> * `IsCongruenceFormation Sig G` — `G` is a *congruence formation*: a family sending
>   each sorted set `A` to a set `G A` of congruences of the term algebra on `A`.
> * `algebraFormations Sig` is the set of all algebra formations; `congruenceFormations
>   Sig` the set of all congruence formations.
> * `IsAlgebraicLattice L` — the complete lattice `L` is *algebraic*: every element is
>   the join of the compact elements below it; `IsCompact a` — `a` is compact
>   (for every directed set `D`, `a ≤ ⨆D` implies `a ≤ d` for some `d ∈ D`).
> * `HOperator Sig F` — the **homomorphic-image closure** of `F`; `PFsdOperator Sig F`
>   — closure under subdirect products ("`P_{sd}`").
> * `Subfinal A` / `SubfinalAlg Sig X` — `A` (resp. the algebra `X`) is *subfinal*
>   (has no proper quotient; a subdirectly-irreducible-style condition).
> * `quot Φ`, `quotAlg Sig A Φ hΦ`, `pr`, `prAlg`, `quotLift`, `quotOp` — the
>   quotient of a sorted set/algebra by a congruence, the projection onto it, the
>   induced map out of a quotient, and the induced operations.
> * `termAlg Sig X` — the term algebra on `X`; `termEta` inserts variables;
>   `termEval` evaluates terms in an algebra; `termLift` is the unique homomorphic
>   extension of a map on variables.
> * `thetaSigma`, `thetaSigmaInv` — the mutually inverse maps between algebra
>   formations and congruence formations; `formAlgFormCgrIso` packages them as an
>   **order isomorphism**.
> * `finalAlg`, `finalSorted`, `iAlg`, `iPairAlg`, `subAlg`, `ker`, `deltaSub`,
>   `inverseImage`, `complA` — final object, product algebra and its mediating
>   map, subalgebra, kernel equivalence, etc., as used below.
>
> ## Main proved theorem
>
> **`congruenceFormations_isAlgebraicLattice`.** For every signature `Sig`, the
> complete lattice of congruence formations (under `congruenceFormationsCompleteLattice`)
> is an **algebraic lattice**. The proof transports algebraicity from the algebra
> formations across the order isomorphism `formAlgFormCgrIso` (using the fact that
> algebra formations form an algebraic lattice, declared as
> `algebraFormations_isAlgebraicLattice`).
>
> ## The remaining declarations (statements as given)
>
> Most of the file below the first theorem is a signature list (no proof bodies); each
> item is stated below with its exact hypothesis/conclusion content.
>
> ### Operators and their monotonicity
> * `HOperator_mono` — if `F ⊆ G` then `HOperator Sig F ⊆ HOperator Sig G`.
> * `PFsdOperator_mono` — if `F ⊆ G` then `PFsdOperator Sig F ⊆ PFsdOperator Sig G`.
> * `IsCongruence_inf` — if `Φ` and `Ψ` are both congruences of `⟨A, F⟩`, then their
>   infimum `sortedEqvInf Φ Ψ` is again a congruence.
>
> ### The algebra-formation / congruence-formation correspondence
> * `algebraFormationOfCongruenceFormation Sig G` — the algebra formation attached to
>   a congruence formation `G`.
> * `algebraFormationOfCongruenceFormation_HOperator` — if `G` is a congruence
>   formation, the associated algebra formation is **closed under homomorphic images**:
>   `HOperator Sig (… G) ⊆ (… G)`.
> * `algebraFormationOfCongruenceFormation_PFsdOperator` — under the same hypothesis,
>   it is closed under subdirect products: `PFsdOperator Sig (… G) ⊆ (… G)`.
> * `algebraFormationOfCongruenceFormation_congruenceFormationOf` — for any algebra
>   formation `F`, applying the construction to `congruenceFormationOf Sig F` returns
>   `F` exactly.
> * `algebraFormationOfCongruenceFormation_isAlgebraFormation` — the image of a
>   congruence formation is an algebra formation.
> * `algebraFormationOfCongruenceFormation_mono` — if `G A ⊆ G' A` for every `A`, the
>   associated algebra formations satisfy the corresponding inclusion.
> * `congruenceFormationOf Sig F` — the congruence formation attached to a class `F`
>   of algebras.
> * `congruenceFormationOf_algebraFormationOfCongruenceFormation` — for a congruence
>   formation `G`, the round trip returns `G` exactly.
> * `congruenceFormationOf_mono` — if `F ⊆ F'` then for every `A`,
>   `congruenceFormationOf Sig F A ⊆ congruenceFormationOf Sig F' A`.
> * `congruenceFormation_isCongruenceFormation` — the congruence formation attached to
>   an algebra formation is indeed a congruence formation.
> * `thetaSigma_left_inv` — for `F` an algebra formation,
>   `thetaSigmaInv (thetaSigma F) = F`.
> * `thetaSigma_right_inv` — for `G` a congruence formation,
>   `thetaSigma (thetaSigmaInv G) = G`.
> * `formAlgFormCgrIso` — an order isomorphism
>   `algebraFormations Sig ≃o congruenceFormations Sig` (order-reflecting bijection).
>
> ### The lattice of algebra formations
> * `algebraFormationsClosureOperator` — the closure operator on `Set (Alg Sig)` whose
>   fixed points are the algebra formations.
> * `algebraFormationsCompleteLattice` — the induced complete lattice structure on
>   `algebraFormations Sig`.
> * `algebraFormations_isAlgebraicClosureSystem` — `algebraFormations Sig` is an
>   algebraic closure system on the set `Alg Sig` (closed under arbitrary intersections
>   and directed unions).
> * `algebraFormations_isAlgebraicLattice` — that lattice is algebraic.
>
> ### The lattice of congruence formations
> * `congruenceFormationsCompleteLattice` — complete lattice structure on
>   `congruenceFormations Sig`.
> * `congruenceFormationsInf Sig T` — the meet of a set `T` of congruence formations;
>   `congruenceFormationsTop Sig` — the top congruence formation.
> * `congruenceFormations_isGLB_sInf` — `congruenceFormationsInf Sig T` is the
>   **greatest lower bound** of `T`.
> * `exists_mem_superset_finset` — for a nonempty directed family `D` (any two members
>   have an upper bound in `D`) and finitely many members `F i ∈ D`, `i ∈ s`, there is
>   `G ∈ D` with `F i ⊆ G` for all `i ∈ s`. (A finite-above/directedness lemma used to
>   establish algebraicity/compactness.)
>
> ### Formation closure and invariance
> * `formation_abstract` — if `HOperator Sig F ⊆ F` (closure under homomorphic images),
>   `A ∈ F`, and `f : A.1 → B.1` is an algebra isomorphism, then `B ∈ F`. Thus
>   H-closure alone already gives isomorphism-invariance.
> * `formation_mem_of_iso` — the same conclusion in the opposite direction: if
>   `X ∈ F` and `f : Y.1 → X.1` is an isomorphism, then `Y ∈ F`.
> * `formation_congInf` — for an algebra formation `F`, an algebra `A`, and congruences
>   `Φ`, `Ψ` of `A`: if `A/Φ ∈ F` and `A/Ψ ∈ F`, then `A/(Φ ∧ Ψ) ∈ F`.
> * `subfinalAlg_iff` — `SubfinalAlg Sig X` holds iff `X.1` is subfinal as a sorted set.
> * `subfinalAlg_mem_of_formation` — every subfinal algebra belongs to every algebra
>   formation.
>
> ### Products, quotients, kernels
> * `isAlgHom_iPairAlg` — if each `f i : B → A i` is a homomorphism, the mediating map
>   `iPairAlg Sig A f : B → ∏ i, A i` is a homomorphism.
> * `isAlgHom_prAlg` — the projection `prAlg` of a quotient algebra is a homomorphism.
> * `isAlgIso_symm` — the pointwise inverse of an algebra isomorphism is an algebra
>   isomorphism.
> * `ker f` — the kernel sorted equivalence of `f` (`x ~ y` iff `f x = f y`).
> * `ker_isCongruence` — the kernel of a homomorphism is a congruence.
> * `ker_pr` — the kernel of the projection `pr Φ` is `Φ`.
> * `ker_prAlg` — the kernel of `prAlg Sig F Φ hΦ` is `Φ`.
> * `nabla_isCongruence` — the universal sorted equivalence is a congruence of every
>   algebra.
> * `quotAlgLift_isAlgHom` — if `f : A → B` is a homomorphism and `Φ ≤ ker f`, then the
>   lifted map `quotLift Φ f h : A/Φ → B` is a homomorphism.
> * `quotAlg_ker_isAlgIso` — the first isomorphism theorem: for a surjective
>   homomorphism `f`, the lifted map `A/ker f → B` is an isomorphism.
> * `quotLift_comp` — the lift factors the original map: `(quotLift Φ f h) ∘ pr Φ = f`.
> * `quotOp_mk` — the quotient operation computed on representatives: applying the
>   induced operation to the classes of `a i` yields the class of `F p σ a`.
> * `quot_nabla_subfinal` — the quotient of any algebra by the universal congruence is
>   subfinal (the trivial algebra is subfinal).
> * `isSubalgebra / subAlg` — the notion of a subalgebra and the subalgebra it
>   determines.
> * `IsEpiAlg / IsMonoAlg / IsSubdirectEmbedding` — respectively: `f` is a surjective
>   homomorphism, an injective homomorphism, and an embedding realizing its target as a
>   subdirect product of the `Ai`.
>
> ### The term algebra
> * `termEval_isAlgHom` — evaluation of terms is a homomorphism `termAlg A → A`.
> * `termEval_surjective` — evaluation on `termAlg Sig A.1` is surjective onto `A` in
>   every sort.
> * `termLift_eta` — the lifted homomorphism agrees with the given map on variables:
>   `termLift ∘ termEta = g`.
> * `termLift_isAlgHom` — `termLift` is a homomorphism.
> * `termLift_unique` — any homomorphism `f` out of the term algebra with
>   `f ∘ termEta = g` equals `termLift Sig X FA g` (the free-algebra universal
>   property, uniqueness clause).
> * `term_projective` — the term algebra is projective: for a surjective homomorphism
>   `f : B → C` and any homomorphism `g : Term Sig X → C`, there exists a homomorphism
>   `l : Term Sig X → B` with `f ∘ l = g`.
> * `finalAlg / finalSorted` — the terminal algebra and the one-point sorted set.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-C006 verdict
>
> ## Clause-by-clause
>
> Contract clause 1: "$\mathbf{Form}_{\mathrm{Cgr}}(\Sigma)$ is an algebraic lattice."
> Lean counterpart: `congruenceFormations_isAlgebraicLattice`, stated for the complete
> lattice `congruenceFormationsCompleteLattice` on `congruenceFormations Sig`, concluding
> `IsAlgebraicLattice` on it. The read-back also carries the transport proof from
> `algebraFormations_isAlgebraicLattice` across `formAlgFormCgrIso`.
>
> The commented-out clause in the contract ("and isomorphic to the algebraic lattice
> $\mathbf{Form}_{\mathrm{Alg}}(\Sigma)$") is commented out in the LaTeX source and is
> therefore not an asserted clause. The Lean file nevertheless provides the matching
> order isomorphism `formAlgFormCgrIso`, so even the commented clause has a counterpart.
>
> No clause of the contract is missing and the Lean statement adds no hypothesis beyond
> the ambient signature `Sig`.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the Lean theorem is exactly the contract's assertion that the
> lattice of congruence formations is algebraic.

