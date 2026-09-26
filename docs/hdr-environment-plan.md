# HDR environment maps — plan, and what was built

> **Status (Sep 2026): steps 1–6 are built** — `js/hdr.js` (loader),
> `_makeSkyTexture` in `js/PathTracer.js` (RGBA32F upload + `skyLinear`),
> `skyTex`/`getSky` in `glsl/tracer/1Setup/sky.glsl` (rotation, intensity,
> linear-vs-sRGB), the Sky Intensity / Sky Rotation knobs (Render tab), the
> `pt-sky-ready` event render-diff waits on, and the test scene
> `scenes/hdrSky` (sky: `public/assets/monkstown_castle_2k.hdr`, Poly Haven
> CC0 — soft, brightest pixel ~39, converges evenly). **Still open: the firefly
> caveat below**, for skies with a small bright sun — e.g. Poly Haven's
> sunflowers_puresky: a ~40-pixel sun up to ~70,000 carrying 47% of the light,
> found by diffuse bounces only by chance (tried, and dropped from the repo).

Goal: let a scene's sky be a real HDR image (Radiance `.hdr`), so bright regions
— windows, the sun, a softbox — actually LIGHT the scene instead of clipping at
1.0 like the 8-bit `office.jpg` does today. `.jpg` skies keep working unchanged.

## Where the sky lives today

- `settings.sky` (or `description.sky`, which wins — `js/scenegen/emitter.js`):
  `{type: 'image', src}` (default `/assets/office.jpg`), `{type: 'solid', color}`,
  `{type: 'gradient', top, bottom}`.
- `js/shaderData/buildTraceShader.js` → `buildSky()` turns that into
  `{mode, src, color1, color2}`; uniforms `sky`, `skyMode`, `skyColor1/2`.
- `js/PathTracer.js` → `_makeSkyTexture(desc)`: an `<img>` uploaded as RGBA8
  (flipY, mipmaps), `reset()` on load. The render-diff tool waits for that load.
- `glsl/tracer/1Setup/sky.glsl` → `skyTex(v)`: equirectangular lookup,
  `textureLod(sky, uv, 0.)` (level 0 since the Sep 2026 fix), then
  `SRGBToLinear` — i.e. the shader assumes an sRGB-encoded 8-bit image.
- Files are served from `public/assets/` (shared by every build).

## The plan

1. **Loader** — new `js/hdr.js`, no dependencies: `fetch(src)` → ArrayBuffer →
   parse the Radiance header (`#?RADIANCE` / `#?RGBE`, `FORMAT=32-bit_rle_rgbe`,
   optional `EXPOSURE=`, then the resolution line `-Y H +X W`), decode the
   scanlines — new-style RLE (each scanline starts `2 2 hi lo`, then 4
   channels run-length encoded separately) or flat RGBE — to float RGB with
   `v = (c + 0.5) / 256 * 2^(e - 128)` (0 when e = 0). ~80 lines.
2. **Upload** — `RGBA16F` texture (filterable in WebGL2 core; type `FLOAT`
   data is accepted for a 16F internal format), LINEAR min/mag, no mipmaps
   (the shader samples level 0), rows flipped in JS to match the jpg path's
   `UNPACK_FLIP_Y` orientation. 4k×2k = 64 MB of texture; 2k is plenty for
   a background. *As built (Sep 2026): RGBA32F when `OES_texture_float_linear`
   is available (4k×2k = 128 MB), because half float tops out at 65504 and an
   unclipped sun above that uploads as Inf (a black sun: the accumulator drops
   the sample); without the extension, RGBA16F with values clamped to 65504.*
3. **Shader** — the sky must know if its texture is sRGB-encoded (jpg) or
   linear (hdr): a uniform (e.g. `skyLinear`, or `skyMode = 3` for "linear
   image") so `skyTex` skips `SRGBToLinear` for HDR.
4. **Descriptor** — same `{type: 'image', src}`; `_makeSkyTexture` picks the
   loader by extension (`.hdr` → hdr.js, else `<img>`). Keep `reset()` on load.
   The render-diff tool's "wait for images" hook only counts `new Image()`:
   make the HDR path also hold the start (e.g. count fetches, or expose a
   `window.__skyReady` promise) or HDR scenes will be unstable in render-diff.
5. **Knobs worth adding** (engine knobs, Scene or Render tab): sky
   **intensity** (a multiplier — HDRIs vary wildly in absolute scale) and sky
   **rotation** (yaw, to put the bright window where the composition wants
   it). Both are cheap uniforms in `skyTex`. Intensity changes need a reset
   (it's lighting, not exposure).
6. **A test scene** — e.g. `scenes/hdrStudio` (a few spheres: chrome, glass,
   matte on a floor, NO room so the sky is visible and does the lighting), or
   switch `sheet` (already image-lit) to the HDR. Render-diff references get a
   new entry; nothing else changes (no existing scene uses HDR).

## Expected caveat: fireflies from a bright sun

Light aiming (`aimLights.glsl`) only aims at sphere lights, so a small, very
bright region of an HDR (the sun) is found by chance → speckle, the same
problem sphere lights had. Forward-only follow-up, in the spirit of the rest
of the tracer: at load, find the few brightest compact regions of the HDR and
hand them to the aiming mixture as extra **cones of directions** (a direction
cone is exactly what aimLights already samples — no two-point problem, one
closed-form density). Full environment importance sampling (a CDF over every
pixel) would work too but is the kind of probability machinery the tracer
avoids.

## Asset

Poly Haven HDRIs are CC0. Put the file in `public/assets/<name>.hdr`
(2k ≈ 6 MB, 4k ≈ 24 MB — commit the 2k).
