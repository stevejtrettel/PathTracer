# Bounding-volume acceleration: uniform system + rollout plan

## Goal

Every *finite* object whose real sdf is meaningfully more expensive than a cheap
bounding shape should trace that bounding shape first, and only evaluate the real
sdf once a ray is close. Far-away objects then cost one cheap test per march step.

Today this exists but is applied to only 8 of ~90 object types, and three
competing idioms are used inconsistently. This plan picks **one** mechanism and
applies it by **one** rule across the whole library. No geometry changes — pure
acceleration. Behaviour is frozen; renders must match baselines.

---

## The system

### One concept

An object type may hand-write a **bound**: a cheap, conservative *underestimate*
of its own local sdf (never larger than the true distance, so a ray is never told
to step past a real surface). The generated world sdf traces the bound until the
ray is within `BOUND_MARGIN`, then switches to the real sdf.

This replaces, and unifies, all three current idioms:
- the existing `bound()` sphere-radius opt-in (8 types),
- the hand-rolled `if(length(p) > R) return length(p) - R';` culls baked inside
  local sdfs (menger, bunny, trefoil, kleinBottle, polytope4D),
- and the "no bound at all" default (everything else).

### One signature (decided)

Generalize `bound()` from *a sphere radius* to *a bound sdf*:

```glsl
float bound( vec3 p, Type obj )   // cheap conservative sdf, local coords
```

- A **sphere** bound is `length(p) - R`.
- A **box** bound is `bBox(p, halfwidths)`.
- A **cylinder** bound is `bCyl(p, vec2(radius, halfheight))`.

One mechanism covers all bound shapes, and elongated objects (plateLines, Cables,
Cybertruck, Castle) get a tight box instead of a loose sphere with no second
mechanism to add later.

### API change (objectAPI.glsl)

`OBJECT_LOCATORS_B` changes from the hard-coded sphere:

```glsl
// BEFORE
float b = obj.frame.scale * (length(local) - bound(obj));
if( b > BOUND_MARGIN ) return b;
return obj.frame.scale * sdf( local, obj );

// AFTER
float b = obj.frame.scale * bound( local, obj );
if( b > BOUND_MARGIN ) return b;
return obj.frame.scale * sdf( local, obj );
```

The default `OBJECT_LOCATORS` still injects a no-op bound, now as an sdf:

```glsl
float bound( vec3 p, Type obj ){ return -1.0; }   // always "inside" → never skips
OBJECT_LOCATORS_B(Type)
```

(Returning a negative constant means `b` is always `<= BOUND_MARGIN`, so the real
sdf always runs — identical to today's 10000 default, but in sdf form.)

`OBJECT_API`, `OBJECT_API_B` unchanged in spelling; only the bound signature moves.

### One opt-in rule (documented in the objectAPI header)

- **Finite** object **and** real sdf clearly costlier than the bound → give it a
  `bound()` and use the `_B` macros. (All fractals, gallery models, varieties,
  cubics, hyperbolic solids, glassware.)
- **Cheap** primitive (sphere-ish sdf: torus, cone, boxFrame, the polyhedra) →
  stay on the plain macro; a bound test would cost as much as the sdf.
- **Infinite / tiled** (plane, honeycombs, kleinianEscape/Seahorse) → no bound.
  Correct as-is.
- **Analytic trace** (sphere, roomBox) → no bound; never marched.

### Clip stays separate

`max(dist, bBox(...))` / `smax(...)` *inside* a local sdf **defines geometry**
(varieties clipped to a region, cubicSurface, gasket). That is a different concern
from the bound and stays exactly where it is. The `bBox`/`bCyl` helpers keep their
names but get a one-line comment noting their two roles (clip shape vs. bound
shape). A type can both clip its geometry with `bBox` *and* bound itself with a
matching `bBox` — the varieties already do exactly this.

---

## Migration reference (from the full 109-file sweep)

Legend: **bound()** = sphere accel via `_B`; **cull** = hand-rolled early-out
inside sdf; **clip** = geometry `max`/`smax` (not accel); **none** = no accel.

### Already correct — only touched by the signature change (Stage A)
`basic/box`, `shapes/cubicSurface`, `varieties/{varBox,varCyl,varSphere,surfBox,surfCyl,surfSphere}`.
Their `float bound(Type)` becomes `float bound(vec3 p, Type)` returning the
matching sphere/box/cyl sdf instead of a radius.

### Correctly unbounded — leave alone
`basic/plane` (custom sdf+trace, dir cull), `basic/sphere` (analytic trace),
`environments/roomBox` (analytic trace), `fractals/{hyperbolicHoneycomb,
hyperbolicHoneycomb2,kleinianEscape,kleinianSeahorse}` (infinite/tiled).

### Cheap primitives — leave on plain macro
`basic/{torus,cone,doubleCone,boxFrame,tetrahedron,octahedron,dodecahedron,
icosahedron,triangle}`, `sdf_gallery/basicGeometry/*` (19 single primitives).

### Clip-but-no-bound — add bound(), switch to `_B` (Stage B)
These already clip to a finite region but use the default macro. The bound is
derivable from the clip region they already carry.

| File | Struct(s) | Clip region → bound |
|---|---|---|
| `varieties/variety` | Variety | `var_bBox(p)` — reuse as the bound directly |
| `varieties/surface` | Surface | `surface_bBox(p)` — reuse as the bound |
| `shapes/cubicLines` | PairLines, ConicLines, ExceptionalLines | `sceneBBox(p)` |
| `shapes/plateLines` | PlateLines | `plateBBox(p)` |
| `shapes/planarConics` | PlanarConics | `plateBBox(p)` |

Note: `variety`/`surface` take the clip sdf as a *provided function*
(`var_bBox`/`surface_bBox`), so `bound(p, obj)` just forwards to it — a genuinely
tight bound for free. The cubic-line family clips to `sceneBBox`/`plateBBox`,
likewise reusable verbatim. `cubicLines`/`plateLines`/`planarConics` provide a
`sdf_cached` fast path over `_cached*` globals — orthogonal to bounding, untouched.

### Expensive + finite + no accel — add new bound() (Stage D)
| File | Struct | Suggested bound |
|---|---|---|
| `shapes/hypDod` | HypDod | sphere/box enclosing the solid (measure) |
| `shapes/hypCoxCube` | HypCoxCube | sphere/box (measure) |
| `fractals/apollonian` | Apollonian | sphere ~ inversion radius (weak gain) |
| `shapes/{bottle,bottleTorus,cocktailGlass,pint}` | resp. | cyl/box from profile extent |
| `multiMaterial/{beer,cocktail,bottleLiquid,bottleTorusClearcoat,poincareMarble,mobius}` | resp. | custom `sdf(Vector)` — open with the 3-line bound pattern by hand |

`multiMaterial/{varBox,varSphere}×{Glass,Clearcoat}` inherit the inner variety's
bound through `VARIETY_IN_SHELL_API`; no change needed unless we want a top-level
bound too.

### Gallery — one wrapper, 27 expensive models (Stage C, biggest win)
`sdf_gallery/object.glsl` includes exactly one `sdfs/*.glsl`, each providing a
one-arg `float sdf(vec3 p)`. Plan: each vendored file also defines
`float bound(vec3 p)` (conservative box/sphere for that model), and `object.glsl`
forwards `bound(vec3 p, Object)` to it and switches to `OBJECT_API_B`. Because only
one gallery sdf compiles at a time, this accelerates all 27 with one wrapper edit +
one bound per file. `basicGeometry/*` are cheap → give them a trivial
`bound(){ return -1.; }` or a separate cheap wrapper so the switch is uniform.

### Hand-rolled culls — migrate onto bound() (Stage E, only behaviour-touching step)
| File | Current in-sdf cull | Becomes bound() |
|---|---|---|
| `fractals/menger` | `if(length(p)>2.) return length(p)-1.9;` | `bound = length(p)-1.9` |
| `shapes/bunny` | `if(length(p)>1.) return length(p)-.8;` | `bound = length(p)-.8` |
| `shapes/trefoil` | `if(length(p)>2.) return length(p)-1.9;` | `bound = length(p)-1.9` |
| `shapes/kleinBottle` | `if(length(p)>6.) return length(p)-5.9;` | `bound = length(p)-5.9` |
| `polytopes/polytope4D` | `if(length(pos)>2.5) return length(pos)-2.4;` | `bound = length(pos)-2.4` |

The sdf loses its opening `if`; the math moves into `bound()` verbatim. Net effect
is near-identical, and arguably a bug fix: the world wrapper applies `frame.scale`
and `BOUND_MARGIN` correctly, which the in-sdf culls currently ignore. This is the
one step that changes a working path, so it renders-tests on its own.

`fractals/{apollonianGasket,breathe,kleinianSpiral}` use an in-sdf *clip* (geometry
`max`), not a cull — those stay; optionally also given a `bound()` for accel.

---

## Rollout (behaviour-frozen, render-test between stages)

Baseline shots first: the affected scenes are already enumerated
(`render-tests/baseline/`). After each stage, re-render the same set and diff.

- **Stage A — API change + migrate the 8.** `objectAPI.glsl` signature; convert
  `box`, `cubicSurface`, six varieties from radius to bound-sdf. No visual change.
- **Stage B — clip family opt-in.** `variety`, `surface`, cubicLines×3,
  plateLines, planarConics. Reuse existing clip sdf as the bound. No visual change.
- **Stage C — gallery.** Wrapper + 27 bounds (+ basicGeometry uniformity). Verify
  a representative sample of gallery models render identically.
- **Stage D — new bounds.** hypDod, hypCoxCube, apollonian, bottles, glasses,
  custom multiMaterial. Conservative-large bounds first; tighten only if a render
  clips.
- **Stage E — cull migration.** menger, bunny, trefoil, kleinBottle, polytope4D.
  The only step touching working behaviour; render-test each individually.
- **Docs.** objectAPI header (the opt-in rule + new signature), `bBox`/`bCyl`
  clip-vs-bound comment in computations.glsl, objects `readme.md`.

## Risk / correctness notes

- Bound must be a *conservative underestimate*. A too-tight bound clips the object
  (visible hole); a too-loose bound just costs a little speed. When unsure, err
  large.
- `BOUND_MARGIN` (0.05) already keeps the bound surface itself out of the hit band;
  no per-object tuning needed.
- `frame.scale` is applied once in the wrapper; bounds are authored in local units
  like sdfs, so nothing per-file needs to know about scale.
- The gallery's single-type constraint (only one sdf compiles at a time) means the
  wrapper's `bound(vec3, Object)` can call the freestanding `bound(vec3)` with no
  name collision, mirroring how `sdf(vec3, Object)` already calls `sdf(vec3)`.
- No consumers of `bound()` exist outside `glsl/objects/` (verified), so the
  signature change is fully contained.
