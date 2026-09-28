# Correspondence audit `B-P102` (`PRecVar`)

Two-stage blind protocol (Architecture.md Section 11.2). Stage 1 read the Lean
declaration back as informal mathematics, seeing only the declaration and the
pilot definitions; stage 2 compared that read-back with the manuscript
statement, seeing only the read-back and the statement.

- **Lean:** `Mscong.PRecVar` -- `lean/Mscong/BasicTerms.lean`
- **Manuscript:** Proposition `PRecVar` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

> Let `S` be a finite sort set. For an arbitrary many-sorted signature `Sig`
> over `S`, an arbitrary `S`-sorted set `X` of variables, any sort `s : S`, and
> any variable `x : X s`, the singleton set consisting of the single term
> `Term.var x` is recognizable at `s` in the free algebra `T_Σ(X)`. Unpacking
> `RecognizableAt`: there exist a finite `Σ`-algebra `B`, a homomorphism
> `f : T_Σ(X) → B`, and a subset `M ⊆ B_s` with `{var x} = f_s⁻¹[M]`.

## Stage 2 -- comparator

**Verdict: `equivalent`.**

- Direction: both assert the same positive existence claim; inverse-image
  equality identical.
- Quantifier domain: both universally quantify finite `S`, arbitrary `Σ`, `X`,
  `s`, and `x : X_s`.
- Finiteness: `S` finite in both; `B` finite in both; `Σ`, `X` unrestricted.
- Degenerate cases: empty `X_s` makes the statement vacuous in both.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
