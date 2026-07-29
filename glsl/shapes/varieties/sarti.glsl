//-------------------------------------------------
// VARIETY FORMULAS — sarti
// STANDARD FLOAT GLSL, from the published forms (algVariety-reference.md):
// transpiled to dual code, gate-verified per run (variety-builder §6.5).
//
// Sarti's octic (144 nodes) and dodecic (600 nodes) — the bipolyhedral
// symmetry family. (The dodecic file used to be sarti12.glsl; the family
// shares a home now.)
//-------------------------------------------------

//x^8+y^8+z^8+w^8 + 14(x^4(y^4+z^4+w^4) + y^4(z^4+w^4) + (zw)^4)
//  + 168(xyzw)^2 - 9/16 (x^2+y^2+z^2+w^2)^4
float sarti8(float x, float y, float z, float w){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float w2 = w*w;
    float x4 = x2*x2;
    float y4 = y2*y2;
    float z4 = z2*z2;
    float w4 = w2*w2;
    float r2 = x2 + y2 + z2 + w2;
    return x4*x4 + y4*y4 + z4*z4 + w4*w4
         + 14.0*(x4*(y4 + z4 + w4) + y4*(z4 + w4) + z4*w4)
         + 168.0*x2*y2*z2*w2
         - 9.0/16.0*r2*r2*r2*r2;
}

float sarti12(float x, float y, float z, float w){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    float w2 = w*w;
    float l1 = x2*x2 + y2*y2 + z2*z2 + w2*w2;
    float l2 = x2*y2 + z2*w2;
    float l3 = x2*z2 + y2*w2;
    float l4 = y2*z2 + x2*w2;
    float l5 = x*y*z*w;
    float s10  = l1*(l2*l3 + l2*l4 + l3*l4);
    float s11  = l1*l1*(l2 + l3 + l4);
    float s12  = l1*(l2*l2 + l3*l3 + l4*l4);
    float s51  = l5*l5*(l2 + l3 + l4);
    float s234 = l2*l2*l2 + l3*l3*l3 + l4*l4*l4;
    float s23p = l2*(l2 + l3)*l3;
    float s23m = l2*(l2 - l3)*l3;
    float s34p = l3*(l3 + l4)*l4;
    float s34m = l3*(l3 - l4)*l4;
    float s42p = l4*(l4 + l2)*l2;
    float s42m = l4*(l4 - l2)*l2;
    float q  = x2 + y2 + z2 + w2;
    float q3 = q*q*q;
    float Q12 = q3*q3;
    float S12 = 33.0*sqrt(5.0)*(s23m + s34m + s42m) + 19.0*(s23p + s34p + s42p) + 10.0*s234
              - 14.0*s10 + 2.0*s11 - 6.0*s12 - 352.0*s51 + 336.0*l5*l5*l1 + 48.0*l2*l3*l4;
    return 22.0*Q12 - 243.0*S12;
}
