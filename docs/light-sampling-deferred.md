# Deferred sphere-light sampling (NEE)

The design for unbiased next-event estimation of sphere lights — worked out in
full, then deliberately not built (August 2026) because our small-light scenes
put their noise exactly where NEE is blind. Companion to
[material-system.md](material-system.md) (the event tree this hooks into),
[marching.md](marching.md) (the transport the shadow ray reuses), and
[scene-authoring.md](scene-authoring.md) (the contract a `lights:` declaration
would extend).

> TL;DR — the tracer is already Monte Carlo with the sampling pdf *defined to
> be* the material, which is why light sampling bolts on with exactly one new
> closed-form number: the solid angle of the light's cone. Diffuse bounces
> sample the light directly (one shadow march, contribution
> `path.light · Le · V · cosθ · 2(1−cosθmax)`), and diffuse rays stop seeing
> lights at hits — `path.type == 1` is already the double-count guard, no MIS,
> no weights. Correct **for the diffuse lobe only**, in **open air only**.
> Deferred because in our actual scenes (bottle/cocktail + small light for
> floor caustics) the caustic is the slowest-converging region and NEE cannot
> touch it — the regions NEE accelerates were never the bottleneck. Revive for
> scenes where full-frame direct-light speckle, not a caustic, sets the clock.

## Why it fits at all: the system is secretly standard MC

The "naive" framing — materials are probability distributions, no sampling
weights anywhere — is not outside Monte Carlo; it is Monte Carlo with the pdf
matched to the BRDF so `f/pdf` collapses to the tint. The diffuse lobe proves
it: `normalize(normal + randomVector)` is exactly cosine-weighted sampling,
Lambert is `albedo/π`, the pdf is `cosθ/π`, and the quotient is the single
`path.light *= diffuse` in `updateFromSurface`. Light sampling does not break
this story; it adds one alternative pdf whose quotient is *also* closed-form.

That same observation draws the hard boundary:

- **Diffuse lobe**: `f = albedo/π` is evaluable → exact NEE possible.
- **Specular / coat / transmit**: the Gaussian-facet sampler IS the material;
  there is no evaluable `f(ωin, ωout)` to price a light-direction sample.
  Any NEE there is a guess = bias. These lobes keep finding lights by
  hitting them, unchanged.

## The estimator: solid-angle cone sampling

For a sphere light (center `c`, radius `R`, radiance `Le`) seen from a shading
point `p` with `d = |c−p| > R`, the light subtends a cone:

    sinθmax = R/d        cosθmax = sqrt(1 − (R/d)²)
    Ω = 2π(1 − cosθmax)

Sample a direction **uniformly in that cone** (pdf = 1/Ω): draw `u,v`,
set `cosθ = 1 − u(1−cosθmax)`, `φ = 2πv`, build in a tangent frame around the
unit vector toward `c`. Every direction in the cone geometrically hits the
sphere, and a uniform emitter radiates `Le` along all of them, so the
estimator is exact — no 1/r², no cosine-at-the-light, no singularity near
contact. (Uniform *area* sampling of the sphere surface is strictly worse:
half the samples land on the back side and the geometry term blows up near
contact. Rejected.)

The contribution, with the weight worked through (`cosθs` = cosine at the
shading surface, `V` = visibility):

    estimate = f · cosθs · Le · V / pdf
             = (albedo/π) · cosθs · Le · V · Ω
             = albedo · Le · V · cosθs · 2(1 − cosθmax)

Hooked in **after** `updateFromSurface`, `path.light` already carries the
albedo, so the whole thing is:

    path.pixel += path.light * Le * V * cosθs * 2.*(1. - cosMax);

One scalar, from geometry. It adds to `pixel` only — `path.light` is never
touched, so the throughput ≤ 1 invariant (which the spectral roulette fix
depends on) survives. The factor can exceed 1; that is fine, it is terminal
radiance, not carried throughput.

## The double-count rule — and why `path.type` makes it weight-free

Stated as one physical rule, not a patch: **diffuse rays no longer see light
sources; instead, every diffuse bounce looks at the lights directly.**

- **Add**: run the light sample only when the scatter *chose* the diffuse
  branch (`path.type == 1`).
- **Suppress**: in `updateFromSurface`, skip the `emit` add when
  `path.type == 1 && dat.hit ∈ LIGHT_IDS`.

Two facts make this exact rather than merely tidy:

1. **Gating on the chosen event preserves the energy bookkeeping.** The
   effective diffuse reflectance here is `p_diffuse · albedo/π` — the lobe
   probability IS the energy fraction (scatter.glsl's contract). Firing NEE
   only when the branch was selected picks up `p_diffuse` through the branch
   probability itself, exactly matching the term being suppressed at hit
   time. Firing at every hit instead would require multiplying by
   `p_diffuse` explicitly — the sampling-weight machinery the event tree
   exists to avoid.
2. **The suppression is exactly complementary.** Paths reaching the light
   via specular, coat, transmit, or any bounce after the diffuse vertex
   arrive with `type ≠ 1` and still add emission — and NEE never covered
   those. Nothing counts twice; nothing is lost. Undeclared emitters are
   never suppressed, so they behave exactly as today.

Note the mirror case is handled for free: diffuse vertex → mirror → light
arrives as type 2, not suppressed, and NEE at the diffuse vertex did not
cover the reflected connection. And diffuse → glass → light arrives as
type 3: the shadow ray treated the glass as an occluder (added 0), the hit
adds the emission — the direct term and the refracted term partition cleanly.

## Loop integration

A `directLight(path)` beside `updateFromSurface`/`updateFromSky`, called from
`pathTrace` after `updateFromSurface` and **before** `roulette` (the 1/p boost
applies only to the continuation; the NEE add is not subject to termination).
`scatter()` has already flowed the ray off the surface by `10·EPSILON`, so
`path.tv.pos` is the shadow-ray origin as-is; `path.dat.normal` is still live.

```glsl
void directLight(inout Path path){
    if(path.type != 1){ return; }          //diffuse lobe only (see boundary above)
    if(path.region != ID_NONE){ return; }  //open-air vertices only (see gates below)

    //pick one light uniformly; multiply the contribution by NUM_LIGHTS
    Light L   = LIGHTS[lightIndex];
    vec3 toC  = L.center - path.tv.pos;
    float d2  = dot(toC, toC);
    if(d2 <= L.radius*L.radius){ return; } //inside the light: hits handle it

    float cosMax = sqrt(1. - L.radius*L.radius/d2);
    Vector shadow = Vector(path.tv.pos, coneSample(normalize(toC), cosMax));

    float cosS = dot(shadow.dir, path.dat.normal.dir);
    if(cosS <= 0.){ return; }              //below the horizon contributes 0

    //visibility = the SAME transport as stepForward: analytic stop + march.
    //tLight is the exact ray/sphere distance; unoccluded, the march lands ON
    //the light there, so visible == landing within the marcher's tolerance.
    float tLight = raySphere(shadow, L.center, L.radius);
    float t = raytrace(shadow, tLight);
    t       = raymarch(shadow, t);
    if(t < tLight - AT_THRESH){ return; }

    path.pixel += float(NUM_LIGHTS) * path.light * L.emit
                  * cosS * 2.*(1. - cosMax);
}
```

Cost: one extra bounded sphere-trace per diffuse bounce — comparable to a
transport segment. What it buys: today a cosine sample finds a small light
with probability ~`(R/d)²` (a radius-0.7 light at distance 12 → ~1 hit in
300 samples, i.e. severe full-frame speckle); with NEE the direct term
converges at O(1) regardless of light size.

The structural cost is permanent and worth naming: this is the first second
ray in the tracer. Today "the path is the only ray" is an invariant; after
this, every future transport feature must answer "what does the shadow ray do
about me?" (media and fog already forced the answer below: it doesn't exist
there).

## Scene contract

There is no light list today — emission is a surface field. NEE needs scene
knowledge, declared once (each value once, per the materials rule):

- The scene description declares `lights: [{center, radius, emit}]` (or the
  generator derives the entry from a `sphereLight` preset flagged for
  sampling). The generator emits the `LIGHTS` array, `NUM_LIGHTS`, the
  `LIGHT_IDS` set for the suppression check, **and** the light objects'
  materials from that single declaration — the sampled `Le` and the surface's
  `emit` cannot drift apart.
- Everything is inside `#ifdef SCENE_LIGHTS` (the `SCENE_SUBSURFACE`
  pattern): scenes that declare nothing compile byte-identical, same random
  stream, and the render-test gate never notices. Declared scenes consume
  extra randoms, so their streams differ by construction — their baselines
  are new.

## Correctness gates (code) and contract rules (docs)

One runtime check, everything else a documented contract:

- **Code**: NEE fires only at open-air vertices (`path.region == ID_NONE`).
  This one condition subsumes vertices inside absorbing or scattering media.
- **Code**: skip when inside the light sphere (`d ≤ R`); clamp `cosS` at 0.
- **Contract**: *scenes that declare sampled lights are plain-air scenes* —
  no ODE media (straight shadow segments are meaningless where light bends),
  no ambient fog (the shadow ray would owe the fog its transmittance), no
  unrendered pass-through shells around lights (the shadow march counts them
  as occluders even though transport does not).
- **Contract**: *declare only bare lights.* A light enclosed in glass gets
  V = 0 from every shadow ray — still unbiased (no type-1 segment can reach
  it directly, so the suppression never fires either) but every march is
  wasted. Enclosed lights simply stay undeclared and work exactly as today.
- Anything crossing a *surface* is an occluder, full stop — NEE replaces only
  the direct, unrefracted connection, which is what makes the partition with
  hit-found emission exact.

Deliberately refused, forever if need be: MIS (light-sampling-only is never
the high-variance strategy for a pure Lambert lobe — the classic MIS failure
case is glossy lobes, which are excluded by the BRDF boundary), power-weighted
light selection (uniform × N is unbiased; revisit only if many-light scenes
appear), non-sphere lights, NEE through refraction.

## Why deferred (August 2026)

The scenes that motivated this are bottle/cocktail glass with a small sphere
light, composed *for the floor caustic*. A frame is done when its
slowest-converging region looks good, and in that archetype:

- The directly lit floor/walls — what NEE fixes — converge slowly today but
  DO converge within any accumulation long enough for the caustic.
- The caustic and the glass shadow it sits in get essentially no direct light
  (the bottle blocks the shadow rays; V = 0 is correct there). Their light
  arrives via floor → glass → light chains, which NEE structurally cannot
  sample. That region converges at exactly today's rate no matter what.

The caustic is the hero — the light is small precisely to keep it crisp, so a
bigger dimmer light is not a workaround — and it sets the clock. NEE would
clean the surroundings early and then wait on the caustic anyway: **net effect
on time-to-beautiful-image ≈ zero**, for the price of the second-ray concept,
the scene contract, and a shadow march per diffuse bounce. There is also a
perceptual kicker: a clean floor makes the still-sparkling caustic read as
*noisier* mid-accumulation.

Accelerating the caustic itself means sampling the refracted connection:
manifold NEE (Newton iteration on the interface — research-grade on
sphere-traced SDFs), photon mapping, or bidirectional transport. Each inverts
or doubles the architecture; none fit this system. Firefly clamping is biased.
The caustic strategy remains: let it accumulate.

## When to revive

The moment the wait is **full-frame direct-light speckle rather than a
caustic**: dramatic small-point-light scenes that are diffuse-dominated —
harsh single-bulb lighting, fractal/variety geometry under a tiny key light,
anything where the glass is incidental or absent. For those scenes NEE is
transformative (the ~1-in-300 hit rate above becomes O(1)), and the design
here can be built as specified without re-derivation. Build the minimal
version and refuse the extensions.

## Verification plan (when built)

1. **Off-switch frozen**: full render-test pass with no scene declaring
   lights — byte-identical expected (everything is `#ifdef`'d out; the
   `--budget 60000` / quiet-machine protocol from the material-fields notes).
2. **The oracle**: the naive estimator IS the unbiased reference. One scene
   with and without its `lights:` declaration, both run long — converged
   blur-means must match. This is the direct test of the double-count rule
   (a guard bug shows up as ~2× direct light, invisible by eye without the
   A/B).
3. **The point of it all**: a small-bare-light diffuse scene, declared —
   direct-lit surfaces smooth at a small fraction of today's budget.
4. **Partition test**: a glass object between light and floor — caustic and
   glass-shadow regions match the undeclared render's converged means
   (V = 0 + hit-found emission must reproduce them exactly).
5. **Edge sweep**: camera/vertex inside a declared light (skip path), light
   grazing the horizon (cosS clamp), two lights (uniform pick × N).
