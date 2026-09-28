# Correspondence audit `B-P147` (`PRecLH`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.PRecLH` -- `lean/Mscong/TreeHom.lean`
- **Manuscript:** Proposition `PRecLH` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

∀ `φ : S → T` with `[Finite S]` `[Finite T]` `[Finite (Sigma Σ)]`, a **linear**
hyperderivor `c`, `FiniteSSet X`, sort `s`, `L ⊆ T_Σ(X)_s`: if `L ∈ Rec_s` then
the forward image `(treeHom c)_s[L] ∈ Rec_{φ(s)}(T_Ξ(Y))`.

## Stage 2 -- comparator

**Verdict: `equivalent`.**

Both restrict to a linear hyperderivor and assert that the forward image of a
recognizable `L` under the linear tree homomorphism is recognizable at `φ(s)`;
direction agrees. The `[Finite S]`, `[Finite (Sigma Σ)]`, `FiniteSSet X` match
the subsection assumptions noted for this proposition. The extra `[Finite T]` is
harmless (only finitely many image sorts matter) and does not change the claim.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
