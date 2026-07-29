//-------------------------------------------------
// VARIETY FORMULAS — escudero
// STANDARD FLOAT GLSL, from the published form (algVariety-reference.md):
// transpiled to dual code, gate-verified per run (variety-builder §6.5).
//
// Escudero's nonic. Never ported to the hand-T catalogue — the transpiler
// makes its size a non-event. (The reference's Escudero9_2 is its
// hand-written affine patch: skipped, the generator derives the patch.)
//-------------------------------------------------

float escudero9(float x, float y, float z, float w){
    float alpha = sqrt(3.0);
    float x2 = x*x;
    float x3 = x2*x;
    float x4 = x2*x2;
    float x5 = x3*x2;
    float y2 = y*y;
    float y3 = y2*y;
    float y4 = y2*y2;
    float y5 = y3*y2;
    float z2 = z*z;
    float z3 = z2*z;
    float z5 = z3*z2;
    float w2 = w*w;
    float w3 = w2*w;
    float w4 = w2*w2;
    float w5 = w3*w2;

    float P = w5*((27.0*x2 - w2)*w2 - 9.0*(w + 6.0*x)*x3)
            + x5*((36.0*w + 21.0*x)*w3 - (9.0*(3.0*w2 - w*x) + x2)*x2)
            + alpha*(81.0*(2.0*x2 - w2)*w4 - (54.0*(w + 1.5*x)*w2 + 9.0*(x - 6.0*w)*x2)*x3)*x2*y
            + ((27.0*w2*(w + x) - 72.0*(1.5*w + x)*x2)*w4 + (w2*(225.0*w + 27.0*x) + 36.0*x2*(x - 3.5*w))*x4)*y2
            + alpha*((27.0*w3 + (108.0*w + 180.0*x)*x2)*w3 - (135.0*w2 + (126.0*w - 84.0*x)*x)*x4)*y3
            + ((-54.0*w2 - 108.0*w*x - 45.0*x2)*w3 + (135.0*w2 - 126.0*x2)*x3)*y4
            + (alpha*(-54.0*(w + x)*w3 - 27.0*w2*x2 - 126.0*(w + x)*x3)
               + (w2*(39.0*w + 81.0*x) + (126.0*w + 84.0*x)*x2)*y
               + alpha*9.0*(3.0*w2 + 6.0*w*x + 4.0*x2)*y2
               - 9.0*(w + x)*y3 - alpha*y4)*y5;

    float Q = (((27.0*z2 - 4.0*w2)*w2 - 9.0*(w + 6.0*z)*z3)*w5
             + ((36.0*w2 + (21.0*w - 27.0*z)*z)*w2 + (9.0*w - z)*z3)*z5)/4.0;

    return P - Q;
}
