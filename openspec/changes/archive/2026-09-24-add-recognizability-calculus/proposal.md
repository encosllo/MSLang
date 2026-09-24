# Proposal

## Why

The `add-mscong-project` change stood up the second manuscript project
(`mscong`, `MSCong.tex`) as a scaffold but formalized none of its mathematics.
The next roadmap milestone, **M1**, is the *recognizability calculus* of
`MSCong.tex` §2.3 — the finite-index notions of congruence and language that
the paper's congruence-based recognizability proofs rest on. Formalizing it now
as Lean infrastructure advances the second project's frontier and de-risks the
later milestones, without requiring author-reserved block-ID minting or
flipping `mscong.ingested`.

## What Changes

- Add the **finite-index recognizability calculus** to `lean/Mscong`:
  - congruences of finite index (`Cgr_fi(A)`), and the fact that `Cgr_fi(A)` is
    upward closed / closed under finite meets, and a filter when `supp_S(A)` is
    finite;
  - the recognizability predicates `Rec_T(A)`, `Rec_s(A)`, `Rec(A)` and their
    `(lf, …)` companions only insofar as the finite-index half needs them;
  - the characterization propositions: `L` is `T`-recognizable iff saturated by
    some finite-index congruence iff `Ω^A([L, ∅^{S−T}])` has finite index; the
    `S`- and `s`-indexed specializations; and `L ∈ Rec_s(A)` iff
    `δ^{s,L} ∈ Rec(A)`;
  - the closure of `Rec(A)`/`Rec_s(A)` under the Boolean operations, translation
    preimages, and inverse images along homomorphisms.
- Implement it as **unmapped Lean infrastructure** in the existing `Mscong`
  library, reusing `Mslang`'s notions (`Cgr`, `Omega`/`congCogenerated`,
  `sat`/`IsSat`, `Quotient`, `IsFiniteIndex`, `SortedEqv`) rather than
  redefining them. No `\blockid`s are minted, `mscong.ingested` stays `false`,
  and no evidence records are written.
- Keep the development **clean and within the permitted axiom set** (the
  mechanical Lean gate), and record the milestone's findings and the deferred
  mapping/evidence decision in `STATE.md`.

## Capabilities

### New Capabilities

- `formalization/mcong-recognizability`: the M1 finite-index recognizability
  calculus for the `Mscong` project — requirements on what the development must
  contain, reuse, and guarantee (build/axiom cleanliness), and on its being
  unmapped infrastructure that does not disturb the default project.

### Modified Capabilities

<!-- None: no existing capability's requirements change. `orchestration/projects`
     already specifies the scaffold and per-project gate; M1 consumes it as-is. -->

## Impact

- `lean/Mscong/Recognizable.lean` (extended) and possibly a new
  `lean/Mscong/` helper module; `lean/Mscong.lean` umbrella unchanged unless a
  module is added.
- `STATE.md`: a session entry and the M1 status.
- **No** change to `mslang` artifacts, evidence, hashes, or views; **no**
  change to the gate's behavior; **no** manuscript edit; `mscong` remains
  `ingested: false` (its provenance checks stay deferred).
