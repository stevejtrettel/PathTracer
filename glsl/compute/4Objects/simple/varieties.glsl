//-------------------------------------------------
// ALGEBRAIC VARIETIES
// a Variety is raymarched with distance estimation
// these are "basic objects" that can be used to build more complex ones
//-------------------------------------------------
//redefining T so this file doesnt get mad --------------------------------------
#define T vec2


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
    float muSqr=0.8;
    float Lambda = (3.* muSqr - 1.)/(3.-muSqr);

    T p = z - w + x * sqrt(2.);
    T q = z - w - x * sqrt(2.);
    T r = z + w + y * sqrt(2.);
    T s = z + w - y * sqrt(2.);

    T fmu = tsqr(x) + tsqr(y) + tsqr(z) - sqrt(muSqr) * tsqr(w);
    T prod = tmul(p,q,r,s);

    return tsqr(fmu) - Lambda * prod;
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





//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY:
// ALL THAT NEEDS TO BE CHANGED IS THE FUNCTION SURF: THE REST AUTOMATICALLY UPDATES FROM THIS
//----------------------------------------------------------------------------------------------------

T surf(T x, T y, T z){
    return endrassOctic(x,y,z);
}

vec4 surf_Data( vec3 p ){

    //Compute gradient.
    T vx = surf( T(p.x, 1.), T(p.y, 0.), T(p.z, 0.) );
    T vy = surf( T(p.x, 0.), T(p.y, 1.), T(p.z, 0.) );
    T vz = surf( T(p.x, 0.), T(p.y, 0.), T(p.z, 1.) );
    vec3 grad = vec3(vx.y,vy.y,vz.y);

    //the value of the function is automatically computed in each of the above:
    float val = vx.x;

    return vec4(grad,val);
}


//-------------------------------------------------
// my stuff: building the sextic in our world
// -------------------------

struct Variety{
    vec3 center;
    float size;
    float inside;
    float outside;
    float boundingSphere;
    float smoothing;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Variety surf ){

    //normalize position
    vec3 pos = p - surf.center;
    float rad = length(pos);
    pos *= surf.size;

    //get the distance estimate
    vec4 data = surf_Data(pos);
    float val = data.w;
    float gradLength = length(data.xyz)*surf.size;
    float dist = DE(val, gradLength);

    //adjust to account for thickness of surface
    dist=abs(dist+surf.inside)-surf.inside-surf.outside;



    //vec3 q = abs(pos) - vec3(20,8,20);
   // float bboxDist = length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);

    float bboxDist = abs(pos.y)-8.;

    //float bboxDist = rad-surf.boundingSphere;
    //adjust for the bounding box
    dist = smax(dist,bboxDist,surf.smoothing);

    return dist;
}



float distR3( Vector tv, Variety surf ){

    //normalize position
    vec3 pos = tv.pos - surf.center;
    float rad = length(pos);
    pos *= surf.size;

    //get the distance estimate
    vec4 data = surf_Data(pos);
    float val = data.w;
    float gradLength = length(data.xyz)/surf.size;
    float dist = DE(val, gradLength);

    //adjust to account for thickness of surface
    dist=abs(dist+surf.inside)-surf.inside-surf.outside;
    //adjust for the bounding box
    dist = smax(dist,rad-surf.boundingSphere,surf.smoothing);

    return dist;
}

//overload of location booleans:
bool at( Vector tv, Variety surf){
    float d = distR3( tv.pos, surf );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Variety surf ){
    float d = distR3( tv.pos, surf );
    return (d<0.);
}

//overload of sdf for a sphere
float sdf( Vector tv, Variety surf ){
    //distance to closest point on sphere
    return distR3(tv.pos, surf);
}

//overload of normalVec for a sphere
Vector normalVec( Vector tv, Variety surf ){

    vec3 pos =tv.pos;
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;//this normalization makes exyy etc all unit vectors;

    float vxyy=distR3( pos + e.xyy*ep, surf);
    float vyyx=distR3( pos + e.yyx*ep, surf);
    float vyxy=distR3( pos + e.yxy*ep, surf);
    float vxxx=distR3( pos + e.xxx*ep, surf);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}

////setData for a two sided surface
//void setData( inout Path path, Variety surf ){
//
//    //if we are at the surface
//    if(at(path.tv, surf)){
//        //compute the normal
//        Vector normal=normalVec(path.tv,surf);
//        Material mat=surf.mat;
//
//        //check if we are on the outside edge:
//        float rad = length(path.tv.pos-surf.center);
//        bool onEdge = (abs(rad-surf.boundingSphere)<0.005);
//
//        if(onEdge){
//            mat.diffuseColor=vec3(0.0);
//            //set the material
//            setObjectInAir(path.dat, false, normal, mat);
//        }
//        else {
//
//            //what side of the variety are we on?
//            vec3 pos = path.tv.pos - surf.center;
//            pos *= surf.size;
//            float val= surf_Data(pos).w;
//            //val positive is one side, val negative is the other;
//
//            if(val<0.){
//                mat.diffuseColor=surf.mat.diffuseColorBack;
//            }
//            else{
//                mat.diffuseColor=surf.mat.diffuseColor;
//            }
//
//            bool side = inside(path.tv, surf);
//            setObjectInAir(path.dat, side, normal, mat);
//        }
//    }
//
//}



//setData for a single sided, volume material
void setData( inout Path path, Variety surf ){

    //if we are at the surface
    if(at(path.tv, surf)){

        //compute the normal
        Vector normal=normalVec(path.tv,surf);
        Material mat=surf.mat;

        bool side = inside(path.tv, surf);
        setObjectInAir(path.dat, side, normal, mat);
        }
}
























/// original stuff from Knighty Fragmentarium Shaders:
// The following functions for various surfaces are
// taken from Abdelaziz Nait Merzouk's Fragmentarium
// shaders.
// https://plus.google.com/114982179961753756261
//
//float Labs(vec4 p) {
//    float x = p.x;
//    float y = p.y;
//    float z = p.z;
//    float w = p.w;
//    // float a = -0.140106854987125;//the real root of 7*a^3+7*a+1=0
//    // Constants
//    float a1= -0.0785282014969835;//(-12./7.*a-384./49.)*a-8./7.;
//    float a2= -4.1583605922880200;//(-32./7.*a+24./49.)*a-4.;
//    float a3= -4.1471434889655100;//(-4.*a+24./49.)*a-4.;
//    float a4= -1.1881659380714800;//(-8./7.*a+8./49.)*a-8./7.;
//    float a5= 51.9426145948147000;//(49.*a-7.)*a+50.;
//    float x2 = x*x,y2 = y*y,z2 = z*z,w2 = w*w;
//    float r2= x2+y2;
//    float U = (z+w)*r2+(a1*z+a2*w)*z2+(a3*z+a4*w)*w2;
//    U = (z+a5*w)*U*U;
//    float P = x*((x2-3.0*7.0*y2)*x2*x2+(5.0*7.0*x2-7.0*y2)*y2*y2);
//    P += z*(7.0*(((r2-8.0*z2)*r2+16.0*z2*z2)*r2)-64.0*z2*z2*z2);
//    return U-P;
//}
//
//float Endrass8(vec4 p){
//    float x = p.x;
//    float y = p.y;
//    float z = p.z;
//    float w = p.w;
//    float x2 = x*x,y2 = y*y,z2 = z*z,w2 = w*w;
//    float r2 = x2+y2;
//    float U = 64.0*(x2-w2)*(y2-w2)*((x+y)*(x+y)-2.0*w2)*((x-y)*(x-y)-2.0*w2);
//    float V = -4.0*(1.0+sqrt(2.0))*r2*r2+(8.0*(2.0+sqrt(2.0))*z2+2.0*(2.0+7.0*sqrt(2.0))*w2)*r2;
//    V = V + z2*(-16.0*z2+8.0*(1.0-2.0*sqrt(2.0))*w2) - (1.0+12.0*sqrt(2.0))*w2*w2;
//    return V*V-U;
//}
//
//float Barth10(vec4 p){//decic
//    float r2 = dot(p.xyz,p.xyz);
//    vec4 p2 = p*p;
//    float r4 = dot(p2.xyz,p2.xyz);
//    vec4 p4 = p2*p2;
//    return (8.0*(p2.x-phi4*p2.y)*(p2.y-phi4*p2.z)*(p2.z-phi4*p2.x)*(r4-2.0*((p.x*p.y)*(p.x*p.y)+(p.x*p.z)*(p.x*p.z)+(p.y*p.z)*(p.y*p.z)))+(3.0+5.0*phi)*(r2-p2.w)*(r2-p2.w)*(r2-(2.0-phi)*p2.w)*(r2-(2.0-phi)*p2.w)*p2.w);
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
//float Kummer(vec4 P) {
//    float A = sqrt(2.0);
//    float mu2 = 0.334 + 3.0*(1.0-cos(0.2*iTime));
//    float x = P.x; float y = P.y;
//    float z = P.z; float w = P.w;
//    float p = w-z-A*x;
//    float q = w-z+A*x;
//    float r = w+z+A*y;
//    float s = w+z-A*y;
//    float lambda = (3.0*mu2-1.0)/(3.0-mu2);
//    float k = x*x + y*y + z*z - mu2*w*w;
//    return k*k-lambda*p*q*r*s;
//}