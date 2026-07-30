//----------------------------------------------------------------------------
// ELLIPSOID — `radii` = the three semi-axes.
//
// IQ's APPROXIMATE ellipsoid: accurate near the surface, and a mild under/over-
// estimate elsewhere. There is no closed-form exact distance to an ellipsoid,
// so this is the standard compromise.
//
// It carries a bound even though it is cheap, and the bound is doing a SECOND
// job: the approximation degrades far from the surface (badly, for an elongated
// ellipsoid), so a marcher that reads the raw estimate at long range can
// overstep. The bounding sphere replaces the far field with an honest distance
// and only lets the estimate speak near the surface, where it is good.
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// p is in the ellipsoid's own coordinates (origin at the centre)
float ellipsoidDistance(vec3 p, vec3 radii){
    float k0 = length(p/radii);
    float k1 = length(p/(radii*radii));
    return k0*(k0 - 1.0)/max(k1, 1.0e-7);
}


// the bounding sphere: the largest semi-axis
float ellipsoidBound(vec3 p, vec3 radii){
    return length(p) - max(radii.x, max(radii.y, radii.z));
}
