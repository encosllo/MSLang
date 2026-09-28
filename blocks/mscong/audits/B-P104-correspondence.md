# Correspondence audit `B-P104` (`PRecOp`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.PRecOp` -- `lean/Mscong/BasicTerms.lean`
- **Manuscript:** Proposition `PRecOp` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

> For every finite sort set `S`, signature `Σ`, `S`-sorted set `X`, pair
> `p = (w,s)` with `w` a nonempty list of sorts, operation symbol
> `σ : Σ_{w,s}`, and family of variables
> `x : (i : Fin w.length) → X (w.get i)`, the singleton
> `{Term.op p σ x} ⊆ T_Σ(X)_s` is recognizable at sort `s`. Unfolded: there
> exist a finite `Σ`-algebra `B`, a homomorphism `f : T_Σ(X) → B`, and
> `M ⊆ B_s` with `f_s⁻¹[M] = {σ(x⃗)}`.

## Stage 2 -- comparator

**Verdict: `equivalent`.**

- Direction: same singleton, same recognizability claim.
- Quantifier domain: same universal scope; the nonempty-arity hypothesis
  `w ≠ []` matches the paper's `w ∈ S⋆ − {λ}`.
- Finiteness: `S` finite in both; neither imposes finiteness on `Σ`, `X`.
- Degenerate cases: empty `X` makes both vacuously true; empty `w` excluded
  on both sides.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
