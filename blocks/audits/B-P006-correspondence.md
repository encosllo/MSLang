# Correspondence audit transcript -- `B-P006`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declarations:** `Mslang.SatSet`, `Mslang.QuotFamily`,
  `Mslang.satOfFamily`, `Mslang.familyOf`, `Mslang.satSetsFamilyEquiv`,
  `Mslang.satSetsCABA`, `Mslang.familyOf_deltaSub`, `Mslang.familyOf_atomRep`,
  `Mslang.satSets_isAtom_iff`, `Mslang.satSets_eq_sSup_atoms`
  (`lean/Mslang/Regular.lean`).
- **Contract:** Proposition `B-P006` (`CABA Saturades`): `(Φ-Sat(A), ⊆)` is a
  complete atomic Boolean algebra; its atoms are the Kronecker deltas
  `δ^{t,[x]_{Φ_t}}`; every saturated `X` is the join of the atoms below it.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Fix a sorted set `A = (A_s)` and a sorted equivalence `Φ = (Φ_s)`. A
> componentwise subset `X : Sub A` is `Φ`-saturated when `sat Φ X = X`; then
> `SatSet Φ = {X : Sub A // sat Φ X = X}`. The quotient projection is
> `pr Φ s : A_s → A_s/Φ_s`, and `QuotFamily Φ = ∀ s, Set (A_s/Φ_s)` is the
> product over sorts of the powersets of the quotients. The maps
> `familyOf Φ X = fun s => pr Φ s '' X_s` and `satOfFamily Φ Y = fun s =>
> (pr Φ s)⁻¹'(Y_s)` are mutually inverse (both round-trips use surjectivity of
> `pr`), giving the bijection `satSetsFamilyEquiv Φ`. Moreover
> `familyOf Φ X ≤ familyOf Φ Y ↔ X.1 ≤ Y.1`, so `familyOf` is an order
> isomorphism onto the whole product order `QuotFamily Φ` with pointwise
> inclusion; the transported inclusion is exactly componentwise inclusion of
> saturated subsets.
>
> `satSetsCABA Φ` is `CompleteAtomicBooleanAlgebra (SatSet Φ)` obtained by
> transporting the canonical CABA structure of the product of powersets across
> that bijection. Its operations are those of `QuotFamily Φ` (pointwise `∪`,
> `∩`, componentwise complement, pointwise `sSup`) transferred along
> `familyOf`/`satOfFamily`; because `familyOf` preserves and reflects inclusion,
> the abstract order is ordinary `⊆` on saturated subsets.
>
> `satSets_isAtom_iff Φ X` says `IsAtom (familyOf Φ X)` iff `X` is a Kronecker
> delta `δ^{s,[x]_Φ}` concentrated at one sort `s` on one `Φ_s`-class
> (`deltaSub s (eqvClass Φ s (Quotient.out q))`). So the atoms correspond to
> `Σ_{s∈S} A_s/Φ_s`. `satSets_eq_sSup_atoms Φ X` says `familyOf Φ X` is the
> `sSup` (pointwise union) of the atoms below it in `QuotFamily Φ`; through the
> order isomorphism, `X` is the join of the atoms below it in `SatSet Φ`.
>
> Packaging: the atom and join facts are stated on `familyOf Φ X` in the
> quotient family; the transfer back to `X` is via the bijection/order
> isomorphism.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> Carrier: `Φ-Sat(A) = {X | sat Φ X = X}` in both, with the same data (sorted
> `A`, `Φ ∈ Eqv(A)`). Order: the contract's `⊆` is matched, since `familyOf`
> preserves and reflects componentwise inclusion. CABA: `satSetsCABA Φ` is a
> `CompleteAtomicBooleanAlgebra`, matching the contract. Atoms: the contract's
> `δ^{t,[x]_{Φ_t}}` for `t ∈ S`, `x ∈ A_t` range exactly over `Σ_s A_s/Φ_s`, and
> the formal characterization (via injectivity of `familyOf`) gives the same
> atom set. Join: the formal family-level `sSup` is pointwise union, which under
> the order isomorphism is exactly "the join of all atoms below `X`".
> Hypotheses and degenerate cases (empty sorts, empty joins, bottom `∅`) are
> handled identically. The packaging difference (atoms/joins stated on the
> quotient family rather than on `X`) is mediated by a bijection that is an order
> isomorphism, which preserves atoms, joins, and the CABA structure exactly, so it
> does not change strength.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). A representation
change (class C6) stales it.
