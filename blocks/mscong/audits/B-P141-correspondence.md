# Correspondence audit `B-P141` (`PRecSubs`)

Two-stage blind protocol (Architecture.md Section 11.2).

- **Lean:** `Mscong.PRecSubs` -- `lean/Mscong/Substitution.lean`
- **Manuscript:** Proposition `PRecSubs` (`manuscript/MSCong.tex`)

## Stage 1 -- read-back

∀ `Sig`, `X` with `[Finite S]` and `FiniteSSet X`, sort `s`, `K ⊆ T_Σ(X)_s`,
assignment `L : X ⇀ languages`: if `K ∈ Rec_s` and `L t x ∈ Rec_t` for every
`t, x`, then `substLang Sig X L s K ∈ Rec_s`.

## Stage 2 -- comparator

**Verdict: `equivalent`.**

Both require `K ∈ Rec_s(T_Σ(X))` and componentwise `L_x ∈ Rec_t`, then conclude
that simultaneous substitution is recognizable at `s`, over the same quantifier
domain. The `[Finite S]` and `FiniteSSet X` are the `PRec*` subsection's
standing finiteness assumptions. Degenerate cases (empty `K`, no variables) are
handled identically.

## Independence caveat

Both stages share this session's model family; common blind spots are not
excluded.
