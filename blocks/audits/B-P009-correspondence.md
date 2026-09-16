# Correspondence audit transcript -- `B-P009`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsCongruence`, `Mslang.quotAlg`,
  `Mslang.prAlg`, `Mslang.quotOp_mk`, `Mslang.isAlgHom_prAlg`,
  `Mslang.ker_isCongruence`, `Mslang.ker_prAlg`,
  `Mslang.quotAlgLift_isAlgHom`, `Mslang.quotAlgLift_comp`,
  `Mslang.quotAlgLift_unique` (`lean/Mslang/Pilot.lean`)
- **Contract:** Proposition `B-P009`, section "Preliminaries".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000073`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> **Structures.** `S` is a type of sorts; a sorted set `A` assigns a type `A s`
> to each sort. A sorted equivalence `Φ` is a family of equivalence relations.
> `Φ ⊆ Ψ` (`sortedEqvLe Φ Ψ`) means Φ refines Ψ. `A/Φ` is the family of
> quotient types `Quotient (Φ s)` and `pr Φ : A → A/Φ` is the projection. The
> kernel `ker f` of `f : A → B` relates `x,y` iff `f s x = f s y`.
>
> **Algebras.** A signature `Σ : (List S × S) → Type` assigns operation symbols
> to an arity word and a coarity sort; `wordProd A w` is the product of
> components along `w`; a structure `F` interprets each `σ : Σ (w,s)` as
> `F_σ : wordProd A w → A s`. `IsAlgHom F G f` is the homomorphism equation
> `f_s(F_σ(a)) = G_σ(f_w(a))`.
>
> **`IsCongruence Sig F Φ`.** Φ is compatible with every operation: if
> `a i ~_{Φ} b i` for all `i` then `F_σ(a) ~_{Φ} F_σ(b)`.
>
> **`quotAlg` / `prAlg` / `quotOp_mk` / `isAlgHom_prAlg`.** `quotAlg Sig F Φ hΦ`
> is the quotient algebra: carrier `A/Φ`, operations induced from `F`.
> `prAlg` is the projection `A → A/Φ`. `quotOp_mk` records the induced operation
> on representatives: `F_{A/Φ,σ}([a_i]) = [F_σ(a)]`. `isAlgHom_prAlg` states
> that `prAlg` is a homomorphism from `(A,F)` to the quotient algebra.
>
> **`ker_isCongruence`.** If `f : A → B` is a homomorphism from `(A,F)` to
> `(B,G)`, then `ker f` is a congruence on `(A,F)`.
>
> **`ker_prAlg`.** For a congruence Φ on `(A,F)`, `ker(prAlg) = Φ`.
>
> **`quotAlgLift_isAlgHom` / `_comp` / `_unique`.** If `f : A → B` is a
> homomorphism and `Φ ⊆ ker f`, the canonical lift `p^{Φ,ker f} : A/Φ → B` is a
> homomorphism (`quotAlgLift_isAlgHom`), satisfies `p^{Φ,ker f} ∘ pr^Φ = f`
> (`quotAlgLift_comp`), and is unique: any sorted map `p : A/Φ → B` with
> `p ∘ pr^Φ = f` equals it (`quotAlgLift_unique`; uniqueness is stated for all
> sorted maps, hence a fortiori for homomorphisms).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> Clause by clause: `ker_isCongruence` yields `Ker(f) ∈ Cgr(A)` from `f` a
> homomorphism. `quotAlg` + `quotOp_mk` give the induced operations and
> `isAlgHom_prAlg` shows `pr^Φ` is a homomorphism (contract's parenthetical).
> `ker_prAlg` is `Ker(pr^Φ) = Φ` (clause 1). Existence is
> `quotAlgLift_isAlgHom` under `Φ ⊆ Ker(f)`; the factorization identity is
> `quotAlgLift_comp`; uniqueness is `quotAlgLift_unique`. The only divergence is
> that uniqueness is stated for arbitrary sorted maps rather than only
> homomorphisms -- a harmless strengthening the contract already entails (since
> `pr^Φ` is surjective it forces the same value pointwise), so it adds no
> mathematical content. Same direction, hypotheses, and quantifiers throughout.
> No missing case, no vacuity or unintended convention.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
