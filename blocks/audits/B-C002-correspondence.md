# Correspondence audit transcript -- `B-C002`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.sat_inf` (`lean/Mslang/Pilot.lean`)
- **Contract:** Corollary `B-C002`
- **Outcome:** `equivalent`
- **Recorded as:** `E-000042`
- **Encoding:** dependent-type carrier model (`representation/pilot-encoding.md`);
  re-run after the Session 29 representation change.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Fix a type `S` of sorts. An `S`-sorted set `A` assigns a type `A s` to each
> sort `s`; a componentwise subset `X` assigns a set `X s ⊆ A s` per sort; a
> sorted equivalence `Φ` assigns a setoid on `A s` per sort. Saturation
> `sat Φ X` is the family whose `s`-component collects every `a : A s` that is
> `Φ s`-equivalent to some element of `X s`; `IsSat Φ X` means `sat Φ X = X`.
> The theorem `sat_inf` states, for arbitrary `Φ`, `Ψ`, `X`: if `X` is
> `Φ`-saturated **and** `X` is `Ψ`-saturated, **then** `X` is saturated under
> the meet `sortedEqvInf Φ Ψ`. This is one-directional (not an equivalence). The
> meet `sortedEqvInf Φ Ψ` relates `x, y` iff both `x ∼_Φ y` and `x ∼_Ψ y`
> (componentwise intersection). The second hypothesis is unused in the proof;
> saturation under `Φ` alone already suffices, since the meet-relation implies
> the `Φ`-relation. Degenerate cases: empty `S` makes everything vacuous; an
> empty `X s` contributes trivially.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> The theorem's statement matches the contract exactly: for arbitrary `S`-sorted
> `A`, `Φ`, `Ψ`, and componentwise subset `X`, if `X` is `Φ`-saturated and `X`
> is `Ψ`-saturated then `X` is saturated under the meet `Φ ∩ Ψ`. Quantifier
> domains agree (all `Φ`, `Ψ`, `X`), the meet is componentwise intersection
> (`x ∼_Φ y ∧ x ∼_Ψ y`), and saturation is defined precisely as `sat Φ X = X`.
> The relation is one-directional, matching the `⊆` contract.
>
> The remark that the second hypothesis is unused is a proof-level observation,
> not a change to the theorem's content: the stated proposition still assumes
> both hypotheses, so it is neither stronger nor weaker than the contract.
> Degenerate cases (empty `S` vacuous, empty `X s` trivial) are handled
> symmetrically, with no direction or domain mismatch.

## Residual note

Inherits the pilot encoding's residuals (see `E-000040`); a representation change
(class C6) stales this verdict.
