//----------------------------------------------------------------------------
// OPS · CURVE — a tube around the curve where two implicit surfaces cross.
//
// Vocabulary: always compiled (glsl/shapes/_vocabulary.glsl). Depends on nothing
// but GLSL. See docs/shape-library.md §1.
//
// Given two scalar fields f and g, the set {f = 0} and {g = 0} are surfaces and
// {f = 0} ∩ {g = 0} is a CURVE. This draws a tube of the given radius around it.
// Neither field has to be anything in particular — the two commonest uses are:
//
//   a variety and its clip shape   the visible EDGE where a surface is cut off
//                                  (this is what the cubic surface's "boundary
//                                  ring" is, generalized)
//   two varieties                  the curve where two surfaces meet each other
//
// THE CONSTRUCTION, and the one step that is easy to get wrong. The naive
// estimate is
//     sqrt(dist_to_f^2 + dist_to_g^2)
// which is right only where the two surfaces meet at a RIGHT ANGLE. The fix is
// to measure f's distance not in space but ALONG g's surface: flatten f's
// gradient into g's tangent plane first, and the pair of distances becomes
// genuinely perpendicular, so combining them by Pythagoras is correct to first
// order at any crossing angle.
//
//     n  = normalize(grad g)          g's normal
//     t  = grad f - (grad f . n) n    f's gradient, flattened into {g = 0}
//     df = |f| / |t|                  distance to {f = 0} measured along {g = 0}
//     -> 0.5*(sqrt(df*df + g*g) - radius)
//
// The 0.5 is an UNDERSTEP, not part of the maths: Pythagoras on two first-order
// distance estimates can overshoot where either surface curves sharply, and a
// marcher that oversteps a thin tube goes straight through it. Halving is the
// tuned-by-eye safety factor the original carried; it costs march steps and buys
// not losing the curve.
//
// WHAT THE CALLER SUPPLIES, and why. Value AND gradient of both fields. The
// variety machinery already hands back vec4(gradient, value) for any equation,
// so f is free; g's gradient is the part our shape library does not expose,
// since shapes publish distance and not gradient. For the shapes anyone
// actually clips with it is a one-liner:
//
//     sphere of radius R at the origin   g = length(q) - R,  grad g = normalize(q)
//     axis-aligned box, half-widths h    g = boxDistance(q, h)
//                                        grad g = normalize(max(abs(q) - h, 0.0)
//                                                           * sign(q))   (outside)
//     anything else                      4-tap it, as the normals do
//
// FUTURE US — the version that does not need this. The nice form would be a
// chain modifier, `edgeTube(clip(variety(...), {to: sphere}), {radius})`, with
// the generator wiring both fields up for you. What blocks it today is that the
// modifier chain passes DISTANCES between stages: the variety's gradient does
// not survive past the base, and the clip shape's gradient is never computed at
// all. Making it work means keeping both fields alive through the chain, which
// is real generator surgery — worth doing on the evidence of a second and third
// caller, not the first. Until then this function is the whole mechanism, and it
// is deliberately general enough that promoting it later changes call sites
// only, never the maths.
//----------------------------------------------------------------------------


// a tube of `radius` around {f = 0} ∩ {g = 0}.
//   fVal, fGrad   the first field's value and gradient at the point
//   gVal, gGrad   the second field's value and gradient at the point
// Fields may be in any units, as long as both are evaluated at the same point.
float opCurveTube(float fVal, vec3 fGrad, float gVal, vec3 gGrad, float radius){
    vec3  n = normalize(gGrad);
    vec3  t = fGrad - dot(fGrad, n)*n;        //f's gradient, flattened into {g = 0}
    float df = abs(fVal)/max(length(t), 1.0e-6);
    return 0.5*(sqrt(df*df + gVal*gVal) - radius);
}
