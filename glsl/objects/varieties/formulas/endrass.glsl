//-------------------------------------------------
// VARIETY FORMULAS — endrass
// dual-number defining equations T eqn(T x,T y,T z[,T w]); the engine (T
// arithmetic, DE, invStereo) lives in glsl/tracer/1Setup/dualNumbers.glsl.
// #include this file in a scene's objects.glsl to use: endrassOctic, endrassStereo.
//-------------------------------------------------

T endrassOctic( T x, T y, T z, T w){

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T w2 = tsqr(w);
    T r2 = x2+y2, r4 = tsqr(r2);
    float s = sqrt(2.);

    T term1 = tmul((x2-w2),(y2-w2));
    T term2 = tsqr(x+y)-2.*w2;
    T term3 = tsqr(x-y)-2.*w2;
    T U = 64.*tmul(term1,term2,term3);

    T term4 = -4.*(1.+s)*r4;
    T term5 = (8.*(2.+s)*z2+2.*(2.+7.*s)*w2);
    T V = term4 + tmul(term5,r2);

    T term6 = (-16.*z2 + 8.*(1.-2.*s)*w2);
    T term7 = (1.+12.*s)*tsqr(w2);
    V = V + tmul(z2,term6) - term7;

    return tsqr(V)-U;
}

T endrassOctic(T x, T y, T z){
    return endrassOctic(x,y,z,T(1,0));
}


T endrassStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return endrassOctic(X,Y,Z,W);
}
