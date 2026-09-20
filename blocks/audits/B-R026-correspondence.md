# Correspondence audit transcript -- `B-R026`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declaration:** `Mslang.exists_regular_infinite_language`
  (`lean/Mslang/Regular.lean`).
- **Contract:** Remark `B-R026`: an algebra of finite support can have a regular
  language that is not finite.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `supp_S(A) = {s : A_s nonempty}`. `congCogenerated Sig A L` identifies two
> elements of a sort iff every term-translation maps them into `L` together or
> outside `L` together (the Myhill-Nerode syntactic congruence `Ω^A(L)`).
> `IsRegularLanguage Sig A L` holds iff `Ω^A(L)` has finite index.
> `FiniteSub L` holds iff the total disjoint-union carrier of `L` is finite, so
> `¬ FiniteSub L` says `L` is infinite. The declaration asserts the existence of
> `S, Σ, A, L` with `supp_S(A)` finite, `L` regular, and `L` infinite.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The contract is an existence claim ("`L` can be regular and not finite"), so a
> single witness establishes it; the read-back's existential over `S, Σ, A, L`
> with finite support, regularity, and infinitude is exactly that witness
> package. "Regular" corresponds to finite index of `Ω^A(L)` (Myhill-Nerode) and
> "not finite" to `¬ FiniteSub L`. No extra or weakened condition appears.

## Witness

One sort (`PUnit`), the empty signature, carrier `ℕ`, and `L = A` (the whole
carrier). `supp(A)` is the single sort (finite); `Ω^A(A) = ∇^A` is the universal
congruence, which has finite index because `supp(A)` is finite
(`isFiniteIndex_nabla`), so `L` is regular; and `L = A` is infinite. The record
inherits the pilot-encoding residuals (`carrier-model`, `small-large`,
`univalence-missing`).
