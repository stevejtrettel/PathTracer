# The scene generator

*The generator is **built** (`js/scenegen/`, July 2026) and every non-variety
scene in `scenes/` runs from a `src/scene.js` description. This file is the
design record: §2 is the GLSL contract the emitter produces, §5 the decided
schema, §6 what the variety pass still owes. The practical how-to-write-a-scene
guide is [scene-authoring.md](scene-authoring.md).*

---

## 1 · What the generator is for

A scene is a JS description. The generator turns it into the GLSL chunk that
`buildTraceShader` concatenates between the setup shader and the trace shader.

Two rules, both learned the hard way while hand-writing the scenes:

**The generator emits glue and structure. Never math.** Every formula lives in a
hand-written `.glsl` file — `glsl/shapes/` for named objects, `computations.glsl`
for operators, `3Materials/` for materials and fields. If the generator ever
wants to emit an expression more complicated than a call or a combinator, the
library is missing a function.

**The output is code a human would be happy to read.** Not the tightest code —
where the two disagree, readability wins and we pay the arithmetic. The seven
scenes in `scenes/` are the standard: that is what generated output should look
like.

---

## 2 · What gets emitted

### 2.1 Per object

An object is one region of space (or one *sheet* — see §2.4). Every function
takes a **world** point; placement is baked inside.

```glsl
float    sdf_<name>     (vec3 p);                        //exact. always
Vector   normal_<name>  (vec3 p);                        //4-tap of the above. always
Material material_<name>(vec3 p, inout Vector n);        //always (+ `bool front` on sheets)
Medium   medium_<name>  (vec3 p);                        //always

float    bound_<name>   (vec3 p);                        //optional
float    trace_<name>   (Vector tv);                     //optional
bool     inside_<name>  (vec3 p);                        //only with SCENE_SUBSURFACE
```

- **`sdf_`** is the shape tree flattened: transform, library call, displacement,
  Lipschitz divisor. It stays **exact** — bounds never appear here (§2.5).
- **`normal_`** is always the 4-tap. There are no analytic normals: the moment an
  object is displaced its analytic normal is wrong, and differentiating the
  *world* sdf handles any transform inside it by the chain rule. Verified in
  `scenes/transform` — a rotated, non-uniformly scaled body shades correctly
  with no inverse-transpose fixup anywhere.
- **`bound_`** and **`trace_`** stay hand-written, because they are *authored
  knowledge* the generator cannot derive: someone chose that bounding shape, and
  someone solved that intersection.
- **`inside_`** is emitted per region with only the nested-region exclusions that
  region actually has (§3.1).

### 2.2 Shapes that yield several regions

A multi-material object is **one shape evaluation feeding several regions**.
Splitting it into independent per-region sdfs evaluates the shape twice, which
is the whole thing composites exist to avoid.

```glsl
void sdf_cocktail(vec3 p, out float cup, out float drink){
    vec3  q = p - GLASS_P;
    float cavity;
    cup   = cocktailGlassDistance(q, G_RADIUS, G_HEIGHT, G_THICKNESS, G_BASE, cavity);
    drink = max(cavity, q.y - WATERLINE);
}

//single-region entry points, for the 4-tap normals
float sdf_cup(vec3 p){   float cup, drink; sdf_cocktail(p, cup, drink); return cup;   }
float sdf_drink(vec3 p){ float cup, drink; sdf_cocktail(p, cup, drink); return drink; }
```

So `sdfAll` is organised **by shape, not by region** — one call filling several
slots. The per-region wrappers exist only because a 4-tap normal has to
differentiate one region at a time.

### 2.3 Dispatchers

```glsl
const int N_OBJ = 4;
float gSDF[N_OBJ];

void     sdfAll    (vec3 p);                                    //fills gSDF, exact
Vector   normalOf  (int id, vec3 p);
Material materialOf(int id, vec3 p, inout Vector n, bool front);
Medium   mediumOf  (int id, vec3 p);                            //ID_NONE -> defaultMedium()
bool     isSheet   (int id);
bool     insideOf  (int id, vec3 p);                            //only with SCENE_SUBSURFACE
```

Ids are `const int ID_<NAME>`, numbered in **declaration order, inner to outer**,
because that order is containment priority and it also breaks the tie at a wall
shared by two objects (the earlier one owns the Surface).

### 2.4 Sheets

A sheet is a two-sided surface with no interior. Both sides open onto whatever
region contains it, so the interface is index-matched: no refraction, and
crossing does not change the ray's medium. All it contributes is a `Surface`,
and it has two — front and back, picked by `front` in `materialOf`.

**A sheet's sdf stays signed, not `abs()`.** `abs()` puts a kink exactly at the
surface and the 4-tap straddles it and returns noise — the same failure as
differentiating a union at a shared wall. The marcher stops on `|sdf| < eps`
regardless of sign, so a signed level set is already hit from both sides. What
makes something a sheet is `isSheet()`, not the shape of its sdf.

### 2.5 Entry points

```glsl
void  buildScene();
float sdf_Scene  (Vector tv);   //the MARCHED union, bound-accelerated
float trace_Scene(Vector tv);   //analytic surfaces only
```

`sdf_Scene` and `sdfAll` are **two emissions of the same tree**, and the
difference is the point:

| | `sdf_Scene` | `sdfAll` |
|---|---|---|
| runs | hundreds of times per bounce | twice per bounce |
| bounds | **yes** — early-out on bounding volumes | **never** |
| contents | marched objects only | every object, incl. analytic ones |

Bounds must not appear in `sdfAll`, because the classifier tests
`abs(gSDF[i]) < AT_THRESH`; a short-circuited sdf there would stop an object
being recognised at its own surface and every hit on it would return `ID_NONE`.

Analytic objects are absent from `sdf_Scene` but present in `sdfAll` — trace
finds the hit, sdfs classify it.

### 2.6 What is NOT generated

`setData_Scene` — the classifier — is engine code in `5Scene/scene.glsl`, written
once. So is `regionAt`, and the whole tracer. The generator never emits
per-scene classification logic; that was the point of the rewrite.

### 2.7 Conventions (settled by the July 2026 normalization)

During the migration, hand-written scene files normalized to these conventions
were the emitter's verification targets, gated by comment-stripped code
equality (`npm run gen <scene> -- --check`). With every scene converted the
references were deleted (git history keeps them); the gate for emitter changes
is now `npm run gen` diffs plus a render look.

**Two namespaces, told apart by word order.**

- **Stem-first = hand-written library math** (`glsl/shapes/`):
  `<stem>Distance(vec3 p, ...)` required, `p` LOCAL, params after;
  `<stem>Trace(Vector tv, vec3 centre, ...)` optional, world;
  `<stem>Bound(vec3 p, ...)` optional. File name == stem. Anything else in the
  file (`roomFace`) is a free-form helper, included verbatim. Multi-output
  shapes name their outputs with one annotation:
  `//@shape cocktailGlass -> wall, cavity`. The scenegen catalogue is PARSED
  from these files (vite raw glob + signature parse) — there are no companion
  JS registry files, and an unparseable `shapes/` file is a loud load error.
- **Kind-first = emitted glue**: `sdf_<name>`, `normal_<name>`,
  `material_<name>`, `medium_<name>`, `bound_<name>`, `trace_<name>`,
  `inside_<name>`, `toLocal_<name>`, `data_<eqn>`, `sdf_Scene`, `trace_Scene`.

**Emitted forms.**

- Constants: placement `const vec3 <NAME>_P`; shape parameters
  `<NAME>_<ARGNAME>` from the signature (`BALL_RADIUS`, `ROOM_HALFSIZE`);
  knob-free Lipschitz divisors `<NAME>_LIP`, knob-driven ones inlined as an
  expression in the sdf.
- `sdf_Scene` / `trace_Scene` are always the accumulate form
  (`float d = maxDist; d = min(d, ...); return d;`). Bound tests bind
  `float b_<name>` and use the ternary (single sdf) or if/else (group) form;
  a scene with nothing marched returns `maxDist` directly.
- Every traced object gets a `trace_<name>(Vector tv)` wrapper; `trace_Scene`
  mins the wrappers in declaration order.
- Constant materials emit their constructor twice — `material_<name>` returns
  it, `medium_<name>` returns `...interior` — with no shared helper function.
- `material_<name>` takes `bool front` ONLY on sheets.
- Numbers: integer-valued floats are written `X.0`; everything else plain
  (`0.25`, `14.25`).
- Slot contracts for authored GLSL bodies: sdf/bound bodies see `q` (local);
  material bodies see `p` (world), `q` (local) and `inout Vector n`; field
  functions take `vec3 q`.

---

## 3 · What the generator knows statically

This is where generation buys more than convenience. Several things that would
have to be runtime searches in hand-written code are **compile-time facts**.

### 3.1 Containment

`insideOf` needs "is p inside region k", which is *not* `sdf_k(p) < 0` when
regions nest — the shell's solid contains the core, so a walk in the shell would
sail through the core's wall. The generator knows the nesting, so it emits only
the terms that region actually needs:

```glsl
bool inside_core (vec3 p){ return sdf_core(p) < 0.; }
bool inside_shell(vec3 p){ return sdf_shell(p) < 0. && sdf_core(p) >= 0.; }
```

Usually zero extra terms. The alternative — a general `regionAt` scan over all N
objects — runs once per scatter step and **sixteen times per boundary crossing**
inside `bisect_Scatter`, so this matters.

### 3.2 Capability flags

The generator knows which regions scatter, refract, or carry a varying index, so
whole engine subsystems can be compiled away. `settings.defines` already injects
these at the top of the shader.

| flag | condition | effect |
|---|---|---|
| `SCENE_SUBSURFACE` | any region has `mfp < maxDist` | **done** — `mediumWalk.glsl` and the `pathTrace` branch vanish; `insideOf` is not needed at all |
| `SCENE_INDEX_FIELD` | any region has a varying index | existing engine hook (`odeMarch`) |
| `SCENE_AMBIENT_MEDIUM` | the scene declares fog | existing engine hook |
| *transmit* | no region transmits | **not built** — the transmit tier of `scatter()` could compile out |

### 3.3 Derived numbers

What the generator computes is a FIXED FORMULA over data the description
declares — it holds no knowledge of its own (that lives in presets):

- **Lipschitz divisors.** A displacement makes the sum non-1-Lipschitz and the
  over-relaxed marcher steps through it. The divisor is `1 + amp·gradBound`,
  with `gradBound` DECLARED by the field (or pre-filled by a preset —
  `|grad fbm(f·p)| ≤ 3.26·f`, `|grad fbm2(f·p)| ≤ 2.01·f` live in
  `fbmHeight`/`fbm2Height`). Getting this wrong is not "a bit slow" —
  under-estimating lets the marcher miss the surface, which is why the formula
  is applied by the emitter rather than retyped per scene.
- **Bound inflation.** A displaced object's bound is the base shape pushed out
  by `maxAbs(range)·amp`, or the bound shaves off the very detail it encloses.
  All other non-library bounds are authored (`bound:` on the node), and an
  authored bound overrides any derivation.
- **Trace/march routing.** A displaced, repeated, or transformed object has no
  closed form, so it loses `trace_` and moves into `sdf_Scene`.
- **`AT_THRESH`** could be derived from `EPSILON·(2 + MARCH_CONE·maxDist)` rather
  than being a hand-tuned constant that happens to fit. (Still open.)

---

## 4 · The spec: eight scenes

Each scene pins down something different; all but `variety` are generated from
`src/scene.js` (variety keeps hand-written GLSL until the variety pass, §6).
The hand-written references the others were checked against live in git
history.

| scene | pins down |
|---|---|
| `glassball` | the floor: analytic everything, `sdf_Scene` returns `maxDist`, nothing marches |
| `cocktail` | one shape → two regions; a shared wall; a group bound; a library include |
| `proto` | several objects at once; marched + analytic mixed; material as a field |
| `rock` | displacement inside the sdf; one height field driving geometry **and** colour; Lipschitz divisor; bound inflation |
| `subsurface` | the medium walk; nested regions; a non-air/non-air interface; `insideOf`; `SCENE_SUBSURFACE` |
| `transform` | rotation + non-uniform scale with no normal fixup; a lattice as one region |
| `sheet` | `isSheet`; front/back Surfaces; index-matched crossing; the image sky |
| `variety` | equation → sdf via dual numbers; the signed-sdf / abs-at-marcher idiom; surface vs volume as one flag |

---

## 5 · The JS schema (decided July 2026; skeleton is next)

Settled in the scene-builder design discussion:

- **Runtime emission.** `main.js` calls `createScene(emit(description))`; the
  description (`src/scene.js`) is the artifact and generated GLSL is never
  committed. A dump script (`npm run gen <scene>`, plus `--catalogue`) writes
  the emitted GLSL for inspection and for the equality check against the eight.
- **Catalogue access.** `lib.sphere({radius: 1.2})` off the catalogue parsed
  from `glsl/shapes/` (Proxy: a typo throws immediately, with suggestions).
  Strings never name code; everything referenceable is a JS binding.
- **Nodes.** `object` / `group` (one shape evaluation → several region slots +
  the shared bound) / `sheet` (front/back material slots). Placement (`at`,
  `rotate`, `scale` — knob-driven allowed) lives on the node; the emitter
  derives `toLocal_`, the min-singular-value Lipschitz factor, and the bound.
- **Knobs.** `knob('name', {...})` returns a JS binding; self-registers at
  module eval; name collisions are a loud emit error. Declarations (label,
  range, default) live in scene.js; current VALUES live in settings.js
  (`export const values = {...}`), merged by the loader; Save-to-Scene writes
  only settings.js (camera pose, uiParams, values). Sky moves INTO scene.js;
  aspect and camera stay in settings.
- **Escape hatches.** glsl`` bodies at every slot (sdf, bound, material,
  field), or a scene-local `.glsl` file imported `?raw`, or scene-level
  `glsl: [src]` blocks prepended verbatim. `${...}` interpolation is REQUIRED
  for fields (dependency + emission ordering), optional for knobs. An authored
  body that calls a library file declares it: `uses: [lib.cocktailGlass]`.
- **Authored GLSL references nothing magical.** An authored body may name only:
  things defined in authored GLSL itself (its own `consts:` block, scene-level
  `glsl:` helpers, fields), knobs (declared visibly in the same scene.js), and
  interpolated JS values. The emitter's derived const names (`<NAME>_<PARAM>`)
  NEVER appear in authored code — share values as plain JS bindings instead.
  For readable output, interpolations can be NAMED: `${{latticeHalf}}` (JS
  shorthand) emits `/*latticeHalf*/vec3(...)`, so a folded constant keeps its
  meaning in the generated code.
- **Explicit descriptions, formulaic generator** (July 2026 simplification).
  The core has a SMALL set of first-class mechanisms and no built-in
  knowledge: the two shape wrappers `displace(by, amp)` and
  `repLim(spacing, limit)`, plus `rotate`/`scale` placement. Everything the
  emitter derives is a fixed formula over DECLARED data — displace's divisor
  `1 + amp*gradBound` and inflation `maxAbs(range)*amp` from the field's
  declared metadata, the transform's min-singular-value factor. Fields are
  one kind: an authored GLSL function + declared `{gradBound, range}`; the
  noise gradient constants live in PRESETS (`fbm2Height`, `fbmHeight` in
  presets.js), not in the core. Groups are always AUTHORED bodies assigning
  their regions (the old lib-group `from:`/cutAbove output-plumbing was
  removed — proto's tumbler form won). Bounds are derived only where
  principled (`<stem>Bound` from the catalogue, displace's inflation);
  everything else is an authored `bound:` expression, which overrides any
  derivation. Multi-material groups remain the one deliberately rich
  mechanism, and their design may be refined further.
- **Nesting is declared** (`nestedIn: 'shell'`), never inferred: it yields the
  `insideOf` exclusion terms and an order check. Capability flags derive from
  material constructor KINDS (`makeSubsurface` → `SCENE_SUBSURFACE`), not
  values — mfp can be a live knob.
- **Engine hooks reserved.** Scene-level `indexField:` and `ambient:` keys will
  emit the hook function plus its define (`SCENE_INDEX_FIELD`,
  `SCENE_AMBIENT_MEDIUM`); their exact shape is designed when the blackhole and
  fog scenes are ported. `scene()` rejects unknown top-level keys so the names
  are reserved now.

Still open, deliberately: the variety builder (§6 — design it against the 14
legacy variety scenes, carefully), the presets API (`room()`, `sphereLight()` —
plain JS functions over the schema, no engine involvement), and `//@`
annotation grammar beyond `//@shape`.

---

## 6 · OPEN — gaps in the spec

The seven scenes exclude patterns that dominate `legacy/`. Designing the schema
against them alone risks a schema that cannot express a quarter of the library.

- **Varieties** — 14 of 52 legacy scenes. A dual-number gradient evaluator plus a
  distance estimate; the old `VARIETY_DATA` macro must become generated code.
  **Deliberately its own build pass**, designed after the non-variety generator
  is finished (done July 2026 — all seven non-variety scenes generate).
  Requirements settled in discussion:
  - a **catalogue of variety formulas** (parsed like shapes; feeds `--catalogue`)
  - some formulas are naturally **homogeneous in R⁴**, some live in **R³**; the
    R⁴ ones must also be drawable **stereographically projected** (`invStereo`,
    as in the original scenes/varieties files)
  - **surface OR region as a first-class authoring choice** from the bottom
    (not a post-hoc flag): a surface-mode variety is a `sheet` (front/back
    faces, abs-at-marcher); a region-mode one has an interior
  - region mode needs an easy **thickened** form — a shell, thick on BOTH
    sides of the zero set — as well as the solid form (filled on one side)
- **Tracer hooks** — `indexField` (blackhole ×3, luneburg), ambient fog. Already
  clean `#define` + function contracts, so probably easy, but unproven.
- **Iteration-state materials** — orbit-trap colouring (apollonian, kleinian ×3,
  honeycomb ×2). Five of these do not currently compile, since they write
  `path.dat.surfDiffuse`, removed in the material rewrite.
- **Shared cached evaluation at scale** — the cubic scenes feed one polynomial and
  gradient to five objects, with hierarchical group bounds and a non-uniform
  stretch. Partly proven by `cocktail` and `transform`, not at that scale.
- **Non-orientable sheets** — a Möbius band has no consistent front, so it would
  declare one `Surface` and ignore `front`. Nothing forces this yet.

A variety scene is the highest-value next addition, on volume alone.

---

*`docs/procedural-scenes.md` is stale — it predates the classifier's final form,
sheets, `insideOf` and the capability flags. Treat this file as current.*
