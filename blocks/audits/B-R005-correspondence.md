# Correspondence audit transcript -- `B-R005`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.quot`, `Mslang.supp_quot`
  (`lean/Mslang/Pilot.lean`)
- **Contract:** Remark `B-R005`, section "Preliminaries".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000056`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> **`quot`.** For any type of sorts `S`, any `S`-sorted set `A`, and any sorted
> equivalence `Φ` on `A`, the *quotient sorted set* `quot Φ` has component at
> each sort `s` the quotient type of `A s` by `Φ s`: `(quot Φ) s := Quotient (Φ s)`,
> the set of equivalence classes.
>
> **`supp_quot`.** For any `S`, `A`, `Φ`, the support of the quotient sorted set
> equals the support of `A`: `supp (quot Φ) = supp A`, where `supp B` is the set
> of sorts `s` with `B s` nonempty. Proof by extensionality over sorts:
> - Forward: if `Quotient (Φ s)` is nonempty, say by `q`, then by
>   `Quotient.exists_rep` `q` is the class of some `x : A s`, so `A s` is
>   nonempty.
> - Backward: if `x : A s`, then `Quotient.mk (Φ s) x` inhabits `Quotient (Φ s)`.
>
> Consequently, quotienting componentwise never changes which sorts are
> nonempty.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> The read-back formalizes `A/Φ` exactly as the componentwise quotient
> `(quot Φ) s := Quotient (Φ s)`, matching `(A_s/Φ_s)`. The support predicate
> `{s : S | B s nonempty}` matches `{s ∈ S : B_s ≠ ∅}`, and the quantifier domain
> (`S`, arbitrary sorted set `A`, arbitrary sorted equivalence `Φ`) matches the
> contract. The theorem `supp (quot Φ) = supp A` is the same equality as
> `supp_S(A) = supp_S(A/Φ)` (same direction, both inclusions proved via
> `Quotient.exists_rep` and `Quotient.mk`), so the difference is
> notational/orientational only.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
Note the contract cites `propssupport`, but the Lean proof derives the equality
directly from the quotient construction; the cited proposition is not needed.
