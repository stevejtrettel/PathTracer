# Writing a scene

The practical guide to authoring scenes with scenegen. Design rationale lives
in [generator.md](generator.md) and [scene-system.md](scene-system.md); the
material model in [material-system.md](material-system.md). This is the
how-to.

Two rules govern everything here:

- **Explicit descriptions, formulaic generator.** The generator derives only
  fixed formulas over data the description declares; anything that *knows*
  particular math (noise gradients, the standard room) is a preset you import.
- **Authored GLSL references nothing magical.** Your GLSL may name only things
  defined in authored GLSL, knobs declared in the same file, and interpolated
  JS values — never the emitter's derived const names.

---

## 1 · A scene folder

```
scenes/<name>/
  index.html            boilerplate page (copy from any scene)
  main.js               the 7-line stub below
  src/scene.js          THE SCENE — everything below is about this file
  src/settings.js       machine-written: camera pose, uiParams, knob VALUES
```

```js
// main.js — identical in every scene
import createScene from "../../js/createScene.js";
import {emit} from "../../js/scenegen/index.js";
import description from "./src/scene.js";
import settings from "./src/settings.js";

createScene(emit(description, settings));
```

The smallest real scene:

```js
import {scene, object, lib} from '../../../js/scenegen/index.js';
import {room, sphereLight, glass} from '../../../js/presets/index.js';

export default scene({
    objects: [
        object('ball', {
            at:       [-1.0, 1.1, -1.2],
            shape:    lib.sphere({radius: 1.2}),
            material: glass({absorb: [0.03, 0.005, 0.02], ior: 1.5}),
        }),
        sphereLight({at: [-7.0, 4.0, 2.0], radius: 1.5, power: 100}),
        room({center: [-5.75, 6.5, -5.0], half: [14.25, 7.5, 15.0]}),
    ],
});
```

Everything else — ids, dispatchers, 4-tap normals, trace wrappers, entry
points — is emitted. Inspect the result any time:

```
npm run gen <scene>              print the emitted GLSL chunk
npm run gen -- --catalogue       what the shape parser found in glsl/shapes/
npm run gen -- --materials       what the material parser found in 3Materials/
npm run gen -- --goldens         byte-compare every scene vs its committed golden
```

---

## 2 · Objects

A scene is a list of nodes, **declared inner-to-outer** — declaration order is
containment priority, and at a wall two objects share, the earlier one owns
the Surface. Three node kinds:

- `object(name, {...})` — one region of space (a signed sdf; negative inside)
- `group(name, {...})` — one authored sdf evaluation feeding several regions (§4)
- `sheet(name, {...})` — a two-sided surface with no interior (§9)

Names (nodes and regions alike) share one scene-wide namespace and are
checked loudly: unique (case-insensitively), never a GLSL keyword or one of
the emitter's own locals (`d`, `p`, `q`, ...).

Placement lives on the node: `at: [x,y,z]` always; optionally
`scale: [sx,sy,sz]` and `rotate: {axis, angle}` (angle may be a knob). The
emitter writes `toLocal_<name>` and, for a non-uniform scale, the
min-singular-value Lipschitz factor. Normals need no fixup anywhere — the
4-tap differentiates the world sdf and the chain rule does the rest.

## 3 · Shapes

**Library shapes** come from the catalogue, which is parsed straight out of
`glsl/shapes/*.glsl` (there are no companion JS files):

```js
shape: lib.sphere({radius: 1.2})        //params by name; typos throw with the real names
```

A shapes file follows the naming convention (`<stem>Distance(vec3 p, ...)`
required; `<stem>Trace(Vector tv, vec3 centre, ...)` and
`<stem>Bound(vec3 p, ...)` optional; file name == stem; `//@shape stem -> a, b`
names multi-outputs; `//@noshape` marks a helpers-only file — include-only,
referenced via `uses: [lib.<stem>]`, an error to call). Adding a library
shape = writing one `.glsl` file.

**Routing is derived**: a plain library shape with a `Trace` is analytic (it
never marches); displacing, repeating, or transforming it removes the closed
form, so it marches.

**Shape modifiers** take one shape and return one shape, so they **stack** —
nesting order is application order, innermost first
([shape-modifiers.md](shape-modifiers.md); `scenes/chain/` is the demo):

```js
shape: displace(lib.sphere({radius: 2.0}), {by: rockHeight, amp: rockAmp})   //§7
shape: repLim(lib.sphere({radius: 0.32}), {spacing: 1.0, limit: [2, 0, 1]})
shape: carve(lib.sphere({radius: 1.9}), {octaves: 6, erosion, gain, blend, seed: 0})
shape: accrete(lib.sphere({radius: 1.4}), {erosion, gain})   //carve's mirror: blobs GROW on the surface (gain < 1)
shape: mirror(lib.gem({size: 1.0}), {axes: 'xz'})            //fold across coordinate planes
shape: radial(lib.box({halfSize: [...]}), {n: 7, axis: 'y'}) //n-fold symmetry about an axis
shape: round(lib.box({halfSize: [...]}), {r: 0.1})           //offset the surface outward
shape: shell(lib.gem({size: 1.4}), {thickness: 0.06})        //keep a skin (>= 0.006)
shape: clip(base, {to: lib.plane({normal: [0,1,0]}), at, blend})     //intersect with a volume
shape: subtract(base, {what: lib.sphere({radius: 1.25}), at, blend}) //carve a volume away

//stacks: an eroded lattice disc; a grid of holes (the cutter is a chain too)
shape: clip(repLim(lib.sphere({radius: 0.32}), {spacing: 1, limit: [3,0,3]}), {to: lib.sphere({radius: 2.4})})
shape: subtract(lib.box({halfSize: [1,1,1]}), {what: repLim(lib.sphere({radius: 0.2}), {spacing: 0.5, limit: [1,1,1]})})

//the ESCAPE HATCH: an authored field mod — expr reads d and the folded q,
//and you DECLARE the bound ('keep' | {inflate: v}). authored-modifiers.md;
//scenes/modifier/ is the demo
shape: modifier(lib.sphere({radius: 1.0}), {expr: glsl`smax(d, 0.45 - length(q.xz), ${bite})`, bound: 'keep'})
```

Two rules order a stack, both checked loudly. A **domain** modifier
(`repLim`, `mirror`, `radial` — they fold the query point) must sit inside
any **field** modifier (everything else — they act on the distance). And
`carve`/`round`/`shell` must sit inside any `displace` — displacement breaks
the true-distance property they rely on.

Frames: `carve` and `displace` act on the **folded** point, so every
lattice/wedge copy gets identical detail. `clip`/`subtract` cutters are
**placed volumes** — they act in the object's own (pre-fold) frame and cut
the whole assembly. A material's `q` is always the unfolded point.
`rotate`/`scale` on the node compose with all of it.

`repLim` folds the query point into one lattice cell — one sdf evaluation no
matter how many copies, all of them one region with one material. Keep the
base shape centered and inside its cell (a sphere is always safe); an
off-center shape can make the fold overestimate distance at cell walls, which
the marcher punishes as tunneling.

`carve` is displacement's structural opposite, and the difference is worth
knowing before choosing between them. Displacement ADDS a height field, which is
not a distance field: it costs a Lipschitz divisor at every march step and an
inflated bound, so it stays affordable only for gentle bumps. Carving SUBTRACTS
a distance field — an fbm of sphere lattices, smooth-maxed out of the solid
(`opCarveFbm`, IQ's fbmSDF) — and a smooth max of distance fields is still one.
So the detail is free to march, and because carving only ever ERODES, the
**uncarved base is already a valid bound** and is emitted as one unchanged.
`gain` is the dial: at `gain <= 1/lacunarity` (0.5) every octave is 1-Lipschitz
and nothing is paid; above it the operator divides by the steepest octave, which
the marcher feels. The carving field is built in, the way `repLim`'s fold is —
letting a caller pass their own distance field is a later addition.

Anything fancier than these is an **authored sdf body** (see §5), not a new
wrapper.

## 4 · Groups — one evaluation, several regions

A multi-material object is one shape evaluation feeding several region slots
(evaluating it once is the point). The body assigns each region name directly;
`q` (local) is in scope, and region declaration order is containment priority:

```js
group('cocktail', {
    at:   [-1.0, 0.1, -1.2],
    uses: [lib.cocktailGlass],                  //authored code calls into this file
    consts: glsl`
        const float COCKTAIL_RADIUS    = 1.0;
        const float COCKTAIL_HEIGHT    = 1.0;
        const float COCKTAIL_THICKNESS = 0.1;
        const float COCKTAIL_BASE      = 0.3;
        const float DRINK_LEVEL        = COCKTAIL_HEIGHT/3.0;
    `,
    sdf: glsl`
        float cavity;
        cup   = cocktailGlassDistance(q, COCKTAIL_RADIUS, COCKTAIL_HEIGHT, COCKTAIL_THICKNESS, COCKTAIL_BASE, cavity);
        drink = max(cavity, q.y - DRINK_LEVEL);
    `,
    bound: glsl`cocktailGlassBound(q, COCKTAIL_RADIUS, COCKTAIL_HEIGHT, COCKTAIL_BASE)`,
    regions: {
        cup:   {material: ...},                 //declared first: owns the shared wall
        drink: {material: ..., medium: ...},
    },
})
```

The emitter writes the `out float` signature, the per-region wrappers the
4-tap normals need, the shape-major `sdfAll` call, and the group form of
`sdf_Scene` (the bound guards ONE evaluation).

## 5 · Authored GLSL — the glsl`` tag

Any slot accepts authored GLSL: a `` glsl`...` `` fragment, a scene-local
`.glsl` file imported `?raw`, or scene-level `glsl: [src]` blocks emitted
verbatim before the objects (the home of helper functions). What each slot
sees:

| slot | in scope | body is |
|---|---|---|
| `sdf:` (group) | `p`, `q`, region names as out params | statements assigning regions |
| `bound:` | `p`, `q` | one expression |
| `material:` | `p`, `q`, `inout Vector n` | statements returning a `Material` |
| `medium:` | `p` | statements returning a `Medium` |
| field function | takes `vec3 q` | a complete function |

`q`'s frame depends on the slot (it matters only on a transformed node):
a **material** body reads the object's own local frame (`toLocal_<name>(p)`
when transformed, so a texture rides the rotation/scale), while a **bound**
reads the placement frame (`p - <at>`, a world-space enclosing volume — author
it rotation-invariant, as the transform scene does). On a plain or displaced
node the two coincide.

Interpolation `${...}` accepts knobs, fields, numbers, `[x,y,z]` vectors,
material constructors, and nested fragments. It is **required for fields**
(that's how the emitter learns the dependency) and optional for knobs (they
are global uniforms). To keep folded constants readable in the output, name
them — `${{latticeHalf}}` (JS shorthand) emits `/*latticeHalf*/vec3(...)`:

```js
const latticeHalf = limit.map(l => spacing*l + beadRadius);
bound: glsl`bBox(q, ${{latticeHalf}})`,
```

And the no-magic rule again, since this is where it bites: share values as
plain JS bindings and interpolate them; never write `BEADS_SPACING` in
authored code just because the emitter happens to generate that const.

## 6 · Materials and knobs

A material is not code — it is a point in the parameter space of the ONE
model (the `Surface`/`Medium` structs in `3Materials/material.glsl`). So a
material is a **value bundle**, and *everything named is a preset*: one flat
space imported from `js/presets/`, from the archetypes (the model's canonical
menu) down through their specializations. Named arguments are the model's REAL
field names — no renames — so a scene and its emitted chunk speak one
vocabulary:

```js
material: glass({absorb: absorbFor([0.85, 0.92, 0.9], 2.0), ior: 1.5})   //transmit defaults to 1 (clear)
material: subsurface({absorb: absorbFor(waxTint, waxDepth), ior: 1.45, mfp: waxDensity, blur: waxBlur})
material: metal({specular: [0.92, 0.8, 0.52], roughness: bodyRough})     //specular is the F0
material: gold({roughness: 0.3})                                          //a look: a preset over metal
material: withCoat(gold({roughness: 0.3}))                               //modifiers merge fields into a base
```

The one primitive is `material({surf: {...}, interior: {...}})` — the escape
hatch for raw struct fields, the way authored `glsl\`\`` is the escape hatch for
sdfs. It lives in `js/scenegen/`; every named material is a preset over it.

The emitter builds each object's material function from the bundle —
`defaultMaterial()` plus assignments — and **each value is emitted exactly
once**: Medium fields land in `medium_<name>`, and `material_<name>` composes
it (`m.interior = medium_<name>(p)`). No duplication to keep in sync.

KIND is derived structurally from *which fields the bundle sets* (never from
values, so a knob stays live): setting `mfp` → subsurface; `transmit` plus any
interior field → volume; otherwise surface. Kind does two jobs silently —
`medium_` carries a real interior only for volume/subsurface, and any
subsurface material derives `SCENE_SUBSURFACE` (compiling the medium walk in).

A **material field** is an authored body instead — sampled fresh at every hit.
It writes the struct directly, or calls the legacy `make*` constructors still
compiled into every shader (retained for authored GLSL and the not-yet-ported
legacy scenes):

```js
material: glsl`
    float h = ${rockHeight}(q);
    ...
    return makeGloss(col, 0.02, mix(0.7, 0.32, w));
`,
```

**Knobs** are live GUI controls, declared at their point of use and usable
wherever a number goes:

```js
const rockAmp = knob('rockAmp', {label: 'Displacement', min: 0, max: 0.6, step: 0.005, value: 0.28});
```

Declarations (name, label, range, default) live in scene.js; current VALUES
live in settings.js, which Save-to-Scene writes — the loader merges the two.
Names are global uniforms: unique per scene, collisions are a loud error.

## 7 · Fields and displacement

A field is one named function driving several things at once — the rock's
height field displaces the sdf AND colours the surface, and the two cannot
drift because they are the same function. One kind exists: a function you
wrote, plus the facts the emitter cannot derive from code:

```js
const rockHeight = field(glsl`
    float rockHeight(vec3 q){
        return fbm2(${rockFreq}*q) - 0.5;
    }
`, {gradBound: glsl`2.01*${rockFreq}`, range: [-0.5, 0.5]});
```

`gradBound` and `range` are required only to displace; from them the emitter
derives the Lipschitz divisor `1 + amp*(gradBound)` and the bound inflation
`maxAbs(range)*amp` — the two numbers an author forgets, and forgetting is
not "a bit slow", it lets the marcher miss the surface. The standard cases
are presets with the declarations pre-filled (the noise gradient constants
live THERE, not in the core):

```js
const rockHeight = fbm2Height('rockHeight', rockFreq);    //|grad fbm2(f q)| <= 2.01 f
```

## 8 · Bounds

Bounds are the marcher's acceleration structure (they exist only in
`sdf_Scene`; `sdfAll` stays exact so the classifier can recognise surfaces).
Derived where principled, authored otherwise:

- a library shape's `<stem>Bound` is used automatically — and a domain fold
  (`repLim`/`mirror`/`radial`) folds it along: `<stem>Bound(opRepLim(...))`
- a displaced shape's bound is the base pushed out by `maxAbs(range)*amp`;
  a carved/subtracted one keeps the uncarved base; a shelled or rounded one
  inflates it; a **clipped** one is *replaced by the cutter* — which is how a
  lattice or a limit set gains a bound it could not otherwise have
  (full table: [shape-modifiers.md](shape-modifiers.md) §5)
- everything else (a bare `repLim` of a `Bound`-less shape, transformed
  bodies, custom groups) takes an authored `bound:` expression — which also
  *overrides* any derivation

Cheap exact shapes (a plain sphere) need no bound: their sdf already is one.

## 9 · Sheets, nesting, sky

**Sheets** are two-sided surfaces with no interior — both sides open onto
whatever contains them (index-matched, no refraction), contributing only two
Surfaces:

```js
sheet('bubble', {
    at:    [1.6, 1.3, -1.2],
    shape: lib.sphere({radius: 1.3}),
    front: glsl`sheetFace(${frontTint}, ${sheetGloss})`,     //front = gradient side
    back:  glsl`sheetFace(${backTint}, ${sheetGloss})`,
})
```

**Nesting is declared, never inferred.** A region inside another region's
solid says so, and must be declared first (inner-to-outer):

```js
object('core',  {nestedIn: 'shell', ...}),      //yields the exclusion term in inside_shell
object('shell', {...}),
```

This matters only in scattering scenes, where it feeds the emitted
`inside_`/`insideOf` the medium walk queries.

**Sky** is scene identity, declared in the description:

```js
sky: {type: 'image', src: '/assets/office.jpg'}     //or {type:'solid'|'gradient', ...}
```

## 10 · Presets

A preset is plain JS returning nodes or fields — ordinary schema use, written
once, imported everywhere. `room()` (the six-wall box with its knobs;
per-scene overrides via `knobs: {roomLight: {max: 3}}`), `sphereLight()`, the
field presets, and the named Kleinian boxes (`kleinianStandardBox`,
`kleinianSeahorse` — a shape's classic parameter bundles, `fractals.js`) live
in `js/presets/` (one file per domain, own index) —
**content, outside the generator**: presets import from scenegen's public
surface, never the reverse. When a pattern repeats across ports, make it a
preset — never new core machinery. Named *materials* are ordinary presets
too — the archetypes (`matte`…`glow`) and their specializations alike, one
flat space in `js/presets/materials.js` over the `material()` primitive (see
§6, §11).

## 11 · When you write new GLSL

The extension contract — what each kind of addition requires:

| you add | write | and that's it? |
|---|---|---|
| a shape | `glsl/shapes/<stem>.glsl` per the §3 convention | yes — `lib.<stem>` appears |
| a shared helper file | a `glsl/shapes/` file topped with `//@noshape` | yes — reference it with `uses: [lib.<stem>]`; calling it as a shape is an error |
| a named material (terracotta, honey, …) or a new archetype | nothing in GLSL — it's *values* | a function returning a bundle in `js/presets/materials.js` — over an archetype (`gloss`, `glass`, …), or over `material()` for a new archetype |
| a new material *capability* (a field the model lacks) | the field on the `Surface`/`Medium` struct in `material.glsl` + its handling in the tracer | nothing in scenegen — `SURF_FIELDS`/`MEDIUM_FIELDS` are parsed from the struct, so `material({...})` accepts the new field automatically; add an archetype preset if it deserves a name. Genuine model surgery, rare by design |
| a noise / field function | the function in `3Materials/fields.glsl` (derive its gradient bound in a comment there) | a field preset in `js/presets/fields.js` declaring `{gradBound, range}` — the bound is human math, it cannot be parsed |
| an operator (`op...`) | `glsl/shapes/ops/` (vocabulary, always compiled) | yes — authored bodies see it; to make it a first-class `shape:` modifier, see the next row |
| a shape modifier | the `op...` as above, its bound effect (and divisor, if distorting) derived in its comment | a short combinator in `js/scenegen/combinators.js` + an `index.js` export — the derivations are human math, *declared* there, never parsed. Recipe: `shape-modifiers.md` §11 |
| a one-off modifier experiment | nothing — `modifier(base, {expr: glsl\`…\`, bound})` right in the scene | yes, but the declared bound is your promise (`authored-modifiers.md`); promote it per the row above when it earns a name |
| a repeated scene pattern | a preset in `js/presets/` | yes — plain JS over the public schema |

If an addition seems to need new machinery in `js/scenegen/`, stop and treat
it as a schema-design question first.
