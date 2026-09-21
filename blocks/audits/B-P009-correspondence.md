# Correspondence audit transcript -- `B-P009`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.ker_isCongruence`, `Mslang.ker_prAlg`, `Mslang.quotAlgLift_isAlgHom`, `Mslang.quotAlgLift_comp`, `Mslang.quotAlgLift_unique` (`lean/Mslang/Congruence.lean`)
- **Contract:** Proposition `B-P009`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000301` (supersedes `E-000096`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-P009.lean`
>
> ## Setting
>
> Fix a type of sorts `S` and a many-sorted signature `Sig` (assigning, to each pair `p = (w, s)` of a list
> of sorts `w : List S` and a result sort `s`, a type `Sig p` of operation symbols of that profile; the
> arity is represented as a list of input sorts). A sorted set `A` is a family of carrier types `(A s)`; an
> `AlgStruct Sig A` is an algebra structure on `A`, i.e. for each symbol `σ : Sig (w, s)` a function
> `A^w → A s` (`wordProd A w` is the product of the carriers along `w`; `finOp A w s` is the type of such
> operations). A `SortedMap f : A → B` is a family of maps `f s : A s → B s`. `IsAlgHom Sig F G f` says `f`
> commutes with all operation symbols. `ker f` is the kernel sorted equivalence of `f`. `IsCongruence Sig F Φ`
> says the sorted equivalence `Φ` is compatible with the operations of `F`. `quot Φ` is the sorted set of
> quotients fiberwise; `quotAlg Sig F Φ hΦ` is the quotient algebra (its underlying sorted set is
> `(quot Φ)`, with operations induced via `quotOp`); `prAlg Sig F Φ hΦ` is the quotient map viewed as a
> sorted map `A → (quotAlg Sig F Φ hΦ).1`. `sortedEqvLe Φ Ψ` means `Φ` refines `Ψ`. `quotLift Φ f h` is
> the induced map on quotients (defined in a previous file), available when `Φ` refines `ker f`.
>
> ## Theorems
>
> - **`ker_isCongruence Sig F G f hf`** (for `F` an algebra structure on `A`, `G` on `B`, `f` a sorted map,
>   and `hf : IsAlgHom Sig F G f`): `IsCongruence Sig F (ker f)`. If `f` is an algebra homomorphism then its
>   kernel is a congruence on the source algebra. Proof: given a profile `p = (w, s)`, a symbol `σ`, and
>   tuples `a, b` that are `ker f`-related pointwise (componentwise `f`-equal), one shows
>   `f s (F σ a) = f s (F σ b)` by rewriting both sides with the homomorphism property and applying
>   componentwise equality.
>
> - **`ker_prAlg Sig F Φ hΦ`** (with `hΦ : IsCongruence Sig F Φ`): `ker (prAlg Sig F Φ hΦ) = Φ`. The
>   kernel of the quotient map is `Φ` (delegates to `ker_pr`).
>
> - **`quotAlgLift_isAlgHom Sig F G Φ hΦ f hf h`** (with `hΦ : IsCongruence Sig F Φ`, `f : A → B`,
>   `hf : IsAlgHom Sig F G f`, and `h : sortedEqvLe Φ (ker f)`):
>   `IsAlgHom Sig (quotAlg Sig F Φ hΦ).2 G (quotLift Φ f h)`. The induced map `quotLift Φ f h` from the
>   quotient algebra to `G` is an algebra homomorphism. Proof: at each profile, after unfolding, one uses
>   the definition of `quotLift` (`Quotient.lift_mk`), then the fact `hf` that `f` is a homomorphism, and
>   finally that each input equals the class of its `Quotient.out` representative.
>
> - **`quotAlgLift_comp Sig F G Φ _hΦ f _hf h`**:
>   `(fun s => (quotLift Φ f h s) ∘ (prAlg Sig F Φ _hΦ s)) = f`. Composing the lift with the quotient map
>   yields `f`; this is the same statement as `quotLift_comp` (the congruence and homomorphism hypotheses
>   are unused).
>
> - **`quotAlgLift_unique Sig F G Φ _hΦ f _hf h p hp`** (with `p : SortedMap (quot Φ) B` and
>   `hp : (fun s => p s ∘ pr Φ s) = f`): `p = quotLift Φ f h`. Uniqueness: any sorted map out of the
>   quotient commuting with `pr Φ` to give `f` equals the lift (delegates to `quotLift_unique`).
>
> ## Declarations stated without bodies in this file
>
> `AlgStruct`, `IsAlgHom`, `IsCongruence`, `SSet`, `Signature`, `SortedEqv`, `SortedMap`, `finOp`, `ker`,
> `pr`, `prAlg`, `quot`, `quotAlg`, `quotLift`, `quotOp`, `sortedEqvLe`, `wordProd` are introduced here as
> declarations without bodies; the meanings are those described in the setting. This file contains the
> many-sorted algebraic counterpart of the universal property of the quotient, showing that kernels of
> homomorphisms are congruences and that quotients by congruences compute the expected homomorphic images.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P009 verdict
>
> Contract: if `f : A → B` is a homomorphism then `Ker(f) ∈ Cgr(A)`; and for `(pr^Φ, A/Φ)`: (1) `Ker(pr^Φ) = Φ`, (2) the universal property among homomorphisms.
>
> ## Clause-by-clause
>
> 1. **`Ker(f) ∈ Cgr(A)` when `f` is a homomorphism.** Lean `ker_isCongruence Sig F G f hf`: `IsCongruence Sig F (ker f)`, proved profile-wise using `hf`. Match.
> 2. **`Ker(pr^Φ) = Φ` for a congruence `Φ`.** Lean `ker_prAlg Sig F Φ hΦ`: `ker (prAlg Sig F Φ hΦ) = Φ` (delegates to `ker_pr`). Match.
> 3. **Universal property (existence, homomorphism).** Lean `quotAlgLift_isAlgHom Sig F G Φ hΦ f hf h`: `quotLift Φ f h` is an algebra homomorphism from the quotient algebra; `quotAlgLift_comp` gives `(quotLift Φ f h) ∘ prAlg = f` under `h : Φ ⊆ Ker(f)`. Match.
> 4. **Universal property (uniqueness).** `quotAlgLift_unique`: any sorted map `p` out of `quot Φ` with `p ∘ pr Φ = f` equals `quotLift Φ f h`. Match.
>
> ## Contract clauses with no Lean counterpart:
>
> none
>
> Verdict: equivalent
> The Lean read-back proves that kernels of homomorphisms are congruences, that `ker (prAlg) = Φ`, and that the induced quotient map is the unique algebra homomorphism factoring `f`, matching all contract clauses.

