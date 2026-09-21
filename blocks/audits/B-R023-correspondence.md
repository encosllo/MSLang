# Correspondence audit transcript -- `B-R023`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.langFormationOf_sat_of_le` (`lean/Mslang/Regular.lean`)
- **Contract:** Remark `B-R023`, section "$\Sigma$-finite index congruence formation, $\Sigma$-regular language formation, and an Eilenberg type theorem for them.".
- **Outcome:** `formal_stronger`
- **Recorded as:** `E-000372`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # Read-back: B-R023.lean
>
> ## Ambient setup
>
> Fix a sort type `S : Type u`. The development uses the same sorted universal
> algebra vocabulary as B-R022:
>
> - `SSet S := S → Type u`; `Signature S := List S × S → Type u` (symbols indexed
>   by an arity pair `p = (w, s)`, `w` input sorts, `s` output sort).
> - `SortedEqv A := ∀ s, Setoid (A s)` (a family of equivalence relations; write
>   `(Φ s).r x y`).
> - `SortedMap A B := ∀ s, A s → B s`; `Sub A := ∀ s, Set (A s)`.
> - `wordProd A w := (i : Fin w.length) → A (w.get i)`;
>   `finOp A w s := wordProd A w → A s`.
> - `Term Sig X`: inductive terms, constructors `var {s} (x : X s)` and
>   `op (p : List S × S) (σ : Sig p) (a : (i : Fin p.1.length) → Term Sig X (p.1.get i)) : Term Sig X p.2`.
> - `Alg Sig` (fields `A.1 : SSet S`, `A.2 : AlgStruct Sig A.1`) is the bundled
>   algebra type.
>
> The file contains the *same* core definitions as B-R022 (in the same shape),
> namely: `AlgStruct`, `ClosesUnderEtl`, `ClosesUnderTl`, `IsAlgHom`,
> `IsCongruence`, `IsCongruenceFormation`, `IsElemTranslation`, `IsSat`, `Term`,
> `TlGen`, `charEqv`, `congCogenerated`, `finOp`, `ker`, `langFormationOf`, `pr`,
> `prAlg`, `quot`, `quotAlg`, `quotOp`, `sat`, `sortedEqvInf`, `sortedEqvLe`,
> `termAlg`, `wordProd`. It does **not** define `satSets`, and it omits
> `langFormationOf_eq_iUnion_satSets`.
>
> ## Definitions (recap, same reading as B-R022)
>
> - `AlgStruct Sig A`: interprets each symbol `σ : Sig (w,s)` as an operation
>   `wordProd A w → A s`.
>
> - `IsAlgHom Sig FA FB f`: `f : SortedMap A B` commutes with all operations:
>   for all `p=(w,s)`, `σ`, `a : wordProd A w`,
>   `f s (FA p σ a) = FB p σ (fun i => f (w.get i) (a i))`.
>
> - `IsCongruence Sig F Φ`: for all `p=(w,s)`, `σ`, `a b : wordProd A w`,
>   `(∀ i, (Φ (w.get i)).r (a i) (b i)) → (Φ s).r (F p σ a) (F p σ b)`
>   (Φ compatible with all operations).
>
> - `IsElemTranslation Sig A t s T`: `T` fixes all-but-one argument of some
>   symbol: there exist `w`, `i : Fin w.length`, `hwit : w.get i = t`,
>   `σ : Sig (w,s)`, and values `a k` for `k ≠ i`, such that for every `x`,
>   `T x = A.2 (w,s) σ` on the tuple equal to `x` at position `i` (transported
>   along `hwit`) and `a k` elsewhere.
>
> - `TlGen Sig A t s T`: smallest class containing `refl` (`id`), `elem` (every
>   elementary translation), closed under `comp` (`U ∘ T`). "Generated
>   translations".
>
> - `ClosesUnderEtl Sig A Φ`: Φ is compatible with every elementary translation.
> - `ClosesUnderTl Sig A Φ`: Φ is compatible with every generated translation.
>
> - `charEqv L`: at sort `s`, `x ~ y` iff `x ∈ L s ↔ y ∈ L s`.
>
> - `congCogenerated Sig A L`: at sort `t`, `x ~ y` iff for all `s` and all
>   `T : A.1 t → A.1 s` with `TlGen Sig A t s T`, `T x ∈ L s ↔ T y ∈ L s`.
>
> - `sat Φ X`: at sort `s`, `{a | ∃ x ∈ X s, (Φ s).r x a}`; `IsSat Φ X := sat Φ X = X`.
>
> - `ker f`: at each `s`, `x ~ y` iff `f s x = f s y`.
>
> - `langFormationOf Sig G A := {L : Sub (Term Sig A) | congCogenerated Sig (termAlg Sig A) L ∈ G A}`.
>
> - `IsCongruenceFormation Sig F` (F maps each `A : SSet S` to a set of sorted
>   equivalences on terms), conjunction of:
>   1. for each `A`: `F A` nonempty; each `Φ ∈ F A` is a congruence on the term
>      algebra `(termAlg Sig A).2`; `F A` closed under `sortedEqvInf`; and `F A`
>      upward closed among congruences (`Φ ∈ F A` and `Φ ≤ Ψ` a congruence imply
>      `Ψ ∈ F A`);
>   2. for all `A B`, congruence `Θ` on `termAlg Sig B` with `Θ ∈ F B`, every
>      algebra homomorphism `f : Term Sig A → Term Sig B` that is surjective onto
>      the quotient by Θ (per sort, after composing with the quotient map), the
>      kernel of `prAlg …Θ… ∘ f` belongs to `F A`.
>
> - `pr`, `quot`, `prAlg`, `quotAlg`, `quotOp`, `termAlg`, `sortedEqvInf`,
>   `sortedEqvLe` as in B-R022, with the same readings:
>   `quotOp F Φ p σ a := Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))`;
>   `sortedEqvInf` pointwise conjunction; `sortedEqvLe` pointwise implication.
>
> ## Theorems (as stated)
>
> The file re-states the same claims as B-R022:
>
> - `closesUnderEtl_of_closesUnderTl`, `closesUnderEtl_of_isCongruence`,
>   `closesUnderTl_of_closesUnderEtl`, `congruence_of_closesUnderEtl`,
>   `isCongruence_iff_closesUnderEtl`: the mutual equivalence between being a
>   congruence and closing under (elementary / generated) translations.
>
> - `congCogenerated_isCongruence`: `congCogenerated Sig A L` is a congruence
>   for `A.2`, for every `L`.
>
> - `congCogenerated_le_charEqv`: `congCogenerated Sig A L ≤ charEqv L`.
>
> - `isSat_iff_sortedEqvLe_charEqv`: `IsSat Φ L ↔ sortedEqvLe Φ (charEqv L)`.
>
> - `le_congCogenerated_of_isCongruence`: congruence `Φ ≤ charEqv L` implies
>   `Φ ≤ congCogenerated Sig A L`.
>
> - `isSat_iff_le_congCogenerated`: for a congruence `Φ`,
>   `IsSat Φ L ↔ sortedEqvLe Φ (congCogenerated Sig A L)`.
>
> - `mem_langFormationOf_iff`: `L ∈ langFormationOf Sig G A ↔ ∃ Φ ∈ G A, IsSat Φ L`.
>
> Additional claims present only in B-R023:
>
> - `sortedEqvLe_trans`: `sortedEqvLe` is transitive: if `Φ ≤ Ψ` and `Ψ ≤ Χ` then
>   `Φ ≤ Χ` (pointwise).
>
> - `sat_antitone`: if `Φ ≤ Ψ` (pointwise) and `X` is Ψ-saturated (`IsSat Ψ X`),
>   then `X` is Φ-saturated (`IsSat Φ X`). A weaker relation saturates fewer
>   sets, so `sat` is antitone in the relation.
>
> - `sat_idem`: `sat Φ (sat Φ X) = sat Φ X` for all `Φ`, `X` — satuation is
>   idempotent.
>
> - `langFormationOf_sat_of_le`: for `G` an `IsCongruenceFormation`, `A : SSet S`,
>   `L ∈ langFormationOf Sig G A`, and `Ψ : SortedEqv (Term Sig A)` with
>   `congCogenerated Sig (termAlg Sig A) L ≤ Ψ`, we have
>   `sat Ψ L ∈ langFormationOf Sig G A`.
>   I.e. the language formation is closed under saturation of a member by any
>   sorted equivalence above its cogenerated congruence. (Proof: extract a
>   witness `Φ ∈ G A` with `IsSat Φ L`, convert to
>   `Φ ≤ congCogenerated L`, chain with the hypothesis to get `Φ ≤ Ψ`, then use
>   `sat_antitone` and `sat_idem` to show `sat Ψ L` is Φ-saturated.)
>
> Note: several theorem statements are declared without proof bodies in the file;
> they are read as asserted claims.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-R023 verdict
>
> Contract (`B-R023.tex`): Given an S-sorted set `A`, an `L ∈ ℒ_𝔉(A)`, and a
> `Ψ ∈ Cgr(T_Σ(A))`, if `Ω^{T_Σ(A)}(L) ⊆ Ψ`, then `[L]^Ψ ∈ ℒ_𝔉(A)`.
>
> ## Clause-by-clause
>
> 1. *`A` an S-sorted set.*
>    Lean: `A : SSet S` (readback line 17). ✓
>
> 2. *`L ∈ ℒ_𝔉(A)`.*
>    Lean: `L ∈ langFormationOf Sig G A` (line 117). ✓
>
> 3. *`Ψ ∈ Cgr(T_Σ(A))` (Ψ is a congruence on the term algebra).*
>    Lean: the hypothesis is `Ψ : SortedEqv (Term Sig A)` with **no** congruence
>    requirement (line 118). The contract's hypothesis on Ψ is strictly stronger,
>    so the Lean claim is strictly more general. **Stronger** (formal_stronger).
>
> 4. *`Ω^{T_Σ(A)}(L) ⊆ Ψ`.*
>    Lean: `congCogenerated Sig (termAlg Sig A) L ≤ Ψ` (line 119), with
>    `congCogenerated` the greatest congruence saturating `L` and `≤` the
>    pointwise-inclusion `sortedEqvLe` (line 120). ✓
>
> 5. *Conclusion `[L]^Ψ ∈ ℒ_𝔉(A)`.*
>    Lean: `sat Ψ L ∈ langFormationOf Sig G A` (line 120), where `sat Ψ L` is the
>    Ψ-saturation `[L]^Ψ`. ✓
>
> The proof sketch in the contract (extract Φ, use Φ ⊆ Ω(L) ⊆ Ψ and PropIncSat)
> is mirrored in the readback's stated proof via `sat_antitone` and `sat_idem`
> (lines 121–125); it does not add a separate clause.
>
> Contract clauses with no Lean counterpart: none.
>
> Verdict: formal_stronger — Lean proves the conclusion for an arbitrary sorted
> equivalence Ψ, dropping the contract's hypothesis that Ψ be a congruence on
> `T_Σ(A)`.

