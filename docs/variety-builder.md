# The variety builder: equations as first-class bases

**Status: CORE BUILT (July 2026)** — the transpiler
([`equation-transpiler.md`](equation-transpiler.md)), the formula catalogue,
the `variety()` base on the chain, the marched-sheet emission, the
`shell({inward, outward})` extension, and the clip-or-bound validation are
all live; `scenes/variety` (since renamed `scenes/variety-barth`) converted as the pilot (the last hand-written
`scene.glsl` retired — it had been silently broken since the
roomFace→roomFaceData migration, so the conversion was also the fix). All
pre-existing goldens byte-identical throughout. As-built deltas:
- the hand catalogue OVERLOADS some names (barthDecic: homogeneous 4-ary +
  hand 3-ary patch) — the 4-ary is the truth, the hand patch is the
  redundant rung the generated one replaces;
- the variety scale const is `<NAME>_VSCALE` (SCALE belongs to the
  transform); `scale: 1` literal emits no const;
- marched sheets are v1-restricted: untransformed, chains of domain mods +
  clip only — both loud;
- `shell({inward})` means depth from the zero set (solid `[-inward, 0]`) —
  half the old `varietyShell(d, t, 0)` span for the same number;
- the `{data: glsl\`\`}` escape hatch shipped with v1.
STILL OWED: the legacy variety bucket (~14 scenes), the float-source
catalogue migration (§6 end state), `--catalogue` listing varieties, and
the owner's by-eye pass on the pilot. Requirements history: `generator.md`
§6; the retired hand scene lives in git history.


## 1 · What a variety is, and what is derived

A variety is authored as an **equation**, not a distance function: a signed
defining function whose zero set is the surface. Everything else is
mechanical, and the pipeline is proven line-for-line in the hand scene:

1. **the gradient** — `data_<name>(p)`: three dual-number evaluations of the
   equation, one per partial (`T` arithmetic, `glsl/tracer/1Setup/dualNumbers.glsl`).
   Four lines of glue from the equation's name. This is what the generator emits.
2. **the distance** — `varietyDistance(data, scale)` = `DE(value, |grad|·scale)`
   (`glsl/shapes/variety.glsl`), a conservative signed estimate. The DE's
   internal constants stay baked (marching-tuning, not knobs).
3. **finite extent** — the zero set is unbounded; it is clipped to a shape.
4. **thickness** — left alone the zero set is a SHEET (infinitely thin,
   two-sided); thickened it becomes a region with an inside; the signed
   field itself is the SOLID (`{s < 0}`).

The load-bearing move (hand scene, §"THE OBJECT'S SDF"): **the object's sdf
stays SIGNED — `abs()` lives only at the marcher.** The sign is the face and
the gradient is the normal, so front/back materials work with no special case.


## 2 · The design: a new base, not a new system

Everything downstream of the equation already exists in the chain and node
grammar. The variety pass adds **one base kind and one marching rule**, and
rides the rest:

| need | served by |
|---|---|
| clip to a shape, smooth or sharp | `clip()` — `blend: 0` is sharp; its bound-donation rule was designed against this exact scene |
| thin sheet / thickened shell / one-side solid | `sheet()` node / `shell()` modifier (extended, §8) / the bare signed base in an `object()` |
| surface-vs-region first-class, from the bottom | the **node kind**: `sheet(...)` vs `object(...)` — grammar, not a flag |
| thicken FIRST, clip second (hand scene rule) | nesting order: `clip(shell(variety(...)))` — what an author writes naturally |
| sheet in a glass enclosure, multi-material | two nodes + `nestedIn`; presets deferred (decided) — the pass makes the two-node form easy, names come later |

```js
//named formula, thickened, clipped — every wrapper already exists
object('gyroidBall', {
    at: [...],
    shape: clip(shell(variety(varieties.gyroid, {scale: 3.0}), {thickness: 0.1}),
                {to: lib.sphere({radius: 1.9}), blend: 0.06}),
    material: glass({...}),
}),

//custom equation, as an infinitely thin two-faced membrane
sheet('membrane', {
    at: [...],
    shape: clip(variety({eqn: 'x^2*y + y^2*z + z^2*x - 0.1'}),
                {to: lib.sphere({radius: 1.9})}),
    front: ..., back: ...,
}),
```


## 3 · The base: `variety(source, opts)`

- `source` — a catalogue reference (`varieties.<name>`, §6) or a custom
  equation (`{eqn, params}`, §5).
- `opts.scale` — the variety's internal zoom (number or knob). The chain rule
  puts it on the gradient (`varietyDistance(data(SCALE*q), SCALE)`), keeping
  the returned distance in object-local units.
- `opts.view` — `'affine' | 'stereo'` (§4). A 3-ary source is affine, full
  stop. A 4-ary source defaults to stereo and may opt into `'affine'` (the
  generated `w = 1` patch). `'stereo'` on a 3-ary source is a loud error —
  there is no automatic lift.

The base plans like any other: domain mods fold its point, field mods act on
its distance, the derived bound folds alongside. Its distance is conservative
(the DE), so it satisfies `requiresTrueDF` consumers the way carve's output
does.


## 4 · Affine ↔ projective (decided, RETHOUGHT: R³ is primary; R⁴ authoring
generates it — never the reverse)

Drawing always happens in R³. Two renderable views, the two main
projections (others can come later):
- **affine**: evaluate a 3-ary formula at the point.
- **stereo**: lift the point to S³ (`invStereo`) and evaluate a 4-ary
  HOMOGENEOUS formula there — the double cover of the projective surface.

**THE ONE RULE — capability is the SIGNATURE, never the body:**
- a **3-ary** source has the affine view. Only.
- a **4-ary** source has BOTH: stereo directly, and the affine patch
  GENERATED by substituting `w = 1` — substitution is total (any body:
  polynomials, trig, loops), so this direction is always available. The
  generated patch + stereo wrappers replace today's hand-written `*Stereo`
  variants.

There is deliberately **no homogenization step** (this supersedes the
earlier define-once-derive-both draft): lifting R³ → R⁴ is partial — only
straight-line polynomials have degrees — and a capability that depends on an
invisible property of the body is exactly the unclear "works sometimes" this
design refuses. Want the stereo view? Author the homogeneous form: the
published form of these surfaces, and what the legacy `*Stereo` scenes
already did by hand. (A `--homogenize` authoring SCAFFOLD — the degree
bookkeeping run ONCE, output printed as float source to paste in as visible
authored text — can arrive later if hand-homogenizing ever hurts. Deferred.)

Homogeneity of a 4-ary source is checked NUMERICALLY by the verification
gate (`F(λp) = λᵈ·F(p)` at random points, `equation-transpiler.md` §5) —
body-agnostic, so a loop-bodied 4-ary formula is checked exactly like a
quartic.

Defaults: 3-ary → affine (the only view). 4-ary → stereo (that is why you
wrote it homogeneous); `view: 'affine'` opts into the patch. The emitted
stereo wrapper takes the lifted point straight to the equation; an S³
rotation (the legacy animation trick) is DEFERRED but the wrapper is the
obvious place for it later — a `mat4` between lift and evaluation.


## 5 · The equation DSL (decided: this is the easy rung)

`variety({eqn: 'x^2*y + y^2*z + z^2*x - c', params: {c: someKnobOr0.1}})`

- **Source forms** (decided): TWO inputs, one transpiler.
  1. **Catalogue formulas are standard float GLSL functions** —
     `float kummer(float x, float y, float z[, float w])` with a
     STRAIGHT-LINE body: local `float` declarations + a return expression
     (what every non-recursive formula already looks like). The GLSL is the
     source of truth; the transpiler emits the dual version. Arity is the
     affine/projective declaration — no string-scanning.
  2. **Scene-level custom equations are bare expression strings** (above) —
     the single-expression case of the same parser; `w`-presence is the
     projective detection there.
- **Grammar** (decided): the **GLSL expression subset** — an equation string
  is simultaneously valid float GLSL and valid DSL input, copy-pasteable
  into a shader and back. `^`(integer) is the one piece of sugar on top
  (strings only; a catalogue function body is pure GLSL).
- **Vocabulary** (decided): polynomials — `+ - * / ^`(integer), parentheses —
  plus `sin cos tan exp sqrt`. (The T library also has log/abs/min/max/pow;
  add on demand, each is one table row.)
- **Free parameters**: any other identifier resolves from `params`; a knob
  stays a live uniform, a number becomes a named const. (This replaces the
  old scratch-knob wiring inside formulas like `goldman`.)
- **Emission**: infix → AST → a `T eqn_<name>(T x, T y, T z[, T w])` function
  in the scene chunk, with shared subexpressions named (`T x2 = tsqr(x);`) —
  the same shape as a hand catalogue formula, and readable next to one.
  Homogenize/patch/degree are AST operations.
- **Loops and branches are IN scope** (decided): catalogue bodies may carry
  the statement whitelist (counted `for`, `if`/`else`, reassignment, helper
  functions) — forward-mode AD transpiles statement-by-statement, so the
  Chebyshev-class formulas are ordinary float source too
  (`equation-transpiler.md` §3). Body form never limits the views — only
  arity does (§4's one rule).
- **The escape hatch, third rung of the same ladder** — at the `data_`
  contract, not the T level: `{data: glsl\`...\`}`, an authored body
  returning `vec4(grad, value)`, for bespoke distance-estimator math that
  is not an equation at all. Hand dual-number T code is NOT part of the end
  state (§6).

The DSL is scoped to be a *transpiler, not a CAS*: no simplification, no
factoring, no AST rewrites — emit what was written, named subexpressions
aside. (The `w = 1` patch is substitution at the wrapper, not a rewrite.)

**The emitted arithmetic (decided): one-pass `vec4` forward mode.** Today's
scheme evaluates the equation THREE times (one `vec2` dual per partial, the
value triplicated). Because nobody hand-writes emitted code, the transpiler
emits `vec4` duals — `(value, ∂x, ∂y, ∂z)` — seeded `x = vec4(p.x, 1,0,0)`
etc.: ONE evaluation returns value + full gradient, no three-seed `data_`
wrapper, roughly 2× cheaper marches on the most expensive sdfs in the
tracer. `+`/`-`/scalar-mult stay native; `tmul`/`tsqr`/`tsin`... gain vec4
OVERLOADS beside the vec2 originals, so emitted code reads exactly like the
hand catalogue, just wider. Hand escape-hatch formulas keep the vec2 path +
three-seed wrapper; both meet at the `vec4 data_` contract. (Symbolic
closed-form gradients considered and rejected: product-rule swell on
degree-12 surfaces vs forward-mode's bounded cost.)
**The precise engineering spec for this whole subsystem — representation,
op table, transpiler grammar, homogenization algorithm, verification gate,
build order — is [`equation-transpiler.md`](equation-transpiler.md).**


## 6 · The formula catalogue

Parse `glsl/objects/varieties/formulas/*.glsl` the way `lib` parses
`glsl/shapes/` (catalogue.js precedent): every top-level
`T <name>(T x, T y, T z[, T w])` is an entry; arity is the affine/projective
fact. Namespace: `varieties.<name>` (name provisional). Formula files stay
opt-in — a scene's chunk includes only the file(s) its formulas live in,
exactly like `uses:`.

- The hand-written `*Stereo` wrappers in the catalogue become redundant
  (generated, §4) — delete them in the migration pass, not before.
- Formulas with baked scratch-knob parameters (`goldman`) are re-authored to
  take the parameters as arguments during migration; the catalogue parses
  extra `T`/`float` parameters after the coordinates like shape params.
- The catalogue also feeds `--catalogue`, per the settled requirement.

**End state (decided): the catalogue is 100% standard float GLSL.** Formula
files become plain `float <name>(float x, float y, float z[, float w])`
functions — readable, testable, paste-into-a-shader standard GLSL — and the
transpiler owns every `tmul` forever (§5 source form 1). With loops and
branches in scope (§5), even the Chebyshev-class formulas are float source:
NO hand dual-number files remain. When the last one converts, the vec2 T
library, the three-seed wrappers, and `#define T vec2` are deleted — with
the "can't name a variable `T`" gotcha dying alongside. Because every
formula then exists as BOTH float source and generated dual arithmetic, the
build cross-checks itself: evaluate the float form and a numerical gradient
at random points in JS, compare against the emitted dual version, per
formula, as an automated regression gate — the kleinian-style math check
running for free on the whole catalogue. Migration is incremental and
per-formula verifiable (un-transpiling a T formula to float is mechanical in
the easy direction: `tmul`→`*`, `tsqr`→squaring); the T-GLSL parser above is
still v1, so nothing blocks on rewriting 37 formulas.


## 6.5 · The float-source migration — EXECUTED (July 2026)

Completed as planned below, file-atomically, gate green at every step. The
catalogue is now **44 float formulas in `glsl/shapes/varieties/`** (its
permanent home, beside the `varietyDistance` engine helpers; the reference
doc moved there as the math archive). The expansion landed: Barth6T, Barth10
(the published form — the hand decic's untracked rendering bug turned out
to be a spuriously squared `(2−φ)`), both Endrass roots, Sarti8, Escudero9,
Togliatti + Dervish, the Chebyshev family with a live int order. Moduli are
live: kummer.muSqr, barthSextic.tau, goldman's four, the Möbius pairs,
thistle's c. TWO reference variants were audited out: Togliatti5's `Mu` is
an overall factor (cannot change a zero set) and Escudero9_2 is a
hand-written affine patch. Shared twins dedupe chunk-wide (two objects, one
formula → one emission; the doubleCover scene forced the mechanism). THE
FINALE SHIPPED: the vec2 `T` library, `#define T vec2` (and the "no
variable named T" gotcha), the three-seed wrappers, and the hand
`*Stereo`/patch overloads are deleted — `dualNumbers.glsl` is vec4-only,
plus `DE` and the dual `invStereo`. `glsl/objects/varieties/` is gone.
(`VARIETY_DATA` references survive only in the uncompiled legacy
`glsl/objects/` shadow, which dies with the objects port.)

The plan as executed:

- **Source of truth:** `algVariety-reference.md` — the PUBLISHED projective
  float forms, with moduli still free. Better than the hand-T code (which
  was hand-transpiled FROM them). The doc stays in place as the math
  archive; formulas not in it (the gallery set) un-transpile mechanically
  (`tmul`→`*`).
- **Notation: FLATTEN to the scalar grammar.** The reference's vec4/swizzle
  idiom is Shadertoy compactness, not speed — GPUs are scalar; both
  spellings compile to the same arithmetic (and emission is untouched
  either way). Teaching the transpiler vector types would also make `vec4`
  mean two things across the toolchain (four scalars in source, a dual in
  emission). `while` recursions rewrite as counted `for`.
- **Moduli become TRAILING PARAMETERS** (float or int — int is a small
  classify() extension, for `Chmutovn`'s order), with catalogue defaults
  declared as `//@default <fn>.<param> <value>` annotations: a scene may
  omit them (default bakes) or knob them (a live Kummer μ). Scratch-knob
  wiring (goldman) dies in the same move.
- **Migration = EXPANSION:** the never-ported set rides along in its
  degree's file — Togliatti ×2, Dervish, Sarti8, Chmutov8/Chmutovn,
  Escudero9 ×2, the minus-root Endrass, Barth6T (~45 formulas total).
- **Verification:** the gate walks every catalogue float formula (defaults
  required — a parametrized formula without `//@default` is a loud error):
  value/gradient/homogeneity/FITTED DEGREE (Sarti12 had better fit 12).
  Scenes using migrated formulas get golden rebakes + render checks. No JS
  emulation of the old T code — the float forms are more authoritative.
- **Mixed catalogue during migration:** a formula FILE is either all-T
  (three-seed include path, as today) or all-float (transpiler input, NOT
  included — only generated code ships; helpers keep their float original
  in the chunk only when a scalar-kind call needs it).
- **The finale:** with the last file converted, delete the vec2 T library,
  `#define T vec2` (and its naming gotcha), the three-seed wrapper path,
  the hand `*Stereo`/patch overloads, and the `VARIETY_DATA` remnants.


## 7 · Mode = node kind, and the marched-sheet rule (the new emission)

- **`object()` + variety base**: the signed field is the region; the solid is
  `{s < 0}`. Nothing new to emit.
- **`sheet()` + variety base**: the signed sdf is emitted as today (the
  classifier and normals read it; front/back work because it is signed). NEW:
  the **marched form**. Today every sheet in the tree is analytic (the sheet
  golden marches nothing) — the generator has never emitted a marched sheet.
  The rule, from the hand scene's `sdf_Scene`:

  ```glsl
  //abs on the pre-cutter value; cutters HARD-maxed outside the abs
  max(abs(<chain before cutters>), <cutter terms, no blend>)
  ```

  `abs` makes the marcher stop on `{s=0}` and pass through `{s<0}`; the hard
  max outside the abs keeps the clip cap over `{s<0}` from being drawn.
  Known wrinkle, accepted by the hand scene: within the blend collar at the
  clip rim, the marched surface (hard) and the classified surface (blended)
  disagree by up to `blend/4` — rim artifacts are confined to that collar.
- **Sheet chain validation (v1)**: a marched sheet's chain may carry domain
  mods and `clip` only — `shell`/`round`/`carve` on a sheet make it a region
  (that's what `object()` is for), and `subtract`'s semantics on a two-sided
  membrane are undefined. Loud error naming the fix.


## 8 · `shell()` extended (decided: extend, then reuse)

`shell({thickness})` keeps today's exact semantics (behavior-frozen:
`abs(d) - T`). NEW alternative form `shell({inward, outward})` — solid where
`-inward <= d <= outward`, emitted `abs(d - (outward-inward)/2) - (inward+outward)/2`
— for asymmetric thickening (the hand catalogue notes enneper "gets
unnaturally thick" symmetric). Validation: `inward + outward >= 0.006`
(2·AT_THRESH, same classifier rule as today); bound inflates by `outward`
(today: by `thickness`). This replaces `varietyShell`'s role in emitted code;
`varietyShell` itself stays for authored bodies.


## 9 · Bounds and validation (decided: always loud)

A bare variety is unboundable — the DE is real math but the zero set is
infinite. **A variety base must end its chain with a `clip` (whose bound
donation is the acceleration volume) or sit on a node with an authored
`bound:`.** Anything else is a loud error at plan time:

```
scenegen: 'membrane': a variety has no derivable bound — clip it to a shape
(clip(..., {to: ...}), which donates its bound) or author a bound: on the node
```

Other validations: a 4-ary source is numerically homogeneity-checked by the
gate (§4); DSL parse errors point at the offending token; sheet chains per
§7; `params` must cover every free identifier (and nothing more).


## 10 · What one object emits

`clip(variety({eqn: 'x^3 + y^3 + z^3 - (x+y+z)'}), {to: lib.sphere({radius: 1.9}), blend: 0.06})`
as `object('cubic', {at: ..., material: glass({...})})`:

```glsl
T eqn_cubic(T x, T y, T z){
    T x3 = tmul(x, x, x);
    T y3 = tmul(y, y, y);
    T z3 = tmul(z, z, z);
    return x3 + y3 + z3 - (x + y + z);
}

vec4 data_cubic(vec3 p){
    T vx = eqn_cubic(T(p.x, 1.0), T(p.y, 0.0), T(p.z, 0.0));
    T vy = eqn_cubic(T(p.x, 0.0), T(p.y, 1.0), T(p.z, 0.0));
    T vz = eqn_cubic(T(p.x, 0.0), T(p.y, 0.0), T(p.z, 1.0));
    return vec4(vx.y, vy.y, vz.y, vx.x);
}

float sdf_cubic(vec3 p){
    vec3  q = p - CUBIC_P;
    float d = varietyDistance(data_cubic(CUBIC_SCALE*q), CUBIC_SCALE);
    return smax(d, sphereDistance(q - CUBIC_CLIP_P, CUBIC_CLIP_RADIUS), CUBIC_CLIP_BLEND);
}

float bound_cubic(vec3 p){
    return sphereDistance(p - CUBIC_P, CUBIC_CLIP_RADIUS) - CUBIC_CLIP_BLEND;
}
```

Same object as a `sheet()` adds the marched variant per §7. Everything after
`data_` is the existing chain fold, untouched.


## 11 · Migration and acceptance

1. **Pilot: convert `scenes/variety`** — the last hand-written scene. No
   byte-compare is possible (the hand file is not generator-shaped); fidelity
   is proven the kleinian way: port both DE paths to plain JS and compare
   over ~200k random points (the legacy/ scenes no longer run, so by-eye
   against the original is not available — the JS comparison is the MATH
   check, renders are the LOOK check).
2. Existing goldens: byte-identical throughout (new base = new code path).
   `shell()`'s `{thickness}` form must not change one byte.
3. Then the legacy variety bucket (~14 scenes), scene by scene, raw-absorb
   color rule and all standing porting lessons applied.
4. When the last hand `*Stereo` wrapper and `VARIETY_DATA` reference is
   gone: delete them (`objectAPI.glsl` note included), update the formulas
   README.
5. When the last hand T-GLSL formula converts to float source: delete the
   vec2 T library, the three-seed wrappers, and `#define T vec2` (retiring
   the T-naming gotcha) — the vec4 overload section becomes the only dual
   arithmetic in the tree.


## 12 · Out of scope (deliberately — all decided)

- **Presets for multi-material composites** (sheet-in-glass-ball). Deferred:
  this pass makes the two-node form easy; names come when the pattern has
  recurred. Nesting stays declared (`nestedIn`), never inferred.
- **Shared cached evaluation** (the cubic-scale five-objects-one-polynomial
  problem) — `generator.md` §6, unchanged.
- **Non-orientable sheets** (Möbius declares one face, ignores `front`) —
  nothing forces it yet.
- **S³ rotation / animation** of stereo views — the wrapper accommodates it
  later (§4).
- **Other projections** beyond affine patch + stereographic.
- **The `--homogenize` authoring scaffold** (§4) — until hand-homogenizing
  demonstrably hurts.
- **DSL as a CAS** — no simplification, no factoring, ever.
