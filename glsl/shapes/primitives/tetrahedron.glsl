//----------------------------------------------------------------------------
// TETRAHEDRON — a triangular pyramid standing on its base: 2*size tall, base
// side 1.73*size. NOT regular (a regular one that tall would have base side
// 2.45*size), and `size` is not its inradius, unlike the other platonics.
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
    //the tapered term's gradient is (0.866, 0.25, 0.5): length 1.0308, so it
    //overstated distance by 3% until divided back (the zero set is unchanged)
    float d = max(abs(q.y) - 0.5,
                  (max(abs(q.x)*0.866025 + q.z*0.5, -q.z) - 0.25*abs(0.5 - q.y))/1.0308);
    return 2.0*size*d;
}
