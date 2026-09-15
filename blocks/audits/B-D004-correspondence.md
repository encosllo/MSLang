# Correspondence audit transcript -- `B-D004`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.Subfinal`, `Mslang.finalSorted`,
  `Mslang.initialSorted` (+ `Mslang.card_le_one_iff`, `Mslang.supp_finalSorted`,
  `Mslang.supp_initialSorted`) (`lean/Mslang/Pilot.lean`)
- **Contract:** Definition `B-D004`
- **Outcome:** `equivalent` (**changed from `incomparable`**, `E-000021`)
- **Recorded as:** `E-000043`
- **Encoding:** dependent-type carrier model (`representation/pilot-encoding.md`);
  re-run after the Session 29 representation change.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> The text sets up an `S`-sorted carrier as `A : S → Type u`. `Subfinal A :=
> ∀ s, Subsingleton (A s)`: every component has at most one element.
> `finalSorted S := fun _ => PUnit`: every component is the one-element type
> `PUnit` (a genuine constant singleton family). `initialSorted S := fun _ =>
> PEmpty`: every component is the empty type `PEmpty`. `supp A := {s | Nonempty
> (A s)}`: sorts with a nonempty component. `card_le_one_iff`: `Subfinal A ↔
> ∀ s, (Set.univ : Set (A s)).encard ≤ 1`, i.e. subfinality is equivalent to
> each component's universal set having extended cardinality at most one.
> `supp_finalSorted`: `supp (finalSorted S) = Set.univ` (supported at every
> sort). `supp_initialSorted`: `supp (initialSorted S) = ∅`. Degenerate cases: if
> `S` is empty, all families are the empty function and `Subfinal` holds
> vacuously; if a component `A s` is empty, `s` lies outside `supp A`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> - **Subfinal:** the contract requires `card(A_s) ≤ 1` for every `s`; the
>   read-back defines `Subfinal A := ∀ s, Subsingleton (A s)`. `Subsingleton` is
>   exactly "at most one element", including the empty component (`card 0 ≤ 1`)
>   and singleton (`card 1`). Matches.
> - **`1^S`:** the contract's final family is the constant one-element set over
>   every sort; `finalSorted S := fun _ => PUnit` is the constant family with
>   every component the one-element type, terminal in `Type`. Matches.
> - **`∅^S`:** `initialSorted S := fun _ => PEmpty` is the constant empty family.
>   Matches.
> - **Support:** `supp A := {s | Nonempty (A s)}` is exactly the set of sorts
>   with nonempty component, and the two support lemmas are its correct
>   consequences.
> - **`card_le_one_iff`** is a derived characterization, valid and adding no
>   content beyond the definition.
>
> Degenerate cases agree: empty `S` makes every family the empty function and
> `Subfinal` holds vacuously; an empty component `A s` places `s` outside
> `supp A`. No added or missing strength.

## Finding resolved

Under the previous fixed-ambient carrier (`A : S → Set U`) `finalSorted` was
`Set.univ`, not a constant singleton, so the pre-C6 audit returned
`incomparable` (`E-000021`, residual `R-delta`, author decision
`D-finalSorted`). The dependent-type carrier makes `1^S` a genuine constant
`PUnit` family, so the correspondence is now `equivalent`; `D-finalSorted` was
closed in Session 29.

## Residual note

Inherits the pilot encoding's residuals (see `E-000040`); a representation change
(class C6) stales this verdict.
