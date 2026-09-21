# Correspondence audit transcript -- `B-D028`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsMonoAlg`, `Mslang.IsEpiAlg`, `Mslang.IsSubdirectEmbedding`, `Mslang.IsSubdirectProduct`, `Mslang.IsomorphicSubdirectEmbeddings` (`lean/Mslang/Formation.lean`)
- **Contract:** Definition `B-D028`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000352`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D028 — monomorphisms, epimorphisms, subdirect embeddings and products
>
> Ambient data: sort set `S : Type u`. `SSet S := S → Type u`; `Signature S :=
> List S × S → Type u`; `SortedMap A B := ∀ s, A s → B s`; `wordProd A w :=
> (i : Fin w.length) → A (w.get i)`; `finOp A w s := wordProd A w → A s`;
> `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`; `Alg Sig` is the
> bundled algebra (carrier `A.1`, structure `A.2`).
> `IsAlgHom Sig FA FB f` for `f : SortedMap A B` means: for all `p = (w,s)`, `σ`,
> `a : wordProd A w`, `f s (FA p σ a) = FB p σ (fun i => f (w.get i) (a i))`.
>
> - `iAlg Sig {ι} (A : ι → Alg Sig) : Alg Sig`, the product algebra: carrier at sort
>   `s` is `∀ i, (A i).1 s`, operations pointwise,
>   `fun p σ b => fun i => (A i).2 p σ (fun j => b j i)`.
>
> ## Definitions
>
> - `IsAlgHom` (above); `IsAlgIso Sig FA FB f := IsAlgHom Sig FA FB f ∧
>   ∀ s, Function.Bijective (f s)`.
> - `IsMonoAlg Sig FA FB f : Prop := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Injective (f s)`
>   — `f` is an algebra monomorphism: a homomorphism that is injective on every sort.
> - `IsEpiAlg Sig FA FB f : Prop := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Surjective (f s)`
>   — `f` is an algebra epimorphism: a homomorphism that is surjective on every sort.
> - `IsSubdirectEmbedding Sig FA {ι} (Ai : ι → Alg Sig) (f : SortedMap A (iAlg Sig Ai).1)
>   : Prop := IsMonoAlg Sig FA (iAlg Sig Ai).2 f ∧
>     ∀ i : ι, ∀ s : S, Function.Surjective (fun a : A s => f s a i)`.
>   An embedding of `(A, FA)` into the product `∏ i, Ai i` that is a monomorphism and
>   whose composite with *each* projection `π i` is surjective (componentwise
>   surjectivity, not just surjectivity onto the product).
> - `IsSubdirectProduct Sig (A : Alg Sig) {ι} (Ai : ι → Alg Sig) : Prop :=
>   ∃ f : SortedMap A.1 (iAlg Sig Ai).1, IsSubdirectEmbedding Sig A.2 Ai f`.
>   `A` is a subdirect product of the family `Ai` iff there is a map `f` from the
>   carrier of `A` into the product that is a subdirect embedding. Note the `∃ f` binds
>   the embedding, and `A`'s structure is `A.2`.
> - `IsomorphicSubdirectEmbeddings Sig {A : SSet S} {ι} {Ai Bi : ι → Alg Sig}
>   (f : SortedMap A (iAlg Sig Ai).1) (g : SortedMap A (iAlg Sig Bi).1) : Prop :=
>   ∃ h : ∀ i, SortedMap (Ai i).1 (Bi i).1,
>     (∀ i, IsAlgIso Sig (Ai i).2 (Bi i).2 (h i)) ∧
>       ∀ (i : ι) (s : S) (a : A s), h i s (f s a i) = g s a i`.
>   Two families of subdirect embeddings of the same `A` into products `∏ Ai` and
>   `∏ Bi` are isomorphic iff there is a family of algebra isomorphisms `h i` between
>   the corresponding factors that intertwines the two embeddings coordinatewise:
>   for every `i`, `h i` is an algebra isomorphism `Ai i ≅ Bi i`, and for every sort
>   `s` and `a : A s`, the `i`-th coordinate of `f s a` maps under `h i` to the `i`-th
>   coordinate of `g s a`. The quantifier structure is `∃ h, (∀ i, Iso (h i)) ∧
>   (∀ i s a, …)`.
>
> ## Remarks
>
> The file contains definitions only; no theorems are proved. Mathematically this sets
> up the notions of monomorphism and epimorphism of algebras, subdirect embeddings and
> subdirect products (an injective homomorphism into a product whose coordinate
> projections are all surjective), and an isomorphism relation between two different
> subdirect-embedding presentations of the same algebra.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D028 verdict — mono/epi, subdirect embeddings and products
>
> Clause-by-clause comparison of the contract (B-D028.tex) against the read-back.
>
> 1. "$\mathbf A$ is a subdirect product of $(\mathbf A^i)_{i\in I}$ if (a) $\mathbf A$ is a subalgebra of $\prod_i \mathbf A^i$ and (b) for every $i$, $\mathrm{pr}^i\!\restriction\!\mathbf A$ is surjective."
>    - Lean `IsSubdirectProduct Sig A {ι} Ai := ∃ f, IsSubdirectEmbedding Sig A.2 Ai f`, where `IsSubdirectEmbedding` is `IsMonoAlg` (a homomorphism injective on every sort) plus componentwise surjectivity `∀ i s, Surjective (fun a => f s a i)`. A mono hom is exactly an embedding identifying `A` with a subalgebra of the product (a); the coordinate surjectivity is the restriction of `pr^i` being surjective (b). Covered.
> 2. "An embedding $f$ is subdirect if $f[\mathbf A]$ is a subdirect product; $\mathrm{Em_{sd}} = \{f\in\mathrm{Mon} \mid \forall i\, \mathrm{pr}^i\circ f \in \mathrm{Epi}\}$."
>    - `IsMonoAlg` matches `Mon`. The `Epi` condition `pr^i ∘ f` surjective (homomorphism-hood is automatic) is captured by the componentwise `Surjective` conjunct of `IsSubdirectEmbedding`. Covered.
> 3. "Two subdirect embeddings $f:\mathbf A\to\prod\mathbf A^i$ and $g:\mathbf A\to\prod\mathbf B^i$ are isomorphic iff there is $(h^i)\in\prod_i\mathrm{Iso}(\mathbf A^i,\mathbf B^i)$ with $h^i\circ\mathrm{pr}^{\mathbf A^i}\circ f = \mathrm{pr}^{\mathbf B^i}\circ g$."
>    - `IsomorphicSubdirectEmbeddings` gives `∃ h, (∀ i, IsAlgIso … (h i)) ∧ ∀ i s a, h i s (f s a i) = g s a i`, i.e. exactly $h^i(f(a)_i)=g(a)_i$ for all $i,s,a$. Covered.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — monomorphism/epimorphism, subdirect product and embedding, and isomorphism of subdirect embeddings (coordinatewise intertwining by a family of algebra isomorphisms) all match the contract.

