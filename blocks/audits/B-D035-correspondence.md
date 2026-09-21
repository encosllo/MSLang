# Correspondence audit transcript -- `B-D035`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsElemTranslation`, `Mslang.Etl` (`lean/Mslang/Translation.lean`)
- **Contract:** Definition `B-D035`, section "Elementary translations and translations.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000359`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D035 — read-back
>
> ## Ambient setup (abbreviations in the file)
>
> - `SSet S := S → Type u`. An `S`-sorted family of types.
> - `Signature S := List S × S → Type u`. A signature maps a spine `(w, s)` (a list
>   `w : List S` of input sorts and an output sort `s : S`) to the type of operation
>   symbols with that arity and result.
> - `Sub A := ∀ s, Set (A s)` for `A : SSet S`. An `S`-sorted family of subsets
>   ("subobjects"), one subset of `A s` for each sort `s`.
> - `Alg Sig` is used but not defined in this file. It is the ambient structure of an
>   algebra for `Sig`; its carrier is `A.1 : SSet S`, and `A.2` interprets a symbol:
>   for `σ : Sig (w, s)` and a choice of one element of `A.1 (w.get k)` for each
>   `k : Fin w.length`, `A.2 (w, s) σ` returns an element of `A.1 s`.
>
> ## Definitions
>
> ### `IsElemTranslation (Sig) (A) (t s : S) (T : A.1 t → A.1 s) : Prop`
>
> `T` is an *elementary translation* from sort `t` to sort `s` iff there exist:
>
> - a word `w : List S`,
> - an index `i : Fin w.length` together with a proof `hwit : w.get i = t`,
> - a symbol `σ : Sig (w, s)`,
> - elements `a k h : A.1 (w.get k)` for every `k : Fin w.length` with `k ≠ i`
>   (the "other coordinates"),
>
> such that **for every** `x : A.1 t`,
>
> ```
> T x = A.2 (w, s) σ (fun k =>
>         if h : k = i then (cast along w.get i = t, reversed) x
>         else a k h)
> ```
>
> Quantifier scope: the existential block `∃ w, ∃ i, ∃ hwit, ∃ σ, ∃ a` is outermost,
> and the `∀ x : A.1 t` is inside all of them. So a *single* choice of `w, i, hwit,
> σ, a` must work uniformly for all inputs `x`.
>
> Meaning: `T` is the unary operation obtained by taking the `w`-ary symbol `σ`,
> plugging `x` into the `i`-th slot (`w.get i = t`, so this slot has the source sort
> `t`; the element `x : A.1 t` is transported across the equality to the slot's
> sort), and filling every other slot with the fixed elements `a k`. Thus `T` is a
> "one-variable specialization" of a basic operation.
>
> ### `Etl (Sig) (A) (t : S) : Sub (fun s => A.1 t → A.1 s)`
>
> The subobject assigning, to each sort `s`, the *set* of maps `A.1 t → A.1 s` that
> are elementary translations from `t` to `s`:
>
> ```
> Etl Sig A t s T  :=  IsElemTranslation Sig A t s T
> ```
>
> ## Theorems / lemmas
>
> None. The file contains only the definition `IsElemTranslation`, the derived
> definition `Etl`, and the abbrevs `SSet`, `Signature`, `Sub`. There are no asserted
> propositions.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D035 verdict
>
> Contract: for each `s`, `Etl_t(A)_s ⊆ (Hom(A_t,A_s))_s`; `T` is in it iff there is a
> word `w ∈ S* - {λ}`, an `i ∈ |w|`, a `σ ∈ Σ_{w,s}`, families `(a_j)_{j≤i-1}` and
> `(a_k)_{k≥i+1}`, with `w_i = t`, such that `T(x) = F_σ(a_0,…,a_{i-1},x,a_{i+1},…)`
> for every `x ∈ A_t`.
>
> - nonempty word, index `i ∈ |w|` ↔ `w : List S`, `i : Fin w.length` (nonempty is
>   implied by `Fin w.length`). Match.
> - `w_i = t` ↔ `hwit : w.get i = t`. Match.
> - `σ ∈ Σ_{w,s}` ↔ `σ : Sig (w, s)`. Match.
> - the two filler families ↔ `a k h : A.1 (w.get k)` for all `k ≠ i`. Match.
> - `∀ x ∈ A_t`, `T(x) = F_σ(…,x,…)` with `x` in slot `i` (transported across
>   `w_i = t`) ↔ single existential block outermost, `∀ x` inside. Match.
> - `T ∈ Hom(A_t,A_s)` ↔ `T : A.1 t → A.1 s`; contract's "mapping" makes `Hom` the
>   function space, so no restriction is dropped.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the existential/uniformity structure, the word/index/data
> families, and the defining equation coincide clause for clause.

