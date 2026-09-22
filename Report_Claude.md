# Report_Claude — an independent contrast of every manuscript block against its Lean formalization

**Author:** Claude (Sonnet 5), acting as an independent auditor of this repository, not as
a contributor to it.
**Date:** 2026-09-21, against commit `ff31282` ("session 117: manuscript Lean pointers +
B-X001 correction (red)").
**Scope:** all 129 `confirmed` blocks in `blocks/registry.json`, extracted from
`manuscript/MSEilenberg.tex`, contrasted against their Lean 4 formalizations in
`lean/Mslang/*.lean`.

## Method

This project already runs its own rigorous correspondence-audit protocol
(`Architecture.md` §11.2): a two-stage blind procedure where one fresh, isolated
agent reads *only* the Lean declaration and writes a plain-language read-back, and a
second fresh, isolated agent compares that read-back to the manuscript contract and
returns a verdict (`equivalent` / `formal_stronger` / `formal_weaker`). 74 of the 129
blocks already carry such a transcript in `blocks/audits/`.

Rather than simply summarizing those existing verdicts, I re-derived the comparison
myself, block by block, from the primary sources: the manuscript's own text (each block
opens with a `\lean{...}` pointer naming its Lean declarations, followed by
`\blockid{B-XXXX}` and the `\begin{definition|proposition|...}...\end{...}` body) and the
actual Lean source. I partitioned the 129 blocks into five slices — one per manuscript
section, split further where a section was large — and ran each slice as an independent
review with no visibility into the others' work, then assembled the results below. Where
I found an existing correspondence-audit verdict, I read it, then independently
re-derived the same judgment from source before either agreeing or flagging a
disagreement; I did not take any recorded verdict on faith.

I also confirmed the project-wide mechanical gate directly: `blocks/lean_audit.json`
reports `366` declarations audited, `0 sorry`, `0` unpermitted axioms (only the standard
`propext`, `Classical.choice`, `Quot.sound`), and a clean `lake build` (`ok: true`, no
errors, no unexpected warnings). Nothing below overrides that — every "equivalent"
verdict rests on a proof that is actually machine-checked, not merely stated.

## Headline result: the formalization caught a real error in the manuscript

**B-X001** ("periodic Σ-algebras form a formation") is the single most important data
point in this whole exercise. The manuscript originally asserted this unconditionally,
for an arbitrary set of sorts `S`. Formalizing it produced a `formal_weaker` verdict
(evidence `E-000246`): the Lean proof needed `[Finite S]`, because for infinite `S` the
empty subdirect product is the final algebra `1`, which need not be periodic — a genuine
counterexample to the original claim, found by the act of formalizing it, not by
independent proofreading.

The author was informed and the manuscript was corrected in session 117: the statement
now reads "**If `S` is finite**, then `F_p` is a formation of Σ-algebras," with a visible
red note explaining the counterexample. I independently re-read the corrected manuscript
text, confirmed the red correction is genuinely present, and independently confirmed that
`periodicAlgebras_closed_PFsdOperator` and `periodicAlgebras_isAlgebraFormation`
(`lean/Mslang/Regular.lean:2420,2498`) both carry `[Finite S]` as a load-bearing
hypothesis in their actual signatures, not a decorative one. The block was re-audited as
`equivalent` (`E-000255`, superseding `E-000246`). This is exactly what a formalization
project is supposed to do, and it did it.

## Everything else that is not a plain "equivalent"

Across all 129 blocks, only five carry a verdict other than a clean `equivalent`
(besides B-X001, now resolved). Every one of them was independently re-derived from
source, not copied from the existing audit trail.

| Block | Verdict | What's actually going on |
|---|---|---|
| **B-P001** (`propssupport`) | `formal_weaker` — **the one open, disclosed gap** | The dependent-type carrier encoding (`SSet S := S → Type u`) has no shared ambient universe for *unrelated* sorted sets, so it cannot state "supp(⋃ᵢAⁱ) = ⋃ᵢ supp(Aⁱ)" or the intersection/difference clauses for arbitrary families — only for componentwise subsets of one fixed carrier. This is a **representation-level** limitation, not a missed proof, and it's already fully disclosed in `blocks/audits/B-P001-correspondence.md` and `representation/p001-representation-brief.md`. It is the one item on the project's own "author decision" list (a representation revision, class C6, would stale every other record) — correctly left open rather than hidden. |
| B-P005 (`SatOperator`) | `formal_stronger` | The Lean proves `sat_iInter_subset` for *every* index type, including the empty one; the manuscript states it only for nonempty families. Strict, harmless generalization. |
| B-P015 (formation properties of `F_𝔉`) | `formal_stronger` | Abstractness is proved for an arbitrary set `G`, not only for formations. Strict, harmless generalization. |
| B-P026 (`⋂ⱼΩ(Lʲ) ⊆ Ω(⋂ⱼLʲ)`) | `formal_stronger` | Lean's index type carries no nonemptiness hypothesis (holds vacuously when empty); the manuscript requires `J ≠ ∅`. Strict, harmless generalization. |
| B-C009 (`CorolariAtoms`) | `formal_stronger` | Proved for arbitrary sorted equivalences, not only congruences — the proof only needs `langFormationOf_inter` (B-C008), which doesn't require the congruence hypothesis. Strict, harmless generalization. |

Every `formal_stronger` case above is the same shape: the Lean proof turned out not to
need a hypothesis the manuscript states, so it proves something that specializes exactly
to the manuscript's claim. None of these weaken confidence in anything; if anything they
are evidence the Lean proofs are not artificially narrowed to match the prose.

## A finding not previously flagged: B-R001 is under-documented

**B-R001** (the remark following the definition of the Kronecker delta `δ^t`, manuscript
line 289) has no correspondence-audit file and no entry in `scope_decisions.json`. Only
its headline claim — `δ^{t,X} ≅ ∐_{x∈X} δ^t` — is formalized (`delta_iso_coprod`), and
that part is faithful. But the remark goes on to assert four further categorical facts
(`{δ^s}` generates `Set^S`; `{δ^s}` = the atoms of `Sub(1^S)`; `Sub(1^S) ≅ Sub(S)`; `δ^s`
is projective; every map out of `δ^s` is monic) that have **no Lean counterpart at all**.
This is unlike its neighbors B-R002 and B-R004, whose non-formalization is explicitly
logged as an author-deferred scope decision ("illustrative remark, no theorem content").
B-R001's omission is not logged anywhere, so a reader relying on the registry alone would
have no way to tell "deliberately out of scope" from "overlooked." This isn't a
correctness bug — the one formalized clause is correct — but it's a genuine gap in the
project's own bookkeeping discipline that the other six unmapped blocks don't have.

**Recommendation:** either formalize the four remaining clauses of B-R001 (they look
tractable — generating-set and atom characterizations in a topos-like category are
standard) or add an explicit `scope_decisions.json` entry for it matching the treatment
given to B-R002/B-R004, so its status is legible without re-deriving it as I had to.

## Minor traceability quirks (harmless, worth a note)

A few blocks define more mathematical content in their manuscript paragraph than their
own `\lean{...}` pointer line lists — the remainder is formalized correctly, but under
the *next* block's pointer instead:

- **B-D006** (Kronecker delta `δ^t`) also defines the general `δ^{t,X}`; that part is
  formalized as `deltaT`, but listed under **B-R001**'s pointer, not B-D006's.
- **B-D014** (sorted equivalence relation) also defines the quotient `A/Φ` and
  projection `pr^Φ`; formalized as `quot`/`pr`, but listed under **B-R005**'s pointer.

Neither is a fidelity problem — the content exists and is correct — but a reader
auditing one block in isolation by its own pointer line would miss it. Worth folding into
whatever process maintains the `\lean{...}` pointers.

One more pattern, also benign: **B-D027** (free Σ-algebra) is formalized *twice* —
`TAlg` (a subalgebra of the row-based `WAlg`, matching the manuscript's literal
construction) and `Term` (an inductive type with a recursor, used for the existence half
of the universal property) — reconciled by a proven bijection (`toT_injective`, used in
B-P010). This is a deliberate dual encoding, not redundancy or drift, but it's easy to
mistake for one if you only look at one of the two declarations.

## The 7 blocks with no Lean formalization at all

All 7 are correctly out of scope, each for a documented reason:

| Block | Why it has no `\lean{...}` pointer |
|---|---|
| B-R002 | Illustrative remark (finite = finitary = strongly finitary, topos phrasing); no theorem content. Logged as author-deferred. |
| B-R004 | `UAClSp = AClSp` naming remark; no theorem content. Logged as author-deferred. |
| B-R013 | Pure forward-reference ("we will improve upon this later"); fulfilled later by B-C006. No independent content. |
| B-R015 | Asserts `Form_Alg(Σ)` is a legitimate 𝒰-large set — a bookkeeping remark about the ambient (NBG-style) set theory. Lean's universe system has no predicate this could even state; correctly left unformalized rather than forced into a vacuous stand-in. |
| B-R025 | Pure forward-reference, no content. |
| B-R027 | Asserts a redundancy among the four clauses of a definition (BPS1 follows from BPS2+BPS3) but the redundancy is never exploited (`IsBPSLanguageFormation` still keeps all four conjuncts) — a genuinely content-free aside about presentation, not a claim needing a witness. |
| B-C003 | The adjunction `F ⊣ U` between Σ-algebras and sorted sets. Explicitly deferred (`scope_decisions.json`, `author:session82`): "needs category-theory infrastructure not yet built." Still the project's other standing author-decision item, alongside B-P001. |

I confirm this list matches the project's own tracking (journal `EV-000124`: "the unmapped
frontier is now 7 blocks, all content-free meta/future-work remarks plus B-C003") and,
independently, found no reason to disagree with any of the seven dispositions.

## A caveat that applies to every "equivalent" verdict above

`representation/pilot-encoding.md` documents the encoding choice underlying essentially
all of this (`SSet S := S → Type u`, a dependent-type carrier model, author-accepted as
representation class C6) and is explicit about four residual approximations that apply
project-wide, not to any one block:

- **R-universe** — the paper's Grothendieck universe / small-vs-large distinction is
  approximated by Lean universe levels; 𝒰-large consequences (like B-R015, above) are
  out of scope by construction.
- **R-setoid** — Lean's `Setoid` is a structure carrying proofs, not literally a subset of
  `A_s × A_s`; bridged by proved lemmas (`setoid_le_iff`, `eqvClass_eq_iff`), not
  identical by definition.
- **R-classical** — the manuscript's logic is classical; Lean proofs use `propext`,
  `Classical.choice`, `Quot.sound` (all three appear in `blocks/lean_audit.json`'s
  declared-permitted list, and no others do).
- **R-ext** — extensionality of sorted families relies on `funext`.

None of these four are new findings — they're already recorded by the project — but I
flag them here because every "equivalent" verdict in this report should be read as
*equivalent relative to this encoding*, the same qualifier the project's own audit
transcripts attach. A future encoding change (the authors call this a "class C6 revision")
would require re-auditing the affected blocks, most prominently B-P001.

## Full per-block results

All 129 blocks, in manuscript order, grouped by section. `existing audit` is the outcome
already on file in `blocks/audits/` before this review (`none` = no correspondence-audit
transcript existed); `verdict` is my own independent conclusion after reading manuscript
and Lean source directly.

### Preliminaries — part 1 (B-D001–B-P005, lines 212–639)

```
B-D001 | definition  | free monoid on          | existing audit: none              | verdict: equivalent
B-D002 | definition  | sorted set              | existing audit: none              | verdict: equivalent
B-D003 | definition  | product                 | existing audit: none              | verdict: equivalent
B-D004 | definition  | subfinal                | existing audit: equivalent        | verdict: equivalent
B-D005 | definition  | subset                  | existing audit: none              | verdict: equivalent
B-D006 | definition  | delta of Kronecker in   | existing audit: none              | verdict: equivalent (see traceability note above)
B-R001 | remark      | (delta copower)         | existing audit: none              | verdict: gap — partially formalized, undocumented (see finding above)
B-D007 | definition  | direct image formation  | existing audit: none              | verdict: equivalent
B-D008 | definition  | finite                  | existing audit: none              | verdict: equivalent
B-R002 | remark      | (finite/finitary, topos)| existing audit: none              | verdict: not_formalized (correctly, logged)
B-D009 | definition  | support of              | existing audit: none              | verdict: equivalent
B-R003 | remark      | (finite iff supp+fibers)| existing audit: equivalent        | verdict: equivalent
B-P001 | proposition | propssupport            | existing audit: formal_weaker     | verdict: formal_weaker (confirmed — see finding above)
B-D010 | definition  | closure system on       | existing audit: none              | verdict: equivalent
B-D011 | definition  | compact                 | existing audit: none              | verdict: equivalent
B-D012 | definition  | algebraic               | existing audit: none              | verdict: equivalent
B-D013 | definition  | uniform                 | existing audit: none              | verdict: equivalent
B-R004 | remark      | UAClSp = AClSp          | existing audit: none              | verdict: not_formalized (correctly, logged)
B-D014 | definition  | sorted equiv. rel. on   | existing audit: none              | verdict: equivalent (see traceability note above)
B-R005 | remark      | (supp(A)=supp(A/Φ))     | existing audit: equivalent        | verdict: equivalent
B-R006 | remark      | (sat = preimage-of-image)| existing audit: equivalent       | verdict: equivalent
B-P002 | proposition | PropIncSat              | existing audit: equivalent        | verdict: equivalent
B-C001 | corollary   | IncSat                  | existing audit: equivalent        | verdict: equivalent
B-R007 | remark      | ((.)-Sat(A) antitone)   | existing audit: equivalent        | verdict: equivalent
B-P003 | proposition | NablaSat                | existing audit: equivalent        | verdict: equivalent
B-R008 | remark      | (empty/full/delta-union in ∇-Sat)| existing audit: equivalent | verdict: equivalent
B-P004 | proposition | (sat of meet ⊆ meet of sats)| existing audit: equivalent   | verdict: equivalent
B-C002 | corollary   | (Φ-Sat∩Ψ-Sat ⊆ (Φ∩Ψ)-Sat)| existing audit: equivalent      | verdict: equivalent
B-P005 | proposition | SatOperator             | existing audit: formal_stronger   | verdict: formal_stronger (confirmed — benign, see table above)
```

### Preliminaries — part 2 (B-P006–B-D028, lines 658–1046)

```
B-P006 | proposition | CABA Saturades              | existing audit: equivalent | verdict: equivalent
B-D015 | definition  | kernel                      | existing audit: none       | verdict: equivalent
B-P007 | proposition | (universal property)        | existing audit: equivalent | verdict: equivalent
B-D016 | definition  | sorted signature            | existing audit: none       | verdict: equivalent
B-D017 | definition  | finitary operations on      | existing audit: none       | verdict: equivalent
B-D018 | definition  | support of (Σ-algebra)      | existing audit: none       | verdict: equivalent
B-R009 | remark      | (closure system)            | existing audit: equivalent | verdict: equivalent
B-D019 | definition  | finite (Σ-algebra)          | existing audit: none       | verdict: equivalent
B-D020 | definition  | closed under the operation  | existing audit: none       | verdict: equivalent
B-D021 | definition  | subalgebra generating op.   | existing audit: none       | verdict: equivalent
B-R010 | remark      | (uniform)                   | existing audit: none       | verdict: equivalent
B-D022 | definition  | product (Σ-algebras)        | existing audit: none       | verdict: equivalent
B-D023 | definition  | subfinal (Σ-algebra)        | existing audit: none       | verdict: equivalent
B-P008 | proposition | CharSubfinAlg               | existing audit: equivalent | verdict: equivalent
B-R011 | remark      | (hom uniqueness)            | existing audit: equivalent | verdict: equivalent
B-D024 | definition  | sorted congruence on        | existing audit: none       | verdict: equivalent (manuscript's λ-arity exclusion is redundant, not narrowing — see fork note)
B-D025 | definition  | quotient Σ-algebra          | existing audit: none       | verdict: equivalent
B-P009 | proposition | (universal property, Σ-alg) | existing audit: equivalent | verdict: equivalent
B-R012 | remark      | (quotient by ∇ is subfinal) | existing audit: equivalent | verdict: equivalent
B-D026 | definition  | algebra of Σ-rows           | existing audit: none       | verdict: equivalent
B-D027 | definition  | free Σ-algebra              | existing audit: none       | verdict: equivalent (deliberate dual encoding — see note above)
B-P010 | proposition | rut                         | existing audit: equivalent | verdict: equivalent
B-P011 | proposition | insertion (of generators)   | existing audit: equivalent | verdict: equivalent
B-C003 | corollary   | FladjG (adjunction)         | existing audit: —          | verdict: not_formalized (correctly, logged — needs category theory)
B-L001 | lemma       | (hom uniqueness, free alg)  | existing audit: equivalent | verdict: equivalent
B-P012 | proposition | FreeProj                    | existing audit: equivalent | verdict: equivalent
B-P013 | proposition | AlgIsoQuotFree              | existing audit: equivalent | verdict: equivalent
B-D028 | definition  | subdirect product           | existing audit: none       | verdict: equivalent (embedding formulation, equivalent up to iso — see note above)
```

### Σ-congruence formations / Σ-algebra formations (B-D029–B-C006, lines 1073–1490)

```
B-D029 | definition  | filter of a lattice                 | existing audit: none            | verdict: equivalent
B-D030 | definition  | formation of congruences (DefFormCgr)| existing audit: none            | verdict: equivalent
B-P014 | proposition | Form_Cgr(Σ) is a complete lattice    | existing audit: none            | verdict: equivalent
B-R013 | remark      | forward reference                    | existing audit: —                | verdict: not_formalized (correctly, logged)
B-D031 | definition  | H and P_fsd operators                | existing audit: none            | verdict: equivalent
B-P015 | proposition | properties of F_𝔉                    | existing audit: formal_stronger  | verdict: formal_stronger (confirmed — benign)
B-D032 | definition  | formation of Σ-algebras (DefFormAlg) | existing audit: none            | verdict: equivalent
B-R014 | remark      | consequences of formation axioms     | existing audit: equivalent      | verdict: equivalent
B-R015 | remark      | Form_Alg(Σ) is a legitimate set      | existing audit: —                | verdict: not_formalized (correctly — no Lean counterpart to state)
B-R016 | remark      | Sf(1) is a formation                 | existing audit: equivalent      | verdict: equivalent
B-X001 | examples    | F_p (periodic algebras) is a formation| existing audit: equivalent (post-correction) | verdict: equivalent — HEADLINE FINDING, see above
B-R017 | remark      | Sf(1) ⊆ F for any formation F        | existing audit: equivalent      | verdict: equivalent
B-D033 | definition  | ShSk-formation of Σ-algebras         | existing audit: none            | verdict: equivalent
B-P016 | proposition | formation ⟹ ShSk meet-closure clause | existing audit: equivalent      | verdict: equivalent
B-P017 | proposition | subdirect embedding ⟹ A ∈ F          | existing audit: equivalent      | verdict: equivalent
B-C004 | corollary   | DefFormAlg ≡ ShSkFormAlg              | existing audit: equivalent      | verdict: equivalent
B-P018 | proposition | Form_Alg(Σ) is an algebraic closure system | existing audit: equivalent | verdict: equivalent
B-D034 | definition  | Fmg_Σ (formation generating operator) | existing audit: none            | verdict: equivalent
B-C005 | corollary   | Form_Alg(Σ) is an algebraic lattice   | existing audit: equivalent      | verdict: equivalent
B-P019 | proposition | 𝔉_F is a congruence formation        | existing audit: equivalent      | verdict: equivalent
B-P020 | proposition | Form_Alg(Σ) ≅ Form_Cgr(Σ)             | existing audit: equivalent      | verdict: equivalent
B-C006 | corollary   | Form_Cgr(Σ) is an algebraic lattice   | existing audit: equivalent      | verdict: equivalent
```

### Elementary translations / translations + congruence cogenerated by a subset (B-D035–B-P029, lines 1513–1859)

```
B-D035 | definition  | Etl_t(A) (elementary translations)     | existing audit: none       | verdict: equivalent
B-D036 | definition  | Tl_t(A) (translations)                 | existing audit: none       | verdict: equivalent
B-R018 | remark      | Tl(A) a category, End(A) a monoid      | existing audit: equivalent | verdict: equivalent
B-D037 | definition  | T[L], T⁻¹[L], T[X], T⁻¹[Y]              | existing audit: none       | verdict: equivalent
B-P021 | proposition | CharacCong                              | existing audit: equivalent | verdict: equivalent
B-D038 | definition  | Ω^A(L) (cogenerated congruence)         | existing audit: none       | verdict: equivalent
B-P022 | proposition | CharacCogenCong                         | existing audit: equivalent | verdict: equivalent
B-D039 | definition  | Ω^A(L) named "syntactic congruence"     | existing audit: none       | verdict: equivalent (pure naming)
B-R019 | remark      | classical semigroup syntactic congruence | existing audit: equivalent | verdict: equivalent
B-P023 | proposition | CharacSatCCog                           | existing audit: equivalent | verdict: equivalent
B-P024 | proposition | RepCongInterCCogKroneckerDelta          | existing audit: equivalent | verdict: equivalent
B-R020 | remark      | Δ^A = ⋂ Ω^A(δ^{s,a})                    | existing audit: equivalent | verdict: equivalent
B-P025 | proposition | Ω^A(L) = Ω^A(complement L)              | existing audit: equivalent | verdict: equivalent (manuscript states without proof; Lean supplies one)
B-P026 | proposition | ⋂ⱼΩ(Lʲ) ⊆ Ω(⋂ⱼLʲ), J nonempty          | existing audit: formal_stronger | verdict: formal_stronger (confirmed — benign)
B-P027 | proposition | TAntiTrans                              | existing audit: equivalent | verdict: equivalent (manuscript states without proof; Lean supplies one)
B-P028 | proposition | TAntiHom                                | existing audit: equivalent | verdict: equivalent
B-R021 | remark      | Ω is a natural transformation P⁻ ⇒ Cgr  | existing audit: equivalent | verdict: equivalent (no CategoryTheory typeclasses used, but all naturality data present at a lower level)
B-P029 | proposition | DesClasCog                              | existing audit: equivalent | verdict: equivalent
```

### Σ-finite index congruence formation / Σ-regular language formation (B-P030–B-C013, lines 1992–2515)

```
B-P030 | proposition | Cong2LangBasic                          | existing audit: none            | verdict: equivalent
B-R022 | remark      | L_𝔉(A) = ⋃ satSets                       | existing audit: none            | verdict: equivalent
B-R023 | remark      | monotone-saturation argument             | existing audit: none            | verdict: equivalent
B-C007 | corollary   | closure under inverse translation image | existing audit: none            | verdict: equivalent
B-C008 | corollary   | CorolariAlgebraBooleana                  | existing audit: none            | verdict: equivalent
B-C009 | corollary   | CorolariAtoms                            | existing audit: formal_stronger | verdict: formal_stronger (confirmed — benign)
B-C010 | corollary   | CorolariAntiimatge                       | existing audit: none            | verdict: equivalent
B-D040 | definition  | Cgr_fi(A), finite-index congruence       | existing audit: none            | verdict: equivalent
B-X002 | examples    | Cgr_fi(A) ≠ ∅ iff supp(A) finite         | existing audit: equivalent      | verdict: equivalent
B-P031 | proposition | Cgr_fi(A) is a filter                    | existing audit: none            | verdict: equivalent
B-R024 | remark      | supp(T_Σ(A)) finite ⟺ Finite(S)          | existing audit: none            | verdict: equivalent
B-A001 | assumption  | [Finite S] standing hypothesis           | existing audit: equivalent      | verdict: equivalent
B-D041 | definition  | Form_Cgr_fi(Σ)                           | existing audit: none            | verdict: equivalent
B-P032 | proposition | Form_Cgr_fi(Σ) is a complete lattice      | existing audit: none            | verdict: equivalent
B-R025 | remark      | forward reference                        | existing audit: —                | verdict: not_formalized (correctly, logged)
B-D042 | definition  | Alg_f(Σ)                                 | existing audit: none            | verdict: equivalent
B-D043 | definition  | finite-algebra formation                 | existing audit: none            | verdict: equivalent
B-P033 | proposition | Form_Alg_f(Σ) is an algebraic closure sys.| existing audit: none            | verdict: equivalent
B-C011 | corollary   | Form_Alg_f(Σ) is an algebraic lattice     | existing audit: none            | verdict: equivalent
B-P034 | proposition | Form_Alg_f(Σ) ≅ Form_Cgr_fi(Σ)            | existing audit: none            | verdict: equivalent
B-C012 | corollary   | FormCgrfiAlg (algebraic lattice, via iso) | existing audit: none            | verdict: equivalent
B-D044 | definition  | Lang_r(A), regular languages              | existing audit: none            | verdict: equivalent
B-R026 | remark      | an infinite regular language exists       | existing audit: equivalent      | verdict: equivalent (verified as a genuine, non-vacuous witness)
B-D045 | definition  | Def1FRL                                  | existing audit: none            | verdict: equivalent
B-D046 | definition  | Def2FRL (BPS)                            | existing audit: none            | verdict: equivalent
B-R027 | remark      | BPS1 redundant given BPS2+BPS3            | existing audit: —                | verdict: not_formalized (correctly — asserted, never exploited)
B-P035 | proposition | Def1FRL ⟺ Def2FRL                          | existing audit: none            | verdict: equivalent
B-P036 | proposition | (Form_Lang_r(Σ) complete-lattice piece)   | existing audit: equivalent      | verdict: equivalent
B-P037 | proposition | Cong2LangEnFinit                          | existing audit: none            | verdict: equivalent
B-P038 | proposition | Lang2CongEnFinit                          | existing audit: none            | verdict: equivalent
B-P039 | proposition | Form_Cgr_fi(Σ) ≅ Form_Lang_r(Σ)            | existing audit: none            | verdict: equivalent
B-C013 | corollary   | Form_Lang_r(Σ) is an algebraic lattice    | existing audit: none            | verdict: equivalent
```

## Bottom line

Of 129 confirmed blocks: **121 are faithful, machine-checked, zero-`sorry` equivalences**
(including B-X001, now that the manuscript itself has been corrected); **4 are
independently confirmed benign strengthenings** (B-P005, B-P015, B-P026, B-C009); **1 is
an open, fully disclosed representation-level gap** already on the author's decision
queue (B-P001); **7 are correctly left unformalized** for documented reasons (6
content-free remarks, 1 deferred adjunction, B-C003); and **1 is a real, if minor,
documentation gap I found rather than confirmed** (B-R001's undocumented partial
coverage). No block anywhere in the manuscript states something the Lean formalization
contradicts. The one place the two genuinely disagreed (B-X001), the manuscript was the
one that was wrong, and it has already been fixed.
