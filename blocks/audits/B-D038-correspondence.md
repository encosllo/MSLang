# Correspondence audit transcript -- `B-D038`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.congCogenerated` (`lean/Mslang/Translation.lean`)
- **Contract:** Definition `B-D038`, section "Congruence cogenerated  by an $S$-sorted subset of the underlying $S$-sorted set of a $\Sigma$-algebra.".
- **Outcome:** `formal_stronger`
- **Recorded as:** `E-000362`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D038 — read-back
>
> ## Ambient setup (abbreviations in the file)
>
> - `SSet S := S → Type u`.
> - `Signature S := List S × S → Type u`.
> - `SortedEqv A := ∀ s, Setoid (A s)` for `A : SSet S`: an `S`-sorted family of
>   setoids, i.e. a family of equivalence relations `~_s` on each `A s`. A
>   `Setoid (A s)` is a bundled structure `⟨rel, refl, symm, trans⟩` where `rel` is
>   the underlying binary relation.
> - `Sub A := ∀ s, Set (A s)`.
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
> `σ : Sig (w, s)`, and fillers `a k h : A.1 (w.get k)` for all `k ≠ i`, such that
> **for all** `x : A.1 t`,
>
> ```
> T x = A.2 (w, s) σ (fun k =>
>         if h : k = i then (cast along w.get i = t, reversed) x
>         else a k h)
> ```
>
> Existentials outermost, `∀ x` innermost: one fixed tuple `(w, i, hwit, σ, a)` works
> for all inputs. `T` is `σ` with `x` placed in the `i`-th slot (transported across
> `w.get i = t`) and fixed elements elsewhere.
>
> ### `TlGen (Sig) (A) : (t s : S) → (A.1 t → A.1 s) → Prop` (inductive)
>
> The translation closure, smallest family of maps closed under:
>
> - `refl (t) : TlGen Sig A t t id`;
> - `elem {T} : IsElemTranslation Sig A t s T → TlGen Sig A t s T`;
> - `comp {T : A.1 t → A.1 u} {U : A.1 u → A.1 s} :
>     TlGen Sig A t u T → TlGen Sig A u s U → TlGen Sig A t s (U ∘ T)`.
>
> (`congCogenerated` below uses `TlGen`.)
>
> ### `congCogenerated (Sig) (A) (L : Sub A.1) : SortedEqv A.1`
>
> The *cogenerated* sorted equivalence relation on `A.1`, determined by the
> subobject `L`. At each sort `t` it is the `Setoid` whose underlying relation is
>
> ```
> x ~_t y  :⟺  ∀ (s : S) (T : A.1 t → A.1 s),
>                 TlGen Sig A t s T → (T x ∈ L s ↔ T y ∈ L s)
> ```
>
> Quantifier scope: for each `t`, `x ~_t y` means that for *all* sorts `s` and *all*
> maps `T : A.1 t → A.1 s` that are translations (witnessed by `TlGen`), membership
> of `T x` in the `s`-component `L s` is equivalent to membership of `T y` in `L s`.
> Equivalently, `x` and `y` are indistinguishable by every translation of `L`.
>
> The bundled equivalence proof is:
>
> - reflexivity: for all `x`, every `s`, `T`, `hT`, the two sides are identical, so
>   `Iff.rfl`;
> - symmetry: from `h : ∀ s T hT, (T x ∈ L s ↔ T y ∈ L s)` produce the reversed
>   implication pointwise via `(h s T hT).symm`;
> - transitivity: from `h1 : x ~ y` and `h2 : y ~ z`, for each `s, T, hT` compose
>   `(h1 s T hT) : (T x ∈ L s ↔ T y ∈ L s)` with
>   `(h2 s T hT) : (T y ∈ L s ↔ T z ∈ L s)` using `Iff.trans`.
>
> ## Theorems / lemmas
>
> None. The file contains `congCogenerated`, `IsElemTranslation`, the inductive
> `TlGen`, and abbrevs. The three `Setoid` fields are constructed inline (no named
> lemma is asserted).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D038 verdict
>
> Contract: `Ω^A(L)` is the binary relation on `A` given, for each `t ∈ S`, by
> `Ω^A(L)_t = {(x,y) ∈ A_t² | ∀ s ∈ S ∀ T ∈ Tl_t(A)_s, (T(x) ∈ L_s ↔ T(y) ∈ L_s)}`.
>
> - underlying relation: `x ~_t y ⟺ ∀ s T, TlGen Sig A t s T → (T x ∈ L s ↔ T y ∈ L s)`
>   ↔ contract's pair-set condition. Match.
> - quantification `∀ s ∈ S`, `∀ T ∈ Tl_t(A)_s` ↔ `∀ (s) (T), TlGen … → …`. Match.
> - the membership biconditional `T(x) ∈ L_s ↔ T(y) ∈ L_s` ↔ same. Match.
> - the Lean object is bundled as a `SortedEqv` (`Setoid` per sort), i.e. it also
>   carries/proves reflexivity, symmetry and transitivity of the relation. The
>   contract states only the bare relation; these equivalence laws are extra.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: formal_stronger — the underlying relation matches exactly, but the Lean
> definition bundles it as a setoid and proves the equivalence laws, carrying content
> beyond the bare relation the contract defines.

