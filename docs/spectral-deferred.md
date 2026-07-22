# Deferred hero wavelength

Why spectral mode is noisy everywhere when only refraction needs it, and the
design that fixes it: a ray stays plain RGB until the moment its path actually
depends on wavelength. Companion to [material-fields.md](material-fields.md)
(the `waveLength` global is available to material fields) and the spectral
design notes in [spectral.glsl](../glsl/tracer/1Setup/spectral.glsl).

> TL;DR — today every spectral ray is born tinted by a saturated one-channel
> weight (~4× peak), so every path in the scene pays heavy chroma variance
> ("confetti") even when nothing on its route disperses. The fix: draw the
> wavelength **lazily, at the first refraction through a dispersing interface**
> — tint the throughput there, and let every later `iorAt()` pick up the shift
> automatically. Paths that never refract through dispersive glass carry *zero*
> spectral noise; dispersive paths are sampled exactly as before. Requires the
> two **base** indices stored in `LocalData` (the ratio alone can't be re-shifted)
> and a three-line resolution hook in `scatter()`'s refract branch. Off-switch
> behavior is unchanged: `spectral` off stays byte-identical.

## The problem: variance with no matching integrand

The hero-wavelength estimator integrates the image over wavelength λ:
each sample draws λ uniform in [0,1], carries weight `spectralWeight(λ)`
(three Gaussian bands, each normalized so its mean over λ is 1), and evaluates
the path with wavelength-shifted indices `iorAt(n, λ)`. The estimator is
unbiased: the tints average to white, so anything λ-independent converges to
its ordinary RGB.

But *where* the λ-dependence enters matters for variance. The integrand
depends on λ **only through refraction directions at dispersing interfaces**
(and, weakly, through Fresnel amounts — see Approximations). For a path that
never refracts through dispersive glass, the integrand is constant in λ — yet
today the sample still carries the tint, a weight that swings between ~0 and
~4 per channel. That is a Monte Carlo estimate of an integral we could have
done exactly (it's 1). The cost is visible: with `spectral` on, a purely
diffuse scene (marble, the seahorse) renders as rainbow confetti that takes an
order of magnitude longer to converge to the *same image* it would have
produced with spectral off.

Measured while diagnosing the roulette bug: at the render-test budget the
seahorse baseline is smooth while the spectral render is still saturated
speckle; blurred means confirm the limits agree (unbiased), so the entire
difference is variance.

## The idea

Defer the draw. A ray starts **spectrally unresolved**: `waveLength` pinned to
0.5 (mid-band), throughput untinted, every material evaluated at its base
index — bit-for-bit the non-spectral tracer. The first time the path is about
to take a direction that depends on λ — the refract branch through an
interface whose two sides' *dispersed* indices differ — it **resolves**:

```glsl
// spectral.glsl
bool waveResolved;                       // reset false each newFrame

void resolveWavelength(inout Path path){
    if(!spectral || waveResolved){ return; }
    waveLength   = randomFloat();
    waveResolved = true;
    path.light  *= spectralWeight(waveLength);
}
```

From that moment the ray is monochromatic. Nothing downstream needs a case
split: `iorAt()` already reads the global `waveLength`, so every *subsequent*
hit's `dat.IOR` comes out wavelength-shifted automatically. Only the resolving
hit itself needs care — its `dat.IOR` was built at mid-band before we knew λ —
so the refract branch recomputes the ratio after resolving:

```glsl
// scatterPath.glsl, refract branch (and this is the WHOLE integration)
if(spectral && dispersion > 0. && path.dat.iorCur != path.dat.iorEnt){
    resolveWavelength(path);
    path.dat.IOR = iorAt(path.dat.iorCur) / iorAt(path.dat.iorEnt);
}
newDir = vRefract(path.tv, normal, path.dat.IOR);
```

### Why this is correct

The wavelength is an independent uniform random variable; drawing it at birth
or at first use is the same joint distribution, so **dispersive paths are
sampled exactly as today** (the tint multiplies the throughput at a different
time, but throughput updates commute). For paths that never reach a dispersive
refraction, the λ-integral is done analytically (it is exactly 1 by the
`spectralWeight` normalization) instead of by a one-sample estimate — expectation
identical, variance strictly reduced, to zero for those paths. This is the
standard "integrate out what you can" improvement; no estimator anywhere gets
a different expected value.

### The resolution rule, precisely

Resolve if and only if **all three** hold at the refract branch:

| condition | why |
|---|---|
| `spectral` on | master switch; off = byte-identical tracer |
| `dispersion > 0.` | at 0, `iorAt` is λ-independent — there is nothing to resolve, so `spectral` on + dispersion 0 now renders *noise-free identical* to spectral off (today it pays full tint noise for no effect) |
| `iorCur != iorEnt` (base indices differ) | an index-matched interface does not bend, hence cannot disperse; also keeps IOR-1 materials (the initMat default) from ever resolving |

Branches that do **not** resolve, deliberately:

- **Specular reflection** — the reflected direction is λ-independent. An
  unresolved reflection off glass uses the mid-band Fresnel amount, which is
  the correct first-order marginal (see Approximations).
- **Diffuse bounce** — obviously λ-independent.
- **Subsurface entry** (the diffuse-branch `vRefract` into a scattering
  medium) — the entry direction technically shifts with λ, but the isotropic
  walk inside immediately destroys all directional correlation, so resolving
  there would buy nothing visible and cost tint noise on every SSS scene with
  the toggle on. The entry stays mid-band. This is a modeling decision, not an
  oversight; revisit only if a "dispersive wax" look is ever wanted.
- **Non-rendered passthrough** (`renderMaterial == false`, e.g. `air()`) — no
  direction change at all.

## What changes, file by file

Small and additive; no knobs, no GUI, no scene changes.

1. **`path.glsl` — `LocalData` gains the base indices**: `float iorCur;
   float iorEnt;` (undispersed, current/entering). Needed because the stored
   `dat.IOR` is a *ratio*: once formed, it cannot be re-shifted per wavelength
   — `iorAt(a)/iorAt(b)` is not a function of `a/b`. `initializeData` sets
   both to 1.
2. **`setImpactData.glsl` — three sites record them** alongside the existing
   ratio: `setObjectInAir` (inside: cur = `mat.IOR`, ent = 1; outside:
   cur = 1, ent = `mat.IOR`), `setMaterialInterface` (cur = `current.IOR`,
   ent = `neighbor.IOR`), `setSurfaceInMat` (both 1 — it is an interface-less
   sheet). `applyMaterial` inherits the behavior for free since it re-runs
   `setObjectInAir`. The existing `dat.IOR = iorAt(...)/iorAt(...)` lines stay
   exactly as they are — pre-resolution they evaluate at mid-band (= the base
   ratio), post-resolution they are automatically λ-shifted. No other reader
   of `dat.IOR` changes.
3. **`spectral.glsl`** — add `waveResolved` + `resolveWavelength()` (above);
   rewrite the header's GATE paragraph.
4. **`traceShader.glsl` `newFrame`** — `waveLength = 0.5; waveResolved = false;`
   unconditionally; **delete** the upfront draw and the upfront
   `path.light = spectralWeight(...)` tint. (One consumed random disappears
   from the spectral-on stream; spectral-off consumed none before and none now.)
5. **`scatterPath.glsl`** — the guarded resolve + ratio recompute in the
   refract branch (the snippet above). Nothing else in `scatter()` moves.

## Approximations, stated honestly

Both are order-`dispersion·(n−1)` effects on *Fresnel amounts only*; directions
are exact.

- **Unresolved Fresnel runs at mid-band.** Physically the reflect/refract
  split varies a little with λ. For an *unresolved* ray the right quantity is
  the λ-average of `F(n(λ))`, and since `n(λ)` is linear in λ with mean = base
  index, mid-band `F` is the first-order-exact marginal. (Today's code shifts
  `F` per-λ from birth; the deferred design is arguably *less* noisy and no
  less correct in expectation to first order.)
- **No energy-split reweight at the resolving hit.** The refract lobe was
  chosen with probability `1 − F(mid)` but at the resolved λ carries fraction
  `1 − F(λ)`; the exact estimator would multiply the throughput by their
  ratio. We omit it: it is within a few percent except near grazing, it keeps
  the house convention that "lobe probabilities ARE the energy fractions, no
  reweights in scatter()" (see the 1/prob removal note in scatterPath.glsl),
  and omitting it errs smoothly, not with fireflies. If dispersive glass ever
  looks measurably off at grazing angles, this is the one line to add:
  `path.light *= (1.-F_resolved)/(1.-F_mid);`.

## Edge cases

- **λ-flip into TIR at the resolving hit**: mid-band Fresnel said "refractable,"
  but the resolved (bluer, denser) index can put the angle past critical.
  `vRefract` is already **total** — it returns the reflected ray under TIR
  (physics.glsl), which is exactly the physically correct outcome for that
  wavelength. No new handling needed; worth a comment at the call site.
- **Roulette**: the tint (peak ~4 in one channel) now enters mid-path;
  `p = min(|light|∞, 1)` already handles throughput above 1 — that cap was a
  prerequisite for spectral in any form (see the energy-loss fix note in
  updatePath.glsl).
- **Material fields reading `waveLength`**: a scene field sampling the global
  (allowed by material-fields.md) sees 0.5 until the path resolves. That is
  the correct unresolved marginal, but it means "spectral albedo" fields only
  vary on dispersive paths. Fine for now; a scene needing per-λ albedo on
  diffuse paths would need its own resolve hook — out of scope, note it in
  material-fields.md when it ever comes up.
- **Debug lenses** (`uDebugMode != 0`): the debug fork runs before any scatter,
  so debug passes always see the unresolved mid-band state — unchanged from
  today's dispersion-0 appearance. No work needed.

## What deliberately does not change

`Material`, the object API, all scenes, both knobs and their GUI, `vRefract`/
`FresnelReflectAmount`, `updateProbabilities`, subsurface scattering, the
accumulator. `spectral` off remains byte-identical to the non-spectral tracer
(same math, same random stream). The `dispersion` slider's meaning is
unchanged; its dead zone (nonzero with spectral off) is unchanged.

## Verification plan

1. **Off-switch frozen**: full render-test pass, `spectral` off (every scene's
   default except prism/gem) vs current tree — byte-identical expected at the
   `--budget 60000` protocol, quiet machine (see material-fields memory: 15s
   budgets give frame-count-skew speckle; do not chase it).
2. **New equivalence**: spectral on + dispersion 0 vs spectral off, one diffuse
   scene and one glass scene — byte-identical expected (the resolve guard
   short-circuits; no random consumed).
3. **The point of it all**: seahorse and marble with spectral on + dispersion
   > 0 — confetti gone entirely (no dispersive interfaces on those paths);
   converged blur-means match the non-spectral render.
4. **Rainbows intact**: prism and gem by eye — spectral bands unchanged (their
   caustic paths resolve at the first glass refraction, which is where all the
   λ-dependence already lived); backgrounds and walls now clean instead of
   speckled, so both demos converge visibly faster.
5. **λ-TIR stress**: a grazing-glass scene (cocktail / bottleLiquid) with
   spectral on, checked for NaN/black-pixel artifacts — exercises the
   `vRefract` TIR fallback at resolved wavelengths.

## Future extensions (out of scope)

- The grazing energy-split reweight (one line, above) if precision at glancing
  dispersive interfaces ever matters.
- Per-λ absorption (`exp(-absorb(λ)·d)`) — physically real (why emeralds are
  green), would resolve λ at the first *absorbing dispersive* medium entry;
  needs a λ-dependent absorb model first, and belongs to the same "volume
  fields" family as material-fields.md tier 3.
- Spectral sky/lights — same lazy-resolution pattern would apply.
