# Correspondence audit transcript -- `B-P013`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.termEval`, `Mslang.termEval_isAlgHom`,
  `Mslang.termEval_surjective` (`lean/Mslang/Term.lean`)
- **Contract:** Proposition `B-P013` (`AlgIsoQuotFree`): every `Σ`-algebra is
  isomorphic to a quotient of a free `Σ`-algebra.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`;
  `T_Σ(X)` is `Term Sig X`, homomorphism is `IsAlgHom`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `termEval Sig A : SortedMap (Term Sig A.1) A.1` is the recursive evaluation of
> terms of `A` in `A` (variable-term `a ↦ a`; operation node `↦ A.2` applied to
> the recursively evaluated children), i.e. the extension of the identity map on
> `A`'s carrier. `termEval_isAlgHom` proves it is a `Σ`-homomorphism from
> `termAlg Sig A.1` to `A`; `termEval_surjective` proves every component is
> surjective (`Term.var a` is a preimage of `a`). Together: evaluating terms over
> `A`'s carrier back into `A` is a surjective `Σ`-algebra homomorphism from the
> free algebra.
>
> Explicitly not claimed: no isomorphism is constructed (no injectivity,
> bijection, or inverse); no quotient structure is constructed (no congruence, no
> kernel relation, no quotient algebra or quotient map, and no explicit
> first-isomorphism-theorem identification `Term/ker ≅ A`).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> `termEval Sig A` is an `IsAlgHom` from the free algebra `Term Sig A.1` onto `A`.
> Taking the kernel congruence `ker(termEval)` and applying the first isomorphism
> theorem for many-sorted `Σ`-algebras gives `A ≅ Term Sig A.1 / ker(termEval)`, a
> quotient of a free algebra on the sorted set `A.1`; conversely any such
> isomorphism composes with the quotient projection to a surjective homomorphism
> from a free algebra onto `A`. The two assertions are inter-derivable, and the
> unconstructed congruence/quotient/isomorphism is exactly the standard
> first-isomorphism-theorem packaging, not extra mathematical content. The
> comparator noted as a caveat that this classification assumes the
> many-sorted first isomorphism theorem is available (or accepted as routine) —
> it is, as `B-P017`'s `quotAlg_ker_isAlgIso`.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
