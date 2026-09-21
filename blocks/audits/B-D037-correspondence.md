# Correspondence audit transcript -- `B-D037`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.deltaSub`, `Mslang.transImage`, `Mslang.transPreimage`, `Mslang.transImageSet`, `Mslang.transPreimageSet` (`lean/Mslang/Translation.lean`)
- **Contract:** Definition `B-D037`, section "Elementary translations and translations.".
- **Outcome:** `formal_stronger`
- **Recorded as:** `E-000361`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D037 — read-back
>
> ## Ambient setup (abbreviations in the file)
>
> - `SSet S := S → Type u`.
> - `Sub A := ∀ s, Set (A s)` for `A : SSet S`. A subobject is an `S`-indexed family
>   of subsets, one subset `L s : Set (A s)` per sort.
> - All definitions are marked `noncomputable` and use `classical` (for the
>   decidability-free `Function.update` on the dependent family and for classical
>   set operations).
>
> ## Definitions
>
> ### `deltaSub {S} {A : SSet S} (s : S) (Y : Set (A s)) : Sub A`
>
> The *concentrated* (delta) subobject at sort `s` with value `Y`: the family that
> equals `Y` at `s` and is empty at every other sort:
>
> ```
> deltaSub s Y := Function.update (fun u => (∅ : Set (A u))) s Y
> ```
>
> So `(deltaSub s Y) s = Y`, and `(deltaSub s Y) u = ∅` for `u ≠ s`.
>
> ### `transImage {t s} (T : A t → A s) (L : Sub A) : Sub A`
>
> The subobject concentrated at the *codomain* sort `s`, whose value there is the
> direct image of `L t` under `T`:
>
> ```
> transImage T L := deltaSub s (Set.image T (L t))
> ```
>
> So it is `Set.image T (L t)` at `s` and `∅` elsewhere; `L` is used only at its
> `t`-component.
>
> ### `transPreimage {t s} (T : A t → A s) (L : Sub A) : Sub A`
>
> The subobject concentrated at the *domain* sort `t`, whose value there is the
> preimage of `L s` under `T`:
>
> ```
> transPreimage T L := deltaSub t (Set.preimage T (L s))
> ```
>
> So it is `{x : A t | T x ∈ L s}` at `t` and `∅` elsewhere; `L` is used only at its
> `s`-component.
>
> ### `transImageSet {t s} (T : A t → A s) (X : Set (A t)) : Sub A`
>
> Direct image of a plain subset `X` of `A t`, packaged as a concentrated subobject
> at `s` (the ambient subobject is first concentrated at `t` with value `X`):
>
> ```
> transImageSet T X := transImage T (deltaSub t X)
> ```
>
> Unfolds to: `Set.image T X` at `s`, `∅` elsewhere.
>
> ### `transPreimageSet {t s} (T : A t → A s) (Y : Set (A s)) : Sub A`
>
> Preimage of a plain subset `Y` of `A s`, packaged as a concentrated subobject at
> `t`:
>
> ```
> transPreimageSet T Y := transPreimage T (deltaSub s Y)
> ```
>
> Unfolds to: `{x : A t | T x ∈ Y}` at `t`, `∅` elsewhere.
>
> ## Theorems / lemmas
>
> None. The file contains only the five definitions above and abbrevs `SSet`, `Sub`.
> No proposition is asserted.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D037 verdict
>
> Contract: for `T ∈ Tl_t(A)_s`, `L ⊆ A`, `X ⊆ A_t`, `Y ⊆ A_s`:
> 1. `T[L]` is concentrated at `s`: `T[L]_s = T[L_t]`, `T[L]_u = ∅` for `u ≠ s`;
>    i.e. `T[L] = δ^{s,T[L_t]}`.
> 2. `T^{-1}[L]` is concentrated at `t`: `T^{-1}[L]_t = T^{-1}[L_s]`, `∅` elsewhere;
>    i.e. `T^{-1}[L] = δ^{t,T^{-1}[L_s]}`.
> 3. `T[X] = T[δ^{t,X}]`.
> 4. `T^{-1}[Y] = T^{-1}[δ^{s,Y}]`.
>
> - clause 1 ↔ `transImage T L := deltaSub s (Set.image T (L t))`; matches `δ`-at-`s`
>   of the image of `L_t`. Match.
> - clause 2 ↔ `transPreimage T L := deltaSub t (Set.preimage T (L s))`. Match.
> - clause 3 ↔ `transImageSet T X := transImage T (deltaSub t X)`. Match.
> - clause 4 ↔ `transPreimageSet T Y := transPreimage T (deltaSub s Y)`. Match.
> - hypothesis `T ∈ Tl_t(A)_s`: the Lean definitions take an arbitrary
>   `T : A t → A s`; this stated restriction is dropped, making them more general.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: formal_stronger — every notation clause has a Lean counterpart with the
> same unfolding, but the Lean definitions generalize by dropping the contract's
> hypothesis that `T` is a translation (`T ∈ Tl_t(A)_s`).

