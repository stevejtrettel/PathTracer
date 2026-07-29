//-------------------------------------------------
// VARIETY FORMULAS — labs7
// STANDARD FLOAT GLSL, from the published form (algVariety-reference.md):
// transpiled to dual code, gate-verified per run (variety-builder §6.5).
//
// Labs' septic — 99 nodes, the record for degree 7. The a-constants derive
// from the real root of 7a³ + 7a + 1 = 0 (precomputed, comments hold the
// closed forms).
//-------------------------------------------------

float Labs7(float x, float y, float z, float w){
    //a = -0.140106854987125, the real root of 7a^3 + 7a + 1 = 0
    float a1 = -0.0785282014969835;      //(-12/7 a - 384/49) a - 8/7
    float a2 = -4.1583605922880200;      //(-32/7 a + 24/49) a - 4
    float a3 = -4.1471434889655100;      //(-4 a + 24/49) a - 4
    float a4 = -1.1881659380714800;      //(-8/7 a + 8/49) a - 8/7
    float a5 = 51.9426145948147000;      //(49 a - 7) a + 50
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float w2 = w*w;
    float r2 = x2 + y2;
    float U = (z + w)*r2 + (a1*z + a2*w)*z2 + (a3*z + a4*w)*w2;
    U = (z + a5*w)*U*U;
    float P = x*((x2 - 21.0*y2)*x2*x2 + (35.0*x2 - 7.0*y2)*y2*y2);
    P = P + z*(7.0*((r2 - 8.0*z2)*r2 + 16.0*z2*z2)*r2 - 64.0*z2*z2*z2);
    return U - P;
}
