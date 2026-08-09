# Project state & open items

State as of August 2026 (branch `scene-builder`). The big refactors are **done**; this
file is a record of what's in place plus the genuinely open items. For how to run or
write a scene, see `readme.md`; per-system design docs live in `docs/`.

## Done (each with its authority doc)

- **Raw-WebGL2 harness.** three.js fully removed; renderer in `js/ComputeShader.js`,
  math vendored into `js/math/`. (`docs/webgl-migration.md`)
- **Scene generator.** Scenes are declarative `src/scene.js` descriptions; the GLSL
  scene chunk is emitted by `js/scenegen/`, all 46 scenes converted, hand-written
  scene GLSL deleted. Byte-exact goldens in `render-tests/goldens/` gate the emitter
  (`node scripts/gen.mjs --goldens`). (`docs/scene-authoring.md`, `docs/generator.md`)
- **Shape library.** `glsl/objects/` deleted; `glsl/shapes/` is a two-layer library —
  always-compiled vocabulary + on-demand catalogue (63 entries), per-scene `march:`
  constants with derived `AT_THRESH`. (`docs/shape-library.md`)
- **Modifier chains.** Stacking wrappers `mirror/radial/repLim/round/shell/clip/
  subtract/carve/accrete/displace` + the authored `modifier()` escape hatch.
  (`docs/shape-modifiers.md` §10.5 as-built, `docs/authored-modifiers.md`)
- **Materials as JS value bundles.** Vocabulary in `glsl/tracer/3Materials/`, named
  materials in `js/presets/materials.js`; Surface+Medium structs, coat/microfacet
  scatter tree, pure-Fresnel glass, material data as fields. (`docs/material-system.md`,
  `docs/material-fields.md`)
- **Marching.** Over-relaxed sphere tracing + adaptive cone epsilon only; per-scene
  constants. (`docs/marching.md`)
- **Curved-light transport.** ODE media (graded-index optics, black holes) via
  symplectic `odeMarch` + the bounded-medium contract. (`docs/curved-light-blackhole.md`)
- **Spectral dispersion.** `spectral` master switch, refractivity-scaled `iorAt`;
  off = byte-identical tracer. (`glsl/tracer/1Setup/spectral.glsl`)
- **Custom tabbed GUI.** Six tabs (Scene/Camera/Render/Export/Debug/Help), knob system
  (declared via `knob()` in `scene.js`), colorPicker + xyPad widgets, Save-to-Scene.
  (`docs/gui-design.md`)
- **Debug suite.** 9 debug lenses (`uDebugMode`), bound shells, focus peaking,
  step-count heatmap. (`docs/debug-suite.md`)
- **Equation transpiler.** Parse/verify/emit for variety formulas, gated behind
  `gen.mjs --equations`, byte-exact fixtures. (`docs/equation-transpiler.md`)

## Open / owed

- **Render verification.** There is no image-comparison step: `scripts/render-test.mjs`
  is screenshot-and-eyeball, `render-tests/*.png` are untracked, and
  `render-tests/baseline/` is empty (docs that claim otherwise referred to local,
  never-committed shots). Owed: a tracked baseline set + a diff step. Blocked-ish on
  the SSS re-tune below (no point baking looks that will change).
- **SSS re-tune + baseline bake.** The July 2026 subsurface direction-normalization
  fix legitimately changed the look of ~21 `subSurface` scenes; `meanFreePath` wants
  a per-scene by-eye re-tune before baselines are baked.
- **Variety builder, remaining phases.** Per `docs/variety-builder.md`: migrate the
  legacy variety bucket (~14 scenes), the float-source catalogue end state,
  `--catalogue` listing varieties, integrate the equation transpiler into the
  `variety()` base, and the owner's by-eye pass on the pilot.
- **Deferred hero-wavelength sampling.** Fully designed in `docs/spectral-deferred.md`
  (draw λ lazily at the first dispersing refraction), not implemented — spectral rays
  still pay chroma variance on non-dispersing paths.
- **By-eye pass over the generated scenes.** The scenegen conversion was verified by
  golden bytes, not by looking at renders; a variety/quality pass over the gallery is
  still owed.
- **Legacy demos.** `gen-pages.mjs` has `DEMO_KINDS = []`; the curated demo library
  under `legacy/` is not yet ported to the region system.
- **ComputeShader ABI shim.** `js/ComputeShader.js` keeps the three.js-era interface
  (`material.uniforms[name].value`, `gl_FragColor` rewriting); all callers are owned
  code, so it could be collapsed someday.
- **Unwrapped ops.** `opRep` (infinite repeat), `opElongate`, `opTwist`,
  `opRevolution`, `opExtrusion`, `opSmoothUnion`, `opSmoothIntersect` exist in
  `glsl/shapes/ops/` with no scenegen wrapper — deliberate library surface, wrap on
  demand. No per-cell ID comes out of `opRep/opRepLim`, so repeated copies are
  necessarily identical; that plus a smooth-union between two catalogue shapes are
  the known expressiveness gaps if they're ever wanted.
- **`pi` vs `PI`** both exist (lowercase used by vendored `sdf_gallery` files) —
  unify only if touching those files anyway.
- **`CAMERA_OFFSET`** (`glsl/tracer/2Space/camera.glsl`) is a legacy world offset
  baked into every saved pose; removing it means reframing every scene.

## Gotchas worth re-reading

- **Knob names are globals** in the assembled shader — avoid collisions with engine
  symbols (`scatter`, `light`, `roughness`...). `checkReserved` throws at declaration
  time for the known engine names.
- **render-test:** `vite-plugin-glsl` caches the inlined `setupShader`, so editing an
  *included* `.glsl` without touching the parent serves a stale shader —
  `rm -rf node_modules/.vite` first. Kill stray dev servers (a squatter on :5173
  makes render-test screenshot the wrong app). Spectral/small-light scenes (e.g.
  `gem`) converge far too slowly for the default budget; a speckled-but-nonblack
  frame still proves the shader compiled.
