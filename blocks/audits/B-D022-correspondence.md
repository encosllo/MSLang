# Correspondence audit transcript -- `B-D022`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.iAlg`, `Mslang.iProjAlg`, `Mslang.isAlgHom_iProjAlg`, `Mslang.iPairAlg`, `Mslang.isAlgHom_iPairAlg`, `Mslang.iProjAlg_iPairAlg`, `Mslang.iPairAlg_unique` (`lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D022`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000347`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D022 — product (indexed) algebra and its universal property
>
> Ambient data: sort set `S : Type u`. `SSet S := S → Type u`. `Signature S :=
> List S × S → Type u`. For a sorted set `A`, `wordProd A w := (i : Fin w.length) →
> A (w.get i)` and `finOp A w s := wordProd A w → A s`, and `AlgStruct Sig A :=
> (p : List S × S) → Sig p → finOp A p.1 p.2`. `SortedMap A B := ∀ s, A s → B s`.
> It is used here that `Alg Sig` is a bundled algebra: `A : Alg Sig` has carrier
> `A.1 : SSet S` and structure `A.2 : AlgStruct Sig A.1`. An algebra homomorphism
> `IsAlgHom Sig FA FB f` (for `f : SortedMap A B`) means: for every `p = (w, s)`,
> `σ : Sig p`, `a : wordProd A w`,
> `f s (FA p σ a) = FB p σ (fun i => f (w.get i) (a i))`.
>
> ## Definitions
>
> - `iAlg Sig {ι} (A : ι → Alg Sig) : Alg Sig`. The product of the family `A`. Its
>   carrier at sort `s` is `∀ i, (A i).1 s` (a dependent function choosing an element
>   of each factor at sort `s`). Its operations are defined pointwise: for `p = (w,s)`,
>   `σ : Sig p`, and a tuple `b` whose `i`-th slot is a tuple of product elements, the
>   result is `fun i => (A i).2 p σ (fun j => b j i)`, i.e. apply the `i`-th factor's
>   operation componentwise. `noncomputable` (only because it is part of a development
>   using quotient constructions elsewhere; the body itself is constructive).
> - `iProjAlg Sig A i : SortedMap (iAlg Sig A).1 (A i).1` is the `i`-th projection,
>   `fun _ a => a i` (independent of the sort).
>
> ## Theorems
>
> - `isAlgHom_iProjAlg Sig A i : IsAlgHom Sig (iAlg Sig A).2 (A i).2 (iProjAlg Sig A i)`.
>   Each projection from the product algebra to the `i`-th factor is an algebra
>   homomorphism. Proof is `rfl` (the operations were defined pointwise).
> - `iPairAlg Sig {B} (A : ι → Alg Sig) (f : ∀ i, SortedMap B (A i).1) :
>   SortedMap B (iAlg Sig A).1`. The tupling map `fun s b i => f i s b`, sending an
>   element of `B` to the family of its images under all `f i`.
> - `isAlgHom_iPairAlg Sig {B} (FB : AlgStruct Sig B) {A} (f : ∀ i, SortedMap B
>   (A i).1) (hf : ∀ i, IsAlgHom Sig FB (A i).2 (f i)) :
>   IsAlgHom Sig FB (iAlg Sig A).2 (iPairAlg Sig A f)`. Hypothesis: each `f i` is an
>   algebra homomorphism from `(B, FB)`. Conclusion: the tupling map is an algebra
>   homomorphism into the product. Proof: pointwise in `i`, reduce to `hf i`.
> - `iProjAlg_iPairAlg Sig {B} A f i : (fun s => (iProjAlg Sig A i s) ∘ (iPairAlg
>   Sig A f s)) = f i`. The composite of the tupling with the `i`-th projection equals
>   `f i` (as a `SortedMap B (A i).1`, equality by function extensionality in sort and
>   element).
> - `iPairAlg_unique Sig {B} (A : ι → Alg Sig) (f : ∀ i, SortedMap B (A i).1)
>   (p : SortedMap B (iAlg Sig A).1)
>   (hp : ∀ i, (fun s => (iProjAlg Sig A i s) ∘ (p s)) = f i) : p = iPairAlg Sig A f`.
>   If any map `p` into the product has all its projections equal to the prescribed
>   `f i`, then `p` is exactly the tupling map. Proof by extensionality over sort,
>   element and index `i`, using `hp i`.
>
> Mathematically: `iAlg` is the product of the algebras `A i`, the `iProjAlg` are the
> projections (homomorphisms), and `iPairAlg` together with `isAlgHom_iPairAlg`,
> `iProjAlg_iPairAlg` and `iPairAlg_unique` establishes the universal property: for any
> algebra `(B, FB)` and homomorphisms `f i : B → A i`, there is a unique homomorphism
> into the product whose composites with the projections are the `f i`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D022 verdict — product algebra and its universal property
>
> Clause-by-clause comparison of the contract (B-D022.tex) against the read-back.
>
> 1. "The product $\prod_{i\in I}\mathbf A^i = (\prod_i A^i, F)$ with $F_\sigma((a_\alpha)_{\alpha})= (F^i_\sigma((a_\alpha(i))_\alpha))_i$." Lean `iAlg`: carrier `∀ i, (A i).1 s`, operations `fun p σ b i => (A i).2 p σ (fun j => b j i)`. Covered.
> 2. "$i$-th canonical projection $\mathrm{pr}^i$ is the homomorphism sending $(a_i)_i$ to $a_i$." Lean `iProjAlg` (`fun _ a => a i`) plus `isAlgHom_iProjAlg`. Covered.
> 3. "For homomorphisms $f^i : \mathbf B \to \mathbf A^i$, there is a unique homomorphism $f : \mathbf B \to \prod_i \mathbf A^i$ with $\mathrm{pr}^i \circ f = f^i$."
>    - Existence: `iPairAlg` and `isAlgHom_iPairAlg` (given each `f i` is a hom).
>    - Defining property: `iProjAlg_iPairAlg` (composite with projection equals `f i`).
>    - Uniqueness: `iPairAlg_unique` (any map with the same projections equals the tupling).
>
> Everything in the contract is present, with the existence/uniqueness universal property fully formalized.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the product algebra, its projections as homomorphisms, and the existence/uniqueness universal property of the tupling map are all faithfully represented.

