//-------------------------------------------------
// VARIETY FORMULAS — togliatti
// dual-number defining equations T eqn(T x,T y,T z[,T w]); the engine (T
// arithmetic, DE, invStereo) lives in glsl/tracer/1Setup/dualNumbers.glsl.
// #include this file in a scene's objects.glsl to use: togliatti, togliattiStereo.
//-------------------------------------------------

T togliatti(T xorig, T yorig, T zorig, T w){

    //rotate coordinates
    T x = xorig, y = -zorig, z = yorig;
    //working in projective patch where w=1.;
    //T w = T(1,0);

    // squaring all the coordinates
    T x2 = tsqr(x), y2 = tsqr(y), z2 = tsqr(z), w2 = tsqr(w);

    T P1 = (x2 - 4.* tmul(x,w) - 10.*y2 - 4.*w2);
    T P2 = (16.*w2 - 20.*y2);

    T P = tmul(x2, P1) + tmul(tmul(x,w)+w2, P2) + 5.* tmul(y2, y2);
    T Q = 4.*(x2+y2-z2)+(1.+3.*sqrt(5.))*w2;
    T Q2 = tsqr(Q);
    T Qfin = tmul(2.* z - sqrt(5.-sqrt(5.)) * w,  Q2);
    T res =  64.*tmul(x-w, P) - 5.*sqrt(5.-sqrt(5.))*Qfin;
    return -res;

}


T togliatti(T xorig, T yorig, T zorig){
    return togliatti( xorig,  yorig,  zorig, T(1,0));
}

T togliattiStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return togliatti(X,Y,Z,W);
}
