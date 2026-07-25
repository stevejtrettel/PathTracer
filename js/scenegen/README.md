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
| `nodes.js` | `scene()` / `object()` / `group()` / `sheet()` — validated plain-data nodes; groups are always AUTHORED sdf bodies; `uses: [lib.x]` declares library calls inside authored code. `scene()` drains the knob/field registries onto the description, so the returned value is SELF-CONTAINED and `emit()` is pure |
| `catalogue.js` | `glsl/shapes/*.glsl` parsed into builders (`lib.sphere({...})`); no companion JS files, the .glsl signatures ARE the metadata |
| `combinators.js` | the two shape wrappers: `displace(by, amp)`, `repLim(spacing, limit)` |
| `fields.js` | `field()` — ONE kind: an authored GLSL function + declared `{gradBound, range}` (required only to displace) |
| `materials.js` | the material PRIMITIVES only: `material({surf, interior})` (the escape hatch — a `{surf, interior}` bundle from raw struct fields), `withSurface`/`withMedium`/`named` merges, `matKind` (from set-fields), `absorbFor`, `checkArgs`. Names NO material — every named material (archetypes + looks) is a preset in `js/presets/materials.js` |
| `knobs.js` | `knob()` — self-registering tunables, drained by scene() |
| `glslTag.js` | the ``glsl`` `` tag + `valueText` (the one rule for interpolating values into authored GLSL) + `bodyText`/`qLine` (the rules every authored body goes through) |
| `fmt.js` | number/vector formatting (shortest float32-exact decimal, `X.0` rule), dedent/indent/pad, the reserved-identifier check |
| `plan.js` | planning: each node → a plain UNIT record (consts, sdf/bound/trace text, dispatcher pieces) |
| `emitter.js` | validation over the assembled plan, the section printers, `emit()` |

**Content lives elsewhere** — `js/scenegen/` is assembly only. Scene presets
(`room()`, `sphereLight()`, the field presets holding the noise gradient
bounds) are plain JS over this public surface in [`js/presets/`](../presets/);
GLSL content is parsed from `glsl/shapes/` (shapes) and
`glsl/tracer/3Materials/` (materials). Presets import FROM scenegen, never
the reverse.

## Tools

```
npm run gen <scene>                  print the emitted chunk
npm run gen <scene> -- --check       comment-stripped code equality vs src/scene.glsl
npm run gen -- --catalogue           what the shape parser believes
npm run gen -- --materials           what the material parser believes
npm run gen -- --goldens             byte-compare every scene vs render-tests/goldens/
npm run gen -- --goldens --write     re-bake the goldens (deliberately, after eyeballing)
```

The hand-written `scene.glsl` references served as the emitter's targets
during the migration and were deleted once every scene converted (git history
keeps them; `--check` still works for any scene that has one). The regression
gate for emitter changes is the committed goldens: `--goldens` byte-compares
every scene's chunk, and an intended output change is re-baked with `--write`
so its full blast radius shows up as a git diff.
