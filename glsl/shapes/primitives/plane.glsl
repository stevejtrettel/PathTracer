//----------------------------------------------------------------------------
// PLANE — a half-space, seen from the side its normal points toward.
//
// Exact and analytic, so a ray never marches toward it — worth having, since
// the marched step is the PERPENDICULAR distance, which crawls on a ray running
// nearly parallel to the plane, and a ground plane is used at exactly that angle.
//
// CAVEAT, learned the hard way: an analytic plane is NOT a drop-in replacement
// for a floor term inside a fractal's own DE. Folding `min(p.z - h, dFractal)`
// into the estimator makes the floor CAP the fractal — it hides everything
// below it. Split that floor out into a plane object and rays fall straight
// through into the infinitely fine detail underneath, and the plane is never
// reached. Use this for a floor the scene genuinely owns.
//
// glsl/shapes/ is the math-only library: plain functions of a point and some
// floats. No structs, no Frame, no Material.
//----------------------------------------------------------------------------


// p is in the plane's own coordinates (origin ON the plane). Negative in the
// solid half-space behind it, positive in the open half-space it faces.
float planeDistance(vec3 p, vec3 normal){
    return dot(p, normal);
}


// Exact ray intersection, in world coordinates: the distance along tv to the
// plane, or maxDist if it is not in front of us. A ray running away from the
// plane, or parallel to it, never meets it — and costs nothing to find out.
float planeTrace(Vector tv, vec3 centre, vec3 normal){
    float dn = dot(tv.dir, normal);
    if(abs(dn) < 1.0e-9){ return maxDist; }     //parallel
    float t = -dot(tv.pos - centre, normal)/dn;
    if(t < 0.){ return maxDist; }
    return min(t, maxDist);
}
