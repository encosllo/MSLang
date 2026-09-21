# Correspondence audit transcript -- `B-D019`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.FiniteAlg` (`lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D019`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000344`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D019 read-back
>
> Fix `S : Type u`.
>
> - `SSet (S) : Type (u+1)` — abbreviation `S → Type u`.
> - `Signature (S)` — abbreviation `List S × S → Type u`.
> - `FiniteSSet {S} (A : SSet S) : Prop` — definitionally `Finite (Sigma A)`. A sorted set is finite iff its total space `Σ s, A s` is finite.
> - `FiniteAlg {S} {Sig : Signature S} (X : Alg Sig) : Prop` — definitionally `FiniteSSet X.1`. An algebra `X` is finite iff its underlying sorted set (`X.1`) is finite, i.e. iff the total space `Σ s, X.1 s` is finite. (Finiteness of the operation set / of the signature is not required or mentioned.)
>
> Note: `Alg Sig` is referenced but **not defined in this file**. No theorems.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D019 verdict
>
> Contract: a `Σ`-algebra `A` is finite if its underlying `S`-sorted set is finite.
>
> - Clause "finite iff underlying sorted set finite": Lean `FiniteAlg X := FiniteSSet X.1` with `FiniteSSet A := Finite (Sigma A)` (total space `Σ s, A s` finite). ✓
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — algebra finiteness is exactly total-space finiteness of the underlying sorted set.

