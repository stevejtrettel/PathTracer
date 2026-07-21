//-------------------------------------------------
// VARIETY FORMULAS — labs7
// dual-number defining equations T eqn(T x,T y,T z[,T w]); the engine (T
// arithmetic, DE, invStereo) lives in glsl/tracer/1Setup/dualNumbers.glsl.
// #include this file in a scene's objects.glsl to use: Labs7.
//-------------------------------------------------

//Septics
T Labs7(T x, T y, T z, T w){

    float a = -0.140106854987125;//the real root of 7*a^3+7*a+1=0
    //Constants
    float a1= -0.0785282014969835;//(-12./7.*a-384./49.)*a-8./7.;
    float a2= -4.1583605922880200;//(-32./7.*a+24./49.)*a-4.;
    float a3= -4.1471434889655100;//(-4.*a+24./49.)*a-4.;
    float a4= -1.1881659380714800;//(-8./7.*a+8./49.)*a-8./7.;
    float a5= 51.9426145948147000;//(49.*a-7.)*a+50.;

    // squaring all the coordinates
    T x2 = tsqr(x), y2 = tsqr(y), z2 = tsqr(z), w2 = tsqr(w);
    T x4 = tsqr(x2), y4 = tsqr(y2), z4 = tsqr(z2);
    T z6 = tmul(z2, z4);
    T r2 = x2+y2;

    T U = tmul(z+w,r2)+tmul(a1*z+a2*w,z2)+tmul(a3*z+a4*w,w2);
    U = tmul(z+a5*w,U,U);

    T P = tmul(x2-21.*y2,x4)+tmul(35.*x2-7.*y2,y4);
    P = tmul(x, P);
    P += tmul(z,7.*tmul(tmul(r2-8.*z2,r2) + 16.*z4, r2)-64.*z6);

    return U-P;
}




T Labs7(T x, T y, T z){
    return Labs7(x,y,z,T(1,0));
}
