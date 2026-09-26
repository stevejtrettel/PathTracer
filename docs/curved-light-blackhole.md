# Curved light: black holes & bounded graded-index media

How the ODE marcher ([glsl/tracer/6Trace/odeMarch.glsl](../glsl/tracer/6Trace/odeMarch.glsl))
bends light, and the **one contract** every variable-index medium follows. Two demo
scenes exercise it: `scenes/blackhole` (a real black hole) and `scenes/blackholeCube`
(a black hole's optics packed into a real block of glass). `scenes/luneburg` is the
same contract at lower strength.

## The physics: n = U²

A Majumdar–Papapetrou black hole (extremal, charge = mass — the case where several
holes sit in static equilibrium) has metric

    ds² = −U⁻² dt² + U² dl²,     U = 1 + Σ Mᵢ / |r − rᵢ|

Null rays satisfy `−U⁻²dt² + U²dl² = 0`, i.e. `dt = U²·dl`. By Fermat, light in the
scene behaves as if travelling through a medium of refractive index

    **n(r) = U² = (1 + Σ Mᵢ/rᵢ)²**

Properties we rely on:
- `n → 1` as `r → ∞` — asymptotically flat, which the Hamiltonian marcher requires.
- `n → ∞` at each `rᵢ` — the event horizon is a **point** in these coordinates.
- The force `n·∇n` is computed by central differences inside `odeMarch`, so a scene
  only supplies `indexField(p)`; it never hand-derives a geodesic equation.

(The reference repo `charged-blackholes` integrates the ray-direction directly with
`U = M/R` and no `+1`; that is a different parametrization. Our Fermat/Hamiltonian
path *needs* the `+1` so that `n → 1` at infinity. Don't copy the `+1`-less `U`.)

## Two things that will bite, and their fixes

### 1. Fixed step size explodes near a hole

The leapfrog drift is `r += h·mom` with `|mom| = n`. A **fixed** affine step `h`
makes the *coordinate* jump `h·n`, which blows up as `n → ∞` near a hole — the ray
leaps a huge distance, samples `indexField` at garbage points, and diverges.
Different impact parameters diverge at different radii ⇒ **concentric black rings**.

Fix (in `odeMarch`): choose the coordinate step `ds` (affine `h = ds/n`) per step
from three limits:
- **the controller:** how much the force `n·∇n` changed over the last step. The
  next step grows (at most ×2) where it barely changed and shrinks (at most ×½)
  where it changed a lot, aiming at `ODE_FTOL` (5%) relative change per step.
  Leapfrog's error comes from the force varying across a step, so this is the
  quantity to watch.
- **field change:** `ds·|∇n|/n ≤ ODE_DTOL`, the strong-field guard near a hole.
- **surfaces:** `ds ≤ max(|sdf_Scene|, ODE_DS_MIN)`, so a step never jumps a wall
  or a thin shell; in a uniform medium this is plain sphere tracing.

The first step is `ODE_STEP`; the reused force keeps it at one gradient eval per
step. The gradient's central-difference spacing grows with the step (`0.1·ds`,
never below `ODE_GRAD_EPS`): far from a hole `n` changes by only ~1e-6 across a
0.002 stencil, which float32 cannot resolve cleanly, and the rounding noise made
the controller refuse to grow the step (most rays hit `maxMarchSteps`). Bounding the change in `n` alone is not enough: far from the hole `n` barely
changes while the force still falls off like 1/r², and with only the last two
limits rays landed 5–25 px off a fine-step reference.

Measured against a fine-step reference (JS port of the marcher, Sep 2026): a
`blackhole` ray took ~1750 steps at the old fixed 0.03 cap — nearly all of them
walking the ~55 units to the far wall — and ~180 with the controller, at equal or
better accuracy (float32 emulation: 99% of exit directions within 1.2 px vs
2.3 px before). `luneburg` went 158 → 66 steps and got more accurate;
`blackholeCube` 93 → 54. On the GPU (640×480, 257 frames) `blackhole` went
18.1 s → 5.9 s (the harness's frame-rate floor) and `blackholeMulti` 36.2 s →
8.5 s, with images the same by eye.

### 2. Capture

`n > ODE_CAPTURE` (⇔ `r < M/√ODE_CAPTURE ≈ M/7` for a single hole) means the ray has
essentially reached the singular point — kill it, it renders black. That black disk
is the shadow (pure dynamics, not a drawn sphere). The capture only *fires reliably*
once the adaptive step above stops the ray leaping over the capture shell.

## The bounded-medium contract (the unified case)

A medium confined to a shape is **a variable-IOR function that acts only inside a
region — but the function itself may extend beyond that region.** Three pieces:

1. **Smooth `indexField(p)`** — the IOR function, real-valued a little *past* the
   boundary. **Never clamp it to 1 outside.** Clamping is the anti-pattern: it makes
   a value-cliff (e.g. the cube wall, `n≈1.3 → 1`) or, when the field already reaches
   1 at the wall, a slope-kink (Luneburg). Either way `odeForce`'s central-difference
   `∇n` reads a spurious gradient right at the wall → banding (and pathologically tiny
   adaptive steps → slow).

2. **`#define IN_MEDIUM_REGION(p) <inside my shape>`** — the geometric gate. This, not
   a discontinuity in the index, is what confines the curving. `odeMarch`/`inMedium`
   default the macro to `true` (unbounded media: global black hole, and any scene with
   no medium is unaffected). The `&&` short-circuits, so `indexField` is never even
   evaluated outside the region — safe even where the smooth continuation would go
   imaginary (Luneburg past `r = R√2`).

3. **Dynamic-IOR surface** (hard-walled media only) — the confining object's `setData`
   refracts with `n_wall = indexField(hit)` instead of a fixed IOR, so Snell at the
   surface uses the *same* field as the interior eikonal. This is what makes the glass
   cube a rigorous physical object (one field governs surface + interior) rather than
   an arbitrary box: a **transformation-optics analog** — a real dielectric in flat
   Euclidean space whose optics equal a black hole's. (A genuine black hole is global;
   any hard wall is an honest, self-consistent truncation of it.)

### Luneburg is the same case
`n = √(2 − (r/R)²)` is 1 at the rim and stays real out to `r = R√2`, so it needs no
dynamic wall (IOR-1, seamless exit) — but it still uses a smooth (unclamped) field +
`IN_MEDIUM_REGION(inside lens)`. Previously it clamped and survived on a mild kink;
now it follows the one contract like everything else.

### What a curved ray can and cannot see (two silent contracts)

1. **Analytic-only surfaces are invisible inside a medium.** `odeMarch` finds
   surfaces solely by an `sdf_Scene` sign change along the bent curve — `trace_Scene`
   is (correctly) never consulted, since a straight-line intersection is meaningless
   on a bent ray. Every current scene satisfies this by construction: the global
   black holes are sky-only, and the bounded media (cube, Luneburg) end at their
   walls, so the straight raytrace+raymarch resumes outside and sees the analytic
   room. But it is a real constraint: **a scene that immerses trace-only geometry
   (a RoomBox, an analytic Sphere) inside a medium region will silently lose those
   surfaces.** Give such geometry an sdf, or keep it outside the medium.

2. **Thin shells inside a medium are safe.** The step never exceeds the distance
   to the nearest marched surface (`ODE_DS_MIN` floor), so a step cannot cross a
   shell and exit it again unseen; the sign-change test then bisects the crossing.

## The demo scenes

| scene | medium | boundary | backdrop |
|---|---|---|---|
| `blackhole` | `n=(1+M/r)²` global | none (no seam possible) | image sky, lensed into an Einstein ring |
| `blackholeCube` | `n=(1+M/r)²` in a cube | glass, dynamic-IOR wall + TIR | image sky through the block |
| `luneburg` | `n=√(2−(r/R)²)` in a sphere | IOR-1, seamless | back-lit room |

`mass` is a per-scene knob (black-hole scenes cap it at 0.5 — beyond that the field is
stiff enough that the shadow is all you see). `ODE_FTOL` / `ODE_DTOL` / `ODE_CAPTURE`
are the tuning constants, `#define`-overridable per scene.
