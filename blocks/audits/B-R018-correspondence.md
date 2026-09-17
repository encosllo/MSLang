# Correspondence audit transcript -- `B-R018`

Protocol: Architecture.md Section 11.2, two-stage blind. Both stages were run by
fresh subagents with isolated contexts; neither was told the expected answer.
Stage 1 saw only the Lean declarations and their definitions (no manuscript, no
project history). Stage 2 saw only the stage 1 read-back and the contract.

- **Lean declarations:** `Mslang.TlHom`, `Mslang.TlId`, `Mslang.TlComp`,
  `Mslang.TlComp_id_left`, `Mslang.TlComp_id_right`, `Mslang.TlComp_assoc`,
  `Mslang.tlEndMonoid` (`lean/Mslang/Translation.lean`).
- **Contract:** Remark `B-R018`, section "Elementary translations and
  translations".
- **Outcome:** `equivalent`
- **Recorded as:** `E-000144`
- **Encoding:** dependent-type carrier model, `representation/pilot-encoding.md`.
- **Independence:** both stages share this session's underlying model
  (`deepseek-v4.1-flash`); shared blind spots are not excluded.

## Stage 1 -- read-back (fresh agent, Lean only)

> `TlHom Sig A t s = {T : A_t → A_s // TlGen Sig A t s T}` is the hom-set from
> `t` to `s`, i.e. `Tl_t(A)_s`. `TlId Sig A t = ⟨id, TlGen.refl t⟩` is the
> identity; `TlComp Sig A f g = ⟨g.1 ∘ f.1, TlGen.comp f.2 g.2⟩` composes
> `f : t → s`, `g : s → u` to `t → u`. The three laws `TlComp_id_left`,
> `TlComp_id_right`, `TlComp_assoc` hold (proved by `Subtype.ext` + function
> extensionality, the translation proofs being irrelevant). `tlEndMonoid Sig A t
> : Monoid (TlHom Sig A t t)` has `mul = TlComp`, `one = TlId`, with the monoid
> laws taken from the category laws, and is registered as an instance.
> Objects are the sorts `S`; morphisms are a subtype of functions; the category
> is presented as raw data rather than a Mathlib `Category` instance.

## Stage 2 -- comparison (fresh agent, read-back + contract only)

> **Outcome: equivalent.**
>
> Objects = sorts `S`; hom-sets = `TlHom = Tl_t(A)_s`; identity = `TlId`
> (witnessed by `TlGen.refl`); composition = `TlComp` (closure by `TlGen.comp`);
> the three category axioms are all present and named. `End(t) = TlHom t t` with
> the `Monoid` structure from `tlEndMonoid` is exactly "`End(t)` is equipped with
> a monoid structure". The absence of a Mathlib `CategoryTheory.Category`
> instance is packaging only: a category typeclass bundles the same hom/id/comp
> + three laws that the Lean supplies as raw data. No dropped/added hypothesis,
> no weakening/strengthening, no size mismatch.

## Residual note

The correspondence is `equivalent` relative to the pilot encoding
(`representation/pilot-encoding.md`, independently audited in `E-000040`,
residuals `carrier-model`, `small-large`, `univalence-missing`). Those residuals
are inherited by this verdict; a representation change (class C6) stales it.

## Provenance note

The category is not registered with Mathlib's `Category` class (a deliberate
choice: a `Category S` instance keyed on a bare sort type would risk leaking).
The mathematical content -- hom type, identity, composition, and the three laws
-- is present explicitly, and the endomorphism monoid is registered as a
typeclass instance.
