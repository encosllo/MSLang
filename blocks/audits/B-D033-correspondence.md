# Correspondence audit transcript -- `B-D033`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.IsCongruence_inf`, `Mslang.IsShSkFormation` (`lean/Mslang/Formation.lean`)
- **Contract:** Definition `B-D033`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000357`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D033 read-back
>
> Fixed ambient data: sort set `S : Type u`, signature `Sig : Signature S`, bundled
> algebras `Alg Sig` (used but not defined here).
>
> ## Theorem `IsCongruence_inf`
>
> ```
> theorem IsCongruence_inf (Sig : Signature S) {A : SSet S}
>     (F : AlgStruct Sig A) {Φ Ψ : SortedEqv A}
>     (hΦ : IsCongruence Sig F Φ) (hΨ : IsCongruence Sig F Ψ) :
>     IsCongruence Sig F (sortedEqvInf Φ Ψ)
> ```
>
> Hypotheses: an algebra structure `F` on carrier `A`; two sorted equivalences
> `Φ`, `Ψ` on `A`; proofs `hΦ`, `hΨ` that each is a congruence on `F`.
> Conclusion: the componentwise meet `sortedEqvInf Φ Ψ` is again a congruence on `F`.
> The proof takes arbitrary `p`, `σ : Sig p`, `a b : wordProd A p.1`, and
> `h : ∀ i, ((sortedEqvInf Φ Ψ) (p.1.get i)).r (a i) (b i)`; since the meet relation
> is a conjunction at each sort, `h i` gives both `(Φ …).r (a i) (b i)` and
> `(Ψ …).r (a i) (b i)`; applying `hΦ` and `hΨ` yields both conjuncts of the required
> output relation. So the set of congruences is closed under binary meet.
>
> ## `IsShSkFormation Sig (F : Set (Alg Sig)) : Prop`
>
> A conjunction of three clauses:
>
> 1. `∀ A : Alg Sig, SubfinalAlg Sig A → A ∈ F` — every subfinal algebra belongs to
>    `F`.
> 2. `HOperator Sig F ⊆ F` — `F` is closed under homomorphic images.
> 3. `∀ (A : Alg Sig) (Φ Ψ : SortedEqv A.1)
>        (hΦ : IsCongruence Sig A.2 Φ) (hΨ : IsCongruence Sig A.2 Ψ),
>      quotAlg Sig A.2 Φ hΦ ∈ F → quotAlg Sig A.2 Ψ hΨ ∈ F →
>      quotAlg Sig A.2 (sortedEqvInf Φ Ψ) (IsCongruence_inf Sig A.2 hΦ hΨ) ∈ F`
>    — if the quotients of `A` by two congruences `Φ` and `Ψ` both lie in `F`, then
>    the quotient by their meet `sortedEqvInf Φ Ψ` (a congruence by the theorem) also
>    lies in `F`. (Closure under quotienting by meets of congruences.)
>
> ## Supporting definitions
>
> - `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`.
> - `IsAlgHom Sig FA FB f :=
>    ∀ (p) (σ : Sig p) (a : wordProd A p.1),
>      f p.2 (FA p σ a) = FB p σ (fun i => f (p.1.get i) (a i))`.
> - `IsAlgIso Sig FA FB f := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Bijective (f s)`:
>   an isomorphism is a homomorphism that is bijective at every sort.
> - `IsEpiAlg Sig FA FB f := IsAlgHom Sig FA FB f ∧ ∀ s, Function.Surjective (f s)`.
> - `IsCongruence Sig F Φ :=
>    ∀ (p) (σ : Sig p) (a b : wordProd A p.1),
>      (∀ i, (Φ (p.1.get i)).r (a i) (b i)) → (Φ p.2).r (F p σ a) (F p σ b)`.
> - `Sub A := ∀ s, Set (A s)`: a sortwise family of subsets.
> - `IsSubalgebra Sig F X : Prop :=
>    ∀ (p) (σ : Sig p) (a : wordProd A p.1),
>      (∀ i, a i ∈ X (p.1.get i)) → F p σ a ∈ X p.2`:
>   `X` contains the result of every operation applied to arguments lying in `X`
>   (argumentwise membership forces result membership).
> - `HOperator Sig F := {A | ∃ B ∈ F, ∃ f : SortedMap B.1 A.1, IsEpiAlg Sig B.2 A.2 f}`.
> - `finalAlg Sig : Alg Sig := ⟨finalSorted S, fun _ _ _ => PUnit.unit⟩`, with
>   `finalSorted S := fun _ => PUnit.{u+1}`: the terminal algebra, whose every sort is
>   a one-element type and whose every operation is the constant `unit`.
> - `SubfinalAlg Sig X : Prop :=
>    ∃ (Y : Sub (finalAlg Sig).1) (hY : IsSubalgebra Sig (finalAlg Sig).2 Y)
>      (f : SortedMap X.1 (subAlg Sig (finalAlg Sig).2 Y hY).1),
>      IsAlgIso Sig X.2 (subAlg Sig (finalAlg Sig).2 Y hY).2 f`:
>   `X` is isomorphic to a subalgebra of the final algebra. Since the final algebra is
>   the one-element algebra, this picks out the "subfinal" (trivial, up to iso)
>   algebras.
> - `subAlg Sig F X hX : Alg Sig :=
>    ⟨fun s => {a : A s // a ∈ X s},
>     fun p σ b => ⟨F p σ (fun i => (b i).1),
>       hX p σ (fun i => (b i).1) (fun i => (b i).2)⟩⟩`:
>   the subalgebra carried by the sortwise subtypes `{a // a ∈ X s}`, with operations
>   computed in `A` (closure supplied by `hX`).
> - `quot Φ := fun s => Quotient (Φ s)`;
>   `quotOp Sig F Φ p σ := fun a => Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))`;
>   `quotAlg Sig F Φ _hΦ := ⟨quot Φ, fun p σ => quotOp Sig F Φ p σ⟩`.
> - `sortedEqvInf Φ Ψ`: sortwise `x ~ y ↔ (Φ s).r x y ∧ (Ψ s).r x y`.
> - `SSet S := S → Type u`; `Signature S := List S × S → Type u`;
>   `SortedEqv A := ∀ s, Setoid (A s)`; `SortedMap A B := ∀ s, A s → B s`;
>   `finOp A w s := wordProd A w → A s`;
>   `wordProd A w := (i : Fin w.length) → A (w.get i)`.
>
> ## Summary
>
> The file proves that congruences are closed under componentwise meet
> (`IsCongruence_inf`) and defines the predicate `IsShSkFormation` on a class of
> algebras: it contains every subfinal algebra, is closed under homomorphic images,
> and is closed under quotienting by the meet of two congruences whose separate
> quotients lie in the class.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D033 clause-by-clause
>
> Contract: an ShSk-formation of Σ-algebras is a set `𝓕` of Σ-algebras with
> 1. `Sf(1) ⊆ 𝓕` (contains the subfinal algebras);
> 2. `H(𝓕) ⊆ 𝓕` (closed under homomorphic images);
> 3. for every `A` and `Φ, Ψ ∈ Cgr(A)`, if `A/Φ, A/Ψ ∈ 𝓕` then
>    `A/(Φ ∩ Ψ) ∈ 𝓕`.
>
> - Clause 1 ↔ Lean `∀ A : Alg Sig, SubfinalAlg Sig A → A ∈ F`, where `SubfinalAlg
>   Sig A` means `A` is isomorphic to a subalgebra of the final (one-element)
>   algebra `finalAlg Sig` (`Sub`+`IsSubalgebra`+`IsAlgIso` into a `subAlg`). This
>   is membership in `Sf(1)` read up to isomorphism. Match.
> - Clause 2 ↔ Lean `HOperator Sig F ⊆ F` (homomorphic images via `IsEpiAlg`).
>   Match.
> - Clause 3 ↔ Lean `∀ A Φ Ψ (hΦ hΨ), quotAlg Sig A.2 Φ hΦ ∈ F →
>   quotAlg Sig A.2 Ψ hΨ ∈ F → quotAlg Sig A.2 (sortedEqvInf Φ Ψ)
>   (IsCongruence_inf …) ∈ F`, i.e. closure under quotienting by the meet of two
>   congruences whose separate quotients lie in `F`. The well-typedness uses the
>   accompanying theorem `IsCongruence_inf` that congruences are closed under the
>   componentwise meet. Match.
> - The commented-out nonemptiness/abstractness items are not active clauses.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — all three active clauses (subfinal algebras, `H`-closure, quotient-by-meet closure) are present, with the meet-quotient well-defined via `IsCongruence_inf`.

