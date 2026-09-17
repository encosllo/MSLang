# Correspondence audit transcript -- `B-P018`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.algebraFormations_isAlgebraicClosureSystem`
  (with helpers `Mslang.HOperator_mono`, `Mslang.PFsdOperator_mono`,
  `Mslang.exists_mem_superset_finset`, and `Mslang.IsAlgebraicClosureSystemOn`
  in `Algebra.lean`; `lean/Mslang/Formation.lean`).
- **Contract:** Proposition `B-P018` (`FormAlgAlgLat`), section "`Σ`-congruence
  formations, `Σ`-algebra formations, and an Eilenberg type theorem for them".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000146`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `IsAlgebraicClosureSystemOn X C` has three clauses: `Set.univ ∈ C`; nonempty
> intersections `⋂₀ D ∈ C`; and nonempty directed unions `⋃₀ D ∈ C` (directed =
> any two members have an upper bound in `D`). The theorem instantiates `X :=
> Alg Sig` and `C := Form_Alg(Σ)`.
>
> Clause 1: `Alg(Σ)` is trivially a formation (both closures land in `Set.univ`).
> Clause 2: for `A ∈ HOperator(⋂₀ D)`, monotonicity `HOperator_mono` and
> `Set.mem_sInter` push the base witness into each `G ∈ D`, and `G`'s formation
> axiom gives `A ∈ G`; hence `A ∈ ⋂₀ D`; likewise for `PFsdOperator`.
> Clause 3: H-closure picks the single `F ∈ D` containing the base witness;
> P_fsd-closure chooses, for each of the finitely many factors `C i`, a member
> `Fi i ∈ D` containing it, combines them into one `G ∈ D` by
> `exists_mem_superset_finset` (finite iteration of directedness), and applies
> `G`'s formation axiom.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> (1) `Set.univ ∈ C` is `Alg(Σ) ∈ Form_Alg(Σ)`, i.e. the contract's fact (i).
> (2) the nonempty-intersection clause matches (ii) (set-indexed vs
> family-indexed nonempty intersections are equivalent). (3) the
> pairwise-upper-bound directedness plus `D.Nonempty` matches (iii)'s upward
> directed nonempty family. `IsAlgebraicClosureSystemOn` is exactly the
> one-sorted algebraic closure system instantiated at the plain set `Alg(Σ)`,
> and `Form_Alg(Σ) = {F | H(F) ⊆ F ∧ P_fsd(F) ⊆ F}` matches B-D032. The
> `Type (u+1)` is the artifact of `Alg` being a structure type, not a mismatch.
> No dropped nonemptiness, no weakened directedness, no added hypotheses.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.

## Provenance note

`IsAlgebraicClosureSystem` (`Algebra.lean`, the many-sorted B-D012) is
`u`-monomorphic and cannot be instantiated at `Alg Sig : Type (u+1)`; the
one-sorted `IsAlgebraicClosureSystemOn` (new, generic) is the encoding used.
This is an encoding device, not a block of the manuscript.
