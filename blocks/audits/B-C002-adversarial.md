# Adversarial-read audit transcript -- `B-C002` (cross-model)

Protocol: Architecture.md Section 11a.5, adversarial read of a reconstructed
proof, per the cross-model audit brief's Tier 3 and Section 6 ingestion
pattern. The proof package (definitions + proposed proof) is the one
originally authored by `deepseek-v4.1-flash` in `blocks/explanations/B-C002.md`
(Session 3, 2026-09-14, itself reconstructed from the Lean proof
`Mslang.sat_inf`; since adopted into the manuscript verbatim by commit
`009152c`). The reader is a fresh, isolated `claude-sonnet-5` agent with no
project history and no expected answer, given only the definitions and the
proof text below.

- **Block:** `B-C002`, Corollary, section "Preliminaries".
- **Contract:** `Φ-Sat(A) ∩ Ψ-Sat(A) ⊆ (Φ∩Ψ)-Sat(A)`, for `A` an `S`-sorted
  set and `Φ, Ψ ∈ Eqv(A)`.
- **Outcome:** `VALID`, no gap. Confirms (independently rediscovers) the
  known observation, already flagged in the explanation's own "notes for the
  adversarial reader", that the `Ψ`-saturation hypothesis is unused.
- **Independence:** proof package authored by `deepseek-v4.1-flash`
  (coordinator role, original explanation author); adversarial read by
  `claude-sonnet-5` (fresh, isolated) -- distinct model families.

## Package supplied to the reader

Definitions: `S`-sorted set, `Eqv(A)`, saturation `[X]^Φ`/`Φ-Sat(A)`
(`B-D014`); the meet `Φ ∩ Ψ` as pointwise intersection, given as an
`S`-sorted equivalence with `Φ∩Ψ ⊆ Φ` and `Φ∩Ψ ⊆ Ψ`. The black-box fact
used: Corollary `B-C001` (`IncSat`) itself, in direct form.

Proposed proof: as in `blocks/explanations/B-C002.md` / the accepted
manuscript proof of `B-C002` (verbatim, both texts agree).

## Adversarial read (fresh agent, claude-sonnet-5)

> **RESULT: VALID**
>
> Reconstruction: fix `X ∈ Φ-Sat(A) ∩ Ψ-Sat(A)` (so `X = [X]^Φ`). Since
> `Φ∩Ψ ⊆ Φ`, show `X = [X]^{Φ∩Ψ}` in two directions: (⊆) reflexivity of
> `Φ∩Ψ` gives `X ⊆ [X]^{Φ∩Ψ}` for *any* equivalence and *any* `X`, using
> neither saturation hypothesis; (⊇) `Φ∩Ψ ⊆ Φ` gives
> `[a]_{(Φ∩Ψ)_s} ⊆ [a]_{Φ_s}` for every `a`, hence
> `[X]^{Φ∩Ψ} ⊆ [X]^Φ = X` (using `X ∈ Φ-Sat(A)`).
>
> **Key finding:** the `Ψ-Sat(A)` hypothesis is never invoked -- only
> `X = [X]^Φ` is used. The proof therefore establishes the strictly stronger
> `Φ-Sat(A) ⊆ (Φ∩Ψ)-Sat(A)` (an immediate instance of the black-box `IncSat`
> with `Θ = Φ∩Ψ ⊆ Φ = Θ'`); the stated corollary follows a fortiori since
> `Φ-Sat(A) ∩ Ψ-Sat(A) ⊆ Φ-Sat(A)`. Not a gap -- a proof using fewer
> hypotheses than stated remains valid for the (weaker) stated claim -- but
> the corollary as phrased undersells what was actually proved.
>
> Edge cases probed, none breaks the argument: `X = ∅`; `S = ∅`; `Φ = Ψ`
> (degenerates to `Φ-Sat(A) ⊆ Φ-Sat(A)`); `Φ = Δ^A` (hypothesis and
> conclusion both trivial, `Δ-Sat(A) = Sub(A)`); `Φ = ∇^A` (`∇-Sat(A)`
> members are trivially `Θ`-saturated for every `Θ`, independently confirming
> the "only `Φ` is used" observation); `Φ∩Ψ = Δ^A` (conclusion trivially
> true). Both inclusion directions checked in the correct orientation; no
> hidden reliance on nonemptiness of `S`, `A_s`, or any class.

## Coordinator note

This is a re-confirmation of the existing same-model `pass` verdicts
(`E-000012`, `E-000039`) with an independent model family and no repo
access. The fresh reader independently rediscovered the exact same
"`Ψ`-saturation is unused" observation the original explanation's author
flagged for the reader in `blocks/explanations/B-C002.md` -- convergent
evidence, not a new gap.
