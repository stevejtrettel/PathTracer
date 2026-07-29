//-------------------------------------------------
// VARIETY FORMULAS — barthDecic
// STANDARD FLOAT GLSL, from the published form (algVariety-reference.md):
// transpiled to dual code, gate-verified per run (variety-builder §6.5).
//
// Barth's decic, 345 nodes. NOTE: the hand-T version carried a known
// "renders incorrectly somewhere" bug — it squared the (2 - φ) coefficient
// in the last factor; the published form (used here) does not.
//-------------------------------------------------

float barthDecic(float x, float y, float z, float w){
    float phi  = 0.5*(1.0 + sqrt(5.0));
    float phi4 = phi*phi*phi*phi;
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float w2 = w*w;
    float r2 = x2 + y2 + z2;
    float r4 = x2*x2 + y2*y2 + z2*z2;
    float cross = x2*y2 + x2*z2 + y2*z2;
    float p1 = 8.0*(x2 - phi4*y2)*(y2 - phi4*z2)*(z2 - phi4*x2)*(r4 - 2.0*cross);
    float t6 = r2 - w2;
    float t7 = r2 - (2.0 - phi)*w2;
    return p1 + (3.0 + 5.0*phi)*t6*t6*t7*t7*w2;
}
