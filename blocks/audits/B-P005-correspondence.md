# Correspondence audit transcript -- `B-P005` (`SatOperator`)

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsClosureOperator`, `Mslang.IsCompletelyAdditive`,
  `Mslang.IsAlgebraic`, and the `sat_*` operator lemmas
  (`sat_extensive`, `sat_monotone`, `sat_idem`, `sat_isClosureOperator`,
  `sat_iUnion`, `sat_isCompletelyAdditive`, `sat_isAlgebraic`,
  `sat_iInter_subset`, `sat_univ`, `sat_compl`, `suppSub_sat`, `sat_uniform`,
  `satSets_fix`) in `lean/Mslang/Pilot.lean`.
- **Contract:** Proposition `B-P005` (`SatOperator`), section "Preliminaries".
- **Outcome:** `formal_stronger` (only divergence: the formal intersection
  inclusion holds for **every** index type, dropping the contract's "nonempty
  `I`"; everything else matches).
- **Recorded as:** `E-000054`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Fix a type `S` of sorts. An `S`-sorted set `A` is a family `(A_s)_{s∈S}` of
> types. `X : Sub A` is a family `X_s ⊆ A_s`; `Subset` is pointwise inclusion.
> `Φ : SortedEqv A` is a family of equivalence relations; the `Φ`-saturation is
> `(sat Φ X)_s = { a ∈ A_s | ∃ x ∈ X_s, Φ_s(x,a) }`; `IsSat Φ X := sat Φ X = X`.
> `satSets Φ = {X | IsSat Φ X}`; `complA X` is the componentwise complement in
> `A`; `suppSub X = {s | X_s ≠ ∅}`.
>
> **Definitions.** `IsClosureOperator c` iff `c` is extensive (`X ⊆ c X`),
> monotone (`X ⊆ Y → c X ⊆ c Y`), and idempotent (`c (c X) = c X`).
> `IsCompletelyAdditive c` iff for every index type `ι` and family `(X_i)`,
> `c (⋃_i X_i) = ⋃_i c(X_i)` (componentwise). `IsAlgebraic c` iff for every `X`,
> sort `s`, and `a ∈ (c X)_s`, there is `F ⊆ X` with every `F_t` finite and
> `a ∈ (c F)_s`.
>
> **Theorems.** `sat_extensive` (`X ⊆ sat Φ X`), `sat_monotone`,
> `sat_idem`; `sat_isClosureOperator`: `sat Φ` is a closure operator;
> `sat_iUnion`: `sat Φ (⋃_i X_i) = ⋃_i sat Φ (X_i)` for every `ι`;
> `sat_isCompletelyAdditive`; `sat_isAlgebraic` (componentwise-finite witness);
> `sat_iInter_subset`: `sat Φ (⋂_i X_i) ⊆ ⋂_i sat Φ (X_i)` for every `ι`;
> `sat_univ`: `sat Φ (full) = full`; `sat_compl`: `IsSat Φ X → IsSat Φ (complA X)`;
> `suppSub_sat`: `suppSub (sat Φ X) = suppSub X`; `sat_uniform`; and
> `satSets_fix`: `satSets Φ = {X | sat Φ X = X}`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: formal_stronger.**
>
> - **Closure-operator properties**: `sat_extensive`, `sat_monotone`,
>   `sat_idem` = extensive/monotone/idempotent -- matches.
> - **Complete additivity**: `sat_iUnion` for every index type = arbitrary-union
>   preservation -- matches.
> - **Intersection inclusion**: the contract requires
>   `[⋂ X^i]^Φ ⊆ ⋂[X^i]^Φ` only for **nonempty** `I`. The read-back proves
>   `sat_iInter_subset` for **every** index type, explicitly "including the empty
>   one", thereby dropping the "nonempty `I`" hypothesis and asserting the
>   inclusion in strictly more cases. This is the one non-notational divergence
>   (the empty case collapses to `sat(A) ⊆ A`, which the contract does not state
>   in this clause).
> - **[A]^Φ = A**: `sat_univ` -- matches.
> - **Complement clause**: `sat_compl` (`IsSat Φ X → IsSat Φ (complA X)`), with
>   `IsSat` the fixed-point predicate, exactly the contract's `X = [X]^Φ ⇒
>   ∁X = [∁X]^Φ` -- matches.
> - **Uniformity**: `sat_uniform` and `suppSub_sat` over `suppSub X = {s | X_s ≠ ∅}`
>   -- matches.
> - **Algebraic claim**: `sat_isAlgebraic` with componentwise-finite witness `F`
>   -- matches.
> - **Fix identity**: `satSets_fix` -- matches.
>
> All substantive clauses align except the generalized meet-inclusion, so the
> formalization proves more than the contract.

## Residual note

The correspondence is `formal_stronger` (a positive outcome: the formal result
is stronger than the contract) relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
