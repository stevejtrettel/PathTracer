//-------------------------------------------------
// VARIETY FORMULAS — kummer
// STANDARD FLOAT GLSL, from the published form (algVariety-reference.md):
// transpiled to dual code, gate-verified per run (variety-builder §6.5).
//
// Kummer's quartic — 16 nodes at muSqr > 1 (the classic picture); nice
// genus-3 surfaces below 1 (the hand catalogue's alternate value was 0.7).
// The modulus is LIVE now: knob it at the scene.
//-------------------------------------------------

//https://en.wikipedia.org/wiki/Kummer_surface
//@default kummer.muSqr 1.5
float kummer(float x, float y, float z, float w, float muSqr){
    float lambda = (3.0*muSqr - 1.0)/(3.0 - muSqr);
    float s2 = sqrt(2.0);
    float p = z - w + x*s2;
    float q = z - w - x*s2;
    float r = z + w + y*s2;
    float s = z + w - y*s2;
    float fmu = x*x + y*y + z*z - muSqr*w*w;
    return fmu*fmu - lambda*p*q*r*s;
}
