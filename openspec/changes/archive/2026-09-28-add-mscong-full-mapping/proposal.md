# Proposal

## Why

The M6 pilot (`add-mscong-correspondence`, archived) proved that the evidence
model scales to `mscong`: it minted block IDs for a six-block cluster, ingested
provenance, mapped the Lean declarations, and recorded correspondence/encoding
evidence — all while leaving `mslang` byte-identical. But `manuscript/MSCong.tex`
still has **176 unmarked theorem-like environments**, so the project's registry
is a six-block island: `gap_report.md` lists the rest as `proposed`, the
dependency graph is empty of them, and the Lean development can only be audited
block-by-block for the pilot.

This change **extends the M6 mapping to the whole manuscript**: every
theorem-like environment gets a stable block identity, the full registry/graph
is ingested, and every block that has a documented Lean counterpart is mapped.
It is the follow-on the pilot design anticipated (`design.md` "Open Questions").

## What Changes

- **Mint `\blockid{}`s for all 176 remaining `MSCong.tex` environments** (9
  assumptions, 47 definitions, 55 propositions, 12 corollaries, 51 remarks, 2
  lemmas), in document order, from the same `B-<letter><NNN>` grammar.
  The six pilot IDs stay unchanged (stable identities; the pilot evidence
  remains current); the new IDs use the `B-<?>0xx` range the pilot reserved.
- **Re-ingest `mscong`**: `blocks/mscong/registry.json` becomes 182 confirmed
  blocks, `hashes.json` grows to match, and the symbol/graph/gap artifacts are
  regenerated.
- **Map the Lean declarations** for every block with a documented counterpart
  (the M1–M5 results and the definitions they formalize), extending
  `lean/declarations.mscong.json`; regenerate `blocks/mscong/formal.json`.
- **Regenerate the `mscong` views and bundle** and append the journal events.
- **Defer**, recorded as caveats: per-block correspondence/review audits for
  the newly mapped blocks (an author-driven process, as for `mslang`), the
  `Sig_d`/`Alg_d`/Grothendieck layer, and `PRecILH`. Unlabelled/unmapped
  propositions are listed in `gap_report.md`.

## Capabilities

### New Capabilities

- `formalization/mcong-full-mapping`: the full-manuscript block mapping for the
  `mscong` project — complete block identities, ingested registry/graph, the
  curated declaration map, project-scoped views, and the deferred audits.

### Modified Capabilities

<!-- None as a delta. `formalization/mcong-correspondence` is a per-milestone
capability spec (this repository records each milestone as its own capability);
it is retained as the M6 pilot's historical spec, and the new
`formalization/mcong-full-mapping` capability describes the extended scope. -->
None. `formalization/mcong-correspondence` is retained as the M6 pilot's
historical capability spec (the repository records each milestone as its own
capability); the new capability describes the full mapping.

## Impact

- `manuscript/MSCong.tex`: 176 `\blockid{}` lines added; **no mathematical
  content change**, no label/ref change.
- `blocks/mscong/*`: registry/hashes/symbols/graph/formal grow; new audit
  backlog in `gap_report.md`.
- `lean/declarations.mscong.json`: curated declarations added.
- `reports/mscong/*` and `journal/mscong.jsonl`: regenerated/appended.
- **No** change to `mslang`, its golden baseline, the `Mscong` Lean sources, or
  the gate's behaviour.

## Note

This is a mechanical breadth change, not a new mathematical result. Its value
is making the whole `MSCong.tex` addressable by the evidence model so the
audit pipeline can be pointed at any block.
