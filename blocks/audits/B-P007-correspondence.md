# Correspondence audit transcript -- `B-P007`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.quotLift`, `Mslang.ker_pr`, `Mslang.quotLift_comp`, `Mslang.quotLift_unique` (`lean/Mslang/Prelim.lean`)
- **Contract:** Proposition `B-P007`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000300` (supersedes `E-000094`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-P007.lean`
>
> ## Setting
>
> Fix sorts `S` and sorted sets `A, B` (families of types over `S`). A `SortedMap A B` is a family of
> functions `f s : A s → B s`, one per sort. A sorted equivalence `Φ` on `A` is a family of equivalence
> relations `Φ s` on each `A s`. `quot Φ` is the sorted set whose fiber at `s` is the quotient
> `Quotient (Φ s)`, and `pr Φ s : A s → Quotient (Φ s)` is the quotient map. For a sorted map `f`, `ker f`
> is its kernel sorted equivalence (`a`, `b` are related at `s` iff `f s a = f s b`). Finally
> `sortedEqvLe Φ Ψ` is the relation "`Φ` refines `Ψ`": whenever `a` and `b` are `Φ`-equivalent they are
> `Ψ`-equivalent (i.e. `Φ` is contained in `Ψ`).
>
> ## Definitions
>
> - **`quotLift Φ f h`** (for `f : SortedMap A B` and `h : sortedEqvLe Φ (ker f)`): the sorted map
>   `SortedMap (quot Φ) B` obtained at each sort by `Quotient.lift (f s)`, which is well defined precisely
>   because `h` says `Φ`-equivalent inputs have equal `f`-images. Informally, the map on the quotient
>   induced by `f`.
>
> ## Theorems
>
> - **`ker_pr Φ`**: `ker (pr Φ) = Φ`. The kernel of the quotient map `pr Φ` is exactly `Φ`. (At each sort,
>   two elements have the same image under `pr Φ s` iff they are `Φ s`-equivalent, i.e. `Quotient.eq`.)
>
> - **`quotLift_comp Φ f h`**: `(fun s => (quotLift Φ f h s) ∘ (pr Φ s)) = f`. The lift of `f` to the
>   quotient, composed sortwise with the projection `pr Φ`, equals `f`. I.e. `quotLift Φ f h` makes the
>   evident triangle commute: it factors `f` through `pr Φ`. (Pointwise this is
>   `Quotient.lift_mk`.)
>
> - **`quotLift_unique Φ f h p hp`** (with `p : SortedMap (quot Φ) B` and
>   `hp : (fun s => p s ∘ pr Φ s) = f`): `p = quotLift Φ f h`. Any sorted map out of the quotient whose
>   composite with `pr Φ` is `f` coincides with the lift. Hence `quotLift Φ f h` is the *unique* map making
>   the triangle commute — the universal property of the quotient.
>
> ## Declarations stated without bodies in this file
>
> `SSet`, `SortedEqv`, `SortedMap`, `ker`, `pr`, `quot`, `sortedEqvLe` are introduced as declarations here
> without bodies; the meanings are those described in the setting.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P007 verdict
>
> Contract: `Ker(f) ∈ Eqv(A)`; and for `(pr^Φ, A/Φ)`: (1) `Ker(pr^Φ) = Φ`, (2) the universal property.
>
> ## Clause-by-clause
>
> 1. **`Ker(f) ∈ Eqv(A)` for every sorted mapping `f`.** Lean: `ker` is introduced as a declaration whose codomain is `SortedEqv A` (the kernel sorted equivalence), so the clause is definitional; the read-back does not list a separate theorem but records the meaning in the setting. Match (by construction).
> 2. **`Ker(pr^Φ) = Φ`.** Lean `ker_pr Φ`: `ker (pr Φ) = Φ`, proved via `Quotient.eq` at each sort. Match.
> 3. **Universal property (existence).** For `f : A → B` with `Φ ⊆ Ker(f)`, the Lean `quotLift Φ f h` is the induced map `quot Φ → B`, and `quotLift_comp Φ f h` gives `(quotLift Φ f h) ∘ (pr Φ) = f`. `Φ ⊆ Ker(f)` is `sortedEqvLe Φ (ker f)` (Φ refines `ker f`). Match.
> 4. **Universal property (uniqueness).** `quotLift_unique Φ f h p hp`: any `p : quot Φ → B` with `p ∘ pr Φ = f` equals `quotLift Φ f h`. Match.
>
> ## Contract clauses with no Lean counterpart:
>
> The clause `Ker(f) ∈ Eqv(A)` has no separately named Lean theorem, but it is definitional because `ker` is declared with codomain `SortedEqv A`.
>
> Verdict: equivalent
> The Lean read-back establishes both the kernel identity `ker (pr Φ) = Φ` and the existence/uniqueness of the factorisation `f = quotLift ∘ pr`, and `ker` is by construction a sorted equivalence.

