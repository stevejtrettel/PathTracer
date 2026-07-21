//-------------------------------------------------
// VARIETY FORMULAS — cubics
// dual-number defining equations T eqn(T x,T y,T z[,T w]); the engine (T
// arithmetic, DE, invStereo) lives in glsl/tracer/1Setup/dualNumbers.glsl.
// #include this file in a scene's objects.glsl to use: cubicTrivial, cubicGenus, clebschCubic, cayleyNodalCubic, myCubic, myCubicStereo.
//-------------------------------------------------

T cubicTrivial(T x, T y, T z){
    //a  cubic with no genus: singular point without offset
    // x^2*y+y^2*z+z^2*x=0.1

    float offset = 0.1;

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    return tmul(x2,y) + tmul(y2,z) + tmul(z2,x) - T(offset,0);

}


T cubicGenus(T x, T y, T z){
    //x^3+y^3+z^3=x+y+z
    T x3 = tmul(x,x,x);
    T y3 = tmul(y,y,y);
    T z3 = tmul(z,z,z);

    return x3 + y3 + z3 - (x+y+z);
}




T clebschCubic(T x, T y, T z ){

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T x3 = tmul(x, x2);
    T y3 = tmul(y, y2);
    T z3 = tmul(z, z2);

    T term1 = 81.*(x3+y3+z3);
    T term2 = -189.*(tmul(x2, y)+tmul(x2, z)+tmul(y2, x)+tmul(y2, z)+tmul(z2, x)+tmul(z2, y));
    T term3 = 54.*tmul(x, y, z)+126.*(tmul(x, y)+tmul(x, z)+tmul(y, z));
    T term4 = -9.*(x+y+z);

    return term1 + term2 + term3 + term4 + T(1, 0);

}

T cayleyNodalCubic(T x, T y, T z, T w){
    // return dot(z.xyz,z.xyz) * z.w + 2. * z.x * z.y * z.z - z.w*z.w*z.w;
    //https://en.wikipedia.org/wiki/Cayley%27s_nodal_cubic_surface

    //offset to make nonsingular surface:
    float offset =0.;

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T w2 = tsqr(w);

    return tmul(x2 + y2 + z2,w)+2.*tmul(x,y,z)-tmul(w,w,w)-T(offset,0);
}

T cayleyNodalCubic(T x, T y, T z){
    return cayleyNodalCubic(x,y,z,T(1,0));
}




T myCubic(T x, T y, T z, T w){
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T w2 = tsqr(w);
    
    // Pure xyz terms (no w)
    T term1 = 24. * tmul(x, y, z);
    T term2 = -30. * tmul(y2, z);
    T term3 = -15. * tmul(y, z2);
    
    // Linear in w
    T term4 = -24. * tmul(x2, w);
    T term5 = 50. * tmul(y2, w);
    T term6 = 42. * tmul(y, z, w);
    T term7 = 6. * tmul(z2, w);
    
    // Quadratic in w
    T term8 = 64. * tmul(x, w2);
    T term9 = -95. * tmul(y, w2);
    T term10 = -28. * tmul(z, w2);
    
    // Cubic in w
    T term11 = -10. * tmul(w2, w);
    
    return term1 + term2 + term3 + term4 + term5 + term6 + term7 + term8 + term9 + term10 + term11;
}

// Affine version (w=1 patch)
T myCubic(T x, T y, T z){
    return myCubic(x, y, z, T(1, 0));
}

// Double cover via inverse stereographic projection to S³
T myCubicStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x, y, z, X, Y, Z, W);
    return myCubic(X, Y, Z, W);
}
