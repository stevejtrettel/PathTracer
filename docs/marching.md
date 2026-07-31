# Marching efficiency

How the tracer finds the next surface, and the two levers we have for making it
faster without a spatial hierarchy (BVH). Companion to
[bounding-volumes.md](bounding-volumes.md) and [debug-suite.md](debug-suite.md).

> TL;DR — the marcher is over-relaxed sphere tracing with adaptive cone epsilon
> (Keinert et al. 2014), in [raymarch.glsl](../glsl/tracer/6Trace/raymarch.glsl).
> It replaced a fixed 0.9-under-relaxed march: same geometry, fewer steps. Its two
> constants (`MARCH_RELAX`, `MARCH_CONE`) are tuned in the file, not knobs.

## The cost model

Every primary and bounce ray costs roughly

```
cost(ray)  ≈  (# march steps)  ×  (cost of one sdf_Scene eval)
```

These are two independent levers:

- **Cheaper steps** — `sdf_Scene` is a `min` over the scene's objects, and each
  bounded object skips its (possibly expensive) real SDF when the ray is outside
  its `bound()` (see [bounding-volumes.md](bounding-volumes.md)). This is what a
  BVH would also attack — but only helps when the per-step cost is dominated by
  *object count*. Our scenes are typically **one hard hero field** (a fractal, an
  algebraic variety, a Kleinian limit set), so there is no object-count factor to
  collapse: a BVH would buy almost nothing. That is why we don't have one.

- **Fewer steps** — this is where the leverage is, and it lives entirely in the
  march loop ([glsl/tracer/6Trace/raymarch.glsl](../glsl/tracer/6Trace/raymarch.glsl)).

The trace itself is two-phase (see `stepForward`): an analytic `raytrace()` gives
a stop distance for shapes with a closed-form intersection (spheres, planes, the
room box), then `raymarch()` marches the SDF only up to that stop. Cheap analytic
shapes are already exact and fast; the marcher's job is the hard fields.

**The stop must only be taken off the SAFE sphere.** An over-relaxed step is a
speculative guess — its skip-guard (the sorFail overlap test) runs on the *next*
sample. Exiting "analytic surface first" because the relaxed step crossed the stop
skips that validation, and a marched surface sitting just in front of an analytic
one gets silently dropped (a glass resting on the floor loses its whole bottom band
at grazing camera angles — found July 2026 in the cocktail/bottle scenes). The
marcher therefore exits on `t + radius > stopDist` (radius is a true lower bound,
so nothing marched can precede the stop), and a relaxed step that would cross the
stop is clamped back to the plain full step. `dbgMarch` mirrors the same rule.

## The marcher

`raymarch()` is over-relaxed sphere tracing with adaptive cone epsilon — two
orthogonal step-count improvements over a plain sphere trace, tuned by the two
constants at the top of the file:

```glsl
const float MARCH_RELAX = 1.2;    // over-relaxation ω
const float MARCH_CONE  = 0.005;  // cone-epsilon growth per unit distance
```

**Adaptive cone epsilon** (`MARCH_CONE`). The hit tolerance grows with distance:

```
eps = EPSILON * (1 + MARCH_CONE * t)
```

A surface far from the camera projects to less than a pixel, so resolving it to
the absolute `EPSILON` (0.001 world units) just burns convergence steps for a
sub-pixel gain. Growing the tolerance with marched distance `t` stops the
geometric crawl on distant geometry. It is invisible to the eye and, because it
only reads the returned scalar distance, is **geometry-neutral** (safe under any
`flow()`, Euclidean or not). `MARCH_CONE = 0` recovers the fixed `EPSILON`.

**Over-relaxed sphere tracing** (`MARCH_RELAX` = ω). Instead of stepping by the
unbounding radius `r`, step by `ω·r`:

- `ω = 1` — the plain conservative full step. Safe on true distance fields.
- `ω ∈ (1, 2)` — **over-steps**. Faster, but an over-step can skip a thin
  surface, so it is guarded by the *enhanced sphere tracing* fallback
  (Keinert, Innmann, Süßmuth, Stamminger, *Enhanced Sphere Tracing*, 2014):

  > An over-step from a sphere of radius `r_prev` is valid only if the new
  > unbounding sphere reaches back far enough to **overlap** it, i.e.
  > `step ≤ r_prev + radius`. If not (`sorFail`), the step may have jumped a
  > surface: retreat to the guaranteed-empty point `r_prev` past the previous
  > sample and resume. No surface is ever skipped.

- `ω < 1` — **under-relaxes**: the safe direction for DE fields that overestimate
  distance (varieties, fractals). At `ω = 0.9, MARCH_CONE = 0` the marcher
  reproduces the old fixed-`0.9` march step-for-step — the correctness anchor
  used when validating the switch.

`ω = 1.2` is the tuned default: over-stepping enough to matter while keeping the
overlap fallback active, which held geometry-identical across every family in the
library (fractals, algebraic varieties, varieties-in-glass, Kleinian gaskets).
Retune it in the file if you add a scene with a pathological field.

The `signedRadius` sign-lock (captured once at the ray origin) lets a single loop
march from *inside* a solid too — the abs-distance interior marching that glass
refraction needs.

> **Non-Euclidean caveat.** The overlap fallback assumes Euclidean ball geometry
> along a straight ray. It is exact for the current straight-line `flow()`. A
> future curved-geodesic space should set `ω ≤ 1` (pure under-relaxation, no
> overlap assumption) or re-derive the invariant for the metric. Adaptive cone
> epsilon has no such assumption and is always safe.

## Measuring cost

The debug lenses (Debug tab, see [debug-suite.md](debug-suite.md)) read the
marcher directly — `dbgMarch()` mirrors `raymarch()`:

1. **Cost heatmap (mode 2)** — the direct read of step count; bright = expensive.
   Use it to find which scenes/regions are march-bound.
2. **Overstep (mode 5)** — red = rays that ran out of `maxMarchSteps` or failed to
   converge. The safety check: red holes on a solid surface mean the marcher is
   tunneling (lower `MARCH_RELAX`).
3. **DE quality (mode 3)** — shows which fields overestimate distance (warm/red);
   those are the ones that want `ω ≤ 1` if you ever retune.

To A/B a change to the constants: note the heatmap before, edit `MARCH_RELAX` /
`MARCH_CONE`, and watch the bright regions move (Vite hot-reloads the shader).

## `maxMarchSteps` (empirical)

`maxMarchSteps = 2000` ([1Setup/uniforms.glsl](../glsl/tracer/1Setup/uniforms.glsl))
is very high — sphere marchers usually live at 128–512. It is the worst-case
tail: every grazing near-miss can burn up to 2000 full-scene evals. Once enhanced
stepping shrinks the tail, re-tune it empirically: lower it and check mode 5
across the heavy scenes for new red holes.

## History

The over-relaxed marcher replaced a fixed `step = 0.9·|sdf|` sphere trace (the
`0.9` under-relaxed every step to stay safe on DE fields that overestimate
distance — a ~10% tax on every ray, everywhere). It first shipped behind a live
`uMarchMode` toggle (classic vs enhanced, with `marchRelax`/`marchCone` knobs) so
it could be A/B-validated against the frozen reference per scene. Once confirmed a
uniform, geometry-identical win — same images across fractals, varieties,
varieties-in-glass, and Kleinian gaskets, fewer march steps everywhere — the
classic marcher and the knobs were removed and the enhanced constants baked in.
The `render-tests/baseline/` set predates the switch and still matches, so it
doubles as the reference; the old marcher lives in git history if ever needed.

---

## Per-scene marching constants (July 2026)

`EPSILON`, `maxDist`, `maxMarchSteps`, `MARCH_RELAX`, `MARCH_CONE` and
`AT_THRESH` are no longer scattered consts in `1Setup/uniforms.glsl` and
`6Trace/raymarch.glsl`. They are **generated as one block** at the top of the
assembled shader (`js/shaderData/buildTraceShader.js`), because a scene may
override the first three with `march: {epsilon, maxDist, maxSteps}`.

They are emitted as plain VALUES, not `#define` hooks: we assemble this shader
ourselves, so there is no separate compilation unit to guard against and nothing
to preprocess around.

**`AT_THRESH` became DERIVED**, which was flagged as wanted in
[generator.md](generator.md) §3.3 and is the reason the block exists at all:

```glsl
const float AT_THRESH = AT_THRESH_MARGIN*EPSILON*(2. + MARCH_CONE*maxDist);
```

`MARCH_RELAX`/`MARCH_CONE` moved into the same block because `AT_THRESH` is
derived from them — a constant and its inputs belong together rather than a file
apart. At the defaults the formula gives `1.2*0.001*(2 + 0.005*100) = 0.003`,
exactly the value it had when hand-tuned, which is the evidence the derivation
is the right one rather than a guess.
