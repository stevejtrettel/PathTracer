//----------------------------------------------------------------------------
// BOTTLETORUS — a torus base and a capped-cone neck, smooth-unioned and hollowed
// to a glass shell (a decanter-ish ring bottle).
//
// glsl/shapes/ is the math-only library. Built from torusDistance + coneDistance +
// opSmoothUnion/Intersect/Onion (glsl/shapes/ops/, always compiled).
//----------------------------------------------------------------------------


// p is in the bottle's own coordinates (origin at the torus centre).
float bottleTorusDistance(vec3 p, float outer, float inner, float height,
                          float base, float flare, float smoothing, float thickness){
    vec3  conePos = p - vec3(0.0, outer + inner + height, 0.0);
    float torusD  = torusDistance(p, outer, inner);
    float neck    = coneDistance(conePos, 0.8*height, base, flare*base);
    float solid   = opSmoothUnion(torusD, neck, smoothing);     //smooth union
    float shell   = opOnion(solid, thickness);          //hollow to a wall
    float top     = conePos.y - 1.7;                         //chop the neck open
    return opSmoothIntersect(shell, top, thickness);
}


// bounding cylinder over the whole ring + neck
float bottleTorusBound(vec3 p, float outer, float inner, float height, float thickness){
    return cylinderSlab(p, outer + inner + thickness + 0.3,
                           outer + inner + height + 2.5 + thickness);
}
