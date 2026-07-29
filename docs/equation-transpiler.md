# The equation transpiler and the vec4 dual-number system

**Status: BUILT (July 2026).** All six build-order steps landed the same day
the spec was written, one commit per stage, every scene golden untouched
throughout. Files: `js/scenegen/equations.js` (parse/evaluate/verify/emit,
~1100 lines), the vec4 section in `dualNumbers.glsl`, the gate in `gen.mjs
--equations`, suite + byte-exact emission fixtures in
`render-tests/equations/`. As-built deltas from the plan below:
- the GATE landed at stage 1 and grew with every stage (the only sane way to
  run vite-loaded modules), rather than arriving at step 6;
- function sources are CLOSED (no free identifiers) — trailing formula
  parameters play the scene-string `params` role, and are read-only;
- `else if` chains and ternaries are in (a ternary's condition is a
  comparison, parsed `expr CMP expr ? … : …`); int/float mixing is refused
  (GLSL ES has no implicit conversion), int expressions are int-only;
- helper twins overload the float ORIGINALS by name — a scalar-kind helper
  call emits the plain name and relies on the float original in the
  catalogue file;
- `x*x` emits `tmul(x, x)`, not `tsqr` — squares are recognized from `^2`
  only (no-simplification rule);
- the parent design is [`variety-builder.md`](variety-builder.md) §5.
Integration into the `variety()` base is the NEXT phase (variety-builder
§7–§10).


## 1 · The representation and the contract

A generated dual number is a `vec4`: **`(value, ∂x, ∂y, ∂z)`** — value in
`.x`, gradient in `.yzw`. One evaluation of the transpiled equation returns
the value and the full gradient (one-pass forward mode, three tangents wide),
replacing today's three `vec2` evaluations with the value computed thrice.

- **Seeds**: `x = vec4(p.x, 1.0, 0.0, 0.0)`, `y = vec4(p.y, 0.0, 1.0, 0.0)`,
  `z = vec4(p.z, 0.0, 0.0, 1.0)`. Constants and parameters: `vec4(c, 0.0, 0.0, 0.0)`.
- **The `data_` contract is unchanged** (`varietyDistance(vec4 data, scale)`
  reads `data.xyz` = gradient, `data.w` = value — `glsl/shapes/variety.glsl`,
  untouched). The generated wrapper ends with one swizzle:
  `return v.yzwx;` maps `(value, gx, gy, gz)` → `(gx, gy, gz, value)`.
- **The hand `vec2` path survives only through migration** (decided: the
  statement-level transpiler covers the Chebyshev-class formulas too, so no
  formula NEEDS hand dual code). While hand T-GLSL formulas remain, they
  keep the three-seed `data_` wrapper exactly as `scenes/variety` writes it —
  both paths meet at the same `vec4 data_` contract. When the last one is
  converted: the vec2 T library, the three-seed wrappers, and `#define T vec2`
  itself are DELETED — which also retires the "a variable may not be named
  `T`" gotcha. The lasting escape hatch sits at the `data_` contract instead:
  an authored glsl`` body returning `vec4(grad, value)`, for bespoke
  distance-estimator math that is not an equation at all.


## 2 · The GLSL layer — additions to `dualNumbers.glsl`

One new, clearly-marked section: **vec4 overloads of the existing names**
(GLSL overloads on parameter type; `#define T vec2` is untouched and no new
alias is introduced — emitted code writes `vec4` plainly). Native vec4 ops
that are ALREADY correct dual arithmetic and need no function: `a + b`,
`a - b`, `-a`, `s * a` (scalar × dual).

| op | definition |
|---|---|
| `tmul(a, b)` | `vec4(a.x*b.x, a.x*b.yzw + b.x*a.yzw)` |
| `tsqr(a)` | `vec4(a.x*a.x, 2.0*a.x*a.yzw)` |
| `tinv(a)` | `vec4(1.0/a.x, -a.yzw/(a.x*a.x))` |
| `tdiv(a, b)` | `vec4(a.x/b.x, (b.x*a.yzw - a.x*b.yzw)/(b.x*b.x))` |
| `tsqrt(a)` | `float r = sqrt(a.x);` → `vec4(r, 0.5*a.yzw/r)` |
| `texp(a)` | `exp(a.x)*vec4(1.0, a.yzw)` |
| `tsin(a)` | `vec4(sin(a.x), cos(a.x)*a.yzw)` |
| `tcos(a)` | `vec4(cos(a.x), -sin(a.x)*a.yzw)` |
| `ttan(a)` | `vec4(tan(a.x), a.yzw/(cos(a.x)*cos(a.x)))` |
| `tpow(a, float p)` | `pow(a.x, p - 1.0)*vec4(a.x, p*a.yzw)` |

(`tlog`/`tabs`/`tmin`/`tmax` on demand — each is one row, both here and in
the vocabulary.) Also 3- and 4-argument `tmul` overloads — the vec2
library's own idiom, which the emitter uses for flattened products
(`16.0*tmul(x, z, term)`). Plus a **vec4 `invStereo` overload** — same body
as the T version, built from the overloaded ops — for the stereo view's
lift.


## 3 · The transpiler — `js/scenegen/equations.js`

One module owning: parse → AST → (emit GLSL | evaluate in JS | homogenize).
No dependencies; a small recursive-descent (Pratt) parser.

**Grammar** (the GLSL expression subset):
- expression: float literals, identifiers, `+ - * /`, unary `-`, parens,
  `fn(args)` with `fn` in the vocabulary; `^` with an INTEGER literal
  exponent (expression strings only — catalogue bodies are pure GLSL).
  Precedence: `^` > unary `-` > `* /` > `+ -`.
- catalogue function body (**statement whitelist** — decided: forward-mode
  AD is local, so statements transpile independently and loops/branches are
  IN scope): comments stripped, then any sequence of
  - `float <id> = <expr>;` / `int <id> = <expr>;` declarations,
  - reassignment `<id> = <expr>;`,
  - counted loops `for(int i = <int>; i < <int>; i++){ ... }` (int bounds —
    loop counters are never differentiated),
  - `if(<cond>){...}[else{...}]` and ternaries — a comparison on a dual
    reads its VALUE lane (`v.x < 0.0`); each branch dual-izes independently
    (piecewise derivative — the hand `tabs` precedent),
  - one or more `return <expr>;`.
  Anything else (`while`, value-dependent bounds, `discard`, swizzled
  writes) is a loud error naming the construct. **Helper functions** in a
  formula file (`float cheb(float x, int n)`) are transpiled too and get
  generated dual twins; the formula-vs-helper rule: a FORMULA's parameters
  are 3–4 floats named `x y z [w]` plus trailing float params — anything
  else is a helper. **Variable kinds promote**: a variable assigned a dual
  expression anywhere is `vec4` throughout its scope.

**Identifier classification**: coordinates (`x y z`, and `w` / the fourth
parameter), declared locals, else **free parameters** — which must be covered
by the `params` map (scene strings) or the formula's extra `float` arguments
(catalogue), exactly and exhaustively (unused param = error too).

**The scalar/dual kind rule**: an AST node is SCALAR iff it contains no
coordinate variable (numbers, params, and locals built only of those). Scalar
nodes emit as `float` and combine with native float arithmetic — parameter
soup (goldman's `k`) stays cheap scalar math. Dual nodes emit `vec4`. Mixed
combinations:
- scalar × dual → native `s*d`;
- scalar ± dual → the scalar folds as a constant dual: `d ± vec4(s, 0.0, 0.0, 0.0)`
  (one term per sum, scalars pre-combined — the hand catalogue's `- T(0.1, 0)`
  idiom, one lane wider);
- scalar `fn` scalar → plain float `fn` (no dual op).

**Power emission**: integer powers become cached power-locals in the hand
catalogue's own style — `x2 = tsqr(x)`, `x3 = tmul(x2, x)`, `x4 = tsqr(x2)`,
odd `n` = `tmul(pow(n-1), base)`, even `n` = `tsqr(pow(n/2))` — named after
the base when the base is a variable or local, inline `tsqr`/`tmul` chains
otherwise. `/` emits `tdiv` (or scalar division when both sides are scalar).

**Locals**: source locals are PRESERVED as emitted locals (`float a = …` →
`vec4 a = …`, or `float` if scalar) — emitted code mirrors the float source
line for line and stays readable next to hand formulas. Locals are inlined
only for the homogenize/degree analysis (§4), never for emission.

**The wrapper forms** (the source × view matrix, variety-builder §4):

```glsl
//affine (3-ary), the base case
vec4 data_<name>(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    <transpiled body: locals..., vec4 v = <return expr>;>
    return v.yzwx;    //(∂x, ∂y, ∂z, value) — the data_ contract
}
```

- **stereo view** (4-ary sources): seed `x y z` as above, then the
  vec4 `invStereo(x, y, z, X, Y, Z, W)` lift, body evaluated at `X Y Z W`.
- **affine patch of a 4-ary**: body evaluated with `w = vec4(1.0, 0.0, 0.0, 0.0)`.
- **hand T-GLSL formulas**: the three-seed vec2 wrapper, as today.

Worked example — `x^2*y + y^2*z + z^2*x - 0.1` emits:

```glsl
vec4 data_cubic(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    vec4 x2 = tsqr(x);
    vec4 y2 = tsqr(y);
    vec4 z2 = tsqr(z);
    vec4 v = tmul(x2, y) + tmul(y2, z) + tmul(z2, x) - vec4(0.1, 0.0, 0.0, 0.0);
    return v.yzwx;
}
```


## 4 · The patch — and deliberately NO homogenization

(Rethought with the user; supersedes the earlier homogenize-on-demand
draft. Rationale: variety-builder §4.) Capability is the SIGNATURE:

- **4-ary → 3-ary (the affine patch)** is TOTAL: substitute
  `w = vec4(1.0, 0.0, 0.0, 0.0)` at the wrapper — works for any body
  (polynomials, trig, loops). This is the only derived direction.
- **3-ary → 4-ary does not exist here.** Lifting needs degrees (partial,
  polynomial-only) and would make capability depend on invisible body
  properties. An author who wants the stereo view writes the homogeneous
  4-ary form. A `--homogenize` authoring SCAFFOLD (degree bookkeeping run
  once, float source printed for pasting) is DEFERRED until wanted.

Homogeneity of every 4-ary source is checked NUMERICALLY by the gate (§5) —
body-agnostic, no static degree analysis anywhere in the transpiler.


## 5 · The verification gate — the transpiler checks itself

`equations.js` also evaluates the AST directly in JS, two ways: **float**
(plain arithmetic) and **dual** (the same vec4 semantics in float64) — a
small AST *interpreter*, since bodies may carry statements and loops. Per
formula, over N = 2000 points sampled in `[-2, 2]³` (seeded RNG,
reproducible; projective forms also lifted to random points of S³):

1. **value**: dual `.x` vs float eval — relative tolerance `1e-9` (same
   math, float64 both sides; this catches transpiler bugs, not GPU float32).
2. **gradient**: dual `.yzw` vs central-difference numerical gradient of the
   float eval (`h = 1e-5`) — relative tolerance `1e-4`, scale-aware.
3. **homogeneity** (every 4-ary source, any body): fit the degree from
   `log|F(λp)/F(p)| / log λ` at random `λ` and points — it must be one
   consistent integer `d`, and `F(λp) = λ^d·F(p)` must then hold across
   the sample. This is the SOLE homogeneity authority (no static check).
4. **migration cross-check**: where a hand T-GLSL formula is being replaced
   by a float source, the old dual formula is ALSO ported to the JS dual
   evaluator once and compared over the same points — the kleinian-style
   bit-fidelity check, per formula, then the hand version is deleted.

Runs as **`node scripts/gen.mjs --equations`** (verify every catalogue
formula + every scene's custom eqn; part of the same workflow slot as
`--goldens`). Never at page load — emission stays pure and fast; the gate is
a build/test-time tool.


## 6 · Validation and errors

House rules (name the fix, point at the doc):

1. Unknown function / non-integer `^` exponent / malformed literal → parse
   error with the offending token and the vocabulary list.
2. A statement outside the whitelist (`while`, value-dependent bounds,
   swizzled writes, …) → error naming the construct and the whitelist —
   "if it truly cannot be written this way, author a data: body
   (variety-builder §5)".
3. Free identifier not in `params` / unused `params` entry → both loud.
4. A 4-ary source that fails the gate's numeric homogeneity check → error
   reporting the two sample points whose fitted degrees disagree (gate-time,
   not parse-time — the only homogeneity authority, §4/§5).
5. `view: 'stereo'` requested on a 3-ary source → error: "the stereo view
   needs the homogeneous 4-ary form — author it (there is no automatic
   lift); variety-builder §4".


## 7 · File map, build order, acceptance

| piece | file | new/edit |
|---|---|---|
| parser, AST, JS float+dual eval, homogenize, verify | `js/scenegen/equations.js` | new |
| GLSL emission of transpiled bodies + wrappers | `equations.js` (emit half) | new |
| vec4 overload section + vec4 `invStereo` | `glsl/tracer/1Setup/dualNumbers.glsl` | additive edit |
| `--equations` gate | `scripts/gen.mjs` | additive edit |
| unit fixtures: source → exact emitted text | `render-tests/equations/` (or beside goldens) | new |

Build order — each step lands testable:
1. `equations.js` EXPRESSION parse + JS evals + verify (pure JS; test
   against hand formulas re-authored as float strings — cubics first).
2. Emission with exact-text fixtures (golden-style: source in, emitted GLSL
   out, byte-compared — the emitter discipline applied to the transpiler).
3. `dualNumbers.glsl` vec4 section (compile-checked by any scene build).
4. The wrapper matrix: affine / stereo / patch (`w = 1` substitution).
5. STATEMENT support (whitelist grammar, kind promotion, helper twins,
   interpreter extension) — `cheb`/`chmutov` as the acceptance formula.
6. The `--equations` gate wired into `gen.mjs` (including the numeric
   homogeneity check, the sole homogeneity authority).

**Acceptance**: every existing golden byte-identical (nothing here touches a
scene); the gate green over the re-authored cubics; one shader compile of a
page including the vec4 section. Integration into the `variety()` base is
the NEXT phase (variety-builder §7–§10), not this one.


## 8 · Out of scope (deliberately)

- Symbolic closed-form gradients (rejected: degree-12 product-rule swell vs
  forward mode's bounded cost — variety-builder §5).
- CAS behavior: no simplification, no factoring, no constant folding beyond
  scalar-kind classification.
- `while` loops and value-dependent iteration counts — nothing in the
  catalogue wants them; counted `for` covers the recursions that exist.
- Second derivatives / curvature (would be `mat3`-carrying duals; nothing
  needs them yet — shape-data curvature can revisit).
- GPU-side float32 accuracy analysis — the gate proves the transpiler, the
  renders prove the look, as everywhere else in this project.
