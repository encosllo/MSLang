# Correspondence audit `B-P135` (`Rec s is Bool`)

Two-stage blind protocol (Architecture.md Section 11.2). Re-audited after the
sort-level Boolean-closure lemmas were added (`Mscong.recognizableAt_union`,
`_inter`, `_sdiff`, `_transPreimage`, `_inverseImage`).

- **Lean:** `Mscong.recognizableAt_empty`, `_univ`, `_union`, `_inter`,
  `_sdiff`, `_transPreimage`, `_inverseImage` -- `lean/Mscong/Recognizable.lean`
- **Manuscript:** Proposition `Rec s is Bool` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

Conjunction of seven clauses: (1) empty and (2) universe for support-finite `A`;
(3) union, (4) intersection, (5) difference for support-finite `A`; (6)
translation preimage `T⁻¹[L] ∈ Rec_t`; (7) homomorphic preimage `f_s⁻¹[M] ∈
Rec_s`. Support-finiteness appears only in clauses (1), (2), (5).

## Stage 2 -- comparator

**Verdict: `formal_weaker`.**

The read-back is implied by the manuscript, not conversely: clauses (1), (2),
(5) add a support-finite hypothesis to `∅, A_s ∈ Rec_s(A)` and to difference
closure, which the manuscript states for an arbitrary `Σ`-algebra `A`. Clauses
(3), (4), (6), (7) match in direction and quantifier domain, so the only
remaining gap is that one hypothesis.

**Formalizer's note.** The support-finiteness hypothesis is in fact **necessary**
and not gratuitous: a finite recognizing algebra `B` forces
`supp(A) ⊆ supp(B)`, so an algebra of infinite support has no finite quotient of
its whole carrier and `A_s ∉ Rec_s(A)`. The manuscript's unconditional part (1)
is therefore only valid when `S` (equivalently `supp(A)`) is finite. This is a
precision correction to be reconciled with the author; the `formal_weaker`
verdict records it rather than hiding it.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
