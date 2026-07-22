# The material system: a concrete plan

A ground-up rethink of the naive material model. Phase 1 is the **mechanism**
— the event tree and the Surface/Medium split — chosen to span the widest
range of physically-correct-looking effects while staying categorical.
Naming, constructors, and presets are consequences and come later (§7).
Companions: [material-fields.md](material-fields.md),
[curved-light-blackhole.md](curved-light-blackhole.md).
Status: **proposal, nothing implemented.**

> TL;DR — four ideas, in dependency order:
> **(1) One microfacet per event**: roughness = jitter the normal once,
> then run *deterministic* Fresnel/reflect/refract off the jittered normal.
> This is microfacet theory with the sampling deleted — one mechanism blurs
> reflection, refraction, and Fresnel itself, correctly coupled.
> **(2) Surface/Medium split, with IOR on the Medium**: a Material is a
> Surface response + an interior Medium; Fresnel comes from the *ratio of
> adjacent media*, which makes multi-material interfaces compositional.
> **(3) Transmission owns the interior**: crossing the interface hands the
> ray to the Medium — ballistic if clear (glass), walking if scattering
> (SSS), with Fresnel/TIR at the boundary from inside. The `subSurface`
> bool disappears; glass is the ballistic limit of marble.
> **(4) A coat tier**: one optional white Fresnel lobe above everything —
> car paint, lacquered metal, wet stone, varnished wood.

---

## 1. The constitution (unchanged)

At every interaction one uniform random number selects one discrete event;
**the event's probability is exactly its energy fraction**, so no 1/p
weights exist anywhere and throughput only ever picks up tints (invariant:
throughput ≤ 1 between roulettes). Fresnel *reshapes* probabilities rather
than weighting lobes; spectral rides along as one wavelength per ray;
roulette is capped at 1 so it only boosts. Volumes are the same idea in 1D:
exponential free path, Beer as continuous tint.

Anything that needs a sampling weight is out of scope by definition.

## 2. The physical picture that organizes the design

Two observations from real optics pick the architecture:

**Diffuse reflection is not fundamental.** Lambertian "paint" is what a
scattering interior looks like when the mean free path is too short to
bother simulating: light crosses the interface, rattles around, and exits
near where it entered, tinted by what the interior didn't absorb. So the
diffuse lobe is best understood as **the analytic shortcut for an interior
too dense to walk** — which puts matte paint, frosted glass, marble, milk,
and clear glass on a *single* axis (interior mfp: 0 → finite → ∞) instead
of in three unrelated mechanisms. The shortcut stays (walking wall paint
would be absurd); what changes is that it's a *limit* of the real thing,
and the real thing is always available by turning one knob.

**IOR is a bulk property, not a surface property.** Fresnel at an
interface is determined by the *two media* touching it. Putting `ior` on
the Medium makes every interface — object-in-air, glass-behind-liquid,
liquid-in-glass — the same computation: `fresnel(mediumA.ior/mediumB.ior)`.
The current `setMaterialInterface` current/neighbor/dominant juggling is
what you get when IOR lives on the material and each case is hand-branched.

So:

> **A Material = a Surface (everything angular, at the interface) + an
> interior Medium (everything with units of 1/length, plus ior). Surfaces
> are boundaries between media. The tracer alternates surface events and
> medium transport.**

```glsl
struct Surface {                  // consumed AT an interface, per event
    vec3  diffuse;                // tint of the diffuse shortcut
    vec3  specular;               // base specular tint: F0 for conductors, white else
    float gloss;                  // artistic Fresnel floor (0 = fully physical)
    float roughness;              // microfacet jitter — shared by ALL base lobes
    float transmit;               // fraction of non-reflected light that crosses
    vec3  transmitTint;           // tint on crossing (white; for THIN surfaces — lampshades)
    float coat;                   // 0 = none, 1 = full clearcoat (fixed n=1.5)
    float coatRoughness;
    vec3  emit;
};

struct Medium {                   // consumed ALONG a segment
    float ior;                    // index (dispersed via iorAt; fields via indexField)
    vec3  absorb;                 // Beer extinction, 1/length
    vec3  emit;                   // volume emission,  1/length
    float mfp;                    // scatter mean free path (maxDist = ballistic)
    float scatterBlur;            // phase width: 0 = forward, 1 = isotropic
};

struct Material { bool render; Surface surf; Medium interior; };
```

Every interaction is then a triple **(Surface, Medium out, Medium in)**.
Object-in-air: out = ambient (a real Medium at last — fog and glow become
scene properties, not fake objects). Multi-material: the boundary owner
supplies the Surface, the two volumes supply the physics. The thin
two-sided variety surfaces are a Surface with *no* interior (their
back-color machinery stays library-side).

## 3. The event tree

```
r ~ U[0,1)                        n  = geometric normal
                                  mc = jitter(n, coatRoughness)      [if coat > 0]
                                  m  = jitter(n, roughness)          ← ONE microfacet, reused

TIER 1 · COAT              P = Fc = coat · schlick(1.5, angle vs mc)
    → reflect off mc, WHITE tint. The wet/lacquered look.

TIER 2 · BASE SPECULAR     P = (1-Fc) · F,   F = mix(gloss, 1, fresnel(nOut/nIn, angle vs m))
    → reflect off m, tint = surf.specular (+ conductor grazing whitening)

TIER 3 · CROSS             P = (1-Fc)(1-F) · transmit
    → refract THROUGH m into the interior Medium, tint = transmitTint
      · mfp = ∞  : ballistic — today's glass, unchanged
      · finite   : the walk — with Fresnel/TIR at the boundary from inside (§5)
      · thin surf: pass through (roughness 1 = Lambertian transmission = paper)

TIER 4 · DIFFUSE           P = (1-Fc)(1-F)(1-transmit)
    → cosine hemisphere, tint = surf.diffuse   (the dense-interior shortcut)
```

Four event types — one more than today — and Tiers 2–4 have exactly the
current semantics (`gloss` = specularChance, `transmit` = refractionChance),
so the whole existing scene corpus maps over mechanically. What's new is
the coat tier, the microfacet, and where transmission *goes*.

### Why these lobes and no others

Checked against the effects catalogue (§6): this tree, plus the Medium,
covers essentially everything a naive tracer can render convincingly. The
candidates that were considered and rejected: anisotropic brushed-metal
highlights (needs tangent frames threaded through every object), sheen/
velvet (a grazing-diffuse tint — fakeable by eye if ever wanted, not worth
a knob), retroreflection, diffraction/opal, and any importance-sampled
light lobe (explicit non-goal). Thin-film iridescence needs **no new
lobe**: under hero-wavelength spectral it is a λ- and angle-dependent
replacement for schlick() in Tier 2 on a thin surface — a future drop-in
(`F_film(cosθ, λ, thickness)`), same tree.

## 4. One microfacet per event (the roughness upgrade)

Today roughness blends the outgoing direction toward the diffuse one
(`mix(dir, diffuseDir, rough²)`). It works, but it's a post-hoc blur:
reflection and refraction are fudged separately (refract blends toward the
*negated* diffuse direction), and Fresnel always sees the smooth normal.

The naive-native version of microfacet theory: **sample one random
microfacet normal `m` per event, then do everything deterministically off
`m`** —

```
m = normalize(mix(n, randomDir, roughness²))     // by-eye tunable jitter
```

- Fresnel is evaluated against `m` → the probabilities themselves get
  rough. Rough surfaces physically soften and *jitter* their Fresnel;
  grazing highlights stop being knife-edged.
- Reflect off `m` → glossy blur, same as now to first order.
- Refract through `m` → **rough glass becomes real ground glass** instead
  of a blend toward inverted-Lambert. TIR through a jittered normal
  happens naturally at grazing — that's precisely what makes the edges of
  ground glass glow bright, an effect the current fudge cannot produce.
- The coat uses its own jitter `mc` with `coatRoughness` — matte-over-
  glossy ("satin" coats) falls out for free.
- Hemisphere safety: if the outgoing ray lands under the geometric
  surface, flip it back across `n` (standard, weightless).

Still zero sampling weights: the microfacet is part of the *event*, not a
distribution we importance-sample. `roughness 1` should still degenerate
to (approximately) the diffuse lobe — verify by eye in an A/B demo scene,
since this visibly changes every rough material in the corpus. This is the
one piece of the plan that most wants its own demo scene before adoption
(two rows: mix-blur vs microfacet, roughness sweeping 0 → 1).

## 5. Transmission owns the interior (killing the subSurface hijack)

Today "enter the interior and walk" is a bool that *steals the diffuse
lobe*, and the walk exits the object with no Fresnel at the boundary.
Consequences: an SSS material can't also have a diffuse or frost
component; glass (ballistic, full TIR machinery) and marble (walk, no exit
Fresnel) are separate code paths that don't limit into each other.

New rule: **Tier 3 is the only door into the interior, and the Medium
decides what happens inside.**

- `mfp = ∞`: the ray refracts and flies — exactly today's glass path,
  byte-identical.
- `mfp` finite: the walk — but when a step crosses the boundary, evaluate
  the sdf normal there and run one Fresnel test from inside: with
  probability F, reflect back in and keep walking (TIR trapping — the
  glow-from-within saturation real wax and jade have); else refract out.
  As `mfp → ∞` this walk *is* the glass path: the continuum closes, and
  "glass vs marble" becomes a knob, not an architecture.
- The walk stays the specialized cheap version (`inside_Object` test +
  bisection) — the boundary Fresnel adds one sdf-gradient normal per exit
  attempt, not a full raymarch per step. Routing walk steps through the
  main loop is the "pure" endpoint; it stays on the shelf for cost.
- Spectral synergy: `mfp` and `absorb` may read `waveLength` like
  everything else — wavelength-dependent free paths (milk's blue edge,
  juice) come free with spectral on, no new machinery.

This is a look change for every SSS scene — which is fine, because the SSS
baselines are already owed a re-tune since the direction-normalization fix;
the two land together.

**Ambient medium** (the other payoff of Medium): the engine's hardcoded
"air" becomes a scene-suppliable Medium via the established hook pattern
(`#ifndef SCENE_AMBIENT_MEDIUM` → vacuum). In `stepForward`'s straight
branch, sample `d ~ Exp(mfp)`; if `d` beats the surface distance, the
segment ends in a scatter event instead — fog, god rays, halos, glowing
air. Zero cost when unused. (Spatially varying density — `scatterField`,
Woodcock — is the designed next member per material-fields.md, later.)

## 6. Coverage: what the plan expresses

| effect | recipe (Surface ; Medium) |
|---|---|
| matte wall | diffuse only; — (physical version: ior 1.5 interior, free 4% sheen) |
| artistic gloss | gloss floor 0.04–0.5 (today's dielectric look, unchanged) |
| plastic | ior-1.5 interior, transmit 0 → Fresnel coat for free |
| metal / mirror | specular = F0, gloss 1; grazing whitening as today |
| brushed metal (isotropic) | + roughness (microfacet) |
| clear / tinted glass | transmit 1; ior + absorb, mfp ∞ |
| ground glass | + roughness (microfacet refraction — new look) |
| frosted / milky glass | transmit < 1 (diffuse remainder) |
| gem + fire | ior 2.42 + spectral (unchanged) |
| marble, wax, milk, jade, skin | transmit 1; mfp finite (+ exit TIR — new look) |
| porcelain | small transmit + warm diffuse + slight interior scatter |
| paper, leaves, lampshade | thin surface, transmit + roughness 1, transmitTint |
| car paint | coat over metal base |
| lacquered gold, varnished wood | coat over base (+ material fields for grain) |
| wet stone / wet anything | coat + hand-darkened diffuse |
| satin finish | coat with coatRoughness |
| soap bubble, oil slick | thin surface + F_film(λ) in Tier 2 (future drop-in) |
| fog, god rays, glowing air | ambient Medium |
| beer + foam | interior Medium; foam = mfp field (volume fields, later) |
| black hole, GRIN lens | Medium ior field (already built: indexField) |
| fire / glowing volumes | Medium emit (the shelved recipes get a home) |

Not covered, deliberately: velvet/sheen, anisotropic highlights,
diffraction, hair. Wrong side of the cost/looks line for this tracer.

## 6b. Extensions using MORE randomness (still weight-free)

The constitution was never really "one random number" — the tracer already
spends many per path (diffuse direction, free path, wavelength, roulette).
The true invariant: **every random draw comes from a distribution that IS
part of the definition (material/camera/physics), and no draw is ever
corrected by a weight.** Extra draws are legal under that rule, and open
two families:

**Family 1 — more randomness inside an event** (procedure-as-definition):

- **Multi-bounce microfacets** (composes with §4; best payoff): when the
  reflected ray lands below the geometric horizon, don't flip — draw a NEW
  facet and bounce again, picking up the specular tint each time, until
  escape (bounded loop). Naive rendition of multiple-scattering microfacet
  theory (Heitz 2016). Real effect the flip loses: **rough metals
  saturate** (grazing light takes several tinted inter-facet bounces) —
  rough gold goes richer, not grayer. Energy-conserving by construction.
- **Stochastic mixtures**: pick sub-material A/B with prob = coverage
  fraction (literally an energy fraction). Dusty metal, patina — and
  **metallic flake**: with prob f the hit is a tiny mirror with a randomly
  drawn orientation (another legal draw), else base paint. Real car-paint
  sparkle. (Frame-stable glitter = position-HASHED orientation → a
  material field, not randomness.)
- **Stochastic coverage**: surface exists at this hit with prob α, else
  pass through untouched. Cutout foliage; dissolve/fade as an artistic
  tool.

**Family 2 — more latent variables per path (the "hero-X" pattern)**: the
accumulation buffer integrates out ANY hidden variable you attach one
sample of to each path. Wavelength was the first; others that fit with
zero weights:

- **Fluorescence** — SKIPPED (user decision, July 2026): a wavelength that
  changes mid-path (prob = quantum yield, pump λ ~ absorption spectrum,
  pixel keeps eye-λ tint; blacklight = lights emitting where
  spectralWeight ≈ 0). Recorded for completeness; not pursuing.
- **Hero polarization** (shelf; design worked out): treat each path as a
  photon with a DEFINITE linear polarization axis; every Fresnel interface
  is a MEASUREMENT — s-axis = normalize(cross(dir, n)), collapse to pure
  s with prob cos²χ else pure p (Malus's law as a categorical draw), then
  use the EXACT Rs/Rp reflectance for the collapsed state as the specular
  probability (replaces Schlick; averages to exact unpolarized Fresnel,
  slightly better than Schlick). Entails: (1) the real cost — a
  parallel-transported polarization axis per bounce, with a normal-
  incidence degeneracy guard; (2) exact Rs/Rp dielectric formulas + one
  collapse draw in updateProbabilities; (3) depolarize at diffuse/volume
  events (resample axis); (4) a master switch like `spectral` (off =
  byte-identical); (5) metals collapse with Rs = Rp (complex conductor
  phase out of scope). Ordinary scenes: image unchanged, slightly noisier
  near Brewster. The payoff is a NEW material: a polarizing filter
  (transmit prob cos²(χ − filterAxis)) → sunglasses killing Brewster
  glare, crossed polarizers, the three-polarizer paradox (reproduced
  exactly — it IS the quantum mechanics), pile-of-plates. Polarized-sky
  reflections would additionally need Rayleigh polarization in the sky
  model. Linear only: no circular/TIR phase shifts (Fresnel rhomb) —
  those need Stokes/Mueller, out of scope; TIR may honestly depolarize.
- **Time**: one shutter instant per ray = motion blur (camera-side, same
  pattern).

What extra randomness does NOT unlock: NEE, MIS, sampled BRDF lobes — the
barrier is the corrective weight, not the number of draws.

Rank by payoff/effort: multi-bounce microfacets (rides on §4), then
flakes/mixtures; polarization is a self-contained shelf project whose
selling point is the polarizer-filter demo class, not realism of existing
scenes; fluorescence skipped.

## 7. Later phases (parked, agreed direction)

Phase 2/3 material — consequences of the mechanism, not drivers of it:
constructor/naming pass (`makeMatte`, `makeGloss` rename of makeDielectric,
`makeSubsurface` to kill the 15-scene boilerplate, `absorbFor(tint, depth)`
to kill the `30.*tealScatter` magic constants, `withCoat(mat)`, presets
wax/milk/jade/water/diamond); ambient-fog demo scene; thin-film specular;
volume fields. The July-2026 usage census that motivates these (what every
constructor is really used for, the dead `air()`, the beer-foam
`path.dat` pokes) lives in this doc's git history and the memory notes.

Small correctness fixes, independent of everything: the `0/0` NaN in
`updateProbabilities` when `specularChance == 1` (every pure metal; masked
only because the specular branch always wins); the swapped
normal/incident argument names at the `FresnelReflectAmount` call site
(harmless, `vDot` symmetric, but a trap).

## 8. Decisions — ALL APPROVED (July 22 2026)

Microfacet roughness (§4, judged via A/B demo), multi-bounce microfacets
(§6b), coat tier (§3), exit Fresnel/TIR on the walk (§5), IOR onto Medium +
interface-as-(Surface, MedA, MedB), ambient medium hook: **yes to all.**
Fluorescence: skipped. Polarization: shelf.

## 9. Implementation — CLEAN REWRITE (executed July 22 2026)

The first attempt layered the new mechanisms behind opt-in `#define` gates
so old scenes stayed byte-identical; that smeared branches across the
tracer and was rejected. The executed approach: **one model, clean files,
demos run, art scenes broken until migration.** Checkpoint commit
`3587709` precedes the rewrite.

**The file map (as built):**

`3Materials/`
- `material.glsl` — `Surface` + `Medium` + `Material{render, surf,
  interior}`; constructors `makeMatte / makeGloss / makeMetal(+named) /
  makePlastic / makeGlass / makeSubsurface / makeLight`, helper
  `absorbFor(tint, depth)`, modifier `withCoat(mat, coat, rough)`.
- `interaction.glsl` — `setInteraction(dat, Surface, Medium front, Medium
  back, normal, side)` owns all interface bookkeeping (IOR ratio from the
  two media, per-side `iorAt` dispersion — air is just the default
  Medium); thin wrappers `setObjectInAir` / `setSurfaceInMat` /
  `setMaterialInterface` keep the object library's call sites unchanged;
  `applyMaterial` (material fields) unchanged.
- `scatter.glsl` — the event tree: coat → specular → transmit → diffuse,
  one microfacet per event (shared by Fresnel and directions),
  multi-bounce specular, facet refraction. Transmit into a medium with
  `mfp < maxDist` raises `path.subSurface`.
- `path.glsl` — `LocalData{surf, IOR, reflect/refract absorb+emit, mfp,
  blur, normal, …}`; `Path` unchanged apart from comments.

`6Trace/`
- `mediumWalk.glsl` — the interior walk (per-step Beer + roulette,
  16-halving exit bisection) with Fresnel/TIR at the boundary from inside;
  the ballistic limit is the glass path.
- `ambient.glsl` — `ambientTransport()`: fog/god-rays behind the
  `SCENE_AMBIENT_MEDIUM` scene hook (engine default vacuum, compiles
  away). Hook contract: `ambientMFP/ambientBlur/ambientAbsorb/ambientEmit`.
- `pathTrace.glsl`, `stepForward.glsl` — restored to their original
  one-screen shapes; one call each into the two files above.

Deleted: `scatterPath.glsl`, `setImpactData.glsl`, `subSurfScatter.glsl`,
the `MICROFACET_ROUGHNESS`/`SSS_EXIT_FRESNEL` gates, the legacy mix-blur
roughness, the `subSurface` bool on Material, back colors, `air()`,
`setDielectric`-family in-place constructors.

**Demos (`demos/`, run these):** `roughSweep` (glass + gold roughness
sweep), `coat` (matte + gold, coat 0→1), `sssExit` (mfp sweep with
exit-Fresnel walk), `fog` (ambient hook). Twin A/B pages are gone — there
is one model; judgment is against memory/checkpoint renders.

**Migration (next, after the looks are approved):** sweep `scenes/` onto
the constructors (the census in git history maps old→new: makeDielectric
spec-0 walls → makeMatte, artistic gloss → makeGloss, the 15-scene SSS
recipe → makeSubsurface, absorb magic constants → absorbFor), rewire the
variety/multiMaterial libraries (`setSurfaceInMat` back-colors and the
dominant-roughness quirk were dropped), then the SSS re-tune + baseline
re-bake.
