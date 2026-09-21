# Correspondence audit transcript -- `B-P035` (cross-model, mixed stages)

Protocol: Architecture.md Section 11.2, two-stage blind, Section 6 ingestion
pattern (reuse an existing stage-1 read-back with a new-family stage 2). Run
in Session 122 as part of Tier 1 of `blocks/audits/cross-model-audit-brief.md`
(`Def1FRL <=> Def2FRL`). Stage 1 is the pre-existing, same-model read-back
from `blocks/audits/B-P035-correspondence.md` (Session 119,
`deepseek-v4.1-flash`, reused verbatim as the coordinator's stage-1 input).
Stage 2 is a fresh, isolated agent on `claude-sonnet-5` given only that
read-back and the contract -- it was not shown the prior stage-2 verdict.

- **Lean declarations:** `Mslang.isBPSLanguageFormation_of_isRegularLanguageFormation`,
  `Mslang.isRegularLanguageFormation_of_isBPSLanguageFormation`
  (`lean/Mslang/Regular.lean`).
- **Contract:** Proposition `B-P035` ("Definitions `B-D045` (Def1FRL) and
  `B-D046` (Def2FRL) are equivalent."), manuscript line 2334, plus `B-D014`
  (Phi-Sat), `B-D040` (finite-index congruence), `B-D035`/`B-D036`/`B-D037`
  (translations), `B-D038` (congruence cogenerated `Omega^A(L)`), `B-D044`
  (regular language), `B-D045`, `B-D046`.
- **Outcome:** `equivalent` -- **verified against the Lean source** (see
  Coordinator verification below).
- **Recorded as:** see `evidence/` (this file's companion record).
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** cross-model -- stage 1 (`read_back_auditor`) ran on
  `deepseek-v4.1-flash` (family `deepseek`), stage 2 (`comparator`) ran on
  `claude-sonnet-5` (family `claude`).

## Stage 1 -- read-back (reused verbatim from Session 119, `deepseek-v4.1-flash`)

See `blocks/audits/B-P035-correspondence.md`, "Stage 1 -- read-back" section;
not duplicated here to avoid drift between the two files.

## Stage 2 -- comparison (fresh agent on `claude-sonnet-5`, read-back + contract only)

> MODEL: claude-sonnet-5 (family: claude)
>
> # B-P035 verdict (stage 2, reusing an independently produced stage-1 read-back)
>
> VERDICT: equivalent
>
> JUSTIFICATION: The two shared components common to both Lean predicates
> plausibly correspond to the contract's "L(A) subseteq Lang_r(T_Sigma(A))"
> typing clause and condition 1/BPS1 (nabla-Sat), which are literally
> identical text in both Def1FRL and Def2FRL in the manuscript too -- so the
> read-back's inability to see their content does not block judgment, since
> both directions carry them over unchanged and the contract imposes nothing
> asymmetric there (B-R027 even notes BPS1 is redundant). The remaining
> clauses line up cleanly: IsBPSLanguageFormation's translation-preimage and
> Boolean-closure clauses match BPS2/BPS3 verbatim, and
> IsRegularLanguageFormation's saturation/meet-closure clause matches Def1FRL
> condition 2. The one point requiring care is the inverse-image clause,
> where the read-back's prose ("as in the BPS condition 3 above") could be
> misread as making IsRegularLanguageFormation's and
> IsBPSLanguageFormation's third clauses textually identical -- which would
> clash with the contract, where Def1FRL's condition 3 is the broad "every N
> compatible with Ker(pr o f)" closure while BPS4 is only the narrow
> "f^{-1}[M] in L(A)". However, the theorem-2 proof narrative resolves this:
> it constructs an auxiliary N' = sat(OmegaM, f''(N)), proves N' in L(B), and
> only then invokes "the BPS inverse-image closure" on N' to get
> inverseImage f N' in L(A) before rewriting to N -- a detour that is
> logically unnecessary if BPS's own clause already covered arbitrary
> compatible N directly. This confirms IsBPSLanguageFormation's primitive
> clause is the narrow BPS4-style one, while IsRegularLanguageFormation's
> primitive is the broad Def1FRL-style one, with `regularFormation_inverseImage`
> bridging broad->narrow as a trivial named corollary -- exactly mirroring
> the contract's asymmetric axiomatizations and its own remark that the
> Def2=>Def1 direction is "the more substantive direction ... using the
> epimorphism/pullback structure and BPS2-4." Both proof directions (easy
> Def1=>BPS in theorem 1, substantive BPS=>Def1 via atom/saturation
> decomposition in theorem 2) match the manuscript's proof sketch closely
> enough that I judge this a faithful formalization of B-P035.

## Coordinator verification

Checked directly against `lean/Mslang/Regular.lean` (lines 426-469, 1317-1322,
1816-1822): neither `IsRegularLanguageFormation` nor `IsBPSLanguageFormation`
takes a `Finite S` hypothesis (both are plain `Prop`s over an arbitrary
`Signature S`), and neither do the two target theorems -- consistent with
B-P035 not itself needing S-finiteness (finiteness enters only through
`Lang_r`/`regularLanguages`, which is baked into each predicate's first
conjunct `L A subseteq regularLanguages Sig (termAlg Sig A)`, matching the
manuscript's own `L(A) subseteq Lang_r(T_Sigma(A))` typing clause). The
stage-2 agent's resolution of the broad-vs-narrow inverse-image clause is
confirmed by direct inspection: `IsRegularLanguageFormation`'s fourth
conjunct concludes `∀ N, IsSat (ker (...)) N -> N ∈ L A` (broad), while
`IsBPSLanguageFormation`'s fifth conjunct concludes only
`inverseImage f M ∈ L A` (narrow, just the image of `M` itself) -- exactly
matching Def1FRL condition 3 (broad) versus BPS4 (narrow) in the contract.
No discrepancy found; `equivalent` stands, unlike `B-P034`.
