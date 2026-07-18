# Debug suite — design plan

> **Status: planned.** A coherent, permanent set of visual debugging lenses for
> authoring SDFs and inspecting the renderer. Supersedes the narrower
> `bound-debug-view.md` (its modes are folded in here). Companion to
> `docs/bounding-volumes.md`.

## Two hard constraints (they drive the whole design)

1. **No shader rebuild to toggle.** Compile times are long; debug modes must switch
   via a **uniform**, never a recompile / `#ifdef`.
2. **Zero measurable cost when off.** With debug off, the shipped render must be
   what it is today — no debug branch in any hot loop.

These look opposed (a runtime uniform usually means a live branch), but one
structural choice satisfies both.

## The architecture: a single top-level fork

The primary ray is launched once per pixel in `glsl/tracer/traceShader.glsl`:

```glsl
// newFrame(), line 37 today:
vec3 col = pathTrace(path);
```

That single call site is the entire integration point. Replace it with a fork on a
`uDebugMode` uniform (int enum, 0 = off):

```glsl
vec3 col;
if (uDebugMode == 0) {
    col = pathTrace(path);              // untouched, ships as-is
} else {
    col = debugPass(uDebugMode, path.tv, fragCoord);   // debug-only march
    return col;                          // skip exposure/accumulation semantics
}
return exposure * col;
```

Why this meets both constraints:

- **No recompile**: `uDebugMode` is a uniform. Flip it in the GUI, next frame draws
  the diagnostic. No rebuild.
- **Zero cost when off**: the fork is **per pixel, once** — not per bounce, not per
  march step — and it's a *coherent* branch (same uniform for every pixel, no warp
  divergence, perfectly predicted). When off, `debugPass` is never entered and the
  path-trace loop, the march loop, and `sdf_Scene` are **byte-for-byte identical**
  to today. The only always-executed addition in the whole renderer is one uniform
  compare per pixel per frame — unmeasurable.
- **Zero churn to the hot loops**: `debugPass` is a *new, self-contained* function
  that does its **own** primary-ray march. We never touch `raymarch()`,
  `pathTrace()`, or the `OBJECT_LOCATORS_B` macro. The debug march reuses the
  existing `sdf_Scene` / `normalVec_Scene` — so it automatically covers **every
  object, present and future**, because those are what every object already feeds.

### Accumulation

Debug output is deterministic (no Monte-Carlo noise), so it doesn't need the
accumulation buffer. Simplest: let `debugPass` write its color through the normal
tracer→accumulate→display path — averaging a constant with itself is a no-op, and
camera moves already reset accumulation. (A later refinement: a pass-through flag in
the accumulate stage so debug frames don't waste accumulation work. Not needed for
v1.)

## Two families: preview shading and diagnostics

`debugPass` does a single primary-ray march of `sdf_Scene`, then branches on the
mode. Because it returns after **one march with no bounce loop**, every mode is a
cheap one-shot — which splits the suite into two families with different intents:

- **Preview shading** — a fast, *presentable* image for composing and navigating a
  scene. This is the "viewport shading" workflow (cf. Blender's Solid/Material
  modes): flip preview **on** to move the camera and place objects at high
  framerate, then flip it **off** to path-trace the final. See below.
- **Diagnostics** — reveal internal state; not meant to look pretty.

Both ride the same fork and skip `pathTrace`; the only difference is what the
`case` returns.

### Why preview mode makes navigation fast *and* clean

Two independent wins, both from the same one-shot march:

1. **No bounce loop.** Full path tracing marches once per bounce (up to
   `maxBounces`, 50) plus scatter/roulette each time. A preview marches **once** and
   shades — a large fraction of the per-frame cost gone.
2. **No accumulation.** Normally a camera move *resets* the accumulation buffer, so
   you navigate through a noisy image that only converges once you stop. A preview
   is **deterministic** — a complete, clean image every single frame — so moving is
   smooth and noise-free. (`debugPass` bypasses accumulation; see above.)

The remaining floor cost is the first-hit march itself, which for heavy SDFs
(fractals, gallery models) is exactly what the **bounding work** already cut and
what the **heatmap / DE-quality** lenses help you cut further — the tools compose.

### Preview shading modes
- **Matcap / normal-lit** *(recommended default preview)* — shade the hit by its
  normal with a fixed hemisphere/"headlight" or a matcap lookup. Reads form like a
  clay render, costs one march + one normal. The go-to navigation view.
- **Albedo** — flat surface diffuse color; shows real materials/colors, no lighting.
- **One-bounce direct** — march to hit, one light/shadow sample, shade. The
  priciest preview, but shows real lighting; still far cheaper than full path trace.

(Note: the **Normals** and **Depth** diagnostic lenses below double as previews —
they're already one-shot and navigable.)

## Diagnostic lenses (each is one `case` in `debugPass`)

Grouped by what they diagnose.

### SDF quality — where the hard authoring bugs live
- **Normals** — RGB = `0.5 + 0.5*normalVec_Scene(hit)`. Exposes bad finite-diff
  epsilons, faceting, discontinuities the moment you add a shape.
- **DE quality (Lipschitz)** — color by `|∇sdf|`, which is ≈1 for a true distance
  field (green), tinting red where it under/over-estimates. This is the root-cause
  view for slow convergence and marching artifacts, and almost no renderer has it.
- **Overstep / non-convergence** — flag rays that exhausted `maxMarchSteps` without
  converging, or where the field crossed zero between steps. Shows exactly where
  holes and speckle come from.

### Performance + bounds
- **Cost heatmap** — the debug march counts steps (its own loop counter `i`); map
  count → color ramp via a `dbgHeatScale` knob. A tight bound hugs the silhouette; a
  loose bound paints a bright blob over its empty corners. This is our live
  bound-looseness read.
- **Bound shells** *(optional, needs plumbing)* — render each object's `bound()==0`
  isosurface translucent. Needs a `bound_Scene()` paralleling `sdf_Scene`
  (code-generated next to `sdf_Objects` to stay automatic). See "bounds correctness"
  for why the *A/B* check lives elsewhere.

### Scene / structure
- **Object ID** — flat unlit color per object; see boundaries and overlaps.
- **Depth** — grayscale by hit distance.
- **Local coords** — a checker in each object's local frame, to debug frame
  placement and scale.

### The veteran, modernized
- **Focus help** — today it *adds* color into the beauty pass (destructive) with
  hard distance tiers (`updatePath.glsl:73`). Reborn as a `debugPass` lens: a clean
  non-destructive focal-distance ramp, or camera-style "focus peaking" that
  highlights only in-focus edges. Same idea it pioneered, done right.

## Bounds correctness (A/B) is handled OFFLINE — on purpose

The one thing that *can't* be a top-level fork is "disable every object's bound
early-out," because that lives inside the per-object wrappers, in the march loop. A
live `uNoBounds` uniform would add a coherent branch **per object per step** — small,
but it violates constraint 2. So we don't ship it.

Instead, bound correctness becomes an **offline check in `scripts/render-test.mjs`**:
render a scene normally, render it again with bounds forced off (a `#define` used
*only* by the test build — recompile is fine offline), and diff. Any nonzero pixel =
a too-tight bound, located exactly. This generalizes the manual baseline-diff we did
during the bounding rollout into an automated guard, and keeps the shipped hot path
clean. Live looseness inspection is covered by the **heatmap** and **shell overlay**.

## GUI wiring (rides the existing knob system)

The knob generator already turns a declaration into a GUI control + a GLSL uniform
(`engineKnobs.js` → `knobUniformDecls`/`knobUniforms`; `focusHelp` is the bool
precedent, `maxBounces` the int precedent). The suite is one new knob group:

```js
// engineKnobs.js — a 'debug' group → its own GUI tab
const debugKnobs = [
  { name: 'uDebugMode',  label: 'Mode', type: 'int', min: 0, max: 8, step: 1, value: 0, group: 'debug' },
  { name: 'dbgHeatScale',label: 'Heat Scale', min: 8, max: 512, step: 1, value: 128, group: 'debug' },
];
```

`uDebugMode` wants an enum/dropdown rather than a bare int slider — either add a
small `select` widget to `js/gui/widgets.js`, or (v1) a labeled int stepper. A
"Debug" tab in `UI.js` hosts it, same pattern as Camera/Render/Help.

## Why it stays a *machine* as objects are added

- Every lens marches `sdf_Scene` / uses `normalVec_Scene` — the shared scene
  entry — so a new object is covered the instant it's in the scene, with no debug
  code of its own.
- Adding a new lens = one `case` in `debugPass` + one entry in the mode list.
- Nothing in the suite touches `pathTrace`, `raymarch`, or the object macros, so it
  can never regress normal-render performance or behavior.

## Build status

- **Slice 1 — BUILT** (matcap preview, normals, cost heatmap, DE quality). The
  scaffold lives in `glsl/tracer/6Trace/debugPass.glsl`, forked at
  `traceShader.glsl` `newFrame()`, driven by the `debug` knob group
  (`uDebugMode`, `dbgHeatScale`) with a Debug tab in the GUI. Verified: mode 0 is
  pixel-identical to before; DE-quality reads green on true SDFs (primitives) and
  warm on imperfect DEs (varieties), matcap gives a clean noise-free preview.
- **Known limitation**: the debug pass marches `sdf_Scene`, so objects that render
  *only* via analytic `trace()` and don't contribute to `sdf_Scene` (sphere,
  plane, roomBox) don't appear in the debug views. Fine for SDF authoring (the
  point is marched fields); worth a later "trace pass" variant if needed.

## Build order

1. **Scaffold + Matcap preview + Normals + Cost heatmap + DE quality.** Stand up
   `debugPass`, the fork, and the `uDebugMode` knob, then these four modes (all share
   the one march, proving the architecture). This slice delivers the two everyday
   wins at once: a **fast navigation preview** (matcap — the scene becomes smooth to
   move around immediately) and the core **SDF-authoring lenses**. It's also the
   view to eyeball the loose sphere bounds we flagged (elongated gallery models,
   apollonian r=6, mobius).
2. **Albedo, One-bounce direct, Depth, Object ID, Local coords, Overstep** — cheap
   additions once the scaffold exists (more preview shading + more diagnostics).
3. **Focus help** reborn as a lens; retire the in-loop `focusCheck`.
4. **Bound shells** (needs `bound_Scene`) + the **offline bounds A/B** in
   render-test.
