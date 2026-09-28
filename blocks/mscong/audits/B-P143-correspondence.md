# Correspondence audit `B-P143` (`PRecQ`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.PRecQ`, `Mscong.quotLang_range_finite` --
  `lean/Mscong/Quotient.lean`
- **Manuscript:** Proposition `PRecQ` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

With `[Finite S]`, `s`, `t`, `z : X_t`: (1) for `K ⊆ T_Σ(X)_t` and
`L ⊆ T_Σ(X)_s` with `L ∈ Rec_s`, `quotLang Sig X z K L ∈ Rec_s` (no hypothesis
on `K`); (2) for `L ∈ Rec_s`, the range `{quotLang Sig X z K L : K}` over all
`K` is finite.

## Stage 2 -- comparator

**Verdict: `equivalent`.**

Both parts match exactly: the `z`-quotient of a recognizable language is
recognizable with no hypothesis on `K`, and the set of `z`-quotients of a fixed
recognizable `L` is finite. Directions and the quantifier domain
(`∀ t`, `∀ z ∈ X_t`, `∀ K`) agree; `[Finite S]` is the subsection's ambient
assumption.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
