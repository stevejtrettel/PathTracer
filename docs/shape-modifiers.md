# Shape modifiers: a chain, not a slot

**Status: BUILT (July 2026).** The chain, the six new modifiers, and the demo
scene (`scenes/chain/`) are live; every pre-existing golden survived the
refactor byte-for-byte. §10.5 records where the build deliberately deviates
from the plan below (each one found and settled during implementation); what
is not written here is deliberately out of scope (§9).

Today a scene's `shape:` is *a library shape plus at most one wrapper*. This plan
replaces that single slot with an **ordered list of modifiers**, so effects that
take one shape and return one shape can stack, and adds four new modifiers
(`clip`/`subtract`, `round`, `shell`, `mirror`, `radial`) over the mechanism.


## 1 · What exists today

- [`js/scenegen/combinators.js`](../js/scenegen/combinators.js) — `displace`, `repLim`,
  `carve`. Each returns `{__shape: true, kind: '<one string>', stem, entry, values, …params}`.
- [`js/scenegen/plan.js`](../js/scenegen/plan.js) — `planObject` reads
  `node.shape.kind ?? 'plain'` and dispatches to one of four builders
  (`sdfPlain`, `sdfDisplaced`, `sdfRepLim`, `sdfCarve`) or `sdfTransformed`.
  **Each builder writes the complete `float sdf_<name>(vec3 p){…}` and its bound
  from scratch, assuming a bare `lib` call as its base.** That is the only reason
  wrappers cannot stack — `displace` and `carve` both throw on a wrapped base.
- The four builders are ~85 lines. `plan.js` is 394 lines; `emitter.js` (510) is
  **not touched by this work** — consts, sdf text and bound text all reach it
  through the plan record.

## 2 · The model: two phases

A modifier is either a **domain mod** (rewrites the query point, before the base
is evaluated) or a **field mod** (rewrites the distance, after). Every emitted
sdf then has one shape:

```glsl
float sdf_rock(vec3 p){
    vec3  q = opRepLim(p - ROCK_P, ROCK_SPACING, ROCK_LIMIT);        // domain mods fold the point
    float d = sphereDistance(q, ROCK_RADIUS);                        // the base
    d = opCarveFbm(q, d, detail, erosion, gain, blend, ROCK_SEED);   // field mods, in order
    return smax(d, planeDistance(p - ROCK_P - ROCK_CLIP_P, ROCK_CLIP_NORMAL), ROCK_CLIP_BLEND);
}
```

One line per modifier, in the order written. Field mods that take an
**infinite field** (`carve`, `displace`) see the **folded** `q` — which is
what makes "a lattice of eroded spheres" mean what it looks like. Field mods
that take a **placed volume** (`clip`, `subtract`) act at the **pre-fold
local point** instead: a cutter is a placed thing, so it cuts the whole
assembly, not each folded copy (§10.5.1).

**Nesting order = application order, innermost first.** `carve(radial(lib.box()))`
folds, then evaluates the box, then carves. Because a domain mod must act before
the base, **a domain mod may not wrap a field mod** — see §6 for the error.


## 3 · The modifier descriptor

*(As built — §10.5.4 records how this evolved from the plan's separate
`consts/line/bound` closures.)* A `shape:` is a base plus `mods: [...]`, each
a plain record its combinator appends (`appendMod`, `combinators.js` — which
also enforces the phase-order and true-DF rules of §6):

```js
{
  kind:  'accrete',            // for errors and validation
  phase: 'domain' | 'field',   // rewrites the point | rewrites the distance
  requiresTrueDF: true,        // refuse if anything below broke true distance
  breaksTrueDF:   true,        // displace: the result is not a true distance
  uses:  [entry, ...],         // library files a cutter operand calls into
  plan(fx){ ... },             // description values -> one planned instance
}
```

`plan(fx)` runs once per emission and returns the planned instance the fold
renders — the sdf AND the bound come from this one call, so consts allocate
exactly once:

| field | meaning |
|---|---|
| `fold: (pt) => text` | domain mods: the point rewrite (`opRepLim(pt, S, L)`) |
| `expr: (d, pt) => text` | field mods: the distance rewrite (`opCarveFbm(pt, d, …)`) |
| `line: 'd += …;'` | statement form — displace only, whose divisor closes the return |
| `readsQ: true` | the mod evaluates the folded point, so the body binds the `q` local |
| `frame: 'local'` | placed-volume mods (clip/subtract): `pt` is the PRE-fold local point |
| `divisor: text` | Lipschitz term, summed into the closing `d/(1.0 + Σ terms)` |
| `boundEffect` | `'keep'` \| `{inflate: text}` \| `{replace: (pt) => text}` — see §5 |
| `helperDefs: [text]` | extra emitted functions (a modified cutter's `clip_<name>`) |

`fx` is the fold context (`makeFoldCtx`, `plan.js`). `fx.value(type, suffix,
v, where)` applies the one naming rule — **a knob stays a bare uniform (an
int knob in a float slot is cast at the call); anything else becomes a const
`<NAME>_<SUFFIX>`**, numbered when a repeated modifier already claimed the
name (`SPACING`, `SPACING2`). `fx.num`/`fx.glsl` resolve plain numbers and
glsl`` fragments, `fx.token` claims a repeat-numbered prefix (`CLIP`,
`CLIP2`), and `fx.cutter` plans a placed operand, whose consts land as
`<NAME>_<tok>_*`.


## 4 · The modifiers to build

### Existing three — migrated unchanged (behaviour-frozen, see §7)

| | phase | line | bound rule |
|---|---|---|---|
| `displace({by, amp})` | field | `d += amp*<field>(q);` + the divisor on the return | base inflated by `maxAbs(range)*amp` |
| `repLim({spacing, limit})` | domain | `q = opRepLim(q, S, L);` | *see the bonus below* |
| `carve({octaves, erosion, gain, blend, seed})` | field | `d = opCarveFbm(q, d, …);` | base, unchanged |

**Bonus available for free:** with domain mods folding the bound too (§5),
`repLim` gains a **derived** bound (fold the point, evaluate the base's bound
there) where today it has none and demands an authored one. Implement it, but
keep any existing authored `bound:` overriding it, and confirm no golden changes.

### New

**`clip(base, {to, at = [0,0,0], blend = 0})` and `subtract(base, {what, at, blend})`**
— one descriptor, one sign flag. `to`/`what` is a **called** lib shape
(`lib.box({halfSize: […]})`) — or a modifier chain over one
(`repLim(lib.sphere({…}), {…})` is "a grid of holes") — used as a volume: no
region, no id, no material. A cutter chain may carry anything except
`displace` (its Lipschitz divisor cannot be threaded through the smax
conservatively); the chain nests as one expression, planned by the same fold.

- clip line: `d = smax(d, <cutterStem>Distance(<local> - <NAME>_CLIP_P, …args), BLEND);`
  where `<local>` is the PRE-fold local point — `p - <NAME>_P`, or
  `toLocal_<name>(p)` on a transformed node, so the cut rides the transform
  (plain `max` when `blend` is 0; the `- <NAME>_CLIP_P` is omitted when `at`
  is the origin)
- subtract line: `d = opSubtractDist(d, <cutter>, BLEND);` — `opSubtractDist(a, b, k)`
  already exists in `computations.glsl`.
- clip bound: **replaced** by the CUTTER'S bound — its `Bound` if the catalogue
  has one (else its `Distance`), with the cutter's own chain folded by the same
  keep/inflate rules, minus the blend. A carved cutter donates its uncarved
  base, never the full erosion (a bound as expensive as the sdf it gates
  accelerates nothing).
  This is the point of the modifier: an unbounded base (a variety's zero set, a
  lattice, a limit set) gets a bound it could not otherwise have.
  **The `- BLEND` is required**, not cosmetic: the polynomial smax bulges outward
  by up to `blend/4`, and a bound that ignores it tunnels at the cut edge. (The
  hand-written `scenes/variety/src/scene.glsl` does exactly this by hand:
  `bound_sheet = sphereDistance(q, CLIP_R + CLIP_SMOOTH)`.)
- subtract bound: base, unchanged (the result is inside the base).
- Sign convention to state in the doc comment: `planeDistance` is negative behind
  the normal, so `clip(to: lib.plane({normal: [0,1,0]}))` keeps the part **below**
  the plane.

**`round(base, {r})`** — field. Line `d -= R;` (negative `r` shrinks).
Bound: base **inflated by `r`**.

**`shell(base, {thickness})`** — field. Line `d = abs(d) - T;`.
Bound: base **inflated by the thickness** — the OUTER face lies `T` outside
the base surface, so an unchanged bound would step past it at grazing angles
(a plan-stage error, caught in the build: §10.5.2).
**Validation: refuse `thickness < 2*AT_THRESH` (0.006)** —
below that the classifier cannot separate the two faces (`docs/marching.md`;
`glsl/shapes/variety.glsl` states the same rule for `varietyShell`).

**`mirror(base, {axes: 'x' | 'xz' | …})`** — domain. Line `q = opSymXZ(q);` etc.
(`opSymX/opSymY/opSymZ/opSymXZ` exist). Exact: a reflection is an isometry.

**`radial(base, {n, axis = 'y'})`** — domain. Needs a **new operator** in
`glsl/objects/computations.glsl`, beside the other domain folds:

```glsl
//fold space into one of n wedges around the axis — an n-fold rotational symmetry.
//A rotation is an isometry, so this is exact; but like opRepLim, the base must
//stay INSIDE its wedge or the fold overestimates distance across the seam, which
//the marcher punishes as tunneling.
vec3 opRadialY(vec3 p, float n){
    float r = length(p.xz);
    if(r < 1.0e-6){ return p; }              // on the axis atan is undefined
    float seg = 6.2831853/n;
    float a   = mod(atan(p.z, p.x) + 0.5*seg, seg) - 0.5*seg;
    return vec3(r*cos(a), p.y, r*sin(a));
}
```

plus `opRadialX`/`opRadialZ` (same body on the other two planes), so the JS picks
a function name rather than passing an axis vector.


## 5 · Bound composition

The bound is folded alongside the sdf. Start from the base's derived bound
(`<stem>Bound` if the catalogue has one, else the base's own `Distance`), then:

| modifier | effect on the running bound |
|---|---|
| `carve`, `subtract` | unchanged — the result is contained in the base |
| `accrete` | inflate by `(ACCRETE_REACH + blend/4)/(1 - gain)` — the octaves' reach, summed |
| `round` | inflate by `r` |
| `shell` | inflate by the thickness (the outer face lies outside the base) |
| `displace` | inflate by `maxAbs(range)*amp` (several displaces SUM their inflations) |
| `clip` | **replaced** by the cutter's distance minus the blend |
| `mirror`, `radial`, `repLim` | the fold applies to the bound too: `bound(fold(q))` |

A derived bound is **emitted only when it differs from the sdf itself** —
at least one field mod, a real `<stem>Bound` on the base, or a clip
replacement. A domain-only chain over a `Bound`-less base (repLim of a
sphere) derives nothing, exactly as before: a bound textually equal to the
sdf accelerates nothing. A transformed node derives no bound at all (a
placement-frame expression cannot enclose a rotated body) — its bound stays
authored.

An authored `bound:` on the node overrides the whole derivation, exactly as today.
An analytic (traced) object still refuses an authored bound.


## 6 · Validation and errors

Each message should name the offending modifier and say what to write instead.

1. **Phase order** — a domain mod wrapping a field mod:
   `scenegen: radial() is a domain fold, so it must be applied before anything that acts on the distance — write radial(...) inside carve(...), not around it`.
2. **Displace last** — `carve`/`round`/`shell` after a `displace` is refused:
   displacement breaks the true-distance property they rely on (the rule the
   old single-slot `carve()` enforced, carried into the chain). `clip`,
   `subtract`, and further `displace`s after a displace are fine — several
   displaces SUM their divisor terms and their bound inflations.
3. `clip`/`subtract`: `to`/`what` must be a **called** lib shape or chain; an
   uncalled builder (`lib.box`) is an error, and so is a displaced cutter (§4).
4. `shell`: literal thickness below `2*AT_THRESH` refused (a knob thickness
   cannot be checked statically and is allowed).
5. `radial`: `n` must be an integer ≥ 2 (or an `int` knob — mirror `carve`'s
   octaves check; the operator takes a float, so an int knob is cast at the call).
6. `displace` keeps its existing requirement that the field declares
   `{gradBound, range}`.
7. Modifiers named in the chain twice: allowed (two clips is meaningful); their
   consts take a numeric suffix (`<NAME>_CLIP_P`, `<NAME>_CLIP2_P`;
   `<NAME>_SPACING`, `<NAME>_SPACING2`).


## 7 · Migration, and the acceptance test

**Every existing scene becomes a one-element (or zero-element) chain, and the
emitted chunk must not change by one byte.** *(Passed on the first run —
every golden byte-identical, zero rebakes.)*

```
npm run gen -- --goldens        # must report OK for every scene, with NO rebake
```

That is the acceptance test for the refactor half of this work, and it is strict
on purpose: it forces the fold to reproduce the current text exactly — same
statement wording, same spacing, same const names and order. If a golden must
change, stop and raise it rather than baking.

Other invariants to preserve:

- `analytic` (traced, never marched) requires **no modifiers and no transform** —
  today's `kind === 'plain' && !transformed` becomes `mods.length === 0 && !transformed`.
- The transform (`rotate`/`scale`) stays where it is: it produces the local point
  `q` via `toLocal_<name>(p)`, before any domain mod, and a non-uniform scale's
  `min(SCALE.x, …)` factor multiplies the **final** distance, after all field mods.
  Removing today's "rotate/scale cannot combine with a wrapper" restriction falls
  out of this for free — do it, and check it changes no existing golden.
- **A material's `q` stays the placement-local (unfolded) point**, as today. Do not
  quietly switch materials to the folded point; it is a real question, and it is
  listed as open in §9.
- Shape-data outputs (`<name>Data` injection) are unaffected.


## 8 · The demo scene

`scenes/chain/` (built) — one object per stack, so the mechanism is legible
at a glance:

```js
mesa:   clip(carve(lib.sphere({radius: 1.9}), {...}), {to: lib.plane({normal: [0,1,0]}), at: [0,0.9,0], blend: 0.05})
beads:  clip(repLim(lib.sphere({radius: 0.32}), {spacing: 1, limit: [3,0,3]}), {to: lib.sphere({radius: 2.4})})
pillar: carve(radial(lib.box({halfSize: [0.35, 1.2, 0.35]}), {n: segments}), {...})
husk:   shell(clip(lib.gem({size: 1.4}), {to: lib.box({halfSize: [2,2,1]}), at: [0,0,1.2]}), {thickness})
dice:   subtract(lib.box({halfSize: [1,1,1]}), {what: lib.sphere({radius: 1.25}), at: [0.7,0.7,0.7], blend: 0.08})
reef:   accrete(lib.box({halfSize: [0.85,0.85,0.85]}), {...})   //carve's mirror, same erosion knobs as mesa
```

`beads` is the bound story in one object: the lattice (unboundable alone —
the old repLim demanded an authored `bound:`) inherits the cutting sphere as
its acceleration volume, no authored bound anywhere.

with `room()` + `sphereLight()` from the presets, and knobs on the parameters
worth moving by eye (erosion, blend, `n`, shell thickness). Register with
`node scripts/gen-pages.mjs`.

**The scene owner aims cameras and judges looks by eye** — do not spend cycles
tuning framing or lighting. Verify that it emits, compiles, and renders something
non-black (`node scripts/render-test.mjs --budget 20000 chain`), then hand it over.


## 9 · Out of scope (deliberately)

- `twist` / `bend` / `taper` — domain mods that *distort*; each needs a divisor
  derived from the base's extent (twist: `√(1 + (k·r)²)`). Own design conversation.
- `elongate` — exact only for convex bases.
- ~~`accrete`~~ — **built** (July 2026, after the chain landed, exactly as
  hoped: no mechanism change). `accrete(base, {octaves, erosion, gain, blend,
  seed})` — carve's mirror: the same lattice octaves GROW on the surface
  (`opAccreteFbm`: each octave's spheres clamp to `ACCRETE_REACH` of the
  running surface, then smooth-union on). The one flipped derivation: the
  bound INFLATES by the geometric series `(ACCRETE_REACH + blend/4)/(1 - gain)`
  — emitted with the const's NAME, so retuning it in GLSL cannot strand the
  derived bounds — which is why accrete alone validates `gain` in `[0, 1)`
  (a literal, or a knob's whole range): the growth itself diverges at 1.
- `carve`'s deferred `by:` (a caller-supplied distance field, metadata = a declared
  Lipschitz constant). See the note in `combinators.js`.
- Union as description structure. Two solids that don't contain each other are
  **two objects**, or one authored group body — see §4 of `scene-authoring.md`.
- **Open question, do not decide silently:** what `q` a material should see after a
  domain fold (today: the unfolded point).


## 10 · House rules the implementation must follow

From [`generator.md`](generator.md) and the surrounding code:

- **The emitter emits glue, never math.** New GLSL math (`opRadial*`) goes in
  `glsl/objects/computations.glsl` beside the other `op*`, and the planner only
  names it. Do not inline formulas into emitted text beyond what the existing
  builders already do.
- Numbers go through `fnum`/`fvec3` (float32-exact shortest decimal); consts are
  `<NAME>_<PARAM>`; knobs are referenced bare; run new names past `checkReserved`.
- A modifier that takes a lib shape as an operand (`clip`, `subtract`) emits that
  shape's parameters as its own consts — it must not reuse the base's names.
- GLSL ES 3.00: no token pasting, `mat3` constructors are column-major, and a
  variable may not be named `T` (`#define T vec2`).
- Update the docs in the same pass: the wrapper list in
  [`scene-authoring.md`](scene-authoring.md) §3 (currently says "Three shape
  wrappers"), and the derivations paragraph in [`generator.md`](generator.md).

## 10.5 · As built — where the build deviates from the plan above

Settled during implementation (July 2026); the sections above have been
amended to match, this list is the record of what changed and why.

1. **Cutter frame.** The plan contradicted itself: §2's example applied the
   clip to the folded `q`, while §4's bound rule and §8's demo (a world
   sphere trimming a whole lattice) require the placement frame — with folded
   `q`, a cutter larger than one lattice cell would never cut anything. The
   rule as built: a modifier that takes a **placed shape** (`clip`,
   `subtract` — they have an `at:`) acts at the pre-fold local point; a
   modifier that takes an **infinite field** (`carve`, `displace`) acts on
   the folded point, so every copy gets identical detail. Per-copy cutting
   can arrive later as an explicit option.
2. **Shell's bound inflates.** The plan said "base, unchanged", but the shell
   of a solid extends OUTWARD by the thickness (`|d| - T = 0` at `d = +T`);
   an unchanged bound overestimates there and the marcher steps past the
   outer face at grazing angles. Bound: base inflated by `T`.
3. **Cutters may be chains.** The plan restricted `to`/`what` to a plain
   called lib shape. The fold is one reusable function, so a cutter is just a
   recursive call to it (`planCutter`) — domain-modified cutters ("a grid of
   holes") cost nothing. A plain cutter stays one inline call; a MODIFIED
   cutter is emitted as its own small function (`clip_<name>`, `cut_<name>`)
   so its folds and field mods evaluate once per call — likewise, a
   transformed node's chain binds `toLocal_<name>(p)` once when a cutter
   reuses it. Only `displace` is refused inside a cutter.
4. **The descriptor carries `plan(fx)`,** not separate `consts/line/bound`
   closures: one call returns the planned instance (`fold`/`line`/`expr`/
   `divisor`/`boundEffect`), so consts allocate exactly once even though the
   fold renders the sdf and the bound from the same chain. `fx` is the fold
   context (`js/scenegen/plan.js` `makeFoldCtx`): the knob-stays-bare /
   value-becomes-const rule, repeat-suffix numbering, and the cutter fold.
5. **Collapse rules** keep simple chains reading like the hand files (and made
   the byte-freeze pass): no `q`/`d` locals unless something needs them; the
   first domain fold inlines the placement expression; a trailing `d = <expr>;`
   folds into the return (compound `d += …` keeps its statement); a divisor
   closes the return as `d/(1.0 + Σ terms)`; scale's `min(S.x, …)` factor
   multiplies the final expression after everything else.
6. **Known refinement, deliberately not taken:** clip's bound REPLACEMENT is
   the plan's rule, and for an unbounded base it is the whole point — but
   when the base already had a cheap bound (the demo's mesa: a sphere,
   replaced by a half-space), intersecting instead (`max(prev, cutter - blend)`)
   would be strictly tighter. Left as-is for now; revisit if a clipped
   scene marches slow.


## 11 · Adding a modifier — the recipe

Accrete (July 2026) is the reference: the first modifier added AFTER the
chain landed, and it needed no mechanism change. (Step 0, optional: prototype
it in one scene first with the `modifier()` escape hatch —
[`authored-modifiers.md`](authored-modifiers.md) — and promote it here once
it earns a name.) What one costs:

1. **The math** — an `op…` in `glsl/objects/computations.glsl`, beside the
   others. Derive the human math IN ITS COMMENT: the bound effect (where the
   new surface can lie relative to the base's) and, for a distorting mod,
   the Lipschitz divisor. These derivations cannot be parsed from code —
   the combinator *declares* them, and the comment is where the next reader
   checks the declaration. If the formula owns a tuning const
   (`ACCRETE_REACH`), the combinator must emit it by NAME, never restate
   the number.
2. **The combinator** — ~30 lines in `js/scenegen/combinators.js`: validate
   the arguments, then `appendMod(base, {kind, phase, flags, plan(fx)},
   signature)` per §3. Validation rules of thumb: a constraint on a value
   must hold for a LITERAL and for a knob's whole `[min, max]` range
   (accrete's gain); loop and fold counts go through `requireInt`;
   constraints inherited from the ENGINE cite their source (shell's
   `2*AT_THRESH` cites `docs/marching.md`). Every error names the modifier
   and says what to write instead (§6).
3. **The export** — one name added in `js/scenegen/index.js`.
4. **The docs** — a line in `scene-authoring.md` §3's modifier list, a row
   in §5's bound table here.
5. **The proof** — use it in a scene (`scenes/chain` is the sampler), check
   `npm run gen -- --goldens` leaves every pre-existing golden untouched,
   bake the new one deliberately (`--write`, after eyeballing the diff),
   and render non-black (`node scripts/render-test.mjs --budget 20000
   <scene>`). Looks are the owner's by-eye pass, not part of the landing.

If the modifier does not fit the §3 descriptor — it needs new machinery in
`plan.js`'s fold — stop and treat it as a schema-design question first
(twist/bend/taper sit in §9 for exactly this reason).
