# Correspondence audit transcript -- `B-D045`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsRegularLanguageFormation`, `Mslang.regularLanguageFormations` (`lean/Mslang/Regular.lean`)
- **Contract:** Definition `B-D045`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000369`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is faithful, not a weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back: B-D045.lean
>
> All definitions are parameterized by a fixed sort/index type `S : Type u`.
>
> ## Ambient vocabulary (defined in this file unless noted)
>
> - `SSet S := S → Type u`. A many-sorted carrier: for each sort `s : S`, a type `A s`.
> - `Signature S := List S × S → Type u`. An operation symbol is a pair `p = (w, s)`
>   (an input word `w : List S` and an output sort `s`), and `Sig p` is the type of
>   symbols of that arity.
> - `SortedEqv A := ∀ s, Setoid (A s)`. A sorted equivalence relation: for each sort
>   `s`, an equivalence relation `(Φ s).r` on `A s` (with `refl`/`symm`/`trans`).
> - `SortedMap A B := ∀ s, A s → B s`. A sort-preserving function.
> - `Sub A := ∀ s, Set (A s)`. A sorted subset (a predicate family).
> - `wordProd A w := (i : Fin w.length) → A (w.get i)`. The product of `A` over the
>   sorts of the word `w`.
> - `finOp A w s := wordProd A w → A s`. An operation of arity `(w, s)`.
> - `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`. An algebra
>   structure on carrier `A`: to each symbol of arity `(w, s)` it assigns an actual
>   operation `wordProd A w → A s`.
> - The bundled type `Alg Sig` is used throughout (`A.1` carrier, `A.2` operations)
>   but is not defined in this file: it is an ambient pair consisting of an
>   `SSet S` together with an `AlgStruct Sig` on it. I read `A : Alg Sig` as
>   `(A.1 : SSet S, A.2 : AlgStruct Sig A.1)` with `A.2 p σ : finOp A.1 p.1 p.2`.
>
> - `Term Sig X : S → Type u` is the inductively generated sorted term algebra over
>   the variable family `X : SSet S`:
>   - `var {s} (x : X s) : Term Sig X s`;
>   - `op (p : List S × S) (σ : Sig p) (a : (i : Fin p.1.length) → Term Sig X (p.1.get i)) :
>        Term Sig X p.2`.
>   So terms are built from sorted variables and symbols, respecting arities.
> - `termAlg Sig X : Alg Sig := ⟨Term Sig X, fun p σ a => Term.op p σ a⟩`, the term
>   algebra itself (carrier `Term Sig X`, symbols interpreted as the `op` constructor).
>
> - `IsSat Φ X := sat Φ X = X`, where `sat Φ X := fun s => {a | ∃ x ∈ X s, (Φ s).r x a}`.
>   `sat Φ X` is the closure of `X` under `Φ` (all elements `Φ`-equivalent to some
>   member of `X`). `IsSat Φ X` says `X` is `Φ`-saturated: closed under `Φ` both
>   ways; equivalently, at every sort `X s` is a union of `Φ s`-classes.
>
> - `nabla A : SortedEqv A` is the universal sorted equivalence: `(nabla A s).r` holds
>   for all pairs. Consequently `IsSat (nabla A) X` holds exactly when, at each sort
>   `s`, `X s = ∅` or `X s = univ` (since `sat nabla X s` is `univ` if `X s ≠ ∅` and
>   `∅` otherwise).
>
> - `sortedEqvInf Φ Ψ : SortedEqv A` is the pointwise intersection of two sorted
>   equivalences: `(Φ ∩ Ψ) s` relates `x,y` iff `(Φ s).r x y ∧ (Ψ s).r x y`, with the
>   evident setoid structure.
>
> - `ker f` for `f : SortedMap A B` is the sorted equivalence with
>   `(ker f s).r x y := f s x = f s y` (the kernel of `f`).
>
> - `quot Φ := fun s => Quotient (Φ s)`, the sorted set of equivalence classes.
> - `pr Φ s : A s → Quotient (Φ s)` is the class map `x ↦ [x]`.
> - `quotOp Sig F Φ p σ : finOp (quot Φ) p.1 p.2` sends a tuple of classes `a` to the
>   class of `F p σ (fun i => Quotient.out (a i))` (representatives chosen by choice;
>   hence the definition is `noncomputable`).
> - `quotAlg Sig F Φ hΦ : Alg Sig := ⟨quot Φ, fun p σ => quotOp Sig F Φ p σ⟩`, the
>   quotient algebra. The hypothesis `hΦ : IsCongruence Sig F Φ` is what makes
>   `quotOp` well-defined on classes.
> - `prAlg Sig F Φ hΦ : SortedMap A (quotAlg Sig F Φ hΦ).1 := pr Φ`: the projection to
>   the quotient algebra, by definition the class map `pr Φ`.
>
> - `IsAlgHom Sig FA FB f` (for `f : SortedMap A B`) says `f` is a homomorphism:
>   for every `p = (w,s)`, `σ : Sig p`, and `a : wordProd A w`,
>   `f s (FA p σ a) = FB p σ (fun i => f (w.get i) (a i))`.
>
> - `IsCongruence Sig F Φ` (for `F : AlgStruct Sig A`, `Φ : SortedEqv A`) says `Φ`
>   is a congruence: for every `p`, `σ`, and tuples `a b : wordProd A p.1`, if for
>   every coordinate `i` we have `(Φ (p.1.get i)).r (a i) (b i)`, then
>   `(Φ p.2).r (F p σ a) (F p σ b)`.
>
> - `IsElemTranslation Sig A t s T` (for `T : A.1 t → A.1 s`) says `T` is an
>   elementary translation: there exist a word `w`, a position `i : Fin w.length`
>   with `hwit : w.get i = t`, a symbol `σ : Sig (w, s)`, and constants
>   `a : ∀ k ≠ i, A.1 (w.get k)`, such that for every `x : A.1 t`,
>   `T x = A.2 (w,s) σ (fun k => if k = i then (transport of x along hwit) else a k _)`.
>   I.e. `T` is a one-hole derived operation: apply one symbol with the single
>   operand `x` in slot `i` and fixed constants elsewhere.
>
> - `TlGen Sig A : (t s : S) → (A.1 t → A.1 s) → Prop` is the inductive closure of
>   elementary translations under identity and composition:
>   - `refl t : TlGen Sig A t t id`;
>   - `elem : IsElemTranslation Sig A t s T → TlGen Sig A t s T`;
>   - `comp : TlGen t u T → TlGen u s U → TlGen t s (U ∘ T)`.
>   So `TlGen Sig A t s T` means `T` is a (unary) translation, i.e. a composition of
>   elementary translations.
>
> - `FiniteSSet A := Finite (Sigma A)`: the disjoint union of the carriers `A s` is
>   finite. `IsFiniteIndex Φ := FiniteSSet (quot Φ)`: `Φ` has finitely many classes
>   across all sorts.
>
> - `congCogenerated Sig A L : SortedEqv A.1`, for `L : Sub A.1`, is the equivalence
>   cogenerated by `L`: at sort `t`,
>   `x ~ y  ⟺  ∀ s (T : A.1 t → A.1 s), TlGen Sig A t s T → (T x ∈ L s ↔ T y ∈ L s)`.
>   Two elements are equivalent iff every translation (context) either sends both into
>   `L` or both outside `L`. The setoid laws are provided (`Iff.rfl`, `.symm`, `.trans`).
>
> - `IsRegularLanguage Sig A L := IsFiniteIndex (congCogenerated Sig A L)`: `L` is a
>   regular language over `A` iff its syntactic congruence has finite index.
> - `regularLanguages Sig A := {L | IsRegularLanguage Sig A L}`.
>
> - `ClosesUnderEtl Sig A Φ`: `Φ` is compatible with every elementary translation:
>   for all `t s`, `x y : A.1 t`, `T : A.1 t → A.1 s`, if
>   `IsElemTranslation Sig A t s T` and `(Φ t).r x y`, then `(Φ s).r (T x) (T y)`.
> - `ClosesUnderTl Sig A Φ`: `Φ` is compatible with every translation: for all `t s`,
>   `T`, if `TlGen Sig A t s T` then `(Φ t).r x y → (Φ s).r (T x) (T y)`.
>
> ## `IsRegularLanguageFormation` and `regularLanguageFormations`
>
> `L : (A : SSet S) → Set (Sub (Term Sig A))` assigns to each many-sorted set `A`
> a collection of sorted subsets of the term algebra `Term Sig A` (languages over the
> free term algebra on variables `A`). `IsRegularLanguageFormation Sig L` is the
> conjunction of four axioms:
>
> 1. (Regularity) `∀ A, L A ⊆ regularLanguages Sig (termAlg Sig A)`: every `X ∈ L A`
>    is a regular language over the term algebra `termAlg Sig A` (equivalently the
>    syntactic congruence `congCogenerated` has finite index).
> 2. (Trivial languages) `∀ A, ∀ X : Sub (Term Sig A), IsSat (nabla (Term Sig A)) X
>    → X ∈ L A`: `L A` contains every subset of each sort that is either empty or all
>    of that sort (saturated for the universal equivalence).
> 3. (Saturation closure) `∀ A, ∀ X Y : Sub (Term Sig A), X ∈ L A → Y ∈ L A →
>    ∀ N : Sub (Term Sig A), IsSat (sortedEqvInf (congCogenerated Sig (termAlg Sig A) X)
>    (congCogenerated Sig (termAlg Sig A) Y)) N → N ∈ L A`: if `X` and `Y` belong to
>    `L A`, then every `N` saturated for the intersection of the syntactic
>    congruences of `X` and `Y` (i.e. every `N` that is a union of common classes)
>    also belongs to `L A`.
> 4. (Preimage along surjective homomorphisms) `∀ A B (M : Sub (Term Sig B)),
>    M ∈ L B → ∀ f : SortedMap (Term Sig A) (Term Sig B), IsAlgHom Sig (termAlg Sig A).2
>    (termAlg Sig B).2 f → (∀ s, Function.Surjective (fun x => prAlg Sig (termAlg Sig B).2
>    (congCogenerated Sig (termAlg Sig B) M) (congCogenerated_isCongruence Sig (termAlg Sig B) M)
>    s (f s x))) → ∀ N : Sub (Term Sig A), IsSat (ker (fun s => prAlg Sig (termAlg Sig B).2
>    (congCogenerated Sig (termAlg Sig B) M) (congCogenerated_isCongruence Sig (termAlg Sig B) M)
>    s ∘ f s)) N → N ∈ L A`.
>    In words: given `M ∈ L B` and a term-algebra homomorphism
>    `f : Term Sig A → Term Sig B` whose composite with the projection onto
>    `Term Sig B / congCogenerated M` is surjective at every sort, the kernel of this
>    composite is a `SortedEqv` on `Term Sig A`; every `N` saturated for that kernel
>    lies in `L A`.
>
> `regularLanguageFormations Sig := {L | IsRegularLanguageFormation Sig L}` is the set
> of all such formations.
>
> ## Theorems (statements only, in file order)
>
> - `closesUnderEtl_of_closesUnderTl (Sig) (A) {Φ} (h : ClosesUnderTl Sig A Φ) :
>    ClosesUnderEtl Sig A Φ`.
>   If `Φ` is compatible with all translations, then it is compatible with all
>   elementary translations.
>
> - `closesUnderEtl_of_isCongruence (Sig) (A) {Φ} (h : IsCongruence Sig A.2 Φ) :
>    ClosesUnderEtl Sig A Φ`.
>   If `Φ` is a congruence for the operations of `A`, then it is compatible with all
>   elementary translations.
>
> - `congCogenerated_isCongruence (Sig) (A) (L : Sub A.1) :
>    IsCongruence Sig A.2 (congCogenerated Sig A L)`.
>   For every language `L`, its cogenerated (syntactic) equivalence is a congruence.
>
> - `congruence_of_closesUnderEtl (Sig) (A) {Φ} (h : ClosesUnderEtl Sig A Φ) :
>    IsCongruence Sig A.2 Φ`.
>   If `Φ` is compatible with all elementary translations, then `Φ` is a congruence.
>   (The converse direction of the characterization: step-by-step compatibility for
>   one coordinate at a time yields full operational compatibility.)
>
> - `isCongruence_iff_closesUnderEtl (Sig) (A) (Φ : SortedEqv A.1) :
>    IsCongruence Sig A.2 Φ ↔ ClosesUnderEtl Sig A Φ`.
>   For any sorted equivalence `Φ`, being a congruence for `A`'s operations is
>   equivalent to being compatible with every elementary translation. (Combines the
>   previous two: `→` is `closesUnderEtl_of_isCongruence`, `←` is
>   `congruence_of_closesUnderEtl`.)

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # Verdict: B-D045
>
> Read-back: `B-D045.readback.md` (IsRegularLanguageFormation / regularLanguageFormations, Lean)
> Contract: `B-D045.tex` (Def1FRL, formation of regular languages w.r.t. Sigma)
>
> ## Clause-by-clause
>
> - Preamble (global standing assumption, finite S): The contract opens with the
>   standing assumption that S is finite. The Lean read-back is parameterized over
>   `S : Type u`; under the audit convention that the standing assumption is part of
>   the contract and a Lean `[Finite S]` hypothesis is faithful, this is not a
>   weakening. No mathematical clause is dropped. Match.
> - Domain/type of L: Contract: `L` is a function on `U^S`, sending each
>   `A ∈ U^S` to a collection of languages with `L(A) ⊆ Lang_r(T_Σ(A))`.
>   Lean: `L : (A : SSet S) → Set (Sub (Term Sig A))` with `SSet S := S → Type u`
>   capturing `U^S`, and `L A ⊆ regularLanguages Sig (termAlg Sig A)`. Match.
> - Clause 0 (regularity containment `L(A) ⊆ Lang_r(T_Σ(A))`): Lean axiom 1
>   (Regularity) is exactly `∀ A, L A ⊆ regularLanguages Sig (termAlg Sig A)`.
>   Match.
> - Clause 1 (`∇^{T_Σ(A)}-Sat(T_Σ(A)) ⊆ L(A)`): Lean axiom 2 (Trivial languages):
>   `∀ A, ∀ X, IsSat (nabla (Term Sig A)) X → X ∈ L A`. `IsSat nabla` is
>   `nabla`-saturation, quantified over all saturated sets, i.e. the same
>   subset-inclusion. Match.
> - Clause 2 (`(Ω^{T_Σ(A)}(L) ∩ Ω^{T_Σ(A)}(L'))-Sat ⊆ L(A)`): Lean axiom 3
>   (Saturation closure): for `X,Y ∈ L A`, every `N` with
>   `IsSat (sortedEqvInf (congCogenerated … X) (congCogenerated … Y)) N` lies in
>   `L A`. `congCogenerated` is the syntactic (Myhill–Nerode) congruence, i.e. `Ω`,
>   and `sortedEqvInf` is the pointwise intersection. Match.
> - Clause 3 (`Ker(pr^{Ω^{T_Σ(B)}(M)} ∘ f)-Sat(T_Σ(A)) ⊆ L(A)` for every
>   `Ω^{T_Σ(B)}(M)`-epimorphism `f : T_Σ(A) → T_Σ(B)`): Lean axiom 4: for
>   `M ∈ L B`, a term-algebra homomorphism `f` (`IsAlgHom`) with
>   `prAlg … ∘ f` surjective at every sort, every `N` with
>   `IsSat (ker (fun s => prAlg … s ∘ f s)) N` lies in `L A`. The
>   "`Ω(M)`-epimorphism" condition (homomorphism whose composite with the class
>   projection is an epimorphism) is exactly `IsAlgHom` + sortwise surjectivity of
>   `prAlg ∘ f`; the kernel is the kernel of that composite; saturation is retained.
>   Match.
>
> No additional hypothesis is imposed and no conclusion is dropped or narrowed.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent
>
> Justification: All four conditions (`L(A) ⊆ Lang_r`, `∇-Sat ⊆ L(A)`,
> `(Ω(L)∩Ω(L'))-Sat ⊆ L(A)`, `Ker(pr ∘ f)-Sat ⊆ L(A)`) appear verbatim in the Lean
> conjunction, with the standing finite-S assumption absorbed faithfully.

