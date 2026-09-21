# Correspondence audit transcript -- `B-D025`

Protocol: Architecture.md Section 11.2, two-stage blind. First audit of this
block's correspondence layer, run in Session 119 in section batches (one fresh
agent per stage-batch; no agent was told the expected answer). Stage 1 saw only
the Lean declarations and their definitions (with definition bodies); stage 2 saw
only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.quotOp`, `Mslang.quotAlg`, `Mslang.prAlg`, `Mslang.quotOp_mk`, `Mslang.isAlgHom_prAlg` (`lean/Mslang/Congruence.lean`)
- **Contract:** Definition `B-D025`, section "Preliminaries.".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000349`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** the stage agents share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> # B-D025 — quotient algebra by a congruence
>
> Ambient data: sort set `S : Type u`. `SSet S := S → Type u`; `Signature S :=
> List S × S → Type u`; `SortedMap A B := ∀ s, A s → B s`; `wordProd A w :=
> (i : Fin w.length) → A (w.get i)`; `finOp A w s := wordProd A w → A s`;
> `AlgStruct Sig A := (p : List S × S) → Sig p → finOp A p.1 p.2`; `Alg Sig` is the
> bundled algebra (carrier plus structure). `IsAlgHom Sig FA FB f` for
> `f : SortedMap A B` means: for all `p = (w,s)`, `σ`, `a : wordProd A w`,
> `f s (FA p σ a) = FB p σ (fun i => f (w.get i) (a i))`.
>
> - `SortedEqv A := ∀ s, Setoid (A s)` — a sortwise equivalence relation (each
>   `Φ s` is a `Setoid` on `A s`, i.e. a relation `r` that is reflexive, symmetric,
>   transitive).
> - `pr Φ s : A s → Quotient (Φ s) := fun x => Quotient.mk (Φ s) x` — the quotient
>   map at sort `s`.
> - `quot Φ : SSet S := fun s => Quotient (Φ s)` — the quotient sorted set.
> - `IsCongruence Sig F Φ : Prop := ∀ p σ a b, (∀ i, (Φ (p.1.get i)).r (a i) (b i)) →
>   (Φ p.2).r (F p σ a) (F p σ b)` — `Φ` is a congruence: whenever two tuples `a`, `b`
>   of the same arity are pointwise `Φ`-equivalent at the input sorts, their operation
>   images are `Φ`-equivalent at the output sort.
>
> ## Definitions
>
> - `quotOp Sig F Φ p σ : finOp (quot Φ) p.1 p.2`, defined
>   `fun a => Quotient.mk (Φ p.2) (F p σ (fun i => Quotient.out (a i)))`. An operation
>   on the quotient: given representatives `a i : Quotient (Φ (w.get i))`, choose for
>   each a representative via `Quotient.out`, apply `F`, and take the class. Well
>   definedness (independence of the choices of representatives) is the content of
>   `quotOp_mk`. `noncomputable` because of `Quotient.out`.
> - `quotAlg Sig F Φ (_hΦ : IsCongruence Sig F Φ) : Alg Sig :=
>   ⟨quot Φ, fun p σ => quotOp Sig F Φ p σ⟩`. The quotient algebra: carrier `quot Φ`,
>   operations `quotOp`. The congruence hypothesis `hΦ` is an argument only to record
>   that the construction is well defined; the body does not use it (so it is
>   essentially proof-irrelevant data).
> - `prAlg Sig F Φ hΦ : SortedMap A (quotAlg Sig F Φ hΦ).1 := pr Φ` — the quotient
>   projection map `pr Φ`, packaged as a sorted map into the quotient algebra.
>
> ## Theorems
>
> - `quotOp_mk Sig F Φ hΦ p σ a :
>   quotOp Sig F Φ p σ (fun i => Quotient.mk (Φ (p.1.get i)) (a i)) =
>     Quotient.mk (Φ p.2) (F p σ a)`.
>   The quotient operation, evaluated on the classes of an actual tuple `a`, returns
>   the class of `F p σ a` (no `out` re-entry). Proof: push to a quotient equality
>   `Quotient.eq.mpr`, then apply the congruence `hΦ` between the chosen representatives
>   `Quotient.out (Quotient.mk (Φ (w.get i)) (a i))` and `a i`; the needed pointwise
>   relation holds since `Quotient.out_eq` relates `out (mk (a i))` to `mk (a i)`,
>   hence (via `Quotient.exact`) to `a i`.
> - `isAlgHom_prAlg Sig F Φ hΦ : IsAlgHom Sig F (quotAlg Sig F Φ hΦ).2 (prAlg Sig F Φ hΦ)`.
>   The quotient projection `pr Φ` is an algebra homomorphism from `(A, F)` to the
>   quotient algebra: for all `p σ a`,
>   `Quotient.mk (Φ p.2) (F p σ a) = quotOp Sig F Φ p σ (fun i =>
>   Quotient.mk (Φ (p.1.get i)) (a i))`. This is exactly the reverse direction of
>   `quotOp_mk`.
>
> Mathematically: `quotAlg` is the quotient of `A` by the congruence `Φ`; `quotOp`
> makes the operations well defined on classes, `quotOp_mk` records the computation
> rule on representatives, and `prAlg` is the canonical surjective homomorphism
> `A ↠ A/Φ`.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> # B-D025 verdict — quotient algebra by a congruence
>
> Clause-by-clause comparison of the contract (B-D025.tex) against the read-back.
>
> 1. "$\Phi \in \mathrm{Cgr}(\mathbf A)$" (a congruence). Lean `IsCongruence Sig F Φ := ∀ p σ a b, (∀ i, Φ(w_i).r (a i) (b i)) → Φ(s).r (F p σ a) (F p σ b)`. Covered.
> 2. "$\mathbf A/\Phi = (A/\Phi, F^{\mathbf A/\Phi})$ with $F_\sigma$ sending $([a_i])$ to $[F_\sigma((a_i))]$." Lean `quotAlg` carrier `quot Φ` and operations `quotOp`, whose value on classes of a representative tuple is computed by `quotOp_mk` to be `Quotient.mk (Φ s) (F p σ a)`. Covered (well-definedness via `Quotient.out` discharged by `quotOp_mk`).
> 3. "The canonical projection $\mathrm{pr}^\Phi : \mathbf A \to \mathbf A/\Phi$ is the homomorphism determined by the sorted map $\mathrm{pr}^\Phi$." Lean `prAlg` and `isAlgHom_prAlg`. Covered.
>
> Contract clauses with no Lean counterpart: none
>
> Verdict: equivalent — the quotient algebra, its class operation on representatives, and the canonical projection as a homomorphism are all faithfully formalized.

