# scenegen — the scene generator

A scene is authored as JS (`scenes/<name>/src/scene.js`) and emitted to GLSL at
page load. The description is the artifact; generated GLSL is never committed.

**How to write a scene: [docs/scene-authoring.md](../../docs/scene-authoring.md).**
Design and conventions: [docs/generator.md](../../docs/generator.md)
(§2.7 emitted forms, §5 schema decisions) and
[docs/scene-system.md](../../docs/scene-system.md).

## The flow

```
scene.js ──(builders: object/group/sheet, lib.*, knob, glsl, fields)──▶ description
description + settings.js ──emit()──▶ { scene: GLSL chunk, settings }  ──▶ createScene()
```

Knob **declarations** live in scene.js; current **values** (and the camera
pose) live in settings.js, which Save-to-Scene keeps writing. `emit()` merges
the two.

## The modules

The design rule (settled in discussion): **explicit descriptions, formulaic
generator**. The core has a small set of first-class mechanisms and no
built-in knowledge — everything it derives is a fixed formula over data the
description DECLARES. Anything that knows particular math (noise gradients,
the standard room) is a preset: plain JS you import.

| file | is |
|---|---|
| `index.js` | the public surface — everything a scene.js imports |
| `nodes.js` | `scene()` / `object()` / `group()` / `sheet()` — validated plain-data nodes; groups are always AUTHORED sdf bodies; `uses: [lib.x]` declares library calls inside authored code |
| `catalogue.js` | `glsl/shapes/*.glsl` parsed into builders (`lib.sphere({...})`); no companion JS files, the .glsl signatures ARE the metadata |
| `combinators.js` | the two shape wrappers: `displace(by, amp)`, `repLim(spacing, limit)` |
| `fields.js` | `field()` — ONE kind: an authored GLSL function + declared `{gradBound, range}` (required only to displace) |
| `materials.js` | JS mirrors of the GLSL constructors (`makeGlass`, ...) with the `kind` the emitter reasons from |
| `knobs.js` | `knob()` — self-registering tunables, drained by emit |
| `glslTag.js` | the ``glsl`` `` tag + `valueText`: the one rule for interpolating values into authored GLSL |
| `fmt.js` | number/vector formatting (`1.0` rule), dedent/indent |
| `emitter.js` | planning (units + regions) and the section printers |
| `presets.js` | plain JS over the schema: `room()`, `sphereLight()`, and the field presets (`fbm2Height`, `fbmHeight`) where the noise gradient bounds live |

## Tools

```
npm run gen <scene>              print the emitted chunk
npm run gen <scene> -- --check   comment-stripped code equality vs src/scene.glsl
npm run gen -- --catalogue       what the shape parser believes
```

The hand-written `scene.glsl` references served as the emitter's targets
during the migration and were deleted once every scene converted (git history
keeps them; `--check` still works for any scene that has one). The regression
gate for emitter changes is now `npm run gen` diffs plus a render look.
