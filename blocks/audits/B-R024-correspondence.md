# Correspondence audit transcript -- `B-R024`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declaration:** `Mslang.finite_supp_term_iff` (`lean/Mslang/Regular.lean`).
- **Contract:** Remark `B-R024`: the conditions "(1) for every `A ∈ 𝒰^S`,
  `supp_S(T_Σ(A))` is finite" and "(2) `S` is finite" are equivalent.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> For any sort set `S` and any signature `Sig` over `S`, the following are
> equivalent: (1) for every `S`-sorted set `A` of variables, the term algebra
> `Term Sig A` is supported on only finitely many sorts, i.e.
> `supp(Term Sig A) = {s ∈ S : there exists a term of sort s over A}` is finite;
> (2) `S` is finite.
>
> Here an `S`-sorted set is a family of sets indexed by `S`; a signature assigns
> to each pair (list of sorts, sort) a set of operation symbols; `Term Sig A` is
> the inductive algebra of finite terms with leaves in `A` and internal nodes
> operation symbols respecting sorts; `supp(A) = {s : A_s ≠ ∅}`; and
> `finalSorted S` is the sorted set with a single element at every sort.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The read-back states exactly the same TFAE as the contract: (1) for every
> sorted variable set `A` the term algebra has finite support, and (2) `S` is
> finite. The direction is bidirectional in both, the quantifier over `A` is
> universal in both, and "support" is defined as the set of sorts carrying at
> least one element/term, matching `supp_S`. The contract uses the terminal
> sorted set `A = 1` merely as a witness in the proof of `(1) ⇒ (2)`; the Lean
> statement needs no separate mention of it because it is an instance of the
> universally quantified `A`, so omitting it is a packaging difference, not a
> loss or gain of content.

## Residual note

The formalization of `B-R024` is faithful. The proof's forward direction uses the
terminal sorted set `A = 1` (`finalSorted S`): its free algebra is inhabited at
every sort (`Term.var PUnit.unit`), so `supp(T_Σ(1)) = univ`, and `univ` finite
gives `S` finite. The contract's explicit witness is thereby reproduced. The
record inherits the pilot-encoding residuals (`carrier-model`, `small-large`,
`univalence-missing`), none of which touches this statement.
