//-------------------------------------------------
// VARIETY FORMULAS — misc
// STANDARD FLOAT GLSL defining equations: the generator transpiles each
// into one-pass dual-number code, and `gen.mjs --equations` verifies the
// arithmetic on every run (docs/variety-builder.md §6.5).
//
// 3-ary (x, y, z) = affine. Trailing parameters are scene knob hooks;
// //@default holds the classic values. (chmutov lives in chebyshev.glsl
// with the rest of its family.)
//-------------------------------------------------

float gyroid(float x, float y, float z){
    return sin(x)*cos(y) + sin(y)*cos(z) + sin(z)*cos(x);
}

//Ian Stewart's Klein bottle (order the inputs y, x, z to lay it on its side):
//  (r2 + 2y - 1)((r2 - 2y - 1)^2 - 8z^2) + 16xz(r2 - 2y - 1)
float kleinBottleVariety(float x, float y, float z){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float r2 = x2 + y2 + z2;
    float term1 = r2 + 2.0*y - 1.0;
    float term2 = r2 - 2.0*y - 1.0;
    return term1*(term2*term2 - 8.0*z2) + 16.0*x*z*term2;
}

//z^2 x^2 + (z^2 + 1) y^2 = 5(z^4 + z^2)
float riemannTwoBranch(float x, float y, float z){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    return z2*x2 + (z2 + 1.0)*y2 - 5.0*(z2*z2 + z2);
}

//the enneper surface (a = 1). Does not thicken well near the xy plane.
float enneper(float x, float y, float z){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float z3 = z2*z;
    float term1 = 0.5*(y2 - x2) + 2.0/9.0*z3 + 2.0/3.0*z;
    float term2 = 0.25*(y2 - x2) - 0.25*z*(x2 + y2 + 8.0/9.0*z2) + 2.0/9.0*z;
    return -term1*term1*term1 + 6.0*z*term2*term2;
}

//Goldman's quartic family — the four moduli were wired to scratch knobs in
//the hand catalogue; they are honest parameters now
//@default goldman.a 1.0
//@default goldman.b 1.0
//@default goldman.c 1.0
//@default goldman.d 1.0
float goldman(float x, float y, float z, float a, float b, float c, float d){
    float k = 4.0 - a*a - b*b - c*c - a*b*c*d;
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float term1 = (a*b + c*d)*x + (a*d + b*c)*y + (a*c + b*d)*z + k;
    float term2 = x2 + y2 + z2 + x*y*z;
    return term2 - term1;
}

//https://www.imaginary.org/sites/default/files/moebiusband.pdf
//@default mobiusStripVariety.a 0.02
//@default mobiusStripVariety.b 0.6
float mobiusStripVariety(float x, float y, float z, float a, float b){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float t2 = x2 + y2;
    float term1 = (a - b)*(x*(t2 - z2 + 1.0) - 2.0*y*z);
    float term2 = (2.0*a + 2.0*b + a*b)*t2;
    float term3 = (a + b)*(t2 + z2 + 1.0);
    float term4 = 2.0*(a - b)*(y*z - x);
    float side1 = term1 - term2;
    float side2 = term3 + term4;
    return -side1*side1 + t2*side2*side2;
}

//the 3-twist band, same source
//@default mobiusStrip3TwistVariety.a 0.01
//@default mobiusStrip3TwistVariety.b 0.33
float mobiusStrip3TwistVariety(float x, float y, float z, float a, float b){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float t2 = x2 + y2;
    float t4 = t2*t2;
    float comp1 = 3.0*x2*y - y2*y;
    float comp2 = x2*x - 3.0*x*y2;
    float term1 = -2.0*(a + b)*t4 + (a - b)*(comp1*(t2 - z2 + 1.0) - 2.0*comp2*z);
    float term2 = (a + b)*t2*(t2 + z2 + 1.0) - 2.0*(a - b)*(comp1 - z*comp2) - 2.0*a*b*t2;
    return -term1*term1 + t2*term2*term2;
}

//Nadir's universal family over X15: t x^2 - x^3 - t y + (1 - t) x y + y^2,
//the fiber coordinate riding z (the hand catalogue named it t). The xy
//plane is compressed into a disk first, and the fiber parameter is cubed
//and damped so the interesting fibers spread along the axis.
float ellipticFibration(float x, float y, float z){
    float lengthScale = 3.5;
    float r = sqrt(x*x + y*y);
    float su = exp(r/lengthScale);
    float sd = exp(-r/lengthScale);
    float scalingFactor = su*su + sd*sd - 2.0;
    float xs = x*scalingFactor;
    float ys = y*scalingFactor;
    float t = z*z*z/10.0;
    float x2 = xs*xs;
    float y2 = ys*ys;
    return t*x2 - x2*xs - t*ys + (1.0 - t)*xs*ys + y2;
}

//the same family drawn on its double cover: the xy plane lifts to the
//sphere by inverse stereographic projection (inlined — plain algebra), and
//tan() pulls the whole fiber line into the visible z range
float elliptic(float x, float y, float z){
    float t = tan(z);
    float denom = x*x + y*y + 1.0;
    float X = 2.0*x/denom;
    float Y = 2.0*y/denom;
    float Z = (x*x + y*y - 1.0)/denom;
    float X2 = X*X;
    float Y2 = Y*Y;
    float Z2 = Z*Z;
    float X3 = X*X2;
    return -(t*X2*Z - X3 - t*Y*Z2 + (1.0 - t)*X*Y*Z + Y2*Z);
}
