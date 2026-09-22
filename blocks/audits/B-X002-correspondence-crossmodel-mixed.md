# Correspondence audit transcript -- `B-X002` (cross-model, mixed)

Protocol: Architecture.md Section 11.2, two-stage blind, per the cross-model
audit brief's Tier 4 and Section 6 ingestion pattern. Stage 1 reuses the
existing `deepseek-v4.1-flash` read-back (from
`blocks/audits/B-X002-correspondence.md`, the Session-119 re-read with
definition bodies included). Stage 2 is a fresh, isolated `claude-sonnet-5`
agent given the stage-1 read-back and the full manuscript contract text --
no repo access, no expected answer, explicitly asked to go clause by clause.

- **Lean declarations:** `Mslang.congFi_nonempty_iff`,
  `Mslang.congFi_nonempty_of_finite_sorts` (`lean/Mslang/Regular.lean`)
- **Contract:** Example `B-X002`, section "$\Sigma$-finite index congruence
  formation, $\Sigma$-regular language formation, and an Eilenberg type
  theorem for them." -- full text (the dichotomy, the finite-`S` corollary,
  and the four concrete example categories `Sgr-Act(Set)`, `Mon-Act(Set)`,
  `Grp-Act(Set)`, `Mod = CRng-Act(AbGrp)`).
- **Outcome:** `formal_weaker` -- confirmed.
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** stage 1 ran on `deepseek-v4.1-flash`, stage 2 on
  `claude-sonnet-5` -- distinct model families.

## Stage 1 -- read-back (reused from the deepseek-v4.1-flash transcript, Lean only)

> `congFi_nonempty_iff Sig A : (congFi Sig A.2).Nonempty ↔ (supp A.1).Finite`
> -- there exists a finite-index congruence of `A` iff only finitely many
> sorts of `A` are inhabited. `congFi_nonempty_of_finite_sorts Sig [Finite S]
> A : (congFi Sig A.2).Nonempty` -- if `S` is finite, every `A` has a
> finite-index congruence (an immediate corollary). No Lean declaration
> anywhere mentions the categories `Sgr-Act(Set)`, `Mon-Act(Set)`,
> `Grp-Act(Set)`, or `Mod`, nor any general "this condition holds for a
> category" bridge connecting the dichotomy to those categories.

## Stage 2 -- comparison (fresh agent, claude-sonnet-5, read-back + full contract, clause by clause)

> **VERDICT: formal_weaker**
>
> C2 (`Cgr_fi(A) ≠ ∅` iff `supp_S(A)` finite) -- exact match to
> `congFi_nonempty_iff`. Equivalent in isolation.
>
> C3 (`card(S) < ℵ₀` ⇒ `Cgr_fi(A) ≠ ∅` for every `A`) -- matches
> `congFi_nonempty_of_finite_sorts`, an immediate corollary of C2 as in the
> Lean. Equivalent in isolation.
>
> C4 (`Sgr-Act(Set)` -- left actions of semigroups on sets -- satisfies the
> dichotomy) -- no Lean counterpart. Encoding a concrete category as a
> many-sorted signature/algebra and verifying the dichotomy's hypotheses
> apply is itself mathematical content the Lean development does not
> contain.
>
> C5 (`Mon-Act(Set)`, `Grp-Act(Set)`, `Mod = CRng-Act(AbGrp)`, "defined in
> the same way") -- no Lean counterpart, same reason as C4.
>
> Summary: the quantitative core (C2, C3) is formalized exactly; the four
> concrete-instantiation clauses (C4, C5) asserting specific categories are
> correctly captured as many-sorted algebras to which the dichotomy applies
> have no Lean counterpart anywhere. `formal_weaker`.

## Coordinator note

Re-confirms the existing same-model verdict (`E-000330`, supersedes
`E-000248`). The fresh cross-model reader independently reached the exact
same clause-by-clause breakdown (C2/C3 covered, C4/C5 uncovered).
