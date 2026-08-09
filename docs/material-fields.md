# Material fields

How material data stops being a constant and becomes a *field* — a function of
position (and, for free, wavelength) supplied by the scene. Companion to
[curved-light-blackhole.md](curved-light-blackhole.md), whose `indexField` was
the first field in this family.

> TL;DR — two mechanisms, both scene-owned, both zero-cost when unused:
> **(1) surface fields**: in `setData_Objects`, sample a `Material` at the hit
> point and hand it to `applyMaterial(path, mat)`
> (now `setData_Scene` in [scene.glsl](../glsl/tracer/5Scene/scene.glsl)) — every
> field of `Material` (albedo, roughness, specularity, emission, IOR…) can vary
> over the surface. **(2) volume fields**: `indexField(p)` + the bounded-medium
> contract, exactly as before, except the `return 1.;` boilerplate is gone —
> the engine supplies that default; a medium scene `#define SCENE_INDEX_FIELD`s
> above its real one. Demo: [scenes/luneburg](../scenes/luneburg) (the original
> `scenes/marble` demo was retired in the materials overhaul).

## The taxonomy

Material data divides by *where the tracer consumes it*:

- **Surface data** — consumed once, at a hit point: `diffuseColor`,
  `specularColor`, `roughness`, `surfaceEmit`, the scatter chances, the
  interface `IOR`. Making these spatial is cheap and exact: sample the field at
  the hit and run the ordinary machinery on the sampled values.

- **Volume data** — consumed *along a segment*: the refractive index `n(x)`,
  absorption, volume emission, scatter density. A single sample cannot
  represent a varying field; it must be **integrated**. `indexField` is our
  one volume field so far, and it needed its own integrator
  ([odeMarch.glsl](../glsl/tracer/6Trace/odeMarch.glsl)). Spatially varying
  absorption/scatter would be the next member (per-step Beer accumulation or
  Woodcock tracking) — designed-for but not built.

**Wavelength is an orthogonal axis, not a third kind.** Under spectral
dispersion every ray carries a global `waveLength`
([spectral.glsl](../glsl/tracer/1Setup/spectral.glsl)); any scene-written field
function may read it. A wavelength-dependent albedo needs no new machinery —
the hero-wavelength accumulation already integrates the spectrum.

## Surface fields: `applyMaterial`

The scene's `setData_Objects` already runs at the hit point with full path
state — it is the natural (and, in GLSL, the *only* clean) place to vary a
material: there are no function pointers, so "attach a color function to this
object" cannot be expressed in the object API without macro contortions, and a
macro hook would be type-level when variation is naturally per-instance.

Instead the pattern is a **followup**: let the standard `setData` do geometry
and the flat base material, then resample and reapply:

```glsl
void setData_Objects(inout Path path){
    setData(path, ball);
    if( at(path.tv, ball) ){
        vec3 p = toLocal(ball.frame, path.tv.pos);   // local: pattern rides with the object
        Material m = ball.mat;
        m.diffuseColor = grainColor(p);
        m.roughness    = grainRough(p);
        applyMaterial(path, m);
    }
}
```

`applyMaterial(path, mat)` re-runs `setObjectInAir` with the freshly sampled
material and the normal/side the standard `setData` already computed — so
two-sidedness, the flipped normal, IOR ratios, dispersion (`iorAt`), and the
volume handoff (`refractAbsorb` etc.) all stay in engine code. The scene never
touches `LocalData` fields directly (the fragile pre-`applyMaterial` version of
this pattern — overriding `path.dat.surfDiffuse` by hand — knew too much about
which field which ray type reads).

Two conventions:

- **Sample in local coordinates** (`toLocal(obj.frame, path.tv.pos)`) so the
  pattern moves/scales with the object. Use world position deliberately when
  the pattern should be pinned to the world instead.
- **Start from `obj.mat`** and override only what varies — the base material
  keeps carrying everything you didn't make spatial.

Implementation notes: `setObjectInAir` records `dat.side` (−1 inside, +1
outside — same convention as `setSurfaceInMat`; the field existed but was never
written before this). `applyMaterial` recovers the geometric normal from the
stored back-facing one and calls `setObjectInAir` again. It covers the
object-in-air case; multi-material objects (glass shells, liquids) build their
interfaces with `setMaterialInterface` directly in their custom `setData`s and
can resample the same way before calling it — a dedicated helper can be added
if a scene ever wants a varying material *behind* an interface.

## Volume fields: the scene-hook contract

`indexField` established the pattern: an **optional scene-supplied function
with an engine default**, consumed by the tracer. Previously the default lived
as boilerplate in every scene (`float indexField(vec3 p){ return 1.; }` ×
~50 files). Now the engine owns the default, guarded the same way
`IN_MEDIUM_REGION` always was:

```glsl
// in odeMarch.glsl (compiled after the scene chunk — include order is what
// makes scene-defined hooks visible to the tracer)
#ifndef SCENE_INDEX_FIELD
float indexField(vec3 p){ return 1.; }
#endif
```

A scene with no medium says nothing. A medium scene announces its field:

```glsl
#define SCENE_INDEX_FIELD
float indexField(vec3 p){ ... }               // the smooth field
#define IN_MEDIUM_REGION(p) inLens(p)         // bounded media only (see below)
```

The full bounded-medium contract (smooth field continued past the wall, the
geometric gate, the dynamic-IOR wall) is unchanged — see
[curved-light-blackhole.md](curved-light-blackhole.md).

### The hook family

All scene-supplied hooks the tracer knows about, in one place:

| hook | kind | default | opt-in |
|---|---|---|---|
| `indexField(vec3 p)` | volume (integrated by `odeMarch`) | `1.` (no medium) | `#define SCENE_INDEX_FIELD` + definition |
| `IN_MEDIUM_REGION(p)` | gate for bounded media | `true` (unbounded) | `#define IN_MEDIUM_REGION(p) …` |

Future volume fields (`absorbField`, `emitField`, `scatterField`) should join
this table with the same shape: engine default under `#ifndef SCENE_…`, scene
defines the macro plus the function. Adding a hook never touches existing
scenes.

## What deliberately did not change

`Material`, `Path`, `LocalData` layout (only the dead `side` field is now
written), `scatterPath`, `updatePath`, the object API macros, and every
multi-material `setData`. Scenes that use no fields compile to byte-identical
shaders (the sweep was verified with a full before/after render-test pass).
