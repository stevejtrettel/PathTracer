//-------------------------------------------------
// ALGEBRAIC VARIETIES
// a Variety is raymarched with distance estimation
// these are "basic objects" that can be used to build more complex ones
//-------------------------------------------------

//---------------------------------------
// Dual Number Arithmetic
// For algebraic distance estimations
//-------------------------------------

// Dual numbers, basically complex with very small imaginary
// component, so multiplication can ignore the im*im part.

#define T vec2


T tfloat(float x) {
    return T(x,0);
}

T tmul(T z, T w) {
    return T(z.x*w.x,z.x*w.y+z.y*w.x); // Dual numbers
}

T tmul(T z, T w, T v) {
    return tmul(z,tmul(w,v));
}

T tmul(T z, T w, T u, T v) {
    return tmul(tmul(z,w),tmul(u,v));
}

T tsqr(T z) {
    //return tmul(z,z);
    return T(z.x*z.x,2.0*z.x*z.y);
}

T tcube(T z){
    return tmul(z,z,z);
}

T tfourth(T z){
    return tmul(tsqr(z),tsqr(z));
}

T tinv(T z){
    return T(1./z.x, -z.y/(z.x*z.x));
}

T tdiv(T x, T y){
    return tmul(x,tinv(y));
}

// (T)Chebyshev polynomials
// Use T(2n,x) = T(n,x)*T(n,x)-1
T tcheb(T x, int n) {
    for (int i = 0; i < n; i++) {
        x = 2.0*tsqr(x) - tfloat(1.0);
    }
    return x;
}


T tabs( T v){
    if( v.x < 0. ) {
        v.x = -v.x;
        v.y= -v.y;
    }
    return v;
}


T tpow(in T v, in float p){//v must be positive ! //p is a constant .
    return pow( v.x , p - 1. ) *T( v.x , p * v.y );
}


T tmin(in T z, in T w){
    if( z.x < w.x ) return z;
    else return w;
}

T tmax(in T z, in T w){
    if( z.x > w.x ) return z;
    else return w;
}

T texp( T z){
    return exp(z.x)*T(1,z.y);
}

T tlog( T v){
    return T( log(v.x) , v.y / v.x );
}

T tsqrt( T v){
    float r = sqrt(v.x);
    return T( r , 0.5 * v.y / r );
}


//T tpow(in T v, in T p){//v.x must be positive ! //p is a constant .
//    return texp( tmul( p , tlog( v ) ) );
//}

T tcos(in T v){
    return T( cos( v.x ) , - v.y * sin( v.x ) );
}

T tsin(in T v){
    return T( sin( v.x ) ,  v.y * cos( v.x ) );
}

T ttan(in T v){
    return T( tan( v.x ) ,  v.y /( cos( v.x )*cos( v.x )) );
}


T tasin(in T v){
    return T( asin(v.x) , v.y / sqrt( 1. - v.x * v.x ) );
}

T tacos(in T v){
    return T( acos(v.x) , - v.y / sqrt( 1. - v.x * v.x ) );
}

T tatan(in T v){
    return T( atan(v.x) , v.y / ( 1. + v.x * v.x ) );
}













//--- The Distance Estimator -----
// Takes in a value and gradient length, approximated distance to zero level set:

float DE(float val, float gradLength){
    float k = 1.-1./(abs(val)+1.);
    float param = 5.0; // a free parameter we can set to change accuracy/speed (trial and error)
    float adjustedSpeed = gradLength+param*k+.001;

    //what would happen if it were linear, and we were headed right towards the max decrease?
    float dist = val/adjustedSpeed;
    return 0.4*dist;
}




//----------------------------------------------------------------------------------------------
// Dual - Number Formulas for various varieties:
//----------------------------------------------------------------------------------------------------

void invStereo( in T x, in T y, in T z, out T X, out T Y, out T Z, out T W){
    //takes in x y z in R3
    // returns XYZW in R4

    T denom = T(1,0) + tsqr(x) + tsqr(y) + tsqr(z); // 1+x^2+y^2+z^2
    T wNum = denom - T(2,0); // x^2+y^2+z^2-1

    X = 2.* tdiv(x,denom);
    Y = 2.* tdiv(y,denom);
    Z = 2.* tdiv(z,denom);
    W = tdiv(wNum, denom);

}


T gyroid(T x, T y, T z){
    T term1 = tmul(tsin(x),tcos(y));
    T term2 = tmul(tsin(y), tcos(z));
    T term3 = tmul(tsin(z),tcos(x));
    return 1.*(term1 + term2 + term3);
}

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



T barthDecic(T x, T y, T z, T w){

    //THERES SOME ERROR IN HERE BUT I AM NOT SURE WHERE!

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


T chmutov(T x, T y, T z) {
    int n = 4;
    return tcheb(x,n)+tcheb(y,n)+tcheb(z,n)+tfloat(1.0);
}


T kummer(T x, T y, T z, T w){

    //moduli for the quartic:
    float muSqr=0.7;
    float Lambda = (3.* muSqr - 1.)/(3.-muSqr);

    T p = z - w + x * sqrt(2.);
    T q = z - w - x * sqrt(2.);
    T r = z + w + y * sqrt(2.);
    T s = z + w - y * sqrt(2.);

    T fmu = tsqr(x) + tsqr(y) + tsqr(z) - sqrt(muSqr) * tsqr(w);
    T prod = tmul(p,q,r,s);

    return tsqr(fmu) - Lambda * prod;
}

T kummer(T x, T y, T z){
    return kummer(x,y,z,T(1,0));
}

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

    //    float r2 = x2+y2;
    //    float U = 64.0*(x2-w2)*(y2-w2)*((x+y)*(x+y)-2.0*w2)*((x-y)*(x-y)-2.0*w2);
    //    float V = -4.0*(1.0+sqrt(2.0))*r2*r2+(8.0*(2.0+sqrt(2.0))*z2+2.0*(2.0+7.0*sqrt(2.0))*w2)*r2;
    //    V = V + z2*(-16.0*z2+8.0*(1.0-2.0*sqrt(2.0))*w2) - (1.0+12.0*sqrt(2.0))*w2*w2;
    //    return V*V-U;
}

T endrassOctic(T x, T y, T z){
    return endrassOctic(x,y,z,T(1,0));
}


T endrassStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return endrassOctic(X,Y,Z,W);
}




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

T sexticStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return togliatti(X,Y,Z,W);
}

T decicStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return barthDecic(X,Y,Z,W);
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

















//
////-------------ALGEBRAIC VARIETIES---------------------
////CURRENTLY NOT INCLUDED IN THE PROGRAM!
//// MAINLY FOR REFERENCE, AS WE NEED TO TRANSLATE THEM INTO DUAL NUMBERS FOR USE
////----------------------------------------------------
//
//#define Phi (.5*(1.+sqrt(5.)))
//#define PHI  1.618034
//#define PHI2 2.618034
//#define PHI4 6.854102
//
////Cubics
//float CayleyNodal3(vec4 z) //https://en.wikipedia.org/wiki/Cayley%27s_nodal_cubic_surface
//{
//    return dot(z.xyz,z.xyz) * z.w + 2. * z.x * z.y * z.z - z.w*z.w*z.w;
//}
////Quartics
//float Kummer4(vec4 z) //See https://en.wikipedia.org/wiki/Kummer_surface and http://www.mathcurve.com/surfaces/kummer/kummer.shtml
//{
//    float p = z.z - z.w + z.x * sqrt(2.);
//    float q = z.z - z.w - z.x * sqrt(2.);
//    float r = z.z + z.w + z.y * sqrt(2.);
//    float s = z.z + z.w - z.y * sqrt(2.);
//    float fmu = dot(z.xyz,z.xyz) - Mu * z.w*z.w;
//    return fmu*fmu - Lambda * p*q*r*s;
//}
////Quintics
//float Togliatti_5(vec4 z) //See http://www2.mathematik.uni-mainz.de/alggeom/docs/Etogliatti.shtml http://mathworld.wolfram.com/TogliattiSurface.html
//{
//    vec4 z2 = z*z;
//    float P = z2.x*(z2.x-4.*z.x*z.w-10.*z2.y-4.*z2.w)+z.x*z.w*(16.*z2.w-20.*z2.y)+5.*z2.y*z2.y+z2.w*(16.*z2.w-20.*z2.y);
//    float Q = 4.*(z2.x+z2.y-z2.z)+(1.+3.*sqrt(5.))*z2.w;
//    Q = (2.*z.z - z.w*sqrt(5.-sqrt(5.))) * Q*Q;
//    return  64.*(z.x-z.w)*P - 5.*sqrt(5.-sqrt(5.))*Q;
//}
//
//float Togliatti5(vec4 z) //inferred from: http://mathworld.wolfram.com/Dervish.html
//{
//    vec4 z2 = z*z;
//    const float ro = 0.25*(1.+3.*sqrt(5.));
//    const float a = - 8./5.*(1.+1./sqrt(5.))*sqrt(5.-sqrt(5.));
//    const float c = 0.5*sqrt(5.-sqrt(5.));
//
//    float h1 = z.x - z.w;
//    float h2 = cos(2.*PI/5.)*z.x - sin(2.*PI/5.)*z.y - z.w;
//    float h3 = cos(4.*PI/5.)*z.x - sin(4.*PI/5.)*z.y - z.w;
//    float h4 = cos(6.*PI/5.)*z.x - sin(6.*PI/5.)*z.y - z.w;
//    float h5 = cos(8.*PI/5.)*z.x - sin(8.*PI/5.)*z.y - z.w;
//
//    float P =h1*h2*h3*h4*h5;
//    float Q = z2.x + z2.y - z2.z + ro*z2.w ;
//    Q = (z.z - c*z.w) * Q*Q;
//    return  Mu*(a*P + Q);
//}
//
//float Dervish5(vec4 z) //See http://mathworld.wolfram.com/Dervish.html
//{
//    vec4 z2 = z*z;
//    const float ro = 0.25*(1.+3.*sqrt(5.));
//    const float a = - 8./5.*(1.+1./sqrt(5.))*sqrt(5.-sqrt(5.));
//    const float c = 0.5*sqrt(5.-sqrt(5.));
//    float h1 = z.x + z.z;
//    float h2 = cos(2.*PI/5.)*z.x - sin(2.*PI/5.)*z.y + z.z;
//    float h3 = cos(4.*PI/5.)*z.x - sin(4.*PI/5.)*z.y + z.z;
//    float h4 = cos(6.*PI/5.)*z.x - sin(6.*PI/5.)*z.y + z.z;
//    float h5 = cos(8.*PI/5.)*z.x - sin(8.*PI/5.)*z.y + z.z;
//
//    float P =h1*h2*h3*h4*h5;
//    float Q = z2.x + z2.y + ro*z2.z - z2.w;
//    Q = (z.w + c*z.z) * Q*Q;
//    return  a*P + Q;
//}
////Sextics
//float Barth6(vec4 z)
//{
//    vec4 z2=z*z;
//    vec3 z3=PHI2*z2.xyz-z2.yzx;
//    float p1=4.*z3.x*z3.y*z3.z;
//    float r2=dot(z.xyz,z.xyz)-z2.w;
//    float p2=Tau*(r2*r2)*z2.w;
//    return p2-p1;
//}
//
////Septics
//float Labs7(vec4 p){
//    float a = -0.140106854987125;//the real root of 7*a^3+7*a+1=0
//    //Constants
//    float a1= -0.0785282014969835;//(-12./7.*a-384./49.)*a-8./7.;
//    float a2= -4.1583605922880200;//(-32./7.*a+24./49.)*a-4.;
//    float a3= -4.1471434889655100;//(-4.*a+24./49.)*a-4.;
//    float a4= -1.1881659380714800;//(-8./7.*a+8./49.)*a-8./7.;
//    float a5= 51.9426145948147000;//(49.*a-7.)*a+50.;
//
//    float	r2= dot(p.xy,p.xy);
//    vec4 p2=p*p;
//    float U = (p.z+p.w)*r2+(a1*p.z+a2*p.w)*p2.z+(a3*p.z+a4*p.w)*p2.w;
//    U = (p.z+a5*p.w)*U*U;
//    float P = p.x*((p2.x-3.*7.*p2.y)*p2.x*p2.x+(5.*7.*p2.x-7.*p2.y)*p2.y*p2.y);
//    P+= p.z*(7.*(((r2-8.*p2.z)*r2+16.*p2.z*p2.z)*r2)-64.*p2.z*p2.z*p2.z);
//    return U-P;
//}
//
////Octics
//float Endrass8(vec4 p){
//    vec4 p2 = p*p;
//    float r2 = dot(p.xy,p.xy);
//    float U = 64.*(p2.x-p2.w)*(p2.y-p2.w)*((p.x+p.y)*(p.x+p.y)-2.*p2.w)*((p.x-p.y)*(p.x-p.y)-2.*p2.w);
//    float V = -4.*(1.+sqrt(2.))*r2*r2+(8.*(2.+sqrt(2.))*p2.z+2.*(2.+7.*sqrt(2.))*p2.w)*r2;
//    V = V + p2.z*(-16.*p2.z+8.*(1.-2.*sqrt(2.))*p2.w) - (1.+12.*sqrt(2.))*p2.w*p2.w;
//    return V*V-U;
//}
//
//float Endrass_8(vec4 p){
//    vec4 p2 = p*p;
//    float r2 = dot(p.xy,p.xy);
//    float U = 64.*(p2.x-p2.w)*(p2.y-p2.w)*((p.x+p.y)*(p.x+p.y)-2.*p2.w)*((p.x-p.y)*(p.x-p.y)-2.*p2.w);
//    float V = -4.*(1.-sqrt(2.))*r2*r2+(8.*(2.-sqrt(2.))*p2.z+2.*(2.-7.*sqrt(2.))*p2.w)*r2;
//    V = V + p2.z*(-16.*p2.z+8.*(1.+2.*sqrt(2.))*p2.w) - (1.-12.*sqrt(2.))*p2.w*p2.w;
//    return V*V-U;
//}
//
//float Sarti8(vec4 p){
//    vec4 p2 = p*p;
//    vec4 p4 = p2*p2;
//    vec4 p8 = p4*p4;
//    float r2  = dot(p,p);
//    return dot(p4,p4) + 14.*(p4.x*dot(p2.yzw,p2.yzw) + p4.y*dot(p2.zw,p2.zw)+p4.z*p4.w) + 168. * (p2.x*p2.y*p2.z*p2.w) - 9.0/16. * r2*r2*r2*r2;
//    //x^8+y^8+z^8+w^8+14*(x^4*(y^4+z^4+w^4)+y^4*(z^4+w^4)+(z*w)^4)+   168*(x*y*z*w)^2-9/16*(x^2+y^2+z^2+w^2)^4
//}
//
//float Chmutov8(in vec4 P){//octic
//    vec4 P2=P*P;
//    //vec3 R = 1.*P2.w*P2.w*P2.w*P2.w+P2.xyz*32.*(-1.*P2.w*P2.w*P2.w+P2.xyz*(5.*P2.w*P2.w+P2.xyz*(-8.*P2.w+P2.xyz*4.)));
//    vec3 R=P2.w*P2.w*P2.w*P2.w+P2.xyz*32.0*(-1.0*P2.w*P2.w*P2.w+P2.xyz*(5.0*P2.w*P2.w+P2.xyz*(-8.0*P2.w+P2.xyz*4.0)));
//    return R.x+R.y+R.z+Mu*P2.w*P2.w*P2.w*P2.w;
//}
//
//float Cheby(float x, int n){
//    float t0=1., t1=x;
//    while(n>1){
//        float t=2.*x*t1-t0;
//        t0=t1; t1=t;
//        n-=1;
//    }
//    return t1;
//}
//vec3 Cheby(vec3 x,float w,  int n, out float wn){
//    vec3 t0=vec3(1.), t1=x;
//    float w2=w*w;
//    wn=w;
//    while(n>1){
//        vec3 t=2.*x*t1-t0*w2;
//        t0=t1; t1=t;
//        n-=1;
//        wn*=w;
//    }
//    return t1;
//}
//
//float Chmutovn(in vec4 p){
//    float wn=0.;
//    vec3 t=Cheby(p.xyz,p.w,ChN,wn);
//    return t.x+t.y+t.z+wn;
//}
//
////nonics
//float Escudero9(vec4 p){
//    float alpha=sqrt(3.);
//    vec4 p2 = p*p, p3=p*p2, p4=p2*p2, p5=p2*p3;
//
//    float P= p5.w*((27.*p2.x-p2.w)*p2.w-9.*(p.w+6.*p.x)*p3.x)+p5.x*((36.*p.w+21.*p.x)*p3.w-(9.*(3.*p2.w-p.w*p.x)+p2.x)*p2.x)
//    +alpha*(81.*(2.*p2.x-p2.w)*p4.w-(54.*(p.w+1.5*p.x)*p2.w+9.*(p.x-6.*p.w)*p2.x)*p3.x)*p2.x*p.y
//    +((27.*p2.w*(p.w+p.x)-72.*(1.5*p.w+p.x)*p2.x)*p4.w+(p2.w*(225.*p.w+27.*p.x)+36.*p2.x*(p.x-3.5*p.w))*p4.x)*p2.y
//    +alpha*((27.*p3.w+(108.*p.w+180.*p.x)*p2.x)*p3.w-(135.*p2.w+(126.*p.w-84.*p.x)*p.x)*p4.x)*p3.y
//    +((-54.*p2.w-108.*p.w*p.x-45.*p2.x)*p3.w+(135.*p2.w-126.*p2.x)*p3.x)*p4.y
//    +(alpha*(-54.*(p.w+p.x)*p3.w-27.*p2.w*p2.x-126.*(p.w+p.x)*p3.x)
//    +(p2.w*(39.*p.w+81.*p.x)+(126.*p.w+84.*p.x)*p2.x)*p.y
//    +alpha*9.*(3.*p2.w+6.*p.w*p.x+4.*p2.x)*p2.y
//    -9.*(p.w+p.x)*p3.y-alpha*p4.y)*p5.y;
//
//    float Q= (((27.*p2.z-4.*p2.w)*p2.w-9.*(p.w+6.*p.z)*p3.z)*p5.w+((36.*p2.w+(21.*p.w-27.*p.z)*p.z)*p2.w+(9.*p.w-p.z)*p3.z)*p5.z)/4.;
//
//    return P-Q;
//}
//float Escudero9_2(vec4 p){
//    float alpha=sqrt(3.);
//    vec4 p2 = p*p, p3=p*p2, p4=p2*p2, p5=p2*p3;
//
//    float P= ((27.*p2.x-1.)-9.*(1.+6.*p.x)*p3.x)+p5.x*((36.*1.+21.*p.x)-(9.*(3.-p.x)+p2.x)*p2.x)
//    +alpha*(81.*(2.*p2.x-1.)-(54.*(1.+1.5*p.x)+9.*(p.x-6.)*p2.x)*p3.x)*p2.x*p.y
//    +((27.*(1.+p.x)-72.*(1.5+p.x)*p2.x)+((225.+27.*p.x)+36.*p2.x*(p.x-3.5))*p4.x)*p2.y
//    +alpha*((27.+(108.+180.*p.x)*p2.x)-(135.+(126.-84.*p.x)*p.x)*p4.x)*p3.y
//    +((-54.-108.*p.x-45.*p2.x)+(135.-126.*p2.x)*p3.x)*p4.y
//    +(alpha*(-54.*(1.+p.x)-27.*p2.x-126.*(1.+p.x)*p3.x)
//    +((39.+81.*p.x)+(126.+84.*p.x)*p2.x)*p.y
//    +alpha*9.*(3.+6.*p.x+4.*p2.x)*p2.y
//    -9.*(1.+p.x)*p3.y-alpha*p4.y)*p5.y;
//
//    float Q= (((27.*p2.z-4.)-9.*(1.+6.*p.z)*p3.z)+((36.+(21.-27.*p.z)*p.z)+(9.-p.z)*p3.z)*p5.z)/4.;
//
//    return P-Q;
//}
////Decics
//float Barth10(in vec4 P){//decic
//    float r2=dot(P.xyz,P.xyz);
//    vec4 P2=P*P;
//    float r4=dot(P2.xyz,P2.xyz);
//    vec4 P4=P2*P2;
//    return (8.0*(P2.x-PHI4*P2.y)*(P2.y-PHI4*P2.z)*(P2.z-PHI4*P2.x)*(r4-2.0*((P.x*P.y)*(P.x*P.y)+(P.x*P.z)*(P.x*P.z)+(P.y*P.z)*(P.y*P.z)))+(3.0+5.0*PHI)*(r2-P2.w)*(r2-P2.w)*(r2-(2.0-PHI)*P2.w)*(r2-(2.0-PHI)*P2.w)*P2.w);
//}
//
////   Dodecics
//float Sarti12(vec4 p){
//    vec4 p2 = p*p;
//    vec4 p4 = p2*p2;
//    float l1 = dot(p2,p2);
//    float l2 = p2.x*p2.y+p2.z*p2.w;
//    float l3 = p2.x*p2.z+p2.y*p2.w;
//    float l4 = p2.y*p2.z+p2.x*p2.w;
//    float l5 = p.x*p.y*p.z*p.w;
//    float s10 = l1*(l2*l3+l2*l4+l3*l4), s11 = l1*l1*(l2+l3+l4);
//    float s12=l1*(l2*l2+l3*l3+l4*l4),    s51=l5*l5*(l2+l3+l4),  s234=l2*l2*l2+l3*l3*l3+l4*l4*l4;
//    float s23p=l2*(l2+l3)*l3,   s23m=l2*(l2-l3)*l3;
//    float s34p=l3*(l3+l4)*l4,       s34m=l3*(l3-l4)*l4;
//    float s42p=l4*(l4+l2)*l2,       s42m=l4*(l4-l2)*l2;
//    float Q12=dot(p,p); Q12=Q12*Q12*Q12; Q12=Q12*Q12;
//    float S12=33.*sqrt(5.)*(s23m+s34m+s42m)+19.*(s23p+s34p+s42p)+10.*s234-14.*s10+2.*s11-6.*s12-352.*s51+336.*l5*l5*l1+48.*l2*l3*l4;
//    return 22.*Q12-243.*S12;
//}
//
////---------------------------------------
////Barth sextic with transformation: p-> 2*p/(1-p^2) . This transformation is related to Stereographic projection (the result is actually equivalent).
////The plane at infinity is mapped to the unit sphere and we get two copies of the original implicit. One inside the unit sphere and the other outside.
////This one preserves the symmetries unlihe the homographic transformation.
////... After some algebra and simplification :-)
//float Barth6T(vec3 p){
//    float r2 = dot(p,p);
//    float m2 = 1.-r2; m2 *= m2;
//    float n2 = r2- 0.25 * m2; n2 *= n2;
//    vec3 p2 = p*p;
//    return -(16.*(PHI2*p2.x - p2.y)*(PHI2*p2.y - p2.z)*(PHI2*p2.z - p2.x) - Tau * m2 * n2);
//}
////---------------------------------------
