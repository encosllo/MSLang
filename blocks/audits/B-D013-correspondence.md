# Correspondence audit transcript -- `B-D013`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsUniform`, `Mslang.IsUniformAlgebraicClosureOperator` (`lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D013`, section "Preliminaries.".
- **Outcome:** `formal_weaker`
- **Recorded as:** `E-000339`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D013 read-back
>
> Fix `S : Type u`. Every notion here concerns a candidate closure operator `c : Sub A → Sub A` on sub-objects of a sorted set `A`.
>
> - `SSet (S) : Type (u+1)` — abbreviation `S → Type u`.
> - `Sub {S} (A : SSet S) : Type u` — abbreviation `∀ s, Set (A s)`.
> - `Subset {S} {A} (X Y : Sub A) : Prop` — definitionally `∀ s, X s ⊆ Y s` (sortwise inclusion).
>
> - `IsUniform {S} {A} (c : Sub A → Sub A) : Prop` — definitionally
>   `∀ X Y : Sub A, suppSub X = suppSub Y → suppSub (c X) = suppSub (c Y)`.
>   `c` is **uniform** iff it respects equality of supports: whenever two sub-objects `X, Y` have the same support (under `suppSub`, which is *not defined in this file*), their images `c X, c Y` have the same support. I.e. the support of `c X` depends only on the support of `X`. (Quantifier scope: for all `X, Y`, if `suppSub X = suppSub Y` then `suppSub (c X) = suppSub (c Y)`.)
>
> - `IsAlgebraic {S} {A} (c : Sub A → Sub A) : Prop` — definitionally
>   `∀ (X : Sub A) (s : S) (a : A s), a ∈ c X s → ∃ F : Sub A, Subset F X ∧ (∀ t, (F t).Finite) ∧ a ∈ c F s`.
>   `c` is **algebraic** iff every element `a` of sort `s` that lies in `c X s` is already captured by some *finite sub-object* `F ⊆ X`: for every `X`, every sort `s`, and every `a ∈ c X s`, there exists `F` with `F ⊆ X` sortwise, `F t` finite at every sort `t`, and `a ∈ c F s`. (Note: the finiteness requirement is at *all* sorts `t`, not only at `s`.)
>
> - `IsUniformAlgebraicClosureOperator {S} {A} (c : Sub A → Sub A) : Prop` — definitionally `IsAlgebraic c ∧ IsUniform c`. `c` is a uniform algebraic closure operator iff it is both algebraic and uniform. (The "closure operator" axioms — extensivity, monotonicity, idempotence — are **not** part of this predicate; only algebraicity and uniformity are bundled.)
>
> No theorems. `suppSub` is referenced but not defined in this file.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D013 verdict
>
> Contract clause — uniform operator: `J` on `Sub(A)` is uniform if for all `X, Y ⊆ A`, `supp(X) = supp(Y) ⇒ supp(J(X)) = supp(J(Y))`.
>
> - Lean `IsUniform c := ∀ X Y, suppSub X = suppSub Y → suppSub (c X) = suppSub (c Y)`. ✓
>
> Contract clause — uniform algebraic `S`-closure operator: `J` is a uniform algebraic `S`-closure operator if `J` is an algebraic `S`-closure operator and `J` is uniform. "Algebraic `S`-closure operator" (from the ambient definition) includes the closure-operator axioms (extensivity, isotonicity, idempotence) plus algebraicity.
>
> - Lean `IsUniformAlgebraicClosureOperator c := IsAlgebraic c ∧ IsUniform c`, where `IsAlgebraic c := ∀ X s a, a ∈ c X s → ∃ F, Subset F X ∧ (∀ t, (F t).Finite) ∧ a ∈ c F s`. ✓ for the finite-approximation (algebraicity) and uniformity parts.
> - However the read-back explicitly notes the closure-operator axioms (extensivity, monotonicity, idempotence) are **not** part of the predicate. Hence the contract's requirement that `J` be a *closure operator* is dropped.
>
> Contract clauses with no Lean counterpart: the closure-operator axioms (extensivity, isotonicity, idempotence) required by "algebraic `S`-closure operator"; also `suppSub` is only referenced, not defined here.
> Verdict: formal_weaker — uniformity and the finitary approximation are captured, but the bundled predicate omits the closure-operator axioms that the contract's "algebraic `S`-closure operator" demands.

