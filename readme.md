# PathTracer

A GPU path tracer for photorealistic mathematical rendering, written from scratch in GLSL,
with a thin three.js/JavaScript harness. Images are produced by Monte Carlo integration over
light paths, accumulated frame-by-frame in a full-screen shader.

## Running

```
npm install
npm run dev <scene-name>        # e.g.  npm run dev sphere
```

Run `npm run dev` with no argument to list the available scenes.
`npm run build <scene-name>` builds a scene into `dist/<scene-name>/`.

Under the hood (`scripts/run-example.mjs`), the script rewrites the single
script tag in `index.html` to point at `example/<scene-name>/main.js`, then
launches vite — so `index.html` always reflects the last scene you ran, and
editing the tag by hand still works too.

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
glsl/tracer/setupShader.glsl      (engine: math, random, camera, materials, basic objects)
  + the scene's environment.glsl + objects.glsl
glsl/tracer/traceShader.glsl      (engine: scene assembly, bounce loop, main())
```

The engine sections live in numbered folders reflecting concatenation order:
`1Setup` (uniforms, math, dual-number variety DE, RNG, sky), `2Space` (Vector/Isometry
structs, geodesic flow, camera, physics), `3Materials` (Material struct, Path struct,
scattering), `5Scene` (glue that calls the scene's functions), `6Trace` (raymarch/raytrace,
bounce loop, subsurface scattering). Scene code is inserted between 3 and 5, so it may use
anything defined in 1–3 plus the object library.

### The object library (`glsl/objects/`)

Reusable shapes. Each object file defines a struct plus overloads of the standard interface,
dispatched by GLSL function overloading on the struct type:

- `float distR3(vec3 p, Type o)` — the SDF (the only genuinely per-object code)
- `bool at(Vector tv, Type o)` / `bool inside(Vector tv, Type o)`
- `float sdf(Vector tv, Type o)` — SDF at a tangent vector's position
- `Vector normalVec(Vector tv, Type o)` — normal (finite-difference by default)
- `void setData(inout Path path, Type o)` — writes material/normal into the path on a hit
- optionally `float trace(Vector tv, Type o)` for shapes with analytic/custom intersection

`basic/` is auto-included by the engine; anything else must be `#include`d from the scene's
`objects.glsl` with a path relative to that file.

## Writing a scene

A scene is a folder `example/<name>/` containing `main.js` plus `src/` with three files:

**`src/settings.js`** — must default-export `{uiParams, location}`:
- `uiParams`: `aperture, focalLength, exposure, focusHelp, fov, extra, extra2, extra3, extra4`
  (all nine required; `extra`–`extra4` are free scene parameters wired to UI sliders)
- `location`: `{position: [x,y,z], facing: [9 entries, row-major 3x3 rotation]}`

Use the UI's **Download Settings** button to capture the current camera/parameters as a
ready-made `settings.js`.

**`src/objects.glsl`** — must define:
```glsl
void  buildObjects();
float trace_Objects(Vector tv);
float sdf_Objects(Vector tv);
bool  inside_Object(Vector tv);        // used by subsurface scattering
void  setData_Objects(inout Path path);
```

**`src/environment.glsl`** — must define the analogous
`buildEnvironment / trace_Environment / sdf_Environment / setData_Environment`.

`main.js` is currently identical boilerplate in every scene — copy it from `example/sphere/`.
Larger scenes may split generated geometry data into extra files (see the `cubic*` scenes'
`scene2d.glsl`/`scene3d.glsl`) and `#include` them from `objects.glsl`.

The easiest start: copy `example/sphere/` wholesale, point `index.html` at it, and edit.

## Controls

- Arrow keys: translate; `'`/`/`: up/down; WASD + QE: rotate
- UI panel: camera (aperture / focal length / fov / exposure, with a focus-help overlay),
  the four `extra` sliders, preview resolution, auto-save, and tiled "HD" panel rendering
  for output larger than the screen.
- **Save Image** downloads the current canvas; **Download Settings** downloads a
  `settings.js` capturing the current camera and parameters.

## Notes

- The sky texture is currently hardcoded to `/assets/office.jpg` in
  `js/shaderData/buildTraceShader.js`.
- Every ray origin is offset by the legacy constant `CAMERA_OFFSET` in
  `glsl/tracer/2Space/camera.glsl`; saved scene settings were authored with it baked in.
- `final/` holds finished renders; `assets/` holds environment textures.
