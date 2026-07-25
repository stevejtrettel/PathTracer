# Shape data outputs: geometry-produced data for material coloring

A shape can expose **data outputs** — named functions of the local point, beyond
its distance — and a material colors by reading them. The emitter injects each
one into the material body with the object's own parameters baked in, exactly the
way it injects `q`. The palette that maps the data to a colour stays authored (it
is art); only the *channel* is mechanised.

This is not a new *kind* of thing — the room already did it ad-hoc (`roomFace`
picks the wall, the material switches on it). This formalises that pattern and
kills its one rough edge (the material re-passing the shape's parameters).

## The one rule

**A data output is a shape function named `<stem><Name>Data(vec3 q, …params)`;
a material that reads `<name>Data` gets it injected.**

- The **`Data` suffix** marks it — self-identifying, so the catalogue
  auto-detects it (no annotation), and a private helper never becomes one by
  accident.
- **params ⊆ the Distance parameters** (validated, like `<stem>Bound`), so the
  emitter can bake the object's own consts into the call — the data can never
  drift from the geometry.
- The injected variable name is the suffix with the stem stripped, first letter
  lowered: `kleinianSpiralOrbitTrapData → orbitTrapData`, `roomFaceData → faceData`.

## What the author writes

Shape file (`glsl/shapes/`):
```glsl
float <stem>Distance(vec3 p, int iterations, …){ … }         // required, as always
//                                                            no annotation needed:
vec4  <stem>OrbitTrapData(vec3 q, int iterations){ … }        // the Data suffix IS the marker
```

Scene material — reads the injected name, maps it however it likes:
```js
material: glsl`
    vec3 c = base + strength*(X*orbitTrapData.x + Y*orbitTrapData.y + …);
    return makeGloss(c, 0.2, 0.05);
`   // orbitTrapData is injected because the body reads it; the palette is yours
```

Emitted:
```glsl
Material material_klein(vec3 p, inout Vector n){
    vec3 q = p - KLEIN_P;
    vec4 orbitTrapData = kleinianSpiralOrbitTrapData(q, KLEIN_ITERATIONS);  // injected, params baked
    vec3 c = base + strength*(X*orbitTrapData.x + …);
    return makeGloss(c, 0.2, 0.05);
}
```

The injection fires only when the body references the name (the `qLine` rule), so
scenes that don't use data are byte-identical.

## The `int` / region-id variant is the same channel

The hyperbolic honeycombs tag a point with which chamber it landed in. That is a
`regionData` output (`int <stem>RegionData(vec3 q, …)`), coloured by an authored
switch — the **room pattern**, one mechanism for every id-based material:
```js
material: glsl`
    if(regionData == SEG_A){ return makeGloss(COL_A, …); }
    if(regionData == FLOOR){ return makeGloss(floorTint(q), …); }
    …
`
```

## `roomFace` is migrated onto this

`glsl/shapes/room.glsl`: `roomFace` → `roomFaceData`. The `room()` preset's
material drops its hand-passed `half` and reads the injected `faceData`. Behaviour
is identical (same function, same baked arg = `ROOM_HALFSIZE`); the emitted text
changes, so every room scene's golden rebakes once. This is the validation that
the mechanism works on a real, shipping scene — and it is simply cleaner.

## The data output family (why this earns a mechanism)

Not a fractal one-off — the space is broad and leans toward the variety bucket:

| output | shapes |
|---|---|
| `orbitTrapData` (vec4/vec3/float) | Kleinian / Apollonian fractals |
| `regionData` (int) | hyperbolic honeycombs, tilings, the room (`faceData`) |
| `cellData` (which lattice copy) | `repLim` lattices |
| `uvData` (surface coordinates) | textured surfaces — the **variety** scenes |
| `curvatureData` (Gaussian/mean) | mathematical surfaces — the **variety** scenes |
| `aoData` / interior depth | crevice shading, subsurface depth |

## Consistency (it composes patterns we already trust)

| this design | the pattern it mirrors |
|---|---|
| inject `…Data` when the body reads it | `qLine` (inject `q` on reference) |
| bake the object's consts into the call | `indexField_<name>(p − LENS_P)` (curved media) |
| catalogue parses the fn, params ⊆ Distance | `<stem>Bound` parsing |
| palette authored, data injected | rock/marble authored material + a field |

## What is NOT touched

**Pure generator change** — catalogue parsing + one emitter injection. **No
engine change.** (The Kleinian `maxDist`/`EPSILON` override is a separate,
spiral-only question, deferred.) The ad-hoc path still works too: a material may
always call a shape function directly; the channel just adds param-baking and the
clean injected name.

## Staging

1. **The mechanism** — catalogue auto-detects `<stem>…Data`; emitter injects on
   reference. Migrate `roomFace → roomFaceData` (rebakes room goldens,
   behaviour-frozen). A test confirms injection + that renders are unchanged.
2. **Prove it on the fractals** — orbit-trap scenes and the region-id honeycombs
   author palettes over `orbitTrapData` / `regionData`.
3. **Deferred** — the spiral's engine-const override; fractal-DE marching stability.

Later, `…Data` references could also be allowed inside *bundle* field expressions
(the beer-foam `q`-in-bundle mechanism), so a `subsurface({diffuse: glsl\`…curvatureData…\`})`
works — but authored bodies cover every current case.
