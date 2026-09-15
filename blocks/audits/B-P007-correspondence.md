# Correspondence audit transcript -- `B-P007`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.quotLift`, `Mslang.ker_pr`,
  `Mslang.quotLift_comp`, `Mslang.quotLift_unique` (`lean/Mslang/Pilot.lean`)
- **Contract:** Proposition `B-P007`, section "Preliminaries".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000058`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> **Structures.** `A`, `B` are `S`-sorted sets; `f : A → B` is a family of
> functions; `Φ : SortedEqv A` is a componentwise equivalence; `Φ` refines `Ψ`
> when every pair identified by `Φ` is identified by `Ψ`. `ker f` is the
> componentwise kernel (`x (ker f) y` iff `f s x = f s y`); `pr Φ` is the
> componentwise projection `x ↦ [x]`; `A/Φ` is the quotient sorted set.
>
> **`quotLift`.** For `h : Φ refines ker f`, `quotLift Φ f h : A/Φ → B` is the
> componentwise descent `Quotient.lift (f s) (h s)`, with
> `(quotLift Φ f h) s [x] = f s x`.
>
> **`ker_pr`.** `ker (pr Φ) = Φ`: at each sort, `[x] = [y]` iff `x (Φ s) y`.
>
> **`quotLift_comp`.** With the same hypotheses,
> `(fun s => (quotLift Φ f h) s ∘ (pr Φ) s) = f`, i.e. `p ∘ pr^Φ = f` for
> `p = quotLift Φ f h`.
>
> **`quotLift_unique`.** For any `p : A/Φ → B` with
> `(fun s => p s ∘ (pr Φ) s) = f`, one has `p = quotLift Φ f h`. So `quotLift`
> is the unique map out of the quotient whose composite with `pr^Φ` is `f`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> (a) `ker f : SortedEqv A`, with `x (ker f) y ↔ f s x = f s y`, is a bundled
> `Setoid` (relation + laws) at each sort, so `Ker(f) ∈ Eqv(A)` is established
> rather than assumed -- matches the first sentence.
> (b) `ker_pr Φ : ker (pr Φ) = Φ` says, per sort, `[x] = [y] ↔ x Φ y`, exactly
> `Ker(pr^Φ) = Φ` -- matches clause (1).
> (c) `h : sortedEqvLe Φ (ker f)` is precisely `Φ ⊆ Ker(f)`. Existence is
> `quotLift Φ f h` with `quotLift_comp` giving `f = p ∘ pr^Φ`; uniqueness is
> `quotLift_unique`. Same direction and quantifiers as clause (2).
>
> All three clauses align; differences are notational only. No extra strength,
> no missing case, no vacuity or unintended convention.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
