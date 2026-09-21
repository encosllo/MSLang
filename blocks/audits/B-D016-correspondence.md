# Correspondence audit transcript -- `B-D016`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.Signature` (`lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D016`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000341`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D016 read-back
>
> Fix `S : Type u`.
>
> - `Signature (S : Type u)` — abbreviation for `List S × S → Type u`. A (many-sorted, single-sorted-indexed) **signature**: to each *arity datum* `p = (w, s)` consisting of a list of input sorts `w : List S` and an output sort `s : S`, it assigns a type `Sig p : Type u` whose elements are the operation symbols of that arity. The list `w` is the ordered sort-sequence of the arguments; `s` is the result sort. There is no restriction to finite arities beyond `List S` being finite lists.
>
> No theorems or other definitions. Everything is definitionally this abbreviation.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D016 verdict
>
> Contract: an `S`-sorted signature is a function `Σ : S^★ × S → U` sending `(w,s)` to the set `Σ_{w,s}` of formal operations of arity `w` and coarity `s`.
>
> - Clause "`Σ : S^★ × S → U`": Lean `Signature S := List S × S → Type u` with `S^★ = List S`. ✓
> - Clause "`Σ_{w,s}` is the set of formal operations of arity `w`, sort `s`": Lean `Sig p : Type u` for `p = (w, s)`. ✓
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — the signature is exactly a type-valued family indexed by `List S × S`.

