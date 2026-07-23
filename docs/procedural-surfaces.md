# Procedural surfaces

How a smooth mathematical object acquires *substance* — relief you can see in
the silhouette, grain you can see in the highlight, and material that varies
over the surface — under one authoring model.

This doc **subsumes** [material-fields.md](material-fields.md): that document
described surface material fields and the `applyMaterial` followup, which stay
exactly as they are but are no longer hand-wired per scene. It sits alongside
[material-system.md](material-system.md) (what a `Material` *is*),
[marching.md](marching.md) (the marcher whose invariants constrain everything
here) and [bounding-volumes.md](bounding-volumes.md) (the `bound()` cull this
extends).

> TL;DR — three additions, each independently useful.
> **(1) The scene list.** One `SCENE_LIST(X)` declaration generates
> `sdf_Objects`, `setData_Objects` and `inside_Object`, killing a five-way
> hand-sync. **(2) Geometry fields.** A `Texture tex` slot on an object gives it
> a height field, rendered in *two channels at once*: coarse octaves **displace**
> the sdf, fine octaves **bump** the normal, split automatically at the marcher's
> resolution floor. **(3) One model.** Material fields, geometry fields and
> volume fields become three instances of the same idea, with the same
> attachment mechanism and the same escape hatch.

---

## Part 0 · The unified model

An object today carries **flat data**: a `Frame`, shape parameters, a
`Material`. Everything is constant over the surface. Making something vary means
hand-writing a followup in `setData_Objects`.

The model this doc builds: every object has **two data slots and two field
slots**, and the flat data is simply the default the field starts from.

| | flat data (per instance, knob-drivable) | field (function of the local point) |
|---|---|---|
| **material** | `obj.mat` — a `Material` | `matField(vec3 p, Material base) → Material` |
| **geometry** | `obj.tex` — a `Texture` | `texHeight(vec3 p, Texture t) → float` |

Plus a third family that is neither, because it is consumed along a segment
rather than at a point:

| | | |
|---|---|---|
| **volume** | `mat.interior` — a `Medium` | `indexField(vec3 p)` and friends, integrated by `odeMarch` |

The taxonomy from [material-fields.md](material-fields.md) is unchanged — it
just gains a row. Surface data is sampled once at a hit; volume data must be
integrated; **geometry data is sampled in the march loop**, which is what makes
it the expensive and constrained one.

### What this subsumes

- **Flat materials** — untouched. An object with no field and `tex.amp == 0`
  compiles to the same shader it does today (see the byte-identical gates in
  Part 8).
- **Material fields** — the `applyMaterial` followup mechanism is untouched.
  What changes is that it is *attached declaratively* in the scene list instead
  of hand-written in `setData_Objects`, so it can no longer drift out of sync
  with the other four functions.
- **Multi-material objects** (glass shells, liquids, varieties-in-shells) —
  opt out of the scene list entirely and hand-write their `setData`, exactly as
  today. See Part 7.
- **Volume fields** — unchanged, and the hook table in
  [material-fields.md](material-fields.md) gains one row.
- **Displacement** — new.

---

## Part 1 · The scene list

### The problem

A scene currently maintains the same object list in five places:
`buildObjects`, `sdf_Objects`, `trace_Objects`, `setData_Objects`,
`inside_Object`, plus one material-field followup per object. They are
hand-synced, and every omission fails *silently*:

| omission | symptom |
|---|---|
| missing from `sdf_Objects` | object invisible |
| missing from `setData_Objects` | object renders as sky |
| missing from `inside_Object` | subsurface scattering silently wrong |
| followup forgotten | object renders with its flat base material |

Adding a `tex` slot makes this worse, not better. So the list becomes data.

### The mechanism: X-macros

One declaration, expanded once per generated function:

```glsl
#define SCENE_LIST(X)              \
    X( plinth, wornStone )         \
    X( vase,   noField    )        \
    X( ball,   noField    )

SCENE_OBJECTS(SCENE_LIST)
```

`SCENE_OBJECTS` expands to:

```glsl
float sdf_Objects( Vector tv ){
    float d = maxDist;
    #define X(o, f)   d = min(d, sdf(tv, o));
    SCENE_LIST(X)
    #undef X
    return d;
}

void setData_Objects( inout Path path ){
    #define X(o, f)                                              \
        setData(path, o);                                        \
        if( at(path.tv, o) ){                                    \
            vec3 lp = toLocal(o.frame, path.tv.pos);             \
            applyMaterial(path, f(lp, o.mat));                   \
        }
    SCENE_LIST(X)
    #undef X
}

bool inside_Object( Vector tv ){
    #define X(o, f)   if( inside(tv, o) ){ return true; }
    SCENE_LIST(X)
    #undef X
    return false;
}
```

`buildObjects` stays hand-written — it is the part with real content
(placement, parameters, knobs), and it is the one place a missing object is
*loud* rather than silent.

### The no-field sentinel

Rather than branch in the preprocessor (GLSL ES has no `#`/`##` operators, so
conditional expansion on an argument is awkward), the "no field" case is a real
function:

```glsl
Material noField( vec3 p, Material base ){ return base; }
```

`applyMaterial(path, noField(lp, o.mat))` re-runs `setObjectInAir` with the
same material and the recovered geometric normal. Negation is exact in IEEE
754, so the result is bit-identical to not calling it — which is what makes the
Part 8 gate achievable. The cost is one struct copy per hit, negligible against
a march.

### Portability risk (spike this first)

Passing a macro *name* as a macro argument is one step past anything currently
in the codebase — `OBJECT_API(Type)` is plain function-like expansion. The
X-macro pattern needs no `#`/`##`, only argument substitution, and should be
within GLSL ES 3.00's preprocessor. **Verify before building on it.**

Fallback if a driver balks: numbered variants,

```glsl
SCENE_OBJECTS_3( plinth, wornStone, vase, noField, ball, noField )
```

for arities 1–8. Uglier, certainly portable, and kills the desync just as well.
Everything downstream in this doc is indifferent to which form ships.

---

## Part 2 · Geometry fields

### 2.1 The height field

One authored object per texture:

```glsl
float texHeight( vec3 p, Texture t );     //  [-1, 1], zero-mean
```

Zero-mean matters: displacement `A·h` then wobbles the surface *about* the
original rather than inflating it, so an object keeps its nominal size and the
band bounds in §2.4 stay symmetric.

It is rendered in two channels **simultaneously**:

- **macro** — coarse octaves, displace the sdf. Real silhouette, real
  self-shadowing, real contact.
- **micro** — fine octaves, perturb the shading normal. Free, but flat in
  profile and with no interocclusion.

### 2.2 The resolution floor — where the split comes from

`AT_THRESH = 0.003`, and adaptive cone epsilon widens the marcher's landing
band to `EPSILON·(2 + MARCH_CONE·t)` ≈ 0.0025 at `t = 100`
([uniforms.glsl:33-48](../glsl/tracer/1Setup/uniforms.glsl)). A displaced
feature whose amplitude is near that band gets smeared into the hit tolerance,
and — worse — `OBJECT_NORMAL_FD` differentiates at `ep = 1e-4`, so sub-floor
displaced noise yields *noisy normals*, not fine detail. It costs more and looks
worse.

So the crossover is not an artistic choice. It is a property of the renderer:

> **Displace every octave whose amplitude clears the landing band. Bump the
> rest.**

For fbm with total amplitude `A`, gain `g`, octave `i`:

```
octave i displaces   iff   A·gⁱ  >  TEX_FLOOR          (≈ 0.01 = 3·AT_THRESH)
```

With `A = 0.035`, `g = 0.5`: octaves 0 and 1 displace (0.035, 0.0175); octaves
2+ (0.009, 0.004, 0.002 …) bump. The author typed `makeStone(0.035, 3.0)` and
got the right split.

### 2.3 Why the split makes displacement affordable

Displacement costs a Lipschitz correction (§2.4) of `1 + A·L`. For fbm with
gain·lacunarity = 1 — which is what [fields.glsl](../glsl/tracer/3Materials/fields.glsl)
uses — *every octave contributes equally* to `L`. So:

| displaced band | L | step cost on that object |
|---|---|---|
| all 6 octaves (naive) | ~6·F·L₁ | **~2.0×** |
| 2 octaves (split at the floor) | ~2·F·L₁ | **~1.3×** |

The dropped octaves are simultaneously the most expensive and the least
visible. They return through the bump channel at full strength and zero march
cost, so the split is a pure win — cheaper *and* higher-frequency detail than
displacing the full spectrum.

Second benefit, equally important: the displaced field now contains only low
frequencies, so FD normals at `ep = 1e-4` are clean **by construction** rather
than by tuning. The noisy-normal failure mode is designed out.

### 2.4 The Lipschitz correction (why displacement is dangerous)

[raymarch.glsl](../glsl/tracer/6Trace/raymarch.glsl) is over-relaxed sphere
tracing with the Keinert overlap fallback. Both the relaxation and the fallback
require the returned scalar to be a genuine **unbounding radius**:
`|f(p)| ≤ dist(p, surface)`.

`f = d − A·h` breaks that. If `|∇h| ≤ L` then `|∇f| ≤ 1 + A·L`, so `f`
*overestimates* distance by up to that factor and the marcher tunnels — visible
as red speckle in debug mode 5.

The fix is exact, not heuristic. If `f` is `K`-Lipschitz and vanishes on `S′`,
then for the nearest `q ∈ S′`,

```
|f(p)| = |f(p) − f(q)| ≤ K·|p − q| = K·dist(p, S′)
⇒  dist(p, S′) ≥ |f(p)| / K
```

so `f / K` is a valid unbounding radius:

```glsl
return (d - A*h(p)) / (1. + A*L);
```

The cost is exactly that factor in step length, and it is **per object** —
`sdf_Scene` is a `min`, so nothing else in the scene slows down.

**Every pattern must therefore publish its `L`.** The constructors compute it;
an author never types one. Analytic where possible:

| pattern | `h` | `L` (at unit frequency) |
|---|---|---|
| `makeRibs` | `sin(k·x)` | `k` exactly |
| `makeStone` | banded fbm | `Σ (g·l)ⁱ · L₁`, summed over displaced octaves |
| `makeCrackle` | `worleyEdge` | measured, with safety factor |
| `makePaper` | high-freq fbm | micro-only; no `L` needed |

`L₁` (the max gradient of the unit-frequency, unit-amplitude value noise) is
measured empirically in stage 4 and baked as a const with a safety factor.
Debug mode 5 is the gate that says whether the factor is honest.

### 2.5 The band short-circuit

The displaced surface lies inside `{|d| ≤ A}` (zero-mean `h`, amplitude `A`).
So outside a band around the surface, a cheap 1-Lipschitz underestimate is
available and **the noise need not be evaluated at all**:

```glsl
float texWrap( float d, float A, float invLip, float h ){
    // caller passes h = 0 and takes the outer branch when |d| > band
}

// in the generated world sdf:
float band = A + BOUND_MARGIN;
if( abs(d) > band )  return d - sign(d)*A;        // 1-Lipschitz, valid, no noise eval
return (d - A*texHeight(p, tex)) * invLip;        // the real field, only near the surface
```

Validity of the outer branch: for `d > band`, every point of `S′` has
`|p − q| ≥ d(p) − A`; for `d < −band`, `dist ≥ |d| ≥ |d + A|`. Both branches are
independently valid underestimates, so the discontinuity at the band edge is
harmless — the marcher needs monotone conservatism, not continuity.

This is the same philosophy as `bound()`: cheap conservative outer, expensive
exact inner. **The cost of texture is confined to a thin shell around the
surface**, and long approaches through empty space run at full step length with
zero noise evaluations.

### 2.6 Normals

**Macro / displaced.** The wrapping happens inside the *local* sdf sampled by
finite differences, so the displaced normal comes out exactly. The uniform
`invLip` scale factor cancels under `normalize`, so it does not perturb the
direction at all. This needs one new macro (`OBJECT_NORMAL_FD_T`) that samples
the wrapped field rather than the raw one — four extra `texHeight` evaluations,
**on hits only**, never in the march loop.

**Micro / bumped.** No parameterization exists (these are implicit surfaces), so
the tangent-space normal-map formulation is unavailable. Use the
surface-gradient form (Mikkelsen, *Bump mapping unparametrized surfaces on the
GPU*): take `∇h` by a 4-tap tetrahedron FD, project out the normal component,
subtract.

```glsl
vec3 g  = texGrad(p, tex);          // 4-tap FD of the micro band
vec3 gS = g - dot(g, n)*n;          // surface gradient
n' = normalize(n - Amicro*gS);
```

Coordinate-free, no tangent frame, works on any implicit surface — and it is
precisely the first-order normal of the displaced surface, which is what makes
the two channels consistent instead of merely coexisting.

Two guards:

- **Horizon clamp.** If `n′` rotates past the ray (`dot(n′, tv.dir)` flips
  sign) you get black speckle and, on dielectrics, garbage Fresnel and spurious
  TIR. Lerp back toward `n` until it is on the correct side.
- **`side` stays geometric.** Apply the perturbation *after* `setData`, so
  `inside()` and `dat.side` are still computed from the true sdf. Bump then
  cannot corrupt the medium handoff.

### 2.7 `bound()` expansion

Displacement inflates the object by `A`, so every bounded type must widen its
bound. This happens once, inside the generated world sdf, so no hand-written
`bound()` changes anywhere:

```glsl
float b = obj.frame.scale * (bound(local, obj) - obj.tex.amp);
```

The `-1e9` no-bound sentinel and the `uDebugMode == 9` bound-shells branch are
preserved verbatim — see [bounding-volumes.md](bounding-volumes.md).

### 2.8 Distance LOD

High-frequency displacement far from the camera is march cost for sub-pixel
gain. Amplitude may fade with distance **from the camera position**:

```glsl
float A = tex.amp * texLOD(length(p - camPos));
```

This is legal because it remains a pure function of `p` — the field is still a
well-defined SDF, just a different one per frame. **Fading with marched `t`
would not be**, and would break the overlap fallback, which assumes a
stationary field. This distinction is a trap worth remembering.

### 2.9 The ladder

Your existing `roughness` is the bottom rung of the same ladder:

| feature scale | mechanism | cost |
|---|---|---|
| sub-pixel, statistical | `surf.roughness` | free (already built) |
| resolvable, invisible in profile | micro / bump | ~free |
| visible in silhouette at your framing | macro / displace | 1.3–1.4× on that object |

The authoring test: *at the framing you intend, would you see it on the
outline?* Paper — no. Stone tooth — no. Ribbed pottery — yes. Bark — yes.

---

## Part 3 · Dispatch, and why it works the way it does

Material fields attach **by name**, in the scene list, because they are called
at the hit point in `setData_Objects` — scene code, compiled after the scene
chunk, with full path state.

Height fields cannot use the same mechanism. They are called **inside the sdf**,
which is generated at *type* level by a macro in `glsl/objects/`, compiled
**before** the scene chunk. The generated code cannot name a function the scene
has not defined yet.

So geometry fields dispatch on data, using the established scene-hook contract:

```glsl
// glsl/objects/texture.glsl — prototype only; GLSL ES 3.00 permits this
float texHeight( vec3 p, Texture t );
float texHeightLib( vec3 p, Texture t );   // the library switch on t.kind

// compiled AFTER the scene chunk, so a scene's definition wins:
#ifndef SCENE_TEX_HEIGHT
float texHeight( vec3 p, Texture t ){ return texHeightLib(p, t); }
#endif
```

A scene wanting a bespoke pattern announces it, exactly as a medium scene
announces `indexField`:

```glsl
#define SCENE_TEX_HEIGHT
float texHeight( vec3 p, Texture t ){
    if( t.kind == 100 ) return myWeirdPattern(p);
    return texHeightLib(p, t);          // library patterns still available
}
```

`t.kind` is an `int` switch, but the branch is **coherent per object** — every
ray touching that plinth takes the same arm — and each object still gets
per-instance amplitude and frequency, which is what the knobs need.

The hook family table in [material-fields.md](material-fields.md) gains a row:

| hook | kind | default | opt-in |
|---|---|---|---|
| `indexField(vec3 p)` | volume | `1.` | `#define SCENE_INDEX_FIELD` |
| `IN_MEDIUM_REGION(p)` | gate | `true` | `#define IN_MEDIUM_REGION(p) …` |
| `texHeight(vec3 p, Texture t)` | geometry | library switch on `kind` | `#define SCENE_TEX_HEIGHT` |

---

## Part 4 · API reference

### The `Texture` struct

```glsl
struct Texture{
    int   kind;     // which pattern (0 = none)
    int   mode;     // TEX_FULL | TEX_BUMP  — a CEILING, not a selector
    float amp;      // total amplitude A, world units
    float freq;     // base frequency, in the object's LOCAL chart
    float macroAmp; // displaced band amplitude   (computed by the constructor)
    float microAmp; // bumped band amplitude      (computed by the constructor)
    float invLip;   // 1/(1 + macroAmp·L)         (computed by the constructor)
};
```

`mode` is a ceiling: `TEX_BUMP` forces everything into the micro channel — the
always-safe fallback, mandatory for DE-based objects and advisable for
transmissive ones. `TEX_FULL` allows the automatic split.

`amp == 0` short-circuits every wrapper back to the untextured object. This is
the byte-identical guarantee and the left end of every amplitude knob.

### Constructors

```glsl
Texture makeStone  ( float amp, float freq );   // fbm — rock, weathered concrete
Texture makePaper  ( float amp, float freq );   // fine tooth; defaults to TEX_BUMP
Texture makeRibs   ( float amp, float freq );   // sin sheets along local x
Texture makeCrackle( float amp, float freq );   // worleyEdge — glaze, mud, bark
Texture noTexture  ();                          // kind = 0, amp = 0
```

Each computes the octave split, the per-band amplitudes and `invLip` from its
own published Lipschitz constant.

### Height access

```glsl
float texMacro ( vec3 p, Texture t );   // displaced band — sdf hot path
float texMicro ( vec3 p, Texture t );   // bumped band — hits only
float texHeight( vec3 p, Texture t );   // full field, [-1,1] — for material fields
float texHeight01( vec3 p, Texture t ); // remapped to [0,1] — for mix()
vec3  texGrad  ( vec3 p, Texture t );   // 4-tap FD of the micro band
```

### Object macros

```glsl
OBJECT_LOCATORS_T(Type)   // world sdf: bound−amp cull, band short-circuit,
                          // Lipschitz scale, mode-9 branch; at(); inside()
OBJECT_NORMAL_FD_T(Type)  // FD normal over the WRAPPED local field
OBJECT_SETDATA_T(Type)    // setData + micro-band normal perturbation
OBJECT_API_T(Type)        // = INIT + LOCATORS_T + NORMAL_FD_T + SETDATA_T
```

A type opts in by adding `Texture tex;` to its struct and switching
`OBJECT_API_B` → `OBJECT_API_T`. `initObject` sets `tex = noTexture()`.

### Scene macros

```glsl
SCENE_OBJECTS(SCENE_LIST)   // sdf_Objects, setData_Objects, inside_Object
Material noField( vec3 p, Material base );   // the identity field
```

---

## Part 5 · Authoring

### A complete scene

`src/settings.js`:

```js
export const params = [
    { name: 'plinthPos', type: 'vec3',  label: 'Plinth',  min: -5, max: 5, step: 0.01, value: [-2, 1, 0] },
    { name: 'stoneTint', type: 'color', label: 'Stone',   value: [0.72, 0.70, 0.66] },
    { name: 'relief',    label: 'Relief', min: 0, max: 0.08, step: 0.001, value: 0.035 },
    { name: 'grain',     label: 'Grain',  min: 1, max: 12,  step: 0.1,   value: 3.0 },
];
```

`src/objects.glsl`:

```glsl
Box      plinth;
Cylinder vase;

//a material field: wear on the high points, grime in the recesses.
//NOTE it reads the SAME height field that carved the geometry.
Material wornStone( vec3 p, Material base ){
    float h = texHeight01(p, plinth.tex);
    Material m = base;
    m.surf.diffuse   *= mix(0.55, 1.0, h);
    m.surf.roughness  = mix(0.60, 0.25, h);
    return m;
}

void buildObjects(){

    plinth.frame   = makeFrame(plinthPos);
    plinth.sides   = vec3(1.);
    plinth.rounded = 0.02;
    plinth.mat     = makeGloss(stoneTint, 0.05, 0.4);
    plinth.tex     = makeStone(relief, grain);

    vase.frame  = makeFrame(vec3(1.6, 1.2, 0.));
    vase.radius = 0.8;
    vase.height = 1.2;
    vase.mat    = makeGloss(vec3(0.35,0.22,0.16), 0.08, 0.3);
    vase.tex    = makeRibs(0.02, 30.);
}

#define SCENE_LIST(X)          \
    X( plinth, wornStone )     \
    X( vase,   noField   )

SCENE_OBJECTS(SCENE_LIST)
```

Everything below `buildObjects` is generated. Adding an object is one line in
one place; texturing it is one line on the object; attaching a material field is
one word in the list.

### The knob story

`buildScene()` runs inside `main`, per pixel, per frame
([traceShader.glsl:45](../glsl/tracer/traceShader.glsl#L45)), so **every uniform
read in `buildObjects` is live**. Dragging the position widget moves the plinth
with no recompile; Save-to-Scene serializes the tuned values back into
`settings.js` via `serializeKnobs`. Knobs already support
`float | int | bool | color | vec2 | vec3`
([knobs.js](../js/shaderData/knobs.js)) — no new machinery is needed for
GUI-driven placement, colour or texture parameters.

The limit: knobs drive **values**, not **structure**. Object count and which
objects exist are compile-time; use `settings.defines` for that.

### Frequency is local

`freq` is measured in the object's local chart, so it rides with `frame.scale`:
a plinth scaled 2× keeps the same apparent grain. Pin a pattern to world space
deliberately (sample `path.tv.pos` instead of `toLocal(...)`) only when several
objects should look carved from one continuous block.

### The tuning loop

Because displacement can tunnel, the check is mechanical rather than by eye:

1. Set `relief` where you like it in mode 0.
2. **Debug mode 5 (overstep).** Red speckle on the textured object means the
   Lipschitz bound is too loose for the chosen frequency. The fix is lowering
   `freq`, *not* lowering the published `L`.
3. **Debug mode 2 (cost).** The textured object should brighten by roughly
   `1/invLip`, confined to that object. If the whole frame brightens, the band
   short-circuit is not firing.
4. If step 2 red-flags at an amplitude you actually want, switch that object to
   `TEX_BUMP` and accept the flat silhouette.

Same shape as the `MARCH_RELAX` A/B in [marching.md](marching.md): mode 5 is the
safety gate, mode 2 is the price tag.

---

## Part 6 · Which objects may be textured

| family | macro (displace) | micro (bump) | why |
|---|---|---|---|
| `basic/`, `shapes/`, gallery — exact SDFs | ✅ | ✅ | exact distance; Lipschitz argument holds |
| varieties, fractals — DE fields | ❌ | ✅ | already conservative underestimates of unknown tightness; stacking a second error budget is not sound |
| transmissive / glass | ⚠️ | ❌ | refracting through a fabricated normal is not reciprocal; use `surf.roughness`, or real displacement |
| infinite / tiled (planes, honeycombs) | ⚠️ | ✅ | no `bound()`; displacement is legal but the band short-circuit is the only cost control |

Analytic-`trace` objects are out of scope by design: **a textured object is a
marched object.** Displacement has no closed-form intersection, so a type that
wants the macro channel must present a real sdf.

---

## Part 7 · Escape hatches

The abstraction must never become mandatory — the scenes that make this project
interesting are the ones it cannot express.

- **A scene needing custom `setData` logic** (varieties-in-shells, liquids,
  multi-material interfaces, `setMaterialInterface` work) simply does not call
  `SCENE_OBJECTS` and hand-writes the three functions, exactly as today. The two
  styles coexist file by file; nothing is migrated by force.
- **A scene needing a bespoke height pattern** uses the `SCENE_TEX_HEIGHT` hook
  with its own `kind` id, and can still fall through to `texHeightLib`.
- **A scene needing bespoke mathematics** — Kleinian iteration, dual-number
  autodiff, ODE media, hyperbolic honeycombs — writes GLSL, as it should. None
  of this touches that code.

This is the deciding argument against a fuller scene DSL or GLSL compiler: the
hard and valuable part of this library is bespoke mathematics, and an
abstraction whose sweet spot is "sphere with marble" would handle none of it.
The failure mode of such a system is not that it doesn't work — it is that the
escape hatch becomes the main road and you maintain both. Macros keep the
generator in the language, with no build step and generated code you can read by
dumping the preprocessed shader.

---

## Part 8 · Implementation plan

Behaviour-frozen, staged, each with a gate. Render-test byte-compare needs
`--budget 60000` on a quiet machine.

**Stage 0 · Spike + this doc.**
Confirm the GLSL ES preprocessor accepts a macro passed as a macro argument. If
not, switch Part 1 to the numbered `SCENE_OBJECTS_N` form; nothing downstream
changes. *Gate: a trivial two-object scene compiles and renders.*

**Stage 1 · `SCENE_OBJECTS` + `noField`.**
Macros only, no texture. Migrate three existing scenes of increasing complexity.
*Gate: those three render byte-identical to their current output.*

**Stage 2 · Height library.**
`glsl/objects/texture.glsl` — `Texture`, the constructors, `texHeightLib` and
its `kind` switch, `texMacro` / `texMicro` / `texHeight` / `texHeight01` /
`texGrad`, the `texHeight` prototype, and the `#ifndef SCENE_TEX_HEIGHT` default
placed after the scene chunk. Reuses `fbm` / `worleyEdge` / `valueNoise` from
[fields.glsl](../glsl/tracer/3Materials/fields.glsl) — `3Materials` compiles
before `objects/`, so no noise code is duplicated. No object edits.
*Gate: full render-test pass byte-identical.*

**Stage 3 · Micro channel (bump).**
`OBJECT_SETDATA_T` on `Box` and `Cylinder`; `applyNormal` beside
`applyMaterial` in [interaction.glsl](../glsl/tracer/3Materials/interaction.glsl);
horizon clamp; `side` preserved. Demo page sweeping micro amplitude.
*Gate: `tex.amp = 0` reproduces the untextured object exactly; untextured scenes
still byte-identical.*

**Stage 4 · Macro channel (displace).**
`OBJECT_LOCATORS_T` and `OBJECT_NORMAL_FD_T` — band short-circuit, Lipschitz
scale, `bound` expansion, mode-9 preservation, distance LOD. Measure `L₁`
empirically and bake it with a safety factor.
*Gate: debug mode 5 clean across the full authored amplitude range on the pilot
objects; mode 2 shows the cost rise confined to the textured object and within
~1.4×.*

**Stage 5 · The octave split.**
Wire `macroAmp` / `microAmp` so one `makeStone` drives both channels, crossover
at `TEX_FLOOR`.
*Gate: visual A/B against stage-4 full-spectrum displacement at equal `A` — must
look the same or better, and measurably cheaper on mode 2.*

**Stage 6 · Rollout.**
`OBJECT_API_T` across `basic/` and `shapes/`; varieties and fractals restricted
to `TEX_BUMP`. A catalog demo, an amplitude/frequency sweep page, and one real
art piece chosen to exercise **contact** and **raking light** — the two things
the bump channel cannot fake.

Stages 3 and 4 are independent given stage 2, so the bump channel ships and is
usable while displacement is still being validated. If stage 4's gate fails at
the amplitudes you want, the feature is still complete and useful and stage 5
simply does not happen.

---

## Part 9 · Gotchas

- **GLSL ES has no ternary on struct types.** Use `if`/`else` when selecting
  between `Material` or `Texture` values. Already bitten `applyMaterial`.
- **`T` is `#define`d to `vec2`** by the dual-number machinery — never name a
  local `T`.
- **Never write fields through an `inout` nested struct member** on an
  uninitialized local; build with constructor literals. Documented in
  [material.glsl](../glsl/tracer/3Materials/material.glsl) — some drivers leave
  garbage.
- **`#define X` / `#undef X` inside a function body** is legal (preprocessor
  directives are line-oriented and position-independent), but keep the `#undef`
  adjacent so two generated functions can't collide.
- **The band short-circuit must not evaluate the noise.** Use `if`/`else`, not a
  ternary, so laziness is unambiguous — a `texHeight` call in an unselected
  ternary arm is exactly the cost this design exists to avoid.
- **Distance LOD may depend on the camera position, never on marched `t`.**
  See §2.8.
- **`AT_THRESH` was raised to 0.003 for a reason** (it must contain the
  marcher's landings). If `TEX_FLOOR` is ever retuned, retune it *against*
  `AT_THRESH`, not independently.
- **Baselines.** `render-tests/baseline/` is already stale for ~21 subsurface
  scenes pending the SSS meanFreePath re-tune. Do not conflate that with a
  texture regression when reading stage gates.
