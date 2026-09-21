# Correspondence audit transcript -- `B-P020`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.congruenceFormations`, `Mslang.algebraFormationOfCongruenceFormation_isAlgebraFormation`, `Mslang.congruenceFormationOf_mono`, `Mslang.algebraFormationOfCongruenceFormation_mono`, `Mslang.algebraFormationOfCongruenceFormation_congruenceFormationOf`, `Mslang.congruenceFormationOf_algebraFormationOfCongruenceFormation`, `Mslang.thetaSigma`, `Mslang.thetaSigmaInv`, `Mslang.thetaSigma_left_inv`, `Mslang.thetaSigma_right_inv`, `Mslang.formAlgFormCgrIso` (`lean/Mslang/Formation.lean`)
- **Contract:** Proposition `B-P020`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000307` (supersedes `E-000180`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-P020.lean`
>
> *Blind first-stage correspondence audit. Only this file was read.*
>
> ## Caveat
>
> This file contains one group of fully proved theorems (a Galois/order-isomorphism
> package between "algebra formations" and "congruence formations", plus several
> structural lemmas) interspersed with many *interface declarations*
> (`def`/`theorem`/`abbrev` with no body given). For those interface declarations
> the reading below is forced by their type and by how the proved theorems use
> them; it is flagged as inferred.
>
> ## Setting and notation (many-sorted universal algebra)
>
> Fix a type `S` of sorts (universe `u`).
>
> - `SSet S` is the type of **S-sorted sets** `(A_s)_{s∈S}`.
> - `Signature S` is a **many-sorted signature**: `Sig (w,s)` is the type of
>   operation symbols of input arity the word `w : List S` and result sort `s`.
> - `SortedMap A B` is the type of **S-sorted maps** `(f_s : A_s → B_s)_{s∈S}`.
> - `SortedEqv A` is the type of **S-sorted equivalences**: a family of
>   equivalence relations `(Φ_s)` on `A_s`. Write `x ~_{Φ,s} y`.
> - `sortedEqvLe Φ Ψ` (declared) is the **refinement order**: `Φ ⊆ Ψ` as
>   relations, i.e. `∀ s x y, x ~_{Φ,s} y → x ~_{Ψ,s} y`; `Φ` is finer than `Ψ`.
> - `sortedEqvInf Φ Ψ` (declared) is the **intersection/infimum** of sorted
>   equivalences.
> - `Alg Sig` is the type of **algebras**: a pair `(C.1, C.2)` with carrier
>   `C.1 : SSet S` and structure `C.2 : AlgStruct Sig C.1` interpreting each
>   symbol `σ : Sig p` by an operation `F p σ a`.
> - `wordProd A w` is the product `∏_{i<|w|} A_{w_i}`; `finOp A w s` is the type
>   of `w`-ary operations with result sort `s`.
> - `Term Sig X` is the inductive type of **many-sorted terms** over variables
>   `X`: `var x` for `x : X s`, and `op p σ a` for `p = (w,s)`, `σ : Sig p`,
>   `a : ∏_{i<|w|} Term Sig X (w_i)`, of sort `s`.
> - `termAlg Sig X`, `termEta Sig X`, `termEval Sig A`, `termLift Sig X FA g`
>   are the term algebra, variable insertion, term evaluation, and the unique
>   homomorphic extension of a map on variables.
> - `finalAlg Sig`, `finalSorted S` are the final algebra and a one-element
>   carrier at every sort; `iAlg Sig A` is the product of the family
>   `A : ι → Alg Sig`; `iPairAlg Sig A f` is the **pairing** map into the product
>   induced by maps `f i : B → (A i).1`.
> - `ker f`, `nabla A`, `pr`, `prAlg`, `quot`, `quotAlg`, `quotLift`, `quotOp`
>   are the kernel, total relation, projections, quotient constructions and
>   induced maps, as usual.
> - `IsAlgHom` / `IsAlgIso` say a sorted map is an algebra homomorphism /
>   isomorphism (bijective at each sort); `IsCongruence Sig F Φ` says `Φ` is a
>   congruence on the algebra structure `F`.
> - `IsSubalgebra Sig F X` says `X : Sub A` is a subalgebra; `subAlg Sig F X hX`
>   is the resulting algebra; `Subfinal A` / `SubfinalAlg Sig X` say a sorted
>   set / algebra is **subfinal** (a one-element, i.e. trivial, algebra, or a
>   subalgebra of the final algebra — see `subfinalAlg_iff`).
>
> ## The formation interface (inferred from use)
>
> - A **congruence formation** is a family
>   `G : (A : SSet S) → Set (SortedEqv (Term Sig A))` satisfying
>   `IsCongruenceFormation Sig G`: for each `A`, `G A` is a nonempty set of
>   congruences on the term algebra `Term Sig A`, closed under finite
>   intersections and upward under `sortedEqvLe` (so `∇, ⊤ ∈ G A`), plus the
>   pullback/asymmetric closure: if `Ψ ∈ G B` and `g : Term A → Term B` is a hom
>   whose composite with `prB` is surjective at every sort, then
>   `ker (prB ∘ g) ∈ G A`.
> - `congruenceFormations Sig` is the **set of all congruence formations**.
> - An **algebra formation** is a class `F : Set (Alg Sig)` with
>   `IsAlgebraFormation Sig F`, which (by how it is produced and used) means
>   `F` is closed under `HOperator Sig` (homomorphic images) and under
>   `PFsdOperator Sig` (finite subdirect products); its two components are used
>   as `hF.1` (H-closure) and `hF.2` (PFsd-closure).
> - `algebraFormations Sig` is the **set of all algebra formations**.
> - `congruenceFormationOf Sig F A` is the set of congruences `Φ` on the term
>   algebra `Term Sig A` such that the quotient `Term Sig A / Φ` lies in the
>   class `F` (membership is the pair "`Φ` is a congruence" together with
>   "quotient ∈ `F`").
> - `algebraFormationOfCongruenceFormation Sig G` is the class of algebras
>   isomorphic to a quotient `Term Sig A / Φ` with `Φ ∈ G A`.
>
> ## Proved theorems
>
> ### `congruenceFormations`
> The set `{G | IsCongruenceFormation Sig G}` of congruence formations.
>
> ### `algebraFormationOfCongruenceFormation_isAlgebraFormation`
> **Statement.** If `hG : IsCongruenceFormation Sig G`, then
> `IsAlgebraFormation Sig (algebraFormationOfCongruenceFormation Sig G)`.
> **Content.** The class of algebras cut out by a congruence formation is indeed
> an algebra formation; concretely this is the conjunction of the H-closure and
> PFsd-closure of that class (imported here as the two interface theorems
> `..._HOperator` and `..._PFsdOperator`). This is the map from congruence
> formations to algebra formations.
>
> ### `congruenceFormationOf_mono`
> **Statement.** For classes `F ⊆ F'` of algebras, for every sorted set `A`,
> `congruenceFormationOf Sig F A ⊆ congruenceFormationOf Sig F' A`.
> **Content.** `congruenceFormationOf` is **monotone** in the class: a larger
> class of algebras admits at least as many quotient congruences. Pointwise
> inclusion of families.
>
> ### `algebraFormationOfCongruenceFormation_mono`
> **Statement.** If `G A ⊆ G' A` for every `A`, then
> `algebraFormationOfCongruenceFormation Sig G ⊆
>  algebraFormationOfCongruenceFormation Sig G'`.
> **Content.** `algebraFormationOfCongruenceFormation` is **monotone** in the
> congruence formation, pointwise.
>
> ### `algebraFormationOfCongruenceFormation_congruenceFormationOf`
> **Statement.** If `hF : IsAlgebraFormation Sig F`, then
> `algebraFormationOfCongruenceFormation Sig (congruenceFormationOf Sig F) = F`.
> **Content.** **Left-inverse identity.** For an algebra formation `F`, taking its
> quotient congruences and then closing back up by term quotients recovers `F`.
> - `⊆`: a quotient `Term A / Φ` with `Term A / Φ ∈ F`, isomorphic to `C`, has
>   `C ∈ F` by closure of a formation under isomorphism.
> - `⊇`: given `C ∈ F`, the evaluation map `termEval : Term C.1 ↠ C` is a
>   surjective hom with kernel `Θ`; `Term C.1 / Θ ≅ C ∈ F`, so `Θ` lies in
>   `congruenceFormationOf Sig F C.1`, and `C` (isomorphic to that quotient) lies
>   in `algebraFormationOfCongruenceFormation`.
>
> ### `congruenceFormationOf_algebraFormationOfCongruenceFormation`
> **Statement.** If `hG : IsCongruenceFormation Sig G`, then
> `congruenceFormationOf Sig (algebraFormationOfCongruenceFormation Sig G) = G`.
> **Content.** **Right-inverse identity**, the substantive direction.
> - `⊇`: if `Φ ∈ G A`, then `Φ` is a congruence (formation property) and
>   `Term A / Φ` is in the class via the identity isomorphism, so
>   `Φ ∈ congruenceFormationOf Sig (algebraFormationOf ... G) A`.
> - `⊆`: if `Φ` is a congruence on `Term A` and `Term A / Φ` is a quotient
>   `Term B / Ψ` with `Ψ ∈ G B`, then `Φ ∈ G A`. The proof writes `f` for the
>   iso `Term A / Φ ≅ Term B / Ψ`, uses projectivity of term algebras
>   (`term_projective`) to lift `f ∘ prA : Term A → Term B / Ψ` along
>   `prB : Term B → Term B / Ψ`, obtaining a hom `g : Term A → Term B` with
>   `prB ∘ g = f ∘ prA`; this composite is surjective, so the pullback clause of
>   the congruence formation gives `ker (prB ∘ g) ∈ G A`. Since `f` is injective,
>   `ker (prB ∘ g) = ker (f ∘ prA) = ker prA = Φ`, hence `Φ ∈ G A`.
>
> ### `thetaSigma`
> `thetaSigma Sig : algebraFormations Sig → congruenceFormations Sig`, sending
> `F ↦ congruenceFormationOf Sig F.1`, with the proof that this is a congruence
> formation.
>
> ### `thetaSigmaInv`
> `thetaSigmaInv Sig : congruenceFormations Sig → algebraFormations Sig`, sending
> `G ↦ algebraFormationOfCongruenceFormation Sig G.1`, with the proof that this is
> an algebra formation.
>
> ### `thetaSigma_left_inv`
> For every algebra formation `F`,
> `thetaSigmaInv Sig (thetaSigma Sig F) = F`.
>
> ### `thetaSigma_right_inv`
> For every congruence formation `G`,
> `thetaSigma Sig (thetaSigmaInv Sig G) = G`.
>
> **Content.** `thetaSigma` and `thetaSigmaInv` are mutually inverse bijections
> between algebra formations and congruence formations, by the two composition
> identities above.
>
> ### `formAlgFormCgrIso`
> `formAlgFormCgrIso Sig : algebraFormations Sig ≃o congruenceFormations Sig` is
> an **order isomorphism** (`≃o`) between algebra formations and congruence
> formations, ordered by inclusion (the algebra side by `⊆` of classes; the
> congruence side pointwise by `⊆` of the families). Its `map_rel_iff'` proves
> both directions:
> - if `congruenceFormationOf F A ⊆ congruenceFormationOf F' A` for all `A`,
>   then `F ⊆ F'` (apply `algebraFormationOfCongruenceFormation_mono`, then
>   rewrite both sides back to `F`, `F'` by the left-inverse identity);
> - if `F ⊆ F'`, then `congruenceFormationOf F A ⊆ congruenceFormationOf F' A`
>   for all `A` (this is `congruenceFormationOf_mono`).
>
> Thus it is order-preserving *and* order-reflecting (the order is an
> isomorphism, not merely an embedding).
>
> ### `IsCongruence_inf`
> **Statement.** If `Φ` and `Ψ` are both congruences on the same algebra
> structure `F`, then their infimum `sortedEqvInf Φ Ψ` is a congruence.
> **Content.** Congruences on an algebra are closed under binary intersection
> (the lattice meet in the refinement order).
>
> ### `formation_abstract`
> **Statement.** If `HOperator Sig F ⊆ F`, and `A ∈ F` with an algebra
> isomorphism `f : A → B`, then `B ∈ F`.
> **Content.** A class closed under homomorphic images is closed under isomorphic
> images.
>
> ### `formation_congInf`
> **Statement.** If `hF : IsAlgebraFormation Sig F`, `A` an algebra, `Φ`, `Ψ`
> congruences on `A`, and the quotients `A/Φ` and `A/Ψ` both lie in `F`, then the
> quotient `A/(Φ ⊓ Ψ)` lies in `F`.
> **Content.** An algebra formation is closed under taking the meet of quotient
> congruences.
>
> ### `formation_mem_of_iso`
> **Statement.** If `HOperator Sig F ⊆ F`, `X ∈ F`, and there is an algebra
> isomorphism `f : Y → X`, then `Y ∈ F`.
> **Content.** Same invariance under isomorphism as `formation_abstract`, but
> stated with the isomorphism pointing *into* the known member (`Y ≅ X`, `X ∈ F
> ⟹ Y ∈ F`).
>
> ### `iPairAlg` / `isAlgHom_iPairAlg`
> `iPairAlg Sig A f : SortedMap B (iAlg Sig A).1` is the **pairing** of maps
> `f i : B → (A i).1` into the product. `isAlgHom_iPairAlg` says: if every
> component `f i` is an algebra hom, then the pairing is an algebra hom.
>
> ### `quotLift_comp`
> For any `Φ` and `f` with `sortedEqvLe Φ (ker f)`,
> `(quotLift Φ f h) ∘ pr Φ = f`: the lift of `f` through the quotient projection
> does commute with the projection.
>
> ### `quot_nabla_subfinal`
> For any algebra structure `F` on a sorted set `A`, the quotient of `A` by the
> total congruence `nabla A` is **subfinal** (`SubfinalAlg`): it is the trivial
> one-element algebra.
>
> ### `subfinalAlg_iff`
> For an algebra `X`, `SubfinalAlg Sig X ↔ Subfinal X.1`: an algebra is subfinal
> if and only if its underlying sorted set is subfinal.
>
> ### `subfinalAlg_mem_of_formation`
> If `hF : IsAlgebraFormation Sig F` and `A` is a subfinal algebra, then
> `A ∈ F`. Every algebra formation contains all subfinal (trivial) algebras.
>
> ## Order/lattice structure claimed
>
> - **Order isomorphism**: `formAlgFormCgrIso Sig` is an order isomorphism between
>   algebra formations and congruence formations, both ordered by inclusion
>   (`≃o`, with preservation and reflection proved).
> - **Galois-type inverse operators**: `thetaSigma` / `thetaSigmaInv` are mutually
>   inverse; `congruenceFormationOf` and `algebraFormationOfCongruenceFormation`
>   are inverse constructions on the two kinds of formations.
> - **Monotonicity**: both constructions are monotone (the two `_mono` lemmas).
> - **Meet structure**: congruences are closed under binary infimum
>   (`IsCongruence_inf`); algebra formations are closed under meets of quotient
>   congruences (`formation_congInf`).
> - **Smallest formation**: since every algebra formation contains all subfinal
>   algebras (`subfinalAlg_mem_of_formation`), the subfinal algebras form the
>   least algebra formation.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P020 — second-stage verdict
>
> Contract: "The complete lattices `Form_Alg(Σ)` and `Form_Cgr(Σ)` are isomorphic."
> Read-back: `B-P020.lean`.
>
> ## Clause-by-clause
>
> - **The two objects are the lattice of algebra formations and the lattice of
>   congruence formations.**
>   Contract: `Form_Alg(Σ)`, `Form_Cgr(Σ)`.
>   Lean: `algebraFormations Sig` = set of all algebra formations;
>   `congruenceFormations Sig` = set of all congruence formations.
>   → **equivalent** (same objects).
>
> - **They are ordered as lattices, by inclusion.**
>   Contract: "complete lattices" — order is inclusion (algebra side: class
>   inclusion; congruence side: pointwise inclusion of families).
>   Lean: read-back states both sides are "ordered by inclusion" (algebra side by
>   `⊆` of classes; congruence side pointwise by `⊆` of the families).
>   → **equivalent order** (the completeness of the two collections is a
>   presupposition of the proposition, established apart from the isomorphism
>   claim; the file asserts the same order).
>
> - **They are isomorphic.**
>   Contract: isomorphic (as complete lattices).
>   Lean: `formAlgFormCgrIso Sig : algebraFormations Sig ≃o congruenceFormations
>   Sig`, an order isomorphism whose `map_rel_iff'` proves order-preservation and
>   order-reflection, plus mutually inverse operators `thetaSigma` /
>   `thetaSigmaInv` (`thetaSigma_left_inv`, `thetaSigma_right_inv`).
>   For complete lattices an order isomorphism is a complete-lattice isomorphism
>   (it preserves all existing joins and meets), so this is the same assertion.
>   → **equivalent**.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the file's order isomorphism `formAlgFormCgrIso` between
> the two collections (ordered by inclusion, with mutual-inverse operators) is the
> exact formal content of "the two complete lattices are isomorphic," since an
> order isomorphism between complete lattices is a complete-lattice isomorphism.

