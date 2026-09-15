# Correspondence audit transcript -- `B-R008`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.nabla_sat_empty`, `Mslang.nabla_sat_univ`,
  `Mslang.nabla_sat_deltaUnion` (`lean/Mslang/Pilot.lean`)
- **Contract:** Remark `B-R008`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000047`
- **Encoding:** dependent-type carrier model (`representation/pilot-encoding.md`);
  re-run after the Session 29 representation change.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `S` is a type of sorts and `A : S → Type u` an `S`-sorted carrier. `Sub A` is
> the per-sort subset family. `sat Φ X s = {a | ∃ x ∈ X s, (Φ s).r x a}`;
> `IsSat Φ X` asserts `sat Φ X = X`. `nabla A` is the universal sorted
> equivalence (every pair related at every sort). `deltaUnion T A` is the family
> whose fiber at `s` is all of `A s` when `s ∈ T` and empty otherwise; it is
> noncomputable.
>
> Consequence 1 (`nabla_sat_empty`): the empty-at-every-sort family `fun s => ∅`
> is saturated under `nabla A`. Consequence 2 (`nabla_sat_univ`): the
> full-at-every-sort family `fun s => Set.univ` is saturated under `nabla A`.
> Consequence 3 (`nabla_sat_deltaUnion`): for every `T : Set S`, `deltaUnion T A`
> is saturated under `nabla A`. `nabla A` is the maximally coarse equivalence, so
> a family is `nabla A`-saturated exactly when each fiber is either empty or
> full. `deltaUnion T A` selects whole sorts and interpolates between the empty
> family (`T = ∅`) and the full family (`T = S`). Degenerate cases: empty `S`
> vacuous; `T = ∅` specializes Consequence 3 to Consequence 1; `T = S`
> specializes it to Consequence 2.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> The read-back preserves the contract's structure and asserted consequences.
> `∇^A` is correctly rendered as the universal sorted equivalence, and
> `∇^A−Sat(A)` as the family of `nabla A`-saturated subsets. Under this maximal
> equivalence a fiber is saturated exactly when it is empty or full, which is
> precisely the content of Consequences 1--2 (empty family, full family
> `fun s => Set.univ` = `A`) and of Consequence 3.
>
> The role of `δ^{t,A_t}` is faithfully captured: `deltaUnion T A` is `A s` at
> sorts `s ∈ T` and `∅` otherwise, matching the componentwise union
> `⋃_{t∈T} δ^{t,A_t}`. Since each such fiber is either empty or full, saturation
> holds for every `T`, and the specializations (`T = ∅` -> Consequence 1,
> `T = S` -> Consequence 2, empty `S` vacuous) are stated. Noncomputability of
> `deltaUnion` is a representation detail that does not weaken or strengthen the
> mathematical claim. No extra or missing assertions.

## Residual note

Inherits the pilot encoding's residuals (see `E-000040`); a representation change
(class C6) stales this verdict.
