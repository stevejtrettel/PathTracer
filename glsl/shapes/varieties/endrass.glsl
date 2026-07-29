//-------------------------------------------------
// VARIETY FORMULAS — endrass
// STANDARD FLOAT GLSL, from the published forms (algVariety-reference.md):
// transpiled to dual code, gate-verified per run (variety-builder §6.5).
//
// Endrass' octics, 168 nodes: the two Galois-conjugate surfaces (the ±√2
// roots). The hand catalogue carried only the plus root.
//-------------------------------------------------

float endrassOctic(float x, float y, float z, float w){
    float s2 = sqrt(2.0);
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float w2 = w*w;
    float r2 = x2 + y2;
    float U = 64.0*(x2 - w2)*(y2 - w2)*((x + y)*(x + y) - 2.0*w2)*((x - y)*(x - y) - 2.0*w2);
    float V = -4.0*(1.0 + s2)*r2*r2 + (8.0*(2.0 + s2)*z2 + 2.0*(2.0 + 7.0*s2)*w2)*r2
            + z2*(-16.0*z2 + 8.0*(1.0 - 2.0*s2)*w2) - (1.0 + 12.0*s2)*w2*w2;
    return V*V - U;
}

float endrassOcticMinus(float x, float y, float z, float w){
    float s2 = sqrt(2.0);
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float w2 = w*w;
    float r2 = x2 + y2;
    float U = 64.0*(x2 - w2)*(y2 - w2)*((x + y)*(x + y) - 2.0*w2)*((x - y)*(x - y) - 2.0*w2);
    float V = -4.0*(1.0 - s2)*r2*r2 + (8.0*(2.0 - s2)*z2 + 2.0*(2.0 - 7.0*s2)*w2)*r2
            + z2*(-16.0*z2 + 8.0*(1.0 + 2.0*s2)*w2) - (1.0 - 12.0*s2)*w2*w2;
    return V*V - U;
}
