// ---------- glsl/objects/shapes/curves/CurveDispatch.glsl ----------
#include "helixCurve.glsl"
#include "trefoilCurve.glsl"

// Implements the forward-declared functions from parametricCurve.glsl

vec3 curvePosDispatch(in ParametricCurve pc, float t) {
    if (pc.curveType == CURVE_HELIX)   return helixPos(t, /*R*/1.0, /*pitch*/0.25);
    if (pc.curveType == CURVE_TREFOIL) return trefoilPos(t);
    // fallback far away to avoid accidental hits
    return vec3(1e9);
}

float curveRadiusDispatch(in ParametricCurve pc, float t) {
    if (pc.radiusType == RAD_CONST) return pc.radius;
    if (pc.radiusType == RAD_TAPER) return helixRadiusTaper(t, pc.radius, /*k*/1.0);
    return pc.radius;
}
