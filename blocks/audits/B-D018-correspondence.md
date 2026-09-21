# Correspondence audit transcript -- `B-D018`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.suppAlg` (`lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D018`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000343`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D018 read-back
>
> Fix `S : Type u`.
>
> - `SSet (S) : Type (u+1)` — abbreviation `S → Type u`.
> - `Signature (S)` — abbreviation `List S × S → Type u`.
> - `supp {S} (A : SSet S) : Set S` — definitionally `{s | Nonempty (A s)}`; the set of sorts at which `A` is inhabited.
>
> - `suppAlg {S} {Sig : Signature S} (X : Alg Sig) : Set S` — definitionally `supp X.1`. The **support of an algebra** `X`: it is the support (`supp`) of `X`'s underlying sorted set, accessed as the first field `X.1`. Hence `s ∈ suppAlg X ↔ Nonempty (X.1 s)`.
>
> Note: the type `Alg Sig` is referenced (and `X.1` is used, implying `Alg Sig` is a structure whose first projection is an `SSet S`), but `Alg` is **not defined in this file**. No theorems.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D018 verdict
>
> Contract: `supp_S(A)` for a `Σ`-algebra `A` is the support of its underlying `S`-sorted set.
>
> - Clause "support of the underlying sorted set": Lean `suppAlg X := supp X.1`, where `X.1` is the underlying sorted set and `supp A := {s | Nonempty (A s)}`. ✓
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — the algebra's support is definitionally the support of its underlying sorted set.

