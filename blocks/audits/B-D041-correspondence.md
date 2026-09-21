# Correspondence audit transcript -- `B-D041`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsFiniteIndexCongruenceFormation`, `Mslang.finiteIndexCongruenceFormations` (`lean/Mslang/Regular.lean`)
- **Contract:** Definition `B-D041`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000365`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is faithful, not a weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D041 — read-back
>
> Fixed data: sorts `S`; `SSet S := S → Type u`; `Signature S := (List S × S) → Type u`
> (an operation symbol has arity `p = (w, s)`, inputs `w`, output `s`).
>
> `Alg Sig` is *not* defined in this file; it is used as a bundled algebra whose
> `.1 : SSet S` is the carrier and `.2 : AlgStruct Sig A` its operations.
>
> ## Core definitions
>
> - `Term Sig X`: the inductive many-sorted term algebra over the variable
>   carrier `X : SSet S`.
>   - `var x`, for `x : X s`, is a term of sort `s`.
>   - `op p σ a`, for `p = (w, s)`, symbol `σ : Sig p`, and children
>     `a : (i : Fin p.1.length) → Term Sig X (p.1.get i)`, is a term of sort `s`.
> - `termAlg Sig X : Alg Sig`, carrier `Term Sig X`, operations
>   `(p, σ, a) ↦ Term.op p σ a`. The free term algebra.
> - `wordProd A w := (i : Fin w.length) → A (w.get i)`; `finOp A w s := wordProd A w → A s`;
>   `AlgStruct Sig A := (p) → Sig p → finOp A p.1 p.2`.
> - `SortedMap A B := ∀ s, A s → B s` (sortwise functions).
> - `SortedEqv A := ∀ s, Setoid (A s)` (sortwise equivalence relations).
> - `quot Φ := fun s => Quotient (Φ s)`.
>
> ## Congruence machinery
>
> - `IsCongruence Sig F Φ` (`F : AlgStruct Sig A`, `Φ : SortedEqv A`): for all
>   arities `p = (w, s)`, symbols `σ : Sig p`, tuples `a b : wordProd A p.1`, if
>   `(Φ (w.get i)).r (a i) (b i)` for every `i`, then
>   `(Φ s).r (F p σ a) (F p σ b)`. Compatibility of `Φ` with every operation.
> - `ker f`, for `f : SortedMap A B`: the sorted equivalence whose relation at sort
>   `s` is equality of images, `f s x = f s y`. (Reflexivity/symmetry/transitivity
>   are proved from equality.)
> - `pr Φ s : A s → Quotient (Φ s) := Quotient.mk (Φ s)`. The canonical projection.
> - `prAlg Sig F Φ hΦ : SortedMap A (quotAlg Sig F Φ hΦ).1 := pr Φ`. So it is the
>   projection as a sorted map into the quotient algebra carrier (type-correct
>   because `hΦ` witnesses that the quotient operations are well-defined).
> - `quotOp Sig F Φ p σ : finOp (quot Φ) p.1 p.2`, defined by
>   `a ↦ Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))`: represent each
>   input class by `Quotient.out`, apply the operation, and take the class. This is
>   a noncomputable choice-based definition of the quotient operation.
> - `quotAlg Sig F Φ _hΦ : Alg Sig := ⟨quot Φ, fun p σ => quotOp Sig F Φ p σ⟩`.
> - `sortedEqvInf Φ Ψ`: the sortwise meet (intersection) of two sorted equivalences,
>   relation `(Φ s).r x y ∧ (Ψ s).r x y`, with componentwise proofs.
> - `sortedEqvLe Φ Ψ := ∀ s x y, (Φ s).r x y → (Ψ s).r x y`. Inclusion of relations;
>   `Φ` is finer than `Ψ`.
> - `IsFiniteIndex Φ := FiniteSSet (quot Φ)`, `FiniteSSet A := Finite (Sigma A)`.
> - `congFi Sig F := {Φ | IsCongruence Sig F Φ ∧ IsFiniteIndex Φ}`.
>
> ## Theorems / main predicates
>
> - `IsCongruenceFormation Sig F`, where
>   `F : (A : SSet S) → Set (SortedEqv (Term Sig A))` is a family assigning to each
>   variable carrier `A` a set of sorted equivalences on the term algebra
>   `Term Sig A`. It asserts the conjunction of:
>   1. For **every** `A`:
>      - `F A` is nonempty;
>      - every `Φ ∈ F A` is a congruence of `termAlg Sig A`;
>      - `F A` is closed under finite meets: `Φ, Ψ ∈ F A` implies
>        `sortedEqvInf Φ Ψ ∈ F A`;
>      - `F A` is upward closed among congruences: if `Φ ∈ F A`, `Ψ` is a
>        congruence of `termAlg Sig A`, and `Φ ≤ Ψ` (`sortedEqvLe`), then `Ψ ∈ F A`.
>   2. (Inverse-image / surjectivity closure, quantified over all `A, B`.) For every
>      `Θ : SortedEqv (Term Sig B)` that is a congruence of `termAlg Sig B` with
>      `Θ ∈ F B`, and every `f : SortedMap (Term Sig A) (Term Sig B)` that is an
>      algebra homomorphism and whose induced map to the quotient is surjective at
>      every sort — i.e. for each `s`, `x ↦ prAlg Sig (termAlg Sig B).2 Θ hΘ s (f s x)`
>      is surjective — the kernel
>      `ker (fun s => prAlg Sig (termAlg Sig B).2 Θ hΘ s ∘ f s)` lies in `F A`.
>      This is the kernel of the composite of `f` with the projection onto
>      `B/Θ`, pulled back to a congruence on the free terms over `A`.
> - `IsCongruenceFormation` is a predicate, not a theorem; there are no `theorem`
>   declarations in this file.
> - `IsFiniteIndexCongruenceFormation Sig G`, for
>   `G : (A : SSet S) → Set (SortedEqv (Term Sig A))`:
>   `IsCongruenceFormation Sig G ∧ ∀ A, G A ⊆ congFi Sig (termAlg Sig A).2`.
>   I.e. `G` is a congruence formation and every member it assigns is a
>   finite-index congruence of the corresponding free term algebra.
> - `finiteIndexCongruenceFormations Sig := {G | IsFiniteIndexCongruenceFormation Sig G}`:
>   the set of all such `G` (the finite-index congruence formations).
>
> No `theorem`/`lemma` declarations; everything is definitional (with proof terms
> in the setoid structures).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D041 — verdict
>
> Contract: `𝔽` a formation of congruences w.r.t. Σ (DefFormCgr); `𝔽` is a
> formation of finite index congruences if for every `A`, `𝔽(A) ⊆ Cgr_fi(T_Σ(A))`;
> `Form_{Cgr_fi}(Σ)` the set of all such formations.
>
> ## Clause-by-clause
>
> - "formation of congruences ... as in DefFormCgr" — Lean:
>   `IsCongruenceFormation Sig F` with `F : (A) → Set (SortedEqv (Term Sig A))`:
>   nonempty, members are congruences of `termAlg`, closed under finite meets
>   (`sortedEqvInf`), upward closed among congruences (`sortedEqvLe`), and closure
>   under inverse images along surjective homomorphisms. Present (matches the
>   filter-valued formation notion).
> - "for every A ∈ U^S, 𝔽(A) ⊆ Cgr_fi(T_Σ(A))" — Lean:
>   `IsFiniteIndexCongruenceFormation Sig G := IsCongruenceFormation Sig G ∧
>    ∀ A, G A ⊆ congFi Sig (termAlg Sig A).2`. Present.
> - "Form_{Cgr_fi}(Σ)" — Lean:
>   `finiteIndexCongruenceFormations Sig := {G | IsFiniteIndexCongruenceFormation Sig G}`.
>   Present.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the imported DefFormCgr conditions are made explicit
> (`IsCongruenceFormation`) and the new finite-index clause plus the named set are
> both represented.

