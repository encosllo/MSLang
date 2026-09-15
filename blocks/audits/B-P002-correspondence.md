# Correspondence audit transcript -- `B-P002` (`PropIncSat`)

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.prop_incSat` (`lean/Mslang/Pilot.lean`)
- **Contract:** Proposition `B-P002`, `\label{PropIncSat}`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000044`
- **Encoding:** dependent-type carrier model (`representation/pilot-encoding.md`);
  re-run after the Session 29 representation change.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> The theorem concerns two `S`-sorted equivalence relations `Φ` and `Ψ` on an
> `S`-sorted carrier `A`, and says that `Φ` refines `Ψ` -- pointwise, every pair
> related by `Φ` is related by `Ψ` (`sortedEqvLe Φ Ψ`) -- if and only if, for
> every componentwise subset `X` of `A`, closing `X` under `Ψ` and then closing
> the result under `Φ` gives back exactly the `Ψ`-closure of `X`:
> `sat Φ (sat Ψ X) = sat Ψ X`.
>
> Objects: `S` the type of sorts; `A : S → Type u`; `Sub A` a per-sort subset;
> `SortedEqv A` a per-sort setoid; `sat Φ X s = {a | ∃ x ∈ X s, (Φ s).r x a}`.
> Forward direction: if `Φ` refines `Ψ`, then `sat Ψ X` is `Ψ`-closed and
> `Φ ⊆ Ψ`, so `Φ`-closing adds nothing. Reverse direction: if
> `sat Φ (sat Ψ X) = sat Ψ X` for all `X`, taking `X` a singleton `{x}` in a
> component, `sat Ψ X` is the `Ψ`-class of `x` and its `Φ`-closure equalling
> itself forces every `Φ`-successor of `x` to be `Ψ`-related to `x`. Degenerate
> cases: empty `S` vacuous; an empty carrier component imposes no constraint; an
> empty `X s` gives empty on both sides.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> Both directions and the quantifier domain match the contract exactly. The
> read-back's `sortedEqvLe Φ Ψ` is precisely the componentwise inclusion
> `Φ ⊆ Ψ`, and its condition `sat Φ (sat Ψ X) = sat Ψ X` for every `X` is
> precisely `[[X]^Ψ]^Φ = [X]^Ψ` (same order). The biconditional is stated in the
> same direction, and the `sat` definition matches the componentwise union of
> `Φ`-classes meeting `X`.
>
> Direction check: forward (`Φ ⊆ Ψ` implies the condition) uses that `sat Ψ X`
> is `Ψ`-closed; reverse instantiates at the componentwise singleton `X` (valid
> in the contract's "for all `X`" domain). No stronger hypothesis is smuggled
> in, and no case is dropped. Degenerate cases agree: empty `S` vacuous, empty
> carrier component imposes no constraint, empty `X s` yields `∅` on both sides.

## Note on the manuscript route

The manuscript's converse proof constructs its test family via
`\delta^{s,[a]_{\Psi_s}}`; the Lean proof instead uses a plain singleton family
(`Function.update (fun _ => ∅) s {x}`), which is simpler and does not need
`delta`. Whether the paper's proof is simplified accordingly is the author
decision `D-bp002-simplification`; it does not affect this correspondence
verdict, which is about the statement, not the proof.

## Residual note

Inherits the pilot encoding's residuals (see `E-000040`); a representation change
(class C6) stales this verdict.
