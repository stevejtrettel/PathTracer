# demos — the reference library

Instrument pages for the engine. These are **instruments, not art** — the art
lives in [`scenes/`](../scenes/).

```
demos/
  _studio/      shared environments (no main.js — not a page)
  materials/    the material system  (3Materials/) — this file
  objects/      the object/SDF library (glsl/objects/)
```

Run any page by name, from either subfolder — names are unique across the
whole project, so the folder never has to be typed:

```
npm run dev <name>          # e.g. npm run dev playground
```

Every page is also linked from the root gallery (`npm run dev` with no
argument), under a heading per subfolder.

---

# materials/

Reference pages for the material system (`glsl/tracer/3Materials/`, designed in
[docs/material-system.md](../docs/material-system.md) and
[docs/material-fields.md](../docs/material-fields.md)).

## The three tiers

Names are prefixed so the gallery groups them alphabetically.

### `ref-*` — catalogs: *what can I make?*

| page | shows |
|---|---|
| `ref-presets` | one sphere per named preset in `presets.glsl` — opaque, metal, transmissive, subsurface. The master tuning reference. |
| `ref-metals` | every named F0 conductor, polished and brushed. Most metals are nearly colourless — only gold, copper and their alloys are strongly tinted. |
| `ref-thin` | thin two-sided surfaces (`setSurfaceInMat`) as lit paper lanterns: with no interior, `transmitTint` **is** the material's colour. |
| `ref-fields-stone` | procedural solids whose pattern **is** the substance: marble, granite, lapis, agate, wood, damascus. |
| `ref-fields-weathered` | six layers accumulating on a base — rust, patina, dust, lichen, snow, waterline. One `coverage` knob drives all six. |
| `ref-fields-exotic` | fields that drive something other than albedo: films (pearl, oil slick), emission (lava), and the bare `mixMaterial` mechanism. |

### `axis-*` — sweeps: *what does this one knob do?*

Each page fixes everything but a single parameter and sweeps it left to right,
usually across two contrasting rows.

| page | axis | rows |
|---|---|---|
| `axis-roughness` | `surf.roughness` 0 → max | glass (ground-glass blur) vs gold (rough metal **saturates**, not greys) |
| `axis-coat` | `surf.coat` 0 → 1 | matte cherry (wet-stone) vs rough gold (lacquered metal) |
| `axis-transmit` | `surf.transmit` 0 → 1 | clear interior vs absorbing interior (the tint only appears as the door opens) |
| `axis-density` | `interior.mfp` dense → ballistic | smooth exit (jade, marble, glass) vs rough exit (wax, clay) |
| `axis-fresnel` | `surf.gloss` vs `interior.ior` | the two ways to get a highlight: the artistic floor lifts the whole curve, the physical index brightens only the rim |
| `axis-absorb` | Beer's `exp(-absorb·d)` | more glass (growing radius) vs more pigment (growing extinction) — visually identical, which is the point |

`axis-density` is the one to read first. The claim organizing the whole system
is that diffuse, subsurface, and glass are **one axis, not three mechanisms** —
that page is the axis, ending at literal `makeGlass` in its rightmost column.

### `fx-*` — phenomena: *effects that need their own rig*

| page | shows |
|---|---|
| `fx-fog` | the ambient-medium hook: open air as a scattering medium, giving god rays. Turn `roomLight` down and `lightPower` up. |
| `fx-soapfilm` | thin-film interference on a two-sided surface, with drainage. Needs `spectral` for true rainbows. |
| `fx-iridescence` | the same film over five substrates — bare shell, black, white, gold, nacre. Iridescence is a *contrast* effect: it needs a dark base to read. |

### `playground` — *build one yourself*

One sphere with every field of `Surface` and `Medium` on a live knob, assembled
field-by-field so the panel maps 1:1 onto the structs. Recipes for glass,
frosted glass, jade, wax, gold, car paint, and a soap bubble are listed at the
top of its `objects.glsl`.

---

# objects/

Reference pages for the object library (`glsl/objects/`) — one shape or shape
family per page, named for the shape itself (no `ref-`/`axis-`/`fx-` prefix;
that grouping is a materials/ concern).

| page | shows |
|---|---|
| `sphere` | the analytic primitive — exact closed-form intersection, no marching. In glass, so one view reads the silhouette, the shadow, and the room refracted through the interior at once. |

Object pages use the `empty.glsl` studio: a bare ceiling-lit box, so the only
thing in frame is the shape.

---

## Conventions

**`demos/_studio/` holds the shared environments**, one level above both
subfolders so `materials/` and `objects/` pages share them (import path
`../../_studio/…`). Three rigs:

- `neutral.glsl` — grey box, one key light. For the `axis-*` sweeps and
  `ref-presets`: anything coloured in the walls would contaminate a measured
  comparison. *(needs `lightPower`, `roomLight`)*
- `accent.glsl` — same rig, brighter, with warm/cool side walls so glossy and
  metallic materials have something coloured to reflect. For the
  `ref-fields-*` charts. *(needs `lightPower`, `roomLight`)*
- `empty.glsl` — a tighter bare box with **no key light**: the ceiling is the
  only emitter. For `objects/`, where a pinpoint highlight would fight the
  shape. *(needs `roomLight` only)*

**No cross-imports.** A demo imports its environment from `../../_studio/`,
never from another demo's folder. (`_studio/` has no `main.js`, so
`gen-pages.mjs` correctly ignores it rather than treating it as a page.)

**Adding a page.** Create `demos/<kind>/<name>/` with `main.js`,
`src/objects.glsl`, and `src/settings.js` — copy the closest existing page —
then run `node scripts/gen-pages.mjs` to generate its `index.html` and relink
the gallery. In `materials/`, pick the prefix that matches what the page is
*for*: a catalog (`ref-`), a single-parameter sweep (`axis-`), or a phenomenon
(`fx-`).

**Adding a new demo kind.** The subfolders are declared in one place —
`DEMO_KINDS` in [`scripts/gen-pages.mjs`](../scripts/gen-pages.mjs) (title +
blurb for the gallery) and `SCENE_ROOTS` in `scripts/run-example.mjs`,
`scripts/render-test.mjs`, and `vite.config.js`.
