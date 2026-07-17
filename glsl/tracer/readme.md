# The trace shader

The path-tracing fragment shader is assembled (by js/buildTraceShader.js) from
three pieces, in order:

1. **setupShader.glsl** — includes the numbered stages below plus the
   always-available objects (`objectAPI`, `computations`, `basic/_basic`).
   Camera/render knob uniforms (aperture, fov, exposure, maxBounces,
   scratch1..4, ...) are generated from the knob lists and injected above it.
2. **the scene** — each scene supplies `src/environment.glsl` and
   `src/objects.glsl` (see any folder in scenes/), which must define:
   `buildEnvironment() sdf_Environment() trace_Environment() setData_Environment()`
   `buildObjects() sdf_Objects() trace_Objects() setData_Objects()`
3. **traceShader.glsl** — includes 5Scene + 6Trace and runs the trace loop.

The numbered stages:

- **1Setup** — uniforms & constants, math helpers, dual-number machinery and
  variety formulas (algVariety), random number generators, the sky.
- **2Space** — tangent vectors and Frames (geometry), reflection/refraction
  (physics), the camera.
- **3Materials** — the Material, LocalData, and Path structs; setting surface
  data on impact; scattering; picking up color along the path.
- **5Scene** — combines the scene-supplied environment and objects.
- **6Trace** — raymarch/raytrace, stepping forward, subsurface scattering,
  and the main pathTrace loop.

The separate **accumulate/** and **display/** shaders are their own programs:
accumulate blends each new frame into the running average; display tone-maps
and gamma-corrects the accumulated image to the screen.
