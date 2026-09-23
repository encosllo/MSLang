# Design

## Context

See `proposal.md` — Why. Current state that shapes the approach:

- `mscong` is a scaffold (OpenSpec change `add-mscong-project`, archived):
  `lean/Mscong/Recognizable.lean` exists as an empty `namespace Mscong` that
  imports `Mslang.Regular`; `lean/declarations.mscong.json` is empty and
  `mscong.ingested` is `false`, so its provenance checks are deferred.
- `Mslang` already provides every preliminary the calculus needs: sorted
  equivalences and congruence (`SortedEqv`, `IsCongruence`), the cogenerated
  congruence (`congCogenerated`, `Ω`), saturation (`sat`, `IsSat`, `satSets`),
  quotients (`quot`, `quotAlg`), finite index (`IsFiniteIndex` =
  `FiniteSSet (quot Φ)`), the Kronecker delta (`delta`, `deltaSub`, `deltaT`),
  translations (`TlGen`, `transPreimage`), and recognizability-as-finite-index
  (`IsRegularLanguage`).
- The paper's §2.3 states the calculus over an arbitrary `Σ`-algebra `A`, a
  sort subset `T ⊆ S`, and a language `L ⊆ A↾_T`, with a locally-finite half
  and a finite-index half. Some propositions assume `S` finite.

## Goals / Non-Goals

**Goals:**

- Formalize the **finite-index** half of §2.3 in `Mscong`, reusing `Mslang`:
  `Cgr_fi` and its closure/filter facts; the recognizability predicates
  `Rec_T`, `Rec_s`, `Rec`; the characterization by finite-index saturation /
  `Ω`-finite-index; the `δ^{s,L}` bridge; and closure under Boolean operations,
  translation preimages, and inverse images along homomorphisms.
- Keep it **unmapped infrastructure**: no block IDs, no evidence, no change to
  `mslang`, `mscong` stays `ingested: false`.
- Build clean, `sorry`-free, within the permitted axiom set.

**Non-Goals:**

- The locally-finite-index half (`Cgr_lfi`, `Rec_lf`) — deferred to a later
  milestone.
- The finite-`S` subdirect-product result (`Rec(A) ≅ subdirect product of
  Rec_s(A)`), which needs `S` finite and is not on M1's critical path.
- Any manuscript edit, block-ID minting, evidence record, or mapping.
- The later milestones (basic terms, substitution, tree homomorphisms).

## Decisions

### D1. Reuse `Mslang` notions; do not redefine

`Mscong` imports `Mslang.Regular` (which brings `Congruence`, `Prelim`,
`Translation`, `Formation` transitively). Finite index is `Mslang.IsFiniteIndex`
(`FiniteSSet (quot Φ)`), congruences are `Mslang.IsCongruence`, saturation is
`Mslang.IsSat`/`sat`, and `Ω` is `Mslang.congCogenerated`. Rationale: one
formalization of the shared preliminaries; the spec's *Reuse of the `Mslang`
foundations*. Alternative (copy into `Mscong`) rejected — it would duplicate and
diverge.

### D2. `Rec_T` is encoded over a restricted carrier

A `T`-language of `A` is encoded as a dependent family
`(t : {t // t ∈ T}) → Set (A.1 t.val)`; `Rec` and `Rec_s` are the `T = univ`
and `T = {s}` specializations. The restriction maps `f↾_T` and `(f↾_T)⁻¹` are
built from `Mslang.SortedMap`/`inverseImage`. Rationale: matches the paper's
`A↾_T` and keeps `Rec_s` a genuine specialization. Alternative (only full
languages, no `T`) rejected — the paper's `T`-indexed statements are used later.

### D3. Definition first, characterization proved

`Rec_T(A)` is defined by the paper's existential form (a finite `Σ`-algebra
`B`, a homomorphism `f : A → B`, and `M ⊆ B↾_T` with `L = (f↾_T)⁻¹[M]`), and
the equivalent "saturated by a finite-index congruence" / "`Ω` has finite
index" form is a proved characterization. Rationale: the definition is the
contract; the characterization is the workhorse the later milestones use.
`Finite` on the algebra is `Mslang.FiniteSSet` on its carrier (`B-D008`).

### D4. Kronecker-delta bridge via existing concentration

`δ^{s,L}` is the existing `Mslang.deltaSub`/`deltaT` concentration; the bridge
`L ∈ Rec_s(A) ↔ δ^{s,L} ∈ Rec(A)` is proved from the definition, not by
re-encoding. Rationale: `Mslang` already has `deltaSub`/`deltaT` and their
support lemmas.

### D5. Unmapped infrastructure, mapped later

No declaration is added to `lean/declarations.mscong.json`; the module is
built by the `Mscong` default target and audited by `lean_audit.py --project
mscong` (when run). Rationale: the author chose to avoid block-ID minting in
M1; mapping and evidence are a later change. Mirrors how `Mslang` began
(`Term.lean` was infrastructure before mapping).

### D6. Module layout

The calculus goes in `lean/Mscong/Recognizable.lean`. If it outgrows one file,
split by dependency into `Mscong/Recognizable.lean` (definitions + predicates)
and a helper module imported by it; `Mscong.lean`/`Main.lean` import the
result. Rationale: keeps the compile-time dependency graph shallow (Mscong →
Mslang) and the file focused.

## Risks / Trade-offs

- **`Rec_T` restriction bookkeeping** can get fiddly (dependent `T`-families,
  `f↾_T`). Mitigation: define the general `Rec_T` once and derive `Rec`/`Rec_s`
  as specializations, rather than three independent definitions.
- **Finite-algebra encoding**: the paper's "finite `B`" is
  `Mslang.FiniteSSet B.1`; the "quotient is finite" direction must match it
  (as in `Mslang`'s `IsFiniteIndex`). Mitigation: prove the characterization
  through `IsFiniteIndex` and the first isomorphism theorem already used in
  `Mslang.Formation`.
- **Scope creep**: the locally-finite half and the finite-`S` subdirect result
  are adjacent. Mitigation: explicitly out of scope (Non-Goals); a follow-up
  milestone covers them.
- **Axiom creep**: the `Rec` characterization may use `Classical.choice`. The
  permitted set allows it; the gate records it.

## Migration Plan

1. Extend `lean/Mscong/Recognizable.lean` with the definitions and lemmas, in
   dependency order.
2. Iterate with a targeted `lake build Mscong.Recognizable`.
3. Run the gate: `scripts/check_all.sh --fast` (default project unaffected) and
   one `scripts/check_all.sh` at close; optionally
   `python3 scripts/lean_audit.py --project mscong` to audit the new
   declarations' axioms.
4. Record the milestone in `STATE.md`; leave `mscong.ingested: false`.

Rollback: the change is additive to one Mscong module; reverting the commit
restores the scaffold.

## Open Questions

- Should M1 also state the `S`-finite subdirect-product result (it needs the
  `S` finite hypothesis), or defer it to the term-algebra milestone where the
  paper uses it?
- When the calculus is mapped (a later change), are the §2.3 items given
  `\blockid`s in `MSCong.tex`, or registered as `proposed` first?
