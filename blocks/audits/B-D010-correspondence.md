# Correspondence audit transcript -- `B-D010`

Protocol: Architecture.md Section 11.2, two-stage blind. Re-audit in Session 119
after a class C5 declaration move and/or definition revision; fresh isolated agents,
no expected answer disclosed.

- **Lean declarations:** `Mslang.IsClosureSystem`, `Mslang.IsClosureOperator` (`lean/Mslang/Algebra.lean`, `lean/Mslang/Prelim.lean`)
- **Contract:** Definition `B-D010`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000374` (supersedes `E-000336`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** same-model stages (`deepseek-v4.1-flash`); shared blind spots not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D010 — informal read-back
>
> ## Ambient setup
>
> Fix `S : Type u`, `SSet S := S → Type u`, a fixed `A : SSet S`, and
> `Sub A := ∀ s, Set (A s)` (many-sorted subsets). `Subset X Y := ∀ s, X s ⊆ Y s`
> (sortwise inclusion).
>
> - `Sub_iInter D`, for a family `D : Set (Sub A)` of many-sorted subsets, is the
>   many-sorted subset
>   `fun s a => ∀ X : Sub A, X ∈ D → a ∈ X s`,
>   i.e. the sortwise intersection of all members of `D`: at sort `s`, `a` is in
>   `Sub_iInter D` iff `a ∈ X s` for every `X ∈ D`. (If `D` is empty this is
>   everywhere true, i.e. the full subobject, by vacuity.)
>
> - `IsClosureSystem C`, for `C : Set (Sub A)`, is the conjunction of:
>   - (top) the full many-sorted subset `fun s => (Set.univ : Set (A s))` belongs
>     to `C`;
>   - (intersections) for every `D : Set (Sub A)` such that `D ⊆ C` (every member
>     of `D` is in `C`) and `D.Nonempty` (i.e. `∃ X, X ∈ D`), the intersection
>     `Sub_iInter D` again belongs to `C`.
>
>   Reading: `C` is a family of many-sorted subsets closed under the full
>   subobject and under intersections of nonempty subfamilies drawn from `C`. The
>   nonemptiness requirement avoids having to demand the top element twice.
>
> - `IsClosureOperator c`, for `c : Sub A → Sub A`, is the conjunction of:
>   extensivity `∀ X, Subset X (c X)`; monotonicity
>   `∀ X Y, Subset X Y → Subset (c X) (c Y)`; and idempotence
>   `∀ X, c (c X) = c X`.
>
> ## Theorems
>
> There are **no theorems** in this file. It contains only the definitions above
> (`IsClosureSystem`, `IsClosureOperator`, `SSet`, `Sub`, `Sub_iInter`, `Subset`),
> all of which are definition bodies; no assertion is made and nothing is proven.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D010 — verdict
>
> ## Clause-by-clause comparison
>
> Contract: Definition, two numbered items, `A` an `S`-sorted set.
>
> | # | Contract clause | Lean counterpart | Match |
> |---|---|---|---|
> | 1 | `S`-**closure system on `A`**: `C ⊆ Sub(A)` with `A ∈ C` and, for any `D ⊆ C` with `D ≠ ∅`, `⋂D = (⋂_{D∈D} D_s)_{s∈S} ∈ C` | `IsClosureSystem C` = full subobject `fun s => Set.univ ∈ C` ∧ (for every `D : Set (Sub A)`, `D ⊆ C` and `D.Nonempty` → `Sub_iInter D ∈ C`) | yes |
> | 1' | Notation `ClSy(A)` (set of closure systems), `ClSy(A)` ordered by inclusion | not bundled; the set is `{C | IsClosureSystem C}` and inclusion is immediate — notational metadata, no mathematical assertion | n/a (notation) |
> | 2 | `S`-**closure operator on `A`**: `J : Sub(A) → Sub(A)` with extensivity `X ⊆ J(X)`, isotonicity `X ⊆ Y → J(X) ⊆ J(Y)`, idempotence `J(J(X)) = J(X)` | `IsClosureOperator c` = extensivity ∧ monotonicity ∧ idempotence | yes |
> | 2' | Notation `ClOp(A)` and the pointwise order `J ≤ K ↔ ∀X, J(X) ⊆ K(X)` | not bundled; predicate only — notational metadata | n/a (notation) |
>
> The two substantive definitions (closure system, closure operator) are matched
> exactly: the top-element clause is the contract's `A ∈ C` (the full many-sorted
> subobject), the intersection clause is the contract's nonempty-`D` intersection
> (`Sub_iInter D s a ↔ ∀ X ∈ D, a ∈ X s`), and the three closure-operator axioms
> line up one-for-one. The file has no theorems, matching the purely definitional
> contract. The only content not carried by Lean is the packaging of the predicate
> into the named sets `ClSy(A)`/`ClOp(A)` and their orders, which is notation
> rather than an assertion.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent
>
> Justification: Both the closure-system and closure-operator definitions are
> matched clause-for-clause, the only unformalized material being notational
> bundling of the underlying sets and their inclusion orders.

## Note

`IsClosureOperator` (the closure-operator clause) is now registered under this block.

