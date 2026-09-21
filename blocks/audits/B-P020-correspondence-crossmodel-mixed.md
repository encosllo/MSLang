# Correspondence audit transcript -- `B-P020` (cross-model, mixed stages)

Protocol: Architecture.md Section 11.2, two-stage blind, Section 6 ingestion
pattern (reuse an existing stage-1 read-back with a new-family stage 2). Run in
Session 122 as part of Tier 1 of `blocks/audits/cross-model-audit-brief.md`.
Stage 1 is the pre-existing, same-model read-back from
`blocks/audits/B-P020-correspondence.md` (Session 119, `deepseek-v4.1-flash`,
reused verbatim as the coordinator's stage-1 input, per Section 6's example
`--stage read_back_auditor=deepseek-v4.1-flash --stage comparator=<MODEL_ID>`
command). Stage 2 is a fresh, isolated agent on `claude-sonnet-5` given only
that read-back and the contract -- it was not shown the prior stage-2 verdict
or any other project material.

- **Lean declarations:** same as `blocks/audits/B-P020-correspondence.md`
  (`Mslang.congruenceFormations`, ..., `Mslang.formAlgFormCgrIso`,
  `lean/Mslang/Formation.lean`).
- **Contract:** Proposition `B-P020` plus `B-D030`, `B-D031`, `B-D032`,
  `B-P015`, `B-P019` (same contract package as
  `blocks/audits/B-P020-correspondence-crossmodel-claude.md`).
- **Outcome:** `equivalent`
- **Recorded as:** see `evidence/` (this file's companion record).
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** cross-model -- stage 1 (`read_back_auditor`) ran on
  `deepseek-v4.1-flash` (family `deepseek`), stage 2 (`comparator`) ran on
  `claude-sonnet-5` (family `claude`); the two stages span two model families,
  so this record independently corroborates the fully-fresh double-`claude`
  redo in `blocks/audits/B-P020-correspondence-crossmodel-claude.md` (which
  itself classifies `same_model` since both of its stages ran on `claude`).

## Stage 1 -- read-back (reused verbatim from Session 119, `deepseek-v4.1-flash`)

See `blocks/audits/B-P020-correspondence.md`, "Stage 1 -- read-back" section,
reproduced there in full; not duplicated here to avoid drift between the two
files. The coordinator pasted that section verbatim (Lean-only content, no
verdict) as the sole material for the stage-2 agent below.

## Stage 2 -- comparison (fresh agent on `claude-sonnet-5`, read-back + contract only)

> MODEL: claude-sonnet-5 (family: claude)
>
> # B-P020 verdict (stage 2, reusing an independently produced stage-1 read-back)
>
> VERDICT: equivalent
>
> JUSTIFICATION: The read-back's `formAlgFormCgrIso Sig : algebraFormations Sig
> ≃o congruenceFormations Sig`, built from the mutually-inverse monotone maps
> `thetaSigma`/`thetaSigmaInv` (equivalently `congruenceFormationOf`/
> `algebraFormationOfCongruenceFormation` with the two proved inverse
> identities), is exactly the order isomorphism the contract (B-P020) asks for
> between Form_Alg(Sigma) and Form_Cgr(Sigma). The underlying data definitions
> line up precisely: the inferred `IsCongruenceFormation` (nonempty,
> finite-intersection-closed, upward-closed family, plus the pullback clause
> "Psi in G B and g a hom with prB∘g surjective => ker(prB∘g) in G A") matches
> B-D030's filter condition plus its Theta-epimorphism pullback clause
> verbatim, and `IsAlgebraFormation` (H-closure and PFsd-closure) matches
> B-D032 exactly; likewise `congruenceFormationOf` and
> `algebraFormationOfCongruenceFormation` match B-P019/B-P015's definitions
> term for term. Since both sides are independently established as complete
> lattices (B-P014, B-C005/PFsd background -- not reproved in this file but
> not needed to be, as completeness is a per-lattice fact), a proven order
> isomorphism (`≃o`, both order-preserving and order-reflecting per
> `map_rel_iff'`) between them automatically transports arbitrary meets/joins,
> so it is equivalent to the "complete lattices are isomorphic" claim of
> B-P020, not a weaker poset-only substitute. No hypothesis is dropped or
> extra hypothesis added on either side (monotonicity, the pullback clause,
> and both inverse identities are all present and used exactly as the
> manuscript's proof sketch describes). No gap in quantifiers, degenerate
> cases (e.g. subfinal/bottom formation handled by
> `subfinalAlg_mem_of_formation`), or direction of implication that would push
> this to formal_stronger/weaker/incomparable.
