# Correspondence audit transcript -- `B-R012`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.nabla_isCongruence`, `Mslang.quot_nabla_subfinal` (`lean/Mslang/Subfinal.lean`)
- **Contract:** Remark `B-R012`, section "Preliminaries.".
- **Outcome:** `formal_weaker`
- **Recorded as:** `E-000327` (supersedes `E-000107`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back: B-R012.lean2
>
> Fixed ambient data: a type `S : Type u`. `Setoid` is Lean's bundled equivalence
> relation, and `(Φ s).r x y` denotes the relation of the setoid `Φ s`.
>
> ## Notational abbreviations (all fully defined in-file)
>
> - `SSet S := S → Type u` (a sort-indexed family of types; universe `Type (u+1)`).
> - `Signature S := List S × S → Type u` (operation symbols indexed by an arity
>   list `p.1` and a result sort `p.2`).
> - `SortedEqv A := ∀ s, Setoid (A s)` (a sort-respecting equivalence relation).
> - `SortedMap A B := ∀ s, A s → B s` (a sort-respecting function, not required
>   to preserve operations).
> - `Sub A := ∀ s, Set (A s)` (a sort-respecting subfamily).
> - `wordProd A w := (i : Fin w.length) → A (w.get i)` (the product of `A` over the
>   positions of the arity word `w`).
> - `finOp A w s := wordProd A w → A s` (an `w`-ary operation returning sort `s`).
>
> ## Definitions
>
> - `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`: an
>   interpretation of each operation symbol `σ : Sig p` as a function from the
>   product of `A` over the arity `p.1` into `A` at the result sort `p.2`.
>   (The type `Alg Sig`, used below with projections `.1`, `.2`, is *not*
>   defined in this file; it is referenced but absent here.)
> - `IsAlgHom Sig FA FB f := ∀ p σ a, f p.2 (FA p σ a) = FB p σ (fun i => f (p.1.get i) (a i))`:
>   `f` commutes with every operation, sortwise. Quantifiers: `p : List S × S`,
>   `σ : Sig p`, `a : wordProd A p.1`.
> - `IsAlgIso Sig FA FB f := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Bijective (f s)`:
>   a bijective homomorphism sortwise (note: no requirement that the inverse be a
>   homomorphism is added separately).
> - `IsCongruence Sig F Φ := ∀ p σ a b, (∀ i, (Φ (p.1.get i)).r (a i) (b i)) → (Φ p.2).r (F p σ a) (F p σ b)`:
>   `Φ` is compatible with every operation: pointwise `Φ`-related arguments give
>   `Φ`-related results.
> - `IsSubalgebra Sig F X := ∀ p σ a, (∀ i, a i ∈ X (p.1.get i)) → F p σ a ∈ X p.2`:
>   `X` contains the result of applying any operation to arguments lying in `X`
>   (sortwise).
> - `Subfinal A := ∀ s, Subsingleton (A s)`: every sort of `A` has at most one
>   element.
> - `finalSorted S := fun _ => PUnit` and `finalAlg Sig := ⟨finalSorted S, fun _ _ _ => PUnit.unit⟩`:
>   the terminal (one-element-per-sort) algebra.
> - `SubfinalAlg Sig X` (where `X : Alg Sig`) is defined as
>   `∃ Y : Sub (finalAlg Sig).1, ∃ hY : IsSubalgebra Sig (finalAlg Sig).2 Y,
>    ∃ f : SortedMap X.1 (subAlg Sig (finalAlg Sig).2 Y hY).1,
>      IsAlgIso Sig X.2 (subAlg Sig (finalAlg Sig).2 Y hY).2 f`:
>   `X` is isomorphic, as a sorted algebra, to some subalgebra `Y` of the final
>   algebra. Intuitively "subfinal".
> - `nabla A : SortedEqv A` is the *universal* relation: at every sort it is
>   `fun _ _ => True`, with trivially-proven equivalence laws.
> - `quot Φ := fun s => Quotient (Φ s)`.
> - `quotOp Sig F Φ p σ : finOp (quot Φ) p.1 p.2` is
>   `fun a => Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))` (uses a
>   choice of representatives `Quotient.out`; noncomputable).
> - `quotAlg Sig F Φ _hΦ : Alg Sig := ⟨quot Φ, fun p σ => quotOp Sig F Φ p σ⟩`.
>   (The congruence hypothesis `hΦ` is ignored in the body.)
> - `subAlg Sig F X hX : Alg Sig := ⟨fun s => {a : A s // a ∈ X s},
>    fun p σ b => ⟨F p σ (fun i => (b i).1), hX p σ (fun i => (b i).1) (fun i => (b i).2)⟩⟩`:
>   the subalgebra carried by `X`, with inherited operations using `hX` for
>   closure.
>
> ## Theorems
>
> 1. `nabla_isCongruence Sig F : IsCongruence Sig F (nabla A)`.
>    For arbitrary `Sig`, `A`, `F`, the universal sorted equivalence is a
>    congruence. (Proof: `intro; trivial`, since the goal relation is `True`.)
>    Hypothesis-free apart from `Sig`, `A`, `F`.
>
> 2. `subfinalAlg_iff Sig X : SubfinalAlg Sig X ↔ Subfinal X.1`.
>    For any `X : Alg Sig`, being "subfinal" (isomorphic to a subalgebra of the
>    final algebra) is equivalent to every sort of `X.1` being a subsingleton.
>    No hypotheses beyond `Sig`, `X`.
>
> 3. `quot_nabla_subfinal Sig F :` the quotient algebra
>    `quotAlg Sig F (nabla A) (nabla_isCongruence Sig F)` is `SubfinalAlg Sig ...`.
>    Concrete meaning: collapsing `A` by the universal congruence (i.e. making all
>    elements of each sort equal) yields a subfinal algebra. Proof route: rewrite
>    with `subfinalAlg_iff` to reduce to `Subfinal` of the quotient family; for
>    each sort, any two quotient classes are equal via `Quotient.sound trivial`.
>    Hypotheses: `Sig`, `A`, `F`; `F`'s algebra structure is not used.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-R012 verdict
>
> - Clause "A/∇^A is isomorphic to a subalgebra of 1": matched by `quot_nabla_subfinal` together with `SubfinalAlg` (= is isomorphic to a subalgebra `Y` of `finalAlg`), and `nabla_isCongruence`.
> - Lean additionally gives `subfinalAlg_iff` (subfinal ⇔ every sort is a subsingleton), a characterisation the contract does not state.
> - Single-sorted clause (∅ is an algebra ⇒ ∅/∇=∅, subalgebra of 1, and Sub(1)={∅,1}): no Lean counterpart.
> - Many-sorted clause (card(S)≥2 and Σ_{λ,s}=∅ ⇒ ∅^S is a Σ-algebra and ∅^S/∇=∅^S): no Lean counterpart.
> - Existence clause (there are A with ∅⊂supp_S(A)⊂S, so A/∇ is isomorphic to a subalgebra in Sub(1)−{∅^S,1}): no Lean counterpart.
>
> Contract clauses with no Lean counterpart: the enumeration Sub(1)={∅,1}, the ∅^S/∇=∅^S example, and the existence of algebras with intermediate support.
>
> Verdict: formal_weaker — the headline isomorphism is captured (even sharpened by `subfinalAlg_iff`), but three explicit content clauses of the remark are not formalised.
>
> Justification: the central claim is present, yet the remark's illustrative enumeration and intermediate-support existence clauses have no Lean counterpart.

## Note

Re-read with the bodies of the supporting definitions included (the first pass
had shown definition statements only). See the Session 119 `STATE.md` entry.

