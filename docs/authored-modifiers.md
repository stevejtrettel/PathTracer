# Authored modifiers: the escape hatch

**Status: BUILT (July 2026).** Design settled in conversation, built the same
day, exactly to plan — the §2 design claim held: `modifier()` is ~50 lines in
`combinators.js` plus an export, and `plan.js`/`emitter.js` were not touched.
Demo: `scenes/modifier/` (drilled = `'keep'`, halo = `{inflate}`); every
pre-existing golden byte-identical, the demo's baked, render non-black.
Companion to [`shape-modifiers.md`](shape-modifiers.md) — that doc's §3
descriptor and §11 recipe are the *named* layer this primitive sits beneath.


## 1 · The gap

Everywhere else the system has two rungs: a raw escape hatch usable directly
in a scene, and a curated named layer above it.

| | escape hatch | named layer |
|---|---|---|
| shapes | an authored `glsl\`\`` body | `glsl/shapes/` → `lib.<stem>` |
| materials | `material({surf, interior})` | archetypes + looks in `js/presets/materials.js` |
| fields | `field()` + declared `{gradBound, range}` | field presets in `js/presets/fields.js` |
| modifiers | **— missing —** | combinators in `js/scenegen/combinators.js` |

The consequence: every modifier is born as core surgery. Trying a one-off
`op…` on a single object means editing the generator on day one, and an
experiment's blast radius is the whole library. This primitive gives
modifiers the missing bottom rung: try it in one scene tonight, promote it
(shape-modifiers §11) once it earns a name.

**The bargain is `field()`'s bargain.** The author supplies the GLSL and
*declares the safety facts the generator cannot derive* — chiefly what the
effect does to the bound. The derivations are human math; they are declared,
never parsed (`scene-authoring.md` §11). The generator does everything it
already knows how to do: knobs stay live uniforms, the expression folds into
the emitted sdf, the declared inflation folds into the derived bound.


## 2 · The primitive

```js
shape: modifier(base, {
    expr:  glsl`smax(d, 0.4 - length(q.xz), ${bite})`,   // the distance rewrite
    bound: 'keep',                                        // or {inflate: <number|knob>}
})
```

- **`expr`** — a `glsl\`\`` EXPRESSION (not a statement: no `;`, no
  assignment) producing the new distance. It reads two documented locals,
  exactly as authored material bodies read `q`:
  - `d` — the running distance (the base, plus any earlier field mods);
  - `q` — the **folded** local point. An authored modifier is an
    infinite-field mod in the sense of shape-modifiers §2: like `carve` and
    `displace` it sees the folded point, so under `repLim`/`radial`/`mirror`
    every copy gets identical treatment. (Placed-volume behaviour — cutting
    the whole assembly at the pre-fold point — is `clip`/`subtract`'s
    machinery, and stays theirs.)

  Interpolations follow the glsl tag's normal rules (`scene-authoring.md`
  §5): knobs interpolate bare and stay live, numbers inline, `${{name}}`
  emits a commented value.
- **`bound`** — required, no default; making the author state it is the
  point. Two forms:
  - `'keep'` — the result is contained in the base (a carve-class effect);
  - `{inflate: v}` — the surface can move outward by at most `v` (a number
    or a float knob; a knob's `max` is what the declaration promises).

The result is an ordinary field mod: it stacks with every other modifier,
may appear more than once in a chain, and obeys the phase rules of
shape-modifiers §2/§6 unchanged.

### What it emits

```js
object('drilled', {
    at: [0, 1, 0],
    shape: modifier(lib.sphere({radius: 1.0}), {
        expr:  glsl`smax(d, 0.4 - length(q.xz), ${bite})`,
        bound: 'keep',
    }),
    ...
})
```

```glsl
float sdf_drilled(vec3 p){
    vec3  q = p - DRILLED_P;
    float d = sphereDistance(q, DRILLED_RADIUS);
    return smax(d, 0.4 - length(q.xz), bite);
}
```

One line, folded by the existing collapse rules (a trailing expression folds
into the return). An `{inflate: v}` declaration lands on the derived bound as
`- v`, summed with any other inflations, exactly like `round`/`shell`/
`accrete`.

### The descriptor it plans

The whole design claim is that this fits the existing §3 descriptor with
**zero new fold machinery**:

```js
{kind: 'modifier', phase: 'field', requiresTrueDF: true,
 plan(fx){ return {
     expr: () => fx.glsl(spec.expr),      // resolved once; ignores (d, pt) —
     readsQ: true,                        // the fragment names d and q itself
     boundEffect: spec.bound === 'keep' ? 'keep'
                : {inflate: fx.num(spec.bound.inflate, …)},
 };}}
```

If the implementation finds itself touching `plan.js` or `emitter.js`, the
design is wrong — stop and reopen this doc.


## 3 · The contract the author signs

Stated in the doc and in the error messages, because nothing can check it:

1. **The expression must return a conservative distance** — never farther
   than the true distance to the surface it defines. Smooth min/max of
   distances, offsets, and engine `op…`s qualify; `d + noise(q)` does NOT
   (that is displacement — use `displace()`, which pays the divisor).
   `requiresTrueDF: true` means the chain refuses to apply an authored
   modifier after a `displace`, same as `carve`.
2. **The declared bound is a promise.** `'keep'` when the surface stays
   inside the base; `{inflate: v}` when it can reach at most `v` outside.
   A wrong declaration is invisible until the marcher tunnels — one scene's
   blast radius, but real. Derive it the way the library does: in a comment
   next to the expression.
3. **New math belongs in GLSL, not in the fragment.** A one-liner may live
   inline; anything with real structure goes in
   `glsl/objects/computations.glsl` as an `op…` (engine-global, so the
   fragment can call it) — which is also step 1 of promotion.


## 4 · Validation and errors

Each message names the fix, house style (shape-modifiers §6):

1. `expr` missing or not a glsl fragment:
   `scenegen: modifier() needs expr: a glsl\`...\` expression over d and q — see docs/authored-modifiers.md`.
2. `expr` containing `;` or an assignment: refused — it must be an
   expression producing the new distance, not a statement.
3. `bound` missing:
   `scenegen: modifier() must declare its bound — 'keep' if the surface stays inside the base, {inflate: v} if it can move outward by at most v. This is your promise to the marcher; docs/authored-modifiers.md §3.`
4. `{inflate: v}`: a literal must be a number ≥ 0; a knob must have
   `min >= 0` (the whole range is the promise — the accrete rule).
5. Applied after `displace`: refused by the existing `requiresTrueDF` rule.
6. Everything else (base must be a lib shape or chain, phase order) is
   `appendMod`'s existing enforcement, inherited for free.


## 5 · Promotion

When a one-off earns a name: move the math to `computations.glsl` (if it
isn't there already), write the ~30-line combinator per shape-modifiers §11
— its `plan()` returns the same planned instance the hatch built, now with
named-argument validation — and the scene swaps
`modifier(base, {...})` for `myMod(base, {...})`. The declaration doesn't
change shape; it changes address and gains a gatekeeper.


## 6 · Demo and acceptance

- **Every pre-existing golden byte-identical** — the primitive adds a code
  path; no existing scene can change. `npm run gen -- --goldens` with zero
  rebakes is the gate for the mechanism itself.
- **Demo**: `scenes/modifier` (a new tiny scene — chain's golden stays
  frozen, decided), one object per bound form: `drilled`, a sphere with a
  smooth borehole, for `'keep'` (the §2 example); and `halo`, a gem plus a
  detached skin of its own offset surface (`min(d, abs(d - gap) - 0.04)`),
  for the `{inflate}` declaration — halved vertically by a named
  `subtract()` stacked over the hatch (opaque + cutaway: a clear-glass
  shell around a clear-glass gem was invisible — first by-eye lesson), so
  the cross-section shows skin/gap/gem and the hatch composing with the
  rest of the chain. Golden baked
  deliberately; render non-black via
  `node scripts/render-test.mjs --budget 20000 modifier`. Looks are the
  owner's by-eye pass.
- Docs in the same pass: the escape-hatch row in `scene-authoring.md` §11's
  table, a pointer in §3's modifier list, and this doc's status flipped to
  BUILT with any §-deltas recorded (shape-modifiers §10.5 style).


## 7 · Out of scope (deliberately)

- **Domain folds.** A declared number protects a field mod; nothing protects
  a bad fold. The built-in folds are isometries — a user fold that stretches
  space breaks the distance property *silently*. Named layer only.
- **Divisors** (displace-class effects that break the true-distance
  property). Addable later as a declared `divisor:` — the `gradBound`
  pattern — but it doubles the ways to get hurt; not in v1.
- **`replace` bounds** — bound donation is `clip`'s semantics and needs a
  placed volume; the hatch has none.
- **Placed operands / `frame: 'local'`** — cutter machinery, named layer only.
- **`carve`'s deferred `by:`** — the same "declare the human math" move
  (a carving field with a declared Lipschitz constant), but it composes with
  carve's octave/bound bookkeeping rather than replacing the whole
  expression. Design it beside this, as a sibling; the hatch may cover the
  experimentation need in the meantime.
