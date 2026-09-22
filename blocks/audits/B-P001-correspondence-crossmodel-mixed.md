# Correspondence audit transcript -- `B-P001` (cross-model, mixed)

Protocol: Architecture.md Section 11.2, two-stage blind, per the cross-model
audit brief's Tier 4 (re-confirm/challenge an accepted `formal_weaker`
finding) and Section 6 ingestion pattern. Stage 1 reuses the existing
`deepseek-v4.1-flash` read-back verbatim (from
`blocks/audits/B-P001-correspondence.md`). Stage 2 is a fresh, isolated
`claude-sonnet-5` agent given the stage-1 read-back and the full manuscript
contract text (all three numbered items, not a summary) -- no repo access,
no expected answer, explicitly asked to go clause by clause.

- **Lean declarations:** `Mslang.nonempty_sortedMap_iff`,
  `Mslang.supp_mono_of_injective`, `Mslang.suppSub_directImage`,
  `Mslang.supp_eq_of_surjective`, `Mslang.suppSub_inverseImage`,
  `Mslang.supp_initialSorted`, `Mslang.supp_finalSorted`,
  `Mslang.supp_iCoprod`, `Mslang.supp_iProd`, `Mslang.suppSub_iInter_subset`,
  `Mslang.suppSub_sdiff_subset` (`lean/Mslang/Prelim.lean`).
- **Contract:** Proposition `B-P001` (`propssupport`), all three items.
- **Outcome:** `formal_weaker` -- confirmed.
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** stage 1 ran on `deepseek-v4.1-flash`, stage 2 on
  `claude-sonnet-5` -- distinct model families.

## Stage 1 -- read-back (reused verbatim, deepseek-v4.1-flash, Lean only)

(As in `blocks/audits/B-P001-correspondence.md`: the type encoding has no
ambient universe; `supp`, `suppSub`, `SortedMap`, `iCoprod`, `iProd` as
defined there; claims 1-10 matched to the eleven Lean declarations.)

## Stage 2 -- comparison (fresh agent, claude-sonnet-5, read-back + full contract, clause by clause)

> **VERDICT: formal_weaker**
>
> Clause 1 (Hom(A,B)≠∅ iff supp A ⊆ supp B; therefore A⊆B ⇒ supp A ⊆ supp B;
> moreover supp X = supp f[X]) -- matched exactly by declarations 1-3;
> equivalent in isolation.
>
> Clause 2 (surjective f ⇒ supp A = supp B; moreover supp Y = supp f⁻¹[Y]) --
> matched exactly by declarations 4-5; equivalent in isolation.
>
> Clause 3 (seven equalities/inclusions) -- this is where correspondence
> breaks down: `supp(∅^S)=∅`, `supp(1^S)=S`, `supp(∐A^i)=⋃supp(A^i)`, and
> `supp(∏A^i)=⋂supp(A^i)` are matched exactly. But `supp(⋃A^i)=⋃supp(A^i)`
> for a genuine set-theoretic union of *arbitrary* (unrelated-carrier) sorted
> sets has **no Lean counterpart** -- the type encoding cannot express it;
> only the coproduct analogue (`supp_iCoprod`) is proved, a different
> construction that happens to share the numeric formula. The
> intersection-inclusion and set-difference-inclusion clauses are proved
> only for componentwise subsets of one fixed common carrier (`Sub A`), not
> for arbitrary sorted sets as the contract states -- a domain restriction
> that a locally-dropped `I ≠ ∅` hypothesis does not compensate for.
>
> Contract clauses with no Lean counterpart: the arbitrary-union sub-clause
> of item 3. Two further sub-clauses (intersection, difference) are proved
> only in a narrower domain than stated. No Lean content exceeds the
> contract. Overall verdict: `formal_weaker`, confirming the existing
> same-model finding -- a representation-level gap (no ambient universe for
> unrelated-carrier set operations), not a proof gap.

## Coordinator note

Re-confirms the existing same-model verdict (`E-000236`) with an independent
model family; the specific gap identified (general union unformalized;
intersection/difference restricted to `Sub A`) matches exactly.
