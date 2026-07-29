//----------------------------------------------------------------------------
// BOTTLETORUS — a torus base and a capped-cone neck, smooth-unioned and hollowed
// to a glass shell (a decanter-ish ring bottle).
//
// glsl/shapes/ is the math-only library. Built from sdTorus + sdCappedCone +
// opMin/Max/OnionDist (glsl/objects/computations.glsl, globally included).
//----------------------------------------------------------------------------


// p is in the bottle's own coordinates (origin at the torus centre).
float bottleTorusDistance(vec3 p, float outer, float inner, float height,
                          float base, float flare, float smoothing, float thickness){
    vec3  conePos = p - vec3(0.0, outer + inner + height, 0.0);
    float torusD  = sdTorus(p, outer, inner);
    float neck    = sdCappedCone(conePos, 0.8*height, base, flare*base);
    float solid   = opMinDist(torusD, neck, smoothing);     //smooth union
    float shell   = opOnionDist(solid, thickness);          //hollow to a wall
    float top     = conePos.y - 1.7;                         //chop the neck open
    return opMaxDist(shell, top, thickness);
}


// bounding cylinder over the whole ring + neck
float bottleTorusBound(vec3 p, float outer, float inner, float height, float thickness){
    return bCyl(p, vec2(outer + inner + thickness + 0.3,
                        outer + inner + height + 2.5 + thickness));
}
