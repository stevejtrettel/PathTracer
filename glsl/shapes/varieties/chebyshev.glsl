//-------------------------------------------------
// VARIETY FORMULAS — the Chebyshev family
// STANDARD FLOAT GLSL: transpiled to dual code, gate-verified per run
// (docs/variety-builder.md §6.5). The loops are counted, so the transpiler
// takes them as written.
//
// One helper serves the family: chebH(s, w, n) is the HOMOGENIZED
// Chebyshev polynomial w^n·T_n(s/w) by the standard recurrence (t0 rides
// one degree below t1, so each step raises the degree by one). At w = 1 it
// is plain T_n.
//-------------------------------------------------

float chebH(float s, float w, int n){
    float t0 = 1.0;
    float t1 = s;
    float w2 = w*w;
    for(int i = 1; i < n; i++){
        float t = 2.0*s*t1 - t0*w2;
        t0 = t1;
        t1 = t;
    }
    return t1;
}

float powInt(float b, int n){
    float r = 1.0;
    for(int i = 0; i < n; i++){ r = r*b; }
    return r;
}

//the classic Chmutov quartic: T4(x) + T4(y) + T4(z) + 1
float chmutov(float x, float y, float z){
    return chebH(x, 1.0, 4) + chebH(y, 1.0, 4) + chebH(z, 1.0, 4) + 1.0;
}

//the octic, homogeneous with a free constant (mu·w^8)
//@default chmutov8.mu 1.0
float chmutov8(float x, float y, float z, float w, float mu){
    return chebH(x, w, 8) + chebH(y, w, 8) + chebH(z, w, 8) + mu*powInt(w, 8);
}

//the WHOLE family: degree n on an int knob — homogeneous, so both views
//@default chmutovN.n 6
float chmutovN(float x, float y, float z, float w, int n){
    return chebH(x, w, n) + chebH(y, w, n) + chebH(z, w, n) + powInt(w, n);
}
