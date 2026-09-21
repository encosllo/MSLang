# Correspondence audit transcript -- `B-D040`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsFiniteIndex`, `Mslang.congFi` (`lean/Mslang/Regular.lean`)
- **Contract:** Definition `B-D040`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000364`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D040 — read-back
>
> Fixed data: a sort type `S`; a many-sorted carrier is a type family
> `SSet S := S → Type u` (each sort `s : S` gets a type `A s`). A signature is
> `Signature S := (List S × S) → Type u`: an operation symbol is indexed by a pair
> `p = (w, s)` with `w` the list of input sorts and `s` the output sort.
>
> ## Definitions
>
> - `wordProd A w := (i : Fin w.length) → A (w.get i)`. The product of the
>   carriers along the arity list `w`: an argument tuple assigning to each position
>   `i < |w|` a value of sort `w.get i`.
> - `finOp A w s := wordProd A w → A s`. An `|w|`-ary operation from the `w`-indexed
>   product into sort `s`, i.e. operation type for an arity `(w, s)`.
> - `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`. An algebra
>   structure on `A`: for every arity `p = (w, s)` and every symbol `σ : Sig p`, a
>   function `A^{w} → A s`.
> - `SortedEqv A := ∀ s, Setoid (A s)`. A sortwise family of equivalence relations
>   (a "sorted equivalence"); at each `s`, a setoid on `A s`.
> - `quot Φ := fun s => Quotient (Φ s)`. The sortwise quotient carrier.
> - `FiniteSSet A := Finite (Sigma A)`. `A` is finite iff the disjoint sum
>   `Σ s, A s` of all carriers is a finite type (all sorts finite, and only finitely
>   many nonempty sorts).
> - `IsFiniteIndex Φ := FiniteSSet (quot Φ)`. The sorted equivalence `Φ` has finite
>   index iff the sortwise quotient carrier `quot Φ` is finite (finitely many
>   classes in total).
> - `IsCongruence Sig F Φ`, for `F : AlgStruct Sig A` and `Φ : SortedEqv A`:
>   for every arity `p = (w, s)`, symbol `σ : Sig p`, and tuples
>   `a b : wordProd A p.1`, if `(Φ (w.get i)).r (a i) (b i)` holds **for all**
>   positions `i`, then `(Φ s).r (F p σ a) (F p σ b)` holds. I.e. each operation is
>   compatible with `Φ` in every argument: `Φ` is a congruence of the algebra.
>   (Quantifier order: `∀ p σ a b, (∀ i, …) → …`.)
> - `congFi Sig F := {Φ | IsCongruence Sig F Φ ∧ IsFiniteIndex Φ}`. The set of
>   finite-index congruences of the algebra `(A, F)`.
>
> ## Theorems
>
> None (this file contains only definitions).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D040 — verdict
>
> Contract: `A` a Σ-algebra, `Φ ∈ Cgr(A)`; `Φ` of finite index iff `A/Φ` is a
> finite S-sorted set; `Cgr_fi(A)` the set of all finite-index congruences.
>
> ## Clause-by-clause
>
> - "Let A be a Σ-algebra" — Lean: `SSet S`, `Signature S`, `AlgStruct Sig A`
>   (carrier + operations). Present.
> - "Φ ∈ Cgr(A)" — Lean: `IsCongruence Sig F Φ` for `F : AlgStruct Sig A`,
>   `Φ : SortedEqv A`. Present.
> - "A/Φ" — Lean: `quot Φ := fun s => Quotient (Φ s)`. Present.
> - "A/Φ is finite" — Lean: `FiniteSSet (quot Φ) := Finite (Sigma (quot Φ))`;
>   `IsFiniteIndex Φ`. Present.
> - "Cgr_fi(A)" — Lean: `congFi Sig F := {Φ | IsCongruence Sig F Φ ∧ IsFiniteIndex Φ}`.
>   Present.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — every clause of the definition (algebra, congruence,
> sortwise quotient, finiteness of the quotient, and the set of finite-index
> congruences) has a matching Lean definition.

