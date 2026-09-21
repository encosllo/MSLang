# Correspondence audit transcript -- `B-D017`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.wordProd`, `Mslang.finOp`, `Mslang.AlgStruct`, `Mslang.IsAlgHom` (`lean/Mslang/Algebra.lean`)
- **Contract:** Definition `B-D017`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000342`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D017 read-back
>
> Fix `S : Type u`.
>
> - `SSet (S) : Type (u+1)` — abbreviation `S → Type u`.
> - `Signature (S)` — abbreviation `List S × S → Type u`; operation symbols `Sig (w, s)` with input sort-list `w` and output sort `s`.
> - `SortedMap {S} (A B : SSet S)` — abbreviation `∀ s, A s → B s`.
>
> - `wordProd {S} (A : SSet S) (w : List S) : Type u` — definitionally `(i : Fin w.length) → A (w.get i)`. The **product type** of the argument sorts enumerated by `w`: a term is a dependent function assigning to each position `i` in `w` an element of the `i`-th sort's carrier `A (w.get i)`. Equivalently `A w₀ × A w₁ × ⋯`.
>
> - `finOp {S} (A : SSet S) (w : List S) (s : S) : Type u` — definitionally `wordProd A w → A s`. A finitary operation on `A` with input sort-list `w` and output sort `s`: a function from the argument product to `A s`.
>
> - `AlgStruct {S} (Sig : Signature S) (A : SSet S)` — definitionally `(p : List S × S) → Sig p → finOp A p.1 p.2`. An **algebra structure** on the sorted set `A` for signature `Sig`: for every arity `p = (w, s)` and every operation symbol `σ : Sig p`, an actual operation `wordProd A w → A s`.
>
> - `IsAlgHom {S} (Sig) {A B} (FA : AlgStruct Sig A) (FB : AlgStruct Sig B) (f : SortedMap A B) : Prop` — definitionally
>   `∀ (p : List S × S) (σ : Sig p) (a : wordProd A p.1), f p.2 (FA p σ a) = FB p σ (fun i => f (p.1.get i) (a i))`.
>   `f` is a **homomorphism** from `(A, FA)` to `(B, FB)` iff for every arity `p = (w, s)`, every operation symbol `σ : Sig p`, and every argument tuple `a : wordProd A w`:
>   applying the operation in `A` and then `f` at the output sort `s` equals applying the operation in `B` to the tuple of `f`-images of the arguments. I.e. `f` commutes with every operation, sortwise. Quantifier scope is: `∀ p, ∀ σ, ∀ a`.
>
> No theorems.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D017 verdict
>
> Contract: finitary operations `(Hom(A_w, A_s))_{(w,s)}` with `A_w = ∏_{i∈|w|} A_{w_i}`; a `Σ`-algebra structure `F = (F_{w,s})` with `F_{w,s} : Σ_{w,s} → Hom(A_w, A_s)`, written `F_σ`; a `Σ`-algebra `(A,F)`; a `Σ`-homomorphism `f : A → B` with `f_s(F_σ(a)) = G_σ(f_w(a))`, `f_w = ∏ f_{w_i}`; category `Alg(Σ)` and object set `Alg(Σ)`.
>
> - Clause "`A_w = ∏_{i∈|w|} A_{w_i}`": Lean `wordProd A w := (i : Fin w.length) → A (w.get i)`. ✓
> - Clause "`Hom(A_w,A_s)` (finitary operations)": Lean `finOp A w s := wordProd A w → A s`. ✓
> - Clause "structure `F_{w,s} : Σ_{w,s} → Hom(A_w,A_s)`": Lean `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`. ✓
> - Clause "homomorphism condition `f_s(F_σ(a)) = G_σ(f_w(a))`, `f_w = ∏ f_{w_i}`": Lean `IsAlgHom ... := ∀ p σ a, f p.2 (FA p σ a) = FB p σ (fun i => f (p.1.get i) (a i))`. ✓
> - Clause "the category `Alg(Σ)` and object set `Alg(Σ)`": not formalized here; this is representational packaging (objects via `AlgStruct`, morphisms via `IsAlgHom`), so the content is present even though the category/object-collection data are not.
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — all defining content (arity products, operations, algebra structure, homomorphism equation) matches; the only omission is the category packaging of the same data.

