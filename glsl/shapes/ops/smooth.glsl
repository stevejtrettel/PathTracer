//----------------------------------------------------------------------------
// OPS · COMBINE — operators that act on a DISTANCE (or two).
//
// Vocabulary: always compiled (glsl/shapes/_vocabulary.glsl), callable from any
// shape file and from authored scene GLSL with no declaration. See
// docs/shape-library.md §1.
//
// Hard union and intersection are just min() and max() on the distances — they
// need no operator. What lives here is everything else: the SMOOTH versions,
// the shell, the offset, and the 2D->3D extrusion.
//
// NOTE the engine also has smin/smax (1Setup/math.glsl, polynomial form). Those
// are the ENGINE's; these are the library's blend operators and are the ones a
// shape should call. The two use different formulas and are not interchangeable.
//----------------------------------------------------------------------------


//SMOOTH UNION: min(a,b) with a blend of radius k (quadratic form)
float opSmoothUnion(float a, float b, float k){
    float h = max(k - abs(a - b), 0.0);
    float m = 0.25*h*h/k;
    return min(a, b) - m;
}


//SMOOTH INTERSECTION: max(a,b) with a blend of radius k
float opSmoothIntersect(float a, float b, float k){
    return -opSmoothUnion(-a, -b, k);
}


//SUBTRACTION: carve B out of A (the result's surface is A minus B)
float opSubtract(float a, float b){
    return max(a, -b);
}


//SMOOTH SUBTRACTION: the same, with a blend of radius k
float opSmoothSubtract(float a, float b, float k){
    return opSmoothIntersect(a, -b, k);
}


//ONION: keep a shell of half-width `thickness` around the surface, discarding
//the interior. Applied to a solid it hollows it out.
float opOnion(float d, float thickness){
    return abs(d) - thickness;
}


//ROUND: offset the surface outward by r, rounding every convex edge
float opRound(float d, float r){
    return d - r;
}


//EXTRUDE a 2D distance (in x,y) along z to a slab of half-height h. IQ's
//formula, with the slight rounding variant: a little nicer, a little slower.
float opExtrusion(float sdf2d, float pz, float h){
    const float sf = 0.028;
    vec2 w = vec2(sdf2d, abs(pz) - h) + sf;
    return min(max(w.x, w.y), 0.0) + length(max(w, 0.0)) - sf;
}
