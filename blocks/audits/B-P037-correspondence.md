# Correspondence audit transcript -- `B-P037`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.langFormationOf_isRegularLanguageFormation`
  (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P037` (`Cong2LangEnFinit`).
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `hG : IsFiniteIndexCongruenceFormation Sig G` says `G` is a congruence
> formation and every `G(A)` consists of finite-index congruences.
> `langFormationOf Sig G A = {L | Ω(L) ∈ G A}`. The theorem concludes
> `IsRegularLanguageFormation Sig (langFormationOf Sig G)`: the regularity clause
> is `hG.2` (`Ω(L)` finite index), and the `∇`/meet/kernel-saturation clauses are
> `B-P030`'s `langFormationOf_nabla`/`_inf`/`_ker` under `hG.1`.
>
> Explicitly not claimed: no converse/bijection; only the inclusion
> `L_𝔉(A) ⊆ Lang_r`; no nonemptiness; no characterization of the closures.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The hypothesis is exactly "formation of finite-index congruences" (no extra,
> none missing); the conclusion is exactly "`L_𝔉` is a formation of regular
> languages" with all four clauses (`L(A) ⊆ Lang_r`, `∇`-, meet-, and
> kernel-saturation). The proof composes `B-P030` legitimately: `hG.1` supplies
> the congruence-formation input for the closure fields, `hG.2` the regularity
> field; nothing is strengthened or dropped.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
