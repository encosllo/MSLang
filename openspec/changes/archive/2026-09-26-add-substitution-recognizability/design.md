# Design

## Context

See `proposal.md` — Why. Current state that shapes the approach:

- M1 (`formalization/mcong-recognizability`, archived) supplies
  `Recognizable`/`RecognizableAt`, the finite-index characterization
  (`recognizable_iff_exists_finiteIndex_sat`), and the closure properties, all
  reusing `Mslang`'s `IsFiniteIndex`, `congCogenerated` (`Ω`), and `IsSat`.
- M2 (`formalization/mcong-basic-terms`, archived) supplies `PRecVar` and the
  finite two-element algebra, the base case `L^{0,z} = {z}` uses.
- `Mslang` supplies the free algebra `Term`/`termAlg`/`termLift` (the universal
  property), the subset operations (`Sub_union`/`Sub_inter`/`directImage`), the
  finite-index filter `congFi_filter`, and `deltaSub` (`δ^{s,L}`).
- `MSCong.tex` §3.2–§3.4 defines the substitution operators, the `z`-iteration
  `L^{⋆z}`, and the `z`-quotient `K^{-z}L`, and proves each preserves
  recognizability by refining the syntactic congruence of the inputs to a
  finite-index congruence of a bounded index `k_r 2^{k_r}`.
- `mscong` is still a scaffold (`ingested: false`).

## Goals / Non-Goals

**Goals:**

- Formalize the substitution operators and the induced homomorphism into the
  subset algebra, then `PRecSubs`, `PRecIt`, `PRecQ` in `Mscong`, reusing
  Mslang and M1/M2.
- Keep it **unmapped infrastructure**: no block IDs, no evidence, no change to
  `mslang`, `mscong` stays `ingested: false`.
- Build clean, `sorry`-free, within the permitted axiom set.

**Non-Goals:**

- Tree homomorphisms / hyperderivors / derivors (`PRecH`, `PRecLH`, `PRecILH`)
  — M4/M5.
- The locally-finite-index analogue of any of these.
- Any manuscript edit, block-ID minting, evidence record, or mapping.

## Decisions

### D1. Reuse the inductive free algebra and the subset algebra

As in M2, work on the inductive `Term Sig X` (recursor available) and state
recognizability through `RecognizableAt`. The "subset algebra" on `Sub (Term Sig X)`
has, for `σ : Σ_{w,s}`, the operation mapping `(A_i)` to the direct image
`{σ(a_i) mid a_i ∈ A_i}`; constants map to singletons. The induced substitution
homomorphism is `termLift` of the assignment `x ↦ L_x`. Rationale: the paper
defines the substitution operators exactly this way (via the universal property
into `T_Σ(X)^℘`), and it avoids the occurrence bookkeeping of a direct
recursive definition. Alternative (a recursive "occurrence-indexed"
substitution) rejected as the primary encoding — the subset-hom form is the
paper's and is what `PRecSubs` needs.

### D2. The substituted language is the subset-hom image

`((x\L_x))^♯_s(K)` is `{W | ∃ P ∈ K, W ∈ substHom L P}`. The recognizability
statement is about this set; it is expressible through `directImage` and
`InverseImage` of the subset hom, which keeps it close to `Mslang`'s `Sub`
vocabulary.

### D3. Finite-index refinement (the core of all three proofs)

Each proof refines the syntactic congruence `Φ` of the inputs:
- `PRecSubs`: `Φ = ⋂ (⋃_{t,x} {Ω(δ^{t,L_x})} ∪ {Ω(δ^{s,K})})`; finite index by
  the filter property (`congFi_filter`) and the finiteness of `S`,`X`.
- `PRecIt`: `Φ = Ω(δ^{s,L}) ∩ Ω(δ^{s,z})`.
- `PRecQ`: `Φ = Ω(δ^{s,L})`.
Then a relation `Ψ` is defined refining `Φ`, with `Ψ_r` the pairs agreeing on
membership in the finitely many `Φ_r`-classes' substituted languages; its index
is at most `k_r · 2^{k_r}`, hence finite. The work is to show `Ψ` is a
congruence of finite index saturating the target language and conclude
`IsFiniteIndex Ω(target)` via `recognizable_iff_exists_finiteIndex_sat`.

### D4. Module layout

The calculus goes in the existing scaffold `lean/Mscong/Substitution.lean`
(substitution operators + `PRecSubs`), with `Iteration.lean` and `Quotient.lean`
for `PRecIt`/`PRecQ` if the modules stay focused, all imported by `Main.lean`.
Rationale: keeps the compile-time graph shallow and the modules doc-scoped.

### D5. Unmapped infrastructure

No declaration is added to `lean/declarations.mscong.json`; the modules are
built by the `Mscong` default target and audited by `lean_audit.py --project
mscong`. Mapping and evidence are a later change (as in M1/M2).

## Risks / Trade-offs

- **The `Ψ` refinement and its index bound** (`k_r · 2^{k_r}`) is the technical
  heart of the paper and the main formalization risk: it needs a finite
  transversal of `T_Σ(X)/Φ` and a counting argument. Mitigation: build a small
  reusable "finite-index congruence → finite transversal/index" API once and use
  it for all three proofs.
- **The occurrence-indexed substitution** is avoided by D1, but the subset-hom
  form still needs the subset algebra's operations to be homomorphic; this is
  the same style as M2's `twoAlg`.
- **Assumption hygiene**: `PRecSubs` needs `S` and `X` finite, `PRecIt`/`PRecQ`
  only `S` finite. Keep the hypotheses exactly as the paper states.
- **Scope**: M3 is three propositions; if substitution alone proves large, the
  change may be closed in stages (substitution first), with iteration/quotient
  as a follow-up — a coordinator decision to record in `STATE.md`.

## Migration Plan

1. Extend `lean/Mscong/Substitution.lean` (and add `Iteration.lean`/
   `Quotient.lean`) in dependency order.
2. Iterate with a targeted `lake build Mscong.Substitution`.
3. Run the gate: `scripts/check_all.sh --fast`, one `scripts/check_all.sh` at
   close, and `lean_audit.py --project mscong`.
4. Record the milestone in `STATE.md`; leave `mscong.ingested: false`.

Rollback: additive to `Mscong` modules; reverting the commit restores the
scaffold.

## Open Questions

- Represent the finite transversal of `T_Σ(X)/Φ` with `Finset`/`Fintype` on the
  quotient, or with an explicit enumeration? Decide when building the reusable
  finite-index API.
- Split M3 into two changes (substitution; iteration+quotient) if the
  substitution proof is large — the roadmap groups them, but the paper's proofs
  for iteration/quotient are independent of `PRecSubs`.
