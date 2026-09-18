# Correspondence audit transcript -- `B-P015`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.algebraFormationOfCongruenceFormation`,
  `..._nonempty`, `..._abstract`, `..._HOperator`, `..._PFsdOperator`
  (`lean/Mslang/Formation.lean`)
- **Contract:** Proposition `B-P015`, the four properties of `F_𝔉`.
- **Outcome:** `formal_stronger` (abstractness is proved for arbitrary `G`).
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`;
  `T_Σ(A)` is the inductive `Term Sig A`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `algebraFormationOfCongruenceFormation Sig G` is the class of `Σ`-algebras `C`
> admitting a sorted set `A`, a congruence `Φ ∈ G(A)` on `T_Σ(A)`, and a
> sortwise-bijective homomorphism `C ≅ T_Σ(A)/Φ` — the isomorphism-closure of the
> quotients of free algebras by `G`-admitted congruences.
>
> - `_nonempty`: for a congruence formation `G`, `F_𝔉` is non-empty, witnessed by
>   `T_Σ(1)/∇` (`∇ ∈ G(1)` by up-closure).
> - `_abstract`: if `C ∈ F_𝔉` and `D ≅ C`, then `D ∈ F_𝔉` (compose with the
>   isomorphism). **Stated for arbitrary `G`** (no formation hypothesis).
> - `_HOperator`: for a congruence formation `G`, `HOperator(F_𝔉) ⊆ F_𝔉`.
> - `_PFsdOperator`: for a congruence formation `G`, `PFsdOperator(F_𝔉) ⊆ F_𝔉`.
>
> Explicitly not claimed: no closure under infinite products, subalgebras, limits,
> or any variety/HSP statement; `H`/`P_fsd` are inclusions, not equalities; no
> canonical/uniqueness of the witnessing `A`, `Φ`, or isomorphisms; the formation
> clause concerns free-algebra homomorphisms only.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `formal_stronger`.**
>
> The defined set matches the contract exactly, and properties (1), (3), (4) match
> under the `IsCongruenceFormation` hypothesis as inclusions. Property (2) is
> proved for *arbitrary* `G`, whereas the contract states it for a formation;
> since a formation is a special case, the formal statement specializes to the
> contract's (2), but it is a strict generalization (adds no hypothesis, removes
> none, changes no conclusion). Nothing extra or missing otherwise. Hence the
> formalization is strictly stronger than the contract.

## Residual note

The correspondence is `formal_stronger` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
This is a *positive* typed divergence, recorded rather than folded into
`equivalent` (the same shape as `B-P005` and `B-P026`).
