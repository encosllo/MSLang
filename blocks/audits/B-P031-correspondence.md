# Correspondence audit transcript -- `B-P031`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.quotLe`, `Mslang.quotLe_mk`, `Mslang.isFiniteIndex_nabla`, `Mslang.IsFiniteIndex_of_le`, `Mslang.IsFiniteIndex_inf`, `Mslang.congFi_filter` (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P031`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000317` (supersedes `E-000187`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-P031 — read-back (informal mathematics)
>
> ## Ambient setting
>
> `S` is a type of **sorts**; `SSet S` is a sorted set (a family of types over
> sorts); `Signature S` is a many-sorted signature with operation symbols indexed
> by `p = (w, s)` (`w : List S` input word, `s` result sort). `SortedEqv A` is a
> sorted equivalence relation on `A`; `SortedMap A B` is a sort-preserving
> function; `quot Φ` is the quotient sorted set by `Φ`; `supp A : Set S` is the
> support of the sorted set `A` (the sorts on which `A` is nonempty); `finOp` and
> `wordProd` are the arity types. `AlgStruct Sig A` gives `A` an algebra
> structure, and `IsCongruence Sig F Φ` says `Φ` is a congruence of the algebra
> `(A,F)`.
>
> Order and lattice on sorted equivalences:
>
> * `sortedEqvLe Φ Ψ` is **refinement** (Φ is a sub-relation of Ψ).
> * `sortedEqvInf Φ Ψ` is the **binary meet** (intersection relation).
> * `IsCongruence_inf` (`B-P031.lean:100`) states that the meet of two
>   congruences is again a congruence.
> * `nabla A` (`:120`) is the universal relation; `nabla_isCongruence` (`:122`)
>   says it is a congruence.
>
> Finiteness notions:
>
> * `FiniteSSet A` (`:95`) says the total carrier `Σ s, A s` is finite.
> * `IsFiniteIndex Φ` (`:105`) says the quotient `quot Φ` is a finite sorted set,
>   i.e. `Finite (Σ s, A s / Φ s)` — `Φ` has finitely many classes in total.
>
> `congFi Sig F` (`:115`) is the set of congruences `Φ` of the algebra `(A,F)`
> that have finite index.
>
> ## Definitions introduced by this file
>
> * `quotLe Φ Ψ h` (`:1`), for `h : sortedEqvLe Φ Ψ`, is the sorted map
>   `quot Φ → quot Ψ` sending the `Φ`-class of an element to its `Ψ`-class; it is
>   well-defined precisely because `Φ` refines `Ψ` (`Quotient.lift` along `h`).
> * `quotLe_mk` (`:7`): on a representative, `quotLe Φ Ψ h s (mk (Φ s) a) =
>   mk (Ψ s) a`. (Definitional equality.)
>
> ## Theorems
>
> 1. `isFiniteIndex_nabla` (`:12`).
>    Hypotheses: `A : SSet S`; `h : (supp A).Finite`.
>    Conclusion: `IsFiniteIndex (nabla A)`.
>    In words: if only finitely many sorts are nonempty, then the universal
>    relation has finitely many classes (one class per nonempty sort). The proof
>    uses surjectivity of the map from the support `↥(supp A)` onto
>    `Σ s, A s / nabla A`.
>
> 2. `IsFiniteIndex_of_le` (`:27`).
>    Hypotheses: `h : sortedEqvLe Φ Ψ`; `hΦ : IsFiniteIndex Φ`.
>    Conclusion: `IsFiniteIndex Ψ`.
>    Direction: `Φ` refines `Ψ`. Since `Φ` has finite index, `Ψ` does too: the
>    class map `quotLe Φ Ψ h` is a surjection from `quot Φ` onto `quot Ψ`, and a
>    surjective image of a finite set is finite. Note the hypothesis is placed on
>    the *finer* relation `Φ`; the conclusion on the *coarser* `Ψ`.
>
> 3. `IsFiniteIndex_inf` (`:41`).
>    Hypotheses: `hΦ : IsFiniteIndex Φ`; `hΨ : IsFiniteIndex Ψ`.
>    Conclusion: `IsFiniteIndex (sortedEqvInf Φ Ψ)`.
>    In words: the meet (intersection) of two finite-index equivalences has finite
>    index. The proof uses that an element is determined by (its `Φ`-class, its
>    `Ψ`-class): the map
>    `quot (Φ ∧ Ψ) → quot Φ × quot Ψ`, `[a] ↦ ([a]_Φ, [a]_Ψ)`,
>    is injective, so the domain is finite as a subset of a finite product. (It
>    uses `sortedEqvInf_le_left` and `sortedEqvInf_le_right`, i.e. the meet is
>    below both factors in the refinement order.)
>
> 4. `congFi_filter` (`:79`).
>    Hypotheses: `Sig : Signature S`; `F : AlgStruct Sig A`; `hfin : (supp A).Finite`.
>    Conclusion (a conjunction of three statements about `congFi Sig F`):
>    * **Nonempty**: `(congFi Sig F).Nonempty`. Witness: `nabla A`, which is a
>      congruence (`nabla_isCongruence`) and has finite index
>      (`isFiniteIndex_nabla` from `hfin`).
>    * **Closed under binary meet**: for all `Φ ∈ congFi Sig F` and
>      `Ψ ∈ congFi Sig F`, also `sortedEqvInf Φ Ψ ∈ congFi Sig F`. Uses
>      `IsCongruence_inf` and `IsFiniteIndex_inf`.
>    * **Upward closed among congruences**: for all `Φ ∈ congFi Sig F`, all
>      `Ψ : SortedEqv A` with `IsCongruence Sig F Ψ` and `sortedEqvLe Φ Ψ`, we
>      have `Ψ ∈ congFi Sig F`. Uses `IsFiniteIndex_of_le` applied to `Φ ≤ Ψ`.
>    So `congFi Sig F` is a **filter** in the lattice of congruences of the
>    algebra, when the support of `A` is finite, with `∇` as bottom element (in
>    the refinement order the universal relation is the least element).
>
> Other declarations (`AlgStruct`, `FiniteSSet`, `IsCongruence`,
> `IsCongruence_inf`, `IsFiniteIndex`, `nabla`, `quot`, `sortedEqvInf`,
> `sortedEqvLe`, `supp`, `wordProd`, `finOp`, etc.) are signature-only interface
> statements; their reading is given in the "Ambient setting" section.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P031 verdict
>
> ## Clause-by-clause
>
> **Hypothesis: `supp_S(A)` finite.**
> Lean `congFi_filter` assumes `hfin : (supp A).Finite`. Match.
>
> **Object: `Cgr_fi(A)` vs `congFi Sig F`.**
> Contract: finite-index congruences of the algebra. Lean `congFi Sig F` is
> `{Φ | IsCongruence Sig F Φ ∧ IsFiniteIndex Φ}` (finite index = finitely many
> classes). Match.
>
> **Clause: `Cgr_fi(A)` is a filter.**
> A lattice filter is nonempty, upward closed, and closed under binary meets.
> Lean's conclusion is the conjunction:
> - Nonempty: `(congFi Sig F).Nonempty`, witness `nabla` (`nabla_isCongruence`
>   plus `isFiniteIndex_nabla` from `hfin`).
> - Closed under binary meet: `Φ, Ψ ∈ congFi ⟹ sortedEqvInf Φ Ψ ∈ congFi`
>   (`IsCongruence_inf`, `IsFiniteIndex_inf`).
> - Upward closed among congruences: `Φ ∈ congFi`, `IsCongruence Ψ`, `Φ ≤ Ψ`
>   ⟹ `Ψ ∈ congFi` (`IsFiniteIndex_of_le`).
> Match: this is exactly the filter condition.
>
> **Background descriptor "of the algebraic lattice `Cgr(A)`".**
> The algebraicity of the lattice of congruences is not asserted/proved as a
> separate clause in the Lean read-back; it is ambient context for the filter
> notion. The proposition's own assertion is only the filter property of
> `Cgr_fi(A)`, which is fully formalized.
>
> Contract clauses with no Lean counterpart: none (algebraicity of `Cgr(A)` is
> background, not part of the proposition's claim about `Cgr_fi`).
>
> Verdict: equivalent — the finite-support hypothesis and the three filter
> conditions (nonempty, meet-closed, upward-closed) correspond exactly to
> `congFi_filter` and its component proofs.

