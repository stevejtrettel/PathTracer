//-------------------------------------------------
// VARIETY FORMULAS — cubics
// STANDARD FLOAT GLSL defining equations: the generator transpiles each
// into one-pass dual-number code, and `gen.mjs --equations` verifies the
// arithmetic (value, gradient, homogeneity, fitted degree) on every run
// (docs/variety-builder.md §6.5, docs/equation-transpiler.md).
//
// 3-ary (x, y, z) = affine. 4-ary (x, y, z, w) homogeneous = projective,
// drawable as the stereo double cover or the generated w = 1 patch.
// Trailing parameters are scene knob hooks; //@default holds the classic
// values, which bake when a scene omits the parameter.
//-------------------------------------------------

//a cubic with no genus: a singular point, pushed off the zero set by `offset`
//  x^2 y + y^2 z + z^2 x = offset
//@default cubicTrivial.offset 0.1
float cubicTrivial(float x, float y, float z, float offset){
    return x*x*y + y*y*z + z*z*x - offset;
}

//x^3 + y^3 + z^3 = x + y + z
float cubicGenus(float x, float y, float z){
    return x*x*x + y*y*y + z*z*z - (x + y + z);
}

//the Clebsch diagonal cubic — all 27 real lines
float clebschCubic(float x, float y, float z){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    return 81.0*(x2*x + y2*y + z2*z)
         - 189.0*(x2*y + x2*z + y2*x + y2*z + z2*x + z2*y)
         + 54.0*x*y*z + 126.0*(x*y + x*z + y*z)
         - 9.0*(x + y + z) + 1.0;
}

//Cayley's nodal cubic: (x² + y² + z²)·w + 2xyz − w³
//https://en.wikipedia.org/wiki/Cayley%27s_nodal_cubic_surface
float cayleyNodalCubic(float x, float y, float z, float w){
    return (x*x + y*y + z*z)*w + 2.0*x*y*z - w*w*w;
}

//a hand-tuned cubic, kept from the hand catalogue
float myCubic(float x, float y, float z, float w){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float w2 = w*w;
    return 24.0*x*y*z - 30.0*y2*z - 15.0*y*z2
         - 24.0*x2*w + 50.0*y2*w + 42.0*y*z*w + 6.0*z2*w
         + 64.0*x*w2 - 95.0*y*w2 - 28.0*z*w2
         - 10.0*w2*w;
}
