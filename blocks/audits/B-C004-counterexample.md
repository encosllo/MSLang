# Negation probe -- `B-C004` (Architecture.md Section 11.3)

**Outcome: the literal statement "Definitions `DefFormAlg` (`B-D032`) and
`ShSkFormAlg` (`B-D033`) are equivalent" is false** for the pre-fix `B-D033`
(whose clause 1 was `F ≠ ∅`). Confirmed by a Lean counterexample, then resolved
by the author's Option 1 (amend clause 1 to `Sf(1) ⊆ F`).

## Counterexample

Let `S ≠ ∅`, let `Σ` have no operations, and let
`F = { X : Σ-algebra | supp X ≠ ∅ }` (at least one nonempty component).

- `F` is an **ShSk-formation**: nonempty (`1 ∈ F`); `H`-closed (a surjective
  image of a nonempty-support algebra has nonempty support); meet-closure holds
  because `supp(A/Φ) ≠ ∅ ⟹ supp(A) ≠ ∅ ⟹ supp(A/(Φ ⊓ Ψ)) ≠ ∅`.
- `F` is **not a formation**: the empty product (`n = 0`) is `1`, and the initial
  algebra `∅^S` admits a subdirect embedding into `1`, so
  `∅^S ∈ P_fsd(F)` — but `∅^S ∉ F`.

So `IsShSkFormation Sig F ∧ ¬ IsAlgebraFormation Sig F`.

The paper itself records the many-sorted empties at `MSEilenberg.tex` line 844
(`∅^S` is a Σ-algebra when there are no nullary operations), so this is not an
encoding artifact. The single-sorted case is unaffected.

## Artifact

`B-C004-counterexample.lean.txt` is the scratch probe as run. It compiled
cleanly (axioms `propext`, `Classical.choice`, `Quot.sound`) against the
**pre-fix** `Mslang.IsShSkFormation`, and **no longer compiles** against the
fixed definition (the `Sf(1) ⊆ F` clause is not satisfied by
`nonemptyAlgebras`), which is the intended resolution.

## Resolution

Author decision: Option 1 — `B-D033` clause 1 becomes `Sf(1) ⊆ F` (highlighted
red in the manuscript). See `STATE.md` Session 71 for the (interrupted) work
list.
