# Correspondence audit transcript -- `B-C004`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.algebraFormation_iff_shskFormation`, `Mslang.shskFormation_mem_of_subdirect`, `Mslang.sortedEqvLe_refl`, `Mslang.sortedEqvLe_trans` (`lean/Mslang/Formation.lean`)
- **Contract:** Corollary `B-C004`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000287` (supersedes `E-000133`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-C004.lean`
>
> ## Ambient setting
>
> A fixed type `S` (the set of **sorts**) is understood. A **signature** `Sig` assigns,
> to every pair `p = (w, s)` consisting of a list of sorts `w` and a sort `s`, a type
> `Sig p` of operation symbols "with input sorts `w` and output sort `s`".
>
> * `SSet S` is an `S`-sorted set, i.e. a family `(A_s)_{s∈S}` of types.
> * `SortedMap A B` is a sorted family of functions, one `A_s → B_s` for each sort `s`.
> * `SortedEqv A` is a sorted family of equivalence relations, one `Setoid (A_s)` per sort.
> * `Alg Sig` is an algebra: an `S`-sorted set together with an interpretation of every
>   operation symbol. `AlgStruct Sig A` is the algebra structure carried by `A`.
> * For sorted equivalences write `sortedEqvLe Φ Ψ` ("`Φ` refines `Ψ`", i.e. `Φ ≤ Ψ`) for
>   `∀ s, ∀ x y, (x,y) ∈ Φ_s → (x,y) ∈ Ψ_s`, and let `sortedEqvInf Φ Ψ` be their **meet**,
>   the relation `(x,y) ∈ (Φ⊓Ψ)_s ↔ (x,y) ∈ Φ_s ∧ (x,y) ∈ Ψ_s`.
> * `IsCongruence Sig F Φ` says the sorted equivalence `Φ` is a congruence of the algebra
>   `(A,F)` (compatible with all operations).
> * `IsAlgHom Sig F G f` says the sorted map `f` preserves the operations; `IsAlgIso` is a
>   bijective homomorphism.
> * `ker f` is the sorted equivalence `(x,y) ∈ (ker f)_s ↔ f_s x = f_s y`.
> * `quotAlg Sig F Φ hΦ` is the quotient algebra `A/Φ`; `iAlg Sig C` is the product of a
>   family `C : ι → Alg`; `iPairAlg`/`iProjAlg` are its tupling and projections.
> * `Subfinal X` says the `S`-sorted set `X` is **subfinal** (each layer `X_s` has at most
>   one element); `SubfinalAlg Sig X ↔ Subfinal X.1`. `finalAlg`/`finalSorted` are the
>   one-point (terminal) algebra and terminal sorted set.
> * `Sub A` is the type of sub-`S`-sets of `A`; `subAlg` is the subalgebra on one.
>
> ### The two formation classes
>
> `IsAlgebraFormation Sig F` (for a set `F` of algebras) is a **pair** of conditions:
>
> * `F.1` : `HOperator Sig F ⊆ F` — `F` is closed under the **H-operator**, i.e. under
>   homomorphic images. Membership in `HOperator Sig F` means: there are `A ∈ F`, a map
>   `f : A → B`, an `IsAlgHom` proof for `f`, and surjectivity of `f` on every sort.
> * `F.2` : closure under **subdirect products**: for every finite index type `ι`, every
>   family `C : ι → Alg` with `C i ∈ F` for all `i`, and every algebra `A` equipped with a
>   subdirect embedding into `∏_{i} C_i`, one has `A ∈ F`.
>
> `IsShSkFormation Sig F` is a **triple** of conditions:
>
> * `F.1` : every subfinal algebra lies in `F` (`∀ A, SubfinalAlg Sig A → A ∈ F`).
> * `F.2.1` : `HOperator Sig F ⊆ F` (same H-closure as above).
> * `F.2.2` : closure under **intersections of congruences**: if `Φ` and `Ψ` are
>   congruences of an algebra `A` and `A/Φ ∈ F` and `A/Ψ ∈ F`, then `A/(Φ⊓Ψ) ∈ F`.
>
> `IsSubdirectEmbedding Sig A C f`, for `f : A → ∏_{ι} C_i`, is the conjunction:
> `f` is an algebra homomorphism, `f` is injective, and for each `i` the composite
> `π_i ∘ f` is surjective on every sort. (So `f` is an injective hom whose image projects
> onto each factor.)
>
> ## Proven statements
>
> **`algebraFormation_iff_shskFormation`.** For every signature `Sig` and every set `F` of
> algebras:
> `IsAlgebraFormation Sig F ↔ IsShSkFormation Sig F`.
>
> * (⇒) From an algebra formation one builds the triple by taking, for the first component,
>   the fact that every subfinal algebra is in `F` (`subfinalAlg_mem_of_formation`), for the
>   second the H-closure `F.1`, and for the third `formation_congInf`.
> * (⇐) From an Sh/Sk formation one builds the pair by taking the H-closure `F.2.1` and, for
>   closure under subdirect products, invoking `shskFormation_mem_of_subdirect`.
>
> **`shskFormation_mem_of_subdirect`.** Hypotheses: `F` is an Sh/Sk formation; `ι` is a
> **finite** type; `C : ι → Alg` with `C i ∈ F` for all `i`; `A` is an algebra and
> `f : A → ∏_{ι} C_i` is a subdirect embedding. Conclusion: `A ∈ F`.
>
> *Informal proof.* Put `φ_i = π_i ∘ f : A → C_i`. Each `φ_i` is a homomorphism, its kernel
> `ker φ_i` is a congruence, and because `φ_i` is surjective the induced map
> `A/ker φ_i → C_i` is an isomorphism (first isomorphism theorem); hence `A/ker φ_i ∈ F` by
> closure of `F` under isomorphisms (an instance of H-closure). If `ι` is nonempty, iterating
> the meet-closure condition `F.2.2` over the finite set of all indices produces a congruence
> `Ψ = ⋂_i ker φ_i` with `A/Ψ ∈ F`. The identity map `A → A` respects `Ψ` (since `Ψ` is
> contained in the diagonal `ker idA`) and therefore factors through `A/Ψ` as an isomorphism
> `A/Ψ ≅ A`; by H-closure (`formation_abstract`) applied to the isomorphism `A/Ψ → A`, one
> concludes `A ∈ F`. If `ι` is empty, the product is the terminal algebra and injectivity of
> `f` forces `A` to be subfinal, so `A ∈ F` by the first field of `F`.
>
> **`sortedEqvLe_refl`.** For every sorted equivalence `Φ`, `Φ ≤ Φ`. (Reflexivity.)
>
> **`sortedEqvLe_trans`.** For sorted equivalences `Φ, Ψ, Χ`: if `Φ ≤ Ψ` and `Ψ ≤ Χ` then
> `Φ ≤ Χ`. (Transitivity; together with the previous lemma, `≤` is a preorder on sorted
> equivalences.)
>
> ## Declared vocabulary (types only in this file)
>
> `IsAlgebraFormation`, `IsShSkFormation`, `IsSubdirectEmbedding`, `IsCongruence`,
> `IsAlgHom`, `IsAlgIso`, `IsEpiAlg` (epimorphism), `IsMonoAlg` (monomorphism),
> `IsSubalgebra`, `HOperator` (homomorphic-image operator), `PFsdOperator`, `Sub`,
> `Subfinal`, `SubfinalAlg`, `AlgStruct`, `finalAlg`, `finalSorted`, `finOp`, `wordProd`,
> `pr`/`prAlg` (quotient projections), `quot`/`quotAlg`, `quotLift`, `quotOp`, `iAlg`,
> `iPairAlg`, `subAlg`.
>
> Also stated (proofs elsewhere): the relational lemmas used above — `formation_abstract`
> (if `HOperator F ⊆ F`, `A ∈ F`, and `A ≅ B` then `B ∈ F`), `formation_congInf`,
> `formation_mem_of_iso` (isomorphic copy of a member is a member), `isAlgHom_iPairAlg`,
> `isAlgHom_prAlg`, `isAlgIso_symm`, `ker_isCongruence`, `ker_pr`, `ker_prAlg`,
> `quotAlgLift_isAlgHom`, `quotAlg_ker_isAlgIso`, `quotLift_comp`, `subfinalAlg_iff`,
> `subfinalAlg_mem_of_formation`, and `IsCongruence_inf` (the meet of two congruences is a
> congruence).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-C004 — clause-by-clause
>
> Contract (corollary): Definitions `DefFormAlg` and `ShSkFormAlg` are equivalent.
>
> - Clause 1 (the two formation notions coincide). Lean `algebraFormation_iff_shskFormation`
>   states, for every signature `Sig` and every set `F` of algebras,
>   `IsAlgebraFormation Sig F ↔ IsShSkFormation Sig F`. This is precisely the asserted
>   equivalence of the two definitions. Match.
> - Clause 2 (supporting content of the equivalence). The Lean decomposition matches the
>   stated definitions: (⇒) uses `subfinalAlg_mem_of_formation` (subfinal members),
>   `F.1` H-closure and `formation_congInf` (meet-closure) to build the Sh/Sk triple;
>   (⇐) uses the Sh/Sk H-closure `F.2.1` and `shskFormation_mem_of_subdirect` for the
>   subdirect-product closure of the algebra-formation pair. Match.
> - Clause 3 (context of definitions). `IsAlgebraFormation` (H-operator + finite subdirect
>   products) and `IsShSkFormation` (subfinal + H-operator + congruence-meet closure) are
>   both present and explicit in the read-back, consistent with the two named definitions.
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — the biconditional between `IsAlgebraFormation` and `IsShSkFormation` is exactly the asserted equivalence of the two definitions.

