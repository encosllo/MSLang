# Cross-model audit brief

Status: **OPERATIONAL BRIEF**. Hand this to an auditor running on a model family
other than `deepseek` (Architecture.md Sections 9, 11.2, 11.5, 11a.5). It is not
evidence; it is the protocol whose results the coordinator turns into evidence
records.

## 0. Context and goal

Every evidence record carries an **independence class** computed from the model
families of its audit stages (`scripts/status.py`, Architecture.md Section 9).
Every audit so far ran on one family (`deepseek-v4.1-flash`), so every positive
layer reports `provisional` rather than `pass`. A second family is the one
caveat the project cannot remove with its current resources (Architecture.md
Section 25.3 item 1). Once a second family's audits are recorded, the layers they
cover classify as `cross_model` and become `pass`.

## 1. Independence rules (non-negotiable)

1. **The auditor is independent.** Work only from the material pasted into each
   task. Do **not** consult `evidence/`, `STATE.md`, `reports/`, `journal/`, git
   history, or any existing verdict.
2. **No expected answer is given.** The verdict vocabulary is supplied; choose
   honestly.
3. **Two-stage tasks are blind.** Run stage 1 and stage 2 in **separate
   contexts**. Stage 2 sees only stage 1's read-back and the contract.
4. **Report identity.** State the model identifier and family (family = the first
   hyphen-separated segment of the id, e.g. `claude-sonnet-4` -> `claude`).
5. **Return transcripts verbatim**; the coordinator stores them as the record's
   justification.

## 2. Protocol A -- encoding (representation) audit (Section 11.5)

**Material:** the whole of `representation/pilot-encoding.md`.

**Task.** Audit whether the encoding faithfully represents the paper's ZFSK /
Grothendieck-universe foundation, and enumerate the *residual caveats* it imposes
(short labels). Judge each operation the paper uses (subset, componentwise
product/union/intersection/complement, `delta`, support, sorted equivalence,
saturation, quotient/projection, product) as representable, bridgeable, or
residual.

```
AUDIT: representation
ARTIFACT: representation/pilot-encoding.md
OUTCOME: faithful | faithful-with-caveat | unfaithful
RESIDUALS: <comma-separated short labels>
JUSTIFICATION: <one paragraph>
```

## 3. Protocol B -- two-stage blind correspondence audit (Section 11.2)

One run per block. The coordinator supplies (i) the block's Lean declaration
source, (ii) the definitions it uses (its definition closure), (iii) the informal
contract (the manuscript block text).

**Stage 1 (read-back)** -- paste only (i) and (ii):

> You see only the Lean declarations and their definitions below. You are not
> told the intended meaning. Write a precise informal read-back, in ordinary
> mathematical English, of what the declaration states -- hypotheses,
> conclusion, and quantification. Do not mention tactics or proofs.

**Stage 2 (comparison)** -- paste only stage 1's read-back and the contract:

> You see a read-back of a Lean declaration and the informal contract it should
> formalize. Decide the correspondence verdict: `equivalent` (same statement);
> `formal_stronger` (Lean assumes less / concludes more); `formal_weaker` (Lean
> assumes more / concludes less -- the contract is stronger); `incomparable`
> (neither implies the other); `ill_posed` (the contract cannot be made
> precise). State the verdict first, then justify in 3-6 sentences, checking
> hypotheses, quantification, and degenerate cases.

```
AUDIT: correspondence
BLOCK: B-XXXX
STAGE1_READBACK: <verbatim>
VERDICT: equivalent | formal_stronger | formal_weaker | incomparable | ill_posed
JUSTIFICATION: <3-6 sentences>
```

## 4. Protocol C -- adversarial read of a reconstructed proof (Section 11a.5)

For a block whose manuscript proof was reconstructed (`B-C001`, `B-C002`), the
coordinator supplies the definitions and the proposed proof
(`blocks/explanations/<id>.md`). Reconstruct the argument from the definitions
and proof alone, with no project history; probe edge cases (empty sets/sorts,
degenerate relations, boundary cases).

```
AUDIT: adversarial-read
BLOCK: B-XXXX
RESULT: VALID | GAP
FINDINGS: <reconstruction, edge cases probed, any gap>
```

## 5. Targets, in priority order

- **Tier 1.** Protocol A on `representation/pilot-encoding.md`; Protocol B on
  `B-P020` (first Eilenberg theorem), `B-P034`/`B-P039` (second Eilenberg
  theorem), `B-P035` (`Def1FRL <=> Def2FRL`).
- **Tier 2.** Protocol B on `B-C005`, `B-C006`, `B-C011`, `B-C012`, `B-C013`.
- **Tier 3.** Protocol C on `B-C001`, `B-C002`.
- **Tier 4.** Protocol B on the five accepted `formal_weaker` findings
  (`B-P001`, `B-D002`, `B-R001`, `B-R012`, `B-X002`), to confirm or challenge.
- **Optional (large).** Protocol B on the remaining mapped blocks; see
  `reports/coverage.md`.

The coordinator finds each block's declaration via `lean/declarations.json`
(`blocks.<BLOCK>.decl`/`.decls`, `.file`) and the contract at the
`\blockid{<BLOCK>}` line of `manuscript/MSEilenberg.tex`.

## 6. Ingestion (coordinator only -- not the auditor)

**a. Declare the second model** in `calibration/models.json`:
`{ "id": "<MODEL_ID>", "family": "<FAMILY>", "available": true }`
(`family` must equal the first hyphen-segment of the id; `scripts/models.py
--check` enforces it).

**b. Write the record with explicit stages spanning two families** (otherwise it
computes `same_model`). Correspondence:

```
python3 scripts/evidence.py new --block B-P020 --layer correspondence \
  --representation representation/pilot-encoding.md --representation-name encoding \
  --producer-role comparator --outcome <VERDICT> --protocol "two-stage blind" \
  --stage read_back_auditor=deepseek-v4.1-flash \
  --stage comparator=<MODEL_ID> \
  --finding "<JUSTIFICATION>" --write
```

Encoding audit:

```
python3 scripts/evidence.py new --block representation/encoding --layer representation \
  --producer-role encoding_auditor --outcome <OUTCOME> --protocol "encoding audit" \
  --residual carrier-model --residual small-large --residual univalence-missing \
  --stage formalization_worker=deepseek-v4.1-flash \
  --stage encoding_auditor=<MODEL_ID> \
  --finding "<JUSTIFICATION>" --write
```

Adversarial read: `--layer review --producer-role adversarial_reader --outcome
pass --strength R1 --protocol "adversarial read" --stage
adversarial_reader=<MODEL_ID> --stage coordinator=deepseek-v4.1-flash`.

**c. Save transcripts** to `blocks/audits/<BLOCK>-correspondence.md` (or
`-encoding.md`, `-adversarial.md`), then regenerate in order: `scripts/report.py`,
`scripts/discrepancy.py --report`, `scripts/frontier.py --report`, the journal
event, `scripts/decisions.py --report`, `scripts/bundle.py`; finish with
`scripts/check_all.sh` (slow) and commit.

**d. Verify independence:** the record's `independence.class` must read
`cross_model`; if it reads `same_model`, the stages did not span two families --
fix the `--stage` flags.
