# Tasks

## 1. Hall-algebra structure

- [x] 1.1 Defined `derivPlace (φ : S → T) (w : List S) : SSet T` in
  `lean/Mscong/Hall.lean` as `ULift {i : Fin w.length // φ (w.get i) = t}` (the
  `Type u` lift of M4's `Yplus` `Sum.inr` summand); `abbrev` so it unfolds.
- [x] 1.2 Defined the `HallAlg S` structure (`carrier`, `pi`, `xi`, `H1`, `H2`,
  `H3`), with `H3` the manuscript's associativity equation.

## 2. Hall algebra of operations (`Op_H`)

- [x] 2.1 Defined `OpH (A : SSet S) : HallAlg S` (carrier `A_w → A_s`,
  `pi` projection, `xi` composition with the tuple map `⟨g_i⟩`).
- [x] 2.2 Proved `H1`, `H2`, `H3` for `OpH` (extensional, `rfl`).

## 3. Hall algebra of terms (`Ter_H`)

- [x] 3.1 Defined `termSubst` and its equations (`termSubst_var`,
  `termSubst_op`), `termSubst_cast`, `termSubst_comp`, `term_var_cast`,
  `termLift_id`/`termSubst_id`, `substMap`, and `TerH (Σ) : HallAlg S`
  (carrier `Term Σ (derivPlace id p.1) p.2`).
- [x] 3.2 Proved `H1` and `H2` for `TerH` (`H2` via `substMap_pi` +
  `termSubst_id`).
- [x] 3.3 Proved `H3` for `TerH` via `termSubst_comp` and a pointwise map
  equality using `termSubst_cast`.

## 4. Derived algebras and Lemma `L:aux`

- [x] 4.1 Defined `derivedAlg`, `pMap`, `pSharp`.
- [x] 4.2 Proved `derivedAlg_eval` (Lemma `L:aux`) by `Term.rec` (`H1` in the
  variable case, `H3` in the operation case).

## 5. Derivors and the hyperderivor bridge

- [x] 5.1 Defined `Derivor φ Sig Lam` with
  `d : Σ_{w,s} → Term Λ (derivPlace φ w) (φ s)`, `countPlaceholderD`,
  `Derivor.IsLinear`, and `placeIncl` (`↓φ*(w) ↪ Y ∪ ↓φ*(w)`).
- [x] 5.2 Proved `Derivor.toHyperderivor` (`c` is `d` composed with `placeIncl`
  via `termSubst`).
- [x] 5.3 Proved `countPlaceholder_toHyperderivor` and
  `Derivor.toHyperderivor_isLinear` (linearity preserved).

## 6. Recognizability counterparts

- [x] 6.1 Proved `PRecDerivor` (inverse image; from M4 `PRecH`).
- [x] 6.2 Proved `PRecLinDerivor` (direct image under a linear derivor; from M4
  `PRecLH`).

## 7. Infrastructure discipline and gate

- [x] 7.1 `lean/declarations.mscong.json` still maps no declarations, no evidence
  is written under `evidence/mscong/`; `scripts/projects.py --check` and
  `--collisions` pass.
- [x] 7.2 The default project is untouched: `scripts/projects.py
  --check-baseline` passes and `scripts/check_all.sh --fast` is green.
- [x] 7.3 `python3 scripts/lean_audit.py --project mscong`: **0 declarations, 0
  warnings, 0 `sorry`, ok=True**.

## 8. Docs and state

- [x] 8.1 Record the M5 session in `STATE.md` (what was formalized, axioms, the
  deferred category-theoretic layer, next steps) and add the M5 journal event
  (`journal/mscong.jsonl`, `EV-000156`; `reports/mscong/bundle.md` regenerated).
- [x] 8.2 Note in `STATE.md` that the correspondence audit (M6) remains open and
  that the free-Hall-algebra isomorphism / `Sig_d` / `Alg_d` are deferred as an
  explicit author-visible caveat.

  A stale test premise surfaced and was fixed: `scripts/projects_test.py`
  asserted "mscong has no identifiers yet", which the M5 journal event makes
  false; the check now requires no *block* or *evidence* identifiers (journal
  events may accrue).
