# Kleinian limit sets — what `shapes/kleinian.glsl` actually draws

The estimator in [`glsl/shapes/kleinian.glsl`](../glsl/shapes/kleinian.glsl) is
Knighty's *pseudo-Kleinian* distance estimator (after Jos Leys' renderings).
This note says what the parameters mean mathematically, what the rendered
surface is, and which hyperbolic space the geometry lives in.

Everything marked **exact** below was checked numerically against the shader's
own arithmetic; everything marked **heuristic** is a fit, and is why the
estimator needs a per-box `fudge`.


## 1 · The group

Write the third coordinate as `w`, and identify the `xy`-plane with **C**,
ζ = x + iy. The fold applies three generators (**exact** — verified to 1e-10):

| in the shader | as a Möbius map of Ĉ |
|---|---|
| the sheared `klein_wrap` in x | **T**: ζ ↦ ζ + L,  L = 2·`box.x` |
| `z = (−b, a, 0) − z` | **σ**: ζ ↦ μ − ζ  (half-turn about μ/2) |
| `ir = 1/dot(z,z); z *= −ir; …` | **B**: ζ ↦ μ + 1/ζ |

with the single complex parameter

> **μ = −`kleinI` + i·`kleinR`**

⟨T, B⟩ = ⟨ζ ↦ ζ+L, ζ ↦ μ+1/ζ⟩ is the **Maskit-slice family** of *Indra's
Pearls*: punctured-torus groups sitting on the boundary of Teichmüller space.
`box.x` fixes the normalization (L = 2 is the textbook one); the two knobs are
the real and imaginary parts of the Maskit parameter.

The plane **w = 0 is exactly invariant** under the whole fold (verified: max
|w| = 0 over 20k orbits), so the classical two-dimensional picture is literally
the `w = 0` cross-section of the 3D object. The shader's generators are the
Poincaré extensions of the 2D maps composed with the mirror w ↦ −w, which is
harmless — it commutes with all of them.

**The third dimension** comes from one extra generator: `klein_wrap` also wraps
`w`, i.e. a transverse translation **U**: w ↦ w + 2·`box.z`. U does *not*
preserve the plane, and that is what turns a plane curve into a solid: the
limit set gets repeated along w and then curled around by the inversions.


## 2 · H³ or H⁴? Both, at different levels

Möb(**R**ⁿ ∪ ∞) ≅ Isom(Hⁿ⁺¹) — a conformal group of the n-sphere is the
isometry group of the hyperbolic space it bounds. So:

- **The classical part.** Γ₀ = ⟨T, σ, B⟩ acts on the plane w = 0 by Möbius
  maps, i.e. on Ĉ. It is a Kleinian group in the classical sense: a discrete
  subgroup of PSL(2,**C**) = Isom⁺(**H³**). The hyperbolic 3-space it acts on
  by isometries is the *half-space above the plane*, w > 0. Its limit set
  Λ(Γ₀) ⊂ Ĉ = ∂H³ is the classical limit-set curve. **You never see H³**: the
  render is drawn on its boundary.

- **The rendered object.** The full group Γ = ⟨T, U, σ, B⟩ moves w, so it is
  not an isometry group of that half-space. It is a discrete group of Möbius
  transformations of **R³** ∪ ∞ = S³, hence a subgroup of Isom(**H⁴**), and
  the **R³** the ray marcher walks through is ∂H⁴. Its limit set is a
  3-dimensional-looking fractal in that boundary.

So: *the mathematics of the curve is H³; the space you are rendering is the
boundary of H⁴.* The fourth dimension is the one that never appears on screen —
it is the direction "into" the space on which the group acts by isometries.

⚠ **Heuristic:** whether Γ (with U) is genuinely discrete is not established —
that is the "pseudo" in pseudo-Kleinian. Γ₀ alone certainly is.


## 3 · What the surface is

The estimator ends with

```glsl
float y  = min(z.y, a - z.y);        // distance to the planes y = 0 and y = a
float DE = min(y, 0.24)/max(DF, 1.0);
```

Those two planes are not arbitrary. Restricted to the boundary plane they are
the **real axis R and its image B(R)** — B(t) = μ + 1/t is real-shifted-by-μ
for real t, so B(R̂) is exactly the line Im ζ = `kleinR` (**exact**, checked).
So the DE measures distance to one orbit: **Γ·R̂**.

R̂ = **R** ∪ {∞} is a circle in Ĉ, and Möbius maps send circles to circles, so
the orbit is a family of **mutually tangent circles** — Indra's pearls. In 3D
the planes y = const are vertical, so their orbit is a family of **tangent
spheres**, and the solid being rendered is the union of the Γ-images of the two
half-spaces y ≤ 0 and y ≥ a (each image a ball). The fractal set on which those
spheres accumulate *is* the limit set Λ.

The distance itself is the standard fold-and-differentiate estimate: if g is
the composite map that folded p into the fundamental domain, then

  dist(p, Γ·R̂) ≈ dist(g(p), R̂) / |g′(p)|,

and `DF = ∏ 1/|zᵢ|²` is precisely that accumulated conformal derivative
|g′(p)| (each inversion in the unit sphere scales by 1/|p|²). `max(DF, 1)` and
`min(y, 0.24)` are safety clamps where the linearization stops being valid;
the trailing `DE·d²/(r + d·DE)` is the chain rule for the one-shot pre-inversion,
up to a constant the `fudge` absorbs.

⚠ **Heuristic:** the fold's separation line

```glsl
z.y >= a*0.5 + f*(2a-1.95)/4 * sign(z.x + b*0.5) * (1 - exp(-(7.2-(1.95-a)*15)*abs(z.x + b*0.5)))
```

is an *empirical fit* to the fundamental-domain wall, not the wall itself —
hence the magic 1.95 / 7.2 / 15, fitted over a ∈ [1.4, 2), which is also why the
knob ranges stop where they do. `fold` scales how far it bows from the flat
line y = a/2 (0 = flat).


## 4 · The parameters, as mathematics

| parameter | meaning |
|---|---|
| `kleinR`, `kleinI` | Im μ and −Re μ: the Maskit parameter, the group itself |
| `box.x` | L/2, the translation normalization (L = 2 is textbook Maskit) |
| `box.z` | half-period of the transverse translation U — the third dimension |
| `fold` | how far the approximate fundamental-domain wall bows |
| `inversionCenter`, `inversionRadius` | a one-shot Möbius change of viewpoint (see §5) |
| `size`, `offset` | scale, and which point of the fractal sits at the origin |
| `iterations` | how deep into the orbit — how close to Λ you resolve |
| `fudge` | marcher understep; pays for the heuristic wall |


## 5 · The two scenes

Both draw the same construction. They differ in the normalization, in where μ
sits, and — most visibly — in **viewpoint**, which is what the pre-inversion is:
a Möbius change of coordinates whose centre is the point everything infinitely
far away gets crushed onto.

**[`scenes/kleinian`](../scenes/kleinian/src/scene.js)** — L = 2 (textbook),
μ = −1.8 + 1.8i. Well inside the discreteness region, so Λ is a mild
quasicircle: fat round pearls, fractal beading only where they kiss, tiling off
to infinity in x and w. The inversion centre `(1, 0.96, 0)` lies *on* the
invariant plane, so the plane stays a plane and the picture stays unbounded.
Sweeping (R, I) walks the Maskit slice toward its fractal boundary — the pearls
shrink and the lace fines as you approach, and past it discreteness fails and
the image turns to noise.

**[`scenes/kleinianLimit`](../scenes/kleinianLimit/src/scene.js)** —
L = 1.6178 ≈ φ, μ = −0.1 + 1.89i: Jos Leys' seahorse, just off the real axis and
right up against the boundary, where the limit-set curve **spirals** into the
seahorse tails. And the inversion centre `(0, 1, 1)` is *off* the invariant
plane, so the plane w = 0 — the one carrying the classical curve — inverts into
a **sphere of radius 0.32 centred at (0, 1, 0.68)** in the fractal's own frame.
The infinite tiling is wrapped into a compact blob whose densest point is the
inversion centre itself, local (0,1,1) = world (0, 1, −2). That is what "the
compact limit set" means in the legacy scene.


## 6 · Reading

- Mumford, Series & Wright, *Indra's Pearls* — the Maskit slice, the pearls,
  the seahorse.
- Jos Leys' Kleinian galleries; Knighty's Fragmentarium `pseudo-Kleinian`
  formula, from which this DE descends (via the shadertoys credited in
  [`shapes/kleinian.glsl`](../glsl/shapes/kleinian.glsl)).
- The named parameter bundles: [`js/presets/fractals.js`](../js/presets/fractals.js).
