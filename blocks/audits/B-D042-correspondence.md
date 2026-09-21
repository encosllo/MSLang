# Correspondence audit transcript -- `B-D042`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.algebraFinite` (`lean/Mslang/Regular.lean`)
- **Contract:** Definition `B-D042`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000366`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is faithful, not a weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D042 — read-back
>
> Fixed data: sorts `S`; `SSet S := S → Type u` (sortwise carrier);
> `Signature S := (List S × S) → Type u`. `Alg Sig` is used as a bundled algebra
> (carrier `.1 : SSet S`, operations `.2`); it is not defined in this file.
>
> ## Definitions
>
> - `FiniteSSet A := Finite (Sigma A)`. The many-sorted set `A` is finite iff its
>   disjoint sum `Σ s, A s` over all sorts is a finite type (equivalently, finitely
>   many sorts have nonempty carriers and each carrier is finite).
> - `FiniteAlg X`, for a bundled algebra `X : Alg Sig`:
>   `FiniteSSet X.1`. The algebra is finite iff its underlying many-sorted carrier
>   is finite. No condition is placed on the operations.
> - `algebraFinite Sig := {A : Alg Sig | FiniteAlg A}`. The set of finite
>   `Sig`-algebras.
>
> ## Theorems
>
> None (definitions only).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D042 — verdict
>
> Contract: `Alg_f(Σ)` is the set of all finite Σ-algebras.
>
> ## Clause-by-clause
>
> - "finite Σ-algebra" — Lean: `FiniteAlg X := FiniteSSet X.1` with
>   `FiniteSSet A := Finite (Sigma A)`; i.e. the underlying S-sorted carrier is a
>   finite type, with no constraint on the operations. Present.
> - "Alg_f(Σ)" — Lean: `algebraFinite Sig := {A : Alg Sig | FiniteAlg A}`. Present.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the finite-algebra predicate and the set `Alg_f(Σ)` are
> both defined as specified.

