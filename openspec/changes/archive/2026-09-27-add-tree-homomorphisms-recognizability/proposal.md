# Proposal

## Why

M3 (archived) completed the §3.2–§3.4 substitution / iteration / quotient
recognizability results, so every `Mscong` recognizability theorem that acts
inside a single free algebra `T_Σ(X)` is now formalized. **M4** is the next
roadmap milestone: the §3.5 **tree homomorphisms** (`PRecH`, `PRecLH`), which
move *between* two free algebras `T_Σ(X)` and `T_Ξ(Y)` along a sort map
`φ : S → T`, and are the last recognizability results before the derivors / Hall
algebras of M5.

## What Changes

- Add the **tree-homomorphism** development to `lean/Mscong/TreeHom.lean`
  (currently a scaffold):
  - the base change `Δ_φ` of a `T`-sorted set along `φ : S → T`;
  - the **hyperderivor** `(c, f)` from `(Σ, X)` to `(Ξ, Y)`: a sort map
    `φ : S → T`, an `S⋆ × S`-indexed map `c` sending `σ : Σ_{w,s}` to a term in
    `T_Ξ(Y ∪ ↓φ*(w))_{φ(s)}`, and a sorted map `f : X → T_Ξ(Y)_φ`;
  - the induced `Σ`-algebra structure `c(T_Ξ(Y))` on `T_Ξ(Y)_φ` (the operation
    for `σ` substitutes the argument family into `c(σ)`);
  - the **tree homomorphism** `f♯ : T_Σ(X) → c(T_Ξ(Y))`, the free extension of
    `f`, and its linearity (each placeholder appears at most once);
  - **`PRecH`**: the inverse image of a recognizable language under `f♯` is
    recognizable (no finiteness hypotheses);
  - **`PRecLH`**: for finite `S`, `T`, `Σ`, `X`, the direct image of a
    recognizable language under the `s`-th coordinate of a **linear** tree
    homomorphism is recognizable.
- Implement it as **unmapped Lean infrastructure**, reusing `Mslang`
  (`Term`/`termLift`, the free-algebra universal property, `congCogenerated`,
  saturation, finite index), M1/M2/M3, with no block IDs, no evidence, and no
  change to `mslang`; `mscong.ingested` stays `false`.
- Keep the development clean, `sorry`-free, within the permitted axiom set.

## Capabilities

### New Capabilities

- `formalization/mcong-tree-homomorphisms`: the M4 hyperderivor / tree
  homomorphism development for the `Mscong` project — the definitions, `PRecH`,
  `PRecLH`, reuse of the `Mslang`/M1–M3 foundations, and unmapped-infrastructure
  discipline.

### Modified Capabilities

<!-- None. -->

## Impact

- `lean/Mscong/TreeHom.lean` (scaffold -> development), imported by
  `lean/Mscong/Main.lean`. `lean/declarations.mscong.json` stays empty.
- `STATE.md`: a session entry and the M4 status.
- **No** change to `mslang` artifacts, evidence, hashes, or views; **no** change
  to the gate's behavior; **no** manuscript edit; `mscong` remains
  `ingested: false`.

## Note

`PRecILH` (the iterated/derived tree-homomorphism result) is **commented out** in
`MSCong.tex` (line 3787) and is therefore not part of this change; it can be a
later item if the author revives it.
