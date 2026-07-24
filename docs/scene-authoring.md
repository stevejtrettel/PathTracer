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
import {scene, object, lib, makeGlass, room, sphereLight} from '../../../js/scenegen/index.js';

export default scene({
    objects: [
        object('ball', {
            at:       [-1.0, 1.1, -1.2],
            shape:    lib.sphere({radius: 1.2}),
            material: makeGlass([0.03, 0.005, 0.02], 1.5),
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
```

---

## 2 · Objects

A scene is a list of nodes, **declared inner-to-outer** — declaration order is
containment priority, and at a wall two objects share, the earlier one owns
the Surface. Three node kinds:

- `object(name, {...})` — one region of space (a signed sdf; negative inside)
- `group(name, {...})` — one authored sdf evaluation feeding several regions (§4)
- `sheet(name, {...})` — a two-sided surface with no interior (§9)

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
names multi-outputs; `//@noshape` opts a helpers-only file out). Adding a
library shape = writing one `.glsl` file.

**Routing is derived**: a plain library shape with a `Trace` is analytic (it
never marches); displacing, repeating, or transforming it removes the closed
form, so it marches.

**Two shape wrappers** exist, and only these:

```js
shape: displace(lib.sphere({radius: 2.0}), {by: rockHeight, amp: rockAmp})   //§7
shape: repLim(lib.sphere({radius: 0.32}), {spacing: 1.0, limit: [2, 0, 1]})
```

`repLim` folds the query point into one lattice cell — one sdf evaluation no
matter how many copies, all of them one region with one material. Keep the
base shape centered and inside its cell (a sphere is always safe); an
off-center shape can make the fold overestimate distance at cell walls, which
the marcher punishes as tunneling.

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

Constant materials are the JS mirrors of the GLSL constructors — same names,
same arguments (`docs/material-system.md`):

```js
material: makeGlass(absorbFor([0.85, 0.92, 0.9], 2.0), 1.5, 1.0)
material: makeSubsurface(absorbFor(waxTint, waxDepth), 1.45, waxDensity, waxBlur)
```

The constructor's kind does two jobs silently: `medium_` returns `.interior`
for volume/subsurface materials and `defaultMedium()` otherwise, and any
`makeSubsurface` in the scene derives `SCENE_SUBSURFACE` (compiling the medium
walk in). A **material field** is an authored body instead — sampled fresh at
every hit:

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

- a library shape's `<stem>Bound` is used automatically
- a displaced shape's bound is the base pushed out by `maxAbs(range)*amp`
- everything else (`repLim` lattices, transformed bodies, custom groups) takes
  an authored `bound:` expression — which also *overrides* any derivation

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
per-scene overrides via `knobs: {roomLight: {max: 3}}`), `sphereLight()`, and
the field presets live in `js/scenegen/presets.js`. When a pattern repeats
across ports, make it a preset — never new core machinery.
