# Removing three.js — raw WebGL2 migration plan

Goal: **bundle size.** three is 451 KB of the 540 KB bundle (83%), essentially
all of it the WebGL renderer. The path tracer is 100% hand-written GLSL; three is
just a GPGPU harness + a math library. Removing it takes the bundle to ~90–140 KB
with **no change to the path-tracing math or the shaders**.

Measured (sphere, minified): bundle 540 KB / gzip 138 KB · three renderer 451 KB
/ 114 KB · three math-only 51 KB / 15 KB · app JS + inlined GLSL ~89 KB.

## Stage 1 — DONE (commit e052f57)
three's `Vector2/Vector3/Matrix3/Matrix4` (+ `Quaternion`, `MathUtils`, two
coord-system constants) copied verbatim into `js/math/`; every math import
repointed there. three now enters the bundle ONLY via the renderer
(ComputeShader/WebGLRenderer), sky textures, and Stats. Renders identical.

## Stage 2 — replace the renderer with raw WebGL2

### Guiding principle: preserve ComputeShader's interface
PathTracer and UI reach into ComputeShader only through:
- `material.uniforms.<name>.value` — `frameNumber` (`+= 1`, `%`, `>=`) and
  `panelToRender` (read/write), used in PathTracer.js + UI.js.
- methods `render()`, `renderToScreen()`, `getData()`, `updateUniforms(obj)`,
  `setSize(res)`.

Keep `this.material = { uniforms: {name:{value}} }` as a **plain object** (three's
ShaderMaterial happens to expose that shape; a plain object is identical) and keep
the method signatures. Then the rewrite is ~90% inside ComputeShader.js and
PathTracer/UI barely change.

### The shader ABI shim (agreed: option A — GLSL untouched)
Modern WebGL2 needs `#version 300 es`, a precision line, and a declared `out`.
The shaders use old-style `gl_FragColor` (3 sites) + one `texture2D`, no version
/precision (confirmed: only comment matches). The compile step prepends and
rewrites in JS — the GLSL files are never edited:

    #version 300 es
    precision highp float;
    precision highp int;
    out vec4 pc_fragColor;
    // + source.replace(/\bgl_FragColor\b/g,'pc_fragColor').replace(/\btexture2D\b/g,'texture')

Vertex shader is a fixed attributeless fullscreen triangle (from `gl_VertexID`);
fragments use `gl_FragCoord`, so no varyings/attributes are needed (the current
`uv` attribute is unused).

### 2a — new `ComputeShader.js` on WebGL2
- `constructor(data, gl, res)`:
  - compile program (shared FS-triangle vertex + shimmed fragment). On
    compile/link failure call `showShaderError(gl, program, vs, fs)` directly
    (replaces three's `onShaderError` hook; ErrorOverlay unchanged, and
    `getShaderSource` now returns our shimmed source — snippet lines self-consistent).
  - enumerate active uniforms via `gl.getActiveUniform` → cache
    `{name:{location,type,unit?}}`; assign a texture unit per `SAMPLER_2D`.
  - build `this.material.uniforms` from `data.uniforms` (preserve shape).
  - two `RGBA32F` FBO textures a/b at `res` (needs `EXT_color_buffer_float`);
    `NEAREST`, `CLAMP_TO_EDGE`, no depth/stencil. (32F = matches today's FloatType.)
- `updateUniforms(obj)`: `this.material.uniforms[k].value = v` (unchanged).
- `render()`: `useProgram`; bind fboA; `viewport(res)`; apply all uniforms
  (dispatch on cached GL type below); `drawArrays(TRIANGLES,0,3)`; swap a/b;
  `this.data = texB`.
- `renderToScreen()`: `useProgram`; bind framebuffer null; `viewport(canvas)`;
  apply uniforms; draw.
- `setSize(res)`: re-`texImage2D` both FBO textures; update `iResolution`.
- `getData()`: return the current data `WebGLTexture`.
- Shared per-gl: one empty VAO + the vertex shader.

**Uniform dispatch (by cached GL type — robust, no manual table):**
FLOAT→`1f` · INT→`1i` · BOOL→`1i` · FLOAT_VEC2→`2f(x,y)` · FLOAT_VEC3→`3f(x,y,z)`
· FLOAT_MAT3→`uniformMatrix3fv(loc,false,m.elements)` (three `.elements` is
column-major = what WebGL wants) · SAMPLER_2D→`activeTexture(unit)`+`bindTexture`
+`1i(loc,unit)`. Values are our js/math Vectors (`.x/.y/.z`), Matrix3 (`.elements`),
numbers, and `WebGLTexture`s.

### 2b — `PathTracer.js` swap
- `this.canvas = document.createElement('canvas')`;
  `this.gl = canvas.getContext('webgl2', {preserveDrawingBuffer:true})` (keeps
  `toDataURL` for saveImage); `gl.getExtension('EXT_color_buffer_float')` (fail
  loudly via the overlay if absent); append canvas.
- Pass `this.gl` to the three ComputeShaders.
- `resize(res)`: set `canvas.width/height`, store `this.size = res`, call each
  ComputeShader `setSize` (each sets its own viewport per draw).
- `startHDRender`: replace `renderer.getSize(new Vector2())` with `this.size`.
- `saveImage`: unchanged (`canvas.toDataURL`).

### 2c — sky texture (`buildTraceShader.js`, deferred to when gl exists)
Uniforms are built before the gl context exists, so `buildSky` returns a
**descriptor** `{mode, color1, color2, src|null}` (no GL object); the `sky` uniform
starts `null`. PathTracer (after gl) creates the `WebGLTexture`: 1×1 white
immediately; for image mode `new Image()`, and `onload` → `texImage2D` +
`generateMipmap` + `reset()`. **Match three's TextureLoader defaults for identical
sky:** RGBA8 / UNSIGNED_BYTE, `UNPACK_FLIP_Y = true`, min `LINEAR_MIPMAP_LINEAR`,
mag `LINEAR`, wrap `CLAMP_TO_EDGE`. (three's default `colorSpace` is NoColorSpace →
RGBA8, no sRGB decode → raw GL matches; do NOT use an SRGB internal format.)

### 2d — `Stats` → tiny `FpsMeter`
`three/addons/libs/stats.module` → a ~15-line `js/FpsMeter.js` with `.dom`,
`.begin()`, `.end()` (rAF fps). UI Help hosting unchanged.

### 2e — error overlay rewire
Remove the `renderer.debug.onShaderError` line in `createScene.js`; ComputeShader's
compile calls `showShaderError` directly. `ErrorOverlay.js` unchanged.

### 2f — drop the dependency + measure
Remove `three` from `package.json` (keep `vite-plugin-glsl`). Build sphere; expect
~90–140 KB. Full render-test panel + visual compare.

## Risk hotspots
1. **Sky fidelity** — flipY, mipmaps, filter, colorspace. Verify against an
   image-sky scene (office.jpg default).
2. **Float FBO** — `EXT_color_buffer_float` required for RGBA32F; guard + overlay.
3. **Precision** — ES3 fragment default is mediump; prepend highp (no conflicts).
4. **ABI replace** — word-boundary `\bgl_FragColor\b` / `\btexture2D\b`.
5. **bool / mat3** — bool via `1i`; mat3 `.elements` column-major, transpose=false.

## Verification matrix (each sub-stage)
sphere (glass) · variety (image sky + surface) · cubic (bounds) · a color/vec2
knob scene · an HD tile render · Save Image · Save-to-Scene. Compare against
pre-Stage-2 screenshots.
