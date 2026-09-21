# Correspondence audit transcript -- `B-D023`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.finalAlg`, `Mslang.IsAlgIso`, `Mslang.subAlg`, `Mslang.SubfinalAlg` (`lean/Mslang/Subfinal.lean`)
- **Contract:** Definition `B-D023`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000348`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D023 — terminal algebra, subalgebras, subfinality
>
> Ambient data: sort set `S : Type u`. `SSet S := S → Type u`; `Signature S :=
> List S × S → Type u`; `Sub A := ∀ s, Set (A s)`; `SortedMap A B := ∀ s, A s → B s`;
> `wordProd A w := (i : Fin w.length) → A (w.get i)`; `finOp A w s := wordProd A w → A s`;
> `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`.
> An algebra is bundled `Alg Sig` with carrier `A.1` and structure `A.2`.
> `IsAlgHom Sig FA FB f` for `f : SortedMap A B` means: for all `p = (w,s)`, `σ`,
> `a : wordProd A w`, `f s (FA p σ a) = FB p σ (fun i => f (w.get i) (a i))`.
> `IsSubalgebra Sig F X` means `X` is closed under all operations:
> `∀ p σ a, (∀ i, a i ∈ X (w.get i)) → F p σ a ∈ X s`.
>
> ## Definitions
>
> - `finalSorted (S) : SSet S := fun _ => PUnit.{u+1}` — the sorted set whose carrier
>   at every sort is a one-element type.
> - `finalAlg Sig : Alg Sig := ⟨finalSorted S, fun _ _ _ => PUnit.unit⟩` — the algebra
>   on `finalSorted` with the unique possible operations. (Up to iso this is the
>   terminal/one-element algebra for each sort.)
> - `IsAlgIso Sig FA FB f : Prop := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Bijective (f s)`
>   — `f` is an isomorphism iff it is a homomorphism and bijective on every sort.
> - `subAlg Sig {A} F (X : Sub A) (hX : IsSubalgebra Sig F X) : Alg Sig`. The
>   subalgebra carried by `X`, with carrier
>   `fun s => {a : A s // a ∈ X s}` and operations
>   `fun p σ b => ⟨F p σ (fun i => (b i).1), hX p σ (fun i => (b i).1) (fun i => (b i).2)⟩`,
>   i.e. apply the ambient operation to the underlying elements and transport the proof
>   of membership using `hX`.
> - `SubfinalAlg Sig (X : Alg Sig) : Prop` — `X` is *subfinal* iff there exist:
>   a subfamily `Y : Sub (finalAlg Sig).1` of the terminal carrier,
>   a proof `hY : IsSubalgebra Sig (finalAlg Sig).2 Y`,
>   a map `f : SortedMap X.1 (subAlg Sig (finalAlg Sig).2 Y hY).1`, and
>   a proof `IsAlgIso Sig X.2 (subAlg Sig (finalAlg Sig).2 Y hY).2 f`.
>   So `X` is subfinal iff it is isomorphic (as an algebra) to a subalgebra of the
>   terminal algebra. Since each carrier of the terminal algebra is `PUnit`, such a
>   subalgebra has at most one element per sort; hence `X` is subfinal exactly when
>   every carrier of `X` has at most one element (i.e. all sorts are subsingletons),
>   presented here via an explicit subalgebra of `finalAlg` and an algebra isomorphism
>   onto it.
>
> ## Remarks
>
> No theorems are stated in this file; it contains only the definitions above. The
> quantifiers in `SubfinalAlg` are existential over `Y`, `hY`, `f` (with `hY` and `f`
> depending on the chosen `Y`), followed by the iso assertion.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D023 verdict — subfinal algebras
>
> Clause-by-clause comparison of the contract (B-D023.tex) against the read-back.
>
> 1. "A $\Sigma$-algebra $\mathbf A$ is subfinal if $\mathbf A$ is isomorphic to a subalgebra of $\mathbf 1$, the final $\Sigma$-algebra."
>    - `finalAlg` / `finalSorted` provide the final (one-element-per-sort) algebra.
>    - `SubfinalAlg Sig X := ∃ Y hY f, IsAlgIso Sig X.2 (subAlg Sig (finalAlg Sig).2 Y hY).2 f` states exactly that `X` is isomorphic to a subalgebra of the final algebra. Covered.
> 2. "We denote by $\mathrm{Sf}(\mathbf 1)$ the set of all subfinal $\Sigma$-algebras of $\mathbf 1$."
>    - Lean gives the predicate `SubfinalAlg`; the set $\mathrm{Sf}(\mathbf 1)$ is its extension `{X | SubfinalAlg Sig X}`, not a separately named object. Covered as the extension of the predicate (notation only).
>
> No theorem content is claimed by the contract, and none is missed.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — subfinality is formalized exactly as isomorphism onto a subalgebra of the final algebra, and $\mathrm{Sf}(\mathbf 1)$ is recovered as the extension of the `SubfinalAlg` predicate.

