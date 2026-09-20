# Correspondence audit transcript -- `B-A001`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declaration:** `Mslang.FiniteSorts` (`lean/Mslang/Regular.lean`).
- **Contract:** Assumption `B-A001`: "In the remainder of this section we require
  `S` to be finite."
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> The declaration introduces a property, `FiniteSorts`, predicated of any type
> (sort) `S`: it asserts that `S` is finite. `FiniteSorts S` holds exactly when
> the collection of elements of `S` is a finite set. The definition is a
> transparent renaming: `FiniteSorts S` is, by definition, the standard
> finiteness proposition `Finite S`, carrying no additional data.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The Lean declaration `FiniteSorts S := Finite S` expresses exactly the
> proposition that `S` is finite, which is precisely what the contract "we
> require `S` to be finite" demands as a standing hypothesis. The only difference
> is packaging (a named predicate versus an inline requirement), which is a
> permissible difference of phrasing. No additional content is asserted or
> omitted.

## Residual note

`B-A001` is an **assumption**, not a theorem: the section's declarations carry
its content as the `[Finite S]` typeclass hypothesis (`B-P032`, `B-P033`,
`B-P034`, `B-P039`, ...). Naming it (`FiniteSorts`) records the assumption as a
mapped object without pretending it is proved. Its companion remark `B-R024`
proves that the assumption is *equivalent* to the property that every free
algebra has finite support, so the named hypothesis is not vacuous.
