# Encoding audit -- `representation/mscong-pilot-encoding.md` (M6 pilot)

Section 11.5 audit of the pilot representation record. The auditor saw only the
record and the definitions it cites.

**Verdict: `faithful-with-caveat` with residuals R-universe, R-classical,
R-finite, R-congruence, R-first, R-restriction.**

## Per-residual justification

- **R-universe.** The paper's Grothendieck universe is approximated by Lean
  universe levels; `𝒰`-large consequences are out of scope. Disclosed and
  bounded.
- **R-classical.** The paper is classical; Lean uses `propext`,
  `Classical.choice`, `Quot.sound` (permitted set). Admitted, not a semantic
  mismatch.
- **R-finite.** The paper's "finite many-sorted set" is `FiniteSSet`
  (finite support + finite carriers on the support), not `Fintype`; the bridge
  `finiteSSet_iff` is load-bearing and recorded.
- **R-congruence.** The paper's `Cgr_fi(A)` is a congruence
  (operation-compatible), while `SortedEqv` is a bare per-sort `Setoid`.
  Compatibility (`IsCongruence`) is separate, so the encoding is broader than
  the paper's object unless carried; recorded.
- **R-first.** The `Filter` block maps to two closure facts
  (`IsFiniteIndex_of_le`, `IsFiniteIndex_inf`); those do not by themselves
  discharge the full filter statement (top/nonemptiness), so the match is
  partial; recorded.
- **R-restriction.** `Rec_T(A)` for `T ⊊ S` is about `A↾_T`, but the Lean
  `RecognizableOn` goes through a `zeroExtension` to all of `S`; the interaction
  outside `T` is not certified; recorded.

## Independence caveat

Same-session, same-model self-audit; not independent. Recorded in the evidence
record's `independence_caveat`.
