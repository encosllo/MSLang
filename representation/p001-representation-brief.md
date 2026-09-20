# Decision brief -- closing `B-P001`'s `formal_weaker` gap

Status: **PROPOSED, unaudited**. This is a design brief for the author
(Architecture.md Section 16.4, decision-brief format). It is not evidence and
must not be treated as authoritative.

## Keynote

`B-P001` (support properties of sorted sets) is the **only negative
correspondence** in the pilot: the two-stage blind comparator returned
`formal_weaker` (`E-000236`). Three of its clauses -- the arbitrary union
`supp(⋃ᵢ Aⁱ) = ⋃ᵢ supp(Aⁱ)`, and the intersection/difference clauses for
arbitrary sorted sets -- cannot be *stated* in the adopted encoding. Closing the
gap is a **representation decision** (class C6), not a proof gap.

## The artifact to audit

`representation/pilot-encoding.md` (the dependent-type carrier model:
`SSet S := S → Type u`), and `lean/Mslang/Prelim.lean`'s `B-P001` section.

## Why the gap exists

The encoding makes an `S`-sorted set a family of *types*. There is no common
ambient in which to form `⋃ᵢ Aⁱ`, `⋂ᵢ Aⁱ`, or `A − B` for sorted sets on
unrelated carriers. The Lean `B-P001` therefore proves the union clause only for
the coproduct `iCoprod` (whose support formula coincides) and the
intersection/difference clauses only for componentwise subsets of one fixed
carrier. This is exactly the representation's declared `D2` residual.

## The tension (why this is not a one-line fix)

The paper's foundation is a Grothendieck universe `𝒰` with sorted sets as
elements of `𝒰^S`, i.e. *subobjects of a fixed ambient*. That model makes the
set-theoretic operations componentwise and immediate. The project moved to the
dependent-type model in Session 29 (class C6) to fix `R-delta`, `R-quotient`,
`R-product`, `R-complement`: a fixed ambient of plain sets makes `1^S` the whole
ambient (not a singleton), and quotients/products/complements leave the object
class `S → Set U`.

The two requirements pull in opposite directions:

- **unions/intersections/differences** want a fixed ambient `U` and
  `A : S → Set U`;
- **quotients/products** want closure of the object class under
  `Quotient`/`Π`, which in Lean raises the universe (`Set U : Type (u+1)`).

A Grothendieck universe resolves this only because it is closed under powersets
and quotients -- a closure property Lean's universe polymorphism does not give
for free.

## Consequences common to any C6 revision

Changing the representation changes the hash of `representation/encoding`, so
**every** current review/correspondence record stales (the C6 invalidation of
Session 29 affected ~240 records). A revision must budget a full re-baseline:
re-issue every verification record, re-run every correspondence audit, and
re-audit the representation. The `B-P001` win alone does not justify that cost;
it is justified only if the revision also *improves* fidelity elsewhere (e.g.
makes `B-A001`/`B-R024` unconditional, or removes other residuals).

## Options

1. **Status quo -- accept `formal_weaker`.** Keep the dependent-type model;
   record `B-P001` as `formal_weaker` (representation-level gap, `D2`). Cost: 0.
   Cost to truthfulness: `B-P001`'s union clause has no formal counterpart.

2. **Fixed-ambient subobject model (`SSet S := S → Set U`).** Most faithful to
   the paper's `𝒰^S`; `B-P001` becomes provable verbatim. Re-introduces
   `R-quotient`/`R-product`/`R-complement` unless a universe-closure assumption
   or a separate quotient layer is added. Full C6 re-baseline.

3. **Universe/hybrid model.** Keep `S → Type u` as the primary carrier, and add
   a *subobject presentation*: for a fixed ambient `U`, sorted sets that are
   subobjects of `U` form a second class on which `⋃`/`⋂`/`−` are componentwise;
   prove a bridge between the two presentations. Formalize `B-P001` in the
   subobject presentation. Additive, but introduces a second representation and
   bridge obligations; a partial (non-universe) version is already what the Lean
   intersection/difference clauses do.

4. **Universe-polymorphic rewrite with `ULift`/`Quotient` bridges.** Model the
   paper's `𝒰` as `Type u` and accept `ULift`-mediated coercions where the
   object class must be raised; state the set operations on a chosen small
   ambient. Largest engineering effort; likely to need `Type u`-indexed
   structure and careful universe bookkeeping.

## Recommendation (advisory)

Prefer **Option 3** if the author wants `B-P001` closed: it is the only option
that adds the missing operations *without* re-introducing the residuals the
dependent-type model was chosen to fix, and it can be staged (subobject
presentation first, bridge later) so the full re-baseline is deferred until the
bridge is accepted. Otherwise **Option 1** is honest and costs nothing. Options
2 and 4 trade one set of residuals for another.

This brief proposes no change; the representation revision, if any, is
author-reserved (Sections 11.5, 16.4).
