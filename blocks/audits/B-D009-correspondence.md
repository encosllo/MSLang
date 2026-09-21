# Correspondence audit transcript -- `B-D009`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.supp` (`lean/Mslang/Prelim.lean`)
- **Contract:** Definition `B-D009`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000335`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D009 read-back
>
> Fix `S : Type u`.
>
> - `SSet (S) : Type (u+1)` — abbreviation `S → Type u`.
> - `supp {S} (A : SSet S) : Set S` — definitionally `{s | Nonempty (A s)}`. The **support** of a sorted set: the set of sorts `s` at which `A s` is inhabited (has at least one element). Membership characterization: `s ∈ supp A ↔ Nonempty (A s)`.
>
> No theorems. Note the use of `Nonempty` (propositional inhabitation) rather than exhibiting an element; this makes `supp` well-behaved without choice.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D009 verdict
>
> Contract: `supp_S(A) = {s ∈ S | A_s ≠ ∅}`.
>
> - Clause "the set of sorts at which `A_s ≠ ∅`": Lean `supp A := {s | Nonempty (A s)}`; `Nonempty (A s)` is equivalent to `A s ≠ ∅`. ✓
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — support is exactly the set of sorts with inhabited carrier.

