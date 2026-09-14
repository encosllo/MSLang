# Correspondence audit transcript -- `B-C001` (`IncSat`)

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.sat_antitone` (`lean/Mslang/Pilot.lean`)
- **Contract:** Corollary `B-C001`, `\label{IncSat}`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000004`
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> The statement reads: let `S` and `U` be fixed types, `A : S → Set U` a fixed
> sorted family of subsets of `U`; let `Φ` and `Ψ` be sorted equivalences on
> `A` (each assigning to every sort `s` an equivalence relation on `A s`).
> Hypothesis `h : sortedEqvLe Φ Ψ` means: for every sort `s` and all
> `x, y ∈ A s`, `(Φ s).r x y` implies `(Ψ s).r x y`; i.e. at each sort
> `Φ s ⊆ Ψ s` as relations.
>
> `sat Φ X` is defined sortwise by
> `(sat Φ X) s = { a ∈ A s : ∃ x ∈ X s, (Φ s).r x a }`, the closure of `X s`
> under `Φ s`. `IsSat Φ X` means `sat Φ X = X`; by reflexivity this is
> equivalent to: any `a ∈ A s` equivalent under `Φ s` to a member of `X s` lies
> in `X s`.
>
> Conclusion: for every `A`, `Φ`, `Ψ` with `Φ` refining `Ψ`, and every family
> `X` of subsets `X s ⊆ A s`, if `X` is `Ψ`-saturated then `X` is
> `Φ`-saturated. All quantifiers universal; the only existential is the
> witness `∃ x ∈ X s` inside `sat`. The name `sat_antitone` matches: since
> `Φ s ⊆ Ψ s`, finer relations give smaller closures.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> - Direction of refinement: `sortedEqvLe Φ Ψ` is `Φ_s ⊆ Ψ_s`, matching the
>   contract's `Φ ⊆ Ψ`; conclusion `IsSat Ψ X → IsSat Φ X` matches
>   `Ψ-Sat(A) ⊆ Φ-Sat(A)`.
> - Saturation: `sat Φ X s = { a : ∃ x ∈ X_s, (Φ_s).r x a }` is exactly the
>   sortwise union `⋃_{x∈X_s} [x]_{Φ_s}`; `IsSat Φ X := sat Φ X = X` matches
>   `X = [X]^Φ` extensionally.
> - Quantification and objects: both universally quantify over `A`, `Φ`, `Ψ`,
>   and `X`; no hidden quantifier or extra hypothesis.
> - Degenerate cases: empty sorts, empty `X`, and empty `S` all make both
>   `IsSat`s vacuously true; no case breaks the equivalence.
> - No vacuity or added/dropped strength.
>
> Justification: the Lean statement is a pointwise, definitional restatement of
> `Φ ⊆ Ψ ⟹ (X = [X]^Ψ ⟹ X = [X]^Φ)`, literally `Ψ-Sat(A) ⊆ Φ-Sat(A)`.

## Residual note

The correspondence is `equivalent` **relative to the pilot encoding**
(`representation/pilot-encoding.md`, audited `faithful-with-caveat` in
`E-000002`, residuals D1/D2/D4). In particular the fixed-ambient carrier model
(D2) and the `Setoid`-vs-relation choice (D4) are inherited by this verdict; a
representation change (class C6) stales it.
