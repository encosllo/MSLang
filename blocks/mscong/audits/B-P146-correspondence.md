# Correspondence audit `B-P146` (`PRecH`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.PRecH` -- `lean/Mscong/TreeHom.lean`
- **Manuscript:** Proposition `PRecH` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

∀ `φ : S → T`, `[Finite S]`, hyperderivor `c`, sort `s`,
`L ⊆ T_Ξ(Y)_{φ(s)}`: if `L ∈ Rec_{φ(s)}(T_Ξ(Y))` then
`(treeHom c)_s⁻¹[L] ∈ Rec_s(T_Σ(X))`.

## Stage 2 -- comparator

**Verdict: `equivalent`.**

Both say that if `L ∈ Rec_{φ(s)}(T_Ξ(Y))` then its inverse image at sort `s` lies
in `Rec_s(T_Σ(X))`; direction and quantifier domain agree. `[Finite S]` is the
`PRec*` subsection's standing assumption. The manuscript's `(f♯_{φ(s)})⁻¹` is a
sort-index typo for `f♯_s`; degenerate `s` and empty `L` behave the same.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
