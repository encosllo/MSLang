# Correspondence audit transcript -- `B-R012` (cross-model, mixed)

Protocol: Architecture.md Section 11.2, two-stage blind, per the cross-model
audit brief's Tier 4 and Section 6 ingestion pattern. Stage 1 reuses the
existing `deepseek-v4.1-flash` read-back (from
`blocks/audits/B-R012-correspondence.md`, the Session-119 re-read with
definition bodies included). Stage 2 is a fresh, isolated `claude-sonnet-5`
agent given the stage-1 read-back and the full manuscript contract text --
no repo access, no expected answer, explicitly asked to go clause by clause.

- **Lean declarations:** `Mslang.nabla_isCongruence`,
  `Mslang.quot_nabla_subfinal` (`lean/Mslang/Subfinal.lean`)
- **Contract:** Remark `B-R012`, section "Preliminaries" -- full text (the
  general subfinality sentence, the single-sorted worked example, the
  many-sorted worked example, the intermediate-support existence claim, and
  the refined "neither `∅^S` nor `1`" corollary).
- **Outcome:** `formal_weaker` -- confirmed.
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** stage 1 ran on `deepseek-v4.1-flash`, stage 2 on
  `claude-sonnet-5` -- distinct model families.

## Stage 1 -- read-back (reused from the deepseek-v4.1-flash transcript, Lean only)

> `nabla_isCongruence Sig F : IsCongruence Sig F (nabla A)` -- for arbitrary
> `Sig`, `A`, `F`, the universal sorted equivalence is a congruence.
> `quot_nabla_subfinal Sig F` -- the quotient algebra `quotAlg Sig F (nabla
> A) (...)` is `SubfinalAlg Sig ...`, i.e. isomorphic to a subalgebra of the
> terminal algebra. Both hypothesis-free apart from `Sig`, `A`, `F`. No Lean
> declaration anywhere states a single-sorted empty-algebra example, a
> many-sorted `card(S) ≥ 2` example, an enumeration of `Sub(1) = {∅, 1}`, or
> an intermediate-support existence claim.

## Stage 2 -- comparison (fresh agent, claude-sonnet-5, read-back + full contract, clause by clause)

> **VERDICT: formal_weaker**
>
> Clause 1 (general: `A/∇^A` is isomorphic to a subalgebra of `1`) -- matched
> exactly by `nabla_isCongruence` + `quot_nabla_subfinal`, for arbitrary
> `Sig`/`A`/`F` with no restriction on `S`, `card(S)`, or the signature.
> Equivalent in isolation.
>
> Clause 2 (single-sorted `∅` example, plus `Sub(1) = {∅,1}` enumeration) --
> no Lean counterpart.
>
> Clause 3 (many-sorted `card(S)≥2`, no-nullary-operations example) -- no
> Lean counterpart.
>
> Clause 4 (existence of `A` with `∅ ⊂ supp_S(A) ⊂ S`) -- no Lean
> counterpart; a genuine additional existence claim.
>
> Clause 5 (refined corollary: quotient lands in `Sub(1) − {∅^S, 1}`) -- no
> direct Lean counterpart; depends on the un-formalized clause 4.
>
> Summary: the general opening theorem matches Lean one-to-one; the
> remaining four of five clauses (two worked examples, an existence claim,
> and a refinement corollary) have no Lean declaration anywhere in the file
> or its dependencies. `formal_weaker`.

## Coordinator note

Re-confirms the existing same-model verdict (`E-000327`, supersedes
`E-000107`). The fresh cross-model reader independently reached the exact
same clause-by-clause breakdown (1 covered, 2-5 uncovered).
