# Correspondence audit transcript -- `B-R016`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declarations:** `Mslang.subfinalAlgebras`,
  `Mslang.subfinalAlgebras_isAlgebraFormation` (`lean/Mslang/Formation.lean`).
- **Contract:** Remark `B-R016`: `Sf(1)`, the set of subfinal `Σ`-algebras, is a
  formation of `Σ`-algebras.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `subfinalAlgebras` is the set of all `Σ`-algebras that are subfinal: `X` is
> subfinal when it is isomorphic (a homomorphism bijective on every sort) to the
> algebra carried by a subalgebra of the final algebra `1`; equivalently, by
> `subfinalAlg_iff`, when its carrier is subsingleton in each sort.
>
> `subfinalAlgebras_isAlgebraFormation` asserts that this set is a formation,
> i.e. closed under (1) homomorphic images (a surjective homomorphic image of a
> subfinal algebra is subfinal) and (2) finite subdirect products (a subdirect
> product of a finite family of subfinal algebras is subfinal).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The paper's definition of a formation is exactly closure under homomorphic
> images and finite subdirect products; non-emptiness (`1 ∈ Sf(1)`) and
> iso-closure are derived consequences (B-R014), not defining axioms. The
> read-back asserts precisely the two closure properties. The contract's
> "isomorphic to a subalgebra of `1`" is the definition of subfinal, and the
> subsingleton characterization is a proved equivalence (`subfinalAlg_iff`). The
> contract's intermediate steps (`∏ C^α ∈ Sf(1)`, `f[A] ∈ Sf(1)`, `A ≅ f[A]`)
> are proof moves, not extra requirements. No strength asymmetry.

## Residual note

The Lean proof of closure differs from the paper's: the paper routes H-closure
through `supp_S(A) = supp_S(B)` and "`f` is an isomorphism" (B-P001), while the
Lean uses `subfinalAlg_iff` (subsingleton components): a surjective image of a
subsingleton is a subsingleton, and a subobject of a product of subsingletons is
a subsingleton. The statement is unchanged. The record inherits the
pilot-encoding residuals (`carrier-model`, `small-large`, `univalence-missing`).
