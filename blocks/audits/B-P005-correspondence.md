# Correspondence audit transcript -- `B-P005`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.IsClosureOperator`, `Mslang.IsCompletelyAdditive`, `Mslang.IsAlgebraic`, `Mslang.sat_extensive`, `Mslang.sat_monotone`, `Mslang.sat_idem`, `Mslang.sat_isClosureOperator`, `Mslang.sat_iUnion`, `Mslang.sat_isCompletelyAdditive`, `Mslang.sat_isAlgebraic`, `Mslang.sat_iInter_subset`, `Mslang.sat_univ`, `Mslang.sat_compl`, `Mslang.suppSub_sat`, `Mslang.sat_uniform`, `Mslang.satSets_fix` (`lean/Mslang/Prelim.lean`)
- **Contract:** Proposition `B-P005`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000298` (supersedes `E-000092`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-P005.lean`
>
> ## Setting
>
> Fix a type of sorts `S`. An `SSet S` (a *sorted set*) is a family `A = (A s)_{s : S}` of types indexed by
> `s`. A *subobject* `X : Sub A` is a family of subsets `X s ⊆ A s`, one per sort. A *sorted equivalence*
> `Φ : SortedEqv A` is a family of equivalence relations (setoids) `Φ s` on each `A s`. Inclusion of
> subobjects `Subset X Y` means `X s ⊆ Y s` for every sort `s`.
>
> The central operator is `sat Φ`, the *saturation* of a subobject `X` under `Φ`: sortwise it adjoins to
> `X s` every element of `A s` that is `Φ s`-equivalent to some element of `X s`.
>
> ## Definitions
>
> - **`IsClosureOperator c`** (for `c : Sub A → Sub A`): the conjunction of
>   1. *extensiveness*: `X ⊆ c X` for every `X` (i.e. `X s ⊆ c X s` for all `s`);
>   2. *monotonicity*: for all `X, Y`, `X ⊆ Y` implies `c X ⊆ c Y`;
>   3. *idempotence*: `c (c X) = c X` for every `X`.
>   (Here `=` between subobjects is sortwise set equality / function extensionality.)
>
> - **`IsCompletelyAdditive c`**: for every index type `ι` (in the same universe as `S`) and every family
>   `X : ι → Sub A`, the operator commutes with arbitrary unions:
>   `c (⋃_i X_i) = ⋃_i c (X_i)`, with the union formed sortwise (`(⋃_i X_i) s = ⋃_i X_i s`). So `c`
>   preserves all (small) joins.
>
> - **`IsAlgebraic c`**: for every `X`, every sort `s`, and every `a : A s` with `a ∈ (c X) s`, there exists
>   a subobject `F : Sub A` such that
>   - `F ⊆ X` (sortwise),
>   - `F t` is finite for *every* sort `t`, and
>   - `a ∈ (c F) s`.
>   So every membership in a closure is witnessed by a subobject all of whose fibers are finite.
>
> ## Theorems
>
> - **`sat_extensive`**: for every `Φ` and `X`, `X ⊆ sat Φ X`. (Each `x ∈ X s` is in `sat Φ X s` via
>   reflexivity of `Φ s`.)
>
> - **`sat_monotone`**: for every `Φ`, if `X ⊆ Y` then `sat Φ X ⊆ sat Φ Y`.
>
> - **`sat_idem`**: for every `Φ` and `X`, `sat Φ (sat Φ X) = sat Φ X` (sortwise set equality). The proof
>   uses transitivity of `Φ s` for the nontrivial inclusion and reflexivity for the reverse.
>
> - **`sat_isClosureOperator`**: `sat Φ` satisfies `IsClosureOperator`, i.e. `sat Φ` is extensive,
>   monotone, and idempotent.
>
> - **`sat_iUnion`**: for every `Φ`, index type `ι`, and family `X : ι → Sub A`,
>   `sat Φ (⋃_i X_i) = ⋃_i sat Φ (X_i)` sortwise. Hence `sat Φ` commutes with arbitrary unions.
>
> - **`sat_isCompletelyAdditive`**: `sat Φ` is completely additive (immediate from `sat_iUnion`).
>
> - **`sat_isAlgebraic`**: `sat Φ` is algebraic. Explicitly: given `X`, sort `s`, and
>   `a ∈ sat Φ X s` (so `a` is `Φ s`-equivalent to some `x ∈ X s`), one may take `F` concentrated at `s`
>   with `F s = {x}` and `F t = ∅` for `t ≠ s`; then `F ⊆ X`, every `F t` is finite, and
>   `a ∈ sat Φ F s`.
>
> - **`sat_iInter_subset`**: for every `Φ`, `ι`, and family `X : ι → Sub A`,
>   `sat Φ (⋂_i X_i) ⊆ ⋂_i sat Φ (X_i)` (sortwise). This is only one inclusion: `sat Φ` need not preserve
>   intersections.
>
> - **`sat_univ`**: `sat Φ (fun _ => univ) = fun _ => univ`, i.e. saturation of the top subobject (all of
>   `A s` at each sort) is again the top subobject.
>
> - **`sat_compl`**: for every `Φ` and subobject `X`, if `X` is `Φ`-saturated (`IsSat Φ X`, meaning
>   `sat Φ X = X`), then its complement `complA X` (sortwise complement) is also `Φ`-saturated. Uses
>   symmetry of `Φ`.
>
> - **`suppSub_sat`**: `suppSub (sat Φ X) = suppSub X`. Here `suppSub` is the support, i.e. the set of
>   sorts at which the subobject is nonempty. Saturation does not change the nonemptiness pattern, because
>   it only adds equivalent elements and does not remove any.
>
> - **`sat_uniform`**: if `suppSub X = suppSub Y` then `suppSub (sat Φ X) = suppSub (sat Φ Y)`.
>
> - **`satSets_fix`**: `satSets Φ = {X : Sub A | sat Φ X = X}`, by definition (`rfl`): the family
>   `satSets Φ` is definitionally the set of fixed points of `sat Φ`.
>
> ## Declarations stated without bodies in this file
>
> `SSet`, `SortedEqv`, `Sub`, `Subset`, `complA`, `sat`, `satSets`, `IsSat` are introduced here only as
> (opaque/abbreviated) declarations; their content is as described above and is used by the theorems.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P005 verdict
>
> Contract: Proposition `SatOperator`. Lean read-back: `sat`, closure/additivity/algebraicity of `sat Φ`.
>
> ## Clause-by-clause
>
> 1. **Setting** — `A` an `S`-sorted set, `Φ ∈ Eqv(A)`, `[·]^Φ : Sub(A) → Sub(A)`. Lean: `SSet S`, `SortedEqv A`, `Sub A`, `sat Φ : Sub A → Sub A`. Match.
> 2. **`[·]^Φ` is a closure operator.** Lean `IsClosureOperator` = extensive + monotone + idempotent; proved by `sat_extensive`, `sat_monotone`, `sat_idem`, packaged as `sat_isClosureOperator`. Match (exact clause list).
> 3. **`[·]^Φ` is completely additive.** Lean `IsCompletelyAdditive`: `sat Φ (⋃ᵢ Xᵢ) = ⋃ᵢ sat Φ (Xᵢ)` for every index type; proved by `sat_iUnion`, packaged as `sat_isCompletelyAdditive`. Match.
> 4. **`[⋂_{i∈I} Xⁱ]^Φ ⊆ ⋂_{i∈I} [Xⁱ]^Φ` for nonempty `I`.** Lean `sat_iInter_subset`, same one-inclusion statement. The Lean version quantifies over *every* `ι`, not only nonempty ones; the extra empty-family case reduces to `sat Φ A ⊆ A`, which is trivially true (`sat_univ`). This is a vacuous generalization only. Match.
> 5. **`[A]^Φ = A`.** Lean `sat_univ`. Match.
> 6. **Saturated ⟹ complement saturated.** Lean `sat_compl` (using symmetry of `Φ`); saturation is `IsSat Φ X` = `sat Φ X = X`. Match.
> 7. **Uniformity:** `supp_S(X) = supp_S(Y) ⟹ supp_S([X]^Φ) = supp_S([Y]^Φ).` Lean `sat_uniform`; furthermore `suppSub_sat` gives the stronger identity `suppSub (sat Φ X) = suppSub X`, which immediately implies uniformity. Match (Lean sub-clause is slightly stronger but contains the contract's statement).
> 8. **Algebraic closure operator** ("hence ... uniform algebraic closure operator"). Lean `IsAlgebraic` and `sat_isAlgebraic` (finite witness subobject), together with 2 and 7. Match.
> 9. **`Φ-Sat(A) = Fix([·]^Φ)`.** Lean `satSets Φ = {X | sat Φ X = X}` by definition (`satSets_fix` is `rfl`). Match.
>
> ## Contract clauses with no Lean counterpart:
>
> none
>
> Verdict: equivalent
> The Lean read-back states exactly the closure-operator, complete-additivity, intersection-inclusion, top, complement, uniformity, algebraicity and `Fix` clauses; the only textual difference is that the intersection clause drops `I` nonempty, and the omitted case is vacuous.

