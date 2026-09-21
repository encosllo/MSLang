# Correspondence audit transcript -- `B-D043`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsFiniteAlgebraFormation`, `Mslang.finiteAlgebraFormations` (`lean/Mslang/Regular.lean`)
- **Contract:** Definition `B-D043`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000367`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

> **Standing assumption.** This block lies after manuscript Assumption `B-A001`
> ("in the remainder of this section we require `S` to be finite"), which is part
> of the contract; a Lean `[Finite S]` hypothesis is faithful, not a weakening.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D043 — read-back
>
> Fixed data: sorts `S`; `SSet S := S → Type u`; `Signature S := (List S × S) → Type u`.
> `Alg Sig` is a bundled algebra (carrier `.1 : SSet S`, operations
> `.2 : AlgStruct Sig A`); it is not defined in this file.
>
> ## Basic definitions
>
> - `wordProd A w := (i : Fin w.length) → A (w.get i)`; `finOp A w s := wordProd A w → A s`;
>   `AlgStruct Sig A := (p) → Sig p → finOp A p.1 p.2`.
> - `SortedMap A B := ∀ s, A s → B s`.
> - `FiniteSSet A := Finite (Sigma A)`; `FiniteAlg X := FiniteSSet X.1`;
>   `algebraFinite Sig := {A | FiniteAlg A}` (the finite algebras).
> - `iAlg Sig A`, for an index family `A : ι → Alg Sig`: the **direct product**
>   algebra with carrier `fun s => ∀ i, (A i).1 s` (sortwise dependent product,
>   complete product over all `ι`), and operations `(p, σ, b) ↦ fun i => (A i).2 p σ (fun j => b j i)`
>   (apply componentwise). Noncomputable only because of bundling.
>
> ## Homomorphisms
>
> - `IsAlgHom Sig FA FB f`, for `FA : AlgStruct Sig A`, `FB : AlgStruct Sig B`,
>   `f : SortedMap A B`: for every arity `p = (w, s)`, symbol `σ : Sig p`, and
>   tuple `a : wordProd A p.1`,
>   `f p.2 (FA p σ a) = FB p σ (fun i => f (p.1.get i) (a i))`.
>   So `f` preserves every operation (sortwise function family respecting the
>   algebra structure).
> - `IsEpiAlg Sig FA FB f := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Surjective (f s)`:
>   a surjective homomorphism (an epimorphism in the algebraic sense; surjective at
>   every sort).
> - `IsMonoAlg Sig FA FB f := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Injective (f s)`:
>   an injective homomorphism.
>
> ## Operators
>
> - `HOperator Sig F`, for `F : Set (Alg Sig)`: the set of algebras `A` such that
>   there exist `B ∈ F` and `f : SortedMap B.1 A.1` with
>   `IsEpiAlg Sig B.2 A.2 f`. I.e. all homomorphic (surjective) images of members
>   of `F`. (`H` = homomorphic images.)
> - `IsSubdirectEmbedding Sig FA Ai f`, for `FA : AlgStruct Sig A`,
>   an index family `Ai : ι → Alg Sig` (with `iAlg Sig Ai` their product), and
>   `f : SortedMap A (iAlg Sig Ai).1`: `f` is a mono homomorphism
>   (`IsMonoAlg Sig FA (iAlg Sig Ai).2 f`) and for every coordinate `i : ι` and sort
>   `s`, the projection `a ↦ f s a i` from `A s` to `(Ai i).1 s` is surjective.
>   I.e. `A` embeds into the product and projects onto each factor (a subdirect
>   representation).
> - `PFsdOperator Sig F`: the set of algebras `A` such that there exist a type `ι`
>   with `Fintype ι` (finite index type), a family `C : ι → Alg Sig` with each
>   `C i ∈ F`, and an embedding `f : SortedMap A.1 (iAlg Sig C).1` that is a
>   subdirect embedding. I.e. algebras that are **subdirect products of finitely
>   many members of `F`** (up to subdirect representation).
> - `IsAlgebraFormation Sig F := HOperator Sig F ⊆ F ∧ PFsdOperator Sig F ⊆ F`:
>   `F` is an algebra formation (a class closed under homomorphic images and under
>   finite subdirect products).
> - `IsFiniteAlgebraFormation Sig F := IsAlgebraFormation Sig F ∧ F ⊆ algebraFinite Sig`:
>   a formation consisting only of finite algebras.
> - `finiteAlgebraFormations Sig := {F | IsFiniteAlgebraFormation Sig F}`: the set
>   of all such finite algebra formations (a set of classes of algebras).
>
> ## Theorems
>
> None (definitions only).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D043 — verdict
>
> Contract: `F` a formation of Σ-algebras (DefFormAlg); `F` is a formation of
> finite Σ-algebras if `F ⊆ Alg_f(Σ)`; `Form_{Alg_f}(Σ)` the set of all such
> formations.
>
> ## Clause-by-clause
>
> - "formation of Σ-algebras ... as in DefFormAlg" — Lean:
>   `IsAlgebraFormation Sig F := HOperator Sig F ⊆ F ∧ PFsdOperator Sig F ⊆ F`
>   (closure under homomorphic images, defined via `IsEpiAlg`, and under subdirect
>   products of finitely many members, via `IsSubdirectEmbedding`/`Fintype ι`).
>   Present.
> - "F ⊆ Alg_f(Σ)" — Lean:
>   `IsFiniteAlgebraFormation Sig F := IsAlgebraFormation Sig F ∧ F ⊆ algebraFinite Sig`.
>   Present.
> - "Form_{Alg_f}(Σ)" — Lean:
>   `finiteAlgebraFormations Sig := {F | IsFiniteAlgebraFormation Sig F}`. Present.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the imported DefFormAlg conditions (`H`, finite `P_sd`
> closure) are formalized and the new finiteness clause and named set are present.

