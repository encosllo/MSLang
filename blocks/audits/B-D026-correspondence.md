# Correspondence audit transcript -- `B-D026`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.SigElem`, `Mslang.XElem`, `Mslang.RowAlpha`, `Mslang.WSet`, `Mslang.WAlg` (`lean/Mslang/Free.lean`)
- **Contract:** Definition `B-D026`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000350`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D026 — word (syntactic) algebra on an alphabet
>
> Ambient data: sort set `S : Type u`. `SSet S := S → Type u`; `Signature S :=
> List S × S → Type u`; `Alg Sig` is the bundled algebra (carrier `A.1`, structure
> `A.2`). An `AlgStruct Sig A` for `A : SSet S` is
> `(p : List S × S) → Sig p → finOp A p.1 p.2`, where an operation of arity
> `p = (w, s)` consumes a `wordProd A w` (a tuple indexed by `Fin w.length`) and
> returns an `A s`.
>
> ## Definitions
>
> - `SigElem Sig := Σ p : List S × S, Sig p`. The type of *operation symbols* paired
>   with their arities: an element is a dependent pair `⟨p, σ⟩` with `p : List S × S`
>   and `σ : Sig p`.
> - `XElem X := Σ s : S, X s` (for `X : SSet S`). The type of *variables sorted by
>   sort*: an element is a dependent pair `⟨s, x⟩` with `x : X s`. Note this needs
>   `X` to be used where a sorted set is expected; in `WAlg`/`RowAlpha` it is used
>   with the variable-set argument.
> - `RowAlpha Sig X := SigElem Sig ⊕ XElem X`. The alphabet: each letter is either an
>   operation symbol (with its arity) or a variable (with its sort).
> - `WSet Sig X : SSet S := fun _ => List (RowAlpha Sig X)`. The carrier at *every*
>   sort is the type of finite lists ("words") of alphabet letters. The sort index is
>   ignored, so all sorts share the same word type.
> - `WAlg Sig X : Alg Sig :=
>   ⟨WSet Sig X, fun p σ a => Sum.inl (⟨p, σ⟩ : SigElem Sig) :: (List.ofFn a).flatten⟩`.
>   The *word algebra*. Its carriers are the word types `WSet Sig X s`. For an
>   operation of arity `p = (w, s)` and symbol `σ`, applied to a tuple
>   `a : (i : Fin w.length) → List (RowAlpha Sig X)`, the result is the word
>   `⟨p,σ⟩ :: (ofFn a).flatten`: first the letter `inl ⟨p, σ⟩` (the operation symbol),
>   then the concatenation of the words `a i` in the order given by `List.ofFn a`.
>
> So each sort's carrier is the set of finite rows over the alphabet, and operations
> build a new row by prefixing the operation symbol and concatenating the argument
> rows. This is the raw syntactic word algebra (its generated subalgebra is the term
> algebra, constructed in `B-D027`).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D026 verdict — word (row) algebra on an alphabet
>
> Clause-by-clause comparison of the contract (B-D026.tex) against the read-back.
>
> 1. "The underlying $S$-sorted set $\mathrm W_\Sigma(X)$ is constantly $(\coprod\Sigma \amalg \coprod X)^\star$." Lean `WSet Sig X := fun _ => List (RowAlpha Sig X)` with `RowAlpha Sig X := SigElem Sig ⊕ XElem X`, `SigElem Sig = Σ p, Sig p` ($=\coprod\Sigma$) and `XElem X = Σ s, X s` ($=\coprod X$). Constant over sorts. Covered.
> 2. "For $\sigma \in \Sigma_{w,s}$ the operation $F_\sigma$ sends $(P_i)_{i\in|w|}$ to $(\sigma)\curlywedge\concat_i P_i$, where $(\sigma)=(((\sigma,(w,s)),0))$." Lean `WAlg` operation `fun p σ a => Sum.inl (⟨p,σ⟩) :: (List.ofFn a).flatten`, i.e. prefix the operation letter `inl ⟨p,σ⟩` and concatenate the argument rows in order. Covered.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the constant word carrier over $\coprod\Sigma\amalg\coprod X$ and the prefix-and-concatenate row operations match the contract exactly.

