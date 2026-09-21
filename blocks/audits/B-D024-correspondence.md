# Correspondence audit transcript -- `B-D024`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsCongruence` (`lean/Mslang/Congruence.lean`)
- **Contract:** Definition `B-D024`, section "Σ-algebra formations".
- **Outcome:** `formal_weaker` (the defining compatibility clause is faithful,
  and in fact generalized; the `Cgr(A)` closure-system/lattice claims and the
  greatest/least congruence elements are not formalized)
- **Recorded as:** `E-000278`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `IsCongruence Sig F Φ` (def, `Prop`): the sorted equivalence `Φ` on the carrier
> `A` is compatible with the algebra structure `F` for signature `Sig`. It
> quantifies over every arity/coarity pair `p = (w, s)` (`w : List S`), every
> operation symbol `σ : Sig p`, and every two tuples `a b : wordProd A w`.
> Hypothesis: `∀ i, (Φ (w.get i)).r (a i) (b i)`. Conclusion:
> `(Φ s).r (F p σ a) (F p σ b)`. The arity `w` is an arbitrary finite list of
> sorts (the empty list included). No declaration asserts that the set of
> congruences `Cgr(A)` is a closure system or lattice, nor states greatest/least
> congruence elements.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `formal_weaker` (net; mixed).**
>
> The defining compatibility clause is *stronger* in Lean: `IsCongruence`
> quantifies over all `w : List S`, including the empty arity, whereas the
> contract restricts to `S* − {λ}`, so Lean drops the nonempty-arity hypothesis
> (`formal_stronger` for that clause). However, the contract then asserts a
> bundle of structural results about `Cgr(A)` — closure system, algebraic
> lattice, greatest element `∇^A`, least element `Δ^A` — for which the read-back
> reports no Lean counterpart.
>
> **Contract clauses with no Lean counterpart:**
> - `Cgr(A)` is an algebraic closure system on `A×A`.
> - `Cgr(A)` is the algebraic lattice `(Cgr(A), ⊆)`.
> - `∇^A` is the greatest element of `Cgr(A)`.
> - `Δ^A` is the least element of `Cgr(A)`.

## Note on the arity hypothesis

The manuscript excludes the empty word via `(S* − {λ})`; Lean's
`IsCongruence` admits `w = []` and is therefore a strict generalization
(`formal_stronger`) on that clause — the same pattern already recorded for
`B-P005`, `B-P015`, `B-P026`, `B-C009`. The overall verdict is `formal_weaker`
only because the `Cgr(A)` structural claims are unmapped.

## Residual note

The blocked clauses are substantive (order/lattice theory for `Cgr(A)`), not
notational. The record inherits the pilot-encoding residuals (`carrier-model`,
`small-large`, `univalence-missing`).
