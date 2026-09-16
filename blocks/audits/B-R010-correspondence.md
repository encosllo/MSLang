# Correspondence audit transcript -- `B-R010`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.SuppClosure`, `Mslang.suppSub_Sg`,
  `Mslang.suppSub_Sg_uniform` (`lean/Mslang/Pilot.lean`), with `Mslang.MemSg`
  and `Mslang.Sg` as the generating operator.
- **Contract:** Remark `B-R010`, section "Preliminaries".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000079`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `S` is a set of sorts; `A : S → Type`; `X : Sub A` is a componentwise
> subset; `suppSub X = {s | X s nonempty}`. `Sig` is a signature and
> `AlgStruct Sig A` interprets its operations; `F p σ a` applies `σ`.
>
> **`IsSubalgebra`.** `X` closed under every operation.
>
> **`MemSg` / `Sg`.** `MemSg Sig F X s a` is the inductive closure of `X` under
> the operations (base `a ∈ X s`; step from generated tuples). `Sg Sig F X` is
> the componentwise set of generated elements — the least subalgebra of `A`
> containing `X`.
>
> **`SuppClosure Sig T`.** The least set of sorts containing `T` and closed
> under arities: if every sort of an operation's arity word is in it, its
> coarity sort is too. It depends only on `Sig` and `T`, never on `F`.
>
> **`suppSub_Sg`.** `suppSub (Sg Sig F X) = SuppClosure Sig (suppSub X)`: the
> support of the generated subalgebra is the support-level closure of the
> support of `X` — a function of `Sig` and `suppSub X` alone.
>
> **`suppSub_Sg_uniform`.** For any `X, Y : Sub A`, if
> `suppSub X = suppSub Y` then `suppSub (Sg Sig F X) = suppSub (Sg Sig F Y)`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> `F` is the operation interpretation that *is* the algebra `A`, so the
> dependence on `F` is not an extra hypothesis. `Sub A` matches `X ⊆ A`; `suppSub`
> matches `supp_S` on subsets. `MemSg`/`Sg` give the least subalgebra containing
> `X` (closed under operations and contained in every subalgebra containing
> `X`), matching `Sg_A(X)`. `suppSub_Sg_uniform` has the same quantifiers and
> conclusion as the contract. `SuppClosure` and `suppSub_Sg` are auxiliary;
> `suppSub_Sg` is a strictly stronger intermediate fact (support depends only on
> `Sig` and `suppSub X`), but the final uniformity claim is exactly the
> contract's. No missing or extra hypothesis, no shifted objects.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
`Sg_A` is encoded by the inductive predicate `MemSg` (least subalgebra
containing `X`), which is the paper's generating operator at the definitional
level.
