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
glsl/tracer/setupShader.glsl      (engine: math, random, camera, materials, basic objects)
  + the scene's environment.glsl + objects.glsl
glsl/tracer/traceShader.glsl      (engine: scene assembly, bounce loop, main())
```

The engine sections live in numbered folders reflecting concatenation order:
`1Setup` (uniforms, math, dual-number variety DE, RNG, sky), `2Space` (Vector/Frame
structs, geodesic flow, camera, physics), `3Materials` (Material struct, Path struct,
scattering), `5Scene` (glue that calls the scene's functions), `6Trace` (raymarch/raytrace,
bounce loop, subsurface scattering). Scene code is inserted between 3 and 5, so it may use
anything defined in 1–3 plus the object library.

### The object library (`glsl/objects/`)

Every object is placed in the world by a **Frame** — a similarity transform
`{mat3 rot, vec3 pos, float scale}` (see `2Space/geometry.glsl`). An object file defines:

- a struct with a `Frame frame` field, a `Material mat`, and any shape parameters
- `float sdf(vec3 p, Type o)` — the geometry in the object's OWN local coordinates,
  authored at the origin (the only hand-written code for most objects)
- one macro line, `OBJECT_API(Type)` (see `objects/objectAPI.glsl`), which generates the
  world-facing interface: `initObject()`, the world `sdf(Vector, Type)`, `at`/`inside`,
  a finite-difference `normalVec`, and `setData`

The convention throughout: a `vec3` argument means local coordinates, a `Vector` argument
means world ray state. Objects with analytic normals or ray intersections (sphere, plane)
hand-write those pieces and use the individual macros for the rest; `trace(Vector, Type)`
is always hand-written and only exists for analytically-intersectable shapes.

In a scene, initialize then place:

```glsl
Sphere ball;
void buildObjects(){
    initObject(ball);                                     //identity frame, zeroed material
    ball.frame = makeFrame(vec3(0,1,0));                  //or makeFrame(pos, axis, angleDeg, scale)
    ball.radius = 2.;
    ball.mat = makeGlass(vec3(.3,.05,.2), 1.5);
}
```

`makeFrameNormal(pos, normal)` places surface-like objects (planes) by point + normal.
`basic/` is auto-included by the engine; anything else must be `#include`d from the scene's
`objects.glsl` with a path relative to that file.

## Writing a scene

A scene is a folder `scenes/<name>/` containing a boilerplate `main.js` (seven lines:
import the three `src/` files, call `createScene`) plus `src/` with three files:

**`src/settings.js`** — must default-export `{uiParams, location}`, optionally
`params`, `sky`, and `aspect`:
- `uiParams`: `aperture, focalLength, exposure, focusHelp, fov`, plus `scratch1..scratch4`
  — four always-present generic dials for quick live experiments
- `location`: `{position: [x,y,z], facing: [9 entries, 3x3 rotation]}`
- `params` (optional but preferred): named scene knobs — each entry
  `{name, label, type?, min, max, step, value}` generates a GLSL uniform, a **labeled**
  GUI slider, and a line in saved settings; referenced by `name` in the scene's GLSL.
  This is how keeper controls are exposed (every scene uses them); reach for `scratch`
  only while iterating. A param is a **global uniform**, so pick a name that doesn't
  collide with a function/variable (e.g. not `light`, `scatter`, `roughness`).
  `type` defaults to `float`; `type:'int'` gives an integer slider (handy for
  iteration-count knobs)
- `sky` (optional): `{type:'image', src}` (default `/assets/office.jpg`),
  `{type:'solid', color}`, or `{type:'gradient', top, bottom}`

In dev mode the UI's **Save to Scene** button writes the current camera/parameters
straight back into the scene's `settings.js`; **Download Settings** downloads the
same file, and **Copy Pose** puts just the camera pose on the clipboard.

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

**Position-dependent color** (used by the fractal scenes): keep the object geometry-only and
recolor in the scene as a followup to `setData`. The object exposes a *probe* — e.g.
`vec4 orbitTrap(vec3 p, obj)` or `int region(vec3 p, obj)` — and `setData_Objects` overwrites
`path.dat.surfDiffuse` after `setData` runs:
```glsl
void setData_Objects(inout Path path){
    setData(path, obj);
    if( at(path.tv, obj) ){
        vec3 p = toLocal(obj.frame, path.tv.pos);
        path.dat.surfDiffuse = myColor(p);   // palette lives here, in the scene
    }
}
```
This gives per-hit color without touching the `Material` struct. (Adapting shadertoy fractals
follows the same idea — extract the SDF + camera, discard the shadertoy's renderer, expose a
probe; see `ROADMAP.md` and the `glsl/objects/fractals/` files.)

Larger scenes may split generated geometry data into extra files (see the `cubic*` scenes)
and `#include` them from `objects.glsl`.

The easiest start: copy `scenes/sphere/` wholesale, rename it, and run
`node scripts/gen-pages.mjs` to give it a page and a gallery entry.

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
