//----------------------------------------------------------------------------
// CYLINDER — a capped cylinder standing on the y axis: `radius` across,
// `height` = HALF-height, `rounded` = the rim fillet (0 = sharp edges).
//
// TWO functions, and they are not interchangeable:
//
//   cylinderDistance   the exact rounded capped cylinder (IQ). This is the
//                      shape — lib.cylinder — and what a solid should call.
//   cylinderSlab       max(radial, axial): exact INSIDE, an underestimate
//                      outside the rim. Cheaper (no sqrt) and conservative, so
//                      it is a legal BOUNDING volume, which is all it is used
//                      for — the glassware's <stem>Bound functions.
//
// Folding the two together would silently retune every bound in the library
// (docs/shape-library.md §3), so they stay a pair.
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// p is in the cylinder's own coordinates (origin at the centre, axis = y).
// Built by rotating a rounded 2D box about the axis.
float cylinderDistance(vec3 p, float radius, float height, float rounded){
    vec2 q = vec2(length(p.xz), p.y);
    vec2 b = vec2(radius - rounded, height);

    vec2  w = abs(q) - b;
    float g = max(w.x, w.y);
    float l = length(max(w, 0.0));
    return ((g > 0.0) ? l : g) - rounded;
}


// the cheap conservative form: the intersection of the radial and axial slabs.
// Never overestimates, so it is safe as a bounding sdf.
float cylinderSlab(vec3 p, float radius, float height){
    float r = length(p.xz) - radius;
    float h = abs(p.y) - height;
    return max(r, h);
}
