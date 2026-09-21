# Correspondence audit transcript -- `B-P034` (cross-model)

Protocol: Architecture.md Section 11.2, two-stage blind. Run in Session 122 as
part of Tier 1 of `blocks/audits/cross-model-audit-brief.md` (second Eilenberg
theorem, finite-algebra/finite-index-congruence restriction of `B-P020`). Both
stages were run as fresh, isolated agents on `claude-sonnet-5` (family
`claude`); the coordinator did not consult any prior `B-P034` verdict before
assembling the stage material (no pre-existing transcript file for this block
existed at `blocks/audits/`).

- **Lean declarations:** `Mslang.finiteSSet_of_isAlgIso`,
  `Mslang.congruenceFormationOf_isFiniteIndex`,
  `Mslang.algebraFormationOfCongruenceFormation_isFiniteAlgebra`,
  `Mslang.formAlgFFormCgrFiIso` (`lean/Mslang/Regular.lean`), with the full
  84-declaration `definition_closure` (statements only, no proofs) per
  `blocks/formal.json`.
- **Contract:** Proposition `B-P034` ("The complete lattices
  `Form_Alg_f(Sigma)` and `Form_Cgr_fi(Sigma)` are isomorphic."), manuscript
  line 2214, plus `B-D040` (finite-index congruence), `B-A001` (S finite),
  `B-D041` (formation of finite-index congruences), `B-D042` (finite
  algebras), `B-D043` (formation of finite algebras), and the summarized use
  of `B-P020`'s `theta_Sigma`/`theta_Sigma^{-1}` in the proof.
- **Outcome:** `equivalent`
- **Recorded as:** see `evidence/` (this file's companion record).
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** cross-model -- both stage agents ran on `claude-sonnet-5`
  (family `claude`), independent of every `deepseek-v4.1-flash` stage.

## Stage 1 -- read-back (fresh agent, Lean only)

> MODEL: claude-sonnet-5 (family: claude)
>
> # B-P034 read-back
>
> **finiteSSet_of_isAlgIso.**
> Fix a signature `Sig` on sort set `S`, two sorted sets `A, B : SSet S`,
> algebra structures `FA` on `A` and `FB` on `B`, and a sorted map
> `f : A -> B`. Assume:
> - `hf`: `f` is an algebra isomorphism from `(A, FA)` to `(B, FB)` (a
>   sort-wise bijective homomorphism with homomorphic inverse, per
>   `IsAlgIso`);
> - `hA`: the sorted set `A` is finite (`FiniteSSet A`, i.e. finite in every
>   sort).
>
> Conclusion: the sorted set `B` is also finite (`FiniteSSet B`). In words:
> finiteness of the underlying sorted set is transported across an algebra
> isomorphism.
>
> **congruenceFormationOf_isFiniteIndex.**
> Fix a signature `Sig` and a set `F` of `Sig`-algebras. Assume
> `hF : F subseteq algebraFinite Sig`, i.e. every algebra in `F` is finite.
> Conclusion: for every sorted set `A`, the congruence collection
> `congruenceFormationOf Sig F A` -- the set of congruences on the term
> algebra over `A` that the formation-of-`F` construction associates to `A`
> -- is contained in `congFi Sig (termAlg Sig A).2`, the set of finite-index
> congruences on the term-algebra structure on `A`. In words: if a family of
> algebras consists only of finite algebras, then every congruence it
> generates (at every carrier `A`) has finite index.
>
> **algebraFormationOfCongruenceFormation_isFiniteAlgebra.**
> Fix a signature `Sig` and a family `G` assigning to each sorted set `A` a
> set `G A` of congruences (sorted equivalence relations) on the term algebra
> over `A`. Assume `hfi`: for every sorted set `A`,
> `G A subseteq congFi Sig (termAlg Sig A).2`, i.e. every congruence
> appearing in `G` (at any carrier `A`) has finite index.
> Conclusion: the set of algebras `algebraFormationOfCongruenceFormation Sig
> G` built from `G` (by taking, for each `A`, the quotient of the term
> algebra over `A` by the congruences in `G A`) is contained in
> `algebraFinite Sig`, i.e. every algebra so produced is finite. In words: a
> congruence formation consisting entirely of finite-index congruences
> produces only finite algebras.
>
> **formAlgFFormCgrFiIso.**
> For a signature `Sig`, this defines (the `toFun` component is the only
> field shown, so the full construction is not given) an order isomorphism
> `≃o` between `finiteAlgebraFormations Sig` (the collection of algebra
> formations for `Sig` all of whose members are finite algebras) and
> `finiteIndexCongruenceFormations Sig` (the collection of congruence
> formations for `Sig` all of whose congruences have finite index), where
> both sides are ordered by inclusion. The statement asserts the existence of
> a bijective, order-preserving-and-reflecting correspondence between finite
> algebra formations and finite-index congruence formations -- i.e. these two
> collections are order-isomorphic (the finite/finite-index restriction of
> the general algebra-formation <-> congruence-formation correspondence, per
> the surrounding `Formation.lean` machinery).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> MODEL: claude-sonnet-5 (family: claude)
>
> # B-P034 verdict
>
> VERDICT: equivalent
>
> JUSTIFICATION: The Lean package's final declaration `formAlgFFormCgrFiIso`
> asserts exactly the target: an order isomorphism `≃o` between
> `finiteAlgebraFormations Sig` (= Form_Alg_f(Sigma), B-D043) and
> `finiteIndexCongruenceFormations Sig` (= Form_Cgr_fi(Sigma), B-D041), both
> ordered by inclusion -- and an order isomorphism between complete lattices
> is exactly what "the complete lattices ... are isomorphic" (B-P034) means,
> since order-isomorphisms automatically transport sups/infs. The two
> supporting lemmas mirror the manuscript's two proof steps precisely:
> `congruenceFormationOf_isFiniteIndex` shows theta_Sigma(F) lands in
> finite-index congruences when F consists of finite algebras (B-P034's
> forward direction), and `algebraFormationOfCongruenceFormation_isFiniteAlgebra`
> shows theta_Sigma^{-1}(frak-F) lands in finite algebras when frak-F consists
> of finite-index congruences (the converse direction) -- both stated
> slightly more generally (for arbitrary sub-collections F/G, not requiring
> the full formation axioms), which is a harmless strengthening at the lemma
> level that collapses back to the target statement once combined into the
> order isomorphism. The auxiliary `finiteSSet_of_isAlgIso`
> (isomorphism-invariance of finiteness) correctly supports the manuscript's
> "class of algebras isomorphic to some quotient" phrasing in the
> theta_Sigma^{-1} construction (B-D043/Alg_f is manifestly
> isomorphism-invariant), so no gap there. The manuscript's standing
> hypothesis B-A001 (S finite) does not appear as a hypothesis anywhere in
> the Lean read-back, but the summarized proof of B-P034 itself never invokes
> S-finiteness -- it only uses the definitional equivalence between "quotient
> is finite" and "finite index" -- so its absence is consistent with the
> proof being valid in the extra generality, not a substantive discrepancy.
> The one caveat is that `formAlgFFormCgrFiIso`'s read-back shows only the
> `toFun` field, so the direction/definitional identity of the inverse map
> and the round-trip proofs cannot be fully checked from this read-back
> alone, but nothing in what is shown contradicts the contract.

## Coordinator correction (post-hoc verification)

The stage-2 verdict above (`equivalent`) treated the absence of a `Finite S`
hypothesis as "consistent with the proof being valid in the extra generality,
not a substantive discrepancy." A second, independent cross-model run
(`blocks/audits/B-P034-correspondence-crossmodel-mixed.md`, reusing the
Session-119 `deepseek-v4.1-flash` stage-1 read-back) flagged the same absence
but rated it `formal_stronger` instead. The coordinator checked
`lean/Mslang/Regular.lean` directly to resolve the disagreement: there is no
`variable [Finite S]`/`Finite S` hypothesis anywhere in the file (only
`variable {S : Type u}` at line 19), and none of `finiteSSet_of_isAlgIso`,
`congruenceFormationOf_isFiniteIndex`,
`algebraFormationOfCongruenceFormation_isFiniteAlgebra`, or
`formAlgFFormCgrFiIso` take one. The manuscript's `B-P034` sits under the
standing Assumption `B-A001` ("in the remainder of this section we require
`S` to be finite"), so the Lean genuinely proves the isomorphism for
arbitrary `S`, dropping a section-wide hypothesis the contract carries. This
is a real generalization, not an inconsequential omission -- **the correct
verdict is `formal_stronger`**, matching
`B-P034-correspondence-crossmodel-mixed.md`. This record's outcome is
corrected accordingly in the evidence trail (`E-000392` is superseded).
