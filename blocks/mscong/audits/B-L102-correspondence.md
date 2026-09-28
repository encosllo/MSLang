# Correspondence audit `B-L102` (`L:aux`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.derivedAlg_eval` -- `lean/Mscong/Hall.lean`
- **Manuscript:** Lemma `L:aux` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

∀ `HallAlg A`, `Sig`, `f : Σ → A`, lists `u, w`, sort `s`,
`P ∈ T_Σ(↓w)_s`, assignment `a` of the placeholders `↓w` into `A_{u,·}`:
`termLift (derivedAlg A Sig f u) a P = A.ξ_{u,w,s}(p^w♯_s(P), a)` where
placeholder `i` receives `a` at `w_i`. An equality of evaluations.

## Stage 2 -- comparator

**Verdict: `equivalent`.**

Both state the same equality: evaluating `P` in the derived algebra `A^{f,u}`
under a placeholder assignment equals `ξ^A_{u,w,s}` applied to the lifted term
`(p^w)♯_s(P)` and the same assignment, for all `u, w, s`, `P ∈ T_Σ(↓w)_s` and
`a ∈ ∏_{i∈w} A_{u,w_i}`. Quantifier domain, placeholder indexing, and direction
all agree; no finiteness hypotheses or degenerate-case differences.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
