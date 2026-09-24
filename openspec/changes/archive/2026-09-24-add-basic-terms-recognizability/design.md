# Design

## Context

See `proposal.md` — Why. Current state that shapes the approach:

- M1 (`formalization/mcong-recognizability`, archived) supplies the predicates
  `Recognizable`/`RecognizableAt` and their finite-index characterizations in
  `lean/Mscong/Recognizable.lean`, plus the finite-index calculus, all over an
  arbitrary `Σ`-algebra `A`.
- `Mslang` supplies the free-algebra layer: `Term`/`termAlg` (the inductive
  `T_Σ(X)` with a recursor), `termEta` (the insertion `η^X`), `termLift` (the
  homomorphic extension of a sorted map, with `termLift_isAlgHom`), and
  `termLift_unique`; `subAlg`/`Sg`/`TAlg` give a word-based presentation but only
  a `Prop`-valued membership.
- `MSCong.tex` §3.1 proves `PRecVar` (a variable), `PRecConst` (a constant), and
  `PRecOp` (an operation symbol applied to a family of variables), under the
  Assumption that `S` is finite. Each proof exhibits a *finite* recognizing
  algebra and a homomorphism whose fibre over a distinguished element is the
  singleton language.
- `mscong` is still a scaffold (`ingested: false`); `lean/declarations.mscong.json`
  is empty and `evidence/mscong/` holds only `.gitkeep`.

## Goals / Non-Goals

**Goals:**

- Formalize `PRecVar`, `PRecConst`, `PRecOp` in `Mscong` over the inductive free
  algebra `Term_Σ(X)`, reusing M1's predicates.
- Provide the finite recognizing algebra `2^S` (and the σ-discriminating /
  variable-counting variants the three proofs need), finite because `S` is
  finite.
- Keep it **unmapped infrastructure**: no block IDs, no evidence, no change to
  `mslang`, `mscong` stays `ingested: false`.
- Build clean, `sorry`-free, within the permitted axiom set.

**Non-Goals:**

- Substitutions / iterations / quotients (`PRecSubs`, `PRecIt`, `PRecQ`) — M3.
- Tree homomorphisms (`PRecH`, `PRecLH`, `PRecILH`) — M4.
- The statement that the recognizable languages form a `Σ`-algebra (the
  synthesis the subsection feeds into); it belongs with the operator
  milestones, once their closure properties exist.
- Any manuscript edit, block-ID minting, evidence record, or mapping.

## Decisions

### D1. Work on the inductive `Term`, not the word-based `TAlg`

Recognizability is stated over a genuine `Alg` and the proofs proceed by
induction on terms; `Mslang.Term` is an inductive family with a recursor
(`termLift`) and `termAlg` packages it as an `Alg`. `TAlg` (the `Sg`-generated
subalgebra of `W_Σ(X)`) has only a `Prop`-valued membership (`MemSg`) and no
recursor, so it supports only uniqueness. Rationale: the free-algebra layer
`Mslang/Term.lean` was created exactly for this. This also matches the paper:
`T_Σ(X)` is the free algebra, and `Term` is that algebra.

### D2. One fixed finite algebra `2^S`, specialized per proposition

Let `2^S` be the `Σ`-algebra with carrier `Fin 2` at every sort (`2` is
`{0,1}`), where every operation is the constant map to `0`. It is finite when
`S` is finite (its support is `S`, each component `Fin 2`). A recognizing
homomorphism is `termLift Sig X (2^S).2 g`, the free extension of a chosen
`g : X → 2^S`. The three proofs differ only in `g` and in the interpretation of
the *one distinguished* operation, so the design shares the carrier and varies
the structure:
- `PRecVar`: all operations constant `0`; `g` is the characteristic map of
  `{x}` at `s` (needs `classical` for `DecidableEq (X s)`).
- `PRecConst`: the distinguished constant `σ : Σ_{λ,s}` maps the unique element
  of `2_λ` to `1`, every other operation to `0`; `g` is constantly `0`.
- `PRecOp`: the paper's counting algebra `K` (`K_t = k_t + 1`, `K_s = k_s + 2`,
  `k_t` the number of distinct variables of sort `t` in `(x_i)`) with the
  distinguished `σ` detecting the exact argument tuple; `g` sends a variable in
  the image of `(x_i)` to its `φ`-image and every other variable to the default
  `k_t`.

Rationale: matches the paper's proof and keeps the `PRecVar`/`PRecConst` cases
small. Alternative (one counting algebra for all three) rejected — needless
`Fin` arithmetic for the easy cases.

### D3. Recognize a singleton as the fibre of `{1}`

For each proposition the goal is `RecognizableAt Sig (termAlg Sig X) s {t}` for a
specific term `t`. We supply `B := (the chosen finite algebra)`, `f := termLift
… g`, and `M := {1}` at `s`, and prove `termLift … g s P = 1 ↔ P = t` by
induction on `P`. The `op` case uses that every operation except the
distinguished one is constant `0` and `0 ≠ 1`, and that the distinguished
operation's value is `1` exactly on the target tuple. `RecognizableAt` (rather
than `Recognizable`) is the natural target; full-language recognizability
follows by `recognizableAt_iff` (`δ^{s,{t}} ∈ Rec`) if wanted.

### D4. Unmapped infrastructure

No declaration is added to `lean/declarations.mscong.json`; the module is built
by the `Mscong` default target and audited by `lean_audit.py --project mscong`.
Maps and evidence are a later change (as in M1/D5).

### D5. Module layout

The results go in a new `lean/Mscong/BasicTerms.lean`, imported by
`lean/Mscong/Main.lean` (whose header already names `PRecVar`/`PRecConst`/
`PRecOp` as M2). The two-element algebra and its finiteness live in the same
module unless they grow enough to warrant `Mscong/Two.lean`. Rationale: keeps the
compile-time graph shallow (`Mscong → Mslang`) and modules focused.

## Risks / Trade-offs

- **`PRecOp` counting bookkeeping** (`k_t`, `Fin (k_t + c)` injections, the
  `φ`-bijection) is the fiddly part. Mitigation: isolate it in its own section;
  if it proves too heavy, the fallback is to state the counting only over the
  *finite* set `Im(x)` and use `Finset`/`Fintype` rather than raw `Fin`
  arithmetic.
- **Decidability**: comparing `τ = σ` and `y = x` needs `classical`
  (`Classical.decEq`), which the permitted axiom set allows; the gate records
  it.
- **`Fin 2` vs `Bool`**: `Bool` is finite without any hypothesis; `Fin 2`
  matches the paper's `2 = {0,1}` and keeps `0 ≠ 1` cheap. Either is acceptable;
  choose `Fin 2`.
- **Scope creep**: the closure of the recognizable languages under the `Σ`
  operations is adjacent and tempting; explicitly out of scope (Non-Goals).

## Migration Plan

1. Add `lean/Mscong/BasicTerms.lean` with `2^S`, its finiteness, and the three
   results, in dependency order.
2. Import it from `lean/Mscong/Main.lean`.
3. Iterate with a targeted `lake build Mscong.BasicTerms`.
4. Run the gate: `scripts/check_all.sh --fast`, and one `scripts/check_all.sh`
   at close; optionally `lean_audit.py --project mscong`.
5. Record the milestone in `STATE.md`; leave `mscong.ingested: false`.

Rollback: additive to one new `Mscong` module; reverting the commit restores the
scaffold.

## Open Questions

- Should `PRecOp`'s counting be stated with `Fintype (Im x)` (cleaner) or the
  paper's explicit `k_t` (`Fin (k_t + c)`)? Decide during implementation based
  on which yields the cleaner induction.
- When the calculus is mapped (a later change), are the §3.1 items given
  `\blockid`s in `MSCong.tex`, or registered as `proposed` first?
