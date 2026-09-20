# Correspondence audit transcript -- `B-P036`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declaration:** `Mslang.regularLanguageFormations_completeLattice`
  (`lean/Mslang/Regular.lean`).
- **Contract:** Proposition `B-P036`: `Form_{Lang_r}(Σ)` is a complete lattice.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> For every signature `Σ` over a finite sort set `S`, the collection
> `Form_Lang_r(Σ)` of formations of regular languages carries a complete-lattice
> structure (every subset has a least upper bound and a greatest lower bound).
> The only hypothesis is `[Finite S]`. The declaration exposes as an instance the
> complete-lattice structure already established for `Form_Lang_r(Σ)`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The read-back asserts exactly a `CompleteLattice` instance on
> `Form_Lang_r(Σ)` under `[Finite S]`, the same content as the contract in the
> finite-index section where `B-A001` (`[Finite S]`) is in force. The
> completeness claim is neither weakened nor strengthened by the declaration
> reusing a structure whose ambient construction also yields algebraicity via
> the separate result `B-C013`.

## Residual note

`B-P036` is subsumed by `B-C013` (`regularLanguageFormationsCompleteLattice` is
the `CompleteLattice` part; `regularLanguageFormations_isAlgebraicLattice` adds
algebraicity). The declaration here states the completeness alone, as the
proposition `B-P036` does. The record inherits the pilot-encoding residuals
(`carrier-model`, `small-large`, `univalence-missing`).
