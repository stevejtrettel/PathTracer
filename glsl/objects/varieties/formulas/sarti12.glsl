//-------------------------------------------------
// VARIETY FORMULAS — sarti12
// dual-number defining equations T eqn(T x,T y,T z[,T w]); the engine (T
// arithmetic, DE, invStereo) lives in glsl/tracer/1Setup/dualNumbers.glsl.
// #include this file in a scene's objects.glsl to use: sarti12, sartiStereo.
//-------------------------------------------------

// I probably lifted this from Knighty's Fragmentarium shader.
T sarti12(T x, T y, T z, T w){
    T x2 = tmul(x,x), y2 = tmul(y,y), z2 = tmul(z,z), w2 = tmul(w,w);
    T x4 = tmul(x2,x2), y4 = tmul(y2,y2), z4 = tmul(z2,z2), w4 = tmul(w2,w2);
    T l1 = x4+y4+z4+w4;
    T l2 = tmul(x2,y2)+tmul(z2,w2);
    T l3 = tmul(x2,z2)+tmul(y2,w2);
    T l4 = tmul(y2,z2)+tmul(x2,w2);
    T l5 = tmul(x,y,z,w);
    T s10 = tmul(l1,tmul(l2,l3)+tmul(l2,l4)+tmul(l3,l4));
    T s11 = tmul(tmul(l1,l1),l2+l3+l4);
    T s12=tmul(l1,tmul(l2,l2)+tmul(l3,l3)+tmul(l4,l4));
    T s51=tmul(tmul(l5,l5),l2+l3+l4);
    T s234=tmul(l2,l2,l2)+tmul(l3,l3,l3)+tmul(l4,l4,l4);
    T s23p=tmul(l2,l2+l3,l3), s23m=tmul(l2,l2-l3,l3);
    T s34p=tmul(l3,l3+l4,l4), s34m=tmul(l3,l3-l4,l4);
    T s42p=tmul(l4,l4+l2,l2), s42m=tmul(l4,l4-l2,l2);
    T Q12=x2+y2+z2+w2; Q12=tmul(Q12,Q12,Q12); Q12=tmul(Q12,Q12);
    T S12=33.0*sqrt(5.0)*(s23m+s34m+s42m)+19.0*(s23p+s34p+s42p)+10.0*s234-14.0*s10+2.0*s11-6.0*s12-352.0*s51+336.0*tmul(l5,l5,l1)+48.0*tmul(l2,l3,l4);
    return 22.0*Q12-243.0*S12;
}

T sarti12(T x, T y, T z){
    return sarti12(x,y,z,T(1,0));
}

T sartiStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return sarti12(X,Y,Z,W);
}
