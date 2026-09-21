# Correspondence audit transcript -- `B-D032`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsAlgebraFormation`, `Mslang.algebraFormations` (`lean/Mslang/Formation.lean`)
- **Contract:** Definition `B-D032`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000356`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D032 read-back
>
> Fixed ambient data: sort set `S : Type u`, signature `Sig : Signature S`, and a
> bundled algebra type `Alg Sig` (used but not defined here).
>
> ## `IsAlgebraFormation Sig (F : Set (Alg Sig)) : Prop`
>
> `IsAlgebraFormation Sig F := HOperator Sig F ⊆ F ∧ PFsdOperator Sig F ⊆ F`.
>
> So a class `F` of `Sig`-algebras is an *algebra formation* iff:
> - it is closed under homomorphic images (`HOperator Sig F ⊆ F`), and
> - it is closed under finite subdirect products (`PFsdOperator Sig F ⊆ F`).
>
> Both inclusions are as sets of algebras.
>
> ## `algebraFormations Sig : Set (Set (Alg Sig))`
>
> `algebraFormations Sig := {F | IsAlgebraFormation Sig F}`: the set of all algebra
> formations over `Sig`, i.e. all classes of `Sig`-algebras satisfying the two
> closure conditions above.
>
> ## Supporting definitions (identical in content to B-D031)
>
> - `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`.
> - `IsAlgHom Sig FA FB f : Prop :=
>    ∀ (p) (σ : Sig p) (a : wordProd A p.1),
>      f p.2 (FA p σ a) = FB p σ (fun i => f (p.1.get i) (a i))`.
> - `IsEpiAlg Sig FA FB f := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Surjective (f s)`.
> - `IsMonoAlg Sig FA FB f := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Injective (f s)`.
> - `IsSubdirectEmbedding Sig FA Ai f :=
>    IsMonoAlg Sig FA (iAlg Sig Ai).2 f ∧
>      ∀ i : ι, ∀ s : S, Function.Surjective (fun a : A s => f s a i)`.
> - `HOperator Sig F := {A | ∃ B ∈ F, ∃ f : SortedMap B.1 A.1, IsEpiAlg Sig B.2 A.2 f}`.
> - `PFsdOperator Sig F :=
>    {A | ∃ (ι : Type u) (_ : Fintype ι) (C : ι → Alg Sig), (∀ i, C i ∈ F) ∧
>          ∃ f : SortedMap A.1 (iAlg Sig C).1, IsSubdirectEmbedding Sig A.2 C f}`.
> - `SSet S := S → Type u`; `Signature S := List S × S → Type u`;
>   `SortedMap A B := ∀ s, A s → B s`;
>   `finOp A w s := wordProd A w → A s`;
>   `wordProd A w := (i : Fin w.length) → A (w.get i)`.
> - `iAlg Sig A : Alg Sig :=
>    ⟨fun s => ∀ i, (A i).1 s,
>     fun p σ b => fun i => (A i).2 p σ (fun j => b j i)⟩` (coordinatewise product).
>
> ## Summary
>
> The file defines the predicate `IsAlgebraFormation` (closure under `HOperator` and
> `PFsdOperator`) and the set `algebraFormations` of all such classes, together with
> its supporting algebra/homomorphism/operator definitions. There are no theorems.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D032 clause-by-clause
>
> Contract: a formation of Σ-algebras is a set `𝓕` of Σ-algebras with
> 1. `H(𝓕) ⊆ 𝓕` (closure under homomorphic images);
> 2. `P_fsd(𝓕) ⊆ 𝓕` (closure under finite subdirect products), stated as: if
>    for some `n ∈ ℕ` and family `(C^α)_{α∈n} ∈ 𝓕^n`,
>    `Em_sd(A, ∏ C^α) ≠ ∅`, then `A ∈ 𝓕`.
> Then `Form_Alg(Σ)` is the set of all such formations.
>
> - Clause 1 ↔ Lean `HOperator Sig F ⊆ F`, with `HOperator` per B-D031. Match.
> - Clause 2 ↔ Lean `PFsdOperator Sig F ⊆ F`, with `PFsdOperator` per B-D031
>   (finite `Fintype`-indexed family in `F`, subdirect embedding into the product).
>   Match.
> - `Form_Alg(Σ)` ↔ Lean `algebraFormations Sig := {F | IsAlgebraFormation Sig F}`
>   with `IsAlgebraFormation Sig F := HOperator Sig F ⊆ F ∧ PFsdOperator Sig F ⊆ F`.
>   Match.
> - The nonemptiness and abstractness conditions in the contract appear only as
>   commented-out (`%`) lines, so they are not active clauses and their absence in
>   Lean is not a weakening.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the two active closure conditions (under `H` and under `P_fsd`) and the set of all algebra formations are represented exactly; the commented contract clauses are not part of the definition.

