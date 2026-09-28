# Correspondence audit `B-P103` (`PRecConst`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.PRecConst` -- `lean/Mscong/BasicTerms.lean`
- **Manuscript:** Proposition `PRecConst` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

> For every finite sort set `S`, signature `Σ`, `S`-sorted set `X`, sort
> `s : S`, and constant symbol `σ : Σ_{[],s}`, the singleton
> `{Term.op ([],s) σ (empty family)} ⊆ T_Σ(X)_s` is recognizable at sort `s`.
> Unfolded: there exist a finite `Σ`-algebra `B`, a homomorphism
> `f : T_Σ(X) → B`, and `M ⊆ B_s` with `f_s⁻¹[M] = {σ}`.

## Stage 2 -- comparator

**Verdict: `equivalent`.**

- Direction/statement: same recognizability claim under the identical
  `Rec_s` definition.
- Quantifier domain: same universal scope over `Σ`, `X`, `s`, `σ`.
- Finiteness: `S` finite in both; `X` unconstrained in both; `B` finite.
- Degenerate cases: empty `S` vacuous in both; empty `X` leaves the nullary
  term and its singleton intact in both.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
