# Correspondence audit transcript -- `B-D001`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.Word`, `Mslang.concat`, `Mslang.emptyWord` (`lean/Mslang/Prelim.lean`)
- **Contract:** Definition `B-D001`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000331`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D001 read-back
>
> The file fixes a type universe `u`. Note there is **no** `SSet` here; the whole development is about plain words over a fixed alphabet type `S`.
>
> - `Word (S : Type u) : Type u` — abbreviation for `List S`. A word over alphabet `S` is just a finite list of elements of `S`. (The alphabet `S` is a bare type, not a "sorts" type; `Word` is a plain word type.)
> - `concat {S} (w v : Word S) : Word S` — definitionally `w ++ v`: the concatenation of the two words `w` then `v`.
> - `emptyWord (S) : Word S` — definitionally `[]`: the empty word over `S`.
>
> There are no theorems; only the three definitions above. All are transparent abbreviations/definitions, so they hold definitionally.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D001 verdict
>
> Contract: free monoid on `S` = triple `(S^★, ⋏, λ)`.
>
> - Clause "`S^★` = `⋃_n Hom(n,S)` (words on `S`)": Lean `Word S := List S` — a finite list of elements of `S`, i.e. the same union. ✓
> - Clause "concatenation `⋏`": Lean `concat w v := w ++ v`. ✓
> - Clause "empty word `λ`": Lean `emptyWord := []`. ✓
>
> The triple's three components all have definitional Lean counterparts; the contract states no monoid axioms beyond the triple.
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — the three constituents of the free monoid (word set, concatenation, empty word) are each represented definitionally in Lean.

