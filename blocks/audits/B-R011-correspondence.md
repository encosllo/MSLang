# Correspondence audit transcript -- `B-R011`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.hom_unique_of_subfinalAlg`
  (`lean/Mslang/Pilot.lean`)
- **Contract:** Remark `B-R011`, section "Preliminaries".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000109`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `S` is a set of sorts; `A`, `B` are `S`-sorted sets with `Σ`-algebra
> structures `FA`, `FB`. `SubfinalAlg Sig ⟨A, FA⟩` means `(A, FA)` is subfinal;
> by `subfinalAlg_iff` this is `Subfinal A`, i.e. every component `A s` is a
> subsingleton.
>
> **`hom_unique_of_subfinalAlg`.** If `(A, FA)` is subfinal, then any two
> homomorphisms `f, g : B → A` (viewed as sorted maps) are equal. Proof:
> `Subfinal A` gives `Subsingleton (A s)` at each sort, so `funext` +
> `Subsingleton.elim` shows `f s x = g s x` pointwise. The homomorphism
> hypotheses are present but unused: uniqueness follows from subfinality alone.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> "If `A` is subfinal, for every `Σ`-algebra `B`, at most one homomorphism
> `B → A`" is rendered exactly as "`A` subfinal ⇒ any two homomorphisms
> `f, g : B → A` are equal", with `B` fully arbitrary and target `A` subfinal.
> The fact that the homomorphism hypotheses are unused in the proof is a
> property of the proof, not of the statement; the stated hypotheses and
> conclusion match the contract. No divergence.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
