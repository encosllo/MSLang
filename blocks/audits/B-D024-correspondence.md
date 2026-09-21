# Correspondence audit transcript -- `B-D024`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsCongruence`, `Mslang.deltaEqv_isCongruence`,
  `Mslang.CongOn`, `Mslang.sInter_mem_CongOn`, `Mslang.sUnion_mem_CongOn`,
  `Mslang.CongOn_isAlgebraicClosureSystemOn`, `Mslang.congClosureOperator`,
  `Mslang.congClosedSets_isAlgebraicLattice`, `Mslang.congOrderIso`,
  `Mslang.congSubtypeCompleteLattice`, `Mslang.Cgr_isAlgebraicLattice`
  (`lean/Mslang/Congruence.lean`)
- **Contract:** Definition `B-D024`, section "Preliminaries".
- **Outcome:** `equivalent` (re-run in Session 119 after the `Cgr(A)` structure
  was formalized; supersedes the Session 118 `formal_weaker` verdict)
- **Recorded as:** `E-000280` (supersedes `E-000278`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `IsCongruence Sig F Φ`: the sorted equivalence `Φ` is compatible with the
> algebra structure `F` for signature `Sig` -- for every arity/coarity pair
> `p = (w, s)`, every symbol `σ : Sig p`, and all tuples `a b`, if
> `a i ~ b i` at every position `i` then `F p σ a ~ F p σ b`. `w` is an
> arbitrary finite list of sorts, the empty list included (there the hypothesis
> is vacuous and the conclusion is reflexivity). `CongOn Sig A` is the same
> condition on pair-sets in `EqvOn A.1`.
>
> `deltaEqv_isCongruence`: the discrete equivalence is a congruence.
> `sInter_mem_CongOn`: congruences are closed under arbitrary intersections
> (the empty family included). `sUnion_mem_CongOn`: closed under directed
> unions of nonempty families. `CongOn_isAlgebraicClosureSystemOn`: the
> congruences form an algebraic closure system on the pair space;
> `congClosureOperator` is its closure operator;
> `congClosedSets_isAlgebraicLattice` and `Cgr_isAlgebraicLattice` say the
> closed sets and the bundled congruences (via `congOrderIso`, an order
> isomorphism for inclusion vs refinement) are algebraic lattices;
> `congSubtypeCompleteLattice` transports the complete-lattice structure.
> Conspicuously not asserted: arbitrary-union closure, modularity/distributivity,
> compact-element descriptions, quotient/kernel correspondences, or separately
> named top/bottom theorems.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The defining compatibility clause is faithful. Lean quantifies over *all*
> finite arities, including the empty word, whereas the contract restricts to
> `S* − {λ}`; for a nullary symbol the Lean hypothesis is vacuous and the
> conclusion is `F σ a ~ F σ a`, satisfied by reflexivity, so the extra
> instances do not change the set of congruences -- a vacuous generalization,
> not additional content. `CongOn` is `Cgr(A)` and
> `CongOn_isAlgebraicClosureSystemOn` is the contract's "algebraic closure
> system on `A×A`"; `Cgr_isAlgebraicLattice` (with `congOrderIso`) is the
> algebraic lattice `(Cgr(A), ⊆)`; `deltaEqv_isCongruence` and the universal
> relation being a congruence give `Δ^𝐀`/`∇^𝐀` as the bottom/top, which the
> algebraic-lattice structure supplies.
>
> **Contract clauses with no Lean counterpart:** none.

## Note on the arity hypothesis (Session 118, retained)

The manuscript excludes the empty word via `(S* − {λ})`; Lean's `IsCongruence`
admits `w = []`. The Session 118 audit called this `formal_stronger` and,
because the `Cgr(A)` structural claims were then unmapped, reported the net
verdict `formal_weaker`. Session 119 mapped the structural claims; the stage 2
agent additionally judged the nullary extension *vacuous* (reflexivity), so the
net verdict is `equivalent`.

## Residual note

The record inherits the pilot-encoding residuals (`carrier-model`,
`small-large`, `univalence-missing`).
