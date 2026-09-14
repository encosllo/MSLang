# Pilot representation (encoding) record -- DRAFT, UNAUDITED

> **Status: draft proposal, not an accepted representation.** Architecture.md
> Section 11.5 requires an encoding audit by the encoding auditor *before* any
> statement audit that depends on this encoding. Nothing here may be treated as
> `faithful` yet; the anticipated honest outcome is `faithful-with-caveat` with
> the residuals listed in Section 6. Drafted by `agent:opencode`; decisions
> about the carrier model are reserved to the author (Sections 11.5, 16.4).

This record fixes how the paper's foundational notions are to be encoded in
Lean 4 / Mathlib for the **pilot cluster**

    { B-D002, B-D003, B-D005, B-D006, B-D009, B-D014, B-D015,
      B-P002, B-P003, B-C001, B-C002 }

which is the dependency closure of the chosen pilot `B-D014`. It is refined per
definition cluster (Section 6); a different cluster may add a record.

## 1. The paper's foundation (as used by this cluster)

From `MSEilenberg.tex` (lines cited are the source, latin1):

- Underlying theory is **ZFSK**: ZFC plus a fixed Grothendieck universe
  `\boldsymbol{\mathcal{U}}` (line 187). Elements of `𝒰` are *small sets*;
  subsets of `𝒰` are *large* (classes). `Set` is the category of small sets.
- `S` is a set of sorts in `𝒰`, fixed once and for all (line 207).
- An **`S`-sorted set** is a mapping `A = (A_s)_{s∈S}` from `S` to `𝒰`
  (`B-D002`). An `S`-sorted mapping `f : A → B` is a family `(f_s)` with
  `f_s : A_s → B_s`; `Hom(A,B) = ∏_s Hom(A_s, B_s)`.
- The **product** `∏_i A^i` is componentwise (`B-D003`); all set-theoretic
  operations (`×`, `⊔`, `⋃`, `∩`, `\complement_A`, `-`) are componentwise
  (line 245).
- **Subset**: `A ⊆ B` iff `A_s ⊆ B_s` for all `s`; `Sub(A)` is the set of
  `S`-sorted `X` with `X ⊆ A` (`B-D005`).
- **Delta of Kronecker** in `t`: `δ^t_s = 1` if `s = t`, else `∅` (`B-D006`).
- **Support** `supp_S(A)` and **finite** are recalled in this section
  (`B-D008`, `B-D009`); the cluster uses `supp_S`.
- An **`S`-sorted equivalence relation** `Φ` on `A` is a subset
  `Φ ⊆ A × A` whose components `Φ_s` are equivalence relations; `Eqv(A)` is an
  algebraic closure system, `∇^A` / `Δ^A` its top / bottom (`B-D014`).
  Saturation `[X]^Φ_s = ⋃_{x∈X_s}[x]_{Φ_s}`, and `Φ-Sat(A) = {X | X=[X]^Φ}`
  (`B-D014`). `A/Φ = (A_s/Φ_s)` and `pr^Φ` the canonical projection.
- The cluster's propositions/corollaries (`B-P002`, `B-P003`, `B-C001`,
  `B-C002`) quantify over `A`, `Φ`, `Ψ ∈ Eqv(A)`, `X ⊆ A`.

## 2. Proposed encoding

We use Mathlib's `Set`, `Setoid`, `Set.image`/`preimage`, and `Quotient`.

| Paper | Proposed Lean | Notes |
|---|---|---|
| set of sorts `S ∈ 𝒰` | a type `S : Type u` | sorts carry no structure |
| `S`-sorted set `A : S → 𝒰` | `A : S → Set U` for a fixed `U : Type u` | **fixed ambient**, see D2 |
| `A ⊆ B` | `∀ s, A s ⊆ B s` | pointwise, exact |
| `A × B` | `fun s => Set.prod (A s) (B s)` | componentwise, exact |
| `⋃`, `∩`, `\-`, `\complement_A` | `Set.union`, `Set.inter`, `Set.sdiff`, `fun s => A s \ X s` | pointwise, exact |
| `δ^t` | `fun s => if s = t then Set.univ else ∅` | componentwise |
| `supp_S(A)` | `{s | (A s).Nonempty}` | exact (`B-D009`) |
| `Sub(A)` | `{X : S → Set U // ∀ s, X s ⊆ A s}` | or a bundled predicate |
| `S`-sorted equivalence `Φ ⊆ A×A` | `Φ : ∀ s, Setoid (A s)` | **structure vs relation**, see D4 |
| `Φ ⊆ Ψ` (order on `Eqv`) | pointwise refinement of setoids | bridge `setoid_le_iff` |
| `[X]^Φ` | `fun s => {a | ∃ x ∈ X s, (Φ s).r x a}` | exact |
| `X` is `Φ`-saturated | `X = [X]^Φ` | fixed point |
| `A/Φ`, `pr^Φ` | `fun s => Quotient (Φ s)`, `Quotient.mk''` | representative-based |

## 3. Scope of formalization

- `B-D002`, `B-D003`, `B-D005`, `B-D006`, `B-D009`, `B-D014`, `B-D015`:
  definitions, `full` scope (a bridge to the Mathlib notion where one exists).
- `B-P002`, `B-P003`, `B-C001`, `B-C002`: `full` scope (statement and proof).
- Everything outside the cluster is out of this record's scope.

## 4. Bridge obligations (to be proved once Lean builds)

Each turns a judgment into formal evidence (Section 7.4). None is proved yet.

1. `sat_eq_preimage` -- `[X]^Φ = (pr^Φ)⁻¹[pr^Φ[X]]` (Remark `B-R006`).
2. `setoid_le_iff` -- pointwise setoid refinement coincides with inclusion of
   the underlying relations, so the paper's `Φ ⊆ Ψ` is the Lean order.
3. `sat_antitone` -- `Φ ⊆ Ψ → Ψ-Sat(A) ⊆ Φ-Sat(A)` (Corollary `B-C001`), the
   first formal target; it follows from `B-P002`.
4. `card_le_one_iff` -- `Nat.card`-style `≤ 1` coincides with `Subsingleton`.
5. `delta_support` -- `supp_S(δ^t)` and the `B-P003`/`B-R008` identities.

## 5. Residual caveats (anticipated, for the encoding audit)

- **D1 (universe/smallness).** ZFSK smallness and the set/class distinction are
  not tracked; Lean universe levels are only a rough analogue. Consequences
  about `𝒰`-large objects are out of scope for the pilot (none occur in the
  cluster).
- **D2 (carrier model).** Components are subsets of a single fixed ambient `U`
  rather than arbitrary `𝒰`-small carriers. Componentwise operations coincide
  on subobjects of a common ambient; cross-family unions of unrelated carriers
  are not directly expressible. This is the caveat named in Architecture.md
  Section 11.5 and is the main reason this record is expected to be
  `faithful-with-caveat`, not `faithful`.
- **D3 (complement).** `\complement_A X` is the relative complement in `A_s`;
  if a downstream block uses an absolute complement this must be revisited.
- **D4 (structure vs relation).** Lean `Setoid` is a structure carrying proofs,
  not a subset of `A_s × A_s`; the correspondence is mediated by bridge 2.
- **D5 (quotients).** `Quotient` is a Lean inductive, not the paper's set of
  equivalence classes; bridges may need `Classical.choice`.
- **D6 (logic).** The paper is classical; Lean proofs may use `Classical.choice`
  in addition to `propext`/`Quot.sound`, which are within the permitted axiom
  set (Section 15.5).
- **D7 (empty sorts).** `S` and components may be empty; `Subsingleton` and
  `Subtype` already permit this, but bridge lemmas must not assume inhabitation
  without saying so.

## 6. What is required before use

1. An **encoding audit** (Section 11.5): confirm Section 2, resolve D3/D5, and
   type the outcome `faithful` or `faithful-with-caveat` (with residuals).
2. A content hash of this file recorded as the representation input of every
   dependent evidence record (class **C6** on any change).
3. Author acceptance of the carrier model (D2) -- a reserved decision.

Until then, `scripts/closure.py` correctly refuses to emit review or
correspondence closures for the pilot (`representation not resolved`).
