# Correspondence audit `B-P133` (`s-Rec iff Rec`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.recognizableAt_iff` -- `lean/Mscong/Recognizable.lean`
- **Manuscript:** Proposition `s-Rec iff Rec` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

∀ `Σ`, `A`, sort `s`, `L ⊆ A_s`: `Rec_s(A, L) ↔ Rec(A, δ^{s,L})`, where
`δ^{s,L}` is the Kronecker language; no finiteness hypotheses.

## Stage 2 -- comparator

**Verdict: `equivalent`.**

Both state the same biconditional over the same domain with no finiteness
hypotheses, and both directions are present. The manuscript's trailing "Thus
`Rec_s(A)` is isomorphic to a subset of `Rec(A)`" is a corollary of the iff, not
an additional assertion.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
