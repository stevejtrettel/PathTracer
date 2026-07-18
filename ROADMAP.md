# Project state & open items

State as of July 2026 (branch `refactor`). The big refactors are **done**; this file is
now a record of what's in place plus the handful of genuinely open items. For how to run,
write a scene, or use the object API, see `readme.md`.

## Done

- **Object library on the Frame system.** Every object is a struct with a `Frame frame`
  (similarity transform: rot/pos/scale), a hand-written **local** `sdf(vec3 p, Type obj)`,
  and `OBJECT_API(Type)` generating the world-facing interface. Convention: `vec3` arg =
  local coords, `Vector` arg = world ray state. Optional tight bounding via `float bound(Type)`
  + the `*_B` macros (a real cull; baked into Box, CubicSurface, the surf*/var* families).
- **Named-params knob system.** Every tunable control is one data object
  `{name, label, type, min, max, step, value, group}`; one generator (`js/shaderData/knobs.js`)
  emits the GLSL uniform, the GUI slider, and the `settings.js` serialization. Scenes declare
  named params in `settings.js`; **44 of 45 scenes** use them (all but the parameterless
  `skyDemo`) — the earlier `scratch1..4` convention was swept into labeled sliders (see below).
  `scratch1..4` remain as always-present engine knobs for quick live experiments.
- **Custom tabbed GUI** (Scene / Camera / Render / Export), a plain vanilla-JS renderer of
  the knob list. `lil-gui` is gone.
- **Raw-WebGL2 harness.** three.js fully removed; renderer in `js/ComputeShader.js`, math
  vendored into `js/math/`. Details in `docs/webgl-migration.md`.
- **Named-params sweep + collision lesson (July 2026).** The gallery had an unwritten
  convention — scratch1 = `isotropicScatter`, scratch2 = `meanFreePath`, scratch4 = ceiling
  light — repeated across ~34 scenes. Converted to named sliders (`sssScatter`, `sssDensity`,
  `roomLight`, plus one-offs `rotation`/`emission`/`roughAmt`). NOTE for future knobs: a param
  is a **global** in the assembled shader, so names must avoid collisions — `scatter` clashes
  with the core `scatter()` fn, `light` with `Sphere light;`, `roughness` with locals.

## The shadertoy fractal family (July 2026)

Seven shadertoys adapted into the tracer, all on a shared recipe:
`kleinianSpiral`, `hyperbolicHoneycomb`, `hyperbolicHoneycomb2`, `kleinianSeahorse`,
`breathe`, `apollonian`, `kleinianEscape` (source shadertoys kept under `shadertoys/`).

- **Recipe.** Extract only the SDF/DE and camera; discard the shadertoy's own renderer
  (AO, fog, bloom, DOF, lighting) — our path tracer supplies that. New object file per shape
  under `glsl/objects/fractals/`, standard object API. Fractal DEs overestimate, so bake a
  fudge factor into the returned distance and tune by eye.
- **Coloring convention.** Objects stay geometry-only and expose a *probe* —
  `vec4/vec3 orbitTrap(vec3 p, obj)` or `int region(vec3 p, obj)` — and the scene owns the
  palette, applied as a **followup to `setData`**:
  ```glsl
  void setData_Objects(inout Path path){
      setData(path, obj);                          // geometry + flat base material
      if( at(path.tv, obj) ){                      // recolor followup, scene-owned
          vec3 p = toLocal(obj.frame, path.tv.pos);
          path.dat.surfDiffuse = myColor(p);       // uses the probe; edit freely
      }
  }
  ```
  This keeps the `Material` struct unchanged (no core edits) while allowing position-dependent
  color. Deform parameters (`time`, `KleinR/I`, `r2`, fold depth) are struct fields driven by
  named params.
- **Per-scene rendering knobs (not geometry!).** `maxDist` and `EPSILON` are mutable globals
  settable in `buildObjects` — a shorter `maxDist` gives a ray-length cutoff (fade to sky),
  a finer `EPSILON` lets the marcher see through a fractal's thin "haze" instead of reading it
  as a solid wall. Infinite tilings can be carved to a finite hero block with a clip box.
- **Camera conversion.** shadertoy EYE/TARGET/UP → our `position = EYE - CAMERA_OFFSET`,
  `facing` rows `= [right | up | -forward]`. (Watch the basis arithmetic — a slip gives a
  subtly-wrong pose.)

## Open / deferred

- **cubic-portrait camera aim** — renders near-black; the x=0 object stack is mostly out of
  frame. Re-aim `facing` by eye in the app (WASD + pose readout + Save to Scene).
- **Cubic scenes' rotation machinery** — `rotXZ`/`standUp`/`plateRot` mutate positions in a
  pseudo-world; could fold into object frames and delete the scene-level code (needs eyeballing).
- **Glass shells don't inherit variety frames** — `createVar*Glass` places the shell with
  `makeFrame(var.frame.pos)` (no rotation/scale). Fine today; revisit if a scene rotates a
  wrapped variety.
- **Local-unit thresholds** — the surf* edge-band (0.005) and the gasket bail-out are in local
  units, so they scale *with* the object (arguably correct; only matters for `frame.scale != 1`).
- **`pi` vs `PI`** both exist (lowercase used by vendored `sdf_gallery` files) — unify only if
  touching those files anyway.
- **Orphan library objects** — `menger`, `trefoil`, `poincareMarble`/`hypDod` have no scene.
  Kept deliberately (library surface); a tiny demo scene each would keep them render-tested.
- **render-test gotcha** — `vite-plugin-glsl` caches the inlined `setupShader`, so editing an
  *included* `.glsl` without touching the parent serves a stale shader. `rm -rf node_modules/.vite`
  before render-testing include changes; kill stray dev servers first (a squatter on :5173
  makes render-test screenshot the wrong app).
