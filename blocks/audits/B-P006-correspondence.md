# Correspondence audit transcript -- `B-P006`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.satOfFamily`, `Mslang.familyOf`, `Mslang.satSetsFamilyEquiv`, `Mslang.satSetsCABA`, `Mslang.familyOf_atomRep`, `Mslang.satSets_isAtom_iff`, `Mslang.satSets_eq_sSup_atoms` (`lean/Mslang/Regular.lean`)
- **Contract:** Proposition `B-P006`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000299` (supersedes `E-000234`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-P006.lean`
>
> ## Setting
>
> Fix sorts `S`, a sorted set `A = (A s)_{s : S}`, and a sorted equivalence `Φ = (Φ s)` where each `Φ s` is
> an equivalence relation on `A s`. Write `pr Φ s : A s → Quotient (Φ s)` for the quotient map at sort `s`.
> A *subobject* `X` is a family of subsets `X s ⊆ A s`. `X` is `Φ`-*saturated* iff `sat Φ X = X`, where
> `sat Φ` adjoins all `Φ`-equivalent elements. `SatSet Φ` is the type of saturated subobjects (those `X`
> together with a proof that `sat Φ X = X`). A *quotient family* `QuotFamily Φ` is a family of subsets
> `Y s ⊆ Quotient (Φ s)`, one per sort.
>
> This file establishes that saturated subobjects and quotient families are the same thing, and derives the
> lattice-theoretic consequences.
>
> ## Definitions
>
> - **`satOfFamily Φ Y`** (for `Y : QuotFamily Φ`): the subobject `fun s => (pr Φ s)⁻¹' (Y s)`, i.e. at
>   each sort pull `Y s` back along the quotient map. This is saturated (`isSat_satOfFamily`, used below).
>
> - **`familyOf Φ X`** (for `X : SatSet Φ`): the quotient family `fun s => pr Φ s '' (X.1 s)`, i.e. the
>   image of each fiber of the saturated subobject under the quotient map.
>
> - **`satSetsFamilyEquiv Φ`**: a (noncomputable) equivalence (bijection)
>   `SatSet Φ ≃ QuotFamily Φ`. Its forward map is `familyOf Φ`; its inverse sends `Y` to
>   `⟨satOfFamily Φ Y, isSat_satOfFamily Φ Y⟩`; it satisfies both inverse laws
>   (`satOfFamily_familyOf` and `familyOf_satOfFamily`).
>
> - **`satSetsCABA Φ`**: transport of the `CompleteAtomicBooleanAlgebra` (complete atomic Boolean algebra)
>   structure along that equivalence, endowing `SatSet Φ` with a complete atomic Boolean algebra structure.
>
> ## Theorems
>
> - **`familyOf_atomRep Φ s q`** (with `[DecidableEq S]`, `s : S`, `q : Quotient (Φ s)`): let
>   `X_{s,q}` be the saturated subobject `deltaSub s (eqvClass Φ s (Quotient.out q))`, i.e. the subobject
>   that is the full `Φ s`-equivalence class of a representative of `q` in fiber `s` and empty in all other
>   fibers (a "delta" at sort `s`). Then
>   `familyOf Φ X_{s,q} = Function.update (⊥ : QuotFamily Φ) s ({q} : Set (Quotient (Φ s)))`.
>   In words: the quotient family corresponding to the atom representative at `(s, q)` is the bottom
>   family except in sort `s`, where it is the singleton `{q}`. (Here `⊥` is the bottom of the quotient
>   family lattice, i.e. the everywhere-empty family.) The key content is that the image of the class
>   `eqvClass Φ s (Quotient.out q)` under `pr Φ s` is exactly `{q}`.
>
> - **`satSets_isAtom_iff Φ X`** (for `X : SatSet Φ`): `IsAtom (familyOf Φ X)` holds if and only if there
>   exist a sort `s` and a point `q : Quotient (Φ s)` such that
>   `X = ⟨deltaSub s (eqvClass Φ s (Quotient.out q)), isSat_atomRep Φ s (Quotient.out q)⟩`.
>   So the atoms of the Boolean algebra of saturated subobjects (transported through `familyOf`) are exactly
>   the subobjects that are a single `Φ`-equivalence class in one fiber and empty elsewhere; these are in
>   bijection with the disjoint union over `s` of the quotient points `Quotient (Φ s)`. The forward
>   direction uses that atoms of a product-of-powerset lattice are single generators, and that a singleton
>   is an atom.
>
> - **`satSets_eq_sSup_atoms Φ X`**: for every saturated `X`,
>   `familyOf Φ X = sSup {Y : QuotFamily Φ | IsAtom Y ∧ Y ≤ familyOf Φ X}`.
>   That is, every element of the complete Boolean algebra (viewed via `familyOf`) is the supremum of the
>   atoms below it. Proof by antisymmetry: for `≤`, every atom `Y ≤ familyOf Φ X` is itself `≤` the
>   supremum; for `≥`, the supremum of elements `Y` with `Y ≤ familyOf Φ X` is `≤ familyOf Φ X`
>   (`sSup_le`). This expresses that the algebra is *atomic* (every element is a join of atoms).
>
> ## Declarations stated without bodies in this file
>
> `SSet`, `SortedEqv`, `Sub`, `deltaSub`, `eqvClass`, `pr` are declared here without bodies; they carry the
> meanings described above (family of types; family of equivalence relations; family of subsets; the
> delta subobject supported on one fiber; an equivalence class; the quotient map).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P006 verdict
>
> Contract: Proposition `CABA Saturades`. `(Φ-Sat(A), ⊆)` is a complete atomic Boolean algebra.
>
> ## Clause-by-clause
>
> 1. **Setting** — `A` an `S`-sorted set, `Φ ∈ Eqv(A)`. Lean: `SortedEqv Φ`, saturated subobjects `SatSet Φ` (pairs `X, sat Φ X = X`). Match.
> 2. **`Φ-Sat(A)` is a complete Boolean algebra.** Lean `satSetsCABA Φ`: the `CompleteAtomicBooleanAlgebra` structure on `QuotFamily Φ` (the everywhere-subsets family `∏_s Set (Quotient (Φ s))`) is transported along the bijection `satSetsFamilyEquiv Φ : SatSet Φ ≃ QuotFamily Φ`. This supplies the complete Boolean algebra operations and laws. Match.
> 3. **`Φ-Sat(A)` is *atomic*.** Lean `satSets_eq_sSup_atoms Φ X`: every element is the supremum of the atoms below it. Additionally `satSets_isAtom_iff` characterises the atoms, and `familyOf_atomRep` computes the atom at `(s,q)` as a delta family. This supplies atomicity and more. Match.
>
> ## Contract clauses with no Lean counterpart:
>
> none
>
> Verdict: equivalent
> The Lean read-back transports a full `CompleteAtomicBooleanAlgebra` structure onto the saturated subobjects and explicitly proves atomicity (every element is a sup of atoms), which is exactly the contract's claim.

