# Correspondence audit transcript -- `B-P012`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declaration and its definitions (no manuscript, no
project record). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declaration:** `Mslang.term_projective` (`lean/Mslang/Term.lean`)
- **Contract:** Proposition `B-P012`, projectivity of the free `Σ`-algebra.
- **Outcome:** `equivalent`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`;
  `T_Σ(X)` is `Term Sig X`, homomorphism is `IsAlgHom`, and an epimorphism is a
  homomorphism with componentwise surjective components.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> Given algebras `B` (structure `FB`) and `C` (structure `FC`), a sorted map
> `f : B → C` that is a homomorphism (`hf`) and componentwise surjective
> (`hsurj`), and a homomorphism `g` from the free term algebra `Term Sig X` into
> `C`, the theorem produces a sorted map `l : Term Sig X → B` that is itself a
> homomorphism into `B` and satisfies `f ∘ l = g` componentwise. In plain terms:
> the free term algebra is projective with respect to componentwise-surjective
> homomorphisms. The construction chooses preimages of the generator images under
> `f`, extends that generator assignment by the universal property of `Term`, and
> verifies the equation by uniqueness.
>
> Explicitly not claimed: uniqueness of `l`; injectivity/bijectivity/quotient
> structure; a global section of `f`; surjectivity or image properties of `l`;
> `g` must be a homomorphism; no assumptions on the sorts or signature.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `equivalent`.**
>
> Quantifier order matches (`∀X ∀f ∀g ∃h`); the epimorphism is exactly `hf` plus
> componentwise surjectivity; the equation is `f ∘ h = g` in the same direction;
> `h` is explicitly a homomorphism. The domain/codomain bookkeeping
> (`f : B→C`, `g : Term Sig X → C`, `l : Term Sig X → B`) is the contract's
> (`f : A→B`, `g : T→B`, `h : T→A`) under renamed carrier variables only. The
> explicitly disclaimed extra properties (uniqueness of `l`, bijectivity, global
> sections) add no strength and drop no hypothesis.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.
