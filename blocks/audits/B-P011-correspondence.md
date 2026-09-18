# Correspondence audit transcript -- `B-P011`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.termLift`, `Mslang.termLift_isAlgHom`,
  `Mslang.termLift_eta`, `Mslang.exists_unique_termLift` (`lean/Mslang/Term.lean`)
- **Contract:** Proposition `B-P011`, the free-algebra universal property.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`;
  in this encoding `T_Σ(X)` is the inductive term algebra `Term Sig X`, `η^X` is
  `termEta`, and homomorphism is `IsAlgHom`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `Term Sig X` is the inductive family of formal terms over the sorted set `X`
> (`var`/`op`); `termAlg Sig X` makes it a `Σ`-algebra; `termEta Sig X` inserts a
> variable as `Term.var x`. `termLift Sig X FA g` is the recursively defined
> extension of `g : X → A` (variables via `g`; operation nodes via `FA` applied to
> recursively lifted children), proved to be a homomorphism (`termLift_isAlgHom`)
> and to restrict to `g` along `termEta` (`termLift_eta`).
>
> **`exists_unique_termLift`.** For every `Σ`-algebra `(A, FA)` and every sorted
> map `g : X → A` there is a **unique** sorted map `f : Term Sig X → A` that is a
> homomorphism and satisfies `f ∘ termEta = g`; the uniqueness step invokes
> `termLift_unique`.
>
> Explicitly not claimed: nothing beyond this universal property; no equations,
> quotients, or initiality at the bundled level; `termEta` not claimed injective;
> uniqueness only among homomorphisms extending `g`; no finiteness or
> decidability side conditions.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> The read-back realises the contract's universal property at the same quantifier
> order and direction: `∀X, ∀(A,FA), ∀g : X→A, ∃! f : Term Sig X → A` that is a
> homomorphism and satisfies `f ∘ termEta = g`. The differences are packaging
> only: the sort/signature is fixed explicitly rather than existentially, `g` is
> the contract's `f`, the witness `termLift` is named rather than left
> existential, and uniqueness is factored through `termLift_unique` ("any
> homomorphism extending `g` along `termEta` equals `termLift`"), the same
> uniqueness class as the contract. No extra hypotheses (nonempty sorts,
> decidability, ...) are silently imposed.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
