# Correspondence audit `B-P145` (`IndAlgStrucImHom`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.cStruct`, `Mscong.cAlg`, `Mscong.treeHom_isAlgHom` --
  `lean/Mscong/TreeHom.lean`
- **Manuscript:** Proposition `IndAlgStrucImHom` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

Definition `cStruct`: given a hyperderivor `c`, a `Ξ`-algebra `B`, and a
**surjective** homomorphism `g : T_Ξ(Y) → B`, produce a `Σ`-algebra structure on
`s ↦ B_{φ(s)}`. Definition `cAlg`: the canonical `Σ`-algebra structure on
`s ↦ T_Ξ(Y)_{φ(s)}`. Theorem `treeHom_isAlgHom`: `treeHom c` is a
`Σ`-homomorphism from `T_Σ(X)` to `cAlg`.

## Stage 2 -- comparator

**Verdict: `equivalent`.**

The manuscript asserts the existence of an induced `Σ`-algebra structure on
`A_φ` making the stated map a homomorphism; the read-back realizes this through
`cStruct(B, g)` (whose inputs include the surjective `g`) and
`treeHom_isAlgHom` supplies the homomorphism property for the canonical
structure `cAlg`. Surjectivity, direction, and existence content correspond; no
added finiteness.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
