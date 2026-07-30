# The shape library

*DESIGN + MIGRATION PLAN (July 2026, branch `scene-builder`). **Stages 1–5 are
executed** (5 partially, by decision); 6–8 remain (§5). `glsl/shapes/` is the library the scene generator
draws from; `glsl/objects/` is the pre-generator library, now an archive. This
file says what the finished library looks like, and stages the move. Authoring
how-to: [scene-authoring.md](scene-authoring.md) §3; the emitter contract:
[generator.md](generator.md) §2.7.*

---

## 1 · Two layers, one rule

The library splits on a line that is already there in the code, but was never
named:

- **Vocabulary** — the operators (`opSmoothUnion`, `opRepLim`, `opCarveFbm`) and
  the handful of primitives used *all the time*: `box`, `cylinder`, `cone`,
  `torus` (called by the library's own content files, so they must always be
  available), plus `sphere` and `plane` (in nearly every scene — sphere is in 18
  of 33).
- **Content** — a named thing you put in a scene: a gem, a Kleinian limit set, a
  hyperbolic honeycomb, a variety. **And the occasional primitives**: the
  platonic solids, `boxFrame`, `capsule`, `ellipsoid`, `doubleCone`, `triangle`.
  A dodecahedron is a primitive by taxonomy, but nothing composes one and no
  scene has yet wanted one, so every shader should not pay for it.

Those are **two different axes**, and conflating them was an early mistake here.
The FOLDER says what the math is; the vocabulary list says whether every shader
compiles it. So `primitives/` legitimately holds both.

**Content uses vocabulary. Content never uses content.** That is not an
aspiration — it is a measured fact about the library as it stands. A scan of
every file in `glsl/shapes/` for references to names defined in any *other*
file there returns **zero cross-file dependencies**. Every edge points out of
the library into the always-compiled layer.

So the rule is:

> **The vocabulary is always compiled. Content is included when a scene names it.**

That is the entire dependency contract, and it needs no mechanism: no `uses`
annotation, no import statement, no reference scanner, no topological sort. An
author writes a file and calls any primitive or operator, exactly as today.

This was reached by elimination. A `//@uses <stem>` annotation was designed and
rejected — it restates a dependency the call already expresses, so it can go
stale, and it would need a validator to police it. Deriving the include set by
scanning for referenced-but-undefined identifiers was designed and also
rejected — it is a real mechanism (index, transitive walk, cycle detection,
over-inclusion) built for a graph with no edges. Both were solving a problem
that only exists if the vocabulary is on-demand.

**If a content file ever genuinely needs another content file, promote the
shared math into the vocabulary.** That is the escape hatch, and it is a good
forcing function: it is exactly the moment you want to notice that two models
share geometry.

---

## 2 · The tree

```
glsl/shapes/
  _vocabulary.glsl        THE DEFINITION of what is always compiled: its
                          #include list is what setupShader compiles AND what
                          the catalogue reads to decide what not to inline, so
                          the two cannot drift. Out of the list is the default.

  primitives/     catalogue · MIXED   exact closed forms
                  always compiled:  box sphere plane cylinder cone torus
                  on demand:        triangle capsule ellipsoid boxFrame
                                    doubleCone tetrahedron octahedron
                                    dodecahedron icosahedron

  ops/            ALWAYS COMPILED · not catalogue   the operators
                  smooth.glsl   opSmoothUnion / Intersect / Subtract
                  fold.glsl     opSym* opRep opRepLim opRadial* opElongate
                  carve.glsl    opCarveFbm opAccreteFbm (+ private opCarveCell)

  ──────────────────────────────────────────────────────────────────────
  models/         on demand    gem bottle bottleTorus cocktailGlass pint
                               trefoil kleinBottle bunny hypDod hypCoxCube
  fractals/       on demand    apollonian kleinian menger breathe
                               apollonianGasket        (kleinianSpiral deferred)
  tilings/        on demand    hyperbolicHoneycomb cubeGrid
                                                (hyperbolicHoneycomb2 deferred)
  environments/   on demand    room checkers
  varieties/      on demand    the formula catalogue (unchanged)
  vendor/         on demand    the 27 NVIDIA/shadertoy models (§7)
```

Buckets are by **what the math is**, not by vibe: `primitives/` = exact closed
forms; `fractals/` = escape-time estimators (a DE, a fudge factor, orbit
traps); `tilings/` = periodic or infinite structures; `models/` = hand-authored
named objects; `environments/` = the ones whose solid is the *outside* (the
room) or which are unbounded ground.

Stems stay globally unique, so a scene still writes `lib.torus` — **folders are
organisation only, never part of a name.** Duplicate basenames are a loud load
error.

`ops/` is deliberately **not in the catalogue**: an operator is not a shape, has
no `<stem>Distance`, and can never appear as `lib.<x>`. The catalogue skips the
folder wholesale, the way it already skips `varieties/`. This is cleaner than
tagging every ops file `//@noshape`.

---

## 3 · One naming scheme

Five schemes exist today (`bBox`, `sdTorus`, `cylinderDistance`, `opMinDist`,
`sdgBox`). One survives:

| form | is | where |
|---|---|---|
| `<stem>Distance(vec3 p, …)` | the shape, `p` local | any catalogue file |
| `<stem>Bound` / `<stem>Trace` / `<stem><Name>Data` | optional catalogue surface | as [generator.md](generator.md) §2.7 |
| `op<Verb>(…)` | an operator | `ops/` only |
| `<stem>_helper(…)` | file-private | any file |

`sd*`, `b*`, `*Dist` and `*Vec` are all retired. Concretely:

| today | becomes |
|---|---|
| `bBox(p, h)` | `boxDistance(p, h)` — same formula, `bBox` *was* the exact box sdf |
| `bCyl(p, vec2(r,h))` | `cylinderSlab(p, r, h)` — **not** `cylinderDistance` (see below) |
| `sdTorus(p, ra, rb)` | `torusDistance(p, ra, rb)` |
| `sdCappedCone(p, h, r1, r2)` | `coneDistance(p, h, r1, r2)` |
| `cylinderDistance` (in computations) | `primitives/cylinder.glsl`, same name |
| `opMinDist` / `opMaxDist` | `opSmoothUnion` / `opSmoothIntersect` |
| `opSubtractDist` | `opSmoothSubtract` |
| `sdgBox`, `opMinVec`, `opMaxVec`, `opOnionVec`, `opSubtractVec`, `opRevolutionOutputNormal` | **deleted** (§4) |

There is then exactly **one** box SDF in the codebase, and it is both the
vocabulary function and the `lib.box` catalogue entry — the duplication that
made `bBox` and `boxDistance` coexist is structurally gone.

**`bCyl` is not a duplicate of the cylinder, and must not be folded into it.**
It returns `max(radial, axial)`, which is exact *inside* but an
UNDERESTIMATE outside the rim; `cylinderDistance` is the exact rounded capped
cylinder. Both are conservative, so both are legal bounds — but they return
different numbers, and every current caller uses `bCyl` in a `<stem>Bound`.
Folding them would silently retune every bound in the library. So
`primitives/cylinder.glsl` carries an honest pair: `cylinderDistance` (exact,
the `lib.cylinder` entry) and `cylinderSlab` (the cheap max-form, for bounds).
Two functions because they are two functions — not accretion.

---

## 4 · What dissolves: `computations.glsl`

The file is 373 lines and the last live thing under `glsl/objects/`. Audited
against every reference in `glsl/`, `js/` and `scenes/`:

| | n | disposition |
|---|---|---|
| **Dead surface from a deleted engine** | 6 | `opMinVec`, `opMaxVec`, `opOnionVec`, `opSubtractVec`, `opRevolutionOutputNormal`, `sdgBox` — the analytic **normal-blending** family, obsolete since the 4-tap normal. **Zero callers, including in `legacy/`.** Delete |
| **Unused but legitimate surface** | 6 | `opRevolution`, `opTwist`, `opExtrusion`, `opRound`, `opRep`, `opElongate`. Keep (house rule: never delete unused library surface) — but `opTwist`'s hardcoded `k = 50.0` becomes a parameter |
| **Live operators** | 14 | → `ops/`, renamed per §3 |
| **Primitives in disguise** | 5 | `bBox`, `bCyl`, `cylinderDistance`, `sdCappedCone`, `sdTorus` → `primitives/` |

The `*Vec` family is worth calling out against the house rule. It is not
*unused surface* — it is surface for **an engine that no longer exists**.
Analytic normal blending was replaced wholesale by the 4-tap, and nothing has
called these since, not even the archive.

Two further faults the split fixes: `smin(a,b,k)`
([math.glsl:15](../glsl/tracer/1Setup/math.glsl#L15), polynomial) and
`opMinDist(a,b,k)` (quadratic) are **two different smooth mins, both live** —
`ops/smooth.glsl` becomes the single home, and the engine keeps `smin`/`smax`
for its own use. And `bBox` vs `boxDistance` is one function written twice.

**The layering, stated once:** `glsl/tracer/` is the engine — always compiled,
owns `smin`/`smax`/`rot2`/`fieldHash`/noise. `glsl/shapes/` is the library.
Library may call engine; engine never calls library.

---

## 5 · The stages

Each stage is behavior-frozen and independently verifiable. Renders must not
change; where the emitted text changes, the goldens are re-baked deliberately
and the diff is the review.

**Verification vocabulary**, per stage:

```
npm run gen -- --catalogue          what the parser believes
npm run gen -- --goldens            byte-compare every scene's chunk
npm run gen -- --goldens --write    re-bake, after eyeballing the diff
node scripts/render-test.mjs --budget 60000 <scene>...   pixels (quiet machine)
```

### Stage 1 · Subfolders

Catalogue glob goes recursive (`glsl/shapes/**/*.glsl`, minus `ops/` and
`varieties/`); add the duplicate-basename error; move the existing 15 files
into `models/`, `fractals/`, `tilings/`, `environments/`, `primitives/`.

Nothing else changes. Goldens shift **only** in the
`//--- library: glsl/shapes/<path> ---` banner lines — a comment-only diff, and
a good first proof that the glob change is inert.

### Stage 2 · The vocabulary layer

The big one. `computations.glsl` dissolves:

1. `ops/{smooth,fold,carve}.glsl` and `primitives/*.glsl` written, names per §3.
2. `_vocabulary.glsl` aggregates them; [setupShader.glsl:15](../glsl/tracer/setupShader.glsl#L15)
   includes it instead of `computations.glsl`.
3. **One emitter change**: a catalogue entry under `primitives/` is already
   compiled, so the include loop must not inline it again (duplicate
   definitions = compile error). One boolean derived from the folder path,
   in the include loop at [emitter.js:460](../js/scenegen/emitter.js#L460).
4. Call sites updated — 4 shape files (`bottle`, `bottleTorus`, `cocktailGlass`,
   `pint`, plus `box`/`room`/`cubeGrid` on `bBox`) and **exactly 3 scenes**:
   [proto](../scenes/proto/src/scene.js#L38) (×3),
   [transform](../scenes/transform/src/scene.js#L50) (×1).
5. `combinators.js` updated for the operator renames.

Goldens change substantively (renamed calls inside inlined library text).
Re-bake, then render-test the affected scenes byte-for-byte: `proto`,
`transform`, `bottle`, `bottleTorus`, `cocktail`, `negroniForOne`, `beer`,
`glassball`, `cubeGrid`, plus one room scene.

### Stage 3 · Primitives completed

The 12 remaining from `objects/basic/`: torus, cylinder, capsule, cone,
doubleCone, ellipsoid, boxFrame, gdf, tetrahedron, octahedron, dodecahedron,
icosahedron. Mechanical (§6), with two real edits:

- **The platonics are a rewrite, not a port.** `gdf.glsl` is macro machinery
  (`#define fGDFBegin`, `GDFVector13`…) — hostile to "plain functions of a point
  and floats". Rewrite as an explicit `max` over face normals, one plain
  function per solid.
- **They gain a `size` parameter.** `dodecahedron` currently hardcodes
  `scale = 0.7`, `r = 1.0` and takes nothing.

Additive: no existing scene changes, goldens unchanged. `--catalogue` gains 12
entries.

### Stage 4 · Models — DONE

`bunny`, `trefoil`, `kleinBottle`, `hypDod`, `hypCoxCube`. `bunny`'s **domain
guard** (`if(length(p) > 1.) return size*(length(p)-.8);`) stays inline in the
Distance — it is *not* a bound: the sdf is invalid outside the ball, so a
`<stem>Bound` early-out would still let it paint garbage inside the margin band.

**`line.glsl` moved to Stage 6.** It is not a shape — it is a `Line` struct plus
`lineDist`/`lineNormal`, and its only consumers are the cubic family
(`cubicSurface`, `cubicLines`, `plateLines`). Porting it before them would mean
guessing an interface with no callers to check it against.

### Stage 5 · Fractals — DONE (partial, by decision)

`menger`, `breathe`, `apollonianGasket`. **`hyperbolicHoneycomb2` and
`kleinianSpiral` are deliberately deferred** — to be looked at later, together
with the question of whether the spiral is a distinct estimator or another box of
the existing `kleinian`.

`apollonianGasket` is a genuinely different estimator from `apollonian`, not a
preset of it: fract-fold with a shifting offset versus round-fold with an
inversion-radius morph. Two folds, two fractals, two files.

⚠ **`apollonianGasket` is flagged unresolved in its own header.** The port is
faithful, but the estimator is degenerate at default marcher settings: its
fractal term is never negative (no interior) and its median value inside the unit
ball is ~3e-5, below epsilon, because `scale` diverges over ten iterations. So a
ray reads the whole ball as a wall and it renders as a smooth sphere. That is the
"thin haze read as a solid wall" fractal-DE failure; the fix is a scene-level
EPSILON override and is by-eye work, not a mechanical port.

`breathe` lost four helpers to the engine — `br_pR`, `br_smin`, `br_smax` were
verified bit-identical to `rot2`, `smin`, `smax`, and `br_vmax` was dead. It has
**no bound**, deliberately: the ellipsoid in its estimator is a void SUBTRACTED
from the middle, not a clip containing the form, so a bound derived from it
excluded the shape and rendered it invisible. The outer extent comes from the IFS
escape and would have to be measured before it could be asserted.

### Stage 6 · The cubic family

`checkers`. **Its own design pass, not a port** — six coupled, data-driven
files feeding one polynomial and gradient to five objects with hierarchical
bounds, overlapping the variety builder and the equation transpiler. Do it
after the variety work has settled, against the four `legacy/cubic*` scenes.

### Stage 7 · The vendor decision

`objects/sdf_gallery/` is NVIDIA's `sdf-explorer` corpus, dropped in whole. It
is not a category — "gallery" names a provenance, not a kind of math:

- `basicGeometry/` (19 files) — Sphere, Cube, Torus, Cone… duplicates of our
  own primitives, each ~40 lines of licence header around a 3-line IQ function.
  **Delete outright**, whatever is decided about the rest.
- `sdfs/` (27 files, 55–400 lines) — real models: Teapot, Elephant, Mech,
  HumanSkull, Cybertruck, Temple, Jellyfish, UprightPiano.

**DECIDED (July 29 2026): the 27 stay, in `vendor/`.** The question was
licensing, not taxonomy — most carry CC BY-NC-SA-3.0 (Teapot, Cheese, Castle,
Rooks…), a few MIT, so they live in their own folder where the condition is
structurally visible and never mixed into `models/`. Each file keeps its
licence header verbatim. Per file the port is mechanical — `float sdf(vec3 p)` →
`<stem>Distance`, prefix the private helpers, `GALLERY_BOUND` → a real
`<stem>Bound` — and the old "only one can compile at a time" constraint
evaporates, since the emitter inlines only what a scene names.

### Stage 8 · Delete `glsl/objects/`

Once nothing references it. `legacy/` is already excluded from vite,
render-test and gen-pages and does not compile, so the archive costs nothing to
drop — git history keeps it. `objectAPI.glsl` and the `OBJECT_*` macros go with
it. `multiMaterial/` never migrates: those are scene `group()` nodes now, and
five already have migrated scenes.

Not in scope, deliberately: `polytopes/` (4D projection — a design question,
not a port) and the `var*`/`surf*` variety wrappers (superseded by the variety
builder).

---

## 6 · Adding a shape (the recipe)

The payoff. To add a library shape, write one file:

```glsl
//----------------------------------------------------------------------------
// WIDGET — what it is, what the parameters mean, and any math worth knowing.
//----------------------------------------------------------------------------

//file-private helpers carry the stem
float widget_lobe(vec3 q, float k){ … }

// p is in the widget's own coordinates (origin at …)
float widgetDistance(vec3 p, float size, float twist){
    return opSmoothUnion(widget_lobe(p, twist), cylinderDistance(p, size, 1.0, 0.05), 0.1);
}

//optional: a conservative bounding sdf; params must be a subset of Distance's
float widgetBound(vec3 p, float size){ return length(p) - 1.4*size; }
```

Drop it in the folder that matches what it is. That is the whole procedure —
`lib.widget({size, twist})` now exists, typos throw with the real parameter
names, and any primitive or operator is callable with no declaration.

Porting one legacy object is the same, plus: delete the `struct`, delete
`OBJECT_API*`, `sdf(vec3 p, Type obj)` → `<stem>Distance(vec3 p, …floats)`
with the struct fields becoming parameters, `bound(vec3 p, Type)` →
`<stem>Bound`, prefix the private helpers, and write the header comment
explaining the math (the ports so far are the standard —
[gem.glsl](../glsl/shapes/gem.glsl), [cubeGrid.glsl](../glsl/shapes/cubeGrid.glsl)).

Demos come later, as their own pass: every shape earns a scene so it is
render-tested rather than orphaned (the ROADMAP already flags `menger`,
`trefoil` and `hypDod` as library surface no scene exercises).

---

## 7 · Open

1. ~~Do the 27 vendored models stay?~~ **Yes, in `vendor/`** (decided, Stage 7).
2. **Is the taxonomy right?** Six buckets; `environments/` is the one I am least
   sure earns its own folder over folding `room`/`checkers` into `models/`.
   Proceeding as designed; cheap to fold later, since folders are not names.
3. `polytopes/` — deferred, needs a design.
