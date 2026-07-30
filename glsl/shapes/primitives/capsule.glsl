//----------------------------------------------------------------------------
// CAPSULE — a line segment a -> b thickened by `radius`: the exact distance to
// the segment, minus the radius.
//
// Exact everywhere and cheap (one clamp, two lengths), so it needs no bound —
// its own sdf already is one.
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// p, a and b are all in the capsule's own coordinates (IQ's rounded segment)
float capsuleDistance(vec3 p, vec3 a, vec3 b, float radius){
    vec3  pa = p - a;
    vec3  ba = b - a;
    float h  = clamp(dot(pa, ba)/dot(ba, ba), 0.0, 1.0);
    return length(pa - ba*h) - radius;
}
