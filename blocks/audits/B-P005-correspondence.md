# Correspondence audit transcript -- `B-P005`

Protocol: Architecture.md Section 11.2, two-stage blind. Re-audit in Session 119
after a class C5 declaration move and/or definition revision; fresh isolated agents,
no expected answer disclosed.

- **Lean declarations:** `Mslang.IsCompletelyAdditive`, `Mslang.sat_extensive`, `Mslang.sat_monotone`, `Mslang.sat_idem`, `Mslang.sat_isClosureOperator`, `Mslang.sat_iUnion`, `Mslang.sat_isCompletelyAdditive`, `Mslang.sat_isAlgebraic`, `Mslang.sat_iInter_subset`, `Mslang.sat_univ`, `Mslang.sat_compl`, `Mslang.suppSub_sat`, `Mslang.sat_uniform`, `Mslang.satSets_fix` (`lean/Mslang/Prelim.lean`)
- **Contract:** Proposition `B-P005`, section "Preliminaries.".
- **Outcome:** `formal_stronger`
- **Recorded as:** `E-000373` (supersedes `E-000298`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** same-model stages (`deepseek-v4.1-flash`); shared blind spots not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-P005 — informal read-back
>
> ## Ambient setup
>
> Fix a universe `u` and a type of *sorts* `S : Type u`.
>
> - `SSet S := S → Type u`. An element `A : SSet S` is a many-sorted family of
>   carriers: for each sort `s : S`, a type `A s`.
> - `Sub A := ∀ s, Set (A s)` (for fixed `A : SSet S`). An element `X : Sub A` is
>   a many-sorted subset: for each sort `s`, a set `X s ⊆ A s`.
> - `Subset X Y := ∀ s, X s ⊆ Y s`; so `Subset` is sortwise inclusion of
>   many-sorted subsets.
> - `complA X := fun s => (X s)ᶜ`; sortwise complement.
> - `SortedEqv A := ∀ s, Setoid (A s)`. An element `Φ : SortedEqv A` is a family
>   of equivalence relations, one on each carrier `A s` (Lean's bundled `Setoid`
>   supplies a relation with `refl`, `symm`, `trans`; the relation is written
>   `(Φ s).r`).
> - `sat Φ X := fun s => {a | ∃ x ∈ X s, (Φ s).r x a}`. Reading: the
>   *saturation* of `X` by `Φ`; at each sort `s` it contains exactly the elements
>   `Φ s`-equivalent to some element of `X s`.
> - `IsSat Φ X := sat Φ X = X`; `X` is saturated (a union of `Φ`-classes).
> - `satSets Φ := {X | IsSat Φ X}`, the collection of saturated many-sorted
>   subsets.
> - `IsClosureOperator c` (for `c : Sub A → Sub A`): the conjunction of
>   extensivity `∀ X, Subset X (c X)`, monotonicity
>   `∀ X Y, Subset X Y → Subset (c X) (c Y)`, and idempotence
>   `∀ X, c (c X) = c X`.
> - `IsAlgebraic c`: for every `X`, sort `s`, and `a : A s` with `a ∈ c X s`,
>   there exists a *pointwise-finite* `F : Sub A` with `Subset F X`
>   (i.e. `F ⊆ X`) and `(∀ t, (F t).Finite)` and `a ∈ c F s`. Reading: every
>   element of the closure of `X` is already produced by some finite subfamily of
>   `X`.
> - `IsCompletelyAdditive c`: for every index type `ι : Type u` (same universe)
>   and every `ι`-indexed family `X : ι → Sub A`,
>   `c (fun s => ⋃ i, X i s) = fun s => ⋃ i, c (X i) s`. Reading: `c`
>   distributes over arbitrary sortwise unions.
>
> `suppSub` does **not** occur as a declaration in this file (it is external).
> From its use it is the *support*: a function sending a many-sorted subset `X` to
> the set of sorts `s` for which `X s` is nonempty. The read-back below records the
> statements as they are, noting this dependency.
>
> Note: several declarations used by the theorems (`IsSat`, `IsAlgebraic`,
> `IsClosureOperator`, `SSet`, `SortedEqv`, `Sub`, `Subset`, `complA`, `sat`,
> `satSets`) appear textually *after* the theorems that mention them; the file is a
> flat listing. This does not affect the mathematical content.
>
> ## Theorems
>
> 1. `sat_extensive Φ X : Subset X (sat Φ X)`.
>    For every `Φ : SortedEqv A` and `X : Sub A`, `X ⊆ sat Φ X` sortwise: for each
>    `s` and `x ∈ X s`, `x ∈ sat Φ X s` (witness `x`, using reflexivity of
>    `Φ s`).
>
> 2. `sat_monotone Φ {X Y} (h : Subset X Y) : Subset (sat Φ X) (sat Φ Y)`.
>    If `X ⊆ Y`, then `sat Φ X ⊆ sat Φ Y` sortwise. (Hypothesis `h`; conclusion
>    assumed using the same witness and transitivity of the relation.)
>
> 3. `sat_idem Φ X : sat Φ (sat Φ X) = sat Φ X`.
>    Saturation is idempotent as a many-sorted subset (full equality, not just
>    inclusion): one inclusion uses `trans` of `Φ s`, the other uses `refl`.
>
> 4. `sat_isClosureOperator Φ : IsClosureOperator (sat Φ)`.
>    The triple of extensivity (1), monotonicity (2), and idempotence (3) packaged
>    under `IsClosureOperator`. So `sat Φ` is a closure operator on `Sub A`.
>
> 5. `sat_iUnion Φ {ι} (X : ι → Sub A) :
>      sat Φ (fun s => ⋃ i, X i s) = fun s => ⋃ i, sat Φ (X i) s`.
>    For every `ι : Type u` (same universe as `S`) and family `X i`, saturation
>    commutes exactly with the `ι`-indexed sortwise union. (Both inclusions:
>    a witness pair for the union redistributes; conversely an index is retained.)
>
> 6. `sat_isCompletelyAdditive Φ : IsCompletelyAdditive (sat Φ)`.
>    Immediate instance of (5): `sat Φ` distributes over all sortwise unions.
>
> 7. `sat_isAlgebraic Φ : IsAlgebraic (sat Φ)`.
>    Given `X`, `s`, `a` with `a ∈ sat Φ X s`, i.e. a witness `x ∈ X s` with
>    `Φ s x a`: take `F` to be the many-sorted subset equal to `{x}` at sort `s`
>    and `∅` at all other sorts (`Function.update`). Then `F ⊆ X`, every `F t` is
>    finite (singleton at `s`, empty elsewhere), and `a ∈ sat Φ F s` since
>    `x ∈ F s` and `Φ s x a`.
>
> 8. `sat_iInter_subset Φ {ι} (X : ι → Sub A) :
>      Subset (sat Φ (fun s => ⋂ i, X i s)) (fun s => ⋂ i, sat Φ (X i) s)`.
>    Saturation of a sortwise intersection is contained in the sortwise
>    intersection of the saturations (one inclusion only; the converse is not
>    asserted). Same witness `x` with `x ∈ ⋂ i, X i s` works for every `i`.
>
> 9. `sat_univ Φ : sat Φ (fun _ => (Set.univ : Set (A _))) = fun _ => Set.univ`.
>    Saturating the "full" many-sorted subset (all carriers) yields the full one;
>    every `a` is witnessed by itself via reflexivity.
>
> 10. `sat_compl Φ {X} (hX : IsSat Φ X) : IsSat Φ (complA X)`.
>     Hypothesis: `X` is saturated (`sat Φ X = X`). Conclusion: the sortwise
>     complement `complA X` is saturated. Proof: if `a` is `Φ`-related to some
>     `x ∉ X s`, then `a ∉ X s` (else, using `hX`, `x` would be in `X s`,
>     contradiction); conversely each `a ∉ X s` is in the saturation of the
>     complement via itself.
>
> 11. `suppSub_sat Φ X : suppSub (sat Φ X) = suppSub X`.
>     Saturating `X` leaves its support (the set of sorts at which `X` is
>     nonempty) unchanged: the forward inclusion forgets the witness, the backward
>     one uses `refl`.
>
> 12. `sat_uniform Φ {X Y} (h : suppSub X = suppSub Y) :
>       suppSub (sat Φ X) = suppSub (sat Φ Y)`.
>     If two many-sorted subsets have the same support, so do their saturations;
>     immediate from (11) and `h`.
>
> 13. `satSets_fix Φ : satSets Φ = {X : Sub A | sat Φ X = X}`.
>     The set of saturated subobjects equals the set of fixed points of `sat Φ`;
>     proved by `rfl`, i.e. the two sides are definitionally the same.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P005 — verdict
>
> ## Clause-by-clause comparison
>
> Contract: Proposition `SatOperator`. Setup: `A` an `S`-sorted set, `Φ ∈ Eqv(A)`,
> `[·]^Φ : Sub(A) → Sub(A)`.
>
> | # | Contract clause | Lean counterpart | Match |
> |---|---|---|---|
> | C1 | `[·]^Φ` is a **completely additive closure operator** on `A` | `sat_isClosureOperator` (extensivity `sat_extensive`, monotonicity `sat_monotone`, idempotence `sat_idem`) + `sat_isCompletelyAdditive` (via `sat_iUnion`) | yes |
> | C2 | for every **nonempty** `I ∈ U` and `I`-indexed `(X^i)`: `[∩_i X^i]^Φ ⊆ ∩_i [X^i]^Φ` | `sat_iInter_subset : Subset (sat Φ (fun s => ⋂ i, X i s)) (fun s => ⋂ i, sat Φ (X i) s)` — but quantified over **all** `ι : Type u`, with **no `Nonempty` hypothesis** | yes, but generalized |
> | C3 | `[A]^Φ = A` (stated "obviously") | `sat_univ` | yes |
> | C4 | if `X = [X]^Φ` then `∁_A X = [∁_A X]^Φ` | `sat_compl (hX : IsSat Φ X) : IsSat Φ (complA X)` | yes |
> | C5 | `[·]^Φ` is **uniform**: `supp_S(X)=supp_S(Y) → supp_S([X]^Φ)=supp_S([Y]^Φ)` | `sat_uniform` (with `suppSub_sat` as the support-preservation lemma) | yes |
> | C6 | hence `[·]^Φ` is a **uniform algebraic closure operator** | `sat_isAlgebraic` + `sat_isClosureOperator` + `sat_uniform` | yes |
> | C7 | `Φ-Sat(A) = Fix([·]^Φ)` | `satSets_fix` | yes |
>
> Every clause has a counterpart, and the only formal difference is that C2's
> nonemptiness hypothesis (`I ≠ ∅` / `D.Nonempty`) is absent on the Lean side:
> `sat_iInter_subset` is asserted for an arbitrary index type `ι`, so it covers the
> empty-index case as well. The empty case is trivially true (both sides reduce to
> the full subobject by `sat_univ`), so the Lean statement is a genuine, though
> harmless, generalization of the contract clause. No contract clause is missing,
> and no clause contradicts Lean.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: formal_stronger
>
> Justification: The Lean `sat_iInter_subset` drops the contract's "nonempty `I`"
> hypothesis and asserts the intersection inclusion for arbitrary index types,
> i.e. it generalizes the stated contract clause.

## Note

Nothing in the block changed; `IsClosureOperator`/`IsAlgebraic` moved to their own blocks (C5), and the re-audit re-flagged the existing nonempty-index generalization.

