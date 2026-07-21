//-------------------------------------------------
// VARIETY FORMULAS — gallery
// dual-number defining equations T eqn(T x,T y,T z[,T w]); the engine (T
// arithmetic, DE, invStereo) lives in glsl/tracer/1Setup/dualNumbers.glsl.
// #include this file in a scene's objects.glsl to use: sauermann, sauermann2, sauermann3, visavisVar, kolibriVar, whitneyUmbrella, irisVar, calyxVar, daisyVar, dingdongVar, thistleVar, eistuteVar, herzVar, crossCapVar, romanSurfaceVar.
//-------------------------------------------------

T sauermann(T x, T y, T z){
    //sauermann
    //https://www.imaginary.org/gallery/algebraic-surfaces
    //((x2+y2+(z∗1+0.45)2−0.83)∗(x2+y2+(z∗1−0.45)2−0.83)∗(x2+y2+(z)2)∗(x2+y2+(z)2∗(z)2)∗(x2+y2+(z−0.45)2−1)∗(x2+y2+(z+0.45)2−1)+(x+y)2∗(x−y)2∗(x∗y)2)

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    T a = T(0.45,0);
    T b = T(0.83,0);
    T c = T(1,0);
    T term1 = tmul(x2 + y2 + tsqr(z+a)-b, x2 + y2 + tsqr(z-a)-b);
    T term2 = tmul(x2 + y2 + tsqr(z+a)-c, x2 + y2 + tsqr(z-a)-c);
    T term3 = tmul(x2 + y2 + z2,x2 + y2 + tsqr(z2));

    T term4 = tmul(tsqr(x+y),tsqr(x-y));
    T term5 = tsqr(tmul(x,y));

    return tmul(term1, term2, term3) + tmul(term4, term5);


}


T sauermann2(T x, T y, T z){
    //Sauermann Surface2013
    //https://www.imaginary.org/gallery/algebraic-surfaces
    //-(z+1)*(z^4-5*z^3+6*z^2+z-2)^2+(x^2-1)*(y^2-1)*(x^4-2*x^2*(y^2+2)+y^4-4*y^2+4)
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    T x4 = tsqr(x2);
    T y4 = tsqr(y2);
    T z4 = tsqr(z2);

    T term1 = z+T(1,0);
    T term2 = tsqr(z4-5.*tmul(z2,z)+6.*z2+z-T(2,0));

    T term3 = tmul(x2-T(1,0),y2-T(1,0));
    T term4 = x4-2.*tmul(x2,y2+T(2,0))+y4-4.*y2+T(4,0);

    return  tmul(term1,term2)-tmul(term3,term4);

}



T sauermann3(T x, T y, T z){
    //note: despite the name 'nodal cubic', the formula contains a z^4 term
    //x^3+3*x^2*(-1+y)-3*y^2-3*x* y^2-y^3+(1+z)*(1+2*z-4*z^2)^2
    //sauerman nodal cubic
    z = -z;

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T x3 = tmul(x, x2);
    T y3 = tmul(y, y2);

    T term1 = x3+tmul(3.*x2, T(-1, 0)+y);
    T term2 = -3.*y2-3.*tmul(x, y2);
    T term3 = -y3+tmul(T(1, 0)+z, tsqr(T(1, 0)+2.*z-4.*z2));

    return -(term1 + term2 + term3);
}


T visavisVar(T x, T y, T z){
    //x2−x3+y2+y4+z3−z4=0
    //https://www.imaginary.org/gallery/herwig-hauser-classic

    T x2 = tsqr(x);
    T x3 = tmul(x, x2);
    T y2 = tsqr(y);
    T y4 = tsqr(y2);
    T z3 = tmul(z,z,z);
    T z4 = tmul(z,z3);

    return x2 - x3 + y2 + y4 + z3 - z4;
}


T kolibriVar(T x, T y, T z){
    // y2 = x2z2 + x3  (implemented with x and y swapped)
    //https://www.imaginary.org/gallery/herwig-hauser-classic
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T y3 = tmul(y2,y);

    return x2 - tmul(y2,z2) - y3;
}

T whitneyUmbrella(T x, T y, T z){
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    return x2 - tmul(z2,y);
}


T irisVar(T x, T y, T z){
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T z4 = tsqr(z2);

    return tmul(x2,y) - tmul(y2,z) + z4;
}


T calyxVar(T x, T y, T z){
    //x2+y2z3-z4
    //https://www.imaginary.org/gallery/herwig-hauser-classic
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z3 = tmul(z,z,z);
    T z4 = tmul(z,z3);
    return x2 + tmul(y2,z3)-z4;
}


T daisyVar(T x, T y, T z){
   // (x2−y3)2 = (z2−y2)3
    //https://www.imaginary.org/gallery/herwig-hauser-classic
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T y3 = tmul(y,y2);

    T term1 = x2-y3;
    T term2 = z2-y2;

    return tsqr(term1)-tmul(term2,term2,term2);
}


T dingdongVar(T x, T y, T z){
    //x2+y2+z3−z2=0
    //https://www.imaginary.org/gallery/herwig-hauser-classic
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T z3 = tmul(z2,z);

    return x2 + y2 + z3 - z2;
}


T thistleVar(T x, T y, T z){
    //x2+y2+z2+c(x2+y2)(x2+z2)(y2+z2) = 1
    //https://www.imaginary.org/gallery/herwig-hauser-classic
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    T term1 = x2+y2;
    T term2 = x2+z2;
    T term3 = y2+z2;

    float c = 1500.;
    return x2 + y2 + z2 + c*tmul(term1,term2,term3)-T(1,0);
}


T eistuteVar(T x, T y, T z){
    //(x2+y2)3−x2y2⋅(z2+1)=0
    //https://www.imaginary.org/gallery/herwig-hauser-classic
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    T term1 = x2+y2;
    T term2 = tmul(x2,y2);
    T term3 = z2+T(1,0);

    return (tmul(term1,term1,term1) - tmul(term2, term3));
}


T herzVar(T x, T y, T z){
    //y2+z3 = z4+x2z2
    //https://www.imaginary.org/gallery/herwig-hauser-classic

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T z3 = tmul(z2,z);
    T z4 = tmul(z3,z);

    return y2 + z3 - z4 - tmul(x2,z2);
}


//------Classification of singularities
    //https://www-sop.inria.fr/galaad/surface/
    //need to make these
//---------------



T crossCapVar(T x, T y, T z){
    //https://www-sop.inria.fr/galaad/surface/steiner/index.html
    //https://virtualmathmuseum.org/Surface/cross-cap/cross-cap.html

    //x = x/1.5;
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    float a2 =0.5;
    float b2 =1.;

    T term1 =  x2/a2+y2/b2;
    T term2 = x2 + y2 + z2;
    T term3 = 2.*tmul(z,x2+y2);

    return tmul(term1, term2) - term3;
}




T romanSurfaceVar(T x, T y, T z){
    //{\displaystyle x^{2}y^{2}+y^{2}z^{2}+z^{2}x^{2}-r^{2}xyz=0.\,}
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    float r2=1.;

    return tmul(x2,y2)+ tmul(y2,z2) + tmul(z2,x2) - r2*tmul(x,y,z);

}
