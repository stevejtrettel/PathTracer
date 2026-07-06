# Refactor roadmap

State as of July 2026, on branch `refactor` (all of the below discussed and agreed):
the object library is fully migrated to the Frame system — every object is a struct
with a `Frame frame` (similarity transform: rot/pos/scale), a hand-written **local**
`sdf(vec3 p, Type obj)`, and `OBJECT_API(Type)` generating the world-facing interface.
Convention: `vec3` argument = local coordinates, `Vector` argument = world ray state.
Verification tool: `node scripts/render-test.mjs <scene...>` (headless Chrome screenshots
into `render-tests/`).

Phases 3 and 4 were originally separate; discussion (July 2026) merged them — the
"named scene params" and the "uniform descriptor table" are the same object. The full
design is written up in **`docs/gui-design.md`**; the summary follows. Pilot scene =
`sphere`.

## Phase 3/4 — the knob list (unified; next up)

Every tunable control becomes one plain data object — a **knob**:
`{name, label, type, min, max, step, value, group}`, with `type` ∈
`float | bool | color(vec3) | vec2 | vec3`. One **generator** turns a list of knobs into
the four things now hand-synced across five files: GLSL `uniform` decls, three.js uniform
objects, lil-gui controls (each wired `onChange → updateUniforms + reset`), and the
`settings.js` serialization on Download. The knob list is assembled from three sources:

- **camera** knobs (`fov`, `aperture`, `focalLength`, `exposure`, `focusHelp`) — engine-owned
  default list, values overridden per scene from `settings`. (`maxBounces`, `group:'render'`,
  already promoted to a uniform in commit 43e5e71 as the proof-of-concept.)
- **scratch** knobs (`scratch1..4`, renamed from `extra1..4`) — engine-owned, always present.
  These are a deliberate *live-tweak scratchpad*, NOT latent scene params: four generic,
  always-there dials the user rewires constantly while iterating. Kept, not replaced.
- **named** params — the scene's optional `settings.params`. Populated by *promotion*: tune
  on scratch, and when a value is a keeper, graduate it into a named param (rename in GLSL,
  move one line into settings). Scene tab starts scratch-only and accretes meaning.

Riding the same settings pass:
- **Shared `createScene()` entry point**: the 35 `example/*/main.js` are all identical
  (only `cubic-portrait`/`cubic-landscape` differ — a custom aspect ratio). One engine-side
  entry; a scene folder becomes just its `src/` files. The aspect override moves into
  `settings` (a Render control), so those two scenes stop being special.
- **Per-scene sky texture**: hardcoded `/assets/office.jpg` in `buildTraceShader.js` →
  `settings` entry.

Name-collision note: single letters (`a b c d`) are UNSAFE as global scratch uniforms —
they shadow locals everywhere (`d`=829, `a`=712 uses across the GLSL). Multi-char names
(`scratch1`, `extra1`) are collision-free; keep them.

## Phase 5 — custom tabbed GUI (later; a pure renderer swap)

The knob list is the seam: a custom GUI is just a different *renderer* of the same list, so
this decouples fully from the refactor above and changes no scene. Replace lil-gui with a
custom vanilla-JS tabbed panel (no framework — stays consistent with the three.js/vanilla
stack). A knob's `group` field routes it to a tab; each tab = its knob-group render plus
optional hand-written action widgets. Tabs:

- **Scene** — named params + scratch (knobs only)
- **Camera** — lens knobs + pose readout / reset
- **Render** — image geometry + quality: resolution, aspect ratio, preview, `maxBounces`
  (mix of knobs and engine-action widgets)
- **Export** — Save Image, Download Settings, autosave, and the whole HD-tile feature
  (kept intact — a coupled "emit a final file" workflow)
- **Help** — keybinding map + stats (the WASD/QE/arrow bindings are invisible today)

Litmus that assigns Render vs Export: *does it change the picture you're looking at* (Render)
*or produce a file* (Export). HD tiling is file-producing → Export, whole.

## Deferred / smaller items

- **Default bounding-box support in the object API (DONE July 2026)**: the cubic scenes
  hand-rolled a bounding volume and every one hit the same trap — returning the raw bound
  distance as the marched sdf makes the raymarcher (`abs(sdf) < EPSILON`) *hit the bound
  itself*, rendering it as an opaque (glass) shell. Now a first-class, hit-safe feature:
  every object type may define `float bound( Type )` — its bounding-sphere radius in LOCAL
  coords — and the `OBJECT_LOCATORS` world sdf skips the real sdf (returning the bound
  distance) whenever the ray is outside, with `BOUND_MARGIN` (0.05, > EPSILON) keeping the
  raw bound out of the hit band. Default `bound()` = 10000 (effectively unbounded, no
  behavior change); a type opts into a tight bound via the `*_B` macros (`OBJECT_API_B`).
  Baked so far: `Box` (`length(sides)+rounded`), `CubicSurface` (`3`). Follow-ups: give
  `Variety` a bound (needs its scene-set bbox radius exposed as a field), and migrate the
  cubic scenes' hand-rolled group bounds onto the feature (they share one cubicF eval
  across the group via caching, so that needs a group-level bound, not just per-object).
- **cubicSurface / cubic-portrait still broken (separate from the bounding bug)**:
  `cubicSurface` renders black — `settings.facing` is the identity at `position=[0,2,-6]`,
  so the camera points away from the object at the origin (an unfinished WIP camera).
  `cubic-portrait` renders dim/faint (glass fixed, but a lighting/exposure issue remains;
  its camera IS aimed correctly). Both got the bounding fix; both need a real camera /
  lighting pass to actually render.
- **Dead `render_Environment` / `render_Objects` flags**: declared in every
  scene's environment.glsl / objects.glsl but never read — `trace_Scene` always
  traces both. Either wire them up (skip tracing when false) or delete them.
  (Found during A4: setting `render_Environment=false` did nothing.)
- **render-test staleness gotcha**: `vite-plugin-glsl` caches the inlined
  `setupShader` transform, so editing an *included* `.glsl` (e.g. sky.glsl)
  without touching the parent serves a stale shader. `rm -rf node_modules/.vite`
  before render-testing GLSL-include changes; also kill stray dev servers first
  (a squatter on :5173 makes render-test screenshot the wrong thing).

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
