# Correspondence audit transcript -- `B-D012`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsAlgebraicClosureSystem` (`lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D012`, section "Preliminaries.".
- **Outcome:** `formal_weaker`
- **Recorded as:** `E-000338`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D012 read-back
>
> Fix `S : Type u`.
>
> - `SSet (S) : Type (u+1)` — abbreviation `S → Type u`.
> - `Sub {S} (A : SSet S) : Type u` — abbreviation `∀ s, Set (A s)`.
> - `Subset {S} {A} (X Y : Sub A) : Prop` — definitionally `∀ s, X s ⊆ Y s` (sortwise inclusion).
> - `Sub_iInter {S} {A} (D : Set (Sub A)) : Sub A` — definitionally `fun s a => ∀ X ∈ D, a ∈ X s`; sortwise intersection of the family `D`.
> - `Sub_iUnion {S} {A} (D : Set (Sub A)) : Sub A` — definitionally `fun s a => ∃ X : Sub A, X ∈ D ∧ a ∈ X s`; sortwise union: `a ∈ Sub_iUnion D s` iff `a ∈ X s` for some `X ∈ D`.
>
> - `IsClosureSystem {S} {A} (C : Set (Sub A)) : Prop` — definitionally:
>   1. `(fun s => Set.univ) ∈ C` (full sub-object is in `C`), and
>   2. `∀ D, D ⊆ C → D.Nonempty → Sub_iInter D ∈ C` (closed under nonempty intersections).
>
> - `IsAlgebraicClosureSystem {S} {A} (C : Set (Sub A)) : Prop` — definitionally the conjunction of:
>   1. `IsClosureSystem C`; and
>   2. `∀ D : Set (Sub A), D ⊆ C → D.Nonempty → (∀ X ∈ D, ∀ Y ∈ D, ∃ Z ∈ D, Subset X Z ∧ Subset Y Z) → Sub_iUnion D ∈ C`.
>
>   So an algebraic closure system is a closure system that is additionally closed under **nonempty directed unions**: for any nonempty subfamily `D ⊆ C` that is directed under sortwise inclusion (any two members are dominated by a third member of `D`), the sortwise union of `D` lies in `C`.
>
> Note the directedness hypothesis is stated for all pairs `X, Y ∈ D` (including `X = Y`) with a common upper bound `Z ∈ D`.
>
> No theorems.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D012 verdict
>
> Contract clause (1) — algebraic closure system: an `S`-closure system `C` such that for every nonempty `D ⊆ C` directed under `∪` (any `X,Y ∈ D` have some `Z ∈ D` with `X ∪ Y ⊆ Z`), `⋃D ∈ C`; notation `AClSy(A)`, poset `AClSy(A)`.
>
> - "is an `S`-closure system": Lean `IsClosureSystem C`. ✓
> - "directed nonempty `D`": Lean hypothesis `D ⊆ C`, `D.Nonempty`, `(∀ X∈D, ∀ Y∈D, ∃ Z∈D, Subset X Z ∧ Subset Y Z)` — `Subset X Z ∧ Subset Y Z` is exactly `X ∪ Y ⊆ Z`. ✓
> - "then `⋃D ∈ C`": Lean `Sub_iUnion D ∈ C` with `Sub_iUnion D := fun s a => ∃ X, X ∈ D ∧ a ∈ X s`. ✓
> - Notation/poset `AClSy(A)`: not bundled (minor).
>
> Contract clause (2) — algebraic closure operator: an `S`-closure operator `J` with `J(X) = ⋃_{Z ∈ Sub_f(X)} J(Z)`; notation `AClOp(A)`, poset `AClOp(A)`.
>
> - This entire clause has no Lean counterpart in the read-back.
>
> Contract clauses with no Lean counterpart: the algebraic closure-operator definition of clause (2), and the `AClSy`/`AClOp` notation and orders.
> Verdict: formal_weaker — the algebraic closure-system half is formalized (including the directedness hypothesis), but the algebraic closure-operator half is absent.

