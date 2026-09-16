# Architecture: Concurrent Mathematical Development and Formal Verification (Local-First)

> **Status: normative, revision 2 (pilot-hardened).** This is the single
> normative specification. `Consolidated.md` is a superseded summary retained
> only for history; where the two differ, this document governs.
>
> Revision 2 folds in what was learned by running revision 1 end to end on a
> real pilot. The substantive additions are: the formal *representation* is an
> audited artifact with its own layer (Section 11.5); evidence inputs are
> computed from the dependency graph rather than authored (Sections 7.2,
> 12.3); dependency extraction is strengthened by symbol usage and prose-name
> detection (Section 12.1); Lean statement and proof facets are hashed
> separately so proof irrelevance holds on the formal side too (Sections 6,
> 13.1); reconstructing informal proofs from formal ones is a first-class
> deliverable (Section 11a.5); process intensity is tiered so the default path
> is light (Sections 6, 17.2); and model diversity is scheduled rather than
> merely disclosed (Sections 9, 11.4). A running change log is at the end
> (Section 25).

## 1. Executive Summary

This document describes a research workspace in which informal mathematical
development and formal Lean verification proceed simultaneously rather than
sequentially. The workspace maintains a continuously audited correspondence
between an evolving manuscript, its Lean counterparts, and the verification
evidence attached to both.

Everything runs locally, against a self-contained, pinned Lean/Mathlib
project. There is no external verification platform, mission, or
registration step: the safeguard machinery - evidence records, typed
correspondence audits, independent blind review, seeded-mismatch
calibration - stands on its own and does not depend on any third-party
infrastructure.

The design rests on seven decisions, the first four carried over from
extensive practical use, the fifth added from that same experience, and the
last two added by running the first five on a real pilot:

1. **Evidence, not status labels.** Every claim about a block (reviewed,
   audited, verified) is an evidence record whose validity is determined
   mechanically by the revisions of its inputs. Status is derived from
   evidence; it is never asserted.
2. **Statements and proofs are separate artifacts.** Dependents rely on the
   statements of what they use, not on their proofs. A proof revision
   therefore never invalidates downstream work, while a statement or
   definition revision invalidates exactly its downstream closure.
3. **Correspondence is a typed relation.** An audit records not only
   *whether* a Lean statement matches the intended claim but *how*
   (equivalent, stronger, weaker, incomparable), which determines what the
   formal proof actually establishes.
4. **Verification is local and self-contained.** A pinned Lake project with
   its own toolchain and package cache is the sole source of formal
   verification evidence. Nothing about the workspace depends on an
   external service being available, unchanged, or even used at all.
5. **Freshly written informal proofs get the same adversarial scrutiny as
   formal ones.** A proof that reads smoothly is not the same as a proof
   that is correct, whether it is a Lean tactic script or a paragraph of
   prose. The workspace applies a blind, no-memory adversarial read to new
   mathematical writing itself, not only to the correspondence between
   informal and formal statements.
6. **The formal representation is itself audited.** How the paper's notions
   are encoded in Lean - types versus sets, the meaning of subset and of
   componentwise operations, coercion and truncation conventions, the ambient
   set-theoretic universe - is a first-class object with its own correspondence
   to the paper's foundation. A statement audit is meaningless until the
   encoding it is stated against has been accepted (Section 11.5).
7. **Evidence inputs are computed, and scrutiny is tiered.** The coordinator
   derives each record's input closure from the dependency graph, so an
   evidence record cannot silently omit a dependency (Sections 7.2, 12.3); and
   the default treatment is light, with full adversarial treatment reserved
   for a small cabinet of load-bearing blocks (Sections 6, 17.2).

## 2. Problem and Motivation

Formalization is usually undertaken after the mathematics has stabilized. At
that point, most of its diagnostic value is lost: a missing hypothesis
discovered during formalization of a published paper leads to an erratum,
whereas the same discovery during drafting leads to a better theorem.

Running both activities concurrently is attractive but hard, for three
reasons:

- **Moving targets.** Definitions and statements change during research.
  Formal artifacts tied to earlier versions silently drift out of sync.
- **Faithfulness.** A Lean proof certifies a Lean statement. Whether that
  statement expresses the intended mathematics is a separate question that
  no kernel answers.
- **Heterogeneous evidence.** Human review, agent review, correspondence
  audits, and kernel checks provide different kinds of assurance. Collapsing
  them into one "done" flag hides exactly the information an author needs.

The workspace addresses these three problems directly. Formalization is
used not only to verify completed mathematics but also to:

- detect missing or superfluous hypotheses;
- reveal hidden dependencies (formal proofs using facts the informal proof
  does not cite, and vice versa);
- expose ambiguous or inconsistent definitions;
- identify gaps in arguments;
- produce reproducible counterexamples, disproofs, and precisely stated
  formal blockers.

A fourth problem, learned rather than anticipated, is added here because it
turned out to matter as much as the first three: **freshly written prose is
not automatically correct just because it compiles as LaTeX and reads
smoothly.** A manuscript-editing session on a mature project once introduced
a genuine mathematical gap in a new proof; it was caught only because the
same skepticism normally reserved for Lean/manuscript correspondence was
turned, deliberately, on the new prose itself. Section 11a generalizes that
practice.

## 3. Related Work and Positioning

The proposal builds on established practice and should be judged against
it.

| Prior work | What it provides | What this proposal adds |
|---|---|---|
| Lean blueprints (`leanblueprint`) as used in the PFR, FLT, and similar projects | LaTeX document linked to Lean declarations; dependency graph from `\uses`; progress markers (`\leanok`) | Revisioned blocks, evidence records with automatic staleness, typed correspondence audits, and a workflow designed for manuscripts that are still changing |
| Large collaborative formalizations (e.g. PFR, the Equational Theories Project) | Concurrent human formalization at scale, often of freshly proved results | A single-author or small-team setting with agent workers, where the manuscript's own definitions and statements are still changing and must be kept in sync automatically |
| Autoformalization research | Automatic translation of informal statements into formal ones | Treats translation output as untrusted; faithfulness is established by a separate audit protocol, not by the translator |
| Standard code review / referee practice | A second reader catches what the author no longer sees | A blind, structured protocol - the reader is denied the "intended" text and must reconstruct it, applied uniformly to formal correspondence *and* to informal proof correctness |

The claimed contribution is therefore not concurrency by itself, nor
read-back by itself, but the combination of:

1. an evidence model in which staleness is computed rather than tracked by
   hand;
2. a propagation rule that respects the statement/proof distinction;
3. a correspondence audit protocol that is typed, blind, calibrated, and
   re-run on change;
4. the use of discrepancies between the informal and formal dependency
   graphs as a research signal;
5. a blind adversarial-read protocol applied to informal mathematical
   writing on its own terms, independent of any formal counterpart;
6. an explicit, tested discipline for keeping long agentic working sessions
   coherent across days of work without external process support;
7. an audited representation layer together with computed evidence closures,
   so that the two ways verification most often becomes meaningless - a wrong
   encoding and an omitted dependency - are caught mechanically rather than by
   vigilance;
8. reconstruction of omitted informal proofs from their formal counterparts,
   which turns verification from a check on the writing into a source of it.

## 4. Scope and Non-Goals

**In scope:** research manuscripts in LaTeX whose central results are, at
least in part, formalizable in Lean 4 with Mathlib; single-author or
small-team projects; human and agent workers; long-running, multi-session
agentic work on a single manuscript.

**Non-goals:**

- Replacing peer review or the author's mathematical judgment.
- Fully automatic formalization of arbitrary manuscripts.
- Guaranteeing faithfulness. The system makes faithfulness auditable and
  measurable; it cannot make it certain.
- Formalizing every sentence. Each block declares its formalization scope
  (Section 6).
- Depending on, or integrating with, any third-party verification platform.
  If external registration is ever wanted later, it is an optional adapter
  bolted onto an already-complete local system (Section 15.4), never a
  load-bearing part of it.

## 5. Design Principles

Each principle is stated together with its operational consequence.

| # | Principle | Consequence in the system |
|---|---|---|
| P1 | Mathematics and formalization evolve together. | Either side may lead; neither is a prerequisite for starting work on the other. |
| P2 | Every claim is revisioned and traceable. | Each facet of each block has a content hash and a revision history. |
| P3 | Review, correspondence, and verification are distinct kinds of evidence. | They are stored as separate evidence records and never merged into a single flag. |
| P4 | Evidence becomes stale when its inputs change. | Validity is computed by comparing recorded input hashes with current hashes. |
| P5 | Formal verification does not replace mathematical understanding. | A verified, faithfully audited claim is *true*; the informal proof is still reviewed for correctness and exposition before it is *manuscript-ready*. |
| P6 | No verified result is silently rewritten. | Changes to verified or frozen statements create new revisions and require an author decision record. |
| P7 | The author holds authority over mathematical contracts. | Agents may propose changes to statements and definitions; only the author can accept them. Agents also never unilaterally mint new tracked blocks, change scope, or make a freeze/registration-style decision - they present the decision and stop. |
| P8 | Completion is established by evidence, never by assertion. | A worker's report that a task is finished has no effect on status. |
| P9 | All decisions remain auditable. | Every state change is an event in an append-only journal. |
| P10 | Newly written informal proofs are adversarially checked, not just formal ones. | Any substantial new or rewritten manuscript proof gets a self-re-read pass, and - before it is trusted - an independent no-memory adversarial read (Section 11a), whether or not it is formalized yet. |
| P11 | Session continuity is a first-class deliverable, not an afterthought. | A single running narrative log records what happened, what was deferred, and what to do next, and is kept current even under a tight remaining budget (Section 16). |
| P12 | The formal representation is an audited artifact, not an assumption. | Encoding choices are recorded with their own hash and audited against the paper's foundation before any statement audit relies on them (Section 11.5). |
| P13 | Evidence inputs are computed, never asserted. | The coordinator derives each record's input closure from the dependency graph; a check whose closure cannot be resolved does not run (Sections 7.2, 12.3). |
| P14 | Scrutiny is tiered to value. | Full adversarial treatment is reserved for a small cabinet of load-bearing blocks; the default path is light, and blocks escalate into the cabinet on risk or finding (Sections 6, 17.2). |

## 6. Core Concepts

**Block.** The unit of tracking: a definition, lemma, theorem, construction,
proof fragment, or substantial intermediate claim. Each block has a
persistent identifier independent of theorem numbering and file location.

**Facets.** A block is composed of separately hashed artifacts:

| Facet | Content |
|---|---|
| Informal statement | The claim as written in the manuscript, including hypotheses |
| Informal proof | The argument as written in the manuscript |
| Formal statement | The declared type (elaborated signature) of the Lean declaration |
| Definition closure | The statements of the declarations the block's formal statement transitively uses (Section 12.3), keyed on declaration identity rather than on block membership |
| Formal proof | The Lean proof term or tactic script, hashed separately from the statement so that a proof rewrite is irrelevant to statement-dependent evidence |
| Explanation | A prose reconstruction of a proof from its formal counterpart, produced when the manuscript omits or under-specifies the argument (Section 11a.5); semantically load-bearing, unlike exposition |
| Exposition | Surrounding prose, remarks, and motivation (no semantic weight) |

**Statement versus definition closure.** The formal statement and its definition
closure are hashed as separate facets, and the closure is keyed on the identity
of the declarations it uses, not on the blocks that own them. An earlier design
folded the closure into the statement hash; in practice that made a purely
bookkeeping edit - moving a helper declaration from the block whose proof first
introduced it to the block whose contract it actually formalizes - look exactly
like a change of claim, and forced re-issues whose audit content was unchanged
(Section 13.2). Keeping the two apart lets definition *content* propagate to
dependents (a definition change is still a change to their closure) while
bookkeeping - which block owns a declaration - does not.

**Declaration ownership.** A declaration belongs to the block whose contract it
formalizes, even when it was first written to support some other block's proof.
Helpers that are introduced inside a proof but formalize a later block (a
product, a generated subalgebra, a quotient) are therefore registered against
that later block, and the earlier proof depends on them only through the
definition closure. Section 13.2 (class C5) governs the remap.

**Representation (encoding).** The mapping from the paper's notions to Lean
ones: the carrier model (types versus sets), the meaning of subset and of
componentwise union/intersection/difference, coercion and truncation
conventions, and the treatment of the ambient set-theoretic universe. It is
recorded as a project-level artifact (refined per definition cluster), has its
own content hash, and is audited against the paper's foundation (Section 11.5),
because a statement audit is only meaningful *relative to an accepted
representation*. A single encoding choice can silently determine the outcome
of many statement audits; that is why it is audited once, centrally, rather
than rediscovered block by block.

**Closure.** The set of artifacts an evidence record actually examined,
computed from the dependency graph (Section 12.3): a block's own relevant
facets plus the *statements* (not the proofs) of the blocks in its transitive
dependency closure. Closures are derived, never hand-listed (P13), so an
under-specified record is unrepresentable rather than merely discouraged. On
the formal side, the content of that closure over Lean declarations is captured
by the `definition_closure` facet (Section 7.2); the two are related but not
identical - the input closure also carries informal statements, the
representation hash, and the environment where the layer needs them.

**Treatment tier.** Whether a block takes the light or the full path
(Section 17.2). The default is light; full adversarial treatment is reserved
for the cabinet and granted on promotion.

**Mathematical contract.** The informal statement together with the
definitions it depends on, as accepted by the author. The contract is the
reference against which correspondence is audited. A contract is *frozen*
when the author declares it stable; freezing has no platform consequence by
default, it simply means further changes require an explicit decision
record rather than a routine edit (Section 13.2).

**Formalization scope.** Declared per block:

- *Full*: formal statement and formal proof are both required.
- *Statement-only*: the statement is formalized and audited, but its proof
  is left open (an explicit, visible entry in the trust boundary).
- *Out of scope*: no formal counterpart (for example, motivational remarks
  or results relying on theory far outside Mathlib). Such blocks rely on
  mathematical review alone.

**Evidence record.** A signed, immutable record stating that a particular
check was performed on particular inputs with a particular outcome
(Section 7).

**Trust boundary.** The set of everything the verified results rest on
without being proved within the project: open reductions, statement-only
blocks, cited external results, and non-standard axioms.

## 7. Evidence Model

### 7.1 Three Questions

For every block, the system tracks three independent questions.

| Evidence layer | Question | Typical producer |
|---|---|---|
| Mathematical review | Is the informal claim justified by the informal proof? | Agent reviewers, the author, external experts |
| Correspondence audit | Does the Lean statement express the contract, and in which direction? | Blind read-back auditor and comparator |
| Formal verification | Does Lean's kernel accept the proof of the Lean statement, under the permitted axioms? | Local Lean build |

A verified Lean theorem is not automatically a verified manuscript claim,
and a reviewed manuscript proof does not imply successful formal
verification. All three questions are additionally conditioned on an accepted
*representation* (Section 6): a correspondence audit is meaningless until the
encoding it is stated against has itself been audited (Section 11.5).

### 7.2 Evidence Records

Every piece of evidence is stored as a record of the form. Records are **JSON**
(one file per record, `evidence/E-XXXXXX.json`); the format is fixed to JSON so
that schema validation needs no third-party parser and can never be skipped:

```json
{
  "evidence_id": "E-000731",
  "layer": "correspondence",
  "block": "B-0142",
  "inputs": [
    {"artifact": "B-0142/formal_statement", "hash": "9c1e..."},
    {"artifact": "B-0142/definition_closure", "hash": "7b31..."},
    {"artifact": "B-0142/informal_statement", "hash": "44ab..."},
    {"artifact": "D-0007/formal_statement", "hash": "e02f..."}
  ],
  "environment": {"lean": "<pinned>", "mathlib": "<pinned rev>"},
  "git_commit": "4f21a9c",
  "producer": {"kind": "agent", "role": "comparator", "model": "<id>", "prompt_rev": "<hash>"},
  "outcome": "formal_stronger",
  "strength": "R2",
  "independence_caveat": "Two-stage blind protocol (Section 11.2): a fresh subagent read back the Lean without seeing the manuscript, a second fresh subagent compared that reading to the contract. Both subagents still share this session's underlying model, so shared blind spots are not ruled out.",
  "findings": ["Lean version drops finiteness hypothesis; still implies contract"],
  "timestamp": "2026-09-11T10:42:00Z"
}
```

(`layer` is one of `review` / `correspondence` / `verification`; `inputs` are
the exact artifacts examined, by content hash, including the definition-closure
facet wherever the layer depends on it (Section 12.3); `outcome` is from
Section 7.4; `strength` from Section 7.3, review layer only; `git_commit` is
optional.)

Two optional fields record supersession *provenance*: `supersedes` (the
`evidence_id` this record replaces) and `reissue_reason` (`hash-move`,
`env-bump`, `remap`, `facet-split`, or `other`). They are recorded whenever a
check is re-run on inputs that moved without the audited content changing, and
let a report name the successor and the reason.

The *classification* of stale records does not depend on those fields - a
mechanism that required every re-issue to carry them would mislabel every
re-issue made before the fields existed. It is layer-based instead (Section
8.1): a stale record is **superseded** when its block and layer still has a
current record (the work was redone), and **awaiting re-audit** only when its
layer has no current evidence at all. This is what lets a long history of
mechanical re-issues - representation changes, environment bumps, hash moves,
declaration remaps - read as bookkeeping rather than as a backlog of unverified
claims, without retrofitting provenance onto immutable records.

**Validity rule.** An evidence record is *current* if and only if every
input hash equals the current hash of that artifact. Otherwise it is
*stale*. Stale evidence is not false: it remains a true statement about the
recorded inputs. It is simply no longer evidence about the current block.

The choice of inputs is where the statement/proof distinction enters. For
example, the review of theorem T's informal proof takes as inputs T's
informal statement, T's informal proof, and the *statements* (not the
proofs) of the blocks T cites. A change to a cited lemma's proof therefore
leaves T's review current.

**Inputs are generated, not authored.** The input list above is produced by
the coordinator from the dependency graph (Section 12.3), never typed by
whoever runs the check. The tool expands a block to its own relevant facets
plus its transitive statement-closure, resolves each to a content hash, and
refuses to emit a record whose closure cannot be fully resolved - a missing or
ambiguous edge is a blocker, not a silently dropped dependency. This removes
*by construction* the most damaging failure mode observed in practice: an
evidence record that looks complete but omits a dependency, so that a real
change fails to invalidate it.

**Statement/proof separation on the formal side.** A Lean declaration
contributes three independently hashed facets: `formal_statement` (its
elaborated type), `definition_closure` (the statements of the declarations it
transitively uses, Section 12.3), and `formal_proof` (its term or script).
Correspondence and every statement-dependent record bind to
`formal_statement` together with `definition_closure`; only the block's own
verification record lists `formal_proof`. A proof rewrite therefore stales only
that block's verification, not the correspondence of everything that uses its
statement - the formal-side counterpart of the informal rule above - while a
definition change propagates through `definition_closure` and a remap of a
declaration between blocks does not, because the closure names declarations, not
blocks (Section 6).

**Which layers a block owes depends on its kind.** A definition or a bundled
structure carries *verification only*: it makes no assertion to correspond to,
and its faithfulness is the job of the central encoding audit (Section 11.5),
not of per-block counterparts. A proposition, theorem, lemma, or corollary
carries correspondence and verification, plus review when the manuscript
supplies an informal proof (or an Explanation, Section 11a.5); one the
manuscript states without proof carries correspondence and verification only. A
remark or example carries whatever layers its content actually supports -
typically correspondence and verification, with review only if the author
asserts a proof. This convention is normative: it is why the frontier report
does not list a definition as missing a correspondence layer.

**Schema validation.** Records are machine-validated against a checked-in
schema. An unknown key (for example a misspelled `independence_caveat`) or a
missing required field is a hard error, not silently ignored: evidence whose
metadata the tooling does not parse is not evidence.

**On `independence_caveat`.** Every evidence record from an agent producer
must state plainly how independent the check actually was: a same-session
self-check, a two-stage blind protocol sharing this session's model, or
something stronger. Practice has shown this field is not decorative - a
project can accumulate many self-checked "pass" statuses that look settled
until the first genuinely independent read finds something a self-check
missed (Section 11.2's motivating case). Before treating any block's status
as more than provisional, read this field, not just the outcome.

The optional `git_commit` field is provenance for exact reconstruction
("what did the repo actually contain when this check ran"), not part of the
correctness mechanism - the validity rule above is defined purely in terms
of facet content hashes, so a commit that changes nothing content-wise (a
rebase, a file move, a `git commit --amend` of an unrelated file) never
spuriously invalidates anything. See Section 10.5 for why git history
matters here at all.

### 7.3 Strength of Mathematical Review

Review evidence varies greatly in reliability, and the model records this
explicitly.

| Level | Meaning |
|---|---|
| R0 | No review |
| R1 | A single agent review (typically a same-session self-check) |
| R2 | At least two agent reviews with isolated contexts; disagreements escalated to the author |
| R3 | Author sign-off |
| R4 | External expert review |

The project sets minimum levels per block class, and the levels are *tiered*
(Section 17.2). Cabinet blocks carry the full requirement: R3/R4 for headline
results and definitions, with an independent adversarial read of the informal
proof. Light-path blocks need only current verification plus an R1
self-check, and are promoted into the cabinet when a finding, a mismatch, or a
change on the critical path warrants it.

### 7.4 Typed Correspondence

A correspondence audit returns one of the following outcomes, relative to
the contract:

| Outcome | Meaning | What a formal proof then establishes |
|---|---|---|
| `equivalent` | The Lean statement expresses the contract | The contract |
| `formal_stronger` | The Lean statement implies the contract (weaker hypotheses or stronger conclusion) | The contract, and more |
| `formal_weaker` | The contract implies the Lean statement, not conversely | Only a special case; the block remains partially verified |
| `incomparable` | Neither implies the other | Nothing about the contract |
| `ill_posed` | The formalization is vacuous, ill-typed in spirit, or relies on unintended conventions (for example truncated subtraction or division by zero) | Nothing; formalization must be revised |

For definitions, only `equivalent` is acceptable. Where the project's
definition coincides with an existing Mathlib notion, the audit is
strengthened by a formally proved *bridge lemma* establishing the
equivalence, which turns a judgment into formal evidence.

A clean `equivalent` verdict after genuine skeptical scrutiny is itself a
useful result, not a sign the audit was too easy - most independent audits
in practice confirm rather than overturn, and that confirmation is worth
recording with the same care as a caught defect.

**The verdict is relative to a representation.** An outcome is always
"the Lean statement matches the contract *as encoded by representation R*".
This is why a non-`equivalent` verdict must be attributed before it is acted
on: it may reveal a defect in the statement, or it may reveal that R itself
does not faithfully model the paper (for example, because the paper's ambient
set-theoretic universe has no exact counterpart in the chosen carrier model).
The two have opposite remedies - revise the statement, or revise the
representation - and conflating them sends work in the wrong direction. The
comparator therefore reports *which layer* the discrepancy lives in; the
encoding layer is audited separately and first (Section 11.5).

### 7.5 Derived Guarantees

Two derived notions replace the single, ambiguous notion of "completion":

- **Truth-established.** Either (a) the representation covering the block is
  current and not `unfaithful` (Section 11.5); formal verification is current;
  correspondence is current with outcome `equivalent` or `formal_stronger`;
  *and* every item in the block's trust boundary (including any
  `faithful-with-caveat` residual) is itself truth-established or explicitly
  accepted by the author; or (b) the block is out of formal scope and its
  review meets the required strength.
- **Manuscript-ready.** Truth-established, *and* the informal proof has
  current review at the required strength, *and* the informal proof has
  passed at least one adversarial read (Section 11a) since its last
  substantial revision, *and* no open findings remain on the exposition.

This makes P5 and P10 precise: formal verification can establish truth, but
a manuscript still needs a correct and readable informal argument, checked
on its own terms.

## 8. Status Model

Each layer independently carries its own status, and the overall block
status is derived - never a single linear lifecycle.

### 8.1 Layer Status

Each of the three layers is in exactly one of these states:

| State | Meaning |
|---|---|
| `none` | No work yet |
| `in_progress` | Work assigned, no evidence yet |
| `pass` | Current evidence with a positive outcome |
| `fail` | Current evidence with a negative outcome (finding, mismatch, failed build, disproof) |
| `blocked` | A classified blocker prevents progress (Section 10.2) |
| `stale` | The most recent evidence is no longer current |

A `stale` layer returns to `in_progress` when rework is scheduled, or
directly to `pass` when an author decision record carries the evidence
forward (for example after a purely editorial change; see Section 13.2).

At the record level, a stale record is **superseded** when its block and layer
still has a current record, and **awaiting re-audit** otherwise (Section 7.2).
A layer is `pass` whenever it has current evidence, so its stale records are
superseded history; a layer is `stale` only when it has no current evidence, in
which case its stale records are genuinely outstanding. The optional
`supersedes`/`reissue_reason` fields name the successor and the reason but are
not required for this classification, so a run of mechanical re-issues (an
environment bump, a hash move, a declaration remap) does not read as a backlog
of unverified claims.

### 8.2 Derived Block Status

```text
Draft --> Developing --> Truth-established --> Manuscript-ready
              ^                  |                     |
              `---- a layer becomes stale -------------+

Developing --> Refuted      (disproof or counterexample recorded)
Developing <-> Blocked      (a layer is blocked with a classified reason; returns when resolved)
any state  --> Superseded   (identity retired via split, merge, or deprecation)
```

- **Draft:** the contract is not yet accepted by the author.
- **Developing:** the contract is accepted; at least one layer is not `pass`.
- **Truth-established / Manuscript-ready:** as defined in Section 7.5.
- **Refuted:** a formal disproof or a reviewed counterexample exists. This is
  a valuable outcome, not a failure of the system.
- **Superseded:** the block's identity was retired; its history is preserved
  and a pointer to its successor is recorded.

### 8.3 Treatment Tiers

Independently of the derived status, each block carries a *treatment tier*
(Section 17.2):

| Tier | Evidence required |
|---|---|
| `light` (default) | current verification; correspondence only where scope requires it; R1 self-check |
| `cabinet` | current verification; current correspondence; independent adversarial read of the informal proof; R3/R4 review |

A block enters the cabinet by author designation (a headline result or a
load-bearing definition) or by promotion (a finding, a mismatch, or a change
whose blast radius crosses the critical path). It leaves the cabinet only by
author decision. The tier governs *scrutiny*, not *truth*: a light block can
be truth-established; it is simply not yet held to the cabinet standard.

## 9. Roles and Independence

| Role | Responsibility | Constraints |
|---|---|---|
| Author | Accepts contracts, resolves escalations, signs off, freezes statements, decides scope and identity questions | Sole authority over contracts (P7) |
| Coordinator | Maintains the block graph, computes staleness, schedules work, assembles reports | Cannot produce evidence |
| Mathematical workers | Draft proofs, isolate lemmas, test examples, search for counterexamples, improve exposition | Changes to statements are proposals, not edits |
| Reviewers | Produce review evidence | Isolated context from the worker whose proof they review |
| Formalization workers | Write Lean statements and proofs; classify formal feedback | Cannot audit their own statements |
| Read-back auditor | Translates Lean statements back into mathematics | Never sees the informal statement or the formalizer's notes |
| Comparator | Compares read-back with the contract and assigns a typed outcome | Sees both, but did not produce either; run on a different model from the formalizer where one is available (Section 11.4) |
| Adversarial reader | Reconstructs an informal proof from raw definitions alone and hunts for gaps (Section 11a) | Never told the proof is "known correct"; no access to project history or prior audit results |
| Encoding auditor | Audits the project representation against the paper's foundation (Section 11.5) | Runs before any statement audit that depends on the representation |

Independence is weakened when all agents share one underlying model, because
they may share blind spots. The evidence record therefore stores model
identity and prompt revision; the schedule actively routes the
higher-stakes stages (comparison, adversarial read) to a different model
where one is available; and the evaluation plan (Section 18) measures audit
effectiveness directly, by model pair, rather than assuming it.

## 10. Architecture

### 10.1 Layer 1: Mathematical Development

Responsibilities:

- refining definitions and proposing contract changes;
- completing proofs and isolating missing lemmas;
- testing examples and edge cases;
- exploring alternative arguments;
- searching for counterexamples;
- reconstructing an informal proof from its formal counterpart when the
  manuscript omits or under-specifies the argument (Section 11a.5);
- improving exposition.

Every substantial change is recorded as a new facet revision with its
provenance, and its downstream impact is computed before the author is
asked to accept it.

### 10.2 Layer 2: Formalization

Responsibilities:

- selecting formal representations, reusing Mathlib notions wherever
  possible;
- constructing Lean declarations and proofs;
- proving bridge lemmas to Mathlib definitions;
- running formal sanity checks (Section 11.3);
- extracting formal dependencies;
- producing machine-checkable evidence.

Formal feedback is classified before it reaches the mathematical layer, so
that the author sees mathematics, not Lean noise.

| Class | Example | Routed to |
|---|---|---|
| F-artifact | Coercion, universe, or elaboration difficulty with no mathematical content | Formalization layer only |
| F-representation | The chosen encoding cannot express the contract faithfully (for example, no ambient universe in which cross-family union is definable, so a paper clause becomes an ambient-restricted special case) | Author; triggers or revises a representation audit (Section 11.5) |
| F-library | Required result missing from Mathlib | Library backlog; the block may become statement-only |
| M-hypothesis | Proof requires a hypothesis the contract does not state, or a stated hypothesis is never used | Author, with a proposed contract change |
| M-definition | Two readings of a definition are possible, or the definition behaves unexpectedly on edge cases | Author |
| M-gap | A step of the informal proof has no formal counterpart that can be closed | Mathematical workers, then author |
| M-false | Counterexample found or disproof verified | Author, immediately; block becomes Refuted pending decision |

### 10.3 Layer 3: Correspondence and Informal-Proof Auditing

A dedicated process establishes whether formal declarations express the
intended mathematics (Section 11), and a parallel process establishes
whether freshly written or revised informal proofs are themselves correct,
independent of any formal counterpart (Section 11a).

### 10.4 Orchestration and Storage

The coordinator runs locally. The source of truth is a version-controlled
repository containing the TeX sources, the Lean project, block records, and
the event journal.

```text
project/
|-- manuscript/          # TeX sources with block annotations
|-- lean/                # Lake project, own pinned toolchain and Mathlib
|-- representation/       # encoding records and foundation bridges (Section 11.5)
|-- blocks/              # one record per block (JSON)
|-- evidence/            # immutable evidence records
|-- schemas/             # machine-readable schemas for records and the journal
|-- journal/events.jsonl # append-only event log
|-- STATE.md             # running session narrative (Section 16)
|-- scripts/             # ingestion, hashing, sanity-check tooling
`-- reports/             # generated coverage, trust boundary, gap reports
```

**No `prove2me/`-style directory, and no dependency on a workspace shared
with other projects.** The Lean project owns its toolchain installation and
its package cache outright. This is a hard-won lesson, not a stylistic
preference: sharing a mutable Mathlib cache across unrelated projects means
a toolchain crash in one project can silently corrupt or delete the cache
another project depends on (Section 15.3). Isolation costs some disk space
and cache-warming time; the alternative has actually destroyed shared state
in practice.

### 10.5 Git Architecture and Commit Discipline

This is stated as its own subsection, not left implicit, because leaving it
implicit is exactly what went wrong the first time: an earlier version of
this workspace ran for the length of an entire formalization and
manuscript-editing effort - dozens of sessions - inside a git repository
that was initialized but never actually used. Every file sat untracked,
with zero commits, for the life of the project. Nothing was lost only
because the disk itself never failed; the architecture must not depend on
that being true. Git is not incidental tooling here - it is the actual
mechanism that makes two of this document's own claims real rather than
aspirational: P9's "all decisions remain auditable," and Section 6's
evidence records being "immutable."

**Why git specifically carries load:**

- **It is the durable history.** `journal/events.jsonl` (Section 10.4) is a
  structured, greppable *index* of what happened; git is the record of
  every byte that ever changed, including the journal file itself.
  "Provenance Preservation" (Section 22's success criteria: reconstructing
  the project at an arbitrary past point) is not actually testable without
  it - a journal with no commit history behind it can itself have been
  silently edited.
- **It is what makes evidence immutability checkable, not just claimed.** An
  evidence record (Section 7.2) must never be edited after creation, only
  superseded by a new record with a new ID. That rule is unenforceable by
  convention alone. With real git history, it is a five-line check: any
  commit whose diff touches an existing file under `evidence/` other than
  as a pure addition is a policy violation, and it is exactly as easy to
  write that check as a pre-commit hook as it is to skip writing it and
  hope. Do not skip it.

**Commit discipline:**

- Every session ends with at least one commit, on the same timing rule as
  the `STATE.md` entry (Section 16.1): if remaining budget is tight, commit
  before attempting more work, not after. Real work sitting only in an
  uncommitted working tree is at least as fragile as a stale `STATE.md`,
  and recovers worse - there is no diff history to fall back on if the tree
  is later reset, corrupted, or merged incorrectly.
- Prefer several small, coherent commits over one large end-of-session
  commit: one commit per closed case or lemma, one per manuscript
  edit-and-resync (Section 13.3), one per evidence record produced. This
  matches the project's own block/evidence granularity, so
  `git log -p -- blocks/B-0142.json` becomes a direct, sufficient answer to
  "what happened to this block," rather than something only reconstructible
  from `STATE.md` prose.
- Commit messages name the block ID and/or evidence ID they touch - for
  example `B-TDefRec: close ch_j case (E-000029)` - not only a prose
  description. This makes `git log --all --grep=B-0142` a real search tool.

**Branching.** A single author working with agents does not need a
pull-request ceremony for every proof or editorial edit - the evidence
model already controls blast radius, and routine work commits directly to
`main`. Reserve short-lived branches for actual contract changes (P7): an
agent proposing a change to a frozen statement or a definition commits the
proposal on a branch, and the author's merge of that branch back into
`main` *is* the acceptance record - citable directly from the journal
event, with no separate sign-off mechanism needed on top of git.

**Tags.** Mark real milestones - a pilot's completion, a section's blocks
all formalized and sorry-free, a manuscript submission - with lightweight
annotated tags, so a report or a future session can check out the exact
state a claim was made about instead of reconstructing it from commit
timestamps.

**Safe-restart checklist addition.** `git status` and
`git log --oneline -10` are the first two commands of any session, before
reading `STATE.md`'s own claims. An unexpectedly dirty tree, or a gap
between the latest commit and `STATE.md`'s last entry, is itself a signal
- most likely, a prior session did real work but ran out of budget before
committing it - that should be reconciled (commit or explicitly stash the
prior session's work) before trusting anything else in the repository.

**What to track.** `.gitignore` excludes only regenerable build artifacts:
Lean's `.lake/` build cache, compiled `.olean` files, LaTeX's
`.aux`/`.log`/synctex byproducts. It must never exclude anything meant to
be the durable record - `manuscript/`, `lean/` sources, `blocks/`,
`evidence/`, `journal/`, `scripts/`, `reports/`, and `STATE.md` are always
tracked. If in doubt about whether a file belongs in `.gitignore`, the
default is to track it.

**Visibility.** With no external verification platform (Section 15), the
earlier design's platform-hosted "private mission" mechanism no longer
exists - publication control is now entirely a property of where this git
repository itself is hosted. Keep the remote private for as long as the
manuscript is unpublished; there is no separate per-result visibility flag
to manage, unlike a mission-based platform. Making the repository (or a
specific tagged release of it) public is the author's decision alone, and
is a natural moment to also decide whether to offer the evidence bundle
(Sections 19, 23) to referees.

### 10.6 First-Run Bootstrap Checklist

Before any block is tracked or any Lean file is written, a new project
instantiating this architecture should work through the following once, in
order. Each item names a concrete lesson behind it where one exists. The
point of doing this up front, as a checklist rather than as tribal
knowledge accumulated after the first incident, is that every failure mode
named here has actually occurred in practice and was expensive to diagnose
after the fact and cheap to prevent before it.

1. **Confirm the machine's architecture and pick a toolchain accordingly.**
   Run `uname -m` before installing anything. Do not assume a pre-existing,
   machine-wide default toolchain matches the current machine's native
   architecture - a stale x86_64 toolchain running under Rosetta on an
   arm64 Mac has been observed to crash on ordinary git-based Lake
   operations after an unrelated OS update, and Lake's own error-recovery
   response to that crash is to delete the affected package directory and
   retry, which is destructive if that directory is shared with anything
   else. Install, or confirm, a native-architecture toolchain explicitly,
   in a location this project controls.

2. **Give the project its own toolchain and package cache; never point at
   a cache shared with another project.** Set an isolated toolchain home
   (e.g. a project-specific `ELAN_HOME`) and record the exact environment
   variables needed in a small checked-in script (`scripts/env.sh`, sourced
   at the start of every session) rather than as prose in a narrative log -
   a script is something a session can execute and verify mechanically;
   prose is something it has to remember to read and might not. See
   Section 10.5's cache-sharing incident for why this is not optional.

3. **Pin the exact Lean and Mathlib versions before writing anything.**
   Record them in the Lake project's own toolchain and manifest files, and
   additionally write the pinned versions into the project's environment
   script and into `STATE.md`'s initial entry, so a later session can tell
   at a glance whether the environment it is running in still matches what
   the project expects.

4. **Fetch the dependency cache and do one full clean build before any
   real work,** confirming: it completes without downloading or rebuilding
   dependencies from source; it produces zero errors and zero warnings;
   `#print axioms` on a trivial test theorem reports only the permitted
   axiom set (Section 15.5). Record how long this took once, so a much
   longer time on a later "resume" session is itself a signal that
   something is wrong, in the same spirit as Section 10.5's dirty-tree
   check.

5. **Verify the manuscript's build toolchain and its input encoding before
   any editing begins.** Confirm the chosen typesetting engine is
   installed and produces a clean, exit-code-zero build of the unmodified
   manuscript. Identify the manuscript's declared input encoding explicitly
   - if it declares a legacy encoding (for example `latin1`) rather than
   using an engine without this failure mode, install the non-ASCII
   scanner (Section 13.3) as a script now, before the first edit, not
   after the first silent failure.

6. **Fetch any external class files or templates the manuscript depends
   on, and note whether they carry their own "always fetch the latest
   version" policy** (a publication venue's own document class is a common
   example). Recording this during bootstrap means it is not rediscovered
   as a surprise at submission time.

7. **Scaffold the fixed directory layout** (Section 10.4) and initialize
   git (Section 10.5) if this is not already a repository: create
   `manuscript/`, `lean/`, `blocks/`, `evidence/`, `journal/`, `scripts/`,
   `reports/`, an initial `STATE.md`, and a `.gitignore` that excludes only
   regenerable build artifacts. Make the first commit at the end of this
   checklist, not before it, so that the first commit is a working,
   verified baseline rather than a half-configured one.

8. **Install the mechanical hygiene scripts before the first real edit,
   not after the first incident** (Section 13.3): the anchor-based
   hash/resync tool, the cross-reference blast-radius checker, the
   non-ASCII scanner, and a build wrapper that checks the actual process
   exit code rather than only scanning log text for error markers. Wire
   the evidence-immutability check (Section 10.5: no commit may modify an
   existing file under `evidence/`) as a pre-commit hook now, while there
   is no history yet that would need retroactive auditing.

9. **Run the TeX ingestion importer** (Section 14) to produce the initial
   source inventory, symbol registry, block registry with author-confirmed
   persistent IDs, initial dependency graph, and gap report, and have the
   author confirm the suggested pilot milestone before any block-level
   work starts.

10. **Confirm disk space and remote storage.** A full dependency cache is
    typically several gigabytes; check available space before fetching it,
    and confirm wherever the repository's remote will live (Section 10.5's
    visibility policy) has adequate headroom and the intended access level
    (private, by default) set correctly before the first push.

11. **Write the bootstrap outcome into `STATE.md`'s very first session
    entry**, in the same format every later entry will use: what was
    installed, what versions were pinned, what the clean-build baseline
    looked like, and anything that had to be worked around. This seeds the
    safe-restart checklist once, at the start, rather than leaving it to be
    reconstructed from memory the first time something breaks.

## 11. Correspondence Audit Protocol

The audit is the most fragile part of the system, so it is specified in
detail.

### 11.1 Order

Audits proceed in dependency order, coarsest first:

1. the **representation** (Section 11.5) covering the block's notions;
2. the **definitions** in the block's closure;
3. the **statement** itself.

A statement audit may assume that the representation it is stated against is
accepted and that every definition in its closure has a current `equivalent`
audit; otherwise it is `blocked`, and the blocker is the missing precondition,
not the statement.

### 11.2 Blind Read-Back and Comparison

1. **Read-back.** A fresh agent - never a context-sharing fork, since that
   would defeat the blindness - receives the Lean declaration, the required
   preamble, the definition closure (with their audited informal readings),
   and the symbol registry. It is explicitly instructed *not* to open the
   manuscript, the block/evidence records, or any architecture document. It
   produces an informal rendering, explicitly listing every hypothesis,
   quantifier, type, and convention, and returns the full text inline
   rather than only saving it to a file the next stage might not see.
2. **Comparison.** A second fresh agent receives only the read-back text and
   the contract, typed out inline, and assigns a typed outcome
   (Section 7.4), citing the specific differences. It is prompted explicitly
   to be skeptical rather than to default to "looks fine," and, where
   useful, given concrete examples of gaps this kind of check has found
   before.
3. **Escalation.** Any outcome other than `equivalent` on a headline result,
   and any disagreement between comparators, goes to the author.
4. **Recording.** The result is stored as its own evidence record with an
   `independence_caveat` describing this two-stage protocol explicitly -
   materially stronger than a same-session self-check, but not full
   external review, since both stages still share this session's underlying
   model.

This protocol was validated in practice: a two-stage blind audit run on a
block that ten prior self-checks had all rated `pass` found a real,
previously unrecorded gap, purely because the reader had never been forced
to describe the Lean without already knowing what it was "supposed" to
say. The lesson generalizes - run this protocol on any block whose only
correspondence evidence is a self-check, especially large or load-bearing
ones, before trusting its status as more than provisional.

### 11.3 Formal Sanity Checks

Read-back alone misses a class of errors in which the formal statement
*reads* correctly but *means* something degenerate. Each audited block
therefore also carries lightweight formal checks, which are themselves
verification evidence:

- **Non-vacuity:** a Lean proof that the hypotheses are jointly satisfiable
  (an explicit instance), so the theorem is not vacuously true.
- **Definition examples:** `example` declarations evaluating each new
  definition on known cases from the manuscript, including edge cases.
- **Negation probes:** a bounded attempt to prove the negation; success
  indicates a false claim or a faulty formalization.
- **Convention checks:** automatic flags for truncated subtraction, division
  by zero, implicit coercions between N, Z, and R, and similar conventions
  that commonly alter meaning.

### 11.4 Calibration by Seeded Mismatches

Audit reliability is measured, not assumed. The project maintains a suite of
*mutated* formal statements derived from audited ones (dropped hypothesis,
flipped inequality, strict <-> non-strict, swapped quantifier order, N <-> Z,
off-by-one bounds). The audit pipeline is run periodically on the suite, and
its detection rate per mutation type is reported. A drop in detection rate
after a change of model or prompt blocks that change.

The suite is stood up **early** (roadmap Phase 1, not last): until it exists,
there is no evidence the audits detect mismatches rather than merely agree
with themselves. It is run (a) per mutation type, (b) per *model pair* used
for comparison, so that "a different model catches more" becomes a measured
claim rather than a hope (Section 9), and (c) against seeded **encoding**
mismatches (Section 11.5) as well as statement mismatches - a wrong
representation corrupts many audits at once, so it is the most valuable
mutation to detect. Detection rate is a gate: a drop after a change of model,
prompt, or tooling blocks that change until the drop is explained.

### 11.5 Encoding (Representation) Audit

The single highest-leverage audit in the system, because a representation
error is replicated across every statement that uses it. It is run once per
representation (and re-run whenever the representation changes), before the
statement audits that depend on it.

1. **State the encoding.** The auditor is given the paper's foundational
   conventions (how sets, subsets, the ambient universe, and componentwise
   operations are used) and the project representation (carrier model, subset
   relation, the definitions of union/intersection/difference/image, coercion
   and truncation conventions), and must enumerate every place the two can
   diverge.
2. **Probe the divergences.** Each candidate divergence is either closed by a
   formally checked *foundation bridge* (a lemma proving the encoding agrees
   with the paper on the intended class of instances) or recorded as an
   explicit, bounded weakness together with the class of instances it affects.
   For example: "componentwise union of *arbitrary* S-sorted sets (paper) is
   modelled as union of subobjects of a fixed ambient (Lean); bridge: under
   the paper's common universe the two coincide on subobjects; residual gap:
   cross-family unions of unrelated carriers are not directly expressible."
3. **Outcome.** Typed as for statements (Section 7.4), but the outcome is
   about the *encoding* rather than a claim: `faithful`, `faithful-with-caveat`
   (the residual gap must be listed), or `unfaithful`.
4. **Recording.** A representation-layer evidence record (Section 7.2); every
   statement audit that relies on it lists the representation hash among its
   inputs, so a representation revision stales all of them (Section 13.2,
   class C6).

Only `faithful` or `faithful-with-caveat` lets statement audits proceed; on
`faithful-with-caveat` the caveat is propagated into every dependent block's
trust boundary, so the compromise is visible where a reader will see it rather
than buried in a source comment.

## 11a. Informal Proof Audit Protocol

This protocol is the generalization of Section 11 to a proof's internal
correctness, independent of any Lean counterpart. It is needed because a
manuscript can be edited - a lemma tightened, a gap filled, a construction
made explicit - in sessions that never touch Lean at all, and those edits
are exactly as capable of introducing a genuine mathematical error as a
tactic script is.

### 11a.1 When It Applies

- Any newly written proof, or any proof whose argument changed
  substantially (not a wording edit).
- Before a block is marked `Manuscript-ready` (Section 7.5).
- On request, as a sweep over an entire manuscript section, when no other
  concrete action is available and a correctness pass is warranted.

### 11a.2 Two Tiers

1. **Self-re-read (cheap, do this first, every time).** Before moving to a
   new task, re-read the just-written proof with the same skepticism this
   project applies to Lean: does every case actually get handled, does the
   argument use exactly the hypotheses it's entitled to, does a claimed
   "immediate" or "straightforward" step actually go through? This single
   practice has caught real, load-bearing bugs at essentially no cost - do
   not skip it because the alternative (Section 11a.3) exists.
2. **Independent adversarial read (do this before trusting the result).** A
   fresh agent - no memory of writing the content, not told a bug is
   expected or not expected, not given any framing beyond "be a skeptical
   referee" - receives a self-contained bundle: every definition the proof
   depends on, typed out inline, and the full text of the proof itself. It
   is asked to reconstruct the argument from the definitions rather than
   trust the prose, explicitly probe degenerate and edge cases, and report
   any gap in concrete terms (a specific case not covered, a specific
   implicit fact the proof leans on without justifying).

### 11a.3 What This Has Actually Caught, and Not Caught

Recorded here because the pattern is genuinely informative, not just
procedural color: a self-re-read once caught a real bug (a recursive
construction that silently double-marked a variable outside its intended
subtree) in a proof that had already compiled cleanly into the manuscript.
A downstream proof that cited the buggy construction was checked and found
to have a second, related but distinct problem - its final conclusion was
still correct, but a step of its argument used the buggy construction's
full strength where only a restricted, valid case actually held. Both were
fixed, and every other proof in the same manuscript, checked afterward by
the independent adversarial protocol, came back clean.

The two outcomes - self-check-then-fix, and independent-check-clean - are
both valuable and neither should be read as making the other unnecessary:
a clean independent result after genuine skeptical effort is itself
evidence worth recording (Section 7.4's point about `equivalent` verdicts
applies here too), not a sign the check wasn't rigorous enough.

### 11a.4 Recording

Store the result as a review-layer evidence record (Section 7.2), with
`producer.role: adversarial_reader` and an `independence_caveat` naming
this exact protocol. A clean result raises review strength; a finding
routes back to the mathematical layer's feedback classes (Section 10.2),
typically `M-gap` or `M-false`.

### 11a.5 Explanation: Reconstructing an Informal Proof from a Formal One

The most valuable output of this system is not a status flag but a proof the
manuscript did not previously have. Papers frequently state a theorem (or a
group of properties) and omit the proof; formalization produces one. Turning
the formal argument back into rigorous prose is therefore a first-class
deliverable, not a by-product.

1. **Trigger.** A block is in scope and is `M-gap` (Section 10.2): the
   manuscript states the claim without a proof, or with a proof that hides
   real content. Statement-only and omitted-proof blocks are the common case.
2. **Reconstruct.** A worker reads the *formal proof* (not merely its
   statement) and writes a prose proof whose steps correspond to the formal
   argument, in the paper's vocabulary and against the paper's representation.
   The result is stored as the block's `Explanation` facet (Section 6) - a
   semantic artifact, distinct from exposition.
3. **Audit.** The explanation is then an ordinary informal proof: it gets the
   self-re-read and, before it is trusted, the independent adversarial read of
   Section 11a.2. The formal proof does not substitute for this step (P5) -
   the risk is precisely that the prose says something the Lean does not, or
   silently strengthens a hypothesis along the way.
4. **Adopt.** On a clean adversarial read and author acceptance, the
   explanation becomes the block's informal proof in the manuscript and
   `M-gap` closes. The provenance chain - Lean proof -> explanation -> accepted
   manuscript proof -> adversarial read - is exactly the audit trail a referee
   would want.

**Dependency inversion.** This inverts the usual direction: instead of
formalization following the manuscript, the manuscript follows the
formalization. It is the main mechanism by which formalization *improves the
writing* rather than merely checking it, which is why the roadmap makes it a
Phase 0 deliverable rather than a later nicety.

## 12. Dependency Model

### 12.1 Nodes and Edges

Nodes are facets, not whole blocks. Edges are typed:

| Edge | From -> To | Source |
|---|---|---|
| `uses_statement` | informal proof -> informal statement of another block | `\uses{...}`, `\ref`/`\cref`, reviewer validation |
| `uses_definition` | any statement or proof -> definition | Symbol registry, `\uses{...}` |
| `formal_uses` | formal proof or statement -> formal statement of another declaration | Extraction from Lean declarations (constants used) |
| `proves` | proof facet -> statement facet of the same block | Structural |
| `corresponds` | formal statement <-> informal statement | Correspondence evidence |

Dependency information comes from explicit annotations, extraction from
Lean, and reviewer validation. In practice, for expository mathematics,
`\ref`/`\uses` alone is nearly useless: papers cite by symbol and by name far
more often than by reference. Two further extractors are therefore mandatory,
not optional:

- **Symbol-usage edges.** The importer builds a symbol registry (Section 14)
  mapping each macro and notation to its defining block, then scans every
  block body for uses of those symbols and proposes `uses_definition` edges.
  This is what turns "B-P001 mentions `\mathrm{supp}_{S}`" into a concrete
  dependency on the support definition - a dependency `\ref` never recorded.
- **Prose-name detection.** A block's prose can cite another *by name* ("the
  root formula of Remark X") with no `\ref` at all. A name index over block
  titles and defined terms flags these as candidate edges. Missing one
  silently invalidates a hash (Section 13.3, item 2), so the flag is
  deliberately over-inclusive.

Every proposed edge is presented for confirmation; confirmed edges enter the
graph, and rejected ones are remembered so they are not re-proposed. Semantic
dependencies no extractor finds (for example "by a standard compactness
argument") remain the reviewer's job, which is why the discrepancy report
(Section 12.2) rather than extraction is the completeness backstop.

**The formal extractor must fail closed.** Extraction of `formal_uses` (and of
the formal facets themselves, Section 7.2) can be done either by scanning Lean
source or from the elaborated environment. A source-level scanner is the
cheap option, but it has one recurring, silent failure mode: a declaration
written with a keyword the scanner does not recognize is simply *absent* from
the map, so the block it should belong to silently loses its formalization and
its dependents silently lose a closure edge. This has happened more than once
(on attributes, on `noncomputable def`, on `inductive`), each time discovered
only because a mapping visibly failed. The rule is therefore: the scanner must
recognize every top-level declaration form used in mapped files, must fail
*closed* - an unrecognized declaration in a mapped file is an error, not a
skipped line - and must carry a regression test per supported form. The honest
target state is to derive facets from the elaborated Lean environment, where
the declaration list is whatever the compiler actually accepted; until then,
source-level presence is a checked precondition, not an assumption.

One dependency class deserves special mention because it is easy to miss
mechanically: a block can reference another **by name in prose** (for
example, citing "the root formula of Remark X") rather than by `\ref{}`.
Renaming, promoting, or otherwise editing the first block can silently
invalidate the second block's hash even though nothing in the second
block's own section was touched. Section 13.3 makes this an explicit
propagation-check step rather than something caught only by luck.

### 12.2 Graph Discrepancy Report

Because both an informal and a formal dependency graph exist, their
differences can be computed:

- a formal proof uses a lemma that the informal proof does not cite ->
  possible hidden dependency or unstated step;
- an informal proof cites a lemma that the formal proof never uses ->
  possible superfluous hypothesis or an argument that can be simplified;
- a formal proof uses a hypothesis the informal statement does not have ->
  missing hypothesis (M-hypothesis).

This report is the concrete mechanism behind the claim that formalization
improves the mathematics.

### 12.3 Closure Generation (the Input of Every Evidence Record)

Evidence inputs are computed, not authored (P13). Given a block and an
evidence layer, the coordinator computes the *input closure*: the facets that
layer depends on, plus the **statements** (never the proofs) of every block in
the transitive dependency closure, plus the representation hash (Section 11.5)
where the layer is correspondence or review.

Rules:

- **Layer selects facets.** Verification takes `formal_proof` and the
  environment; correspondence takes `informal_statement`, `formal_statement`,
  `definition_closure`, and the representation; review takes
  `informal_statement`, `informal_proof` (plus `Explanation` where present), and
  dependency statements.
- **Transitive, statement-only.** Dependencies contribute their statements,
  recursively. This is what makes a definition change propagate (Section 13.1)
  while a proof change does not.
- **Keyed on declarations, not blocks.** The closure is a set of declarations
  and their statement hashes. Which block owns a declaration is bookkeeping and
  does not enter the closure, so moving a helper between blocks leaves every
  dependent's `definition_closure` hash unchanged (Section 13.2, class C5). An
  earlier implementation keyed the closure on block membership, which turned
  such a remap into a phantom statement change for every dependent.
- **Fail closed.** If any edge is unresolved or ambiguous, closure generation
  fails and the check does not run; the block's `blocked` status names the
  unresolved edge. A partial closure is never emitted.
- **Deterministic.** The same graph and facets yield the same input list, so
  the resulting record is reproducible (Section 22, Audit Reproducibility).

Closure generation is the mechanism that turns "evidence" from a claim a
worker asserts into a fact the tooling computes.

## 13. Change Classification and Propagation

### 13.1 Default Rule: Hash-Based Invalidation

When any facet changes, the system:

1. records a new revision and a journal event;
2. recomputes the facet hash;
3. marks stale every evidence record that lists the old hash among its
   inputs;
4. recomputes the status vector of every affected block;
5. schedules rework according to Section 17.

Because evidence records list statements, not proofs, of their
dependencies, this rule already implements proof irrelevance on the informal
side: a proof change stales only that block's own review and verification.
The formal side matches it because `formal_statement`, `definition_closure`,
and `formal_proof` are hashed separately (Sections 6, 7.2): rewriting a Lean
proof stales that block's verification record and nothing else; a change to
the elaborated type propagates exactly like a statement change; and a change
to a definition's content moves the `definition_closure` of every dependent,
which is precisely how a definition edit (class C4) reaches its downstream
closure. Because the closure names declarations rather than blocks, moving a
declaration between blocks moves none of these hashes (class C5).

Informal text is normalized (whitespace, comments, macro expansion to a
canonical form) before hashing, so trivial edits do not trigger
invalidation.

### 13.2 Salvage Rules

Classification is used only to *reduce* invalidation, and only with
justification.

| Class | Change | Default effect (hashing) | Salvage allowed |
|---|---|---|---|
| C0 Editorial | Wording, notation display, exposition | Stales evidence whose inputs include the edited facet | Author may carry evidence forward with a decision record |
| C1 Proof revision | Informal or formal proof changes; statement unchanged | Stales that block's review or verification only | None needed |
| C2 Strengthening | Weaker hypotheses or stronger conclusion | Stales dependents' reviews and formal builds | Dependents' reviews may be carried forward if the comparator confirms strengthening; builds are simply re-run |
| C3 Weakening / incomparable | Stronger hypotheses, weaker or different conclusion | Stales dependents | None; dependents are re-reviewed and rebuilt |
| C4 Definition change | Any change to a definition | Stales everything in its downstream closure | None |
| C5 Identity operation | Split, merge, rename, move, declaration remap | None if facet hashes are keyed on content and declaration identity | Evidence carried forward via an explicit identity map |
| C6 Representation change | Any change to the project representation: carrier model, subset/coercion conventions, ambient universe, definition of a componentwise operation | Stales every correspondence and review record listing that representation hash - the whole dependent surface | None; the representation is re-audited (Section 11.5) and every dependent statement re-audited |
| F2 Environment change | Lean or Mathlib version bump | Stales all verification evidence | None; full rebuild |

Misclassification in the permissive direction (for example, labeling a C3
change as C0) is the dangerous failure. Downgrades therefore always require
an author decision record, and macro changes are treated as C4 unless shown
to be display-only. C6 is the highest-blast-radius class of all - worse than
C4, because it can silently reconfigure many definitions at once - and a
representation change is never routine: it is always an author decision,
followed by a fresh encoding audit (P12).

**The declaration-remap sub-case of C5.** A *declaration remap* moves a
declaration from one owning block to another - in practice, a helper
introduced inside a proof being promoted to the block whose contract it
actually formalizes (Section 6). How much it costs depends entirely on what
the definition closure is keyed on. With a declaration-keyed closure
(Section 12.3) it is a genuine no-op: no facet hash moves, no record stales.
With the earlier block-keyed closure it was not: the dependents' closure sets
changed, so their `definition_closure` and every statement-dependent record
moved, and those records had to be re-issued although nothing about the
mathematics had changed. When a remap does force re-issues, record them with
`reissue_reason: remap` (Section 7.2) and keep the existing transcripts; the
audits' content is unchanged and re-running them wastes the independence they
already have. A remap never needs an author decision: it changes no contract.

### 13.3 Mechanical Hygiene (Automate, Do Not Track by Hand)

Practical experience across many editing sessions produced four recurring,
purely mechanical failure modes. All four are cheap to prevent with tooling
and expensive to discover by hand, so treat automation here as required, not
optional:

1. **Anchor drift.** If block hashing is keyed to raw line ranges in the
   source file, every edit that shifts line numbers desyncs every hash
   computed from a range below the edit - silently, until something
   happens to notice. Key hashing to stable anchors (LaTeX labels,
   `\begin{proof}`/`\end{proof}` pairs, or an explicit block-id macro)
   instead of line numbers wherever possible, and re-run the hasher after
   *every* edit to the manuscript, not once at the end of a session. After
   recomputing, verify each recorded hash actually appears in its own block
   record by direct string search - do not just trust that the script ran
   without error.
2. **Cross-reference blast radius.** Before treating an edit as local to one
   block, grep the whole manuscript for the edited block's name/label and
   check whether any other block's prose cites it by name (see Section
   12.1). A rename or promotion three edits back, in a different section,
   can silently change a different block's hash; an automated check catches
   this immediately, a manual "did I touch that file" review reliably does
   not.
3. **Silent encoding failures.** If the manuscript uses a legacy input
   encoding (for example `latin1`), a single accidentally-typed Unicode
   character (a smart quote, an em-dash) can be silently dropped by the
   typesetter under non-interactive compilation, producing a clean-looking
   log with no `!`-prefixed error, while the compiler's own exit code is
   still nonzero. Never trust the printed log alone: check the numeric exit
   code after every compile, and run a small non-ASCII scanner over any
   file that was just edited before even attempting to compile it.
4. **Post-hoc declaration addition.** Adding any declaration to a block that
   already has verification evidence changes that block's `formal_proof` hash,
   so the block's verification silently goes stale even though nothing it
   previously claimed was retracted. This is not a defect to be fixed; it is a
   consequence of hashing facets per block. The rule is a same-session rule:
   whenever a declaration is added to an already-verified block, re-issue that
   block's verification before the session's commit, and never let a session
   end with a block whose own facet has moved since its last verification. The
   same applies to re-maps and to any edit that adds a declaration rather than
   changing one (Section 13.2, class C5). A gate that re-derives every block's
   verification currency from the facets - rather than trusting that "no
   theorem statement changed" - is what makes this mechanical (Section 15.6).

## 14. TeX Ingestion and Project Initialization

The importer creates a project snapshot from the main TeX sources, included
files, macros, bibliography, figures, and supplementary notes. It
generates:

1. **Source inventory.**
2. **Symbol registry:** each macro and notation with its intended meaning
   and, where available, its Lean counterpart. This is shared by
   formalizers, auditors, and comparators.
3. **Block registry** with proposed persistent IDs, confirmed by the author.
   IDs are never reused. IDs are minted **lazily**, as blocks enter the
   formalization frontier, not for the whole manuscript up front (annotation
   discipline below).
4. **Initial dependency graph**, seeded by explicit `\ref`/`\uses` *and* by
   symbol-usage and prose-name extraction (Section 12.1); proposed edges are
   author-confirmed before they enter closure computation.
5. **Gap report:** proofs with unreferenced steps, undefined notation,
   results cited without proof.
6. **Suggested pilot milestone:** a small, dependency-closed set of blocks
   containing at least one definition likely to change.

**Annotation format.** To avoid inventing a new ecosystem, annotations are
compatible with `leanblueprint` (`\lean{...}`, `\uses{...}`, `\leanok`,
`\mathlibok`), extended with a stable identifier macro (for example
`\blockid{B-0142}`) and a scope marker. Existing blueprint tooling,
including its dependency graph rendering, then works on the project
unchanged.

**Annotation discipline (lazy, not wholesale).** Blocks are annotated when
they enter the frontier, not when the paper is first imported. Annotating all
blocks up front mints permanent identities for work that may not be touched
for weeks and produces a registry dominated by `scope: unset` noise. The
importer *proposes* an ID for every candidate block and records the proposal,
but only frontier blocks are committed as annotations in the source. A
proposal is cheap and reversible; an annotation is permanent (IDs are never
reused). This keeps the tracked surface proportional to work actually in
progress and matches the pilot-first roadmap (Section 21).

**Re-ingestion.** After manuscript edits, re-ingestion matches blocks by
identifier first, then by content similarity. Any block that cannot be
matched with confidence is flagged for the author rather than silently
created or deleted. See Section 13.3 for the mechanical hygiene this step
depends on.

## 15. Verification Policy

### 15.1 Local-Only Verification

All formal verification evidence comes from a single, self-contained tier:
a Lake project with a toolchain and Mathlib revision pinned at project
creation, owned exclusively by this project.

There is deliberately no second, "platform" tier. Earlier drafts of this
architecture assumed an external verification service for independent
verification, immutable statement registration, and citable results. In
practice, that integration was never load-bearing - the project's actual
safeguards (evidence records, typed correspondence, the two audit
protocols) are entirely local mechanisms and work identically without it.
Removing the platform dependency removes a source of lock-in and API churn
without weakening any guarantee this workspace actually relies on.

### 15.2 What Replaces Platform Concepts Locally

| Former platform concept | Local equivalent |
|---|---|
| Immutable statement registration | A frozen block's statement facet, with edits requiring a decision record (Section 13.2) |
| Open reduction (proof-sketch with open children) | A block with `formalization_scope: statement-only`, its open proof recorded explicitly in the trust boundary |
| Mission-wide axiom whitelist | Local `#print axioms` check against a fixed permitted set, run by the mechanical Lean gate (Section 15.6) |
| Externally citable, publicly verified result | Not needed locally; if a result must later be shared as independently verifiable, publish the Lean source and evidence bundle alongside the paper - no platform required |

### 15.3 Environment Isolation

Each project installs and pins its own Lean toolchain and its own package
cache. **Do not share a mutable toolchain or Mathlib cache across unrelated
projects.** This is a specific, hard lesson: a toolchain crash under an
unsupported architecture combination has been observed to trigger a build
tool's own error-recovery path, which deleted an entire cached package
directory and attempted to re-clone it - while that same directory was a
dependency shared by other, unrelated projects on the same machine. The
fix, once broken, required diagnosing the exact toolchain/architecture
mismatch and installing a second, isolated toolchain; the cheap prevention
is simply never to share the cache in the first place.

### 15.4 Optional Future External Registration

If, later, there is a concrete reason to register frozen results on an
external verification or dependency-tracking platform (citability,
integration with a broader formalization library, and so on), that
integration should be built as a thin, isolated adapter that talks to the
platform through one clearly bounded interface, mirrors remote state
without ever treating it as authoritative, and can be deleted without
touching any local record. It is explicitly out of scope for the initial
build of this workspace.

### 15.5 `sorry` Policy

`sorry` is never permitted in a block's own formal proof once that block is
reported as formalized. Unproved inputs appear only as imported open lemmas
(statement-only blocks) or explicit trust-boundary entries, all of which
appear in the trust boundary report. A project-wide `sorry`-free check is run
by the mechanical Lean gate (Section 15.6).

### 15.6 The Mechanical Lean Gate

The formal side of the workspace has its own mechanical gate (implemented by
`scripts/lean_audit.py`, whose pure parsing is covered by
`scripts/lean_audit_test.py`), and it is part of `check_all`, not a manual step.
It exists because the three facts the
verification layer depends on - that the project builds, that it builds
cleanly, and that every reported theorem's axioms lie inside the permitted set
- were, in early practice, asserted from a truncated console log rather than
checked. That produced a real drift: a build reported for several sessions as
"0 warnings" in fact emitted a style-linter warning the whole time, and no
check noticed, because nothing in the gate ever invoked the compiler.

The gate must, on every run:

1. **Build the pinned project** and capture the full diagnostic stream, not a
   tail. Zero warnings is the default; a warning may be allowed only through an
   explicit, commented allowlist entry naming the declaration and the reason
   (typically a known false positive in a linter). An unexplained warning is a
   failure, so that "clean build" is a fact the tool establishes rather than a
   claim a session repeats.
2. **Audit axioms.** For every declaration named in the block-to-declaration
   map, run `#print axioms` and fail if any axiom lies outside the permitted
   set (`propext`, `Classical.choice`, `Quot.sound`). This is the concrete
   local replacement for a mission-wide whitelist (Section 15.2).
3. **Check `sorry`-freeness** across the project (Section 15.5).
4. **Record the outcome** in a derived artifact (`blocks/lean_audit.json`,
   containing the warning set, the axiom sets per declaration, and the
   toolchain/Mathlib revisions), and refuse to issue a `build_ok` verification
   record that does not match it. The verification record thereby records a
   measured fact, and a version bump (class F2) stales it through the
   environment facet as before.

The same discipline that makes the informal checks reproducible - derive, do
not assert - applies here. A session may state "clean build, axioms within the
permitted set" only because the gate computed it this run.

## 16. Session Continuity and the Agentic Writing Loop

This section makes explicit what earlier drafts left implicit: the
practices that let a long-running, multi-session agentic effort on a single
manuscript stay coherent, given that each session may start with no memory
of the last. These are as load-bearing as the evidence model itself, and
were arrived at the hard way.

### 16.1 The Continuity File

Maintain one running, human-readable narrative log (`STATE.md` or
equivalent) as the *primary* continuity mechanism between sessions - more
than chat memory, more than commit messages. Each session appends a dated
entry recording:

- what was attempted, in plain language;
- what closed versus what was honestly deferred or abandoned (never a
  placeholder tactic or a quietly weakened claim to make something look
  finished - a documented `sorry` with a precise note of what is missing is
  strictly preferable);
- concrete engineering gotchas hit and how they were resolved, so the next
  session does not re-pay the same cost;
- an updated, prioritized list of suggested next steps;
- a "safe restart checklist" of anything a new session must do or check
  before touching the project (environment variables, known-fragile
  commands, files not to touch without reading a specific caveat first);
- the exact command sequence that regenerates every derived view and runs the
  mechanical gate, exposed as a single orchestrator entry point. Derived views
  have dependencies among themselves (a bundle embeds the journal, which the
  session updates; a discrepancy report consumes the formal graph, which the
  facet extractor rewrites), so regenerating them "in the right order" is a
  real, repeatedly-hit failure mode when it is left to memory. The orchestrator
  regenerates them in dependency order and then runs `check_all`, so a session
  cannot end on a drifted view.

**Narrate the session while it runs (the live work log).** The continuity file
records what happened *after* the fact, and commits record the end state. Neither
lets a human follow a session *during* it: a long batch of tool calls with no
intervening explanation leaves the reasoning chain reconstructible only from
file diffs, which is exactly the "hard to follow your chain of work" failure.
A session therefore narrates itself in the response stream as it proceeds:

- **Open with a banner** - session number, the goal in one sentence, and the
  plan as a short numbered list of intended steps, so the reader knows the shape
  of the session before it starts.
- **Emit a step line after each meaningful action or small batch** -
  `step k/n: <what I did> -> <what it showed>` - so cause and effect are
  visible without reading the diffs.
- **Surface decisions where they are made** - when a result forces a choice
  (for example, layer-based versus field-based supersession after seeing the
  legacy records), state the options and the chosen one *before* acting on it,
  not only in the close-out. A decision that only appears in the final summary
  was, for the reader, not made until then.
- **Close with the durable summary** - file and evidence-ID inventory, the gate
  result, and what the continuity entry records.

The `STATE.md` entry remains the post-hoc record and the evidence records remain
ground truth; the live work log is the view a human follows in real time.

**Write this entry before spending remaining budget on more proof or
writing work, not after**, whenever the remaining budget is uncertain. A
session that finishes real, correctly recorded work in the block/evidence
records but runs out of room before writing its own continuity entry costs
the *next* session real effort rediscovering what happened - the entry is
the last step in the normal order, but should be moved earlier the moment
budget looks tight.

Because this file is a narrative aid, not the ground truth (`blocks/*.json`
and `evidence/*.json` are), a new session should spot-check its top
suggested item against the actual current records before trusting it,
especially if there is any reason to suspect it went stale.

### 16.2 Hand-Trace Before Coding

Before writing a nontrivial inductive or recursive proof - in Lean or in
prose - trace the argument fully by hand first: every case, every use of
the induction hypothesis, every edge case. Repeated experience shows that
skipping this step on genuinely novel structural recursion leads to
multiple wasted, rolled-back attempts, while hand-tracing first reliably
succeeds in one pass even on hard cases. Apply this proactively on any new
structural recursion or induction, not only after being reminded.

### 16.3 The Self-Check-Then-Independent-Audit Ladder

Apply increasing scrutiny in this order, and do not skip a cheap step to
reach for an expensive one:

1. **Self-re-read**, immediately after writing something substantial
   (Section 11a.2). Cheapest, catches the most.
2. **Same-session self-check against the manuscript**, for Lean/manuscript
   correspondence - useful, but explicitly weaker evidence, and must be
   labeled as such (`independence_caveat`).
3. **Independent two-stage blind audit** (Section 11.2 for
   correspondence, Section 11a.2 for informal-proof correctness) - reach
   for this before trusting a block's status as more than provisional,
   especially for headline results or before a submission.

A useful predictor of how much a step will cost, learned from direct
experience: reusing an already-proved pattern on new but structurally
similar content is cheap even when the underlying definitions differ a
lot; inventing a genuinely new argument with no template is expensive
regardless of how well it was hand-traced. When estimating effort for
scheduling (Section 17), weight "does this reuse an existing primitive or
pattern" more heavily than "does this look similar in difficulty to
something done before."

### 16.4 Decisions Reserved for the Author

An agent working autonomously across sessions should never, on its own
initiative:

- mint a new tracked block identifier or change the block registry's scope
  arithmetic;
- decide to pursue a materially different mathematical scope (for example,
  building a new computability layer to support a corollary that was
  previously out of scope);
- treat a contract as frozen, or register/publish a result externally;
- resolve an ambiguity in the author's own manuscript TODOs by guessing.

**Mechanical decisions are not reserved.** Record format, file layout, the
toolchain choice, calibration-model availability, and reconciling the declared
pilot membership with what has actually been built are *coordinator* decisions:
the coordinator takes the low-cost option, records it in the journal, and
reports it. They are not escalated as author audits. Only the items above -
contracts, manuscript prose, the representation, scope *changes*, freezes, and
escalations - require the author's attention. (Confirming that an existing
pilot list matches reality is bookkeeping, not a scope change.)

Present a reserved decision, with the concrete options and their consequences,
and stop there. This is not extra caution for its own sake - every one of these
decisions has downstream cost (new invalidation surface, new scope to
maintain) that only the author can weigh against the actual goal of the
work.

**How to present a reserved decision (the decision brief).** When reserved
decisions are due, the coordinator does not dump the raw queue. It presents
them one at a time, each as a short brief:

1. a *keynote* paragraph: what the situation is, in plain language, why it is
   reserved, and what turns on it;
2. the concrete artifact to audit -- the actual statement text, table, or
   numbers, not a bare path;
3. the consequences of each option: blast radius, what evidence goes stale, and
   downstream work;
4. a short numbered set of options, with a recommendation where one is clear.

The author answers item by item; each decision is recorded immediately
(journal + queue) and the next is presented. Decisions the code can make on its
own -- the mechanical ones above -- are never presented this way. This format
was adopted by the author in Session 33 and applies to every future session and
project.

### 16.5 Manuscript-Editing Sessions Specifically

When the working session's deliverable is the manuscript prose itself
(as opposed to Lean), the same discipline applies with two adjustments:

- **Scope before editing.** Read the full manuscript first, against
  whatever formalization or prior-audit experience exists, to distinguish
  proof sketches that hide real content from ones that are appropriately
  terse for the venue. Present a concrete, prioritized list to the author
  and get explicit confirmation of scope before making changes, rather than
  guessing at how much rewriting is wanted.
- **Resync mechanically after every edit, not at the end.** Apply Section
  13.3 continuously: recompute hashes, check cross-references, and run the
  encoding scanner after each substantive edit. This is what makes it
  possible to trace precisely which edit caused which hash change when
  several edits land in one session.

## 17. Scheduling Policy

### 17.1 Work Ordering

The coordinator orders work by:

1. **Risk first.** Blocks whose truth the author is least sure of are
   formalized early, because formalization is most valuable as a
   falsification tool.
2. **Criticality.** Blocks with high downstream fan-in, or on the critical
   path to headline results, precede peripheral ones.
3. **Stability.** Definitions are formalized early (they fix meaning for
   everything else) but frozen late (changing them is expensive).
4. **Cost.** Estimated effort, informed by Mathlib coverage and by the
   reuse heuristic in Section 16.3, is balanced against value.
5. **Limits on work in progress,** so that a single contract change does not
   waste many parallel efforts.

### 17.2 Treatment Tiers

Scrutiny is budgeted, not uniform (P14). Two tiers:

- **Light (default).** A light-path block needs current verification and an
  R1 self-check. For `full`-scope blocks correspondence is still required, but
  the informal proof gets no independent adversarial read until the block is
  promoted. This is the correct default: most lemmas are routine, and spending
  blind audits on them starves the results that actually need the scrutiny.
- **Cabinet.** A small, author-designated set of load-bearing blocks (headline
  theorems, definitions everything depends on, anything whose truth the author
  doubts). Cabinet blocks require current verification, current correspondence,
  an independent adversarial read of the informal proof, and R3/R4 review. The
  cabinet is deliberately small - a handful of blocks, not a percentage of the
  paper.

**Promotion.** A block is promoted into the cabinet when: the author designates
it; an audit returns a non-`equivalent` outcome; an adversarial or review
finding lands on it; or it lies on the critical path of a cabinet block.
Promotion is automatic on those triggers and recorded as a journal event;
demotion is an author decision. The tier is orthogonal to status (Section
8.3): it says how hard the system looks, not what it found.

**Budget consequence.** The number of full adversarial audits scheduled per
session is capped by the author's declared capacity, so the system degrades by
leaving blocks on the light path rather than by silently skipping scrutiny it
claimed to perform.

## 18. Evaluation Plan

The system is evaluated on a pilot manuscript chosen by the author: ideally
a paper in active development, in an area with reasonable Mathlib coverage,
containing at least one definition expected to change.

| Question | Measurement |
|---|---|
| Does propagation work? | Seeded changes of each class C0-C4 and F2; check that every affected evidence record becomes stale (soundness) and count unnecessary invalidations (precision) |
| Do correspondence audits catch mismatches? | Detection rate on the seeded-mismatch suite (Section 11.4), per mutation type |
| Do informal-proof audits catch defects? | Findings from the adversarial-read protocol (Section 11a) versus findings from self-checks alone, tracked over time |
| Does formalization improve the mathematics? | Number and class of findings (M-hypothesis, M-definition, M-gap, M-false) accepted by the author, and when in the drafting process they arose |
| Is provenance complete? | Reconstruct the full status of the project at arbitrary past journal points and compare with archived reports |
| What does it cost? | Author time on decisions and escalations per block; formalization effort per block class; continuity overhead (Section 16.1) |
| Does the computed closure capture the real dependencies? | Fraction of blocks whose tool-computed closure equals the reviewer-established closure, and the false-negative rate on seeded symbol/prose citations - the exact failure observed in practice when extraction leaned on `\ref` alone |
| Does model diversity actually help? | Calibration-suite detection rate split by model pair (Section 11.4), reported rather than assumed |
| Does the encoding audit catch representation divergences? | Detection rate on seeded encoding mutations; count of `faithful-with-caveat` residuals propagated into trust boundaries |
| Do the treatment tiers save effort? | Cabinet share of blocks; author time per block by tier; findings per unit effort by tier |

## 19. User Interface

The primary view presents mathematical and formal facets side by side for a
block: informal statement and proof, Lean statement and proof, read-back,
typed correspondence outcome, review findings, verification evidence,
dependencies, and pending decisions. Every status indicator links to the
evidence record that justifies it.

Project-level views:

- **Coverage:** status vectors across all blocks, filterable by scope, class,
  and treatment tier.
- **Representation:** the current encoding record, its audit outcome, the
  residual caveats it imposes, and the blocks it covers.
- **Trust boundary:** everything verified results rest on without proof in
  the project.
- **Discrepancy report:** differences between informal and formal
  dependency graphs.
- **Frontier:** open obligations across the project.
- **Staleness:** what became stale, why, and what rework is scheduled.
- **Decision queue:** contract changes, escalations, and freeze requests
  awaiting the author.

## 20. Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Agent review is confidently wrong | Review strength levels; isolated multiple reviewers; author sign-off for headline results; formal verification as an independent check on truth |
| Correspondence audit misses a mismatch | Typed outcomes, blind protocol, formal sanity checks, seeded-mismatch calibration |
| A freshly written informal proof is wrong even though it compiles as LaTeX | Mandatory self-re-read plus independent adversarial read before "Manuscript-ready" (Sections 11a, 16.3) |
| Common-mode failure when all agents share a model | Record model identity; diversify models where available; measure detection rates |
| Change misclassified as harmless | Hash-based default invalidation; salvage only with a decision record |
| Semantic dependencies missing from extraction, including name-only cross-references | Discrepancy report; explicit cross-reference grep on every edit (Section 13.3) |
| Manuscript hash tracking desyncs after edits shift line numbers | Anchor-based hashing, resync after every edit, verify by direct string search, not just script exit status |
| A legacy input encoding silently drops a character with no visible error | Post-edit non-ASCII scanner; always check the compiler's numeric exit code |
| Mathlib lacks the required theory | F-library classification; statement-only scope; visible trust boundary |
| A shared, mutable toolchain/cache is corrupted by an unrelated project's crash | Per-project pinned toolchain and package cache; never share a mutable cache (Section 15.3) |
| Author overwhelmed by escalations | Feedback classification; batching; thresholds for what requires the author; a fixed list of decisions reserved for the author (Section 16.4) |
| A session runs out of budget mid-work | Write the continuity-file entry before spending remaining budget on more proof/writing work, not after (Section 16.1) |
| Large manuscripts need manual curation | Incremental ingestion; pilot-first roadmap |
| An evidence record silently omits a dependency, so a real change does not invalidate it | Inputs are generated from the graph with a fail-closed closure (P13, Section 12.3); schema validation rejects malformed records |
| A wrong representation corrupts many audits at once | Encoding audit before statement audits (Section 11.5); class C6 propagation; calibration on seeded encoding mutations (Section 11.4) |
| The extra model needed for real independence is unavailable, so all work shares one model | Record `independence_caveat`; schedule a second model where available; report detection rate by model pair and treat a drop as a gate (Sections 9, 11.4) |
| Process overhead exceeds the value of the findings | Treatment tiers with a light default; a capped cabinet; overhead measured per tier (Sections 17.2, 18) |

## 21. Implementation Roadmap

Each phase ends with an explicit exit criterion. The order deliberately
front-loads the two things that decide soundness - dependency extraction and
the representation audit - because a pilot that leaves them to the end risks
validating the wrong system: it would confirm that the *bookkeeping* is
consistent while the dependencies and the encoding it records are wrong.

| Phase | Deliverables | Exit criterion |
|---|---|---|
| 0. Vertical slice | A **representation record** and its encoding audit; hand-built records for 10-20 pilot blocks; local, self-contained Lean project; one complete cycle including audit; one definition change propagated; one **Explanation** reconstructed from a formal proof and adversarial-read | A definition change propagates end to end, one omitted manuscript proof has been reconstructed and accepted, and the process is documented |
| 1. Ingestion, extraction, and calibration | Source inventory, symbol registry, lazy block registry with confirmed IDs, blueprint-compatible annotations, initial dependency graph seeded by symbol/prose extraction (Section 12.1), gap report, anchor-based hashing, and the **seeded-mismatch calibration suite stood up now** (Section 11.4) | Re-ingestion preserves every block identity or flags it; a seeded line-shift desyncs no hash; closure extraction recall measured against the hand closure; calibration detection rates reported per mutation type and model pair |
| 2. Evidence engine | Evidence records with **computed closures** (Section 12.3), hashing (informal and formal statement/proof split), validity rule, status vectors, journal, change classification including C6, salvage, schema validation | All seeded propagation tests pass soundness, including a representation change (C6) staling exactly its dependent surface; fail-closed closure blocks on an unresolved edge |
| 3. Audit pipeline | Read-back, comparator on a second model where available, the **encoding audit** (Section 11.5), formal sanity checks, the informal-proof adversarial-read protocol, seeded encoding mutations | Detection rates measured and reviewed by the author for all three audit protocols (statement, informal proof, encoding) |
| 4. Mechanical hygiene tooling | Automated hash resync, cross-reference blast-radius check, encoding scanner, exit-code-checked build script | Every edit to the manuscript triggers all four checks automatically |
| 5. Workspace and continuity | Side-by-side interface, project views, evidence bundles, `STATE.md`-style continuity file with a safe-restart checklist, treatment-tier scheduling (Section 17.2) | Evidence bundle for the pilot produced and usable by a third party; a new session can resume correctly from the continuity file alone |

## 22. Success Criteria

The system is successful when, on the pilot:

1. every manuscript change is attributable to a journal event, and any past
   project state can be reconstructed;
2. no evidence record is reported as current after one of its inputs has
   changed (verified by seeded tests);
3. correspondence audits and informal-proof audits both have measured
   detection rates, at a level the author judges adequate;
4. at every moment the author can see, for each block, which layers hold
   current evidence and what its trust boundary is;
5. formalization and the adversarial-read protocol together have produced
   findings that the author accepted into the manuscript;
6. the local build is clean, `sorry`-free, and axiom-checked at every
   milestone;
7. a new session can resume correctly using only the continuity file and
   the block/evidence records, without re-deriving lost context;
8. the author's time spent on system overhead is judged acceptable relative
   to these findings;
9. every evidence record's closure is computed from the graph and matches the
   hand-audited closure, so no real dependency is silently omitted;
10. the representation carrying the in-scope blocks has passed an encoding
    audit, and any residual caveat is visible in the block's trust boundary;
11. at least one manuscript proof that did not previously exist has been
    reconstructed from its formal counterpart, adversarial-read, and accepted
    (Section 11a.5).

## 23. Expected Outcome

The author supplies a manuscript and a research direction. The system
returns:

- a manuscript whose claims each carry a visible, current evidence status;
- Lean formalizations of the in-scope blocks, building locally and
  sorry-free;
- typed correspondence reports with their calibration data;
- an encoding-audit report for the project representation, with any residual caveat propagated to the trust boundary;
- reconstructed informal proofs (explanations) for blocks whose manuscript omitted them, each adversarial-read before acceptance;
- independent adversarial-read reports on the manuscript's own proofs;
- a trust boundary report;
- a record of mathematical findings produced by formalization and by
  adversarial reading;
- an explicit list of unresolved questions and open obligations, clearly
  marked as decisions for the author.

The system does not guarantee better mathematics. It makes the state of the
mathematics, and of its formalization, precise, current, and auditable,
which is what lets formalization and careful adversarial reading improve
the mathematics while it is still being written - entirely with local
tooling, with no dependency on any external platform.

## 24. Open Questions

1. Which pilot manuscript, and which of its results are the highest-value
   early targets?
2. How much author involvement per block is sustainable, and which
   escalations can be batched?
3. How robust can informal-text normalization be before hashing, especially
   under macro changes and name-only cross-references?
4. How strongly do errors of formalizer and auditor agents correlate when
   they share a model, and does model diversity measurably reduce this? (Now
   measurable: report calibration detection rate by model pair, Section 11.4,
   and record the auditor model on every correspondence/review record so the
   trust view can surface a same-model share, rather than repeating the caveat
   as prose.)
5. Should evidence bundles, including the adversarial-read reports, be
   offered to journal referees, and in what form?
6. Is there ever a concrete case for the optional external-registration
   adapter (Section 15.4), or does local-only verification remain
   sufficient indefinitely for this kind of project?
7. What is the right cabinet size and entry rule, and does automatic
   promotion on a finding over-escalate scrutiny?
8. For a set-theoretic paper in a type-theoretic prover, can encoding
   faithfulness be made formal for the hard cases (ambient universe,
   cross-family operations), or is `faithful-with-caveat` the honest steady
   state?
9. Does reconstructing informal proofs from formal ones (Section 11a.5) scale,
   or does it stall on arguments that are natural in Lean but alien in prose?
10. How much of a paper's dependency graph must be human-confirmed before
    closure generation can be trusted, and can the false-negative rate be
    driven low enough to make computed closures the default?
11. Can the formal facets be derived from the elaborated Lean environment
    cheaply enough to replace source-level scanning altogether, removing the
    whole class of "unrecognized declaration" gaps at the source (Section
    12.1)?
12. Does keying the definition closure on declaration identity fully eliminate
    remap fallout, or do other bookkeeping edits (renaming a declaration,
    splitting or merging a block) still leak into content hashes (Section
    13.2)?

## 25. Change Log

### Revision 3 - frontier-hardened

The following were added after carrying the pilot through a long run of
formalization-frontier sessions (roughly sessions 40-47); each names the
concrete observation that motivated it.

- **Statement/closure separation** (Sections 6, 7.2, 12.3, 13.1, 13.2 class
  C5): `definition_closure` is now its own hashed facet, keyed on declaration
  identity rather than block membership, so definition *content* still
  propagates to dependents while block-ownership bookkeeping does not.
  Motivated by a declaration remap - a helper introduced inside one block's
  proof, then registered against the block whose contract it actually
  formalizes - that changed a dependent's statement hash and forced a re-issue
  of records whose audit content was unchanged.
- **Declaration-ownership rule** (Section 6): a declaration belongs to the
  block whose contract it formalizes, even if first written to support another
  block's proof. Codifies the decision the remap above was making implicitly.
- **The mechanical Lean gate** (Section 15.6; Sections 13.3 item 4, 15.2,
  15.5): build with the full diagnostic stream captured (zero warnings, with a
  commented allowlist for justified false positives), `#print axioms` on every
  mapped declaration against the permitted set, a project-wide `sorry` check,
  and a derived `lean_audit` artifact a `build_ok` record must match. Motivated
  by a build reported as "0 warnings" across sessions while it in fact emitted
  a linter warning - no check noticed because the mechanical gate never invoked
  the compiler.
- **Re-issue vocabulary** (Sections 7.2, 8.1): evidence records gained
  `supersedes` and `reissue_reason`, and the status model separates *stale,
  awaiting re-audit* from *stale, superseded by a content-preserving re-issue*.
  Motivated by a run of mechanical re-issues (environment and hash moves) that
  otherwise read as a backlog of unverified claims.
- **Layer assignment by block kind** (Section 7.2): definitions and bundled
  structures carry verification only; propositions, lemmas, and corollaries
  carry correspondence and verification, plus review when a proof exists (or an
  Explanation, Section 11a.5). Promotes a convention that had been folklore to
  a normative rule.
- **Extractor fail-closed policy** (Section 12.1): an unrecognized declaration
  in a mapped file is an error, every supported declaration form carries a
  regression test, and deriving facets from the elaborated Lean environment
  (rather than source text) is the named target state. Motivated by repeated
  silent extractor gaps found one at a time (an attribute line, `noncomputable
  def`, `inductive`), each surfacing only because a mapping visibly failed.
- **Post-hoc declaration addition** (Section 13.3, item 4): adding a
  declaration to an already-verified block moves that block's own proof hash;
  re-issue its verification in the same session. Motivated by a block that went
  stale after a declaration was added a few steps after its verification was
  recorded, with the staleness missed until the next report was inspected.
- **Session orchestrator** (Section 16.1): one entry point regenerates the
  derived views in dependency order and then runs the gate, instead of relying
  on the session to rediscover the ordering. Motivated by a bundle that drifted
  because the journal was appended after the bundle had been regenerated.
- **Live work log** (Section 16.1): a session narrates itself as it runs - a
  banner with the plan, a step line per action, decisions surfaced where they
  are made - rather than being reconstructible only from diffs. Motivated by the
  author's report that the chain of work was hard to follow once a session
  started.
- **Auditor model recorded** (Sections 11.4, 24.4): correspondence and review
  records name the model, so the trust view can report a same-model share
  rather than repeating the caveat as prose.
- **Open questions extended** (Section 24, items 11-12): elaborated facets as
  a replacement for source-level scanning, and whether declaration-keyed
  closures fully eliminate bookkeeping fallout.

### Revision 2 - pilot-hardened

The following were added after running revision 1 end to end on a real pilot;
each names the concrete observation that motivated it.

- **Representation as an audited artifact** (P12; Sections 6, 7.1, 7.4, 9,
  11.1, 11.5, 13.2 class C6, 20, 22): a dedicated encoding-audit layer that
  runs before statement audits, with typed outcomes `faithful` /
  `faithful-with-caveat` / `unfaithful` and caveats propagated into trust
  boundaries. Motivated by a pilot block whose correspondence verdict was
  `incomparable` almost entirely because of an encoding choice, not a
  mathematical error.
- **Computed closures** (P13; Sections 7.2, 12.3, 22): evidence inputs are
  generated from the dependency graph with fail-closed resolution, never
  hand-authored. Motivated by a hand-authored record that silently omitted its
  dependency closure.
- **Stronger dependency extraction** (Section 12.1): symbol-usage and
  prose-name extractors alongside `\ref`/`\uses`. Motivated by a block whose
  `\ref`-only closure was of size 1 against a true closure of 7.
- **Formal-facet split** (Sections 6, 7.2, 13.1): `formal_statement` and
  `formal_proof` hashed separately, so proof irrelevance holds on the Lean side.
- **Explanations** (Sections 6, 10.1, 11a.5, 22, 23): reconstructing an
  informal proof from a formal one, then adversarial-reading it, as a Phase 0
  deliverable. Motivated by a pilot block the manuscript states without proof.
- **Treatment tiers** (P14; Sections 6, 7.3, 8.3, 17.2, 18, 20): a light
  default and a small, promotable cabinet.
- **Calibration early, by model pair, including encoding mutations**
  (Sections 9, 11.4, 18).
- **Lazy annotation** (Section 14): block IDs minted on the frontier, not
  wholesale.
- **Schema validation** (Sections 7.2, 10.4) and a normative-spec banner
  marking `Consolidated.md` as superseded.
- **Roadmap and success criteria** reordered to front-load extraction and the
  representation audit (Sections 21, 22).
