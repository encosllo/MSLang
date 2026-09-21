# Correspondence audit transcript -- `B-P019`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.congruenceFormationOf`, `Mslang.congruenceFormation_isCongruenceFormation` (`lean/Mslang/Formation.lean`)
- **Contract:** Proposition `B-P019`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000306` (supersedes `E-000176`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-P019.lean`
>
> ## Ambient setting
>
> A fixed type `S` (the set of **sorts**) is understood. A **signature** `Sig` assigns to
> every pair `p = (w, s)` (list of sorts `w`, sort `s`) a type `Sig p` of operation symbols.
> Reused vocabulary: `SSet S` (sorted families of types), `SortedMap A B` (sorted families of
> maps), `SortedEqv A` (sorted families of equivalence relations), `Alg Sig` (algebras),
> `AlgStruct`, `IsAlgHom`, `IsAlgIso`, `IsCongruence`,
> `sortedEqvLe Φ Ψ` ("`Φ` refines `Ψ`", i.e. `Φ_s ⊆ Ψ_s` for every sort `s`),
> `sortedEqvInf Φ Ψ` (meet), `IsCongruence_inf` (meets of congruences are congruences),
> `ker f` (kernel relation), `ker_isCongruence`, `ker_pr`, `ker_prAlg` (the kernel of the
> quotient projection is the relation itself), `pr`/`prAlg` (quotient projection),
> `quot`/`quotAlg`, `quotLift`, `quotAlgLift_isAlgHom`, `nabla` (the universal relation) and
> `nabla_isCongruence`, `Term Sig X` (terms over the variable set `X`), `termAlg Sig X` (the
> term/free algebra on `X`), `iAlg`, `iPairAlg`, `isAlgHom_iPairAlg`, `isAlgHom_prAlg`,
> `IsAlgebraFormation`, `HOperator`, `formation_congInf`, `formation_mem_of_iso`,
> `subfinalAlg_mem_of_formation`, `SubfinalAlg`, `subAlg`, `wordProd`, `finOp`,
> `IsCongruenceFormation`.
>
> Recall:
> * `IsAlgebraFormation Sig F` is a pair: `F.1` says `F` is closed under the H-operator
>   (`HOperator Sig F ⊆ F`; membership means "is a surjective homomorphic image of a member
>   of `F`"), and `F.2` says `F` is closed under subdirect products.
> * `HOperator Sig F` is the class of homomorphic images: `B ∈ HOperator Sig F` iff there
>   are `A ∈ F`, a map `f : A → B`, a proof that `f` is an algebra homomorphism, and a proof
>   that `f` is surjective on every sort.
> * `IsCongruenceFormation Sig F`, for `F : (A : SSet S) → Set (SortedEqv (Term Sig A))`,
>   consists of, for each `A`, the conditions (1) `F A` is nonempty (contains `nabla`),
>   (2) every member of `F A` is a congruence on `termAlg Sig A`, (3) `F A` is closed under
>   binary meets, (4) `F A` is upward closed among congruences (if `Φ ∈ F A`, `Ψ` is a
>   congruence and `Φ ≤ Ψ`, then `Ψ ∈ F A`); plus a homomorphism clause: for any `A, B`, any
>   congruence `Θ` on `termAlg Sig B` with `Θ ∈ F B`, and any surjective homomorphism
>   `f : termAlg Sig A → (termAlg Sig B)/Θ`, the kernel of `prAlg Θ ∘ f` lies in `F A`.
> * `SubfinalAlg Sig X` says every sort of `X` has at most one element; by
>   `subfinalAlg_mem_of_formation`, every subfinal algebra belongs to every algebra formation.
>
> ## Proven statements
>
> **`congruenceFormationOf`.** For a set `F` of algebras, the family assigning to each sorted
> set `A` the set of those congruences `Φ` on the term algebra `termAlg Sig A` for which the
> quotient belongs to `F`:
>
> `{Φ | ∃ hΦ : IsCongruence Sig (termAlg Sig A).2 Φ, quotAlg Sig (termAlg Sig A).2 Φ hΦ ∈ F}`.
>
> **`congruenceFormation_isCongruenceFormation`.** If `F` is an algebra formation
> (`hF : IsAlgebraFormation Sig F`), then `congruenceFormationOf Sig F` is a congruence
> formation (`IsCongruenceFormation Sig (congruenceFormationOf Sig F)`). The two parts:
>
> * For every `A`, the set `congruenceFormationOf Sig F A` satisfies:
>   1. *Nonempty.* The universal relation `nabla (Term Sig A)` is a congruence, and its
>      quotient `(Term Sig A)/nabla` is subfinal (`quot_nabla_subfinal`); since every subfinal
>      algebra is in `F` (`subfinalAlg_mem_of_formation`), `nabla (Term Sig A)` is a member.
>   2. *Members are congruences.* Immediate from the definition.
>   3. *Closed under meets.* If `Φ, Ψ` are members (so their quotients lie in `F`), then the
>      quotient by `Φ ⊓ Ψ` lies in `F` by `formation_congInf`; hence `Φ ⊓ Ψ` is a member.
>   4. *Upward closure.* If `Φ` is a member (`A/Φ ∈ F`), `Ψ` is a congruence on the term
>      algebra, and `Φ ≤ Ψ`, then `A/Ψ ∈ F`. Indeed `Φ ≤ Ψ` gives a canonical surjective
>      homomorphism `A/Φ → A/Ψ` (`quotLift`), which is a homomorphism between the quotients;
>      as `F` is closed under surjective homomorphic images (`hF.1`), `A/Ψ ∈ F`. Hence `Ψ` is
>      a member.
> * *Homomorphism clause.* Given `A, B`, a congruence `Θ` on `termAlg Sig B` with
>   `Θ ∈ congruenceFormationOf Sig F B` (so in particular `(termAlg B)/Θ ∈ F`), and a
>   surjective homomorphism `f : termAlg Sig A → (termAlg Sig B)/Θ`, form
>   `g = prAlg Θ ∘ f`, which is a homomorphism; by the first isomorphism theorem
>   `(termAlg A)/ker g ≅ (termAlg B)/Θ`, whose right side lies in `F`, so by closure under
>   isomorphisms (`formation_mem_of_iso` applied with `hF.1`) the left side lies in `F`; hence
>   `ker g ∈ congruenceFormationOf Sig F A`.
>
> **`quot_nabla_subfinal`.** For every algebra `A`, the quotient of `A` by the universal
> congruence `nabla A` is subfinal (`SubfinalAlg Sig (quotAlg Sig F (nabla A) ...)`), i.e.
> each sort of `A/nabla` has at most one element.
>
> ## Declared vocabulary (types only in this file)
>
> `AlgStruct`, `HOperator`, `IsAlgHom`, `IsAlgIso`, `IsAlgebraFormation`, `IsCongruence`,
> `IsCongruenceFormation`, `IsCongruence_inf`, `IsEpiAlg`, `IsMonoAlg`, `IsSubalgebra`,
> `IsSubdirectEmbedding`, `PFsdOperator`, `SSet`, `Signature`, `SortedEqv`, `SortedMap`,
> `Sub`, `Subfinal`, `SubfinalAlg`, `Term` (inductive; `var` and `op`), `finOp`, `finalAlg`,
> `finalSorted`, `formation_abstract`, `formation_congInf`, `formation_mem_of_iso`, `iAlg`,
> `iPairAlg`, `isAlgHom_iPairAlg`, `isAlgHom_prAlg`, `isAlgIso_symm`, `ker`,
> `ker_isCongruence`, `ker_pr`, `ker_prAlg`, `nabla`, `nabla_isCongruence`, `pr`, `prAlg`,
> `quot`, `quotAlg`, `quotAlgLift_isAlgHom`, `quotAlg_ker_isAlgIso`, `quotLift`,
> `quotLift_comp`, `quotOp`, `quotOp_mk`, `sortedEqvInf`, `sortedEqvLe`, `subAlg`,
> `subfinalAlg_iff`, `subfinalAlg_mem_of_formation`, `termAlg`, `wordProd`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P019 — clause-by-clause
>
> Contract (proposition): Let `F` be a formation of `Σ`-algebras. Then the function `𝔉_F`
> from `U^S` which assigns to `A ∈ U^S` the subset
> `𝔉_F(A) = {Φ ∈ Cgr(T_Σ(A)) | T_Σ(A)/Φ ∈ F}` of `Cgr(T_Σ(A))` is a formation of congruences
> with respect to `Σ`.
>
> - Clause 1 (`F` a formation of `Σ`-algebras). Lean hypothesis `hF : IsAlgebraFormation Sig F`.
>   Match.
> - Clause 2 (the function `𝔉_F` on `U^S`). Lean `congruenceFormationOf Sig F` maps each sorted
>   set `A : SSet S` to a set of binary relations on `Term Sig A`. Match.
> - Clause 3 (defining value of `𝔉_F`). Lean defines it as
>   `{Φ | ∃ hΦ : IsCongruence Sig (termAlg Sig A).2 Φ, quotAlg Sig (termAlg Sig A).2 Φ hΦ ∈ F}`,
>   i.e. exactly `{Φ ∈ Cgr(T_Σ(A)) | T_Σ(A)/Φ ∈ F}` (the `∃` congruence proof is the `∈ Cgr`
>   condition). Match.
> - Clause 4 (conclusion: `𝔉_F` is a formation of congruences). Lean
>   `congruenceFormation_isCongruenceFormation` proves
>   `IsCongruenceFormation Sig (congruenceFormationOf Sig F)`. Match.
> - Clause 5 (proof content). Nonemptiness via `quot_nabla_subfinal` and
>   `subfinalAlg_mem_of_formation`; meets via `formation_congInf`; upward closure via `hF.1`;
>   homomorphism clause via the first isomorphism theorem and `formation_mem_of_iso`.
>   Consistent, no extra claim, no weakened hypothesis.
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — the Lean construction is exactly `𝔉_F` and it is proved to be an `IsCongruenceFormation` under the same formation hypothesis.

