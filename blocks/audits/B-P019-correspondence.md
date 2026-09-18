# Correspondence audit transcript -- `B-P019`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.congruenceFormationOf`,
  `Mslang.congruenceFormation_isCongruenceFormation` (`lean/Mslang/Formation.lean`)
- **Contract:** Proposition `B-P019` (`FormAlgentailsCgrForm`).
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`;
  `T_Σ(A)` is the inductive `Term Sig A` (the adopted encoding), `IsAlgebraFormation`
  is "formation of `Σ`-algebras", `IsCongruenceFormation` is "formation of
  congruences".
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> For a signature `Sig` and a class `F` of `Σ`-algebras, `congruenceFormationOf
> Sig F` sends each sorted set `A` to the set of sorted equivalences `Φ` on the
> free algebra `T_Σ(A)` that are congruences and satisfy `T_Σ(A)/Φ ∈ F`. The
> theorem: if `F` is an algebra formation, this assignment is a congruence
> formation. Per algebra: non-empty (`∇^{T_Σ(A)}`, since `T_Σ(A)/∇` is subfinal,
> hence in `F`); members are congruences; closed under pointwise meet (by
> `B-P016`, the formation intersection closure); up-closed under refinement (a
> coarser congruence gives a homomorphic image of the quotient). Cross algebra:
> for `Θ ∈ 𝔉_F(B)` and a homomorphism `f : T_Σ(A) → T_Σ(B)` with
> `pr^Θ ∘ f` surjective, `ker(pr^Θ ∘ f) ∈ 𝔉_F(A)` by the first isomorphism
> theorem (`T_Σ(A)/ker ≅ T_Σ(B)/Θ ∈ F`, transported by closure under
> isomorphism).
>
> Explicitly not claimed: no converse (every congruence formation arises from an
> algebra formation); no reconstruction of `F` from `𝔉_F`; nothing about
> non-free algebras; only binary meet and up-closure (no joins/infinite meets);
> the surjectivity hypothesis is assumed; no computational content.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> (i) Domain/codomain match: `𝔉_F` assigns to every `A ∈ U^S` a subset of
> `Cgr(T_Σ(A))`. (ii) The defining set is exactly `{Φ ∈ Cgr(T_Σ(A)) | T_Σ(A)/Φ ∈ F}`
> ("sorted equivalence + congruence" is membership in `Cgr`). (iii) The conclusion
> is the supplied `IsCongruenceFormation` predicate, with no extra hypothesis: the
> surjectivity condition is inside that predicate's cross-algebra clause, and the
> "not claimed" items (converse, reconstruction, joins) are outside the contract.
> The proof-route remarks (`B-P016`, first isomorphism theorem) carry no
> additional statement content.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
