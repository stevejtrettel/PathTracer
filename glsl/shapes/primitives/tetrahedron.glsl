//----------------------------------------------------------------------------
// TETRAHEDRON — a regular tetrahedron, `size` across.
//
// A cheap max form, NOT an exact distance: the horizontal half-space term is
// tapered by height (the `abs(0.5 - y)` factor), which is how a cheap taper is
// done, and it underestimates near the edges. Fine for marching, wrong if you
// wanted true distance.
//
// GAINED A `size` PARAMETER IN THE PORT — the legacy
// objects/basic/tetrahedron.glsl was locked to one size.
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// p is in the tetrahedron's own coordinates (origin at the centre).
// 0.866025 = cos(30 degrees).
float tetrahedronDistance(vec3 p, float size){
    vec3 q = 0.5*p/size;
    float d = max(abs(q.y) - 0.5,
                  max(abs(q.x)*0.866025 + q.z*0.5, -q.z) - 0.25*abs(0.5 - q.y));
    return 2.0*size*d;
}
