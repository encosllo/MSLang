# Correspondence audit transcript -- `B-X002`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.congFi_nonempty_iff`, `Mslang.congFi_nonempty_of_finite_sorts` (`lean/Mslang/Regular.lean`)
- **Contract:** Example `B-X002`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `formal_weaker`
- **Recorded as:** `E-000330` (supersedes `E-000248`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back: B-X002.lean2
>
> Fixed ambient data: a type `S : Type u`; `Setoid` bundled; `(Φ s).r x y` is the
> relation. `Alg Sig` is referenced (with `.1`, `.2`) but not defined in-file.
>
> ## Notational abbreviations and definitions
>
> - `SSet S := S → Type u`; `Signature S := List S × S → Type u`;
>   `SortedEqv A := ∀ s, Setoid (A s)`.
> - `wordProd A w := (i : Fin w.length) → A (w.get i)`;
>   `finOp A w s := wordProd A w → A s`;
>   `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`.
> - `IsCongruence Sig F Φ := ∀ p σ a b, (∀ i, (Φ (p.1.get i)).r (a i) (b i)) →
>    (Φ p.2).r (F p σ a) (F p σ b)`.
> - `supp A := {s | Nonempty (A s)}`: the set of sorts at which `A` is inhabited.
> - `FiniteSSet A := Finite (Sigma A)`: finiteness of the total (sigma) type of
>   `A`, i.e. all sorts finite **and** only finitely many inhabited sorts.
> - `IsFiniteIndex Φ := FiniteSSet (quot Φ)`: the quotient by `Φ` has finitely many
>   total elements (finite index).
> - `congFi Sig F := {Φ | IsCongruence Sig F Φ ∧ IsFiniteIndex Φ}`: the set of
>   congruences of finite index.
> - `nabla A : SortedEqv A := fun _ => ⟨fun _ _ => True, ...⟩` (universal relation).
> - `quot Φ := fun s => Quotient (Φ s)`.
>
> ## Theorems
>
> 1. `congFi_nonempty_iff Sig A : (congFi Sig A.2).Nonempty ↔ (supp A.1).Finite`.
>    There exists a finite-index congruence of `A` iff only finitely many sorts of
>    `A` are inhabited. (No finiteness of the individual sorts is required — this
>    matches the finite-index notion via `nabla`.)
>    Proof: forward direction uses `supp_quot` to rewrite `supp A.1` as
>    `supp (quot Φ)` and extracts `.1` from `finiteSSet_iff`; backward direction
>    exhibits `nabla A.1`, using `nabla_isCongruence` and `isFiniteIndex_nabla`.
> 2. `congFi_nonempty_of_finite_sorts Sig [Finite S] A : (congFi Sig A.2).Nonempty`.
>    If the sort index type `S` is finite, then every `A` has a finite-index
>    congruence. Proof: from the previous theorem, `(supp A.1)` is finite as a
>    subset of finite `S`.
> 3. `finiteSSet_iff A : FiniteSSet A ↔ (supp A).Finite ∧ ∀ s, s ∈ supp A → Finite (A s)`.
>    Finiteness of the sigma type is equivalent to finitely many inhabited sorts
>    and each inhabited sort finite. (Forward direction of this equivalence is used
>    in theorem 1.)
> 4. `isFiniteIndex_nabla A (h : (supp A).Finite) : IsFiniteIndex (nabla A)`.
>    If only finitely many sorts are inhabited, the universal relation has finite
>    index (it collapses each inhabited sort to one class, so the quotient has one
>    element per inhabited sort).
> 5. `nabla_isCongruence Sig F : IsCongruence Sig F (nabla A)`.
> 6. `supp_quot Φ : supp (quot Φ) = supp A`.
>    Quotienting sortwise by any sorted equivalence does not change which sorts are
>    inhabited.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-X002 verdict
>
> - Clause "Cgr_fi(A) ≠ ∅ if and only if supp_S(A) is finite": matched by `congFi_nonempty_iff Sig A : (congFi Sig A.2).Nonempty ↔ (supp A.1).Finite`.
> - Clause "if card(S)<ℵ0 then for every Σ-algebra A, Cgr_fi(A) ≠ ∅": matched by `congFi_nonempty_of_finite_sorts Sig [Finite S] A : (congFi Sig A.2).Nonempty`.
> - Clause "the category Sgr-Act(Set) (objects (S,A,·,λ), left actions) satisfies the above condition, as do Mon-Act(Set), Grp-Act(Set) and Mod=CRng-Act(AbGrp)": no Lean counterpart.
> - Lean additionally provides `finiteSSet_iff`, `isFiniteIndex_nabla`, and `supp_quot`, which support the two main clauses.
>
> Contract clauses with no Lean counterpart: the assertion that Sgr-Act(Set) satisfies the condition, and the further examples Mon-Act(Set), Grp-Act(Set), Mod.
>
> Verdict: formal_weaker — the general iff and the finite-sort corollary are formalised, but the category-theoretic examples the block is built around are absent.
>
> Justification: the finite-index dichotomy is captured; the block's category examples have no Lean counterpart.

## Note

Re-read with the bodies of the supporting definitions included (the first pass
had shown definition statements only). See the Session 119 `STATE.md` entry.

