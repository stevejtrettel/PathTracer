//-------------------------------------------------
// VARIETY FORMULAS — misc
// dual-number defining equations T eqn(T x,T y,T z[,T w]); the engine (T
// arithmetic, DE, invStereo) lives in glsl/tracer/1Setup/dualNumbers.glsl.
// #include this file in a scene's objects.glsl to use: gyroid, chmutov, kleinBottleVariety, riemannTwoBranch, enneper, goldman, mobiusStripVariety, mobiusStrip3TwistVariety, ellipticFibration, elliptic.
//-------------------------------------------------

T gyroid(T x, T y, T z){
    T term1 = tmul(tsin(x),tcos(y));
    T term2 = tmul(tsin(y), tcos(z));
    T term3 = tmul(tsin(z),tcos(x));
    return 1.*(term1 + term2 + term3);
}


T chmutov(T x, T y, T z) {
    int n = 2;
    return tcheb(x,n)+tcheb(y,n)+tcheb(z,n)+tfloat(1.0);
}


T kleinBottleVariety(T x, T y, T z){
    //order of input variables should be y,x,z for it laying on its side
    //ian stewart
   // (x^2+y^2+z^2+2*y-1)*((x^2+y^2+z^2-2*y-1)^2-8*z^2) +16*x*z*(x^2+y^2+z^2-2*y-1)=0
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T r2 =  x2 + y2 + z2;
    T term1 = r2 + 2.*y - T(1,0);
    T term2 = r2 - 2.*y - T(1,0);

    return tmul(term1, tsqr(term2) - 8.*z2) + 16.*tmul(x,z,term2);
}


T riemannTwoBranch(T x, T y, T z){
    //z^2*x^2+(z^2+1)*y^2=5*(z^4+z^2)

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T z4 = tsqr(z2);

    return tmul(z2,x2) + tmul(z2+T(1,0), y2) - 5.*(z4+z2);
}


T enneper(T x, T y, T z){

        //doesn't work well as a thickened surface, if we use the variety to thicken it
        //it gets unnaturally thick near the xy plane
        float a = 1.;
        float a2 = a*a;
        float a3 = a*a*a;
        T x2 = tsqr(x);
        T y2 = tsqr(y);
        T z2 = tsqr(z);
        T z3 = tmul(z2,z);

    T term1 = a/2.*(y2-x2) + 2./9.* z3 + 2./3.*a2*z;
    T term2 = a/4.*(y2-x2) - 1./4.*tmul(z,x2+y2+8./9.*z2) + 2./9.*a2*z;

    return -tmul(term1,term1,term1) + 6.*a3*tmul(z,term2,term2);

}





T goldman(T x, T y, T z){

    //free parameters, wired to the GUI scratch knobs
    float a = 2.*scratch1;
    float b = 2.*scratch2;
    float c = 2.*scratch3;
    float d = 2.*scratch4;
    float k = 4.-a*a-b*b-c*c-a*b*c*d;

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T xyz = tmul(x,tmul(y,z));


    T term1 = (a*b+c*d)*x + (a*d+b*c)*y + (a*c+b*d)*z + T(k,0);
    T term2 =x2 + y2 + z2 + xyz;

    return term2-term1;

}


//================================
// MOBIUS BANDS
//================================


T mobiusStripVariety(T x, T y, T z){

    //https://www.imaginary.org/sites/default/files/moebiusband.pdf

    float a = 0.02;
    float b = 0.6;
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T t2 = x2+y2;

    T term1 = (a-b)*(tmul(x,t2-z2+T(1,0))-2.*tmul(y,z));
    T term2 = (2.*a + 2.*b + a*b)*t2;
    T term3 = (a+b)*(t2+z2+T(1,0));
    T term4 = 2.*(a-b)*(tmul(y,z)-x);

    T side1 = term1-term2;
    T side2 = (term3+term4);

    return -tsqr(side1)+tmul(t2,tsqr(side2));

}


T mobiusStrip3TwistVariety(T x, T y, T z){

    //https://www.imaginary.org/sites/default/files/moebiusband.pdf

    float a = 0.01;
    float b = 0.33;
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T t2 = x2+y2;
    T t4 = tsqr(t2);

    T comp1 = 3.*tmul(x2,y)-tmul(y2,y);
    T comp2 = tmul(x,x2)-3.*tmul(x,y2);

    T term1 = -2.*(a+b)*t4+(a-b)*(tmul(comp1, t2-z2+T(1,0))-2.*tmul(comp2,z));
    T term2 = (a+b)*tmul(t2, (t2+z2+T(1,0))) - 2.*(a-b)*(comp1 - tmul(z,comp2)) - 2.*a*b*t2;

    return - tsqr(term1) + tmul(t2,tsqr(term2));

}








T ellipticFibration(T x, T y, T t){
    //from nadir, universal family over X15
    //t x^2 - x^3 - t y + (1 - t) x y + y^2 = 0



    //map xy into a disk:
    float lengthScale = 3.5;
    T r = tsqrt(tsqr(x)+tsqr(y));
    T scalingFactor = tsqr(texp(r/lengthScale))+tsqr(texp(-r/lengthScale));
    scalingFactor -= T(2,0);
    x = tmul(x,scalingFactor);
    y = tmul(y,scalingFactor);


    t = tmul(t,t,t);
    t = t/10.;



    T x2 = tsqr(x);
    T x3 = tmul(x,x2);
    T y2 = tsqr(y);

    return tmul(t, x2) - x3 - tmul(t,y) + tmul(T(1,0)-t,x,y) + y2;
}




T elliptic(T x, T y, T t){
    //from nadir, universal family over X15
    //t x^2z - x^3 - t yz^2 + (1 - t) x yz + y^2z = 0

    //expand out the t-axis, shrinking the importance of larger values
    //T newT = tmul(t,t,t);
   // newT *= 10.;

    //shrink in the t axis from infinity: for t between -pi/2 and pi/2 shows whole line
    T newT = ttan(t);

    //use inverse stereographic projection to draw double cover
    //then, see only one piece by drawing only the lower hemisphere: where (x,y) is in the unit disk
    //for this to work both scale and bounding box should be set to size 1
    T X, Y, Z;
    invStereo(x,y,X,Y,Z);

    T X2 = tsqr(X);
    T Y2 = tsqr(Y);
    T Z2 = tsqr(Z);
    T X3 = tmul(X,X2);


    // // a test: a trivial family of ellptic curves
    // // and its inverse stereographic projection
    //return tsqr(y) - tmul(x,x,x)-tmul(x,x);
    //return -(tmul(Y2, Z) - X3 - tmul(X2,Z));

    //nadir's family
    return -(tmul(newT,X2,Z) - X3 - tmul(newT, Y, Z2) + tmul(T(1,0)-newT,tmul(X,Y,Z)) + tmul(Y2,Z));
}
