# Correspondence audit transcript -- `B-P008`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.finalAlg`, `Mslang.IsAlgIso`,
  `Mslang.subAlg`, `Mslang.SubfinalAlg`, `Mslang.subfinalAlg_iff`
  (`lean/Mslang/Pilot.lean`)
- **Contract:** Proposition `B-P008`, section "Preliminaries".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000105`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `S` is a set of sorts; an `S`-sorted set is a family of types; `Sub A` is a
> componentwise family of subsets. `subAlg Sig F X hX` is the `Σ`-algebra whose
> carrier at `s` is the subtype `{a : A s // a ∈ X s}`. `finalAlg Sig` is the
> terminal algebra on the constant one-element family `fun _ => PUnit`.
> `IsAlgIso` is a homomorphism bijective at every sort. `Subfinal X.1` means
> every component is a subsingleton (at most one element).
>
> `SubfinalAlg Sig X`: there exists a subalgebra `Y` of the terminal algebra
> and an algebra isomorphism from `X` to `subAlg ... Y ...`; i.e. `X` is
> isomorphic to a subalgebra of `1`.
>
> `subfinalAlg_iff`: `SubfinalAlg Sig X ↔ Subfinal X.1`, i.e. `X` is isomorphic
> to a subalgebra of the terminal algebra iff every component of its carrier has
> at most one element.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> `SubfinalAlg Sig X` is exactly "`X` is isomorphic to a subalgebra of `1`": a
> genuine subalgebra `Y` of the terminal algebra (closed under operations),
> together with a bijective homomorphism — an isomorphism, and iso is
> symmetric. `finalAlg Sig` is the intended final algebra `1`. The carrier
> `X.1` is the contract's `A`. `Subfinal X.1` (componentwise subsingleton)
> matches `card(A_s) ≤ 1`, empty components allowed. The biconditional is
> stated for an arbitrary `Σ`-algebra with no extra hypothesis. No divergence.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
