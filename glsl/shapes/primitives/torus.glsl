//----------------------------------------------------------------------------
// TORUS — standing up, symmetry axis = y. `ringRadius` is from the origin to
// the centre of the tube, `tubeRadius` is the tube itself.
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// p is in the torus's own coordinates (origin at the centre of the ring).
// The swizzle stands the ring up so its axis is y rather than z.
float torusDistance(vec3 p, float ringRadius, float tubeRadius){
    vec3  s = vec3(p.x, p.z, -p.y);
    float h = length(s.xz);
    return length(vec2(h - ringRadius, s.y)) - tubeRadius;
}
