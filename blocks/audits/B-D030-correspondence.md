# Correspondence audit transcript -- `B-D030`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsCongruenceFormation` (`lean/Mslang/Formation.lean`)
- **Contract:** Definition `B-D030`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000354`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D030 read-back
>
> Fixed ambient data: a sort set `S : Type u` and a many-sorted signature
> `Sig : Signature S`. `Alg Sig` denotes a bundled algebra (carrier at `.1`, sorted
> operation structure at `.2`); it is used below but not itself defined here.
>
> ## Basic sorted-algebra infrastructure
>
> - `SSet S := S → Type u`. A many-sorted carrier: a type for each sort.
> - `Signature S := List S × S → Type u`. For each "operation profile" `p` consisting
>   of an input-sort list `p.1 : List S` and an output sort `p.2 : S`, a type
>   `Sig p` of operation symbols of that profile.
> - `SortedEqv A := ∀ s, Setoid (A s)`. A family, one equivalence relation per sort
>   (`Setoid` is Lean's bundled equivalence relation with field `.r`).
> - `SortedMap A B := ∀ s, A s → B s`. A sort-preserving (but not necessarily
>   operation-preserving) family of functions.
> - `wordProd A w := (i : Fin w.length) → A (w.get i)`. An element is a tuple of
>   elements of `A`, one for each entry of the sort list `w`.
> - `finOp A w s := wordProd A w → A s`. A raw operation of profile `(w, s)`.
> - `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`. An algebra
>   structure on the carrier `A`: each symbol of profile `p` is interpreted as a
>   function from tuples over `p.1` to the sort `p.2`.
>
> ## `Term Sig X : S → Type u` (inductive)
>
> The many-sorted term algebra on a variable carrier `X`:
>
> - `Term.var {s} (x : X s) : Term Sig X s` — a variable of sort `s`.
> - `Term.op (p : List S × S) (σ : Sig p)
>    (a : (i : Fin p.1.length) → Term Sig X (p.1.get i)) : Term Sig X p.2` —
>   applying symbol `σ` of profile `p` to a tuple of subterms whose sorts match the
>   entries of `p.1`, giving a term of sort `p.2`.
>
> - `termAlg Sig X : Alg Sig := ⟨Term Sig X, fun p σ a => Term.op p σ a⟩`: the term
>   algebra itself, whose operations are the term constructors.
>
> ## Homomorphisms and congruences
>
> - `IsAlgHom Sig FA FB f : Prop` where `FA : AlgStruct Sig A`, `FB : AlgStruct Sig B`,
>   `f : SortedMap A B`. It asserts
>   `∀ (p) (σ : Sig p) (a : wordProd A p.1),
>      f p.2 (FA p σ a) = FB p σ (fun i => f (p.1.get i) (a i))`.
>   That is: for every operation symbol, mapping the interpreted result equals
>   interpreting the operation on the mapped argument tuple (with `p.1.get i` giving
>   the input sort of the `i`-th argument).
>
> - `IsCongruence Sig F Φ : Prop` where `F : AlgStruct Sig A` and
>   `Φ : SortedEqv A`. It asserts
>   `∀ (p) (σ : Sig p) (a b : wordProd A p.1),
>      (∀ i, (Φ (p.1.get i)).r (a i) (b i)) → (Φ p.2).r (F p σ a) (F p σ b)`.
>   So `Φ` is a congruence on the algebra `F` when, for every operation, argumentwise
>   `Φ`-relatedness (at each input sort) forces `Φ`-relatedness of the two results
>   (at the output sort).
>
> ## Kernels, quotients, projections
>
> - `ker f : SortedEqv A` for `f : SortedMap A B`. Sortwise, `(ker f) s` is the
>   equivalence relation `x ~ y ↔ f s x = f s y` (reflexivity, symmetry, transitivity
>   supplied by `Eq`). This is the kernel of `f`, sortwise.
>
> - `pr Φ s : A s → Quotient (Φ s) := fun x => Quotient.mk (Φ s) x`: the canonical
>   projection of each sort onto its `Φ`-quotient.
>
> - `quot Φ : SSet S := fun s => Quotient (Φ s)`: the sortwise quotient carrier.
>
> - `quotOp Sig F Φ p σ : finOp (quot Φ) p.1 p.2 :=
>    fun a => Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))`:
>   the induced operation on the quotient, defined by choosing representatives via
>   `Quotient.out` and interpreting in `A`. (Its well-definedness uses `hΦ`.)
>
> - `quotAlg Sig F Φ _hΦ : Alg Sig := ⟨quot Φ, fun p σ => quotOp Sig F Φ p σ⟩`: the
>   quotient algebra of `A` by the congruence `Φ`.
>
> - `prAlg Sig F Φ hΦ : SortedMap A (quotAlg Sig F Φ hΦ).1 := pr Φ`: the projection
>   `A s → (quotAlg …).1 s`, i.e. the canonical map to the quotient algebra.
>
> - `sortedEqvInf Φ Ψ : SortedEqv A`: sortwise the intersection of the two relations;
>   at sort `s`, `x ~ y` iff `(Φ s).r x y ∧ (Ψ s).r x y`. The setoid structure is
>   built componentwise (reflexivity, symmetry, transitivity both components). This
>   is the meet `Φ ⊓ Ψ` of sorted equivalences.
>
> - `sortedEqvLe Φ Ψ : Prop := ∀ s (x y : A s), (Φ s).r x y → (Ψ s).r x y`: the
>   relation `Φ` is contained in `Ψ` at every sort (order/refinement of equivalences;
>   `Φ` is finer than `Ψ`).
>
> ## `IsCongruenceFormation Sig (F : (A : SSet S) → Set (SortedEqv (Term Sig A))) : Prop`
>
> `F` assigns to each many-sorted carrier `A` a set `F A` of sorted equivalences on
> the term algebra `Term Sig A` (i.e. on `(termAlg Sig A).1`). The predicate is the
> conjunction of two clauses.
>
> **Clause 1: `∀ A : SSet S`,**
> - `(F A).Nonempty` — each `F A` is nonempty;
> - `∀ Φ ∈ F A, IsCongruence Sig (termAlg Sig A).2 Φ` — every member of `F A` is a
>   congruence of the term algebra for `A`;
> - `∀ Φ ∈ F A, ∀ Ψ ∈ F A, sortedEqvInf Φ Ψ ∈ F A` — `F A` is closed under binary
>   meet (componentwise intersection) of sorted equivalences;
> - `∀ Φ ∈ F A, ∀ Ψ : SortedEqv (Term Sig A), IsCongruence Sig (termAlg Sig A).2 Ψ →
>    sortedEqvLe Φ Ψ → Ψ ∈ F A` — `F A` is upward closed under `sortedEqvLe`, but only
>   among *congruences* `Ψ`: if `Ψ` is a congruence and refines `Φ` (in the sense
>   `Φ ≤ Ψ`, `Φ` contained in `Ψ`), then `Ψ ∈ F A`.
>
> **Clause 2 (inverse-image / kernel closure):** for all
> `(A B : SSet S) (Θ : SortedEqv (Term Sig B)) (hΘ : IsCongruence Sig (termAlg Sig B).2 Θ)`,
> if `Θ ∈ F B`, then for **every** `f : SortedMap (Term Sig A) (Term Sig B)` that is
> an algebra homomorphism (`IsAlgHom Sig (termAlg Sig A).2 (termAlg Sig B).2 f`) and
> such that for **every** sort `s` the composite map
> `fun x => prAlg Sig (termAlg Sig B).2 Θ hΘ s (f s x)` is surjective onto the
> quotient `(quotAlg … Θ …).1 s`, the sorted equivalence
> `ker (fun s => prAlg Sig (termAlg Sig B).2 Θ hΘ s ∘ f s)` belongs to `F A`.
>
> In words, with `h := prAlg … Θ …` the projection of the `B`-term algebra onto its
> `Θ`-quotient, clause 2 says: whenever `f` is a homomorphism of term algebras whose
> composite `h ∘ f` is surjective at every sort, then the kernel of `h ∘ f` (a
> sorted equivalence on `Term Sig A`, hence a candidate member of `F A`) is in `F A`.
> The surjectivity hypothesis is stated sortwise via `Function.Surjective`.
>
> ## Summary
>
> The file fixes: sorted signatures, sorted term algebras, homomorphisms,
> congruences, sorted-equivalence kernel/quotient constructions, the meet and the
> inclusion order on sorted equivalences, and the predicate that a sort-indexed
> family of sets of congruences on term algebras is a "congruence formation"
> (nonempty, contains only congruences, closed under meet, upward closed among
> congruences, and closed under pulling back congruences along surjective-on-quotient
> term homomorphisms).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D030 clause-by-clause
>
> Contract: a formation of congruences w.r.t. Σ is `𝔉 : U^S → ...` such that
> 1. for every carrier `A`, `𝔉(A)` is a filter of the algebraic lattice
>    `Cgr(T_Σ(A))`: nonempty, `⊆ Cgr`, closed under binary intersection, and upward
>    closed (`Φ ∈ 𝔉(A)`, `Ψ ∈ Cgr(T_Σ(A))`, `Φ ⊆ Ψ ⟹ Ψ ∈ 𝔉(A)`);
> 2. for all `A,B`, `Θ ∈ 𝔉(B)`, and every Θ-epimorphism `f : T_Σ(A) → T_Σ(B)`,
>    `Ker(pr^Θ ∘ f) ∈ 𝔉(A)`.
>
> - Clause 1 nonempty ↔ Lean `(F A).Nonempty`. Match.
> - Clause 1 `⊆ Cgr` ↔ Lean `∀ Φ ∈ F A, IsCongruence Sig (termAlg Sig A).2 Φ`. Match.
> - Clause 1 meet-closure ↔ Lean `∀ Φ Ψ ∈ F A, sortedEqvInf Φ Ψ ∈ F A` (the
>   sortwise/componentwise intersection `Φ ⊓ Ψ`). Match.
> - Clause 1 upward closure ↔ Lean `∀ Φ ∈ F A, ∀ Ψ : SortedEqv …,
>   IsCongruence … Ψ → sortedEqvLe Φ Ψ → Ψ ∈ F A`; `sortedEqvLe Φ Ψ` is exactly
>   `Φ ⊆ Ψ` and the `IsCongruence` side condition is exactly the `Ψ ∈ Cgr`
>   restriction. Match.
> - Clause 2 ↔ Lean: for all `A B`, `Θ` with `hΘ : IsCongruence … Θ` and `Θ ∈ F B`,
>   every `f : SortedMap (Term Sig A) (Term Sig B)` that is an algebra homomorphism
>   and whose composite `pr^Θ ∘ f` is surjective sortwise has
>   `ker (pr^Θ ∘ f) ∈ F A`. The Θ-epimorphism notion (homomorphism with
>   `pr^Θ ∘ f` surjective) and the pulled-back kernel are both represented. The
>   explicit `hΘ` is redundant given clause 1, so it neither adds nor removes
>   content.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — both defining clauses (filter-valued in `Cgr(T_Σ(A))` with upward closure inside `Cgr`, and inverse-image kernel closure along Θ-epimorphisms) are represented with matching hypotheses.

