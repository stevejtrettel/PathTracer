//----------------------------------------------------------------------------
// PINT — a pint glass: the smooth subtraction of two truncated cones (an outer
// wall and a slightly-raised inner cone carved out to leave the cavity).
//
// glsl/shapes/ is the math-only library. Built from coneDistance + smax
// (glsl/shapes/ops/ and 1Setup/math.glsl, always compiled).
// `pintCavity` is the interior, for a drink region in a group (beer).
//----------------------------------------------------------------------------


//the carved-out inner cone — the cavity surface (file-private shared source)
float pint_inner(vec3 p, float height, float base, float flare, float thickness){
    vec3 pIn = p - vec3(0.0, 2.0*thickness + 0.4, 0.0);
    return coneDistance(pIn, height + 0.2, base - thickness, flare*(base - thickness));
}


// p is in the pint's own coordinates (origin at the centre). The glass SHELL:
// the outer cone with the inner cone subtracted.
float pintDistance(vec3 p, float height, float base, float flare, float thickness){
    float outerWall = coneDistance(p, height, base, flare*base) - 0.1;
    return smax(outerWall, -pint_inner(p, height, base, flare, thickness), 0.1);
}


// the interior cavity — the drink volume, for `drink = max(pintCavity(q,...), q.y - level)`
float pintCavity(vec3 p, float height, float base, float flare, float thickness){
    return pint_inner(p, height, base, flare, thickness);
}


// bounding cylinder over the flared cone
float pintBound(vec3 p, float height, float base, float flare){
    return cylinderSlab(p, max(base, flare*base) + 0.3, height + 1.0);
}
