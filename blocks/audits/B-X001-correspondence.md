# Correspondence audit transcript -- `B-X001`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declarations:** `Mslang.IsCyclicSub`, `Mslang.IsPeriodicAlg`,
  `Mslang.periodicAlgebras`, `Mslang.periodicAlgebras_closed_HOperator`,
  `Mslang.periodicAlgebras_closed_PFsdOperator`,
  `Mslang.periodicAlgebras_isAlgebraFormation` (`lean/Mslang/Regular.lean`).
- **Contract:** Example `B-X001`: `F_p`, the set of periodic `Σ`-algebras, is a
  formation of `Σ`-algebras.
- **Outcome:** `formal_weaker` (the Lean statement carries `[Finite S]`).
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> A subfamily `X ⊆ A` is cyclic if there is a sort `t` and a single element
> `a ∈ A(t)` with `X = Sg(δ^{t,a})`; `A` is periodic if every cyclic subalgebra
> of `A` is finite; `periodicAlgebras` is the class of periodic algebras.
>
> `periodicAlgebras_isAlgebraFormation` asserts: **assuming the sort set `S` is
> finite**, the class of periodic algebras is a formation — closed under
> homomorphic images and finite subdirect products. The only hypothesis carried
> is `[Finite S]`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `formal_weaker`.**
>
> The definitions of cyclic and periodic agree exactly. The contract states, for
> an arbitrary `S`-sorted signature and with no hypothesis on `S`, that `F_p` is
> a formation. The read-back's theorem carries `[Finite S]`, which is *not*
> implied by the contract. It matters for the contract's own `n = 0` clause:
> closure under the empty subdirect product requires the final algebra `1` to be
> periodic, but for an infinite `S` with an operation leading from the generating
> sort into infinitely many fresh sorts, the cyclic subalgebra `Sg_1(δ^{t,c})` is
> infinite, so `1` need not be periodic and the unrestricted claim can fail. The
> Lean statement establishes the formation property only for finite sort sets,
> strictly less than the contract's assertion for all `S`.

## Finding (a gap in the paper, not in the Lean)

The paper's `B-X001` is stated in Section 5, before the `[Finite S]` assumption
`B-A001` (Section 7). The empty subdirect product (`n = 0`) always places the
final algebra `1` in `P_fsd(F)` (the empty product is `1`, and `1` embeds
subdirectly in itself), so if `F_p` is a formation then `1 ∈ F_p`. But `1` need
not be periodic: with `S` infinite and operations `σ_n : () → n`, the cyclic
subalgebra `Sg_1(δ^{t,*})` reaches every sort, hence is infinite. So `B-X001`
fails as stated for infinite `S`. The formalization proves the true statement
(`[Finite S]`) and records the gap as `formal_weaker`.

## Residual note

The record inherits the pilot-encoding residuals (`carrier-model`,
`small-large`, `univalence-missing`).

## Correction re-audit (Session 117)

The manuscript was corrected (author-directed): the claim "the set `F_p` is a
formation" now reads "**If `S` is finite**, then the set `F_p` is a formation",
with a red note that the hypothesis is necessary (for infinite `S` the empty
subdirect product is the final algebra `1`, which need not be periodic). The
Lean declarations are unchanged (they already carry `[Finite S]`), so the
stage-1 read-back above still applies. A fresh stage-2 comparator was run
against the corrected contract and returned **`equivalent`**: the definitions
match, the corrected contract now carries the same `S finite` hypothesis as the
Lean, and the formation claim is the same. The prior record (`E-000246`,
`formal_weaker`) is superseded by `E-000255` (`equivalent`).
