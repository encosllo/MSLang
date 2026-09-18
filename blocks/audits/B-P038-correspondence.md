# Correspondence audit transcript -- `B-P038`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.langCongFormationOf`,
  `Mslang.langCongFormationOf_nabla`, `_up`, `_inf`, `_ker`,
  `Mslang.langCongFormationOf_isFiniteIndexCongruenceFormation`
  (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P038` (`Lang2CongEnFinit`).
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `hL : IsRegularLanguageFormation Sig L` says `L` is a formation of regular
> languages: every `X ∈ L A` is regular, every `∇`-saturated `X` is in `L A`,
> `L` is closed under saturation by `Ω(X) ∩ Ω(Y)`, and closed under
> `Ker(pr^{Ω(M)} ∘ f)`-saturation along `Ω(M)`-epimorphisms.
>
> `langCongFormationOf Sig L A = {Φ | Φ ∈ Cgr_fi(T_Σ(A)) and every
> Φ-saturated N ⊆ T_Σ(A) lies in L A}`. The final theorem concludes
> `IsFiniteIndexCongruenceFormation Sig (langCongFormationOf Sig L)`: the four
> congruence-formation clauses (nonempty via `nabla`, members are congruences,
> meet-closure, up-closure among congruences) plus membership in
> `Cgr_fi(T_Σ(A))`. `[Finite S]` is used only for the `nabla` nonemptiness
> clause.
>
> Explicitly not claimed: no converse/bijection; no claim that every
> finite-index congruence formation arises this way; no minimality or
> completeness of the closure hypotheses; no union/complement closure of `L`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> `[Finite S]` is exactly the section's standing assumption B-A001 ("in the
> remainder of this section we require S to be finite"; equivalent to the
> support-finiteness remark preceding it), so it is part of the contract, not an
> added hypothesis. The hypothesis is clause-for-clause B-D045, the defined
> family is exactly `F_L(A) = {Φ ∈ Cgr_fi(T_Σ(A)) | Φ-Sat(T_Σ(A)) ⊆ L(A)}`, and
> the conclusion is exactly B-D041 plus `G(A) ⊆ Cgr_fi(T_Σ(A))`. Nothing is
> added, dropped, weakened, or reversed. (The first comparator pass, shown the
> bare proposition without the section's standing assumption, classified
> `formal_weaker` on account of `[Finite S]`; this was an omission in the audit
> prompt, not a divergence in the formalization, and is superseded by the
> reading above.)

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
