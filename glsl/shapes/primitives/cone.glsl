//----------------------------------------------------------------------------
// CONE — a truncated cone (frustum) standing on the y axis: `height` = HALF-
// height, `radiusLow` at the bottom, `radiusHigh` at the top. Equal radii give
// a cylinder; a zero top radius gives a true cone.
//
// IQ's exact capped cone. It is the profile component of the glassware —
// models/pint.glsl and models/bottleTorus.glsl are both built on it.
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// p is in the cone's own coordinates (origin at the centre of the axis, axis = y)
float coneDistance(vec3 p, float height, float radiusLow, float radiusHigh){
    vec2 q  = vec2(length(p.xz), p.y);
    vec2 k1 = vec2(radiusHigh, height);
    vec2 k2 = vec2(radiusHigh - radiusLow, 2.0*height);
    vec2 ca = vec2(q.x - min(q.x, (q.y < 0.0) ? radiusLow : radiusHigh), abs(q.y) - height);
    vec2 cb = q - k1 + k2*clamp(dot(k1 - q, k2)/dot(k2, k2), 0.0, 1.0);
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s*sqrt(min(dot(ca, ca), dot(cb, cb)));
}
