# The scene system

Front door to how scenes work after the July 2026 rewrite (branch `scene-builder`).
For emission detail see [generator.md](generator.md); for materials see
[material-system.md](material-system.md).

---

## The goal

Scenes are authored in JS (`src/scene.js`) and the **generator**
(`js/scenegen/`, built July 2026) emits the GLSL at page load. The generator
emits only glue and structure; all math lives in hand-written libraries. Every
non-variety scene in `scenes/` runs this way. Authoring guide:
[scene-authoring.md](scene-authoring.md); emitter contract and schema:
[generator.md](generator.md).

Two standing rules:

- **The generator emits call sites and combinators, never math.** If it would need
  to emit an expression more complex than a call, the library is missing a function.
- **Output reads like clean hand-written code.** Not the tightest code — where
  readability and speed disagree, readability wins and we pay the arithmetic.

---

## The model

**A scene is a list of objects. Each object is one region of space** defined by a
**signed sdf** `s(p)` — positive outside, negative inside, zero on the boundary.
That is the whole primitive. Six walls of a room, the two parts of a cocktail,
the faces of a variety — all are *materials as a function of position over one
region*, not separate objects.

**Objects are declared inner-to-outer.** Declaration order is containment priority
and also breaks the tie at a wall two objects share (the earlier one owns it).

**Trace mode is a per-object flag, not a different kind of object.** The same
signed `s` is drawn either way:

- **volume** — march `s`. `{s<0}` is solid; the ray refracts/absorbs through it.
- **surface** — march `abs(s)`. The ray stops on `{s=0}` and passes through
  `{s<0}`: the zero set as an infinitely thin two-sided membrane.

The critical invariant: **`abs()` lives only at the marcher (`sdf_Scene`). The
object's own `sdf` stays signed.** So its gradient is a real normal and its sign
is the side, and front/back materials work with no special case in either mode.
A "sheet" is just an object traced as a surface; `isSheet` additionally means "no
interior" (excluded from containment, both sides index-matched).

**Interfaces are classified, not authored.** A surface is the boundary between two
media; which two is worked out at the hit by the engine, from the sdfs. Scenes
never write interface case-analysis.

---

## The engine (built, in `glsl/tracer/`)

- **`5Scene/scene.glsl` — the classifier.** At a hit it reads every object's sdf
  (`sdfAll`), finds which object's boundary it is on (`|sdf| < AT_THRESH`), finds
  what is on the other side (a second coincident boundary, else the innermost
  containing object, else air), and fills `LocalData`. This replaces the four
  hand-written `setData` wrappers, now deleted (`interaction.glsl` is gone).
- **`3Materials/path.glsl` — `LocalData` / `Path`.** `LocalData` carries the two
  sides of the interface: `frontID`/`front` and `backID`/`back` (each a `Medium`),
  the `Surface`, and the normal. `Path` carries `Medium medium` + `int region` —
  the medium the ray is currently in. No `Material` ever reaches `LocalData`; a
  Material pairs a surface with *its own* interior, and an interface's two halves
  come from different objects.
- **`6Trace/mediumWalk.glsl` — subsurface.** Region-aware (`insideOf`, tracking
  `path.region`), and compiled out entirely unless the scene declares
  `SCENE_SUBSURFACE`.
- Everything else (raymarch, scatter, spectral, ODE/curved transport) is unchanged.

---

## The per-object contract

Every object supplies, all taking a **world** point (placement baked in):

```glsl
float    sdf_<name>     (vec3 p);                        // SIGNED. always
Vector   normal_<name>  (vec3 p);                        // 4-tap of sdf. always
Material material_<name>(vec3 p, inout Vector n);        // regions
Material material_<name>(vec3 p, inout Vector n, bool front);  // sheets: two faces
Medium   medium_<name>  (vec3 p);                        // when it is the far side
float    bound_<name>   (vec3 p);                        // optional, hand-written
float    trace_<name>   (Vector tv);                     // optional, analytic
bool     inside_<name>  (vec3 p);                        // only with SCENE_SUBSURFACE
```

plus dispatchers (`sdfAll`, `normalOf`, `materialOf`, `mediumOf`, `isSheet`, and
`insideOf` when subsurface), and the entry points `sdf_Scene` (marched union,
bound-accelerated, `abs()` wrapped around surface-traced objects) and
`trace_Scene` (analytic surfaces).

Two structural facts:

- **One shape can fill several object slots.** A multi-material object is one sdf
  evaluation feeding several regions (`sdf_cocktail(p, out cup, out drink)`), so
  `sdfAll` is organised by shape, not by object. Splitting them would evaluate the
  shape twice — the thing composites exist to avoid.
- **Bounds are the acceleration structure, and live only in `sdf_Scene`.** Never
  in `sdfAll`: the classifier tests `|sdf| < AT_THRESH`, so a short-circuited sdf
  there would stop an object being recognised at its own surface. Group bounds
  cover an object and everything nested in it.

The generator derives what an author would forget: Lipschitz divisors for
displacement, bound inflation, trace-vs-march routing, and the capability flags
(`SCENE_SUBSURFACE`, `SCENE_INDEX_FIELD`, `SCENE_AMBIENT_MEDIUM`) that compile
whole subsystems away. See [generator.md](generator.md) §3.

---

## The library (`glsl/shapes/`, math only)

Plain functions of a point and some floats — no structs, no `Frame`, no
`Material`. Ported so far: `sphere`, `room`, `cocktailGlass`, `variety`. The old
struct-based `glsl/objects/` library is retired to `legacy/` and ported per shape
as scenes need it. `glsl/objects/computations.glsl` keeps the generic operators
(`opRepLim`, `smax`, `bBox`, `bCyl`, `cylinderDist`).

Varieties are the one new kind: authored as an equation `T eqn(T,T,T)` (dual
numbers), from which the generator emits a four-line gradient evaluator
(`data_<eqn>`, replacing the old `VARIETY_DATA` macro); `varietyDistance` turns it
into a distance, `varietyShell` thickens a surface into a volume.

---

## The spec: eight scenes

Each pins down one thing. All except `variety` are generated from
`src/scene.js` (variety keeps hand-written GLSL until the variety pass).

| scene | pins down |
|---|---|
| `glassball` | the floor: everything analytic, nothing marches |
| `cocktail` | one shape → two regions; a shared wall; group bound; library include |
| `proto` | many objects; marched + analytic mixed; material as a field of position |
| `rock` | displacement in the sdf; one height field driving geometry AND colour; Lipschitz divisor; bound inflation |
| `subsurface` | the medium walk; nested regions; non-air/non-air interface; `SCENE_SUBSURFACE` |
| `transform` | rotation + non-uniform scale with no normal fixup (chain rule); a lattice as one object |
| `sheet` | surface trace; front/back materials; index-matched crossing; image sky |
| `variety` | equation → sdf; the signed-sdf / abs-at-marcher idiom; surface vs volume as one flag |

All eight run. `transform` and `glassball` confirmed ~120 fps; `cocktail` matches
its legacy twin once lighting is equalised (wall albedo drives path length).

---

## Where we are / next

1. **Done:** engine rewrite; the eight scenes; `glsl/shapes/` started; `legacy/`
   holding 52 old scenes + demos (excluded from the build); the **generator**
   (`js/scenegen/`) with all seven non-variety scenes converted to
   `src/scene.js` descriptions and their hand-written references retired to
   git history. Design rules settled: explicit descriptions / formulaic
   generator, knowledge in presets, authored GLSL references nothing magical
   (generator.md §5).
2. **Next: port `legacy/` scene by scene**, non-variety first — each port
   grows the shapes catalogue and the preset shelf, never core machinery. The
   eight cover most patterns, but these are unproven and will extend the system:
   - **varieties at scale** (14 legacy scenes) — mostly covered by `variety`
   - **tracer hooks** — `indexField` (blackhole ×3, luneburg), ambient fog; clean
     `#define` contracts, probably easy
   - **orbit-trap materials** (apollonian, kleinian ×3, honeycomb ×2) — material
     depends on iteration state; five of these currently don't compile (they write
     the removed `path.dat.surfDiffuse`)
   - **cubic scenes** — one polynomial + gradient shared across five objects,
     hierarchical bounds, a non-uniform stretch
   - **non-orientable sheets** — a Möbius band has no consistent front; declares
     one `Surface`, ignores `front`

The camera in every new scene is a rough guess; the author flies each one and
saves it (see [[pathtracer-working-style]] — framing is a by-eye call).
