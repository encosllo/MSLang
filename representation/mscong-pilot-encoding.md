# M6 pilot representation (encoding) record -- MSCong basic terms

> **Status: draft, unaudited.** The M6 pilot's encoding of the `MSCong.tex`
> §2.3--3.1 notions it maps. This is *not* evidence and must not be treated as
> authoritative; the encoding audit (Section 11.5) is recorded as a
> representation-layer evidence record under `evidence/mscong/`.

This record fixes how the paper's foundational notions are encoded in Lean 4 /
Mathlib for the **M6 pilot cluster**

    { B-D101, B-D102, B-P101, B-P102, B-P103, B-P104 }

## 1. The paper's foundation

The pilot sits on the same many-sorted foundation as `MSEilenberg.tex` and
reuses `Mslang`'s vocabulary (see `representation/pilot-encoding.md`): an
`S`-sorted set `A = (A_s)_{s∈S}`, an `S`-sorted map, a signature
`Σ = (Σ_{w,s})`, `Σ`-algebras, and the free `Σ`-algebra `T_Σ(X)`.

The paper's §2.3 recognizability notions are:

- a congruence `Φ` on `A` is of **finite index** (`fi`) iff `A/Φ` is a finite
  many-sorted set (finite support and finite carriers on the support);
- `L ⊆ A↾_T` is `T`-**recognizable** iff `L = (f↾_T)⁻¹[M]` for a homomorphism
  `f : A → B` into a **finite** `Σ`-algebra `B` and a subset `M ⊆ B↾_T`
  (`T = S` gives `Rec(A)`, `T = {s}` gives `Rec_s(A)`);
- `Cgr_fi(A)` is a filter when `supp_S(A)` is finite.

§3.1 proves the singleton languages `{x}`, `{σ}`, `{σ((x_i))}` recognizable.

## 2. Encoding

| Paper | Lean | Notes |
|---|---|---|
| `S`-sorted set `A` | `Mslang.SSet S := S → Type u` | dependent-type carrier |
| free `Σ`-algebra `T_Σ(X)` | `Mslang.termAlg Sig X : Alg Sig` | `Mslang.Term` |
| `Σ`-homomorphism `f : A → B` | `Mslang.AlgHom` (`IsAlgHom`) | |
| congruence `Φ` | `Mslang.SortedEqv A` (`Setoid` per sort) | |
| `Φ` of **finite index** | `Mslang.IsFiniteIndex Φ` | |
| `Cgr_fi(A)` filter | `Mslang.IsFiniteIndex_of_le`, `IsFiniteIndex_inf` | |
| `L ∈ Rec(A)` | `Mscong.Recognizable Sig A L` | `L : Sub A.1` |
| `L ∈ Rec_s(A)` | `Mscong.RecognizableAt Sig A s L` | `L : Set (A.1 s)` |
| `L ∈ Rec_T(A)` (`T ⊆ S`) | `Mscong.RecognizableOn Sig A T L` + `zeroExtension` | |

The recognizability predicates are *defined* by the existence of a **finite**
recognizing algebra (`Mslang.FiniteAlg`) and a homomorphism, exactly as the
paper's definition, rather than by the `Ω`-saturation characterization; the
equivalence with finite-index saturation is a proved bridge
(`recognizable_iff_exists_finiteIndex_sat`).

## 3. Bridge obligations (proved unless noted)

1. `recognizable_iff_exists_finiteIndex_sat` -- `Rec` iff some finite-index
   congruence saturates (the paper's Proposition `PRecog`, stated in M1).
2. `recognizableAt_iff` -- `Rec_s` iff the Kronecker-concentrated language is
   `Rec` (the paper's `s-Rec iff Rec`).
3. `recognizable_union` / `_inter` / `_compl` -- Boolean closure
   (`Rec is Bool`).
4. `recognizable_inverseImage` -- inverse images along homomorphisms.
5. `finiteAlg_twoAlg` -- the recognizing algebra `2^S` is finite when `S` is
   finite (the §3.1 Assumption).

## 4. Residual caveats

- **R-universe.** Grothendieck universe / smallness approximated by Lean
  universe levels, as for `mslang`; `𝒰`-large consequences out of scope.
- **R-classical.** The paper is classical; Lean proofs use `propext`,
  `Classical.choice`, `Quot.sound` (permitted set).
- **R-finite.** The paper's "finite many-sorted set" is `Mslang.FiniteSSet`
  (finite support and finite carriers on the support), not `Fintype`: the
  bridge `finiteSSet_iff` records this.
- **R-congruence.** The paper's finite-index object is a *congruence* on `A`
  (operation-compatible), while `Mslang.SortedEqv A` is a bare per-sort
  `Setoid`; compatibility with the signature operations is expressed
  separately (`Mslang.IsCongruence`). The pilot's `IsFiniteIndex` is stated for
  a `SortedEqv`, so the encoding is broader than the paper's `Cgr_fi(A)` unless
  a compatibility hypothesis is carried; the correspondence audit for `B-D101`
  records this explicitly.
- **R-first.** The pilot's `Filter` block (`B-P101`) states the paper's
  proposition, but its Lean counterpart maps to the two closure facts
  (`IsFiniteIndex_of_le` upward closure, `IsFiniteIndex_inf`) rather than a
  single bundled "filter" declaration; the two facts alone do not discharge the
  full filter statement (top and nonemptiness under finite support are not
  included), so the correspondence audit types this as a partial match.
- **R-restriction.** The paper's `Rec_T(A)` for `T ⊊ S` is intrinsically about
  `A↾_T`; the Lean `RecognizableOn` is stated through a `zeroExtension` to all
  of `S`. If the extension is only a technical device to reuse `Sub A.1` the
  encoding is faithful, but the interaction of `M`/`L` outside `T` is not
  certified here; carried as a residual.

## 5. What is required before use

1. A fresh **encoding audit** (Section 11.5) of Section 2, typed `faithful` /
   `faithful-with-caveat` (with the residuals above).
2. A content hash of this file recorded as the representation input of every
   dependent evidence record (class **C6**).
