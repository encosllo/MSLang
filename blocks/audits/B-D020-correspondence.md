# Correspondence audit transcript -- `B-D020`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsSubalgebra` (`lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D020`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000345`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D020 read-back
>
> Fix `S : Type u`.
>
> - `Signature (S)` — abbreviation `List S × S → Type u`; operation symbols `Sig (w, s)` with input sort-list `w` and result sort `s`.
> - `SSet (S) : Type (u+1)` — abbreviation `S → Type u`.
> - `Sub {S} (A : SSet S) : Type u` — abbreviation `∀ s, Set (A s)` (sortwise subset).
> - `wordProd {S} (A : SSet S) (w : List S) : Type u` — definitionally `(i : Fin w.length) → A (w.get i)`; the product of the carriers along the sort-list `w`.
> - `finOp {S} (A : SSet S) (w : List S) (s : S) : Type u` — definitionally `wordProd A w → A s`; an operation with input sort-list `w` and output sort `s`.
> - `AlgStruct {S} (Sig) (A : SSet S)` — definitionally `(p : List S × S) → Sig p → finOp A p.1 p.2`; an algebra structure on `A`.
>
> - `IsSubalgebra {S} (Sig) {A} (F : AlgStruct Sig A) (X : Sub A) : Prop` — definitionally
>   `∀ (p : List S × S) (σ : Sig p) (a : wordProd A p.1), (∀ i, a i ∈ X (p.1.get i)) → F p σ a ∈ X p.2`.
>   `X` is a **subalgebra** of the algebra `(A, F)` iff `X` is closed under every operation: for every arity `p = (w, s)`, every operation symbol `σ : Sig p`, and every argument tuple `a` *all of whose components lie in `X`* — i.e. `a i ∈ X (p.1.get i)` for every position `i : Fin w.length` — the result `F p σ a` lies in `X s` (i.e. `X p.2`). Quantifier scope: `∀ p, ∀ σ, ∀ a`, with the componentwise-membership condition as hypothesis.
>
> No theorems. Closure is required for all operation symbols of the signature, with the membership premise checked at each argument position.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D020 verdict
>
> Contract: for `σ : w → s`, `X` is closed under `F_σ : A_w → A_s` if for every `a ∈ X_w`, `F_σ(a) ∈ X_s`; `X` is a subalgebra of `A` if closed under all operations; `Sub(A)` = set of subalgebras (an algebraic closure system), with `Sub(A)` its algebraic lattice; equivalently a `Σ`-algebra `B` is a subalgebra of `A` if `B ⊆ A` and the canonical embedding determines an embedding.
>
> - Clause "closed under `F_σ`: `a ∈ X_w ⇒ F_σ(a) ∈ X_s`": Lean `IsSubalgebra F X := ∀ p σ a, (∀ i, a i ∈ X (p.1.get i)) → F p σ a ∈ X p.2`, where the premise is precisely `a ∈ X_w` (componentwise `X_{w_i}`). ✓
> - Clause "`X` is a subalgebra iff closed under the operations": captured by the same predicate. ✓
> - Clause "`Sub(A)` = set of subalgebras (algebraic closure system)": not defined here; it is a property assertion (that the set of subalgebras forms an algebraic closure system) rather than the defining predicate, and `IsClosureSystem` is available in the same development. Not part of the closure predicate.
> - Clause "equivalent characterization via the canonical embedding": not formalized here; the contract presents it as an alternative statement, not the defining condition.
>
> Contract clauses with no Lean counterpart: none for the defining content (closure under operations / subalgebra predicate); the parenthetical "algebraic closure system" and the "equivalently" embedding characterization are auxiliary assertions not present but not defining.
> Verdict: equivalent — the defining closure/subalgebra condition is fully and correctly represented, including the componentwise membership premise over all operation symbols.

