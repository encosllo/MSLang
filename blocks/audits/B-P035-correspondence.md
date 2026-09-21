# Correspondence audit transcript -- `B-P035`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.isBPSLanguageFormation_of_isRegularLanguageFormation`, `Mslang.isRegularLanguageFormation_of_isBPSLanguageFormation` (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P035`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000320` (supersedes `E-000214`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is therefore faithful, not a
> weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-P035 — read-back (informal mathematics)
>
> ## Ambient setting
>
> `S` is a type of **sorts**; `SSet S` is a sorted set (a family of types over
> sorts); `Sub A` is a sorted family of subsets; `Signature S` is a many-sorted
> signature with operation symbols indexed by `p = (w, s)` (`w : List S` input
> word, `s` result sort); `Term Sig X` is the many-sorted term algebra over
> variables `X`; `termAlg Sig X` packages it as an algebra; `SortedEqv A` is a
> sorted equivalence relation; `SortedMap A B` is a sort-preserving function;
> `Alg Sig` is the class of algebras.
>
> Basic notions:
>
> * `sortedEqvLe Φ Ψ`: refinement (Φ is a sub-relation of Ψ); `sortedEqvInf Φ Ψ`:
>   meet (intersection); `sortedEqvInf_self` (`:217`): `Φ ∧ Φ = Φ`;
>   `sortedEqvLe_antisymm` (`:222`): mutual refinement implies equality.
> * `charEqv L` (`:132`): characteristic equivalence of a subset `L` (membership
>   agrees). `IsSat Φ X` (`:104`): `X` is a union of `Φ`-classes (Φ-compatible);
>   equivalently `Φ ≤ charEqv X` (`isSat_iff_sortedEqvLe_charEqv`, `:176`).
> * `congCogenerated Sig A L` (`:148`): the syntactic congruence of `L`, the
>   greatest congruence refining `charEqv L`; it is a congruence
>   (`congCogenerated_isCongruence`, `:151`), refines `charEqv L`
>   (`congCogenerated_le_charEqv`, `:154`), and is greatest
>   (`le_congCogenerated_of_isCongruence`, `:181`); for a congruence `Φ`,
>   `IsSat Φ L ↔ Φ ≤ congCogenerated … L` (`isSat_iff_le_congCogenerated`, `:172`).
> * `sat` (`:210`): saturation of a subset by a relation; `sat_idem` (`:212`):
>   `sat Φ (sat Φ X) = sat Φ X`.
> * `IsCongruence` / `IsCongruence_inf` are as usual; `ClosesUnderEtl` (`:79`) and
>   `ClosesUnderTl` (`:81`) express compatibility of a sorted equivalence with
>   elementary translations / with all translations; `IsElemTranslation` (`:94`)
>   and the inductive `TlGen` (`:121`, identities, elementary translations,
>   composites) generate translations. The interface also states:
>   `closesUnderEtl_of_closesUnderTl` (`:134`),
>   `closesUnderEtl_of_isCongruence` (`:138`),
>   `closesUnderTl_of_closesUnderEtl` (`:142`),
>   `isCongruence_iff_closesUnderEtl` (`:168`): a sorted equivalence is a
>   congruence iff it is closed under elementary translations.
> * `ker f` (`:179`): kernel of `f`; `pr Φ`, `prAlg`, `quot`, `quotAlg`,
>   `quotOp`: quotient and projection machinery.
> * `regularLanguages Sig A` (`:208`): the set of regular languages on the algebra
>   `A`; `IsRegularLanguage Sig A L` (`:99`): `L` is regular, i.e. compatible with
>   a finite-index congruence. `IsFiniteIndex` (`:97`) is as before.
> * `transPreimage T L` (`:227`): the preimage of `L` under a translation
>   `T : A t → A s`; `inverseImage f Y` (`:166`): the preimage of `Y` under a
>   sorted map `f`; `complA X` (`:146`): complement of a subset; `deltaSub s Y`
>   (`:161`): a subset concentrated on a single sort; `pullbackEqv f Ψ` (`:195`):
>   the equivalence on the source pulled back from `Ψ` along `f`.
>
> ## Language formations
>
> A **language formation** `L` assigns to each variable set `A` a set
> `L A ⊆ Sub (Term Sig A)` of languages on the term algebra over `A`. Two
> predicates on `L` occur in this file. Each is a nested conjunction; both share
> the same first two components (denoted `.1` and `.2.1`), whose content is not
> spelled out in this file but which the file transfers unchanged in both
> directions.
>
> * `IsBPSLanguageFormation Sig L` (`:88`) has (after the two shared components)
>   the following three requirements:
>   1. **Translation-preimage closure**: for every `A`, translation `T`, and
>      language `X ∈ L A`, the preimage of `X` under `T` (`transPreimage`) is again
>      in `L A`.
>   2. **Boolean closure**: for every `A` and `X, Y ∈ L A`, the union, the
>      intersection, and the complement (within `Term Sig A`) of these languages
>      are again in `L A`.
>   3. **Inverse-image closure**: for all `A, B`, every `M ∈ L B`, every algebra
>      homomorphism `f : Term Sig A → Term Sig B` that is surjective onto the
>      quotient of `Term Sig B` by the syntactic congruence of `M`, and every
>      `N : Sub (Term Sig A)` compatible with the kernel of `prAlg ∘ f`, the
>      inverse image of `N` lies in `L A`.
>
> * `IsRegularLanguageFormation Sig L` (`:101`) has (after the two shared
>   components) the following two requirements:
>   1. **Saturation/meet closure**: for every `A` and `X, Y ∈ L A`, and every
>      `N : Sub (Term Sig A)` with `IsSat (sortedEqvInf (congCogenerated … X)
>      (congCogenerated … Y)) N`, one has `N ∈ L A`.
>   2. **Inverse-image closure** as in the BPS condition 3 above.
>
> ## Theorems
>
> 1. `isBPSLanguageFormation_of_isRegularLanguageFormation` (`:1`).
>    Hypothesis: `hL : IsRegularLanguageFormation Sig L`.
>    Conclusion: `IsBPSLanguageFormation Sig L`.
>    Construction: the two shared components are carried over; translation
>    preimage closure is obtained from `regularFormation_transPreimage`; the
>    Boolean closure is obtained from `regularFormation_union`,
>    `regularFormation_inter`, `regularFormation_compl`; the inverse-image closure
>    from `regularFormation_inverseImage`. (These helper lemmas are not declared
>    in this file but state that a regular language formation has the
>    corresponding closure property.)
>
> 2. `isRegularLanguageFormation_of_isBPSLanguageFormation` (`:14`).
>    Hypothesis: `hL : IsBPSLanguageFormation Sig L`.
>    Conclusion: `IsRegularLanguageFormation Sig L`.
>    Construction:
>    * The two shared components are carried over.
>    * The saturation/meet closure is obtained directly from
>      `bps_sat_inf_mem` (`:21`): for `X, Y ∈ L A` and `N` compatible with the meet
>      of the two syntactic congruences, `N ∈ L A`.
>    * Inverse-image closure (lines 22–75). Given `A`, `B`, `M ∈ L B`, an algebra
>      homomorphism `f : Term Sig A → Term Sig B` that is surjective onto the
>      quotient by the syntactic congruence `ΩM := congCogenerated … M`, and `N`
>      compatible with `ker (prAlg_{ΩM} ∘ f)`, one shows `N ∈ L A` as follows:
>      - Set `N' := sat ΩM (f '' N)`, the `ΩM`-saturation of the image of `N`; it
>        is `ΩM`-compatible (`hN'sat`).
>      - `N' ∈ L B`, using the BPS saturation/meet closure at `M, M` (with
>        `sortedEqvInf_self` to identify `ΩM ∧ ΩM` with `ΩM`).
>      - Identify the kernel: `ker (prAlg_{ΩM} ∘ f) = pullbackEqv f ΩM`.
>      - Use compatibility of `N` with this kernel (and the congruence property)
>        to conclude `inverseImage f N' = N`.
>      - Show `f` is surjective onto the quotient by `congCogenerated … N'`,
>        using `ΩM ≤ congCogenerated … N'` (which follows from `IsSat ΩM N'`).
>      - Apply the BPS inverse-image closure to `N' ∈ L B` to get
>        `inverseImage f N' ∈ L A`, then rewrite using `inverseImage f N' = N`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P035 verdict
>
> ## Clause-by-clause
>
> **Clause: Definitions `Def1FRL` and `Def2FRL` are equivalent.**
> Lean provides the two predicates `IsRegularLanguageFormation Sig L` and
> `IsBPSLanguageFormation Sig L` (the two definitions of a language formation)
> and proves both directions:
> - `isBPSLanguageFormation_of_isRegularLanguageFormation`:
>   `IsRegularLanguageFormation Sig L → IsBPSLanguageFormation Sig L`, carrying
>   the two shared components and deriving translation-preimage closure,
>   Boolean closure, and inverse-image closure from the corresponding regular
>   helper lemmas.
> - `isRegularLanguageFormation_of_isBPSLanguageFormation`:
>   `IsBPSLanguageFormation Sig L → IsRegularLanguageFormation Sig L`, carrying
>   the shared components, deriving saturation/meet closure from
>   `bps_sat_inf_mem`, and deriving inverse-image closure via the
>   `N' := sat ΩM (f '' N)` argument.
>
> Together these are the bidirectional equivalence of the two definitions. Match.
>
> Contract clauses with no Lean counterpart: none.
>
> Verdict: equivalent — the two directions between the regular and BPS language
> formation predicates formalize exactly the asserted equivalence of the two
> definitions.

