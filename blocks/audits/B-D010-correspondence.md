# Correspondence audit transcript -- `B-D010`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsClosureSystem` (`lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D010`, section "Preliminaries.".
- **Outcome:** `formal_weaker`
- **Recorded as:** `E-000336`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D010 read-back
>
> Fix `S : Type u`.
>
> - `SSet (S) : Type (u+1)` — abbreviation `S → Type u`.
> - `Sub {S} (A : SSet S) : Type u` — abbreviation `∀ s, Set (A s)`.
> - `Sub_iInter {S} {A} (D : Set (Sub A)) : Sub A` — definitionally `fun s a => ∀ X : Sub A, X ∈ D → a ∈ X s`. The **sortwise intersection** of a family `D` of sub-objects: an element `a : A s` belongs to the intersection iff it belongs to `X s` for *every* `X ∈ D`. (Empty-family behavior: if `D = ∅`, the condition is vacuous, so `Sub_iInter ∅` is the full sub-object.)
>
> - `IsClosureSystem {S} {A} (C : Set (Sub A)) : Prop` — definitionally the conjunction of:
>   1. `(fun s => Set.univ) ∈ C`: the "full" sub-object (all of `A s` at each sort) is in `C`; and
>   2. `∀ D : Set (Sub A), D ⊆ C → D.Nonempty → Sub_iInter D ∈ C`: whenever `D` is a nonempty subfamily of `C`, the sortwise intersection of `D` is again in `C`.
>
>   So a closure system is a family of sub-objects containing the top element and closed under nonempty intersections (of subfamilies drawn from `C`). No closure operator is defined here; only the family.
>
> No theorems.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D010 verdict
>
> Contract clause (1) — closure system: `C ⊆ Sub(A)` with `A ∈ C` and, for nonempty `D ⊆ C`, `⋂D = (⋂_{D∈D} D_s)_s ∈ C`; notation `ClSy(A)`, poset `ClSy(A)`.
>
> - "top/full element `A ∈ C`": Lean `(fun s => Set.univ) ∈ C`. ✓
> - "closed under nonempty sortwise intersections": Lean `∀ D, D ⊆ C → D.Nonempty → Sub_iInter D ∈ C` with `Sub_iInter D := fun s a => ∀ X ∈ D, a ∈ X s`. ✓
> - "`ClSy(A)` and its inclusion order": not separately bundled (minor notational omission).
>
> Contract clause (2) — closure operator: a map `J : Sub(A) → Sub(A)` that is extensive (`X ⊆ J(X)`), isotone (`X ⊆ Y ⇒ J(X) ⊆ J(Y)`), and idempotent (`J(J(X)) = J(X)`); notation `ClOp(A)`, poset `ClOp(A)`.
>
> - This entire clause has no Lean counterpart: the read-back contains no closure-operator definition, no extensity/isotonicity/idempotence conditions, and no `ClOp` order.
>
> Contract clauses with no Lean counterpart: the closure-operator definition of clause (2) (extensivity, isotonicity, idempotence), and the `ClSy`/`ClOp` notation and orders.
> Verdict: formal_weaker — the closure-system half of the definition is formalized, but the whole closure-operator half (clause 2) is absent.

