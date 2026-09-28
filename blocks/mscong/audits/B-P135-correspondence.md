# Correspondence audit `B-P135` (`Rec s is Bool`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.recognizableAt_empty`, `Mscong.recognizableAt_univ` --
  `lean/Mscong/Recognizable.lean`
- **Manuscript:** Proposition `Rec s is Bool` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

∀ `Σ`, `A`, sort `s`, if `supp(A)` is finite then `∅ ∈ Rec_s(A)` and
`A_s ∈ Rec_s(A)`.

## Stage 2 -- comparator

**Verdict: `formal_weaker`.**

The read-back covers only part (1) of the manuscript's four-part proposition,
and even there it adds `supp(A)` finite, which part (1) does not assume. The
manuscript's parts (2) closure under `∪/∩/−`, (3) translation preimage (with the
sort shift into `Rec_t`), and (4) homomorphic preimage of `Rec_s` are absent
from the mapped declarations, so the formal counterpart is strictly weaker.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
