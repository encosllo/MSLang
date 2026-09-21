# Correspondence audit transcript -- `B-D015`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.ker` (`lean/Mslang/Prelim.lean`)
- **Contract:** Definition `B-D015`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000340`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D015 read-back
>
> Fix `S : Type u`.
>
> - `SSet (S) : Type (u+1)` — abbreviation `S → Type u`.
> - `SortedEqv {S} (A : SSet S) : Type u` — abbreviation `∀ s, Setoid (A s)`. A sortwise equivalence relation on `A`: for each sort `s`, a `Setoid` on `A s` (Lean's bundled relation with reflexivity, symmetry, transitivity).
> - `SortedMap {S} (A B : SSet S)` — abbreviation `∀ s, A s → B s`; a sort-preserving map.
>
> - `ker {S} {A B} (f : SortedMap A B) : SortedEqv A` — the **kernel** of `f`. Definitionally it is `fun s => ⟨fun x y => f s x = f s y, ⟨rfl, symm, trans⟩⟩`: at each sort `s`, the setoid on `A s` whose relation is equality of images under `f s`. The three `Setoid` fields are proved by `rfl`, `Eq.symm`, `Eq.trans`. Thus `x ~_{ker f, s} y ↔ f s x = f s y`.
>
> No theorems beyond the fact (packaged in the definition) that the kernel relation at each sort is reflexive, symmetric, and transitive. It is a definition built without axioms.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D015 verdict
>
> Contract: `Ker(f)` for `f : A → B` is the `S`-sorted relation with `Ker(f)_s = Ker(f_s)` (kernel pair of `f_s`).
>
> - Clause "sortwise kernel relation, `Ker(f)_s = Ker(f_s)`": Lean `ker f s := ⟨fun x y => f s x = f s y, ⟨rfl, symm, trans⟩⟩`; the relation is `x ~ y ↔ f s x = f s y`, i.e. the kernel pair of `f s`, packaged as a `Setoid` with the three laws proved. ✓
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — the sortwise kernel relation matches, with the equivalence laws included.

