//-------------------------------------------------
// VARIETY FORMULAS — togliatti
// STANDARD FLOAT GLSL, from the published forms (algVariety-reference.md):
// transpiled to dual code, gate-verified per run (variety-builder §6.5).
//
// The world-record quintics: Togliatti's 31-node surface (closed form) and
// the Dervish presentation (the five pentagonal planes explicit — the
// h-products). The reference's third variant (Togliatti5 with an overall
// factor Mu) is skipped: an overall factor cannot change a zero set.
//-------------------------------------------------

float togliatti(float x, float y, float z, float w){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float w2 = w*w;
    float q5 = sqrt(5.0 - sqrt(5.0));
    float P = x2*(x2 - 4.0*x*w - 10.0*y2 - 4.0*w2) + x*w*(16.0*w2 - 20.0*y2)
            + 5.0*y2*y2 + w2*(16.0*w2 - 20.0*y2);
    float Q = 4.0*(x2 + y2 - z2) + (1.0 + 3.0*sqrt(5.0))*w2;
    Q = (2.0*z - q5*w)*Q*Q;
    return 64.0*(x - w)*P - 5.0*q5*Q;
}

//the five planes at the fifth roots of unity, product form
float dervish(float x, float y, float z, float w){
    float ro = 0.25*(1.0 + 3.0*sqrt(5.0));
    float a  = -8.0/5.0*(1.0 + 1.0/sqrt(5.0))*sqrt(5.0 - sqrt(5.0));
    float c  = 0.5*sqrt(5.0 - sqrt(5.0));
    float h1 = x + z;
    float h2 = cos(1.2566371)*x - sin(1.2566371)*y + z;
    float h3 = cos(2.5132741)*x - sin(2.5132741)*y + z;
    float h4 = cos(3.7699112)*x - sin(3.7699112)*y + z;
    float h5 = cos(5.0265482)*x - sin(5.0265482)*y + z;
    float P = h1*h2*h3*h4*h5;
    float Q = x*x + y*y + ro*z*z - w*w;
    Q = (w + c*z)*Q*Q;
    return a*P + Q;
}
