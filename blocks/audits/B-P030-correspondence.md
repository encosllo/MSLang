# Correspondence audit transcript -- `B-P030`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.langFormationOf`,
  `Mslang.mem_langFormationOf_iff`, `Mslang.langFormationOf_nabla`,
  `Mslang.langFormationOf_inf`, `Mslang.langFormationOf_ker`
  (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P030` (`Cong2LangBasic`).
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `langFormationOf Sig G A = {L | Ω^{T_Σ(A)}(L) ∈ G A}`; `mem_langFormationOf_iff`
> rewrites this as "`L` is `Φ`-saturated for some `Φ ∈ G A`" (the contract's
> second presentation). `langFormationOf_nabla`: every `∇`-saturated `L` lies in
> the family. `langFormationOf_inf`: if `L, L' ∈ L_𝔉(A)`, any `N` saturated by the
> pointwise meet `Ω(L) ⊓ Ω(L')` lies in the family. `langFormationOf_ker`: if
> `M ∈ L_𝔉(B)` and `f : T_Σ(A) → T_Σ(B)` is a hom whose composite with the
> quotient projection `π_M` is surjective at each sort, any `N` saturated by
> `Ker(π_M ∘ f)` lies in `L_𝔉(A)`.
>
> Explicitly not claimed: no converse/correspondence/bijection, no existence of
> `G`; the meet result is about `(Ω(L) ∩ Ω(L'))`-saturated languages, not closure
> under union/complement/intersection; the `ker` clause is conditional on the
> surjectivity; no finiteness or regularity.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> Both contract presentations of `L_𝔉(A)` are present and equated
> (`Ω(L) ∈ 𝔉(A)` and `∃ Φ ∈ 𝔉(A), L = [L]^Φ`). Condition (1) is exactly
> `∇-Sat ⊆ L_𝔉(A)`; the parenthetical that `∅` and `T_Σ(A)` are languages is
> derivable (they are the only `∇`-saturated languages). Condition (2) matches
> the pointwise meet. Condition (3) matches `Ker(pr^{Ω(M)} ∘ f)` under the
> surjectivity hypothesis. No finite-index/regularity assumption is added.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
