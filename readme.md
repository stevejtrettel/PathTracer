# PathTracer

A GPU path tracer for photorealistic mathematical rendering, written from scratch in GLSL,
with a dependency-free raw-WebGL2 JavaScript harness. Images are produced by Monte Carlo
integration over light paths, accumulated frame-by-frame in a full-screen shader.

## Running

```
npm install
npm run dev                     # serve everything; / is a gallery of all scenes
npm run dev <scene-name>        # same, but open that scene  (e.g. npm run dev sphere)
npm run build <scene-name>      # build one scene into dist/<scene-name>/
```

Each scene is its own Vite page (`scenes/<name>/index.html`); the root `index.html`
is a gallery linking to them all. Both are generated — after adding or removing a
scene folder, run `node scripts/gen-pages.mjs` to regenerate them.

`node scripts/render-test.mjs <scene>...` headlessly screenshots scenes into
`render-tests/` — useful for checking nothing broke after engine changes.

## Architecture

Three full-screen fragment shaders run in sequence each frame (driven by `js/PathTracer.js`,
each wrapped in a `ComputeShader` with ping-pong float render targets):

1. **trace** (`glsl/tracer/`) — traces one full light path per pixel and returns a color sample.
2. **accumulate** (`glsl/accumulate/`) — running average of samples across frames
   (the Monte Carlo integration). Resets whenever the camera or a parameter changes.
3. **display** (`glsl/display/`) — tone mapping (ACES) + gamma, drawn to the canvas.

GLSL files are imported into JS as strings by `vite-plugin-glsl`, which also resolves the
`#include` directives inside them.

### The trace shader

Assembled by `js/shaderData/buildTraceShader.js` as a concatenation of three chunks:

```
glsl/tracer/setupShader.glsl      (engine: math, random, camera, materials, shape vocabulary)
  + the scene chunk, GENERATED from the scene's src/scene.js description
glsl/tracer/traceShader.glsl      (engine: scene assembly, bounce loop, main())
```

The middle chunk is emitted by the scene generator (`js/scenegen/`) from a declarative
JavaScript description — no scene GLSL is hand-written anymore. `npm run gen <scene>`
prints the emitted chunk; the byte-exact copies in `render-tests/goldens/` are the
emitter's regression gate (`node scripts/gen.mjs --goldens`).

The engine sections live in numbered folders reflecting concatenation order:
`1Setup` (uniforms, math, dual-number variety DE, RNG, sky), `2Space` (Vector/Frame
structs, geodesic flow, camera, physics), `3Materials` (Material struct, Path struct,
scattering), `5Scene` (glue that calls the scene's functions), `6Trace` (raymarch/raytrace,
bounce loop, subsurface scattering). The scene chunk is inserted between 3 and 5, so it may
use anything defined in 1–3 plus the shape library.

### The shape library (`glsl/shapes/`)

Two layers. The **vocabulary** (`glsl/shapes/_vocabulary.glsl` — primitives, the `op*`
fold/blend/carve toolbox, curve machinery) is always compiled. The **catalogue** —
everything else under `glsl/shapes/` (fractals, models, tilings, vendor SDFs, varieties)
— is auto-discovered and included only when a scene's description names it via `lib.*`.
Each catalogue file is a local-coordinates `float sdf(vec3 p, ...)` plus a header
describing its parameters; `docs/shape-library.md` is the authority.

## Writing a scene

A scene is a folder `scenes/<name>/` containing a boilerplate `main.js` (a five-line
stub calling `emit`) plus two files under `src/`:

**`src/scene.js`** — the scene itself: a declarative description built from
`js/scenegen` (`scene()`, `object()`, `lib.*` shapes, modifier combinators like
`repLim`/`mirror`/`carve`/`clip`/`subtract`) and `js/presets` (named materials,
`room()`, `sphereLight()`, studio setups). Tunable controls are declared inline with
`knob()` — each knob generates a GLSL uniform, a labeled GUI slider, and a line in
saved settings. Authored GLSL escape hatches (`` glsl`...` `` fragments, `material()`,
`modifier()`) cover anything the schema doesn't. The complete guide is
`docs/scene-authoring.md`; the generator's design is `docs/generator.md`.

**`src/settings.js`** — saved *values* only: `uiParams` (aperture, focalLength,
exposure, fov, ...), `location` (`{position, facing}` camera pose), `params` (current
knob values), and optionally `sky` — `{type:'image', src}` (default
`/assets/office.jpg`), `{type:'solid', color}`, or `{type:'gradient', top, bottom}`.
Knob *declarations* live in `scene.js`; settings only overrides their values.

In dev mode the UI's **Save to Scene** button writes the current camera/parameters
straight back into the scene's `settings.js`; **Download Settings** downloads the
same file, and **Copy Pose** puts just the camera pose on the clipboard.

The easiest start: copy `scenes/glassball/` wholesale (one glass sphere in a room,
26 lines), rename it, and run `node scripts/gen-pages.mjs` to give it a page and a
gallery entry.

## Controls

- Keyboard flying: arrow keys translate; `'`/`/` move up/down; WASD + QE rotate.
  Hold Shift for a speed boost; the fly Speed slider lives on the Camera tab.
- Mouse orbit (toggle on the Camera tab): drag to orbit the origin, pinch/scroll to zoom.
- UI panel tabs: **Camera** (aperture / focal length / fov / exposure, focus-help
  overlay, speed, orbit, Copy Pose / Save to Scene / Download Settings),
  **Render** (preview scale, samples, Reset), **Export** (Save Image, Auto Save,
  and tiled HD rendering with a Stop button for output larger than the screen).
- A shader-error overlay reports GLSL compile errors in-page during development.

## Notes

- Every ray origin is offset by the legacy constant `CAMERA_OFFSET` in
  `glsl/tracer/2Space/camera.glsl`; saved scene settings were authored with it baked in.
- Environment textures live in `public/assets/`.
