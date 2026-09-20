# Correspondence audit transcript -- `B-P001`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.

- **Lean declarations:** `Mslang.nonempty_sortedMap_iff`,
  `Mslang.supp_mono_of_injective`, `Mslang.suppSub_directImage`,
  `Mslang.supp_eq_of_surjective`, `Mslang.suppSub_inverseImage`,
  `Mslang.supp_initialSorted`, `Mslang.supp_finalSorted`,
  `Mslang.supp_iCoprod`, `Mslang.supp_iProd`, `Mslang.suppSub_iInter_subset`,
  `Mslang.suppSub_sdiff_subset` (`lean/Mslang/Prelim.lean`).
- **Contract:** Proposition `B-P001` (`propssupport`): supports of sorted sets,
  seven clauses (maps exist iff support included; direct/inverse images; empty,
  terminal, union, coproduct, product, intersection, difference).
- **Outcome:** `formal_weaker`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> The type encoding has no ambient universe: an S-sorted set is a family of
> types `A : S → Type u`, `supp A = {s | Nonempty (A s)}`, `suppSub X =
> {s | (X s).Nonempty}` for `X : Sub A`, `SortedMap A B = ∀ s, A s → B s`,
> `iCoprod A = fun s => Σ i, A i s`, `iProd A = fun s => ∀ i, A i s`.
>
> Claim by claim: (1) `nonempty_sortedMap_iff : Nonempty (SortedMap A B) ↔
> supp A ⊆ supp B`; (2) `supp_mono_of_injective : (f : SortedMap A B) → supp A ⊆
> supp B` (a map exists is weaker data than componentwise `A ⊆ B`);
> (3) `suppSub_directImage : suppSub (directImage f X) = suppSub X`;
> (4) `supp_eq_of_surjective`; (5) `suppSub_inverseImage` for componentwise
> surjective `f`; (6) `supp_initialSorted = ∅`, `supp_finalSorted = univ`;
> (7) `supp_iCoprod`; (8) `supp_iProd`; (9) `suppSub_iInter_subset`, only for
> `Sub A` over one carrier; (10) `suppSub_sdiff_subset`, likewise.
>
> The section header records the design decision: the type encoding has no
> set-theoretic union/intersection/difference of arbitrary sorted sets, so
> `iCoprod` (whose support formula coincides with the union's) plays the union
> role, and intersection/difference are stated for componentwise subsets of a
> common carrier (the fixed-ambient carrier model).

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: `formal_weaker`.**
>
> C1a (map exists iff support included) matches exactly. C1b (`A ⊆ B ⟹ supp A
> ⊆ supp B`) is covered by the map hypothesis (a componentwise inclusion yields
> a sorted map), a harmless generalization. C1c, C2a, C2b, C3a, C3b, C3d, C3e
> (direct/inverse image, surjection, empty/terminal/coproduct/product) are
> faithful equalities.
>
> **C3c** (`supp(⋃ᵢ Aⁱ) = ⋃ᵢ supp(Aⁱ)`): not encoded. The set-theoretic union
> of arbitrary sorted sets is unavailable in the type encoding; the formal
> `supp_iCoprod` states the formula for the disjoint union only. The numerical
> content is recovered, but the union assertion itself has no formal
> counterpart.
>
> **C3f** (`I ≠ ∅ ⟹ supp(⋂ᵢ Aⁱ) ⊆ ⋂ᵢ supp(Aⁱ)`): only for a family
> `B : ι → Sub A` of componentwise subsets of one fixed carrier, not arbitrary
> sorted sets; dropping `I ≠ ∅` is a harmless over-generalization, but the
> carrier restriction narrows the claim.
>
> **C3g** (`supp A − supp B ⊆ supp(A − B)`): likewise only for `X Y : Sub A`;
> `A − B` is undefined across non-common carriers.
>
> The exact equalities of C1--C2 and the initial/terminal/product clauses are
> faithful, but the union clause is substituted and the intersection/difference
> clauses are established only in the fixed-ambient/subobject case. The
> formalization therefore establishes strictly less than the contract.

## Residual note

This is a `formal_weaker` result. The gap is a **representation-level** one, not
a proof gap: the type-level encoding (pilot representation D2, "fixed-ambient
carrier model") cannot express binary operations on unrelated carriers, so the
union/intersection/difference clauses of `B-P001` are not formalizable as
stated. Closing them would require extending the representation to model
S-sorted sets as subobjects of a universe; that is a representation revision
(class C6), which would stale every current record. Left recorded as
`formal_weaker` (a negative correspondence layer) rather than hidden.
