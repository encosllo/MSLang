# Correspondence audit transcript -- `B-P017`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.pairAlgFamily`, `Mslang.isAlgIso_symm`, `Mslang.quotAlg_ker_isAlgIso`, `Mslang.formation_mem_of_iso`, `Mslang.shskFormation_mem_of_subdirect_pair` (`lean/Mslang/Formation.lean`)
- **Contract:** Proposition `B-P017`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000305` (supersedes `E-000131`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-P017.lean`
>
> ## Ambient setting
>
> A fixed type `S` (the set of **sorts**) is understood. A **signature** `Sig` assigns to
> every pair `p = (w, s)` (list of sorts `w`, sort `s`) a type `Sig p` of operation symbols.
> Reused vocabulary: `SSet S` (sorted families of types), `SortedMap A B` (sorted families of
> maps), `SortedEqv A` (sorted families of equivalence relations), `Alg Sig` (algebras),
> `AlgStruct`, `IsAlgHom`, `IsAlgIso`, `IsCongruence`,
> `sortedEqvLe Φ Ψ` ("`Φ` refines `Ψ`", `Φ ≤ Ψ`), `sortedEqvInf Φ Ψ` (their meet),
> `IsCongruence_inf`, `ker f`, `quot`/`quotAlg`, `pr`/`prAlg`, `quotLift`,
> `quotAlgLift_isAlgHom`, `iAlg` (product algebra), `iProjAlg` (projection from a product),
> `IsSubdirectEmbedding`, `IsShSkFormation`, `HOperator`, `IsAlgebraFormation`,
> `formation_abstract`, `SubfinalAlg`, `finalAlg`, `subAlg`, `wordProd`, `finOp`.
>
> Recall:
> * `IsSubdirectEmbedding Sig A C f`, for `f : A → ∏_i C_i`, means `f` is a homomorphism,
>   injective, and each `π_i ∘ f` is surjective.
> * `IsShSkFormation Sig F` is a triple: every subfinal algebra lies in `F`; `F` is closed
>   under the H-operator (`HOperator Sig F ⊆ F`, i.e. under homomorphic images); and if
>   `Φ, Ψ` are congruences of `A` with `A/Φ, A/Ψ ∈ F` then `A/(Φ⊓Ψ) ∈ F`.
> * `formation_abstract` : if `HOperator Sig F ⊆ F`, `A ∈ F`, and `f : A → B` is an algebra
>   isomorphism, then `B ∈ F`.
>
> ## Proven statements
>
> **`pairAlgFamily`.** The definition of the two-element family of algebras on the index type
> `ULift Bool`: it sends `false` to `B` and `true` to `C`. (A concrete "pair" family used to
> phrase a binary product.)
>
> **`isAlgIso_symm`.** If `f : A → B` is an algebra isomorphism (bijective homomorphism, with
> `hf.1` the homomorphism property and `hf.2 s` bijectivity on sort `s`), then the pointwise
> inverse `f⁻¹`, defined on sort `s` as the inverse of the bijection `f_s`, is an algebra
> isomorphism `B → A`. The proof applies `f` to both sides and uses that `f` preserves
> operations to transport the operation law across the inverse.
>
> **`quotAlg_ker_isAlgIso` (first isomorphism theorem).** If `f : A → B` is an algebra
> homomorphism that is surjective on every sort, then the canonical map
> `A/ker f → B` induced by `f` (via `quotLift` along `ker f ≤ ker f`) is an algebra
> isomorphism. Injectivity: if two classes have the same image under this map then their
> representatives have equal `f`-images, hence are `ker f`-equivalent. Surjectivity: for each
> `b ∈ B_s` pick a preimage `a` of `b` and use the class of `a`.
>
> **`formation_mem_of_iso`.** Let `HOperator Sig F ⊆ F`, let `X ∈ F`, and let `f : Y → X` be
> an algebra isomorphism. Then `Y ∈ F`. (Combine `formation_abstract` with the inverse
> isomorphism from `isAlgIso_symm`.)
>
> **`shskFormation_mem_of_subdirect_pair`.** Let `F` be an Sh/Sk formation, let `B, C ∈ F`,
> let `A` be an algebra, and let `f : A → B × C` (more precisely, into the product over
> `pairAlgFamily Sig B C`) be a subdirect embedding. Then `A ∈ F`.
>
> *Informal proof.* Let `φ : A → B` and `ψ : A → C` be the composites of `f` with the two
> projections; each is a homomorphism and, by subdirectness, surjective. Their kernels
> `ker φ`, `ker ψ` are congruences, and by the first isomorphism theorem
> `A/ker φ ≅ B` and `A/ker ψ ≅ C`, so both quotients lie in `F` (closure under isomorphisms).
> The meet `ker φ ⊓ ker ψ` is a congruence and, by the meet-closure field of an Sh/Sk
> formation, `A/(ker φ ⊓ ker ψ) ∈ F`. The identity map `A → A`, whose kernel is the diagonal,
> is coarser than `ker φ ⊓ ker ψ` (an element related by both is mapped by `f` to the same
> pair, and subdirectness makes `f` injective), so it factors through the quotient as an
> isomorphism `A/(ker φ ⊓ ker ψ) ≅ A`; closure under isomorphisms yields `A ∈ F`.
>
> This is the two-factor (`Bool`-indexed) special case of the general subdirect-product
> membership lemma.
>
> ## Declared vocabulary (types only in this file)
>
> `AlgStruct`, `HOperator`, `IsAlgHom`, `IsAlgIso`, `IsCongruence`, `IsCongruence_inf`,
> `IsEpiAlg`, `IsMonoAlg`, `IsShSkFormation`, `IsSubalgebra`, `IsSubdirectEmbedding`, `SSet`,
> `Signature`, `SortedEqv`, `SortedMap`, `Sub`, `SubfinalAlg`, `finOp`, `finalAlg`,
> `finalSorted`, `formation_abstract`, `iAlg`, `iProjAlg`, `ker`, `ker_isCongruence`, `quot`,
> `quotAlg`, `quotAlgLift_isAlgHom`, `quotLift`, `quotOp`, `sortedEqvInf`, `sortedEqvLe`,
> `subAlg`, `wordProd`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P017 — clause-by-clause
>
> Contract (proposition): Let `F` be an ShSk-formation of `Σ`-algebras. Then, for every
> `Σ`-algebra `A`, every `B, C ∈ F`, and every subdirect embedding `f` of `A` in `B×C`, we
> have `A ∈ F`.
>
> - Clause 1 (`F` an ShSk-formation). Lean hypothesis `F` with `IsShSkFormation Sig F`. Match.
> - Clause 2 (`A` a `Σ`-algebra). Lean `A` an algebra. Match.
> - Clause 3 (`B, C ∈ F`). Lean hypotheses `B, C ∈ F`. Match.
> - Clause 4 (`f : A → B×C` a subdirect embedding). Lean `f` into the product over
>   `pairAlgFamily Sig B C` satisfying `IsSubdirectEmbedding` (hom, injective, surjective onto
>   each factor). Match.
> - Clause 5 (conclusion `A ∈ F`). Lean concludes `A ∈ F`. Match.
> - Clause 6 (proof content). Lean proceeds via `ker φ`, `ker ψ`, the first isomorphism theorem
>   (`quotAlg_ker_isAlgIso`), the meet-closure field of the Sh/Sk formation, and
>   `formation_mem_of_iso`. Consistent with the Sh/Sk hypotheses; no extra assumption is used.
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — `shskFormation_mem_of_subdirect_pair` states the contract's two-factor subdirect-embedding membership with exactly the same hypotheses and conclusion.

