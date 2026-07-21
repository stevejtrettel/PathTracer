//-------------------------------------------------
// VARIETY FORMULAS — kummer
// dual-number defining equations T eqn(T x,T y,T z[,T w]); the engine (T
// arithmetic, DE, invStereo) lives in glsl/tracer/1Setup/dualNumbers.glsl.
// #include this file in a scene's objects.glsl to use: kummer, kummerStereo.
//-------------------------------------------------

T kummer(T x, T y, T z, T w){

    //moduli for the quartic:
    float muSqr=1.5; //(alternate value: 0.7)
    float Lambda = (3.* muSqr - 1.)/(3.-muSqr);

    T p = z - w + x * sqrt(2.);
    T q = z - w - x * sqrt(2.);
    T r = z + w + y * sqrt(2.);
    T s = z + w - y * sqrt(2.);

    //put a larger multiple of muSqr as the coefficient to get nice genus 3 surfaces for musqr<1
    float coef = 1.;
    T fmu = tsqr(x) + tsqr(y) + tsqr(z) - coef * muSqr * tsqr(w);
    T prod = tmul(p,q,r,s);

    return tsqr(fmu) - Lambda * prod;
}

T kummer(T x, T y, T z){
    return kummer(x,y,z,T(1,0));
}

T kummerStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return kummer(X,Y,Z,W);
}
