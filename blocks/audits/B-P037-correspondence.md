# Correspondence audit transcript -- `B-P037`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.langFormationOf_isRegularLanguageFormation` (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P037`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000322` (supersedes `E-000195`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is therefore faithful, not a
> weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-P037 — informal read-back
>
> ## Setting
>
> `S` is a fixed type of *sorts*. `SSet S` is the type of `S`-sorted sets (a
> family `s ↦ A s` of types). `Signature S` is a many-sorted algebraic signature.
> `Sub A` is the type of sub-sorted-sets of `A`. `SortedMap A B` is the type of
> sort-preserving maps. `SortedEqv A` is a *sorted equivalence*: an equivalence
> relation on each sort `A s`. `Term Sig X` is the inductive type of many-sorted
> terms over the signature with variables drawn from the sorted set `X`.
>
> `sortedEqvLe Φ Ψ` means **Φ refines Ψ** (Φ is the finer relation; as relations
> `Φ ⊆ Ψ`); `sortedEqvInf Φ Ψ` is the binary meet; `sortedEqvLe_antisymm` makes
> this a partial order. `IsSat Φ X` means the sub-sorted-set `X` is saturated by
> `Φ` (a union of `Φ`-classes).
>
> `AlgStruct Sig A` is an algebra structure on `A`; `IsAlgHom` / `IsCongruence`
> have their usual meanings; `FiniteSSet A` says `A` is finite. `IsFiniteIndex Φ`
> says `Φ` has finitely many classes.
>
> `TlGen Sig A t s T` is the inductive closure asserting `T : A t → A s` is a
> translation: it contains identities (`refl`), all elementary translations
> `IsElemTranslation` (`elem`), and is closed under composition (`comp`).
>
> A *congruence formation* is a family `G : (A : SSet S) → Set (SortedEqv (Term
> Sig A))`; `IsCongruenceFormation Sig G` says `G` is such a formation.
> `IsFiniteIndexCongruenceFormation Sig G` says `G` is a congruence formation all
> of whose members are finite-index congruences and which is closed under the
> appropriate operations. A *language formation* is a family
> `L : (A : SSet S) → Set (Sub (Term Sig A))`; `IsRegularLanguageFormation Sig L`
> says `L` is a regular-language formation. `IsRegularLanguage Sig A L` says a
> single language `L ⊆ A.1` is regular.
>
> ## Main theorem (with proof body)
>
> `langFormationOf_isRegularLanguageFormation`:
> If `G` is a finite-index congruence formation, then `langFormationOf Sig G` is a
> regular-language formation.
>
> The proof constructs the four required fields of `IsRegularLanguageFormation`:
> 1. a regularity/closure component derived from `hG.2`;
> 2. closure under languages saturated by `nabla`: for every `A` and `X`, if
>    `IsSat (nabla (Term Sig A)) X` then `X ∈ langFormationOf Sig G A`
>    (`langFormationOf_nabla`);
> 3. closure under binary intersections, with the saturation condition phrased
>    through the meet of the two cogenerated congruences (`langFormationOf_inf`);
> 4. closure under inverse images along the surjective homomorphisms considered in
>    `langFormationOf_ker`.
>
> So a regular-language formation is (at least) a class of language families
> containing the `nabla`-saturated languages and closed under intersections and
> under the "kernel/inverse-image" operation.
>
> ## Declarations (bodies not given in this file)
>
> ### Core order and saturation
> - `sortedEqvLe Φ Ψ`: refinement order (Φ finer than Ψ).
> - `sortedEqvInf Φ Ψ`: binary meet.
> - `sortedEqvLe_antisymm`: if `Φ ≤ Ψ` and `Ψ ≤ Φ` then `Φ = Ψ` (antisymmetry, so
>   the refinement relation is a partial order).
> - `sat Φ X`: saturation of `X` by `Φ`.
> - `IsSat Φ X`: `X` is saturated by `Φ`.
> - `isSat_iff_sortedEqvLe_charEqv`: for any `Φ` and `L`, `Φ` saturates `L` iff
>   `Φ ≤ charEqv L`.
> - `charEqv L`: the characteristic sorted equivalence of the language `L`.
>
> ### Translations, congruence
> - `IsElemTranslation Sig A t s T`: `T` is an elementary translation.
> - `closesUnderEtl_of_closesUnderTl`: Tl-closure implies Etl-closure.
> - `closesUnderEtl_of_isCongruence`: a congruence is Etl-closed.
> - `closesUnderTl_of_closesUnderEtl`: Etl-closure implies Tl-closure.
> - `isCongruence_iff_closesUnderEtl`: `Φ` is a congruence iff it is Etl-closed.
> - `IsCongruence_inf`: the meet of two congruences on the same algebra is a
>   congruence.
>
> ### Finite index
> - `IsFiniteIndex Φ`: `Φ` has finitely many classes.
> - `IsFiniteIndexCongruenceFormation Sig G`: `G` is a finite-index congruence
>   formation (members are finite-index congruences; closure properties as above).
>
> ### Cogenerated congruence / saturation duality
> - `congCogenerated Sig A L`: the congruence cogenerated by a language `L`.
> - `congCogenerated_isCongruence`: it is a congruence.
> - `congCogenerated_le_charEqv`: `congCogenerated Sig A L ≤ charEqv L`.
> - `isSat_iff_le_congCogenerated`: for a congruence `Φ`, `Φ` saturates `L` iff
>   `Φ ≤ congCogenerated Sig A L`.
> - `le_congCogenerated_of_isCongruence`: if `Φ` is a congruence and
>   `Φ ≤ charEqv L`, then `Φ ≤ congCogenerated Sig A L`.
>
> ### Languages, congruence formations, the two translations
> - `langFormationOf Sig G`: turns a congruence formation `G` into the language
>   formation `A ↦ { L : ∃ Φ ∈ G A, Φ saturates L }`.
> - `langFormationOf_inf`: if `G` is a congruence formation, `L, L' ∈
>   langFormationOf Sig G A`, then any `N` saturated by the meet of
>   `congCogenerated (termAlg A) L` and `congCogenerated (termAlg A) L'` also lies
>   in `langFormationOf Sig G A`.
> - `langFormationOf_ker`: if `G` is a congruence formation, `M ∈ langFormationOf
>   Sig G B`, and `f : Term A → Term B` is an algebra homomorphism whose composite
>   with the projection onto the quotient by `congCogenerated M` is surjective in
>   every sort, then any `N` saturated by the kernel of that composite lies in
>   `langFormationOf Sig G A`.
> - `langFormationOf_nabla`: if `G` is a congruence formation, then every `L`
>   saturated by `nabla (Term Sig A)` belongs to `langFormationOf Sig G A`.
>
> ### Quotients
> - `quot Φ`: the quotient sorted set by `Φ`.
> - `quotAlg Sig F Φ hΦ`: the quotient algebra (given a congruence `hΦ`).
> - `quotOp Sig F Φ p σ`: the operation induced on the quotient by operation
>   symbol `σ` of arity `p`.
> - `quotOp_mk`: on representatives, `quotOp ... (fun i => mk (a i)) = mk (F p σ
>   a)`.
> - `pr Φ s`: projection `A s → Quotient (Φ s)`.
> - `prAlg Sig F Φ hΦ`: projection homomorphism `A → quotAlg`.
> - `isAlgHom_prAlg`: this projection is an algebra homomorphism.
> - `nabla A`: universal (coarsest) sorted equivalence on `A`.
> - `nabla_isCongruence`: `nabla A` is a congruence.
>
> ### Kernels
> - `ker f`: kernel sorted equivalence of `f`.
> - `ker_isCongruence`: the kernel of an algebra homomorphism is a congruence.
>
> ### Auxiliary
> - `IsElemTranslation`, `finOp A w s`: operations with input word `w` and output
>   sort `s`; `wordProd A w`: product over a word of sorts.
> - `regularLanguages Sig A`: set of regular languages of an algebra `A`.
> - `termAlg Sig X`: the term algebra over `X`.
>
> ## Note on scope
>
> This file declares a subset of the full interface: notably it omits the
> order-isomorphism `formCgrFiFormLangRIso` and the `langCongFormationOf`
> construction/its properties, keeping only the `langFormationOf` direction. The
> only theorem whose proof is supplied here is
> `langFormationOf_isRegularLanguageFormation`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P037 verdict
>
> Contract (`Cong2LangEnFinit`): Let `𝔉` be a formation of finite index
> congruences with respect to `Σ`. Then the function `L_𝔉` (defined as in
> Proposition `Cong2LangBasic`) is a formation of regular languages with respect
> to `Σ`.
>
> Read-back: `langFormationOf_isRegularLanguageFormation` — if `G` is a
> finite-index congruence formation, then `langFormationOf Sig G` is a
> regular-language formation.
>
> ## Clause-by-clause
>
> 1. **Hypothesis on `𝔉`.** Contract: `𝔉` is a formation of finite index
>    congruences w.r.t. `Σ`. Read-back: `G` is an
>    `IsFiniteIndexCongruenceFormation Sig`. Match.
> 2. **The function.** Contract: `L_𝔉` as defined in `Cong2LangBasic`, i.e.
>    `L_𝔉(A) = { L ∈ Sub(T_Σ(A)) | ∃ Φ ∈ 𝔉(A), L = [L]^Φ }`
>    (equivalently `Φ` saturates `L`). Read-back: `langFormationOf Sig G` with
>    `L ∈ langFormationOf Sig G A ↔ ∃ Φ ∈ G A, IsSat Φ L`, i.e.
>    `A ↦ { L : ∃ Φ ∈ G A, Φ saturates L }`. Match.
> 3. **Conclusion.** Contract: `L_𝔉` is a formation of regular languages w.r.t.
>    `Σ`. Read-back: `langFormationOf Sig G` is an
>    `IsRegularLanguageFormation Sig`. Match.
> 4. **Hypotheses.** Neither text adds a sort-finiteness or other side condition;
>    the read-back's proof body uses exactly the four closure fields of a
>    regular-language formation. Match.
>
> (The read-back notes it omits the order-isomorphism `formCgrFiFormLangRIso` and
> the `langCongFormationOf` direction; those are separate contracts, not clauses
> of this one.)
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the hypothesis, the explicit definition of `L_𝔉`, and the
> regular-language-formation conclusion all correspond exactly.

