# Correspondence audit transcript -- `B-R001` (cross-model, mixed)

Protocol: Architecture.md Section 11.2, two-stage blind, per the cross-model
audit brief's Tier 4 and Section 6 ingestion pattern. Stage 1 reuses the
existing `deepseek-v4.1-flash` read-back verbatim (from
`blocks/audits/B-R001-correspondence.md`, matching the mapped Lean
declarations). Stage 2 is a fresh, isolated `claude-sonnet-5` agent given
the stage-1 read-back and the full manuscript contract text (both
paragraphs plus items (1)-(4)) -- no repo access, no expected answer,
explicitly asked to go clause by clause including the un-numbered
paragraph-2 claims.

- **Lean declarations:** `Mslang.SortedIso`, `Mslang.iCoprod`, `Mslang.deltaT`,
  `Mslang.delta_iso_coprod` (`lean/Mslang/Pilot.lean`)
- **Contract:** Remark `B-R001`, section "Preliminaries" -- full text (the
  opening isomorphism sentence, the generation/separation paragraph, and
  items (1)-(4) on atoms, `Sub(1^S)≅Sub(S)`, projectivity, monomorphism).
- **Outcome:** `formal_weaker` -- confirmed, matching the Session-118
  full-block correction in the existing transcript.
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** stage 1 ran on `deepseek-v4.1-flash`, stage 2 on
  `claude-sonnet-5` -- distinct model families.

## Stage 1 -- read-back (reused verbatim, deepseek-v4.1-flash, Lean only)

> `delta t` is the Kronecker delta `δ^t`; `deltaT t X` is `δ^{t,X}`;
> `iCoprod A` is the coproduct; `SortedIso A B` is a sorted map bijective at
> every sort. The one theorem: `delta_iso_coprod : SortedIso (deltaT t X)
> (iCoprod (fun _ : X => delta t))`, i.e. `δ^{t,X} ≅ ∐_{x:X} δ^t`. No other
> declarations are mapped to this block; no Lean declaration anywhere states
> a generating/separating-set notion, a Boolean algebra of subobjects,
> atoms, projective objects, or a category-theoretic mono/epi notion for
> `S`-sorted sets.

## Stage 2 -- comparison (fresh agent, claude-sonnet-5, read-back + full contract, clause by clause)

> **VERDICT: formal_weaker**
>
> Paragraph 1 (`δ^{t,X} ≅ ∐_{x∈X}δ^t`) -- matched exactly by
> `delta_iso_coprod`; equivalent in isolation.
>
> Paragraph 2, claim (a) ("`1^S` does not generate `Set^S`") -- no Lean
> counterpart (no generating/separating notion exists at all).
> Claim (b) ("`{δ^s}` is a generating/separating set") -- no Lean
> counterpart, same reason. Claim (c) ("every `S`-sorted set is a coproduct
> of copowers of deltas," a general representation theorem for *all*
> `S`-sorted sets) -- no Lean counterpart; the one proved theorem only
> decomposes the specific object `δ^{t,X}`.
>
> Items (1)-(4) (atoms of `Sub(1^S)`; `Sub(1^S) ≅ Sub(S)`; projectivity of
> `δ^s`; every map out of `δ^s` is a monomorphism) -- **none** has a Lean
> counterpart; no Boolean-algebra-of-subobjects, atoms, projective-object,
> or mono/epi infrastructure exists for `S`-sorted sets in the mapped scope
> or its dependencies.
>
> Summary: of the substantive mathematical assertions (the isomorphism
> sentence, claims (a)-(c), items (1)-(4)), only the opening isomorphism
> sentence has a matching Lean declaration, and that match is exact. The
> remaining eight assertions have no Lean declaration anywhere -- an entire
> Boolean-algebra-of-subobjects/projectivity/generator theory that isn't
> built in Lean at all. Formal side proves strictly less: `formal_weaker`.

## Coordinator note

Re-confirms the existing same-model verdict (`E-000265`, itself a
Session-118 full-block correction of an earlier partial-coverage
`equivalent` record `E-000113`). The fresh cross-model reader independently
identified the same partial-coverage gap without being told about the
Session-118 correction history.
