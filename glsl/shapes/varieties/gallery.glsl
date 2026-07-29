//-------------------------------------------------
// VARIETY FORMULAS — gallery
// STANDARD FLOAT GLSL (un-transpiled from the hand-T catalogue — these art
// surfaces have no published-form entry in algVariety-reference.md):
// transpiled to dual code, gate-verified per run (variety-builder §6.5).
//
// The IMAGINARY / Herwig Hauser classics and friends, all affine 3-ary.
// https://www.imaginary.org/gallery/herwig-hauser-classic
//-------------------------------------------------

float sauermann(float x, float y, float z){
    //https://www.imaginary.org/gallery/algebraic-surfaces
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float a = 0.45;
    float b = 0.83;
    float term1 = (x2 + y2 + (z + a)*(z + a) - b)*(x2 + y2 + (z - a)*(z - a) - b);
    float term2 = (x2 + y2 + (z + a)*(z + a) - 1.0)*(x2 + y2 + (z - a)*(z - a) - 1.0);
    float term3 = (x2 + y2 + z2)*(x2 + y2 + z2*z2);
    float term4 = (x + y)*(x + y)*(x - y)*(x - y);
    float term5 = x*y*x*y;
    return term1*term2*term3 + term4*term5;
}

float sauermann2(float x, float y, float z){
    //-(z+1)(z^4-5z^3+6z^2+z-2)^2 + (x^2-1)(y^2-1)(x^4-2x^2(y^2+2)+y^4-4y^2+4)
    //(sign convention follows the hand catalogue)
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float x4 = x2*x2;
    float y4 = y2*y2;
    float z4 = z2*z2;
    float term2 = z4 - 5.0*z2*z + 6.0*z2 + z - 2.0;
    float term3 = (x2 - 1.0)*(y2 - 1.0);
    float term4 = x4 - 2.0*x2*(y2 + 2.0) + y4 - 4.0*y2 + 4.0;
    return (z + 1.0)*term2*term2 - term3*term4;
}

float sauermann3(float x, float y, float z){
    //the "nodal cubic" (despite the name it carries a z^4 term)
    float zf = -z;
    float x2 = x*x;
    float y2 = y*y;
    float z2 = zf*zf;
    float x3 = x*x2;
    float y3 = y*y2;
    float term1 = x3 + 3.0*x2*(y - 1.0);
    float term2 = -3.0*y2 - 3.0*x*y2;
    float band  = 1.0 + 2.0*zf - 4.0*z2;
    float term3 = -y3 + (1.0 + zf)*band*band;
    return -(term1 + term2 + term3);
}

//x^2 - x^3 + y^2 + y^4 + z^3 - z^4
float visavisVar(float x, float y, float z){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    return x2 - x2*x + y2 + y2*y2 + z2*z - z2*z2;
}

//y^2 = x^2 z^2 + x^3, implemented with x and y swapped
float kolibriVar(float x, float y, float z){
    float y2 = y*y;
    return x*x - y2*z*z - y2*y;
}

float whitneyUmbrella(float x, float y, float z){
    return x*x - z*z*y;
}

float irisVar(float x, float y, float z){
    float z2 = z*z;
    return x*x*y - y*y*z + z2*z2;
}

//x^2 + y^2 z^3 - z^4
float calyxVar(float x, float y, float z){
    float z3 = z*z*z;
    return x*x + y*y*z3 - z3*z;
}

//(x^2 - y^3)^2 = (z^2 - y^2)^3
float daisyVar(float x, float y, float z){
    float term1 = x*x - y*y*y;
    float term2 = z*z - y*y;
    return term1*term1 - term2*term2*term2;
}

//x^2 + y^2 + z^3 - z^2
float dingdongVar(float x, float y, float z){
    float z2 = z*z;
    return x*x + y*y + z2*z - z2;
}

//x^2 + y^2 + z^2 + c(x^2+y^2)(x^2+z^2)(y^2+z^2) = 1
//@default thistleVar.c 1500.0
float thistleVar(float x, float y, float z, float c){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    return x2 + y2 + z2 + c*(x2 + y2)*(x2 + z2)*(y2 + z2) - 1.0;
}

//(x^2 + y^2)^3 - x^2 y^2 (z^2 + 1)
float eistuteVar(float x, float y, float z){
    float x2 = x*x;
    float y2 = y*y;
    float t = x2 + y2;
    return t*t*t - x2*y2*(z*z + 1.0);
}

//y^2 + z^3 = z^4 + x^2 z^2
float herzVar(float x, float y, float z){
    float z2 = z*z;
    float z3 = z2*z;
    return y*y + z3 - z3*z - x*x*z2;
}

//https://www-sop.inria.fr/galaad/surface/steiner/index.html
float crossCapVar(float x, float y, float z){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float term1 = x2/0.5 + y2;
    float term2 = x2 + y2 + z2;
    return term1*term2 - 2.0*z*(x2 + y2);
}

//Steiner's Roman surface: x^2 y^2 + y^2 z^2 + z^2 x^2 - xyz
float romanSurfaceVar(float x, float y, float z){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    return x2*y2 + y2*z2 + z2*x2 - x*y*z;
}
