# Correspondence audit `B-D135` (`GlobSubstOp`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.substHom`, `Mscong.subst1`, `Mscong.substLang` --
  `lean/Mscong/Substitution.lean`
- **Manuscript:** Definition `GlobSubstOp` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

Definitions only: `substHom` (assignment-induced endomorphism of `T_Σ(X)`),
`subst1` (single-variable replacement, recursing through operations), and
`substLang` (substitution into a language). No equations or properties asserted.

## Stage 2 -- comparator

**Verdict: `equivalent`.**

Both sides are definitional with no asserted equations: the manuscript defines
the occurrence-indexed simultaneous substitution operator and the
single-variable operator, and the read-back defines the assignment-induced
endomorphism and single-variable replacement. The operations correspond
term-for-term; no direction, finiteness, or degenerate-case discrepancy.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
