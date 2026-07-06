# Refactor roadmap

State as of July 2026, on branch `refactor` (all of the below discussed and agreed):
the object library is fully migrated to the Frame system — every object is a struct
with a `Frame frame` (similarity transform: rot/pos/scale), a hand-written **local**
`sdf(vec3 p, Type obj)`, and `OBJECT_API(Type)` generating the world-facing interface.
Convention: `vec3` argument = local coordinates, `Vector` argument = world ray state.
Verification tool: `node scripts/render-test.mjs <scene...>` (headless Chrome screenshots
into `render-tests/`).

## Phase 3 — scene authoring consolidation (next up)

- **Shared `createScene()` entry point**: all 35 `example/*/main.js` files are identical
  copies. Replace with one engine-side entry (`js/createScene.js` or similar) so a scene
  folder is just its three `src/` files; `main.js` shrinks to a few lines or disappears.
- **Per-scene sky texture**: the environment map is hardcoded to `/assets/office.jpg` in
  `js/shaderData/buildTraceShader.js`. Make it a `settings.js` entry.
- **Named scene parameters**: replace the anonymous `extra`/`extra2`/`extra3`/`extra4`
  sliders with named params declared in settings (`{name, label, min, max, value}`),
  generating both the lil-gui controls and the GLSL uniforms. Scenes reference them by
  name in GLSL.

## Phase 4 — single uniform descriptor table

The camera/render parameter list is hand-synced across five places: `uniforms.glsl`,
`buildTraceShader.js`, `UI.params`, `UI.printParams`, and every scene's `settings.js`.
One descriptor table should generate: the GLSL uniform declarations, the three.js uniform
objects, the GUI controls, and the settings download. Builds on Phase 3's machinery.

## Deferred / smaller items

- **apollonian_broken**: renders black; verified pre-existing (identical before the frame
  migration). Suspects: the `extra`-slider coupling in the gasket sdf and the always-true
  `at()`. Debug or delete the example.
- **Orphan objects with no scene**: menger, trefoil, poincareMarble/hypDod (only used by
  archived `final/seifertWeber`). Small demo scenes would keep them exercised by the
  render-test panel (the icosahedron bug survived years because nothing rendered it).
- **Cubic scenes' rotation machinery**: `rotXZ`/`standUp`/`plateRot` in the cubic scenes
  mutate positions in a pseudo-world; could fold into the objects' frames and delete the
  scene-level code. Do when next working on those scenes (behavior needs eyeballing).
- **Glass shells don't inherit variety frames**: `createVar*Glass` places the shell with
  `makeFrame(var.frame.pos)` (no rotation/scale inheritance). Fine today; revisit if a
  scene rotates/scales a wrapped variety.
- **Local-unit thresholds**: the surf* edge-band (0.005) and the gasket trace bail-out are
  in local units post-migration — they scale *with* the object (arguably correct; noted in
  code comments). Only matters for `frame.scale != 1`.
- `pi` vs `PI` both exist (lowercase used by vendored sdf_gallery files) — unify only if
  ever touching those files anyway. `package.json` has no name/version fields.
- KeyControls moved to `event.code` — verify all 12 bindings by hand once (arrows,
  `'`/`/` up/down, WASD + QE).
