# Correspondence audit transcript -- `B-D036`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.TlGen`, `Mslang.Tl` (`lean/Mslang/Translation.lean`)
- **Contract:** Definition `B-D036`, section "Elementary translations and translations.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000360`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D036 — read-back
>
> ## Ambient setup (abbreviations in the file)
>
> - `SSet S := S → Type u`.
> - `Signature S := List S × S → Type u`.
> - `Sub A := ∀ s, Set (A s)` for `A : SSet S`.
> - `Alg Sig` is used but not defined here. Its carrier is `A.1 : SSet S`; `A.2`
>   interprets symbols: `A.2 (w, s) σ` takes one element of `A.1 (w.get k)` for each
>   `k : Fin w.length` and returns an element of `A.1 s`.
>
> ## Definitions
>
> ### `IsElemTranslation (Sig) (A) (t s : S) (T : A.1 t → A.1 s) : Prop`
>
> `T` is an *elementary translation* from `t` to `s` iff there exist a word
> `w : List S`, an index `i : Fin w.length` with `hwit : w.get i = t`, a symbol
> `σ : Sig (w, s)`, and other-slot fillers `a k h : A.1 (w.get k)` for all
> `k ≠ i`, such that **for all** `x : A.1 t`,
>
> ```
> T x = A.2 (w, s) σ (fun k =>
>         if h : k = i then (cast along w.get i = t, reversed) x
>         else a k h)
> ```
>
> The existentials are outermost and the universal `∀ x` is inside them: one fixed
> `(w, i, hwit, σ, a)` works for every input. Thus `T` is `σ` specialized with `x`
> in the `i`-th slot (transported across `w.get i = t`) and fixed elements elsewhere.
>
> ### `TlGen (Sig) (A) : (t s : S) → (A.1 t → A.1 s) → Prop` (inductive)
>
> The *translation closure*: the smallest indexed family of maps (`T : A.1 t → A.1 s`
> for each `t, s`) closed under:
>
> - `refl (t) : TlGen Sig A t t id` — the identity map at each sort is a translation.
> - `elem {T} : IsElemTranslation Sig A t s T → TlGen Sig A t s T` — every
>   elementary translation is a translation.
> - `comp {T : A.1 t → A.1 u} {U : A.1 u → A.1 s} :
>     TlGen Sig A t u T → TlGen Sig A u s U → TlGen Sig A t s (U ∘ T)` — translations
>   are closed under composition (`U ∘ T`, i.e. apply `T` first, then `U`).
>
> ### `Tl (Sig) (A) (t : S) : Sub (fun s => A.1 t → A.1 s)`
>
> ```
> Tl Sig A t s T  :=  TlGen Sig A t s T
> ```
>
> The subobject whose value at `s` is the set of translations `A.1 t → A.1 s`.
>
> ## Theorems / lemmas
>
> None. The file contains the induction family `TlGen` (constructors `refl`, `elem`,
> `comp`), the definitions `IsElemTranslation` and `Tl`, and abbrevs. No proposition
> is asserted or proved.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D036 verdict
>
> Contract: `Tl_t(A)_s` holds of `T` iff there is `n ∈ ℕ-1` (i.e. `n ≥ 1`), a word
> `(s_j)_{j∈n+1}`, and `(T_j)_{j∈n}` with `s_0 = t`, `s_n = s`,
> `T_0 ∈ Etl_t(A)_{s_1}`, …, `T_{n-1} ∈ Etl_{s_{n-1}}(A)_s`, and
> `T = T_{n-1} ∘ … ∘ T_0`; and `id_{A_t}` is viewed as an element of `Tl_t(A)_t`.
>
> - finite chain `(s_j)`, `(T_j)` of elementary translations with matching endpoints
>   ↔ `elem` + `comp` constructors: each `elem` is one ETL, `comp` concatenates.
>   Match.
> - composite `T = T_{n-1} ∘ … ∘ T_0` ↔ `comp` yields `U ∘ T` (apply `T` then `U`).
>   Match.
> - `id_{A_t} ∈ Tl_t(A)_t` ↔ `refl (t) : TlGen Sig A t t id`. Match.
> - `n ≥ 1` plus standalone identity ↔ least family closed under `refl`, `elem`,
>   `comp` (equivalently the reflexive–transitive closure of `Etl`); the generated
>   sets of maps coincide.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the inductive closure `refl`/`elem`/`comp` characterizes
> exactly the finite elementary-translation composites plus identities prescribed by
> the contract.

