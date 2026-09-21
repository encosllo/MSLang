# Correspondence audit transcript -- `B-R022`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.langFormationOf_eq_iUnion_satSets` (`lean/Mslang/Regular.lean`)
- **Contract:** Remark `B-R022`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000371`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back: B-R022.lean
>
> ## Ambient setup
>
> Fix a sort type `S : Type u` throughout; all structures are sorted by `S`.
>
> - `SSet S := S → Type u`: an `S`-sorted family of types (a many-sorted carrier).
> - `Signature S := List S × S → Type u`: a signature whose symbols are indexed by
>   an *arity pair* `p = (w, s)`, where `w : List S` is the list of input sorts and
>   `s : S` the output sort; `Sig p` is the (nonempty-or-not) type of operation
>   symbols of that arity.
> - `SortedEqv A := ∀ s, Setoid (A s)`: a family of equivalence relations, one
>   `Setoid` per sort. We write `(Φ s).r x y` for "`x` and `y` are Φ-related at
>   sort `s`".
> - `SortedMap A B := ∀ s, A s → B s`: a sort-preserving function family.
> - `Sub A := ∀ s, Set (A s)`: an `S`-sorted subset (one subset per sort).
> - `wordProd A w := (i : Fin w.length) → A (w.get i)`: the product of the
>   carrier over the sorts listed in `w`.
> - `finOp A w s := wordProd A w → A s`: an operation taking a `w`-indexed tuple
>   to an element of sort `s`.
> - `Term Sig X`: the inductive term type over variables `X : SSet S`. Constructors:
>   - `var {s} (x : X s) : Term Sig X s`;
>   - `op (p : List S × S) (σ : Sig p) (a : (i : Fin p.1.length) → Term Sig X (p.1.get i)) : Term Sig X p.2`.
>   So `op` takes a symbol `σ` of arity `(w, s)` together with one subterm per
>   entry of `w`, and returns a term of sort `s`.
> - `Alg Sig` (with fields `A.1 : SSet S`, `A.2 : AlgStruct Sig A.1`) is the
>   bundled algebra type used here.
>
> ## Definitions
>
> - `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`. An
>   interpretation of every symbol `σ : Sig (w,s)` as an actual operation
>   `wordProd A w → A s`.
>
> - `IsAlgHom Sig FA FB f` (where `f : SortedMap A B`, `FA`/`FB` interpret the
>   signature on `A`/`B`): for every arity `p = (w,s)`, every `σ : Sig p`, and
>   every tuple `a : wordProd A w`,
>   `f s (FA p σ a) = FB p σ (fun i => f (w.get i) (a i))`.
>   I.e. `f` commutes with every operation; a sorted homomorphism.
>
> - `IsCongruence Sig F Φ` (`Φ : SortedEqv A`): for every `p = (w,s)`, `σ : Sig p`,
>   and `a b : wordProd A w`, if `(Φ (w.get i)).r (a i) (b i)` holds for *every*
>   `i`, then `(Φ s).r (F p σ a) (F p σ b)`. I.e. each operation maps
>   componentwise-Φ-equivalent tuples to Φ-equivalent outputs; Φ is compatible
>   with the algebra operations.
>
> - `ClosesUnderEtl Sig A Φ`: for all sorts `t,s`, all `x y : A.1 t`, and all
>   `T : A.1 t → A.1 s`, if `T` is an elementary translation (`IsElemTranslation`)
>   then `(Φ t).r x y → (Φ s).r (T x) (T y)`. Φ is compatible with every
>   elementary (single-variable, others fixed) translation.
>
> - `ClosesUnderTl Sig A Φ`: same but for every `T` that is `TlGen`, i.e. Φ is
>   compatible with all *generated* translations (identities, elementary
>   translations, and their composites).
>
> - `IsElemTranslation Sig A t s T`: there exist `w : List S`, `i : Fin w.length`,
>   `hwit : w.get i = t`, `σ : Sig (w,s)`, and `a : ∀ k, k ≠ i → A.1 (w.get k)`
>   (values for all positions except `i`), such that for every `x : A.1 t`,
>   `T x` equals `A.2 (w,s) σ` applied to the tuple whose `i`-th entry is `x`
>   (transported across the equality `w.get i = t`) and whose other entries are
>   `a k`. In words: `T` fixes all arguments of a symbol except one and varies
>   that one.
>
> - `TlGen Sig A t s T`: the smallest inductive relation on maps `A.1 t → A.1 s`
>   containing `refl` (`id` at any sort `t`), `elem` (every elementary
>   translation), and `comp` (if `T : A.1 t → A.1 u` and `U : A.1 u → A.1 s` are
>   generated then `U ∘ T` is).
>
> - `sat Φ X` (for `X : Sub A`): at each sort `s`,
>   `{a : A s | ∃ x ∈ X s, (Φ s).r x a}` — the Φ-saturation of `X`.
>
> - `IsSat Φ X := sat Φ X = X` — `X` is Φ-saturated (closed under Φ-related
>   elements).
>
> - `satSets Φ := {X : Sub A | IsSat Φ X}` — the family of Φ-saturated subsets.
>
> - `charEqv L` (for `L : Sub A`): the sorted equivalence "same `L`-membership":
>   at sort `s`, `x ~ y` iff `x ∈ L s ↔ y ∈ L s`. (Setoid axioms from `Iff`.)
>
> - `congCogenerated Sig A L`: at sort `t`, `x ~ y` iff for *all* sorts `s`, all
>   `T : A.1 t → A.1 s`, `TlGen Sig A t s T → (T x ∈ L s ↔ T y ∈ L s)`. This is
>   the sorted equivalence cogenerated by `L` under generated translations, with
>   the pointwise Setoid structure.
>
> - `ker f` (for `f : SortedMap A B`): at each `s`, `x ~ y` iff `f s x = f s y`.
>
> - `langFormationOf Sig G A` (for `G : (A : SSet S) → Set (SortedEqv (Term Sig A))`):
>   the set of `L : Sub (Term Sig A)` such that
>   `congCogenerated Sig (termAlg Sig A) L ∈ G A`.
>
> - `IsCongruenceFormation Sig F` (for `F : (A : SSet S) → Set (SortedEqv (Term Sig A))`),
>   the conjunction of two parts:
>   1. For every `A : SSet S`:
>      - `F A` is nonempty;
>      - every `Φ ∈ F A` is a congruence on the term algebra `(termAlg Sig A).2`;
>      - `F A` is closed under `sortedEqvInf`: if `Φ, Ψ ∈ F A` then
>        `sortedEqvInf Φ Ψ ∈ F A`;
>      - `F A` is upward closed among congruences: if `Φ ∈ F A`, `Ψ` is any
>        congruence on the term algebra, and `sortedEqvLe Φ Ψ`, then `Ψ ∈ F A`.
>   2. For all `A B : SSet S`, every congruence `Θ` on `(termAlg Sig B)` with
>      `Θ ∈ F B`, every `f : SortedMap (Term Sig A) (Term Sig B)` that is an
>      algebra homomorphism, and such that for every sort `s` the map
>      `x ↦ prAlg Sig (termAlg Sig B).2 Θ hΘ s (f s x)` is surjective, the kernel
>      `ker (fun s => prAlg Sig (termAlg Sig B).2 Θ hΘ s ∘ f s)` lies in `F A`.
>      (A closure-under-preimages/quotient condition on the formation.)
>
> - `pr Φ s : A s → Quotient (Φ s)`, `x ↦ Quotient.mk (Φ s) x` — quotient map.
>
> - `quot Φ := fun s => Quotient (Φ s)`; `quotAlg Sig F Φ hΦ` is the bundled
>   algebra on `quot Φ` with operations `quotOp`; `prAlg` is the sorted quotient
>   map into it (`= pr Φ`).
>
> - `quotOp Sig F Φ p σ := fun a => Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))`
>   — the induced operation on the quotient, defined by choosing representatives
>   via `Quotient.out`. (The congruence hypothesis `hΦ` is unused in the body.)
>
> - `sortedEqvInf Φ Ψ`: pointwise intersection of the two equivalence relations
>   (the Setoid with `r x y := (Φ s).r x y ∧ (Ψ s).r x y`).
>
> - `sortedEqvLe Φ Ψ := ∀ s x y, (Φ s).r x y → (Ψ s).r x y` — pointwise
>   inclusion/refinement of sorted relations.
>
> - `termAlg Sig X`: the term algebra with carrier `Term Sig X` and operations
>   `Term.op`.
>
> ## Theorems (as stated)
>
> - `closesUnderEtl_of_closesUnderTl`: for `A : Alg Sig`, if `Φ` closes under all
>   generated translations, then `Φ` closes under elementary translations.
>
> - `closesUnderEtl_of_isCongruence`: if `Φ` is a congruence, then `Φ` closes
>   under elementary translations.
>
> - `closesUnderTl_of_closesUnderEtl`: if `Φ` closes under elementary
>   translations, then `Φ` closes under all generated translations.
>
> - `congruence_of_closesUnderEtl`: if `Φ` closes under elementary translations,
>   then `Φ` is a congruence.
>
> - `isCongruence_iff_closesUnderEtl`: `IsCongruence Sig A.2 Φ ↔ ClosesUnderEtl Sig A Φ`.
>
> - `congCogenerated_isCongruence`: for every `L : Sub A.1`,
>   `congCogenerated Sig A L` is a congruence for `A.2`.
>
> - `congCogenerated_le_charEqv`: `congCogenerated Sig A L ≤ charEqv L`
>   (if two elements are identified by the cogenerated relation then they have the
>   same `L`-membership).
>
> - `isSat_iff_sortedEqvLe_charEqv`: for `Φ : SortedEqv A` and `L : Sub A`,
>   `IsSat Φ L ↔ sortedEqvLe Φ (charEqv L)`.
>
> - `le_congCogenerated_of_isCongruence`: if `Φ` is a congruence and
>   `Φ ≤ charEqv L`, then `Φ ≤ congCogenerated Sig A L`.
>
> - `isSat_iff_le_congCogenerated`: for `L : Sub A.1` and a *congruence* `Φ` on
>   `A.2`, `IsSat Φ L ↔ sortedEqvLe Φ (congCogenerated Sig A L)`. (Among
>   congruences, lifting every `L`-element to a Φ-equivalent in `L` is exactly
>   being below the cogenerated congruence.)
>
> - `mem_langFormationOf_iff`: for `G` an `IsCongruenceFormation` and any
>   `A : SSet S`, `L : Sub (Term Sig A)`:
>   `L ∈ langFormationOf Sig G A ↔ ∃ Φ ∈ G A, IsSat Φ L`. I.e. a language belongs
>   to the formation iff it is saturated by some congruence in `G A`.
>
> - `langFormationOf_eq_iUnion_satSets`: for `G` an `IsCongruenceFormation` and
>   any `A : SSet S`,
>   `langFormationOf Sig G A = ⋃ Φ ∈ G A, satSets Φ`.
>   The formation is exactly the union, over all `Φ ∈ G A`, of the families of
>   Φ-saturated subsets. (Proved here via `ext` and `mem_langFormationOf_iff`.)
>
> Note: several of the statements above are declared without a proof body in the
> file; they are read as asserted claims.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-R022 verdict
>
> Contract (`B-R022.tex`): If 𝔉 is a formation of congruences w.r.t. Σ, then for
> every `A ∈ 𝒰^S`,
> `ℒ_𝔉(A) = ⋃_{Φ∈𝔉(A)} Φ-Sat(T_Σ(A)) = ⋃_{Φ∈𝔉(A)} Fix([·]^Φ)`.
>
> ## Clause-by-clause
>
> 1. *Hypothesis "𝔉 is a formation of congruences w.r.t. Σ."*
>    Lean: `IsCongruenceFormation Sig F` (readback lines 91–105), a conjunction of
>    nonemptiness, congruence-valuedness, `sortedEqvInf`-closure and upward closure
>    under congruences, plus the preimage/quotient condition. Matches the notion of
>    a congruence formation used by the remark. ✓
>
> 2. *`ℒ_𝔉(A)` = languages whose cogenerated congruence lies in 𝔉(A).*
>    Lean: `langFormationOf Sig G A := {L | congCogenerated Sig (termAlg Sig A) L ∈ G A}`
>    (line 87–89). ✓
>
> 3. *`⋃_{Φ∈𝔉(A)} Φ-Sat(T_Σ(A))` (the Φ-saturated subsets).*
>    Lean: `satSets Φ := {X | IsSat Φ X}` with
>    `IsSat Φ X := sat Φ X = X` and `sat Φ X = {a | ∃ x ∈ X, Φ x a}` (lines 69–75).
>    This is exactly the family of Φ-saturated subsets of the term algebra. ✓
>
> 4. *Second equality with `⋃ Fix([·]^Φ)`.*
>    Lean has no separate `Fix` symbol and no separately stated equality to it,
>    but `Fix([·]^Φ) = {X | sat Φ X = X} = satSets Φ` by the definition of `IsSat`
>    (line 72), so this clause is definitionally the *same* set as clause 3 and is
>    therefore covered by the same equality. ✓ (definitionally subsumed)
>
> 5. *The equality `ℒ_𝔉(A) = ⋃_{Φ∈𝔉(A)} Φ-Sat(T_Σ(A))`.*
>    Lean: `langFormationOf_eq_iUnion_satSets` (lines 165–169) states
>    `langFormationOf Sig G A = ⋃ Φ ∈ G A, satSets Φ`, resting on
>    `mem_langFormationOf_iff` (lines 160–163). Exact match. ✓
>
> Contract clauses with no Lean counterpart: none (the `Fix([·]^Φ)` form is the
> same set as `satSets Φ` by the definition of `IsSat`, so it needs no separate
> Lean statement).
>
> Verdict: equivalent — the Lean equality `langFormationOf = ⋃ satSets` is exactly
> the contract equality, and the `Fix([·]^Φ)` expression is definitionally the same
> family as `satSets Φ`.

