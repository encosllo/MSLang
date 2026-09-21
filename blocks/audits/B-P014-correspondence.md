# Correspondence audit transcript -- `B-P014`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.congruenceFormationsTop`, `Mslang.congruenceFormationsInf`, `Mslang.congruenceFormations_isGLB_sInf`, `Mslang.congruenceFormationsCompleteLattice` (`lean/Mslang/Formation.lean`)
- **Contract:** Proposition `B-P014`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000302` (supersedes `E-000218`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-P014.lean`
>
> ## Ambient setting
>
> A fixed type `S` (the set of **sorts**) is understood. A **signature** `Sig` assigns to
> every pair `p = (w, s)` (a list of sorts `w`, a sort `s`) a type `Sig p` of operation
> symbols. Reused throughout are: `SSet S` (families of types indexed by sorts),
> `SortedMap A B` (sorted families of functions), `SortedEqv A` (sorted families of
> equivalence relations), `Alg Sig` (algebras), `AlgStruct`, `IsAlgHom`, `IsCongruence`,
> `sortedEqvLe Φ Ψ` ("`Φ` refines `Ψ`", `Φ ≤ Ψ`) and `sortedEqvInf Φ Ψ` (the meet, whose
> classes are pairs related in both `Φ` and `Ψ`). Quotients are `quot`/`quotAlg`, with
> projections `pr`/`prAlg`; `ker f` is the kernel relation of a sorted map; `nabla A` is the
> **universal (top) relation** on `A`; `nabla_isCongruence` says `nabla A` is always a
> congruence. `wordProd` and `finOp` describe arities.
>
> `Term Sig X` is the inductive type of **terms** over an `S`-sorted set of variables `X`:
> a term is either a variable `x ∈ X_s` or an operation symbol `σ : Sig (w,s)` applied to
> terms in the sorts listed by `w`. `termAlg Sig X` is the **term (free) algebra** on `X`.
>
> `congruenceFormations Sig` is the type of **congruence formations**: an element
> `G` consists of a family `G.1 : (A : SSet S) → Set (SortedEqv (Term Sig A))` (for each
> sorted set `A`, a set of binary relations on the term algebra over `A`) together with a
> proof `G.2` that it satisfies `IsCongruenceFormation`. The order used on this type is
> **pointwise inclusion**: `B ≤ G` means `∀ A, B.1 A ⊆ G.1 A`.
>
> `IsCongruenceFormation Sig F`, for a family `F : (A : SSet S) → Set (SortedEqv (Term Sig A))`,
> is the conjunction, as used below, of the following.
>
> For every `A`, the set `F A` satisfies:
> 1. it is nonempty — it contains the universal congruence `nabla (Term Sig A)`;
> 2. every member is a congruence on `termAlg Sig A`;
> 3. it is closed under binary meets: `Φ ∈ F A ∧ Ψ ∈ F A → Φ⊓Ψ ∈ F A`;
> 4. it is **upward closed among congruences**: if `Φ ∈ F A`, `Ψ` is a congruence on
>    `termAlg Sig A`, and `Φ ≤ Ψ`, then `Ψ ∈ F A`.
>
> In addition there is a **homomorphism-closure** clause: for any sorted sets `A, B`, any
> congruence `Θ` on `termAlg Sig B` with `Θ ∈ F B`, and any surjective algebra homomorphism
> `f : termAlg Sig A → (termAlg Sig B)/Θ`, the kernel of the composite `prAlg Θ ∘ f` belongs
> to `F A`.
>
> ## Proven statements
>
> **`congruenceFormationsTop`.** The family which to every `A` assigns the set of **all**
> congruences on `termAlg Sig A`. It is verified to be a congruence formation: it contains
> `nabla`; every member is a congruence; it is closed under meets (`IsCongruence_inf`); it is
> trivially upward closed; and the homomorphism clause holds because all congruence-induced
> kernels are congruences (`ker_isCongruence`). Intuitively this is the **top** element of
> the lattice of congruence formations.
>
> **`congruenceFormationsInf`.** Given a set `T` of congruence formations, this is the family
> `A ↦ ⋂_{G ∈ insert (congruenceFormationsTop) T} G.1 A`, i.e. the pointwise intersection of
> the member-families of all formations in `T`, with the top formation adjoined so that the
> intersection is indexed by a nonempty collection. It is verified to be a congruence
> formation (the four pointwise conditions and the homomorphism clause are each inherited
> from the members).
>
> **`congruenceFormationsInfSet`.** The `InfSet (congruenceFormations Sig)` instance whose
> infimum of a set `T` is `congruenceFormationsInf Sig T`.
>
> **`congruenceFormations_isGLB_sInf`.** For every set `T` of congruence formations,
> `congruenceFormationsInf Sig T` is a **greatest lower bound** of `T` with respect to
> pointwise inclusion.
>
> * Lower bound: for each `G ∈ T` and each `A`, `⋂_{H} H.1 A ⊆ G.1 A`, because `G` occurs
>   among the intersected families (`Set.biInter_subset_of_mem`).
> * Greatest: let `B` be any lower bound, i.e. `∀ G ∈ T, B ≤ G`. For any `A` and
>   `x ∈ B.1 A`, one shows `x` lies in every `H.1 A` with `H ∈ insert Top T`. For
>   `H = Top` this uses that every member of `B.1 A` is a congruence (condition 2 above), so
>   `x` is one of all congruences; for `H ∈ T` this uses `B ≤ H`. Hence `x` lies in the
>   intersection, i.e. `B ≤ congruenceFormationsInf Sig T`.
>
> **`congruenceFormationsCompleteLattice`.** The `CompleteLattice (congruenceFormations Sig)`
> instance produced by `completeLatticeOfInf` from the preceding GLB property. Thus the
> congruence formations on `Sig`, ordered by pointwise inclusion, form a **complete lattice**
> whose arbitrary infima are computed pointwise by intersecting the member-families (with the
> top formation adjoined to keep the indexing nonempty).
>
> ## Declared vocabulary (types only in this file)
>
> `AlgStruct`, `IsAlgHom`, `IsCongruence`, `IsCongruenceFormation`, `IsCongruence_inf`
> (meets of congruences are congruences), `SSet`, `Signature`, `SortedEqv`, `SortedMap`,
> `Term` (inductive; constructors `var` and `op`), `congruenceFormations`, `finOp`,
> `isAlgHom_prAlg` (quotient projection is a hom), `ker`, `ker_isCongruence`, `nabla`
> (universal relation), `nabla_isCongruence`, `pr`, `prAlg`, `quot`, `quotAlg`, `quotOp`
> (operations induced on a quotient), `quotOp_mk`, `sortedEqvInf`, `sortedEqvLe`, `termAlg`,
> `wordProd`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P014 — clause-by-clause
>
> Contract (proposition): `Form_Cgr(Σ)` is a complete lattice.
>
> - Clause 1 (the object `Form_Cgr(Σ)`). Lean `congruenceFormations Sig` is the subtype of
>   congruence formations on `Sig` (families `A ↦ Set (SortedEqv (Term Sig A))` satisfying
>   `IsCongruenceFormation`). Match.
> - Clause 2 (complete-lattice structure). Lean `congruenceFormationsCompleteLattice` is a
>   `CompleteLattice (congruenceFormations Sig)` instance, produced by `completeLatticeOfInf`
>   from `congruenceFormations_isGLB_sInf`. Match.
> - Clause 3 (order and infima). The read-back fixes the order as pointwise inclusion
>   (`B ≤ G ↔ ∀ A, B.1 A ⊆ G.1 A`) and computes arbitrary infima pointwise by intersecting
>   member-families (with the top formation adjoined for nonemptiness), established as a GLB by
>   `congruenceFormations_isGLB_sInf`. Consistent with a complete lattice on this object.
> - Clause 4 (existence of the top/infrastructure). `congruenceFormationsTop` supplies the top
>   element; `congruenceFormationsInf`/`congruenceFormationsInfSet` supply the `InfSet`.
>   Supporting, not extra claims.
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — the Lean builds exactly a `CompleteLattice` instance for the congruence formations under the pointwise-inclusion order, which is what the contract asserts.

