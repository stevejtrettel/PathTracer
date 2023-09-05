

//-------------ALGEBRAIC VARIETIES---------------------
//CURRENTLY NOT INCLUDED IN THE PROGRAM!
// MAINLY FOR REFERENCE, AS WE NEED TO TRANSLATE THEM INTO DUAL NUMBERS FOR USE
//----------------------------------------------------

#define Phi (.5*(1.+sqrt(5.)))
#define PHI  1.618034
#define PHI2 2.618034
#define PHI4 6.854102

//Cubics
float CayleyNodal3(vec4 z) //https://en.wikipedia.org/wiki/Cayley%27s_nodal_cubic_surface
{
    return dot(z.xyz,z.xyz) * z.w + 2. * z.x * z.y * z.z - z.w*z.w*z.w;
}
//Quartics
float Kummer4(vec4 z) //See https://en.wikipedia.org/wiki/Kummer_surface and http://www.mathcurve.com/surfaces/kummer/kummer.shtml
{
    float p = z.z - z.w + z.x * sqrt(2.);
    float q = z.z - z.w - z.x * sqrt(2.);
    float r = z.z + z.w + z.y * sqrt(2.);
    float s = z.z + z.w - z.y * sqrt(2.);
    float fmu = dot(z.xyz,z.xyz) - Mu * z.w*z.w;
    return fmu*fmu - Lambda * p*q*r*s;
}
//Quintics
float Togliatti_5(vec4 z) //See http://www2.mathematik.uni-mainz.de/alggeom/docs/Etogliatti.shtml http://mathworld.wolfram.com/TogliattiSurface.html
{
    vec4 z2 = z*z;
    float P = z2.x*(z2.x-4.*z.x*z.w-10.*z2.y-4.*z2.w)+z.x*z.w*(16.*z2.w-20.*z2.y)+5.*z2.y*z2.y+z2.w*(16.*z2.w-20.*z2.y);
    float Q = 4.*(z2.x+z2.y-z2.z)+(1.+3.*sqrt(5.))*z2.w;
    Q = (2.*z.z - z.w*sqrt(5.-sqrt(5.))) * Q*Q;
    return  64.*(z.x-z.w)*P - 5.*sqrt(5.-sqrt(5.))*Q;
}

float Togliatti5(vec4 z) //inferred from: http://mathworld.wolfram.com/Dervish.html
{
    vec4 z2 = z*z;
    const float ro = 0.25*(1.+3.*sqrt(5.));
    const float a = - 8./5.*(1.+1./sqrt(5.))*sqrt(5.-sqrt(5.));
    const float c = 0.5*sqrt(5.-sqrt(5.));

    float h1 = z.x - z.w;
    float h2 = cos(2.*PI/5.)*z.x - sin(2.*PI/5.)*z.y - z.w;
    float h3 = cos(4.*PI/5.)*z.x - sin(4.*PI/5.)*z.y - z.w;
    float h4 = cos(6.*PI/5.)*z.x - sin(6.*PI/5.)*z.y - z.w;
    float h5 = cos(8.*PI/5.)*z.x - sin(8.*PI/5.)*z.y - z.w;

    float P =h1*h2*h3*h4*h5;
    float Q = z2.x + z2.y - z2.z + ro*z2.w ;
    Q = (z.z - c*z.w) * Q*Q;
    return  Mu*(a*P + Q);
}

float Dervish5(vec4 z) //See http://mathworld.wolfram.com/Dervish.html
{
    vec4 z2 = z*z;
    const float ro = 0.25*(1.+3.*sqrt(5.));
    const float a = - 8./5.*(1.+1./sqrt(5.))*sqrt(5.-sqrt(5.));
    const float c = 0.5*sqrt(5.-sqrt(5.));
    float h1 = z.x + z.z;
    float h2 = cos(2.*PI/5.)*z.x - sin(2.*PI/5.)*z.y + z.z;
    float h3 = cos(4.*PI/5.)*z.x - sin(4.*PI/5.)*z.y + z.z;
    float h4 = cos(6.*PI/5.)*z.x - sin(6.*PI/5.)*z.y + z.z;
    float h5 = cos(8.*PI/5.)*z.x - sin(8.*PI/5.)*z.y + z.z;

    float P =h1*h2*h3*h4*h5;
    float Q = z2.x + z2.y + ro*z2.z - z2.w;
    Q = (z.w + c*z.z) * Q*Q;
    return  a*P + Q;
}
//Sextics
float Barth6(vec4 z)
{
    vec4 z2=z*z;
    vec3 z3=PHI2*z2.xyz-z2.yzx;
    float p1=4.*z3.x*z3.y*z3.z;
    float r2=dot(z.xyz,z.xyz)-z2.w;
    float p2=Tau*(r2*r2)*z2.w;
    return p2-p1;
}

//Septics
float Labs7(vec4 p){
    float a = -0.140106854987125;//the real root of 7*a^3+7*a+1=0
    //Constants
    float a1= -0.0785282014969835;//(-12./7.*a-384./49.)*a-8./7.;
    float a2= -4.1583605922880200;//(-32./7.*a+24./49.)*a-4.;
    float a3= -4.1471434889655100;//(-4.*a+24./49.)*a-4.;
    float a4= -1.1881659380714800;//(-8./7.*a+8./49.)*a-8./7.;
    float a5= 51.9426145948147000;//(49.*a-7.)*a+50.;

    float	r2= dot(p.xy,p.xy);
    vec4 p2=p*p;
    float U = (p.z+p.w)*r2+(a1*p.z+a2*p.w)*p2.z+(a3*p.z+a4*p.w)*p2.w;
    U = (p.z+a5*p.w)*U*U;
    float P = p.x*((p2.x-3.*7.*p2.y)*p2.x*p2.x+(5.*7.*p2.x-7.*p2.y)*p2.y*p2.y);
    P+= p.z*(7.*(((r2-8.*p2.z)*r2+16.*p2.z*p2.z)*r2)-64.*p2.z*p2.z*p2.z);
    return U-P;
}

//Octics
float Endrass8(vec4 p){
    vec4 p2 = p*p;
    float r2 = dot(p.xy,p.xy);
    float U = 64.*(p2.x-p2.w)*(p2.y-p2.w)*((p.x+p.y)*(p.x+p.y)-2.*p2.w)*((p.x-p.y)*(p.x-p.y)-2.*p2.w);
    float V = -4.*(1.+sqrt(2.))*r2*r2+(8.*(2.+sqrt(2.))*p2.z+2.*(2.+7.*sqrt(2.))*p2.w)*r2;
    V = V + p2.z*(-16.*p2.z+8.*(1.-2.*sqrt(2.))*p2.w) - (1.+12.*sqrt(2.))*p2.w*p2.w;
    return V*V-U;
}

float Endrass_8(vec4 p){
    vec4 p2 = p*p;
    float r2 = dot(p.xy,p.xy);
    float U = 64.*(p2.x-p2.w)*(p2.y-p2.w)*((p.x+p.y)*(p.x+p.y)-2.*p2.w)*((p.x-p.y)*(p.x-p.y)-2.*p2.w);
    float V = -4.*(1.-sqrt(2.))*r2*r2+(8.*(2.-sqrt(2.))*p2.z+2.*(2.-7.*sqrt(2.))*p2.w)*r2;
    V = V + p2.z*(-16.*p2.z+8.*(1.+2.*sqrt(2.))*p2.w) - (1.-12.*sqrt(2.))*p2.w*p2.w;
    return V*V-U;
}

float Sarti8(vec4 p){
    vec4 p2 = p*p;
    vec4 p4 = p2*p2;
    vec4 p8 = p4*p4;
    float r2  = dot(p,p);
    return dot(p4,p4) + 14.*(p4.x*dot(p2.yzw,p2.yzw) + p4.y*dot(p2.zw,p2.zw)+p4.z*p4.w) + 168. * (p2.x*p2.y*p2.z*p2.w) - 9.0/16. * r2*r2*r2*r2;
    //x^8+y^8+z^8+w^8+14*(x^4*(y^4+z^4+w^4)+y^4*(z^4+w^4)+(z*w)^4)+   168*(x*y*z*w)^2-9/16*(x^2+y^2+z^2+w^2)^4
}

float Chmutov8(in vec4 P){//octic
    vec4 P2=P*P;
    //vec3 R = 1.*P2.w*P2.w*P2.w*P2.w+P2.xyz*32.*(-1.*P2.w*P2.w*P2.w+P2.xyz*(5.*P2.w*P2.w+P2.xyz*(-8.*P2.w+P2.xyz*4.)));
    vec3 R=P2.w*P2.w*P2.w*P2.w+P2.xyz*32.0*(-1.0*P2.w*P2.w*P2.w+P2.xyz*(5.0*P2.w*P2.w+P2.xyz*(-8.0*P2.w+P2.xyz*4.0)));
    return R.x+R.y+R.z+Mu*P2.w*P2.w*P2.w*P2.w;
}

float Cheby(float x, int n){
    float t0=1., t1=x;
    while(n>1){
        float t=2.*x*t1-t0;
        t0=t1; t1=t;
        n-=1;
    }
    return t1;
}
vec3 Cheby(vec3 x,float w,  int n, out float wn){
    vec3 t0=vec3(1.), t1=x;
    float w2=w*w;
    wn=w;
    while(n>1){
        vec3 t=2.*x*t1-t0*w2;
        t0=t1; t1=t;
        n-=1;
        wn*=w;
    }
    return t1;
}

float Chmutovn(in vec4 p){
    float wn=0.;
    vec3 t=Cheby(p.xyz,p.w,ChN,wn);
    return t.x+t.y+t.z+wn;
}

//nonics
float Escudero9(vec4 p){
    float alpha=sqrt(3.);
    vec4 p2 = p*p, p3=p*p2, p4=p2*p2, p5=p2*p3;

    float P= p5.w*((27.*p2.x-p2.w)*p2.w-9.*(p.w+6.*p.x)*p3.x)+p5.x*((36.*p.w+21.*p.x)*p3.w-(9.*(3.*p2.w-p.w*p.x)+p2.x)*p2.x)
    +alpha*(81.*(2.*p2.x-p2.w)*p4.w-(54.*(p.w+1.5*p.x)*p2.w+9.*(p.x-6.*p.w)*p2.x)*p3.x)*p2.x*p.y
    +((27.*p2.w*(p.w+p.x)-72.*(1.5*p.w+p.x)*p2.x)*p4.w+(p2.w*(225.*p.w+27.*p.x)+36.*p2.x*(p.x-3.5*p.w))*p4.x)*p2.y
    +alpha*((27.*p3.w+(108.*p.w+180.*p.x)*p2.x)*p3.w-(135.*p2.w+(126.*p.w-84.*p.x)*p.x)*p4.x)*p3.y
    +((-54.*p2.w-108.*p.w*p.x-45.*p2.x)*p3.w+(135.*p2.w-126.*p2.x)*p3.x)*p4.y
    +(alpha*(-54.*(p.w+p.x)*p3.w-27.*p2.w*p2.x-126.*(p.w+p.x)*p3.x)
    +(p2.w*(39.*p.w+81.*p.x)+(126.*p.w+84.*p.x)*p2.x)*p.y
    +alpha*9.*(3.*p2.w+6.*p.w*p.x+4.*p2.x)*p2.y
    -9.*(p.w+p.x)*p3.y-alpha*p4.y)*p5.y;

    float Q= (((27.*p2.z-4.*p2.w)*p2.w-9.*(p.w+6.*p.z)*p3.z)*p5.w+((36.*p2.w+(21.*p.w-27.*p.z)*p.z)*p2.w+(9.*p.w-p.z)*p3.z)*p5.z)/4.;

    return P-Q;
}
float Escudero9_2(vec4 p){
    float alpha=sqrt(3.);
    vec4 p2 = p*p, p3=p*p2, p4=p2*p2, p5=p2*p3;

    float P= ((27.*p2.x-1.)-9.*(1.+6.*p.x)*p3.x)+p5.x*((36.*1.+21.*p.x)-(9.*(3.-p.x)+p2.x)*p2.x)
    +alpha*(81.*(2.*p2.x-1.)-(54.*(1.+1.5*p.x)+9.*(p.x-6.)*p2.x)*p3.x)*p2.x*p.y
    +((27.*(1.+p.x)-72.*(1.5+p.x)*p2.x)+((225.+27.*p.x)+36.*p2.x*(p.x-3.5))*p4.x)*p2.y
    +alpha*((27.+(108.+180.*p.x)*p2.x)-(135.+(126.-84.*p.x)*p.x)*p4.x)*p3.y
    +((-54.-108.*p.x-45.*p2.x)+(135.-126.*p2.x)*p3.x)*p4.y
    +(alpha*(-54.*(1.+p.x)-27.*p2.x-126.*(1.+p.x)*p3.x)
    +((39.+81.*p.x)+(126.+84.*p.x)*p2.x)*p.y
    +alpha*9.*(3.+6.*p.x+4.*p2.x)*p2.y
    -9.*(1.+p.x)*p3.y-alpha*p4.y)*p5.y;

    float Q= (((27.*p2.z-4.)-9.*(1.+6.*p.z)*p3.z)+((36.+(21.-27.*p.z)*p.z)+(9.-p.z)*p3.z)*p5.z)/4.;

    return P-Q;
}
//Decics
float Barth10(in vec4 P){//decic
    float r2=dot(P.xyz,P.xyz);
    vec4 P2=P*P;
    float r4=dot(P2.xyz,P2.xyz);
    vec4 P4=P2*P2;
    return (8.0*(P2.x-PHI4*P2.y)*(P2.y-PHI4*P2.z)*(P2.z-PHI4*P2.x)*(r4-2.0*((P.x*P.y)*(P.x*P.y)+(P.x*P.z)*(P.x*P.z)+(P.y*P.z)*(P.y*P.z)))+(3.0+5.0*PHI)*(r2-P2.w)*(r2-P2.w)*(r2-(2.0-PHI)*P2.w)*(r2-(2.0-PHI)*P2.w)*P2.w);
}

//   Dodecics
float Sarti12(vec4 p){
    vec4 p2 = p*p;
    vec4 p4 = p2*p2;
    float l1 = dot(p2,p2);
    float l2 = p2.x*p2.y+p2.z*p2.w;
    float l3 = p2.x*p2.z+p2.y*p2.w;
    float l4 = p2.y*p2.z+p2.x*p2.w;
    float l5 = p.x*p.y*p.z*p.w;
    float s10 = l1*(l2*l3+l2*l4+l3*l4), s11 = l1*l1*(l2+l3+l4);
    float s12=l1*(l2*l2+l3*l3+l4*l4),    s51=l5*l5*(l2+l3+l4),  s234=l2*l2*l2+l3*l3*l3+l4*l4*l4;
    float s23p=l2*(l2+l3)*l3,   s23m=l2*(l2-l3)*l3;
    float s34p=l3*(l3+l4)*l4,       s34m=l3*(l3-l4)*l4;
    float s42p=l4*(l4+l2)*l2,       s42m=l4*(l4-l2)*l2;
    float Q12=dot(p,p); Q12=Q12*Q12*Q12; Q12=Q12*Q12;
    float S12=33.*sqrt(5.)*(s23m+s34m+s42m)+19.*(s23p+s34p+s42p)+10.*s234-14.*s10+2.*s11-6.*s12-352.*s51+336.*l5*l5*l1+48.*l2*l3*l4;
    return 22.*Q12-243.*S12;
}

//---------------------------------------
//Barth sextic with transformation: p-> 2*p/(1-p^2) . This transformation is related to Stereographic projection (the result is actually equivalent).
//The plane at infinity is mapped to the unit sphere and we get two copies of the original implicit. One inside the unit sphere and the other outside.
//This one preserves the symmetries unlihe the homographic transformation.
//... After some algebra and simplification :-)
float Barth6T(vec3 p){
    float r2 = dot(p,p);
    float m2 = 1.-r2; m2 *= m2;
    float n2 = r2- 0.25 * m2; n2 *= n2;
    vec3 p2 = p*p;
    return -(16.*(PHI2*p2.x - p2.y)*(PHI2*p2.y - p2.z)*(PHI2*p2.z - p2.x) - Tau * m2 * n2);
}
//---------------------------------------
