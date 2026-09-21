# Correspondence audit transcript -- `B-C009`

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 119 as a
batched re-audit of the stale correspondence layer: several blocks shared one
stage-batch agent, so the stages for different blocks in a batch had a common
context; no agent was told the expected answer or shown the prior verdict. Stage 1
saw only the Lean declarations and their definitions; stage 2 saw only the stage 1
read-back and the contract.

- **Lean declarations:** `Mslang.langFormationOf_atom_inf` (`lean/Mslang/Regular.lean`)
- **Contract:** Corollary `B-C009`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `formal_stronger`
- **Recorded as:** `E-000291` (supersedes `E-000209`)
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back: B-C009.lean2
>
> Fixed ambient data: a type `S : Type u`; `Setoid` bundled; `(Φ s).r x y` the
> relation. `Alg Sig` (with `.1`, `.2`) and `atomRep` are referenced but not
> defined in this file.
>
> ## Notational abbreviations and definitions
>
> - `SSet S := S → Type u`; `Signature S := List S × S → Type u`;
>   `SortedEqv A := ∀ s, Setoid (A s)`; `SortedMap A B := ∀ s, A s → B s`;
>   `Sub A := ∀ s, Set (A s)`; `wordProd A w := (i : Fin w.length) → A (w.get i)`;
>   `finOp A w s := wordProd A w → A s`;
>   `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`.
> - `Term Sig X : S → Type u` (inductive): `var x` (`x : X s`) or
>   `op p σ a` with `a : (i : Fin p.1.length) → Term Sig X (p.1.get i)`,
>   result sort `p.2`.
> - `IsElemTranslation Sig A t s T`: single-operation substitution as in the
>   companion files (an operation `σ : Sig (w, s)` with one distinguished slot
>   `i` carrying the input and the rest fixed).
> - `TlGen Sig A` (inductive): `refl`, `elem : IsElemTranslation → TlGen`,
>   `comp` (composition of translations).
> - `IsAlgHom Sig FA FB f := ∀ p σ a, f p.2 (FA p σ a) = FB p σ (fun i => f (p.1.get i) (a i))`.
> - `IsCongruence Sig F Φ := ∀ p σ a b, (∀ i, (Φ (p.1.get i)).r (a i) (b i)) →
>    (Φ p.2).r (F p σ a) (F p σ b)`.
> - `ClosesUnderEtl` / `ClosesUnderTl`: translation-closure of a sorted equivalence,
>   exactly as `ClosesUnderEtl Sig A Φ := ∀ t s x y T, IsElemTranslation T →
>    Φ t x y → Φ s (T x) (T y)` and `ClosesUnderTl` with `TlGen` instead.
> - `IsCongruenceFormation Sig F` (for `F : (A : SSet S) → Set (SortedEqv (Term Sig A))`)
>   is the conjunction of:
>   1. for every `A`: `(F A).Nonempty`; every member is a congruence of the term
>      algebra `termAlg Sig A`; closure under `sortedEqvInf`; and upward closure
>      among congruences along `sortedEqvLe`;
>   2. for every `A B`, congruence `Θ` of `termAlg Sig B` with `Θ ∈ F B`, and
>      algebra hom `f : Term Sig A → Term Sig B` whose composite with the projection
>      `prAlg Sig (termAlg B).2 Θ hΘ` is sortwise surjective, the kernel of that
>      composite lies in `F A`.
> - `sat Φ X := fun s => {a | ∃ x ∈ X s, (Φ s).r x a}`; `IsSat Φ X := sat Φ X = X`.
> - `charEqv L : SortedEqv A := fun s => ⟨fun x y => x ∈ L s ↔ y ∈ L s, ...⟩`.
> - `congCogenerated Sig A L : SortedEqv A.1 :=
>    fun t => ⟨fun x y => ∀ (s : S) (T : A.1 t → A.1 s),
>      TlGen Sig A t s T → (T x ∈ L s ↔ T y ∈ L s), ...⟩`.
> - `sortedEqvInf Φ Ψ := fun s => ⟨fun x y => (Φ s).r x y ∧ (Ψ s).r x y, ...⟩`.
> - `sortedEqvLe Φ Ψ := ∀ s x y, (Φ s).r x y → (Ψ s).r x y` (Φ finer than Ψ).
> - `ker f := fun s => ⟨fun x y => f s x = f s y, ...⟩`.
> - `termAlg Sig X := ⟨Term Sig X, fun p σ a => Term.op p σ a⟩`.
> - `pr Φ s x := Quotient.mk (Φ s) x`; `prAlg Sig F Φ _hΦ := pr Φ`; `quot`, `quotOp`,
>   `quotAlg` as in the companion files (quotient by `Φ`, operations via
>   `Quotient.out`, the congruence hypothesis unused in the body).
> - `langFormationOf G A := {L : Sub (Term Sig A) | congCogenerated Sig (termAlg Sig A) L ∈ G A}`.
>
> ## Theorems
>
> Only the first declaration has a proof body; the rest are bare assertions.
>
> 1. `langFormationOf_atom_inf` (has proof): given `hG : IsCongruenceFormation Sig G`,
>    `A : SSet S`, `Φ Ψ : SortedEqv (Term Sig A)`, `s : S`, `P : Term Sig A s`.
>    If `atomRep Φ s P ∈ langFormationOf Sig G A` and
>    `atomRep Ψ s P ∈ langFormationOf Sig G A`, then
>    `atomRep (sortedEqvInf Φ Ψ) s P ∈ langFormationOf Sig G A`.
>    I.e. the "atomic representation" family is closed under `sortedEqvInf` at a
>    fixed atom `P` of sort `s`. Proof: rewrite `atomRep_inf` (not defined in this
>    file) and apply `langFormationOf_inter`.
> 2. `langFormationOf_inter`: if `L ∈ langFormationOf Sig G A` and
>    `L' ∈ langFormationOf Sig G A`, then `(fun s => L s ∩ L' s) ∈ langFormationOf Sig G A`.
>    (Closure of the family under pointwise intersection.)
> 3. `mem_langFormationOf_iff`: `L ∈ langFormationOf Sig G A ↔ ∃ Φ ∈ G A, IsSat Φ L`.
>    A language belongs iff it is fixed by some congruence in `G A`.
> 4. `sat_antitone`: `sortedEqvLe Φ Ψ → IsSat Ψ X → IsSat Φ X`.
>    If `Φ` is finer than `Ψ` and `X` is fixed by `Ψ`, then `X` is fixed by `Φ`.
> 5. `closesUnderEtl_of_closesUnderTl`: `ClosesUnderTl Sig A Φ → ClosesUnderEtl Sig A Φ`.
> 6. `closesUnderEtl_of_isCongruence`: `IsCongruence Sig A.2 Φ → ClosesUnderEtl Sig A Φ`.
> 7. `closesUnderTl_of_closesUnderEtl`: `ClosesUnderEtl Sig A Φ → ClosesUnderTl Sig A Φ`.
> 8. `congCogenerated_isCongruence`: `IsCongruence Sig A.2 (congCogenerated Sig A L)`.
> 9. `congCogenerated_le_charEqv`: `sortedEqvLe (congCogenerated Sig A L) (charEqv L)`.
> 10. `congruence_of_closesUnderEtl`: `ClosesUnderEtl Sig A Φ → IsCongruence Sig A.2 Φ`.
> 11. `isCongruence_iff_closesUnderEtl`: `IsCongruence Sig A.2 Φ ↔ ClosesUnderEtl Sig A Φ`.
> 12. `isSat_iff_le_congCogenerated`: for a congruence `hΦ`,
>     `IsSat Φ L ↔ sortedEqvLe Φ (congCogenerated Sig A L)`.
> 13. `isSat_iff_sortedEqvLe_charEqv`: `IsSat Φ L ↔ sortedEqvLe Φ (charEqv L)`.
> 14. `le_congCogenerated_of_isCongruence`: for a congruence `hΦ` with
>     `sortedEqvLe Φ (charEqv L)`, conclude `sortedEqvLe Φ (congCogenerated Sig A L)`
>     (maximality of `congCogenerated`).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-C009 verdict
>
> - Clause "for congruences Φ,Ψ on T_Σ(A), sort s, term P∈T_Σ(A)_s: if δ^{s,[P]_{Φ_s}} and δ^{s,[P]_{Ψ_s}} are in L_F(A), then so is δ^{s,[P]_{(Φ∩Ψ)_s}}": matched by `langFormationOf_atom_inf`, i.e. from `atomRep Φ s P ∈ langFormationOf Sig G A` and `atomRep Ψ s P ∈ langFormationOf Sig G A` conclude `atomRep (sortedEqvInf Φ Ψ) s P ∈ langFormationOf Sig G A`.
> - δ^{s,[P]_{·}} = Lean `atomRep · s P`; (Φ∩Ψ)_s = Lean `sortedEqvInf Φ Ψ` (pointwise intersection of the relations).
> - Lean omits the contract's requirement that Φ and Ψ be congruences on the term algebra; they are arbitrary `SortedEqv (Term Sig A)`. The proof (via `atomRep_inf` and `langFormationOf_inter`) does not use congruence-ness, so the statement is more general.
> - The formation hypothesis `hG : IsCongruenceFormation Sig G` is implicit in the contract's use of L_F(A).
>
> Contract clauses with no Lean counterpart: none.
>
> Verdict: formal_stronger — the closure statement is obtained for arbitrary sorted equivalences, not only congruences.
>
> Justification: the intersection-of-atoms conclusion matches, and dropping the congruence hypothesis on Φ,Ψ yields a strictly stronger theorem.

## Note

Re-read with the bodies of the supporting definitions included (the first pass
had shown definition statements only). See the Session 119 `STATE.md` entry.

