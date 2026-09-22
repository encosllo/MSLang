# Adversarial-read audit transcript -- `B-C001` (cross-model)

Protocol: Architecture.md Section 11a.5, adversarial read of a reconstructed
proof, per the cross-model audit brief's Tier 3 and Section 6 ingestion
pattern. The proof package (definitions + proposed proof) is the one
originally authored by `deepseek-v4.1-flash` in `blocks/explanations/B-C001.md`
(Session 3, 2026-09-14; since adopted into the manuscript verbatim by commit
`009152c`, "manuscript: add accepted B-C001/B-C002 proofs"). The reader is a
fresh, isolated `claude-sonnet-5` agent with no project history and no
expected answer, given only the definitions and the proof text below.

- **Block:** `B-C001`, Corollary (`IncSat`), section "Preliminaries".
- **Contract:** `Ψ ⊆ Φ`... i.e. `Φ ⊆ Ψ ⟹ Ψ-Sat(A) ⊆ Φ-Sat(A)`, for `A` an
  `S`-sorted set and `Φ, Ψ ∈ Eqv(A)`.
- **Outcome:** `VALID`, no gap.
- **Independence:** proof package authored by `deepseek-v4.1-flash`
  (coordinator role, original explanation author); adversarial read by
  `claude-sonnet-5` (fresh, isolated) -- distinct model families.

## Package supplied to the reader

Definitions: `S`-sorted set, `S`-sorted equivalence relation (`Eqv(A)`,
ordered by inclusion), saturation `[X]^Φ` and `Φ-Sat(A)` (manuscript block
`B-D014`). The black-box fact used: Proposition `B-P002` (`PropIncSat`),
forward direction only -- `Φ ⊆ Ψ ⟹ ∀X⊆A, [[X]^Ψ]^Φ = [X]^Ψ`.

Proposed proof: as in `blocks/explanations/B-C001.md` / the accepted
manuscript proof of Corollary `B-C001` (verbatim, both texts agree).

## Adversarial read (fresh agent, claude-sonnet-5)

> **RESULT: VALID**
>
> Reconstruction: fix `X ∈ Ψ-Sat(A)` (hypothesis `H: X = [X]^Ψ`). Instantiate
> `PropIncSat`'s forward direction at this `X` (legitimate: it is quantified
> over all `X ⊆ A`, no saturation precondition): `[[X]^Ψ]^Φ = [X]^Ψ`. Chain:
> `[X]^Φ = [[X]^Ψ]^Φ` (substitute via `H`) `= [X]^Ψ` (black box) `= X` (via
> `H` again). Hence `X ∈ Φ-Sat(A)`.
>
> Edge cases probed, none breaks the argument: `X = ∅` (trivially saturated
> w.r.t. every relation, no special-casing needed); `S = ∅` (`Eqv(A)`
> singleton, claim vacuous); `Φ = Δ^A` (`Δ-Sat(A) = Sub(A)`, conclusion
> trivial); `Ψ = ∇^A` (`∇-Sat(A)` = "all-or-nothing per sort" subsets,
> independently verified to lie in every `Φ-Sat(A)`); `Φ = Ψ` (degenerates to
> `Ψ-Sat(A) ⊆ Ψ-Sat(A)`, consistent).
>
> The substitution step uses only `H` (twice, as an equality-of-sets rewrite)
> and extensionality of `[·]^Φ`; no hidden strengthening, no unstated
> nonemptiness assumption. Direction sanity check: `Φ ⊆ Ψ` means `Φ`-classes
> refine `Ψ`-classes, so a `Ψ`-saturated set is automatically a union of
> `Φ`-blocks, matching the claimed inclusion direction.

## Coordinator note

This is a re-confirmation of the existing same-model `pass` verdicts
(`E-000001`, `E-000038`) with an independent model family and no repo access.
No discrepancy found; the reconstruction and the edge-case analysis both
matched the expected argument exactly.
