# Curved light in scenegen: media as objects with a varying IOR

How the scene generator emits variable-index (graded-index) media — black holes
and lenses — over the engine's ODE marcher. This is the authoring layer for the
physics in [curved-light-blackhole.md](curved-light-blackhole.md): that file is
the *engine* contract (how `odeMarch` bends light); this file is the *scenegen*
contract (what a `scene.js` writes and what the emitter prints).

## The one rule

**A medium is an object whose interior IOR is a position-varying field.**

That's the whole authoring surface. No scene-level hooks, no flags:

```js
object('lens', {
    at:    [0, 3, 0],
    shape: lib.sphere({radius: 3.0}),
    material: glass({
        ior:    glsl`sqrt(max(2.0 - dot(q, q)/9.0, 0.0))`,   // ← a field of q, not a constant
        absorb: glsl`vec3(0.0)`,
    }),
}),
```

An `ior` that is a `glsl\`\`` expression (reading `q`, the object's own local
frame) instead of a number is the entire signal. Everything else — the geometric
confinement, the ODE integration, the dynamic-IOR wall — is derived from it.
This is the same structural-derivation idea as `matKind` (subsurface derives from
`mfp` being set): the *kind* of thing follows from *how* a field is set, never
from parsing authored code.

## Why per-region, not a global field

The engine used to take a single global `indexField(p)`. That can't express two
different media in one scene — which is why three black holes had to be summed by
hand into one function. The per-region model keys the field to the region:

```glsl
bool  isMedium(int id);              // is this region a curved medium?
float indexFieldOf(int id, vec3 p);  // its index n(p), 1.0 = vacuum
```

so a lens and a black hole (or two holes with different masses) are just two
medium objects. `odeMarch` reads which region the ray is traversing off
`path.region` — the state the engine **already** carries for the subsurface walk
("am I still inside THIS region?") — and integrates that region's field. Carrying
the region *id* and deriving the field (`indexFieldOf(path.region, p)`) is the
house rule, the same one `iorRatio` follows ("DERIVED, not stored … a cached copy
is one more thing that can disagree").

## What the emitter emits

For each medium region `<name>`, in a **media section** printed after the fields
and before the sdfs/materials (so both dispatchers and the wall can call it):

```glsl
//--- the media — a per-region varying index the ODE marcher bends light through
float indexField_lens(vec3 q){
    return sqrt(max(2.0 - dot(q, q)/9.0, 0.0));
}
bool isMedium(int id){ return id == ID_LENS; }
float indexFieldOf(int id, vec3 p){
    if(id == ID_LENS){ return indexField_lens(p - LENS_P); }
    return 1.0;   //not a medium: vacuum
}
```

The `indexField_<name>` function is the **single source**. `indexFieldOf` calls
it (for `odeMarch`), and the region's own `medium_<name>` sets its IOR to the same
call — that's the dynamic-IOR wall, so Snell at the surface matches the interior
eikonal with no duplication:

```glsl
Medium medium_lens(vec3 p){
    Medium m = defaultMedium();
    m.ior    = indexField_lens(p - LENS_P);   // the wall refracts by the field itself
    ...
}
```

Plus:
- **`SCENE_HAS_MEDIA`** is added to `settings.defines`, standing down the engine's
  `#ifndef` defaults (`isMedium → false`, `indexFieldOf → 1.0`). A scene with no
  medium emits none of this and is byte-identical to the straight tracer.
- **The boundary is force-marched.** `odeMarch` finds the wall by an `sdf_Scene`
  sign change, never a trace, so a medium region must contribute to `sdf_Scene`.
  A sphere/box is analytic by default; the emitter drops the trace and marches it
  (you'll see `d = min(d, sdf_lens(p))` and no `trace_lens`). This is automatic —
  triggered by the field-valued IOR, no author action.

## The engine side (for reference)

`odeMarch` (glsl/tracer/6Trace/odeMarch.glsl) reads `int reg = path.region` and
integrates `indexFieldOf(reg, ·)`. `stepForward` switches to it when
`isMedium(path.region)`. `path.region` is set to the entered object on transmit
(scatter.glsl) and at frame start by `regionAt` (so a camera *inside* a medium
starts curving immediately). The field is fixed for the traversal because
`path.region` only changes at a surface crossing — which is exactly where
`odeMarch` exits — so `∇n` stays smooth across the wall for free.

## The author's responsibilities (what can't be checked)

1. **The field must be smooth and real a little PAST the region's own boundary** —
   do not clamp it to 1 at the wall. `odeForce` central-differences `∇n`; a
   value-cliff at the wall bands. (Luneburg's `max(2 − (r/R)², 0)` stays real to
   `r = R√2`; the black hole's `(1+M/r)²` is smooth everywhere.) The region's sdf,
   not a discontinuity in `n`, is what confines the curving.
2. **Media must not overlap or touch within an ODE stencil width** — the
   per-traversal field assumes only one region's field matters near its own wall.
   None of the current scenes come close.
3. **Don't immerse trace-only geometry inside a medium** — `odeMarch` sees
   surfaces only via `sdf_Scene`, so an analytic-only object placed inside a
   medium region is invisible to the bent ray (engine contract #1). Give such
   geometry an sdf or keep it outside.

## The four scenes

| scene | field | boundary |
|---|---|---|
| `blackhole` | `(1+M/r)²` in a big sphere | n≈1 at the far wall (seamless), camera inside |
| `blackholeMulti` | `(1+ΣM/rᵢ)²` in a big sphere | same; the sum is one expression |
| `luneburg` | `√(2−(r/R)²)` in a sphere | n=1 at the rim (index-matched), back-lit room |
| `blackholeCube` | `(1+M/r)²` in a box | n≫1 at the wall → genuine refraction + TIR |

The "global" black holes are media in a large sphere (radius 40): big enough that
`n ≈ 1` at the wall and that the far wall sits inside the marcher's arc budget
(`maxMarchSteps · ODE_STEP ≈ 60` units). There is no truly-unbounded case and no
zero-region scene — every medium is a bounded object. `blackholeCube` needs
`glsl/shapes/box.glsl` (added with this port).

## What is NOT built

- A truly global (unbounded) field — deliberately dropped; a large bounding shape
  is the honest, self-consistent truncation (`n→1` at infinity).
- `blackHole({mass, at})` / `luneburg({at, radius})` **presets** — content over
  this mechanism, a later stage. Each scene is currently the raw field expression.
- The `ambient` (fog) hook — still reserved-only in `scene()`.
