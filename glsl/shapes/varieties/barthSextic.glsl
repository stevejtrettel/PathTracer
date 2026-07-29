//-------------------------------------------------
// VARIETY FORMULAS — barthSextic
// STANDARD FLOAT GLSL, from the published form (algVariety-reference.md):
// transpiled to dual code, gate-verified per run (variety-builder §6.5).
//
// Barth's sextic: 65 nodes in icosahedral symmetry. tau is the classic
// 1 + 2φ = 2 + √5 by default, and live if a scene wants to detune it.
//-------------------------------------------------

//@default barthSextic.tau 4.236068
float barthSextic(float x, float y, float z, float w, float tau){
    float phi  = 0.5*(1.0 + sqrt(5.0));
    float phi2 = phi*phi;
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float w2 = w*w;
    float p1 = 4.0*(phi2*x2 - y2)*(phi2*y2 - z2)*(phi2*z2 - x2);
    float r2 = x2 + y2 + z2 - w2;
    return tau*r2*r2*w2 - p1;
}

//the sextic under p -> 2p/(1 - p^2) — equivalent to the stereographic
//double cover but with the icosahedral symmetries preserved: the plane at
//infinity maps to the unit sphere, one copy inside, one outside
//(the algebra pre-simplified in the reference doc)
//@default barth6T.tau 4.236068
float barth6T(float x, float y, float z, float tau){
    float phi  = 0.5*(1.0 + sqrt(5.0));
    float phi2 = phi*phi;
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float r2 = x2 + y2 + z2;
    float m2 = 1.0 - r2;
    m2 = m2*m2;
    float n2 = r2 - 0.25*m2;
    n2 = n2*n2;
    return -(16.0*(phi2*x2 - y2)*(phi2*y2 - z2)*(phi2*z2 - x2) - tau*m2*n2);
}
