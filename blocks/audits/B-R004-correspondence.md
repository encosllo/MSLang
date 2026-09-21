# Correspondence audit transcript -- `B-R004`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.isUniform_of_subsingleton_sorts`
  (`lean/Mslang/Algebra.lean`)
- **Contract:** Remark `B-R004`, section "Preliminaries".
- **Outcome:** `formal_stronger` (the Lean statement is the contract's claim for
  the single-sorted case, plus the degenerate empty-sort case)
- **Recorded as:** `E-000384`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> The theorem concerns a type `S` of sorts and an `S`-indexed family of types
> `A`, with subfamilies `X : ∀ s, Set (A s)`. The hypothesis `[Subsingleton S]`
> says that `S` has at most one element. Given a closure operator `c` on
> subfamilies (extensive, monotone, idempotent), the conclusion `IsUniform c`
> states that whenever two subfamilies `X` and `Y` have the same support
> `{s | (X s).Nonempty}`, their images `c X` and `c Y` have the same support. So
> on a single-sort (or empty-sort) index type, any closure operator depends only
> on where its input is nonempty, not on the particular elements chosen.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `formal_stronger`.**
>
> The contract is confined to single-sorted index types (a one-element set of
> sorts), whereas the Lean statement hypothesizes only `[Subsingleton S]`, which
> also admits the empty sort type. The formal statement therefore covers
> strictly more index types under a strictly weaker hypothesis: it implies the
> contract and not conversely. In both, the quantified `c` is a closure operator
> -- extensivity, monotonicity and idempotence are exactly the paper's
> definition of "operator" -- and the conclusion `IsUniform c` is precisely the
> contract's uniformity. The only divergence is the degenerate empty-sort case,
> where uniformity holds vacuously. This is a harmless strict generalization
> (the same shape as the recorded `B-P005`/`B-P026` empty-index
> generalizations), not an added hypothesis or a weakened conclusion.

## Residual note

The block inherits the pilot-encoding residuals (`carrier-model`, `small-large`,
`univalence-missing`). The Lean statement is positive under the encoding; if the
correspondence were required to be exactly `equivalent`, the hypothesis could be
tightened to `[Unique S]`.
