# Correspondence audit transcript -- `B-P030`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.langFormationOf`, `Mslang.mem_langFormationOf_iff`, `Mslang.langFormationOf_nabla`, `Mslang.langFormationOf_inf`, `Mslang.langFormationOf_ker` (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P030`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000316` (supersedes `E-000191`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-P030 — read-back (informal mathematics)
>
> ## Ambient setting
>
> The development is many-sorted. `S` is a fixed type of **sorts**. `SSet S` is a
> **sorted set** (a family of types, one per sort). `Signature S` is a many-sorted
> signature whose operation symbols are indexed by a pair `p = (w, s)` (input word
> `w : List S`, output sort `s`); `Sig p` is the set of operation symbols of that
> arity and result sort. `Term Sig X` is the many-sorted **term algebra** on the
> variables `X`; `termAlg Sig X` packages it as an `Alg Sig`. `SortedEqv A` is a
> **sorted equivalence relation** on `A` (one equivalence relation per sort);
> `Sub A` is a sorted family of subsets; `SortedMap A B` is a sort-preserving
> function; `wordProd A w` is the dependent product of `A` over the word `w`, and
> `finOp A w s` is the type of operations with input word `w` and output sort `s`.
>
> ### Order / lattice and basic constructions
>
> * `sortedEqvLe Φ Ψ` is **refinement**: every pair related by `Φ` is related by
>   `Ψ` (Φ is a sub-relation of Ψ).
> * `sortedEqvInf Φ Ψ` is the **binary meet** (the intersection relation: two
>   elements are related iff they are related by both `Φ` and `Ψ`); `Φ` and `Ψ`
>   are each above it in the refinement order.
> * `sortedEqvLe_antisymm` (`B-P030.lean:234`): if `Φ` refines `Ψ` and `Ψ` refines
>   `Φ`, then `Φ = Ψ`. So refinement is a partial order on sorted equivalences.
> * `charEqv L` (`:145`) is the **characteristic equivalence** of a subset `L`:
>   two elements are related iff membership in `L` agrees. `IsSat Φ X` (`:117`)
>   means `X` is a union of `Φ`-classes (Φ is compatible with, / preserves, `X`);
>   equivalently `Φ` refines `charEqv X` (see `isSat_iff_sortedEqvLe_charEqv`).
> * `congCogenerated Sig A L` (`:159`) is the **syntactic congruence** of `L`: the
>   greatest congruence on `A` refining `charEqv L`. It is a congruence
>   (`congCogenerated_isCongruence`, `:162`), it refines `charEqv L`
>   (`congCogenerated_le_charEqv`, `:165`), and it is greatest with that property
>   (`le_congCogenerated_of_isCongruence`, `:195`).
> * `nabla A` (`:200`) is the **universal** (total) relation on `A`;
>   `nabla_isCongruence` (`:202`) says it is a congruence.
> * `ker f` (`:189`) is the kernel relation of a sorted map; `ker_isCongruence`
>   (`:191`) says the kernel of an algebra homomorphism is a congruence.
> * `sat`, `quot`, `quotOp`, `quotAlg`, `pr`, `prAlg`: the saturation of a subset
>   under a relation, the quotient sorted set / quotient algebra by a congruence,
>   its operations, and the projection onto it. `quotOp_mk` (`:222`) records that
>   the quotient operation applied to classes is the class of the original
>   operation applied to representatives (well-definedness of the quotient
>   operations). `isAlgHom_prAlg` (`:174`) says the projection to the quotient is
>   an algebra homomorphism.
> * `IsCongruence Sig F Φ`: `Φ` is a congruence of the algebra `(A, F)` (an
>   equivalence compatible with all operations). `IsCongruence_inf` (`:109`) says
>   the meet of two congruences is a congruence. `isCongruence_iff_closesUnderEtl`
>   (`:178`) says a sorted equivalence is a congruence iff it is closed under
>   elementary translations.
> * `ClosesUnderEtl` / `ClosesUnderTl` (`:96`, `:98`): compatibility with
>   elementary translations / with all translations. `IsElemTranslation` (`:114`)
>   is the predicate that a map `A t → A s` is an elementary translation (an
>   operation with all but one argument fixed). `TlGen` (`:134`) is the inductive
>   family of translations: identities, elementary translations, and composites.
>   The theorems `closesUnderEtl_of_closesUnderTl` (`:147`),
>   `closesUnderTl_of_closesUnderEtl` (`:155`) and `closesUnderEtl_of_isCongruence`
>   (`:151`), `congruence_of_closesUnderEtl` (`:168`) relate these: Tl-closure and
>   Etl-closure coincide, congruences are Etl-closed.
> * `IsCongruenceFormation Sig G` (`:106`), for
>   `G : (A : SSet S) → Set (SortedEqv (Term Sig A))`, is the predicate that at
>   each `A` the set `G A` of congruences of the term algebra over `A` is
>   nonempty, every one of its members is a congruence of that term algebra, it is
>   closed under binary meets, and it is upward-closed in the refinement order
>   among congruences; in addition it is closed under a kernel operation along
>   homomorphisms that are surjective onto a quotient (used precisely in
>   `langFormationOf_ker`). The component `(hG.1 A).1` is nonemptiness,
>   `(hG.1 A).2.1` says every member is a congruence, `(hG.1 A).2.2.1` is
>   meet-closure, `(hG.1 A).2.2.2` is upward closure, and `hG.2` is the kernel
>   closure.
>
> ## Definitions introduced by this file
>
> * `langFormationOf Sig G` (`:1`) — the class of **languages associated with a
>   congruence formation** `G`. For each variable set `A`,
>
>   `langFormationOf Sig G A = { L ⊆ Term Sig A : congCogenerated Sig (termAlg Sig A) L ∈ G A }`,
>
>   i.e. the languages whose syntactic congruence lies in `G A`. (Here `G` maps
>   each `A` to a set of congruences of the term algebra over `A`.)
>
> ## Theorems
>
> 1. `mem_langFormationOf_iff` (`:7`).
>    Hypotheses: `hG : IsCongruenceFormation Sig G`; `A : SSet S`;
>    `L : Sub (Term Sig A)`.
>    Conclusion:
>    `L ∈ langFormationOf Sig G A ↔ ∃ Φ ∈ G A, IsSat Φ L`.
>    So membership in the language class is exactly the existence of *some*
>    congruence in `G A` compatible with `L` (not necessarily the syntactic one);
>    quantifiers: the `Φ` is existentially quantified and `A`, `L` are arbitrary.
>
> 2. `langFormationOf_nabla` (`:22`).
>    Hypotheses: `hG : IsCongruenceFormation Sig G`; `A : SSet S`.
>    Conclusion: `∀ L : Sub (Term Sig A), IsSat (nabla (Term Sig A)) L →
>    L ∈ langFormationOf Sig G A`.
>    Quantifiers: for all `L`. Since `IsSat` against the universal relation means
>    `L` is a union of universal classes, i.e. `L` is empty or full in each sort;
>    and `nabla ∈ G A` follows from `hG`, such `L` belongs to the class.
>
> 3. `langFormationOf_inf` (`:39`).
>    Hypotheses: `hG : IsCongruenceFormation Sig G`; `A : SSet S`.
>    Conclusion: for all `L, L' : Sub (Term Sig A)`,
>    `L ∈ langFormationOf Sig G A → L' ∈ langFormationOf Sig G A →
>     ∀ N : Sub (Term Sig A), IsSat (sortedEqvInf (congCogenerated Sig (termAlg Sig A) L)
>       (congCogenerated Sig (termAlg Sig A) L')) N → N ∈ langFormationOf Sig G A`.
>    Quantifier scope: `L`, `L'`, and `N` are all universally quantified after the
>    two membership hypotheses. In words: the class is closed under taking subsets
>    compatible with the meet of the two syntactic congruences; this is possible
>    because `G A` is closed under binary meets.
>
> 4. `langFormationOf_ker` (`:58`).
>    Hypotheses: `hG : IsCongruenceFormation Sig G`; `A B : SSet S`.
>    Conclusion: for all `M : Sub (Term Sig B)`,
>    `M ∈ langFormationOf Sig G B →` for every `f : SortedMap (Term Sig A) (Term Sig B)`
>    that is an algebra homomorphism (`IsAlgHom Sig (termAlg Sig A).2 (termAlg Sig B).2 f`)
>    and is **surjective onto the quotient** of `Term Sig B` by the syntactic
>    congruence of `M` (for every sort `s` the map
>    `x ↦ prAlg … (congCogenerated … M) s (f s x)` is surjective), for every
>    `N : Sub (Term Sig A)` with `IsSat (ker (prAlg … ∘ f)) N`, one has
>    `N ∈ langFormationOf Sig G A`.
>    In words: the language class is closed under inverse images along
>    homomorphisms that are surjective onto the quotient by the syntactic
>    congruence of `M`, where the inverse image is taken with respect to the
>    kernel of `prAlg ∘ f`.
>
> All other declarations in the file (`AlgStruct`, `IsAlgHom`, `IsSat`,
> `charEqv`, `termAlg`, `wordProd`, `finOp`, `quotOp`, etc.) appear as
> signature-only statements supplying the ambient interface; their intended
> content is described in the "Ambient setting" section above.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P030 verdict
>
> ## Clause-by-clause
>
> **Definition of `L_F` (contract, both displayed forms).**
> Contract: `L_F(A) = {L | ∃ Φ ∈ F(A), L = [L]^Φ}` equals `{L | Ω^{T(A)}(L) ∈ F(A)}`.
> Lean (`langFormationOf`, `mem_langFormationOf_iff`): defines
> `langFormationOf Sig G A = {L | congCogenerated Sig (termAlg Sig A) L ∈ G A}`
> (the second form) and proves `L ∈ langFormationOf ↔ ∃ Φ ∈ G A, IsSat Φ L`
> (the first form, since `IsSat Φ L` is exactly `L = [L]^Φ`). Both directions of
> the displayed set equality are present. Match.
>
> **Clause (1): `∇^{T(A)}-Sat(T(A)) ⊆ L_F(A)`, and in particular `∅^S`, `T(A)` are languages.**
> Lean `langFormationOf_nabla`: `∀ L, IsSat (nabla (Term Sig A)) L → L ∈ langFormationOf Sig G A`.
> This is exactly the ∇-saturation containment. The "in particular ∅, T" is an
> immediate corollary (∅ and the full set are ∇-saturated); not stated separately.
> Match (corollary derivable).
>
> **Clause (2): `L, L' ∈ L_F(A) ⟹ (Ω(L) ∩ Ω(L'))-Sat(T(A)) ⊆ L_F(A)`.**
> Lean `langFormationOf_inf`: for `L, L' ∈ langFormationOf`, every `N` with
> `IsSat (sortedEqvInf (congCogenerated … L) (congCogenerated … L')) N` lies in
> `langFormationOf`. `sortedEqvInf` is the meet ∩, `IsSat` quantifies over the
> saturated sets. Match.
>
> **Clause (3): `M ∈ L_F(B)`, every `Ω(M)`-epimorphism `f : T(A) → T(B)`, then
> `Ker(pr^{Ω(M)} ∘ f)-Sat(T(A)) ⊆ L_F(A)`.**
> Lean `langFormationOf_ker`: `M ∈ langFormationOf B` ⟹ for every hom
> `f : T(A) → T(B)` surjective onto the quotient by `Ω(M)` (i.e. an
> `Ω(M)`-epimorphism), every `N` with `IsSat (ker (prAlg ∘ f)) N` lies in
> `langFormationOf A`. Match.
>
> Contract clauses with no Lean counterpart: none (the "in particular ∅, T" is a
> derived corollary of the formalized ∇-saturation statement).
>
> Verdict: equivalent — the two displayed definitions of `L_F`, all three
> containment properties, and the epimorphism/Ker hypotheses correspond directly
> to `mem_langFormationOf_iff`, `langFormationOf_nabla`, `langFormationOf_inf`,
> and `langFormationOf_ker`.

