# Correspondence audit transcript -- `B-R001`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.SortedIso`, `Mslang.iCoprod`, `Mslang.deltaT`,
  `Mslang.delta_iso_coprod` (`lean/Mslang/Pilot.lean`)
- **Contract:** Remark `B-R001`, section "Preliminaries".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000113`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `delta t` is the Kronecker delta `δ^t`: `PUnit` at sort `t`, `PEmpty`
> elsewhere. `deltaT t X` is `δ^{t,X}`: `X` at sort `t`, empty elsewhere.
> `iCoprod A` is the coproduct of an indexed family of sorted sets, componentwise
> `Σ i, A i s`. `SortedIso A B` is a sorted map bijective at every sort.
>
> **`delta_iso_coprod`.** `SortedIso (deltaT t X) (iCoprod (fun _ : X => delta
> t))`, i.e. `δ^{t,X} ≅ ∐_{x : X} δ^t`. The componentwise bijection sends
> `x : X` at sort `t` to `⟨x, ⋆⟩` (since the coproduct component is
> `Σ _ : X, PUnit`), and is the unique empty bijection at every other sort
> (both sides `PEmpty`).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> The formal statement compares exactly `δ^{t,X}` (`deltaT t X`) with the
> coproduct `∐_{x∈X} δ^t` (`iCoprod (fun _ : X => delta t)`), and `SortedIso`
> is the sortwise bijection the contract calls "isomorphic". No hypothesis is
> added or dropped; both sides are the intended objects and the described
> bijection matches.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
