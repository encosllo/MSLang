# Correspondence audit `B-P132` (`Rec is Bool`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.recognizable_union`, `_inter`, `_compl`, `_empty`, `_univ`,
  `_transPreimage`, `_inverseImage` -- `lean/Mscong/Recognizable.lean`
- **Manuscript:** Proposition `Rec is Bool` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

Conjunction of seven closure theorems for `Recognizable` (each: exists a finite
Σ-algebra `B`, a homomorphism `f : A → B`, `M ⊆ B` with `L = f⁻¹[M]`): union,
intersection, complement; empty and universe (both requiring `supp(A)` finite);
translation preimage under a `TlGen` translation; inverse image along a
homomorphism. No finiteness for union/intersection/complement/preimages.

## Stage 2 -- comparator

**Verdict: `formal_weaker`.**

The seven items align in content and direction with the manuscript's four parts
(complement vs. the manuscript's `A − L` is interderivable given
empty/universe/intersection). The gap is finiteness: the Lean empty/universe
theorems require `supp(A)` finite, whereas the manuscript asserts
`∅, A ∈ Rec(A)` for an arbitrary `Σ`-algebra `A`; the extra hypothesis makes the
formal statement strictly less general.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
