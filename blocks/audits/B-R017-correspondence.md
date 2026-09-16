# Correspondence audit transcript -- `B-R017`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.subfinalAlg_mem_of_formation`
  (`lean/Mslang/Formation.lean`)
- **Contract:** Remark `B-R017`, section "Σ-congruence formations ...".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000127`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `SubfinalAlg Sig A` = `A` is isomorphic to a subalgebra of the final algebra
> `1` (equivalently, componentwise subsingleton). `IsAlgebraFormation Sig F` =
> closure under homomorphic images and finite subdirect products.
>
> **`subfinalAlg_mem_of_formation`.** For a formation `F`, every subfinal `A`
> satisfies `A ∈ F`. Proof idea: the empty finite product is the terminal
> algebra; the unique map `A → ∏_{∅}` is injective (subsingleton components by
> `subfinalAlg_iff`) and homomorphic, with vacuous projection-surjectivity, so it
> is a subdirect embedding; `PFsd`-closure gives `A ∈ F`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> The statement is exactly `Sf(1) ⊆ F`: `SubfinalAlg Sig` characterizes the
> contract's `Sf(1)`, and the formation hypothesis and quantifiers match. The
> observation "the empty product is `1`" is a proof device, not a required
> separate lemma, so its absence as a standalone statement is not a divergence.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
