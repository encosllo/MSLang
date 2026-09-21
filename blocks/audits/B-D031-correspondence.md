# Correspondence audit transcript -- `B-D031`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.HOperator`, `Mslang.PFsdOperator` (`lean/Mslang/Formation.lean`)
- **Contract:** Definition `B-D031`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000355`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D031 read-back
>
> Fixed ambient data: a sort set `S : Type u` and a signature `Sig : Signature S`.
> `Alg Sig` is a bundled algebra (carrier `.1`, structure `.2`) and `Set (Alg Sig)`
> a class of algebras; `Alg Sig` is used but not defined here.
>
> ## Basic infrastructure
>
> - `SSet S := S → Type u`; `Signature S := List S × S → Type u`.
> - `SortedMap A B := ∀ s, A s → B s`.
> - `wordProd A w := (i : Fin w.length) → A (w.get i)`.
> - `finOp A w s := wordProd A w → A s`.
> - `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`.
>
> ## Homomorphism predicates
>
> - `IsAlgHom Sig FA FB f : Prop` asserts
>   `∀ (p) (σ : Sig p) (a : wordProd A p.1),
>      f p.2 (FA p σ a) = FB p σ (fun i => f (p.1.get i) (a i))`:
>   `f` commutes with every operation symbol.
> - `IsEpiAlg Sig FA FB f : Prop := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Surjective (f s)`.
>   A homomorphism that is surjective at every sort.
> - `IsMonoAlg Sig FA FB f : Prop := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Injective (f s)`.
>   A homomorphism that is injective at every sort.
>
> ## Product algebra
>
> - `iAlg Sig A : Alg Sig` for `A : ι → Alg Sig`, `noncomputable`:
>   carrier `fun s => ∀ i, (A i).1 s` (the sortwise product of the carriers), and
>   operations `fun p σ b => fun i => (A i).2 p σ (fun j => b j i)`, i.e. computed
>   coordinatewise. This is the direct product of the family `A`.
>
> ## `IsSubdirectEmbedding Sig {A} (FA : AlgStruct Sig A) {ι} (Ai : ι → Alg Sig)
>      (f : SortedMap A (iAlg Sig Ai).1) : Prop`
>
> It is the conjunction:
> - `IsMonoAlg Sig FA (iAlg Sig Ai).2 f` — `f` is an injective homomorphism
>   `A → ∏ᵢ Aᵢ`; and
> - `∀ i : ι, ∀ s : S, Function.Surjective (fun a : A s => f s a i)` — for every index
>   `i` and sort `s`, the composite of `f` with the `i`-th coordinate projection is
>   surjective.
>
> So `f` is an embedding of `A` into the product whose image projects onto each
> factor; the standard notion of a subdirect embedding (into a product over the index
> type `ι`).
>
> ## Operators on classes of algebras
>
> - `HOperator Sig (F : Set (Alg Sig)) : Set (Alg Sig) :=
>    {A | ∃ B ∈ F, ∃ f : SortedMap B.1 A.1, IsEpiAlg Sig B.2 A.2 f}`.
>   The class of all homomorphic images of members of `F`: `A` is included iff there
>   is `B ∈ F` and a surjective homomorphism `B → A`.
>
> - `PFsdOperator Sig (F : Set (Alg Sig)) : Set (Alg Sig) :=
>    {A | ∃ (ι : Type u) (_ : Fintype ι) (C : ι → Alg Sig),
>           (∀ i, C i ∈ F) ∧
>           ∃ f : SortedMap A.1 (iAlg Sig C).1,
>             IsSubdirectEmbedding Sig A.2 C f}`.
>   The class of subdirect products of *finitely many* members of `F`: `A` is
>   included iff there is a finite index type `ι` (`Fintype ι`), a family `C` of
>   algebras each in `F`, and a subdirect embedding of `A` into `∏ᵢ Cᵢ`.
>
> ## Summary
>
> The file fixes homomorphisms, epimorphisms and monomorphisms of sorted algebras,
> the direct product of a family of algebras, the notion of a subdirect embedding,
> and the two class operators `HOperator` (homomorphic images) and `PFsdOperator`
> (finite subdirect products). There are no theorems.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D031 clause-by-clause
>
> Contract: for a set `𝓕` of Σ-algebras,
> 1. `H(𝓕) = {A ∈ Alg(Σ) | ∃ B ∈ 𝓕 (Epi(B,A) ≠ ∅)}` (homomorphic images);
> 2. `P_fsd(𝓕)` = algebras `A` such that for some `n ∈ ℕ` and family
>    `(C^α)_{α∈n} ∈ 𝓕^n`, `Em_sd(A, ∏_{α∈n} C^α) ≠ ∅` (finite subdirect products).
>
> - Clause 1 ↔ Lean `HOperator Sig F := {A | ∃ B ∈ F, ∃ f : SortedMap B.1 A.1,
>   IsEpiAlg Sig B.2 A.2 f}`, where `IsEpiAlg` = homomorphism surjective at every
>   sort (epimorphism). Match.
> - Clause 2 ↔ Lean `PFsdOperator Sig F := {A | ∃ (ι : Type u) (_ : Fintype ι)
>   (C : ι → Alg Sig), (∀ i, C i ∈ F) ∧ ∃ f …, IsSubdirectEmbedding Sig A.2 C f}`.
>   A finite index type with a family in `F` and a subdirect embedding into the
>   product is exactly "some `n ∈ ℕ` and family in `𝓕^n` with
>   `Em_sd(A, ∏ C^α) ≠ ∅`". `IsSubdirectEmbedding` = injective homomorphism whose
>   coordinate projections onto each factor are surjective, i.e. a subdirect
>   embedding. Match.
> - `iAlg` (coordinatewise product) corresponds to `∏_{α∈n} C^α`. Match.
> - The operator domains (`F : Set (Alg Sig)`) match "set of Σ-algebras".
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — `HOperator` and `PFsdOperator` reproduce the two contract definitions (homomorphic images via epimorphisms, finite subdirect products via subdirect embeddings), with `Fintype`/finite-family indexing equivalent to `n ∈ ℕ`.

