# Correspondence audit transcript -- `B-D004`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages ran in
fresh, isolated contexts; neither was told the expected answer.

- **Lean declarations:** `Mslang.Subfinal`, `Mslang.finalSorted`,
  `Mslang.initialSorted`, `Mslang.card_le_one_iff` (`lean/Mslang/Pilot.lean`)
- **Contract:** Definition `B-D004`
- **Outcome:** `incomparable`
- **Recorded as:** `E-000021`
- **Independence:** both stages share this session's model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `Subfinal A` means every component `A_s` has at most one element.
> `finalSorted`'s component at each sort is `Set.univ`, the **whole ambient
> `U`** -- not a fixed singleton. `initialSorted` is the constantly-empty
> family. `card_le_one_iff` identifies subfinality with `∀ s, (A s).encard ≤ 1`.
> The read-back explicitly flags that `finalSorted` is a singleton only when
> `U` has one element, and equals `initialSorted` when `U` is empty.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `incomparable`.**
>
> - `Subfinal` vs `card(A_s) ≤ 1`: **match**.
> - `initialSorted` vs `∅^S`: **match**.
> - `finalSorted` vs `1^S` (the constant family on the terminal object `1`, a
>   fixed singleton): **mismatch**. With `|U| ≥ 2`, Lean gives all of `U` (card
>   `|U| > 1`), strictly larger than a singleton, and it is not terminal for
>   this carrier (a map into it is not unique). With `|U| = 1` they coincide.
>   With `U = ∅`, Lean gives `∅ = initialSorted`, while the contract's `1^S` is
>   a nonempty constant family, so the two are not even comparable in that case.
> - Since the discrepancy is not monotone across `U` (superset for `|U|>1`,
>   degenerate/disjoint for `U=∅`), `finalSorted` is neither uniformly stronger
>   nor weaker than `1^S`: `incomparable`.

## Classification and disposition

This is an **`F-representation`** finding (Section 10.2): the encoding cannot
express the paper's terminal `1^S` (a fixed singleton), only the top of the
fixed-ambient subobject lattice (`Set.univ`). It is the concrete manifestation of
encoding residual `R-delta` (Session 16). Proposed remedy (author decision,
Section 16.4 / class C6): encode `1^S` as a constant chosen singleton,
`fun _ => ({Classical.choice ‹Nonempty U›} : Set U)` (requires `Nonempty U`, as
the paper's universe is nonempty), and re-prove `supp_finalSorted`. Blast radius:
`B-D004` and `supp_finalSorted` only (the pilot theorems use `A` itself, not
`finalSorted`).
