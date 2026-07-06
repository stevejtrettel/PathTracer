# GUI / parameter system design

Design agreed July 2026 (branch `refactor`). This is the plan for the knob-list refactor
(Phase 3/4) and the custom tabbed GUI (Phase 5) in `ROADMAP.md`. Nothing here is built yet
except `maxBounces` (commit 43e5e71), which is the first knob, wired the old hand-synced
way as a proof that a promoted GLSL constant works as a live uniform.

## The problem

Every tunable control is currently written by hand in FIVE places that must stay in sync.
For `fov`:

```
glsl/tracer/1Setup/uniforms.glsl   uniform float fov;
js/shaderData/buildTraceShader.js  fov: { value: uiParams.fov }
js/UI.js  (control)                cam.add(this.params,'fov',15,140,1).name('FOV').onChange(v=>{updateUniforms({fov:v}); reset()})
js/UI.js  (printParams)            str += `fov: ${this.params.fov},\n`
example/*/src/settings.js          fov: 29
```

Change a range → four places drift. Add a param → five edits × up to 35 scenes.

## The idea: one knob = one data object

```js
{ name: 'fov', label: 'FOV', type: 'float', min: 15, max: 140, step: 1, value: 29, group: 'camera' }
```

A single **generator** loops a list of these and produces all four outputs. The list is the
only new concept ("knob list" / "params list").

### Knob fields

| field   | meaning                                                                 |
|---------|-------------------------------------------------------------------------|
| `name`  | GLSL identifier + JS key. Must be collision-free (see below).            |
| `label` | GUI display name. Defaults to `name` if omitted.                        |
| `type`  | `float` \| `bool` \| `color` \| `vec2` \| `vec3`                         |
| `min`/`max`/`step` | float/vec sliders only. Sensible defaults per type.          |
| `value` | initial value. `number`, `bool`, or array (`[r,g,b]`, `[x,y]`).         |
| `group` | which GUI tab/folder: `camera` \| `scene` \| `scratch` \| `render`.     |

### Types → outputs

| `type`  | GLSL uniform   | GUI widget          | settings value   |
|---------|----------------|---------------------|------------------|
| `float` | `uniform float`| slider (min/max/step)| `0.73`          |
| `bool`  | `uniform bool` | checkbox            | `true`           |
| `color` | `uniform vec3` | color picker        | `[1, 0.15, 0]`   |
| `vec2`  | `uniform vec2` | two sliders         | `[0.5, 0.5]`     |
| `vec3`  | `uniform vec3` | three sliders       | `[...]`          |

The generator is a small `switch(type)`. Adding a type = one more case.

### The four generated outputs (worked example)

For `{name:'scratch1', type:'float', min:0, max:1, step:0.001, value:0, group:'scratch'}`:

```
GLSL       →  uniform float scratch1;
three.js   →  scratch1: { value: 0 }
GUI        →  folder.add(obj,'scratch1',0,1,0.001).onChange(v => { updateUniforms({scratch1:v}); reset() })
serialize  →  scratch1: 0            (in the downloaded settings.js)
```

`color`/`vec` differ only in widget + value shape; the `onChange → updateUniforms + reset`
wiring is identical for every knob.

## Where knobs come from (merge order)

```
knobList = [ ...cameraKnobs, ...scratchKnobs, ...(scene.params ?? []) ]
```

- **cameraKnobs** — engine-owned default list (`fov`, `aperture`, `focalLength`, `exposure`,
  `focusHelp`; `maxBounces` with `group:'render'`). Same list every scene; the scene's
  `settings` overrides only the *values*. This is what kills the five-place camera sync.
- **scratchKnobs** — engine-owned, fixed: `scratch1..4` (renamed from `extra1..4`), all
  `float`, `0..1`, step `0.001`, `group:'scratch'`. Always present in every scene.
- **scene.params** — optional, declared in the scene's `settings.js`:

  ```js
  export const params = [
    { name: 'scatter', value: 0.73, min: 0, max: 1 },
    { name: 'emit',    value: 0.37, type: 'color', value: [1, 0.15, 0] },
  ];
  ```

  Referenced by `name` directly in the scene's `objects.glsl` (no declaration, no boilerplate).

### Scratch vs named — the workflow

Scratch dials are a deliberate **live-tweak scratchpad**: generic, always-there, rewired
constantly while iterating. They are NOT semantic scene params. Named params are the
**retired keepers**: once a scratch value lands, promote it — give it a `name`, move one
line into `settings.params`, rename the identifier in the GLSL — and the scratch dial is
free again. Scene tab starts scratch-only and accretes named params over time.

### Name collisions

Single letters are UNSAFE as global scratch uniforms — they shadow local variables all over
the shader. Measured across the ~24k lines of concatenated GLSL: `d`=829, `a`=712, `b`=377,
`c`=363 standalone uses (uppercase `A..D` are used too). Multi-char names (`scratch1`,
`fov`) are collision-free. Named params get real names and the author owns collision
avoidance (same as naming any variable today); a startup warning should list reserved
engine names (`fov`, `aperture`, `location`, `sky`, `frameNumber`, …) and flag clashes.

## Riding along in the same settings pass

- **`createScene()`** — one engine-side entry replacing the 35 identical `main.js`. A scene
  folder becomes just `src/{environment.glsl, objects.glsl, settings.js}`. The only
  meaningful `main.js` variant today is `cubic-portrait`/`cubic-landscape` (custom √2 aspect
  ratio); that moves into `settings` as a Render control, so they stop being special.
- **Per-scene sky** — hardcoded `/assets/office.jpg` → `settings.sky ?? default`.
- **Download** — regenerates `settings.js` (knob values + camera location) in the new
  format. Just settings, no GLSL, no zip.

## Phase 5 — custom tabbed GUI (later, decoupled)

The knob list is the seam. A custom GUI is a different *renderer* of the same list, so it
changes no scene and can come after the sweep. Custom vanilla-JS (no framework). A knob's
`group` routes it to a tab; each tab = its knob-group render + optional hand-written action
widgets (not every control is a knob — resize/save/download are engine actions).

```
Scene    knobs: named params + scratch
Camera   knobs: fov · aperture · focalLength · exposure · focusHelp   + pose readout / reset
Render   knob: maxBounces (+ advanced quality later)   actions: resolution · aspect · preview
Export   actions: Save Image · Download Settings · autosave · HD tiles (whole feature)
Help     keybinding map + stats
```

**Render vs Export litmus:** does it change the picture you're looking at (Render) or
produce a file (Export)? HD tile rendering is file-producing → Export, kept whole (a
coupled workflow; splitting its geometry into Render isn't worth the cross-tab friction).

## Build sequence

- **A.** knob list + generator + `createScene()` + per-scene sky, still rendered by lil-gui.
  Prove on pilot scene `sphere` (smallest; its `extra` uses are representative), verify with
  `node scripts/render-test.mjs sphere`.
- **B.** sweep the 35 scenes onto it (behavior-frozen, render-test panel each checkpoint).
- **C.** custom tabbed GUI as a pure renderer swap.

## Status (built so far)

- `maxBounces` promoted to a live `int` knob (commit 43e5e71).
- **A1** knob generator + `settings.params` named knobs, piloted on sphere (`ior`).
- **A2** camera/render/scratch routed through the generator; `engineKnobs.js` is the
  single source, `uniforms.glsl` drops the hardcoded knob block. Added `int` knob type.
- **A3** shared `js/createScene.js`; every `main.js` is a 5-line stub; `settings.aspect`
  dissolves cubic-portrait/landscape.
- **A4** per-scene `settings.sky`: image / solid / gradient (`buildSky` + `getSky`).
- **B** renamed the scratch dials `extra/extra2/extra3/extra4` → `scratch1..4` everywhere
  (engineKnobs list, ~130 scene GLSL + settings files, and the two library files
  `algVariety.glsl` / `apolonianGasket.glsl`). Behavior-frozen (values moved with names).
- **C1** custom tabbed GUI as a renderer swap (lil-gui removed). `js/gui/`: `widgets.js`
  (pure builders `slider`/`toggle` + `control()` router + `el`/`button`/`numberField`/
  `select`/`section` furniture), `Panel.js` (hamburger-collapsed stateful shell), `gui.css`
  (dark translucent). `UI.js` no longer `extends GUI`; assembles the five tabs (Scene /
  Camera / Render / Export / Help), injects one `wire` as every widget's onChange, seeds
  `this.values` so Download Settings serializes identically. Behavior-frozen.
- **C2** the new affordances: Render **live Aspect** dropdown (presets incl. √2, re-fits
  canvas; preselects `settings.aspect`); Camera **pose readout + Reset**; **fps stats moved
  into Help** (createScene hands `stats` to UI). `select` generalized to `[label,value]`
  pairs. Sky-color kept **file-driven** (rarely needs a live knob) — no `colorPicker` built.

**Phase 5 COMPLETE (C1 + C2).** Deferred if ever wanted: a `colorPicker` widget for a
live sky-color knob (Scene tab), and `xyPad` for vec2.
