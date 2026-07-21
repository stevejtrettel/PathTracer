//-------------------------------------------------
// VARIETY FORMULAS — barthDecic
// dual-number defining equations T eqn(T x,T y,T z[,T w]); the engine (T
// arithmetic, DE, invStereo) lives in glsl/tracer/1Setup/dualNumbers.glsl.
// #include this file in a scene's objects.glsl to use: barthDecic, decicStereo.
//-------------------------------------------------

T barthDecic(T x, T y, T z, T w){

    //known issue: this formula renders incorrectly somewhere — not yet tracked down
    T x2 = tsqr(x), x4 = tsqr(x2);
    T y2 = tsqr(y), y4 = tsqr(y2);
    T z2 = tsqr(z), z4 = tsqr(z2);
    T w2 = tsqr(w), w4 = tsqr(w2);
    float phi1=(1.+sqrt(5.))/2., phi2=phi1*phi1,  phi4 = phi2*phi2;

    T term1 = (x2 - phi4 * y2);
    T term2 = (y2 - phi4 * z2);
    T term3 = (z2 - phi4 * x2);
    T term4 = ( x4 + y4 + z4 - 2.* tmul(x2,y2) - 2.* tmul(x2, z2) - 2.* tmul(y2, z2) );

    T term5 = (3.+5.*phi1)*w2;
    T term6 = (x2 + y2 + z2 - w2);
    T term7 = (x2 + y2 + z2 - (2.-phi1)*(2.-phi1)* w2);

    return 8.*tmul(term1,term2,term3,term4) + tmul(term5,tsqr(term6),tsqr(term7));

    //\begin{array}{c} 8 (x^2 – \Phi^4 y^2) (y^2 – \Phi^4 z^2) (z^2 – \Phi^4 x^2) \left( x^4 + y^4 + z^4 – 2 x^2 y^2 – 2 x^2 z^2 – 2 y^2 z^2\right) \\
    //+ (3 + 5 \Phi) w^2 \left( x^2 + y^2 + z^2 – w^2 \right)^2 \left( x^2 + y^2 + z^2 – (2-\Phi)^2 w^2)\right) = 0 \end{array}
    //
}


T barthDecic(T x, T y, T z){
    return barthDecic(x,y,z,T(1,0));
}

T decicStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return barthDecic(X,Y,Z,W);
}
