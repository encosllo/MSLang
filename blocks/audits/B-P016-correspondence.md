# Correspondence audit transcript -- `B-P016`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.formation_congInf` (`lean/Mslang/Formation.lean`)
- **Contract:** Proposition `B-P016`, section "$\Sigma$-congruence formations, $\Sigma$-algebra formations, and an Eilenberg type theorem for them.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000304` (supersedes `E-000125`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back of `B-P016.lean`
>
> ## Ambient setting
>
> A fixed type `S` (the set of **sorts**) is understood. A **signature** `Sig` assigns to
> every pair `p = (w, s)` (list of sorts `w`, sort `s`) a type `Sig p` of operation symbols.
> The reused vocabulary is: `SSet S` (families of types indexed by sorts), `SortedMap A B`
> (sorted families of functions), `SortedEqv A` (sorted families of equivalence relations),
> `Alg Sig` (algebras), `AlgStruct`, `IsAlgHom`, `IsAlgIso`,
> `sortedEqvLe Φ Ψ` ("`Φ` refines `Ψ`", `Φ ≤ Ψ`), `sortedEqvInf Φ Ψ` (the meet: related iff
> related in both), `IsCongruence`, `IsCongruence_inf` (the meet of two congruences is a
> congruence), `ker f`, `quot`/`quotAlg` (quotient algebra), `pr`/`prAlg` (quotient
> projection), `quotLift` (factorisation through a coarser relation) and `quotLift_comp`
> (that factorisation indeed recovers the original map), `iAlg` (product algebra),
> `iPairAlg` (tupling into a product), `isAlgHom_iPairAlg`, `isAlgHom_prAlg`,
> `quotAlgLift_isAlgHom`, `ker_prAlg` (the kernel of the quotient projection is the relation
> itself), `IsSubdirectEmbedding`, `PFsdOperator`, `SubfinalAlg`, `finalAlg`,
> `IsAlgebraFormation`, `HOperator`, `wordProd`, `finOp`.
>
> Recall the relevant meanings:
> * `IsAlgebraFormation Sig F` has two parts: `F.1` is closure of `F` under the H-operator
>   (homomorphic images), and `F.2` is closure under subdirect products: if a finite family
>   `C : ι → Alg` has all `C i ∈ F` and `A` admits a subdirect embedding into `∏_i C_i`, then
>   `A ∈ F`.
> * `IsSubdirectEmbedding Sig A C f`, for `f : A → ∏_i C_i`, means `f` is a homomorphism,
>   injective, and surjective onto each factor after projecting.
>
> ## The single proven statement
>
> **`formation_congInf`.** Let `F` be a set of algebras with `hF : IsAlgebraFormation Sig F`.
> Let `A` be an algebra and let `Φ, Ψ` be congruences of `A` (with proofs `hΦ, hΨ`). Assume
> the two quotients are in `F`: `quotAlg Sig A.2 Φ hΦ ∈ F` and
> `quotAlg Sig A.2 Ψ hΨ ∈ F`. Then the quotient by the **meet** congruence is in `F`:
>
> `quotAlg Sig A.2 (sortedEqvInf Φ Ψ) (IsCongruence_inf Sig A.2 hΦ hΨ) ∈ F`.
>
> *Informal proof.* Write `QΦ = A/Φ`, `QΨ = A/Ψ`, `Q⊓ = A/(Φ⊓Ψ)`, and let
> `pΦ : Q⊓ → QΦ`, `pΨ : Q⊓ → QΨ` be the canonical surjections induced by the refinements
> `Φ⊓Ψ ≤ Φ` and `Φ⊓Ψ ≤ Ψ` (via `quotLift`, whose composite with the projection is the
> projection by `quotLift_comp`; both are homomorphisms by `quotAlgLift_isAlgHom`). Form the
> two-element family over the index type `ULift Bool`, with `false ↦ QΦ` and `true ↦ QΨ`, and
> the tupling map `f : Q⊓ → QΦ × QΨ` into the product. One checks:
> `f` is a homomorphism (`isAlgHom_iPairAlg`); `f` is injective, because if both projections
> of an element of `Q⊓` agree, its two representing elements are related in `Φ` and in `Ψ`,
> hence in `Φ⊓Ψ`, so they are equal in `Q⊓`; and `f` is surjective onto each factor (each of
> `pΦ`, `pΨ` is surjective). Thus `f` is a subdirect embedding of `Q⊓` into a product of the
> two algebras `QΦ, QΨ ∈ F`. Closure of `F` under subdirect products (`hF.2`) yields
> `Q⊓ ∈ F`.
>
> ## Declared vocabulary (types only in this file)
>
> `AlgStruct`, `HOperator`, `IsAlgHom`, `IsAlgebraFormation`, `IsCongruence`,
> `IsCongruence_inf`, `IsEpiAlg`, `IsMonoAlg`, `IsSubdirectEmbedding`, `PFsdOperator`, `SSet`,
> `Signature`, `SortedEqv`, `SortedMap`, `finOp`, `iAlg`, `iPairAlg`, `isAlgHom_iPairAlg`,
> `isAlgHom_prAlg`, `ker`, `ker_pr`, `ker_prAlg`, `pr`, `prAlg`, `quot`, `quotAlg`,
> `quotAlgLift_isAlgHom`, `quotLift`, `quotLift_comp`, `quotOp`, `quotOp_mk`, `sortedEqvInf`,
> `sortedEqvLe`, `wordProd`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-P016 — clause-by-clause
>
> Contract (proposition `FormAlgentailsShSk`): Let `F` be a formation of `Σ`-algebras. For
> every `Σ`-algebra `A` and every `Φ, Ψ ∈ Cgr(A)`, if `A/Φ` and `A/Ψ ∈ F`, then
> `A/(Φ∩Ψ) ∈ F`.
>
> - Clause 1 (`F` is a formation of `Σ`-algebras). Lean hypothesis `hF : IsAlgebraFormation Sig F`.
>   Match.
> - Clause 2 (`A` a `Σ`-algebra). Implicit in `A` with `A.2` its algebra structure. Match.
> - Clause 3 (`Φ, Ψ ∈ Cgr(A)`, i.e. congruences of `A`). Lean hypotheses `hΦ, hΨ` with the
>   congruence predicates. Match.
> - Clause 4 (hypothesis `A/Φ, A/Ψ ∈ F`). Lean assumes `quotAlg Sig A.2 Φ hΦ ∈ F` and
>   `quotAlg Sig A.2 Ψ hΨ ∈ F`. Match.
> - Clause 5 (conclusion `A/(Φ∩Ψ) ∈ F`). Lean concludes
>   `quotAlg Sig A.2 (sortedEqvInf Φ Ψ) (IsCongruence_inf …) ∈ F`, i.e. the quotient by the
>   meet `Φ⊓Ψ`. Match.
> - Clause 6 (proof content — closure under subdirect products). The proof builds the
>   subdirect embedding `Q⊓ → QΦ × QΨ` and invokes `hF.2`. Consistent, no extra claim.
>
> Contract clauses with no Lean counterpart: none
> Verdict: equivalent — the Lean theorem `formation_congInf` has exactly the contract's hypotheses and conclusion (quotient by the meet `Φ∩Ψ`).

