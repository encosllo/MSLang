# Correspondence audit transcript -- `B-R006`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.sat_eq_preimage`, `Mslang.isSat_iff_preimage`
  (`lean/Mslang/Pilot.lean`)
- **Contract:** Remark `B-R006`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000046`
- **Encoding:** dependent-type carrier model (`representation/pilot-encoding.md`);
  re-run after the Session 29 representation change.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Sorts are given by a type `S`; `A` assigns a type `A s` per sort; `Φ` assigns a
> setoid on each `A s`; `Sub A` assigns a subset per sort;
> `sat Φ X s = {a | ∃ x ∈ X s, (Φ s).r x a}`; `IsSat Φ X` holds iff
> `X = sat Φ X`. The projection `pr Φ s` is the quotient map sending
> `x : A s` to its equivalence class in `Quotient (Φ s)`.
>
> Theorem `sat_eq_preimage`: for every `Φ` and `X` (no saturation hypothesis),
> `sat Φ X = fun s => (pr Φ s) ⁻¹' ((pr Φ s) '' X s)`: the saturation of `X` is
> the componentwise inverse image under the quotient projection of the direct
> image of `X`. Theorem `isSat_iff_preimage`: for every `Φ` and `X`, `IsSat Φ X`
> if and only if there exists a family `Y` of subsets of the quotient types (one
> per sort) such that `X = fun s => (pr Φ s) ⁻¹' (Y s)`. The forward direction
> takes `Y` to be the direct images of `X`. Degenerate cases: if `A s` is empty,
> only the empty subset exists, `IsSat` holds trivially, and the only `Y s` is
> empty.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> **Direction of implications.** `sat_eq_preimage` is stated for arbitrary `Φ`,
> `X` with no saturation hypothesis, exactly as the contract's definitional
> identity `[X]^Φ = (pr^Φ)^{-1}[pr^Φ[X]]`; the Lean `sat`
> (`{a | ∃ x ∈ X s, (Φ s).r x a}`) is equivalent to that inverse image, since
> for a setoid `pr(x) = pr(a) ⟺ (Φ s).r x a`. The contract's `⊇`-criterion
> matches Lean's equality criterion: by reflexivity `X ⊆ sat Φ X` always holds,
> so `X = sat Φ X ⟺ X ⊇ sat Φ X`, i.e. the two `IsSat` predicates define the
> same class of subsets.
>
> **Quantifier domains** coincide: `S`-sorted `A` and `Φ`, `X` a per-sort
> subset, `Y` a per-sort family of subsets of the quotient types; both identities
> are componentwise and universally quantified over `Φ` and `X` (and the iff over
> `Y`), with the forward direction taking `Y_s = (pr Φ s)'' X s`, as the contract
> prescribes. No extra hypothesis is smuggled in, and neither statement omits a
> direction of the iff.
>
> **Degenerate cases** agree: when `A_s` is empty, `X_s` is necessarily `∅`,
> `sat Φ X_s = ∅`, `IsSat` holds trivially, and the only admissible `Y_s` is
> `∅`. Hence the read-back is neither stronger nor weaker than the contract.

## Residual note

`R-quotient` is encoded via `Quotient (Φ s)` (a type, not a family of subsets);
this is a genuine fixed point of the dependent-type carrier. Inherits the pilot
encoding's residuals (see `E-000040`); a representation change (class C6) stales
this verdict.
