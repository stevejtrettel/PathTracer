//----------------------------------------------------------------------------
// DOUBLECONE — an hourglass: two cones meeting at a point at the origin, each
// `height` tall and flaring to `radius` at its open end. Total extent is
// 2*height along y.
//
// PARAMETRIZED IN THE PORT. The legacy objects/basic/doubleCone.glsl hardcoded
// a ~45-degree half-angle, a height of 2, and a waist sitting at y = 1 rather
// than at the origin (an artefact of mirroring an already-offset cone). This
// takes the same shape and gives it real parameters, centred.
//
// Built by folding y and evaluating ONE cone — the fold is exact (a reflection
// is an isometry, and the shape is symmetric), and the crease it leaves at
// y = 0 is the hourglass's genuine pinch, not an artefact.
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// p is in the hourglass's own coordinates (origin at the waist, axis = y)
float doubleConeDistance(vec3 p, float height, float radius){
    vec3 q = opSymY(p);                                              //fold to y >= 0
    return coneDistance(q - vec3(0.0, 0.5*height, 0.0), 0.5*height, 0.0, radius);
}


// the bounding sphere: the rim of an open end, at (radius, height)
float doubleConeBound(vec3 p, float height, float radius){
    return length(p) - length(vec2(radius, height));
}
