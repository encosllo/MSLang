# Encoding audit transcript -- `representation/pilot-encoding.md` (cross-model)

Protocol: Architecture.md Section 11.5. Run in Session 122 as the Tier-1 target
of `blocks/audits/cross-model-audit-brief.md`: the first cross-model audit of
this project, run by a fresh agent on `claude-sonnet-5` (family `claude`),
independent of the `deepseek-v4.1-flash` formalization work. The agent was
given only the verbatim text of `representation/pilot-encoding.md`, told
nothing about the expected verdict, and instructed not to consult any other
project file.

- **Artifact:** `representation/pilot-encoding.md`.
- **Outcome:** `faithful-with-caveat`.
- **Recorded as:** `E-000389` (supersedes `E-000387`, `E-000388`: corrected
  producer-model attribution and residual labels to match the verdict below).
- **Independence:** cross-model -- the auditor (`claude-sonnet-5`) is a
  different model family from every prior evidence stage
  (`deepseek-v4.1-flash`).

## Encoding audit (fresh agent, artifact only)

> MODEL: claude-sonnet-5 (family: claude)
> AUDIT: representation
> ARTIFACT: representation/pilot-encoding.md
> OUTCOME: faithful-with-caveat
> RESIDUALS: R-universe, R-setoid, R-classical, R-ext, R-union-inter-unevidenced
>
> JUSTIFICATION: The dependent-type carrier encoding (`SSet S := S → Type u`)
> faithfully mirrors the paper's `S`-sorted-set structure operation-by-operation,
> and the document itself is candid about what remains approximated.
> Per-operation: subset/`Sub(A)` is representable directly as the componentwise
> predicate family `∀ s, Set (A s)`, matching the paper's `A_s ⊆ B_s` definition
> exactly. Componentwise product and the paper's disjoint union/coproduct are
> representable as dependent function types and `Sum`, both genuinely "in
> class." Componentwise intersection and union of two sorted subsets of the
> same `A`, however, are not shown anywhere in the table (only complement and
> product/sum appear); they follow trivially from the `Sub A := ∀ s, Set (A s)`
> pattern (`fun s => X s ∩ Y s` / `∪`), but since this isn't evidenced in the
> record itself, it should be scored bridgeable-by-inference rather than
> audited-representable -- hence the added residual label
> `R-union-inter-unevidenced`, which is my own finding from the gap rather than
> one the document names. Componentwise complement is judged representable: it
> is listed under "Resolved by this encoding" as `(X s)ᶜ` inside `A_s`,
> "relative by construction" -- a faithful rendering once there is no fixed
> ambient set (the dependent-type model makes every subset already relative to
> its own `A_s`, matching the paper's ZFSK-style component-relative subset
> notion). `δ^t` and support are representable: `δ^t` becomes a genuine
> `PUnit`/`PEmpty` family (verified by the `delta_support`/`supp_delta` bridge
> lemma) rather than the old model's `Set.univ` approximation, and
> `supp_S(A) = {s | Nonempty (A s)}` is a direct definitional transcription.
> Sorted equivalence is bridgeable rather than strictly representable:
> `SortedEqv A := ∀ s, Setoid (A s)` encodes an equivalence as a
> structure-with-proofs, not literally as a subset `Φ ⊆ A × A`, and this gap is
> only closed via the `setoid_le_iff` and `eqvClass_eq_iff` bridge lemmas --
> explicitly flagged as the residual R-setoid ("bounded" but not eliminated).
> Saturation (`[X]^Φ`, `IsSat`) is representable/bridgeable: its componentwise
> formula is a direct transcription, backed by proved bridge lemmas
> `sat_antitone` and `sat_eq_preimage`. Quotient/projection (`A/Φ`, `pr^Φ`) and
> the (co)product are both representable and explicitly resolved relative to
> the prior ambient-set encoding: the quotient closes over `SSet S` itself
> (`fun s => Quotient (Φ s)`), so it stays in the paper's object class rather
> than escaping it, and `∏_i A^i` is a genuine dependent function type. Beyond
> the operation-level residuals, the document names four caveats that persist
> independent of this representation change and that I am not able to
> independently verify without access to the Lean source: R-universe
> (Grothendieck-universe/small-large distinction only approximated by Lean
> universe levels, "𝒰-large consequences out of scope"), R-setoid (as above),
> R-classical (reliance on `propext`, `Classical.choice`, `Quot.sound`), and
> R-ext (family extensionality needs `funext`). None of these appear to be
> foundational mismatches -- they read as standard, well-understood
> Lean/Mathlib-vs-ZFC translation gaps rather than errors -- so the overall
> verdict is faithful-with-caveat rather than unfaithful, with the one added
> observation (R-union-inter-unevidenced) being a documentation gap in the
> encoding table rather than a suspected faithfulness problem.
