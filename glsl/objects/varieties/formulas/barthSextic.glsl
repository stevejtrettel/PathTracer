//-------------------------------------------------
// VARIETY FORMULAS — barthSextic
// dual-number defining equations T eqn(T x,T y,T z[,T w]); the engine (T
// arithmetic, DE, invStereo) lives in glsl/tracer/1Setup/dualNumbers.glsl.
// #include this file in a scene's objects.glsl to use: barthSextic, sexticStereo.
//-------------------------------------------------

T barthSextic(T x, T y, T z){

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    float phi1=(1.+sqrt(5.))/2., phi2=phi1*phi1;

    T term1 = 4.*tmul(phi2*x2-y2, phi2*y2-z2, phi2*z2-x2);
    T term2 = (1.+2.*phi1) * tmul(x2+y2+z2-T(1,0),x2+y2+z2-T(1,0));

    return -(term1-term2);
}


T barthSextic(T x, T y, T z, T w){

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T w2 = tsqr(w);
    float phi1=(1.+sqrt(5.))/2., phi2=phi1*phi1;

    T term1 = 4.*tmul(phi2*x2-y2, phi2*y2-z2, phi2*z2-x2);
    T term2 = (1.+2.*phi1) * tmul(tsqr(x2+y2+z2-w2),w2);

    return -(term1-term2);
}

T sexticStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return barthSextic(X,Y,Z,W);
}
