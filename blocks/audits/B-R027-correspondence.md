# Correspondence audit transcript -- `B-R027`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.nabla_sat_mem_of_transPreimage_boolean`
  (`lean/Mslang/Regular.lean`)
- **Contract:** Remark `B-R027`, section "Regular languages" (Def2FRL); the
  section's standing assumption is `S` finite (`B-A001`).
- **Outcome:** `equivalent`
- **Recorded as:** `E-000386`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Fix a finite sort set `S` and an `S`-sorted signature `Sig`. `L` assigns to
> every `S`-sorted set `A` a collection `L A` of sorted subobjects of the term
> algebra. `htrans` says each `L A` is closed under translation preimages
> (`transPreimage T X` is the preimage of the sort-`s` part of `X`, concentrated
> at sort `t` and empty elsewhere). `hbool` says each `L A` is closed under
> binary union, binary intersection, and complement. `hne` says `L A` is
> nonempty; `[Finite S]` restricts the sort set to finitely many sorts. The
> conclusion: every subobject `X` of `Term Sig A` saturated for the universal
> sorted equivalence `nabla` lies in `L A`; saturation means each component
> `X s` is either empty or the entire carrier.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The conclusion is exactly (BPS1) and `htrans` is exactly (BPS2). The apparent
> extra hypothesis `hne` (nonemptiness) is not a strengthening: the contract's
> (BPS3) says `L(A)` is a *Boolean subalgebra*, which by definition contains the
> top and bottom elements; `hbool` (closure under ∪, ∩, complement) plus
> nonemptiness is exactly the decomposition of "Boolean subalgebra", since any
> `X ∈ L(A)` yields `X ∪ ∁X = ⊤` and `X ∩ ∁X = ⊥`. `[Finite S]` matches the
> section's standing assumption. Hence the Lean statement and the remark state
> the same implication.

## Residual note

The degenerate empty family is excluded by the contract's word "subalgebra"
(which contains `⊤`/`⊥`); the Lean hypothesis `hne` is the formal counterpart of
that containment. The block inherits the pilot-encoding residuals
(`carrier-model`, `small-large`, `univalence-missing`).
