# Correspondence audit transcript -- `B-P034` (cross-model, mixed stages)

Protocol: Architecture.md Section 11.2, two-stage blind, Section 6 ingestion
pattern (reuse an existing stage-1 read-back with a new-family stage 2). Run
in Session 122 as part of Tier 1 of `blocks/audits/cross-model-audit-brief.md`.
Stage 1 is the pre-existing, same-model read-back from
`blocks/audits/B-P034-correspondence.md` (Session 119, `deepseek-v4.1-flash`,
reused verbatim as the coordinator's stage-1 input). Stage 2 is a fresh,
isolated agent on `claude-sonnet-5` given only that read-back and the
contract -- it was not shown the prior stage-2 verdict.

- **Lean declarations:** same as `blocks/audits/B-P034-correspondence.md`.
- **Contract:** same contract package as
  `blocks/audits/B-P034-correspondence-crossmodel-claude.md`.
- **Outcome:** `formal_stronger` -- **verified against the Lean source** (see
  Coordinator verification below).
- **Recorded as:** see `evidence/` (this file's companion record).
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** cross-model -- stage 1 (`read_back_auditor`) ran on
  `deepseek-v4.1-flash` (family `deepseek`), stage 2 (`comparator`) ran on
  `claude-sonnet-5` (family `claude`).

## Stage 1 -- read-back (reused verbatim from Session 119, `deepseek-v4.1-flash`)

See `blocks/audits/B-P034-correspondence.md`, "Stage 1 -- read-back" section;
not duplicated here to avoid drift between the two files.

## Stage 2 -- comparison (fresh agent on `claude-sonnet-5`, read-back + contract only)

> MODEL: claude-sonnet-5 (family: claude)
>
> # B-P034 verdict (stage 2, reusing an independently produced stage-1 read-back)
>
> VERDICT: formal_stronger
>
> JUSTIFICATION: The core objects and claim line up exactly:
> `finiteAlgebraFormations Sig` is `Form_Alg_f(Sigma)` (algebra formations all
> of whose members are finite), `finiteIndexCongruenceFormations Sig` is
> `Form_Cgr_fi(Sigma)` (congruence formations all of whose members have
> finite index), and `formAlgFFormCgrFiIso` is exactly the claimed order
> isomorphism between them, built as the restriction of the general
> theta_Sigma/theta_Sigma^{-1} correspondence via round-trip identities and
> monotonicity -- matching the manuscript's proof sketch closely. An order
> isomorphism between the two posets does yield the "complete lattices are
> isomorphic" conclusion the contract asks for, since it forces preservation
> of arbitrary joins/meets. However, the manuscript's Assumption B-A001 fixes
> "S finite" as a standing hypothesis for the entire section containing
> B-P034 (justified via B-R024, which links S-finiteness to finiteness of the
> support of term algebras), whereas nowhere in the read-back's theorem list,
> definitions, or the formAlgFFormCgrFiIso interface does any
> `Finite S`/`Fintype S` hypothesis appear -- the sort type S is left
> arbitrary throughout. Since every other piece of the contract is
> reproduced faithfully and only this ambient hypothesis is dropped, the Lean
> development proves the same conclusion under a strictly weaker (or absent)
> assumption, making it formal_stronger rather than equivalent.

## Coordinator verification

Checked directly against `lean/Mslang/Regular.lean`: `grep -n "variable"`
finds only `variable {S : Type u}` (line 19) and `variable {S : Type u}
{A : SSet S}` (line 2214) -- no `[Finite S]`/`Finite S` anywhere in the file.
The full (unabridged) source of `finiteSSet_of_isAlgIso` (line 262),
`congruenceFormationOf_isFiniteIndex` (line 274),
`algebraFormationOfCongruenceFormation_isFiniteAlgebra` (line 283), and
`formAlgFFormCgrFiIso` (line 294) confirms none takes a finiteness hypothesis
on `S`. The stage-2 finding above is correct: the Lean formalizes `B-P034`
for arbitrary `S`, dropping the manuscript's section-wide Assumption `B-A001`.
This is a genuine, source-verified generalization (`formal_stronger`), not an
artifact of an incomplete read-back. It supersedes the `equivalent` verdict
reached by the independent same-model run in
`blocks/audits/B-P034-correspondence-crossmodel-claude.md`, whose stage-2
agent noticed the same absence but underrated its significance; see that
file's "Coordinator correction" section.
