# Correspondence audit transcript -- `B-P032`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.isFiniteIndex_ker_of_finite`, `Mslang.finiteIndexCongruenceFormationsTop`, `Mslang.finiteIndexCongruenceFormationsInf`, `Mslang.finiteIndexCongruenceFormations_isGLB_sInf`, `Mslang.finiteIndexCongruenceFormationsCompleteLattice` (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P032`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000318` (supersedes `E-000220`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is therefore faithful, not a
> weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-P032 — read-back (informal mathematics)
>
> ## Ambient setting
>
> `S` is a type of **sorts**; `SSet S` is a sorted set (a family of types over
> sorts); `Signature S` is a many-sorted signature whose operation symbols are
> indexed by `p = (w, s)` with input word `w : List S` and result sort `s`;
> `Term Sig X` is the many-sorted term algebra on variables `X`, and
> `termAlg Sig X` packages it as an algebra. `SortedEqv A` is a sorted equivalence
> relation on `A`; `SortedMap A B` is a sort-preserving function; `quot Φ` is the
> quotient sorted set by `Φ`; `supp A` is the support. `FiniteSSet A` (`:122`)
> says the total carrier `Σ s, A s` is finite; `IsFiniteIndex Φ` (`:138`) says the
> quotient `quot Φ` is a finite sorted set (finitely many classes in total).
> `ker f` (`:178`) is the kernel relation of `f`; `IsAlgHom` is the algebra
> homomorphism predicate; `IsCongruence` is the congruence predicate.
> `congFi Sig F` (`:163`) is the set of congruences of the algebra `(A,F)` of
> finite index.
>
> The order used on "formations" `G : (A : SSet S) → Set (SortedEqv (Term Sig A))`
> is pointwise inclusion: `G ≤ H` iff for every `A`, `G A ⊆ H A`.
>
> `IsCongruenceFormation Sig G` (`:130`) is the predicate that for every `A` the
> set `G A` is nonempty, every member is a congruence of the term algebra,
> the set is closed under binary meets and upward closed among congruences, and
> additionally is closed under the kernel operation along homomorphisms that are
> surjective onto quotients (the "semantic" closure used in
> `langFormationOf_ker`).
>
> `IsFiniteIndexCongruenceFormation Sig G` (`:140`) is the additional condition
> that every congruence belonging to a formation has finite index.
>
> `finiteIndexCongruenceFormations Sig` (`:168`) is the set (subtype) of all
> `G` satisfying `IsFiniteIndexCongruenceFormation`: the **finite-index
> congruence formations**. An element `G` is accessed as `G.1` (the underlying
> function) with `G.2` the bundled proof.
>
> ## Theorems and constructions
>
> 1. `isFiniteIndex_ker_of_finite` (`:1`).
>    Hypotheses: `f : SortedMap A B`; `hB : FiniteSSet B`.
>    Conclusion: `IsFiniteIndex (ker f)`.
>    In words: the kernel of any sorted map into a finite sorted set has finite
>    index. Direction: if `B` is finite, then `A / ker f` is finite, because
>    `[a] ↦ f a` gives an injective map `quot (ker f) → B` (well-defined since
>    `ker f`-related elements have equal `f`-values).
>
> 2. `finiteIndexCongruenceFormationsTop` (`:23`), assuming `[Finite S]`.
>    Construction: `A ↦ congFi Sig (termAlg Sig A).2`, i.e. assign to each
>    variable set `A` the set of finite-index congruences of the term algebra
>    over `A`. It is shown to be a member of
>    `finiteIndexCongruenceFormations Sig` (lines 26–55): each `congFi` is
>    nonempty (contains `nabla`), consists of congruences, is closed under meets
>    and upward closed, and is closed under the required kernels; the finite-index
>    condition holds by construction. It serves as the top element for the
>    pointwise-inclusion order.
>
> 3. `finiteIndexCongruenceFormationsInf` (`:57`), assuming `[Finite S]`.
>    Inputs: `Sig`, and `T : Set (finiteIndexCongruenceFormations Sig)`.
>    Construction: the formation
>    `A ↦ ⋂ { G.1 A : G ∈ insert (finiteIndexCongruenceFormationsTop Sig) T }`,
>    i.e. the pointwise intersection over `T` together with the top formation.
>    It is a finite-index congruence formation: nonemptiness is witnessed by
>    `nabla` (each member formation contains `nabla`, since `nabla` is a
>    congruence and each member formation is nonempty and upward/meet closed);
>    closure under meets and upward closure are inherited pointwise from each
>    `G`; kernel closure is inherited pointwise; and the finite-index condition is
>    inherited from any member (the inserted top guarantees the index set is
>    nonempty).
>
> 4. `finiteIndexCongruenceFormationsInfSet` (`:93`), assuming `[Finite S]`:
>    the `InfSet` instance whose infimum is `finiteIndexCongruenceFormationsInf`.
>
> 5. `finiteIndexCongruenceFormations_isGLB_sInf` (`:97`), assuming `[Finite S]`.
>    Inputs: `Sig`, `T : Set (finiteIndexCongruenceFormations Sig)`.
>    Conclusion: `IsGLB T (finiteIndexCongruenceFormationsInf Sig T)`.
>    Reading (with pointwise inclusion `≤`): (i) the intersection is a **lower
>    bound**: for every `G ∈ T`, `inf ≤ G` (pointwise, `inf A ⊆ G A`); (ii) it is
>    the **greatest** lower bound: for every `B` with `B ≤ G` for all `G ∈ T`,
>    `B ≤ inf` (pointwise `B A ⊆ ⋂_{G} G A`). The inserted top element is handled
>    in the second part using the finite-index property of `B`.
>
> 6. `finiteIndexCongruenceFormationsCompleteLattice` (`:114`), assuming
>    `[Finite S]`: the complete lattice structure on
>    `finiteIndexCongruenceFormations Sig` obtained from the `IsGLB` property of
>    the pointwise intersection (`completeLatticeOfInf`), i.e. arbitrary meets are
>    the pointwise intersections and joins are derived.
>
> The remaining lines (`AlgStruct`, `FiniteSSet`, `IsAlgHom`, `IsCongruence`,
> `IsCongruence_inf`, `IsFiniteIndex`, `IsFiniteIndex_inf`,
> `IsFiniteIndex_of_le`, `nabla`, `quot`, `quotLift`, `termAlg`, `wordProd`,
> `finOp`, etc.) are signature-only interface statements; their reading is as
> described in the "Ambient setting" section (`IsCongruence_inf` = meet of two
> congruences is a congruence; `IsFiniteIndex_inf` = meet of finite-index
> relations has finite index; `IsFiniteIndex_of_le` = a relation coarser than a
> finite-index relation has finite index).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P032 verdict
>
> Contract clause 1: "Form_{Cgr_fi}(Σ) is a complete lattice."
>
> - Lean counterpart: `finiteIndexCongruenceFormations Sig` is the collection
>   Form_{Cgr_fi}; `finiteIndexCongruenceFormationsCompleteLattice` (under the
>   standing `[Finite S]`) endows it with a `CompleteLattice` structure, derived
>   from `finiteIndexCongruenceFormations_isGLB_sInf` via `completeLatticeOfInf`.
>   The contract's single clause is matched exactly.
> - The remaining read-back material (`finiteIndexCongruenceFormationsTop`,
>   `..._Inf`, `isFiniteIndex_ker_of_finite`, etc.) is supporting context; it does
>   not alter or weaken the contract clause.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the read-back establishes exactly the claimed complete
> lattice structure on Form_{Cgr_fi}, with `[Finite S]` supplied by the standing
> assumption.

