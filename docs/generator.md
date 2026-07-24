# The scene generator

*Working notes. The GLSL contract below is **settled** — it is what the seven
hand-written scenes in `scenes/` actually compile and run. The JS schema at the
end is **not settled**; it is the next thing to design.*

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
Material material_<name>(vec3 p, inout Vector n);        //always
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

Things the generator should compute rather than have an author guess:

- **Lipschitz divisors.** A displacement makes the sum non-1-Lipschitz and the
  over-relaxed marcher steps through it. `fbm` is 4 octaves whose amplitude
  halves as frequency doubles, so every octave contributes the same gradient:
  `|grad fbm(f·p)| ≤ 3.26·f`, `|grad fbm2(f·p)| ≤ 2.01·f`. The divisor is
  `1 + L·amp·freq`. Getting this wrong is not "a bit slow" — under-estimating
  lets the marcher miss the surface.
- **Bound inflation.** A displaced object's bound must grow by the displacement
  amplitude, or the bound shaves off the very detail it encloses.
- **Trace/march routing.** A displaced object has no closed form, so it loses
  `trace_` and moves into `sdf_Scene`.
- **`AT_THRESH`** could be derived from `EPSILON·(2 + MARCH_CONE·maxDist)` rather
  than being a hand-tuned constant that happens to fit.

---

## 4 · The spec: seven scenes

The generator's job is *reproduce these*. Each pins down something different.

| scene | pins down |
|---|---|
| `glassball` | the floor: analytic everything, `sdf_Scene` returns `maxDist`, nothing marches |
| `cocktail` | one shape → two regions; a shared wall; a group bound; a library include |
| `proto` | several objects at once; marched + analytic mixed; material as a field |
| `rock` | displacement inside the sdf; one height field driving geometry **and** colour; Lipschitz divisor; bound inflation |
| `subsurface` | the medium walk; nested regions; a non-air/non-air interface; `insideOf`; `SCENE_SUBSURFACE` |
| `transform` | rotation + non-uniform scale with no normal fixup; a lattice as one region |
| `sheet` | `isSheet`; front/back Surfaces; index-matched crossing; the image sky |

---

## 5 · OPEN — the JS schema

**Not designed.** The early sketch (`region().shape().medium()`) predates regions
vs sheets, `isSheet`, `insideOf`, shape-major `sdfAll`, group bounds and the
capability flags, so it covers none of them.

The next step is to write the JS for `cocktail` by hand and check it emits
exactly the GLSL that is in `scenes/cocktail/src/scene.glsl` — that will expose
the gaps in an afternoon rather than after an emitter exists. Then the other six.

Things the schema must express, from §2–3:

- an object's shape tree, and shapes that yield **several** regions
- declaration order as containment priority
- sheet vs region
- optional `bound` and `trace`, which name hand-written library functions
- knobs declared at their point of use, feeding both GLSL uniforms and the GUI
- raw GLSL escape hatches for one-offs

---

## 6 · OPEN — gaps in the spec

The seven scenes exclude patterns that dominate `legacy/`. Designing the schema
against them alone risks a schema that cannot express a quarter of the library.

- **Varieties** — 14 of 52 legacy scenes. A dual-number gradient evaluator plus a
  distance estimate; the old `VARIETY_DATA` macro must become generated code.
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
