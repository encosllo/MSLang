# Correspondence audit transcript -- `B-P015`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.algebraFormationOfCongruenceFormation`, `Mslang.algebraFormationOfCongruenceFormation_nonempty`, `Mslang.algebraFormationOfCongruenceFormation_abstract`, `Mslang.algebraFormationOfCongruenceFormation_HOperator`, `Mslang.algebraFormationOfCongruenceFormation_PFsdOperator` (`lean/Mslang/Formation.lean`)
- **Contract:** Proposition `B-P015`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000303` (supersedes `E-000178`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-P015.lean`
>
> *Blind first-stage correspondence audit. Only this file was read.*
>
> ## Caveat
>
> This file contains four fully proved theorems (the real content) plus a long
> block of *interface declarations* (`def`/`theorem`/`abbrev` with no body given).
> For those interface declarations the reading below is forced by their type and
> by how the four proofs use them; it is flagged as inferred where relevant.
>
> ## Setting and notation (many-sorted universal algebra)
>
> Fix a type `S` of sorts (universe `u`).
>
> - `SSet S` is the type of **S-sorted sets**: an object `A` is a family of
>   carriers `(A_s)_{s∈S}`, one type per sort.
> - `Signature S` is a **many-sorted signature**: for `p = (w, s)` with
>   `w : List S` a word of input sorts and `s : S` an output sort, `Sig p` is the
>   type of operation symbols of input arity `w` and result sort `s`.
> - `SortedMap A B` is the type of **S-sorted maps** `(f_s : A_s → B_s)_{s∈S}`.
> - `SortedEqv A` is the type of **S-sorted equivalences (setoids)**: a family
>   `(Φ_s)` where each `Φ_s` is an equivalence relation on `A_s`. Write
>   `x ~_{Φ,s} y` for `(Φ s).r x y`.
> - `sortedEqvLe Φ Ψ` (declared here, body not shown) is the **refinement order**
>   on sorted equivalences:
>   `sortedEqvLe Φ Ψ` iff for all sorts `s` and all `x, y : A_s`,
>   `x ~_{Φ,s} y → x ~_{Ψ,s} y`. I.e. `Φ ⊆ Ψ` as relations: `Φ` is *finer* than
>   `Ψ`. (In the proofs it is consumed as a function taking `s x y` and a proof
>   of `(Φ s).r x y` and returning a proof of `(Ψ s).r x y`.)
> - `sortedEqvInf Φ Ψ` (declared) is the **infimum / intersection** of sorted
>   equivalences: the coarsest relation contained in both.
> - `Alg Sig` is the type of **algebras**. An algebra `C` is a pair
>   `(C.1, C.2)`: `C.1 : SSet S` is the carrier and `C.2 : AlgStruct Sig C.1` is
>   the structure, interpreting every symbol `σ : Sig p` as an operation
>   `F p σ a` on arguments `a` drawn from the product `wordProd C.1 p.1`.
> - `wordProd A w` is the product `∏_{i<|w|} A_{w_i}`; `finOp A w s` is the type
>   of `w`-ary operations with result sort `s`.
> - `Term Sig X : S → Type u` is the inductive type of **many-sorted terms** over
>   a sorted set `X` of variables:
>   - `var x` for `x : X s` (a variable of sort `s`);
>   - `op p σ a` for `p = (w,s)`, `σ : Sig p`, and
>     `a : ∏_{i<|w|} Term Sig X (w_i)`; its sort is `s`.
> - `termAlg Sig X : Alg Sig` is the **term algebra** on `X` (operations are term
>   constructors); `termEta Sig X : SortedMap X (Term Sig X)` is variable
>   insertion.
> - `termEval Sig A : SortedMap (Term Sig A.1) A.1` evaluates a term in the
>   algebra `A` (the unique hom from the term algebra on the carrier of `A` to
>   `A`); `termLift Sig X FA g` is the unique hom `Term Sig X → FA` extending
>   `g` on variables.
> - `finalAlg Sig : Alg Sig` is the **final (terminal) algebra**; its carrier
>   `finalSorted S : SSet S` is a one-element type at every sort.
> - `iAlg Sig A` is the **product** of the family of algebras `A : ι → Alg Sig`.
> - `ker f : SortedEqv A` is the **kernel** of a sorted map `f : A → B`, i.e.
>   `x ~_{ker f,s} y ↔ f_s x = f_s y`.
> - `nabla A : SortedEqv A` is the **total (universal, "chaotic") relation**:
>   every pair in every sort is related.
> - `quot Φ : SSet S` and `quotAlg Sig F Φ hΦ : Alg Sig` are the quotient sorted
>   set and quotient algebra by an equivalence/congruence `Φ`; `pr`, `prAlg` are
>   the canonical projections; `quotLift Φ f h` is the map out of the quotient
>   induced by an `f` with `sortedEqvLe Φ (ker f)`.
> - `IsAlgHom Sig FA FB f` says a sorted map `f` is an **algebra homomorphism**;
>   `IsAlgIso Sig FA FB f` says `f` is an **algebra isomorphism** (a hom that is
>   bijective at every sort); `IsCongruence Sig F Φ` says `Φ` is a
>   **congruence** (compatible with the operations of `F`).
>
> ## The congruence-formation interface (inferred from use)
>
> `G : (A : SSet S) → Set (SortedEqv (Term Sig A))` assigns to each sorted set
> `A` a set of equivalences on the term algebra on `A`. `IsCongruenceFormation
> Sig G` (body not shown) is used as a bundle of closure conditions:
>
> 1. For every `A`, `G A` is **nonempty**, and every member of `G A` is a
>    **congruence** on the term algebra `Term Sig A`.
> 2. `G A` is closed under **finite intersections** (`sortedEqvInf`) and, more
>    importantly, is closed **upward in the refinement order**: if `Φ ∈ G A` and
>    `Θ` is a congruence with `sortedEqvLe Φ Θ`, then `Θ ∈ G A`.
>    (Thus the total relation `nabla` and `⊤` lie in `G A` whenever `G A` is
>    nonempty.)
> 3. A **pullback / substitution** closure: if `A, B` are sorted sets,
>    `Ψ ∈ G B`, and `g : Term Sig A → Term Sig B` is a homomorphism such that the
>    composite with the quotient projection `prB` is surjective at every sort,
>    then `ker (prB ∘ g) ∈ G A`.
>
> ## Definition `algebraFormationOfCongruenceFormation`
>
> `algebraFormationOfCongruenceFormation Sig G : Set (Alg Sig)` is
>
> > the set of algebras `C` for which there exist a sorted set `A`, a congruence
> > `Φ` on the term algebra `Term Sig A` with `Φ ∈ G A`, and an algebra
> > isomorphism `C ≅ Term Sig A / Φ`.
>
> Equivalently: up to isomorphism, the members are exactly the quotients of term
> algebras by congruences selected by `G`.
>
> ---
>
> ## Theorem 1 — `..._nonempty`
>
> **Hypotheses.** `Sig` a signature; `hG : IsCongruenceFormation Sig G`.
>
> **Conclusion.** `algebraFormationOfCongruenceFormation Sig G` is nonempty.
>
> **Content.** For any congruence formation `G`, the induced class of algebras is
> inhabited. The witness is the final algebra `finalAlg Sig`. Take
> `A₀ = finalAlg Sig`; `G A₀` is nonempty, so pick some congruence there; by the
> upward-closure clause of a formation, the total relation `nabla (Term Sig A₀)`
> belongs to `G A₀`. Its quotient has a one-element carrier at every sort
> (subsingleton, and nonempty because it contains the class of a variable), hence
> is isomorphic to the final algebra, whose every sort is a one-element type.
> Thus `finalAlg Sig` is (isomorphic to) a quotient of a term algebra by a
> congruence in `G`, i.e. a member of the class. *(No decidability or choice on
> the algebra side is needed; the proof uses `Classical.choice` only to name the
> unique element of each sort of the subsingleton quotient.)*
>
> ## Theorem 2 — `..._abstract`
>
> **Statement.** For all algebras `C, D`:
> `C ∈ algebraFormationOfCongruenceFormation Sig G` and the existence of an
> algebra isomorphism `C ≅ D` together imply
> `D ∈ algebraFormationOfCongruenceFormation Sig G`.
>
> **Content.** The class is **closed under iso­morphic images**: if one member is
> isomorphic to `D`, so is `D`. The proof composes the given isomorphism
> `C ≅ D` with the isomorphism `C ≅ Term Sig A / Φ` witnessing membership of `C`
> (inverse on one side, using that the inverse of an algebra iso is an iso).
> Quantifiers: `∀ C D`, hypotheses in the order "`C ∈ class`", then
> "`∃ f : C → D, f` iso".
>
> ## Theorem 3 — `..._HOperator`
>
> **Hypotheses.** `hG : IsCongruenceFormation Sig G`.
>
> **Conclusion.**
> `HOperator Sig (algebraFormationOfCongruenceFormation Sig G) ⊆
>  algebraFormationOfCongruenceFormation Sig G`.
>
> **Content.** `HOperator Sig F` is the **homomorphic-image operator**: `D` lies
> in it exactly when there is `C ∈ F` together with a sorted map `f : C → D`
> which is an algebra homomorphism and is surjective at every sort. The theorem
> says the class is **closed under homomorphic images** (under surjective
> homomorphic quotients).
>
> **Proof in words.** Let `D` be a surjective homomorphic image of `C` in the
> class. By Theorem 2's membership unfolding, `C ≅ Term Sig A / Φ` for some
> `A` and some congruence `Φ ∈ G A`. Let `QA = Term A / Φ`, `prA : Term A ↠ QA`
> the projection, `g : QA ≅ C` the chosen iso and `k = f ∘ g^{-1} : QA → D`,
> so `k` is a surjective hom. Then `kk = k ∘ prA : Term A → D` is a surjective
> hom, because `prA` is a surjective hom. Since `prA` identifies exactly the
> pairs in `Φ`, and `kk` factors through `prA`, we have `sortedEqvLe Φ (ker kk)`
> (`Φ` is contained in the kernel of `kk`). The kernel of a hom is a congruence,
> so by upward closure `ker kk ∈ G A`. By the first isomorphism theorem for
> surjective homs, `Term A / ker kk ≅ D`; hence `D` is a quotient of a term
> algebra by a congruence in `G`, i.e. `D` belongs to the class.
>
> ## Theorem 4 — `..._PFsdOperator`
>
> **Hypotheses.** `hG : IsCongruenceFormation Sig G`.
>
> **Conclusion.**
> `PFsdOperator Sig (algebraFormationOfCongruenceFormation Sig G) ⊆
>  algebraFormationOfCongruenceFormation Sig G`.
>
> **Content.** `PFsdOperator Sig F` is the **finite subdirect-product operator**:
> `A` lies in it exactly when there are a *finite* index type `ι`, algebras
> `C_i` (`i : ι`) each in `F`, and a sorted map `f : A → ∏_i C_i` which is an
> algebra homomorphism, injective at every sort, and such that for each `i` the
> composite `π_i ∘ f : A → C_i` with the `i`-th projection is surjective — i.e.
> `f` is a **subdirect embedding of `A` into a finite product of members of `F`**.
> The theorem says the class is **closed under finite subdirect products**.
>
> **Proof in words.** Suppose `A` is a subdirect product of finitely many factors
> `C_i`, each `C_i ∈ class`. Each `C_i ≅ Term B_i / Φ_i` with `Φ_i ∈ G B_i`.
> The term-evaluation `g : Term A ↠ A` is a surjective hom (where `A` here is the
> carrier of the subdirect product). For each `i`, define
> `k_i : Term A → Term B_i / Φ_i` by `x ↦ g_i(f(g x)_i)`, where `g_i` is the
> fixed iso `Term B_i / Φ_i ≅ C_i`. Each `k_i` is a surjective hom. Since term
> algebras are projective (the `term_projective` interface theorem: a hom into a
> quotient `B/Ψ` lifts along the projection `prB : Term → B/Ψ` to a hom into the
> term algebra), for each `i` there is a hom `h_i : Term A → Term B_i` with
> `prB_i ∘ h_i = k_i`. Put `Θ_i = ker (prB_i ∘ h_i) = ker k_i`. The pullback
> clause of the congruence formation (with the surjectivity of `prB_i ∘ h_i`)
> gives `Θ_i ∈ G A`. Then the finite infimum `Θ = ⋂_i Θ_i` is in `G A` (closure
> under finite intersections, with the empty infimum handled via upward closure
> from the nonempty `G A`). Finally `Θ ⊆ ker g`: if `x ~_{Θ,s} y` then each
> `k_i(x) = k_i(y)` (since `Θ ⊆ Θ_i`), so `f(g x) = f(g y)` (each component
> agrees), so `g x = g y` by injectivity of the subdirect embedding. The kernel of
> a hom is a congruence, so upward closure gives `ker g ∈ G A`. By the first
> isomorphism theorem `Term A / ker g ≅ A`, hence `A` is in the class.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P015 — second-stage verdict
>
> Contract: proposition defining `F_𝔉 = { C ∈ Alg(Σ) | ∃ A ∈ U^S, ∃ Φ ∈ 𝔉(A), C ≅ T_Σ(A)/Φ }`
> and asserting four properties (nonempty, abstract, H-closed, P_fsd-closed).
> Read-back: `B-P015.lean`.
>
> ## Clause-by-clause
>
> - **Definition of `F_𝔉`.**
>   Contract: `C ∈ F_𝔉` iff there exist a sorted set `A` and `Φ ∈ 𝔉(A)` with
>   `C ≅ T_Σ(A)/Φ`.
>   Lean: `algebraFormationOfCongruenceFormation Sig G` is the set of algebras
>   `C` for which there exist a sorted set `A`, a congruence `Φ` on
>   `Term Sig A` with `Φ ∈ G A`, and an algebra isomorphism `C ≅ Term Sig A / Φ`.
>   → **equivalent** (same quantifiers, same quotient construction).
>
> - **Clause (i): `F_𝔉 ≠ ∅`.**
>   Contract: nonempty.
>   Lean: `..._nonempty` (hyp. `IsCongruenceFormation Sig G`) proves the class is
>   inhabited, witness `finalAlg Sig` obtained as the quotient of a term algebra
>   by the total congruence.
>   → **equivalent**.
>
> - **Clause (ii): abstractness (C ∈ F_𝔉 and D ≅ C ⟹ D ∈ F_𝔉).**
>   Contract: closed under isomorphic images.
>   Lean: `..._abstract` states `C ∈ class` and an algebra isomorphism `C ≅ D`
>   imply `D ∈ class`. Isomorphism is symmetric, so the two readings coincide.
>   → **equivalent**.
>
> - **Clause (iii): `H(F_𝔉) ⊆ F_𝔉`.**
>   Contract: closed under homomorphic images.
>   Lean: `..._HOperator` gives `HOperator Sig (class) ⊆ class`, where
>   `HOperator` is surjective homomorphic images (image of a non-surjective
>   hom is a surjective-hom image, so no gap).
>   → **equivalent**.
>
> - **Clause (iv): `P_fsd(F_𝔉) ⊆ F_𝔉`.**
>   Contract: for every algebra `A`, if for some `n ∈ ℕ` and family
>   `(C^α)_{α∈n} ∈ F_𝔉^n` one has `Em_sd(A, ∏ C^α) ≠ ∅`, then `A ∈ F_𝔉`.
>   Lean: `..._PFsdOperator` gives `PFsdOperator Sig (class) ⊆ class`, where
>   `PFsdOperator` contains `A` iff there are a finite index type `ι`, factors
>   `C_i ∈ class`, and a sorted map `A → ∏_i C_i` that is a hom, injective at
>   every sort, with each projection composite surjective — i.e. a subdirect
>   embedding; `Em_sd ≠ ∅` is exactly the existence of such a map. Finite index
>   type ↔ `n ∈ ℕ`.
>   → **equivalent**.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — each of the four asserted properties and the defining
> formula of `F_𝔉` has a matching fully-proved Lean theorem with the same
> hypotheses and conclusion.

