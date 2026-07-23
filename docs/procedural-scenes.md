# Procedural scenes

*Design document. Nothing here is built yet.*

How scenes are described, how SDFs and materials are assembled from a hand-written
GLSL library, and how the shader is generated. Replaces the hand-written
`src/objects.glsl` / `src/environment.glsl` contract.

Companion docs: [material-system.md](material-system.md) (what a Material is),
[material-fields.md](material-fields.md) (the current, superseded field idiom),
[bounding-volumes.md](bounding-volumes.md), [marching.md](marching.md).

---

## 1 · Why

### 1.1 The five parallel functions

Every scene hand-maintains the same list in five places:

```
buildObjects()      trace_Objects()     sdf_Objects()
inside_Object()     setData_Objects()
```

Nothing checks they agree. Omissions fail silently and differently:

| omission | symptom |
|---|---|
| `sdf_Objects` | object invisible |
| `setData_Objects` | object renders with the *previous bounce's* material |
| `inside_Object` | subsurface walk terminates at the wrong boundary |
| `trace_Objects` | object silently switches to the slower marched path |

### 1.2 Identity is discarded, then re-derived

`raymarch` computes a min over every object at every step, then throws the argmin
away. `setData_Scene` re-derives it by asking `at()` of every object — one more
SDF evaluation each, plus four for the winner's normal.

Because `AT_THRESH` is a *band* (0.003) and each `setData` is an independent
`if`, two objects within 3 mm both claim the hit and **the last writer wins**.
[scene.glsl:59](../glsl/tracer/5Scene/scene.glsl#L59) carries the comment
`//need to set this data first!` — an admission that call order is load-bearing
and unspecified.

The clearest evidence is [cubic-landscape:413](../scenes/cubic-landscape/src/objects.glsl#L413),
which detects whether a group claimed the hit by comparing the normal before and
after:

```glsl
if (any(notEqual(path.dat.normal.dir, prevNormal1))) { … un-rotate it … }
```

### 1.3 `AT_THRESH` is globally coupled

The marcher's landing tolerance grows with distance,
`EPSILON*(2 + MARCH_CONE*t)`; `AT_THRESH` is a constant sized to cover it at
`t = maxDist`. It currently fits exactly. Raising `maxDist` or `MARCH_CONE`
silently breaks distant hits. `kleinianSpiral` tries to set `maxDist = 20` and
does not compile, because the constant is `const`.

### 1.4 Multi-material objects are hand-written case analysis

[cocktail.glsl](../glsl/objects/multiMaterial/cocktail.glsl),
[beer.glsl](../glsl/objects/multiMaterial/beer.glsl),
[bottleLiquid.glsl](../glsl/objects/multiMaterial/bottleLiquid.glsl) and
`VARIETY_IN_SHELL_API` are four spellings of the same three-region structure,
each ~40 lines of nested `if` deciding which interface was struck.
[mobius.glsl](../glsl/objects/multiMaterial/mobius.glsl) spends ~150 of its 200
lines on `atBand`/`atBorder`/`insideBand`/`insideBorder`/`normalVecBand`/
`normalVecBorder`/`setData`.

### 1.5 Known-broken scenes

Found while surveying; the rebuild fixes them rather than porting them.

- `apollonian`, `kleinianEscape`, `kleinianSpiral`, `hyperbolicHoneycomb`,
  `hyperbolicHoneycomb2` write `path.dat.surfDiffuse` / `surfEmit`, replaced by
  `dat.surf` in the material rewrite.
- `kleinianSpiral` additionally assigns to `const` `maxDist` and `EPSILON`.

---

## 2 · The model

> **A surface is not a thing with a material. It is the boundary between two
> media.** — [interaction.glsl](../glsl/tracer/3Materials/interaction.glsl)

The engine has said this since the material rewrite. The object library never
got an abstraction for it, so every composite re-derives it by hand.

### 2.1 The contract: a region is three functions of a point

Everything below is machinery for producing these. A region is:

| | signature | written by |
|---|---|---|
| **sdf** | `float sdf(vec3 p)` | generated, from the shape tree (§4) over library SDFs |
| **normal** | `vec3 normal(vec3 p)` | generated: 4-tap of `field`, or an analytic override |
| **material** | `Material material(vec3 p, inout vec3 n)` | generated: base material + modifier chain (§5) |

plus two optional accelerations, both hand-written because they are authored
knowledge the generator cannot derive:

| | signature | |
|---|---|---|
| **bound** | `float bound(vec3 p)` | conservative underestimate, for culling (§4.3) |
| **trace** | `float trace(Vector ray)` | analytic intersection — the only non-point function |

**`inside` and `at` are not primitives.** They are readings of `field`:
`inside` is `field(p) < 0`, `at` is `abs(field(p)) < AT_THRESH`. Today each is a
separate generated function per type
([objectAPI.glsl:69](../glsl/objects/objectAPI.glsl#L69)), which makes the
object interface look larger than it is.

Everything else about a region is **metadata, not a function**: its id and
priority, whether it is a region or a sheet (§2.2), whether the subsurface walk
applies, and the Lipschitz constant of any displacement (§5.2).

The one thing that is *not* per-region is §3: the rule that takes all the fields
at a single point and decides **which two regions the surface there separates**.

### 2.2 Two node kinds

**Region** — a volume. Has an inside (a `Medium`) and a boundary (a `Surface`).
Contributes a *signed* field: negative inside.

**Sheet** — a two-sided surface with no interior. Both sides open onto whatever
region contains the sheet, so the interface is index-matched — this is exactly
`setSurfaceInMat`. Contributes `abs(field)` to the march.

An orientable sheet carries a **front** and a **back** `Surface`, chosen by the
sign of its defining function. A non-orientable sheet (a Möbius band) has no
consistent global side and declares a single `Surface`.

A conventional "object" is the degenerate case: a region whose only neighbour is
air.

### 2.2 The interface table

Every surface in a scene is a pair of adjacent regions. `cocktail` is three
regions — air, cup, drink — and four interfaces:

| surface | interface |
|---|---|
| outer wall | cup ↔ air |
| inner wall, above the waterline | cup ↔ air |
| inner wall, below the waterline | cup ↔ drink |
| liquid top | drink ↔ air |

The 40-line classifier in `cocktail.glsl` computes exactly this table.

### 2.3 Regions may nest; order is priority

`varSphereGlass` is a variety *inside* a glass ball. `nested-spheres` is a core
*inside* a shell. Regions are tested in declaration order and the first match
wins, so **declare inner to outer**.

### 2.4 The tangential-zero invariant

The scene SDF is the solid union, `min(cup, drink)`. The wall between two
adjacent regions is interior to that union, so it is not a sign change — but both
fields are zero there, so the union *touches* zero, and `raymarch` stops on
`abs(raw) < eps` regardless of sign
([raymarch.glsl:72](../glsl/tracer/6Trace/raymarch.glsl#L72)).

That tangential zero is the only reason glass↔liquid refraction happens at all.
**Adjacent regions must share their boundary exactly.** This is a load-bearing
invariant, not an accident, and the generator must preserve it.

---

## 3 · The classifier

Replaces every hand-written `setData`. Engine-generic; runs once per bounce.

### 3.1 The rule

At a hit, evaluate every region sdf once. Let

- **V** = regions with `|f| < AT_THRESH` — whose boundary we are on
- **C** = regions with `f < -AT_THRESH` — that strictly contain the point

Then:

| case | interface | normal |
|---|---|---|
| `|V| = 2` | the two members of V | `∇f` of the higher-priority one |
| `|V| = 1`, C non-empty | V's member ↔ innermost member of C | `∇f` of V's member |
| `|V| = 1`, C empty | V's member ↔ air | `∇f` of V's member |
| `|V| ≥ 3` | the two highest-priority members | as above |
| `|V| = 0` | no hit claimed — see §3.4 | — |

Orientation comes from the ray: if `dot(dir, ∇f_k) > 0` the ray is leaving `k`,
otherwise entering it. That fixes front/back, and `setInteraction` does the rest.

**There is no probe.** An earlier draft stepped `ε` along the normal to find the
neighbour, which imposed a minimum feature thickness of `2·AT_THRESH ≈ 0.006` —
uncomfortably close to the 0.0075 variety shells. Reading the signs that
`fields()` already computed removes the step and the constraint together.

### 3.2 Worked: cocktail

`cavity` and `wall` come from one `cocktailGlassDistance` call;
`drink = max(cavity, y - height/3)`.

| point | `f_cup` | `f_drink` | V | C | interface |
|---|---|---|---|---|---|
| outer wall | ≈0 | >0 | {cup} | ∅ | cup ↔ air ✓ |
| inner wall, below water | ≈0 | ≈0 | {cup, drink} | ∅ | cup ↔ drink ✓ |
| inner wall, above water | ≈0 | >0 (`max` picks the plane) | {cup} | ∅ | cup ↔ air ✓ |
| liquid top | >0 | ≈0 | {drink} | ∅ | drink ↔ air ✓ |

The above/below-waterline distinction — the trickiest branch in the hand-written
version — falls out of `max` with no special case. The liquid-top normal,
currently hardcoded `vec3(0,1,0)`, is `∇drink`, whose active constraint there
*is* the plane.

### 3.3 Worked: varSphereGlass

| point | `f_marble` | `f_shell` | V | C | interface |
|---|---|---|---|---|---|
| variety surface | ≈0 | <0 | {marble} | {shell} | marble ↔ shell ✓ |
| ball surface, outside | ≈0 (no) / `f_shell`≈0 | ≈0 | {shell} | ∅ | shell ↔ air ✓ |

The 0.0075-thick variety slab classifies without difficulty: its two faces are
0.0075 apart and the `AT_THRESH` bands (±0.003) do not overlap.

### 3.4 Normals come from a region sdf, never the union

At an internal wall, `min(cup, drink)` has a **ridge** — negative on both sides,
zero on the wall — so its gradient is discontinuous and a finite difference
across it returns noise. This is why the existing code reaches for
`normalVec(path.tv, cocktail.glass)` specifically. The classifier always
differentiates `f_k`, never the union.

### 3.5 The empty case

`|V| = 0` means the marcher landed outside every region's hit band. Today this
silently reuses the previous bounce's `LocalData`. The classifier will instead
set a sentinel that `debugPass` can visualise, so the failure is loud.

### 3.6 What this does *not* touch

An earlier draft threaded a hit id out of the marcher. It is unnecessary — the
classifier needs none of it — and it was wrong at cocktail's inner wall, where
the argmin is a tie.

**`raymarch`, `sdf_Scene`, `odeMarch`, `ambientTransport` and the analytic-stop
path are all unchanged.** The entire redesign lives in `setData`.

### 3.7 Cost

Per hit: one `fields()` (every region), plus a 4-tap normal on one field.
Today: `at()` on every object (each a full SDF), plus a 4-tap normal, plus — for
material fields — a second `setObjectInAir` and a wasted `randomFloat()`.

The new path is the same or cheaper on every scene in the corpus, and it runs
once per bounce (≤ `maxBounces` = 50) against hundreds of march steps.

### 3.8 Analytic objects need fields too

Classification no longer distinguishes traced from marched geometry, so every
region contributes a field even when it is also analytically traced — a sphere
gets `length(p) - r`, `RoomBox` six plane distances. `trace()` remains purely an
acceleration for *finding* the hit distance.

---

## 4 · The shape tree

A region's sdf is built from a tree. Leaves are library SDF calls; interior
nodes are combinators. Justified by the corpus, not speculation:

| node | used by |
|---|---|
| `union` | everywhere |
| `intersect` | cocktail/beer/bottle drink (`cavity ∩ halfspace`) |
| `clip` (smax to a bound) | varieties, cubicSurface, kleinianSpiral clip box |
| `lattice` (`opRepLim`) | primitives beads, cubic chain |
| `transform` | every placed object |
| `stretch` (non-uniform) | cubic ×5 |
| `displace` | new — §5 |

**Not included:** material blending across `smin`. No scene does it; `smin` is
used for rounding within one material and `smax` for clipping. It was
speculative.

### 4.1 Transforms

`Frame` is a similarity (rotation + uniform scale), which is why
`toLocal`/`dirToWorld` are exact and cheap. But five scenes need anisotropic
scale and apply it *outside* `Frame`, correcting by hand.

A `transform` node carries a general linear map `M` (world → local) and emits:

- **distance**: divide the local distance by the largest singular value of `M`,
  so the result stays a conservative underestimate in world units.
- **normal**: `normalize(transpose(M) * n_local)` — the inverse transpose.

`cubic-portrait` does both by hand
([`normal.dir.y *= STRETCH_H`](../scenes/cubic-portrait/src/objects.glsl#L483)).
Generated, they cannot get out of step.

### 4.2 Shared multi-output shapes

`cocktailGlassDistance` returns the wall and, via an out-param, the cavity.
The cubic scenes fill `_cachedVal`/`_cachedGrad`/`_cachedBBox` once and five
objects consume them.

A shape instance therefore has **named outputs**, and references to the same
instance emit **one** call:

```js
const cup = cocktailGlass({ at:[-1,.1,-1.2], radius:1, height:1,
                            thickness:.1, base:.3 });
cup.wall     // { instance: cup, output: 'wall' }
cup.cavity   // { instance: cup, output: 'cavity' }
cup.height   // 1 — plain JS, params stay readable
```

Generation is a topological walk that emits each instance once into locals, then
each region's expression with references resolved. Roughly twenty lines of
common-subexpression elimination.

### 4.3 Bounds

`bound()` stays **hand-written** — choosing a bounding shape is authored
knowledge, not derivable from an SDF. The generator wires it in, unions child
bounds up the tree, and inflates by any displacement amplitude (§5.2), which is
the step most easily forgotten by hand.

`cubic-portrait`'s cross-group `if (dist > 0.001)` skip is a hand optimisation
the generator will not reproduce. Deliberate: its correctness is unclear and the
tree's hierarchical bounds cover the intent.

### 4.4 Two emissions of one tree

- `sdf_Objects` — bound-accelerated, with early-outs. Hot loop.
- `fields()` — unconditional, every region. Hits only.

Both are generated from the same tree, so they cannot drift.

---

## 5 · Procedural surfaces

### 5.1 Material fields

A material is a **field over space**; `mat` on an object is the constant case.
The modifier stack is a pure fold, `Material → Material`, sampled at the hit.

Regions therefore carry material *fields*, not values. Two scenes force this:

- **beer** varies `mfp` and `blur` with height for foam, and jitters the liquid
  normal stochastically.
- **blackholeCube** sets `interior.ior = bhIndex(hitPos)` per hit, so Snell at
  the wall and the eikonal inside are one field `n(p)`.

So the generated sampler produces a `Surface` **and both adjacent `Medium`s**:

```glsl
void sample_drink(vec3 p, inout vec3 n, inout Surface s, inout Medium m);
```

Sampling must happen at the `Material` level, **before** `setInteraction`.
`LocalData` is post-interface: it has already resolved the IOR *ratio*, split
absorption into reflect/refract, and folded in which side you are on. By then a
modifier can no longer coherently say "denser here."

### 5.2 Displacement — geometry, in the hot loop

```js
.displace(rock({ freq: 3.0, amp: 0.12 }))
```

```glsl
float region_stone(vec3 p){
    float d = sdSphere(p, 1.2);
    d += rockHeight(p, 3.0) * 0.12;
    return d / 1.36;                   //1 + Σ Lipschitz
}
```

Four consequences the generator derives, each easy to forget by hand:

1. **No analytic trace.** A displaced sphere has no closed form; the region moves
   to the marched path.
2. **No analytic normal.** `Sphere`'s radial normal is now wrong; the FD normal
   is emitted instead. Undisplaced spheres keep the exact one — this is
   selective, not a blanket removal.
3. **Inflated bound.** Displacement pushes the surface outside the original
   bound, which would otherwise cull the detail away.
4. **Lipschitz divisor.** `d + amp·sin(freq·p)` is no longer 1-Lipschitz and
   `MARCH_RELAX = 1.2` will over-step it. The descriptor carries `amp·freq`; the
   generator divides.

### 5.3 Bump — shading only, in the cold loop

```js
.bump(rock({ freq: 3.0, depth: 0.04 }))
```

Same height field, different slot. The march never sees it; the four extra taps
happen once per hit rather than once per march step — a large factor, since a
marched hit can be 50+ evaluations.

```glsl
    //bump: tetrahedral gradient of rockHeight, projected onto the surface
    const float e = 0.0005;
    vec3 g = vec3( 1,-1,-1)*rockHeight(p + e*vec3( 1,-1,-1), 3.0)
           + vec3(-1,-1, 1)*rockHeight(p + e*vec3(-1,-1, 1), 3.0)
           + vec3(-1, 1,-1)*rockHeight(p + e*vec3(-1, 1,-1), 3.0)
           + vec3( 1, 1, 1)*rockHeight(p + e*vec3( 1, 1, 1), 3.0);
    n = bumpNormal(n, g, 0.04);
```

`bumpNormal` is library GLSL: `normalize(n - depth*(g - dot(g,n)*n))` — the
tangential part of the gradient, since the component along `n` only moves the
surface, which bump does not do.

**The library's unit is a scalar height field** `float rockHeight(vec3 p, float freq)`,
so the *same* function serves both slots. A bespoke relief function returning a
perturbed normal could not, which is why this is the shape it takes.

Open: the epsilon is written as a fixed 0.0005 in local units. It should scale
with feature frequency. No principled rule yet.

**Bump on transmissive materials is unsafe.** The perturbed normal feeds Fresnel
and refraction while `side` came from the geometric test, so a ray can refract
back into the surface it just left. Safe on opaque; on glass it needs a clamp or
a rule that bump affects only the reflection lobe. To be decided, not discovered.

### 5.4 Discrete field data

Four fractal scenes colour by orbit trap or by a discrete region index computed
during iteration (`region(p, honey)` returns an int). The sampler recomputes it
at the hit — affordable in the cold loop — which gives these scenes a sanctioned
home and fixes the five that currently do not compile.

---

## 6 · What the generator emits

**Contract: readability is a comment problem, not a structure problem.** Never
emit a function whose only purpose is to name things — emit the call and
annotate it. Generated GLSL must read like something written by hand.

**The generator emits call sites and structure. Never math.** Every formula
lives in a hand-written `.glsl` file. If the generator ever needs to emit an
expression more complex than a call or a combinator, the library is missing a
function.

Region fields live in **one global array per scene**, indexed by region id — not
a struct. The array is what lets the classifier (§3) and `regionAt` be *engine*
code with a loop; a struct would force both to be generated as unrolled branches,
which is the one place the logic should not be per-scene.

```glsl
const int N_REGIONS = 2;
const int ID_CUP    = 0;
const int ID_DRINK  = 1;
const int ID_NONE   = -1;      //air

float gSDF[N_REGIONS];       //filled by fields(), indexed by ID_*

//every region's signed distance at one point
void fields(vec3 pw){
    //shape "cup" — one evaluation, two outputs used
    vec3  q = pw - vec3(-1.0, 0.1, -1.2);
    float cavity;
    gSDF[ID_CUP]   = cocktailGlassDistance(q, /*radius*/ 1.0, /*height*/ 1.0,
                                                /*thickness*/ 0.1, /*base*/ 0.3, cavity);
    gSDF[ID_DRINK] = max(cavity, q.y - 0.3333);   //cavity ∩ below the waterline
}
```

`regionAt` and the classifier are then written once, in the engine:

```glsl
int regionAt(vec3 p){
    fields(p);
    for(int i = 0; i < N_REGIONS; i++){ if(gSDF[i] < 0.){ return i; } }
    return ID_NONE;
}
```

**`fields()` is never called during the march.** `sdf_Objects` is emitted
separately as a plain bound-accelerated `min` (§4.4), so the hot loop never
touches a mutable global array. `fields()` runs once per hit, in the cold loop.

---

## 7 · The JS schema

```js
export default scene({

  camera: { position: [2,3,6], facing: [...], fov: 45 },
  sky:    '/assets/stars.jpg',

  march:  { maxDist: 20, epsilon: 0.00005 },     //optional; §8.2

  regions: [
    region('cup')
      .shape(cup.wall)
      .surface(gloss(0, 0))
      .medium(glass(0.1*[0.3,0.05,0.2], 1.5)),

    region('drink')
      .shape(intersect(cup.cavity, below(cup.height/3)))
      .medium(glass(brownAbsorb + 0.25*redAbsorb, 1.2))
      .walk(true),                                //subsurface walk opt-in
  ],
});
```

### 7.1 Names

Optional `name:`; otherwise auto-numbered by shape type (`cyl0`, `cyl1`).
Collisions are a JS error, not a shader error.

Forty cylinders sharing a material are **one region** whose field is a union —
one id, one field. The generator unrolls below ~8 placements and emits a const
array with a loop above it. Only genuinely different materials justify separate
regions.

### 7.2 Values and knobs

Any value is a number or a GLSL expression. A knob is declared where it is used:

```js
ceiling: light(1.0, knob('roomLight', { min: 0, max: 2, value: 0.4 }))
```

The generator collects them, emits the uniform declarations, and derives the GUI
panel. Today a param is declared in `settings.js` and its bare identifier typed
into GLSL with nothing checking the two match.

### 7.3 Inline GLSL

```js
.shade(glsl`mat.diffuse *= 0.5 + 0.5*sin(20.0*p.y);`)
```

Available on `shade`, `displace`, `bump`, and as a raw region sdf. One-offs stay
one-offs; anything used twice graduates to a library file.

### 7.4 Environments

`room({...})` is a JS preset expanding to six sheet-like regions — the same
copy-a-preset-with-dials ergonomic as today, without the separate
`sdf_Environment`/`trace_Environment`/`setData_Environment` contract.

---

## 8 · Scene-level fields and constants

### 8.1 Tracer hooks

Already clean `#define` + function contracts, so the generator just fills them.
They are **scene-level fields**, not escape hatches and not tree nodes:

```js
  index:  glsl`float r = max(length(p), 1e-4);
               float U = 1.0 + mass/r;
               return U*U;`,                       // → SCENE_INDEX_FIELD
  inMedium: region('cube'),                        // → IN_MEDIUM_REGION
  ambient: fog({ mfp: knob('fogMFP'), blur: knob('fogBlur') }),
                                                   // → SCENE_AMBIENT_MEDIUM
```

`blackhole` is *nothing but* a tracer hook: all eight of its contract functions
are empty stubs today.

### 8.2 March constants

`maxDist`, `EPSILON`, `MARCH_RELAX`, `MARCH_CONE` become generated `const`s. This
fixes `kleinianSpiral`, and lets the generator **derive** `AT_THRESH` from
`EPSILON*(2 + MARCH_CONE*maxDist)` instead of it being a hand-tuned coincidence
(§1.3).

---

## 9 · The library afterwards

Everything structural moves to the generator. What remains is math with plain
arguments — no `Frame`, no `Material`, no boilerplate:

```glsl
//sphere.glsl — the whole file
float sdSphere(vec3 p, float radius){ return length(p) - radius; }
vec2  intersectSphere(vec3 o, vec3 d, float radius){ … }
```

**Kept, because they are authored knowledge the generator cannot derive:** the
SDF itself, `bound()`, analytic `trace()`, extra named outputs, defining
equations, height fields, pattern/noise functions, material constructors.

**Deleted:** `OBJECT_API`, `OBJECT_INIT`, `OBJECT_LOCATORS`, `OBJECT_NORMAL_FD`,
`OBJECT_SETDATA`, `VARIETY_DATA`, `VARIETY_IN_SHELL_API`, every hand-written
`at`/`inside`/`normalVec`/`setData`, and the whole `multiMaterial/` folder.

No macros remain. Macros existed to synthesise names and interfaces the language
could not; the generator has that information directly. **If the generator ever
wants a macro, it is missing information it should have.**

`mobius.glsl` goes from ~200 lines to `sdMobius` plus two accessors.
`sphere.glsl` from ~70 to ~10.

---

## 10 · Phases

Clean break, per the decision to rebuild rather than migrate gradually. Each
phase has a target scene chosen to stress it.

| phase | scope | target |
|---|---|---|
| **0** | generator skeleton; emits today's contract; no engine change | `frameDemo`, `primitives` |
| **1** | regions, sheets, `fields()`, the classifier, generic `setData_Scene` | `cocktail`, `nested-spheres` |
| **2** | material fields — sampler emits `Surface` + both `Medium`s | `beer` (foam), `blackholeCube` (dynamic IOR) |
| **3** | the tree — transforms incl. non-uniform, intersect, clip, lattice, shared instances, hierarchical bounds | `cubic-portrait` |
| **4** | scene-level fields and march constants | `blackhole`, `luneburg`, `fx-fog` |
| **5** | library demolition | — |
| **6** | migrate the remaining ~45 pages | — |

The six targets in phases 1–4 cover every pattern found in the survey. If they
work, the rest is volume rather than risk.

---

## 11 · Constraints and risks

**Adjacent regions must share their boundary exactly** (§2.4) or internal
interfaces vanish from the march.

**Region declaration order is priority.** Inner to outer. Deterministic and
documented, unlike today's last-writer-wins.

**Generated code must be dumpable.** A generator bug breaks all 56 pages at once.
Mitigations: emit readable GLSL with real line numbers, surface it in
[ErrorOverlay.js](../js/gui/ErrorOverlay.js), and keep golden generated output for
two reference scenes diffed by a test.

**Verification is by eye.** A clean break invalidates every render-test baseline;
they are already stale for ~21 subsurface scenes, and 5 scenes do not compile, so
no before/after comparison exists for those. Byte-identical output is explicitly
not a goal.

**Open items:**

- bump epsilon should scale with feature frequency (§5.3)
- bump on transmissive materials needs a rule (§5.3)
- sheets: front/back `Surface` selection, and the non-orientable fallback, want
  confirming against `ref-thin` during phase 1 (§2.1)
- `|V| ≥ 3` (three coincident boundaries) resolves by priority; no scene
  currently does this
