# Pilot representation (encoding) record -- dependent-type carrier model

> **Status: accepted by the author (representation change, class C6).** The
> author chose the dependent-type carrier (`SSet S := S → Type u`) over the
> earlier fixed-ambient (`S → Set U`) model. Supersedes the draft recorded in
> `E-000002`/`E-000013`; a fresh encoding audit is required (Section 11.5).

This record fixes how the paper's foundational notions are encoded in Lean 4 /
Mathlib for the **pilot cluster**

    { B-D002, B-D003, B-D004, B-D005, B-D006, B-D009, B-D014, B-D015,
      B-P002, B-P003, B-C001, B-C002, B-R006, B-R008 }

## 1. The paper's foundation

- Underlying theory is **ZFSK**: ZFC plus a fixed Grothendieck universe `𝒰`.
  Elements of `𝒰` are *small sets*. `S` is a set of sorts in `𝒰`.
- An **`S`-sorted set** is a mapping `A = (A_s)_{s∈S}` from `S` to `𝒰`; an
  `S`-sorted mapping `f : A → B` is a family `(f_s)` with `f_s : A_s → B_s`.
- Subset `A ⊆ B` iff `A_s ⊆ B_s`; `Sub(A)` is the set of `X` with `X ⊆ A`.
- `δ^t_s = 1` if `s = t` (the terminal singleton), else `∅`.
- `supp_S(A) = {s | A_s ≠ ∅}`.
- An `S`-sorted equivalence `Φ ⊆ A × A` with components equivalence relations;
  `[X]^Φ_s = ⋃_{x∈X_s}[x]_{Φ_s}`; `X` `Φ`-saturated iff `X = [X]^Φ`;
  `A/Φ`, `pr^Φ` the quotient and projection.

## 2. Encoding (dependent-type carrier)

| Paper | Lean | Notes |
|---|---|---|
| set of sorts `S ∈ 𝒰` | `S : Type u` | |
| `S`-sorted set `A : S → 𝒰` | `SSet S := S → Type u` | **carrier = a family of types** |
| component `A_s` | `A s : Type u` | a *type*, not a subset of an ambient |
| `S`-sorted mapping `A → B` | `SortedMap A B := ∀ s, A s → B s` | |
| `X ⊆ A`, `Sub(A)` | `Sub A := ∀ s, Set (A s)` | componentwise predicates |
| `A ⊆ B` (subobjects) | `Subset X Y := ∀ s, X s ⊆ Y s` | |
| componentwise `∏`, `⊔`, `×` | `∀ i, …`, `Sum`, `Prod` | products are types, **in class** |
| `δ^t` | `fun s => if s = t then PUnit else PEmpty` | **genuine singleton/empty** |
| `supp_S(A)` | `{s | Nonempty (A s)}` | |
| `1^S` / `∅^S` | `fun _ => PUnit` / `fun _ => PEmpty` | faithful |
| `S`-sorted equivalence `Φ` | `SortedEqv A := ∀ s, Setoid (A s)` | |
| `Φ ⊆ Ψ` | pointwise relation inclusion | definitional (`setoid_le_iff`) |
| `[X]^Φ` | `fun s => {a | ∃ x ∈ X s, (Φ s).r x a}` | |
| `X` `Φ`-saturated | `IsSat Φ X := sat Φ X = X` | |
| `A/Φ`, `pr^Φ` | `fun s => Quotient (Φ s)` (**in `SSet S`**), `Quotient.mk` | **stays in the object class** |
| `∇^A` | `nabla A` (universal relation) | |
| `Ker(f)` | `ker f` (componentwise kernel pair) | |

## 3. Bridge obligations (proved unless noted)

1. `setoid_le_iff` -- `Mslang.setoid_le_iff` (definitional).
2. `sat_antitone` -- `Mslang.sat_antitone`.
3. `card_le_one_iff` -- `Mslang.card_le_one_iff` (`Subfinal ↔ encard ≤ 1`).
4. `delta_support` -- `Mslang.supp_delta` (`supp (δ^t) = {t}`).
5. `sat_eq_preimage` -- `Mslang.sat_eq_preimage`.

## 4. Residual caveats

- **R-universe (universe/smallness).** The Grothendieck universe and the
  small/large distinction are approximated by Lean universe levels; `𝒰`-large
  consequences are out of scope. Unchanged by this encoding.
- **R-setoid (structure vs relation).** `Setoid` is a structure carrying
  proofs, not literally a subset of `A_s × A_s`; mediated by `setoid_le_iff`
  and `eqvClass_eq_iff`. Bounded.
- **R-classical.** The paper is classical; Lean proofs use `propext`,
  `Classical.choice`, `Quot.sound`, within the permitted set.
- **R-ext.** Extensionality of families needs `funext`.

**Resolved by this encoding** (previously residuals of the ambient model):
- **R-delta** -- `δ^t` is now a genuine `PUnit`/`PEmpty` family, not `Set.univ`.
- **R-quotient** -- `A/Φ = fun s => Quotient (Φ s)` is again an `SSet S`, so the
  quotient stays in the object class.
- **R-product** -- `∏_i A^i` is a dependent function type, in class.
- **R-complement** -- componentwise complement is `(X s)ᶜ` inside `A_s`
  (`complA`), relative by construction.

## 5. What is required before use

1. A fresh **encoding audit** (Section 11.5) of Section 2, typed
   `faithful` / `faithful-with-caveat` (with the residuals above).
2. A content hash of this file recorded as the representation input of every
   dependent evidence record (class **C6**).
