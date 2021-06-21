
//-------------------------------------------------
// The ROOTFINDING LOOP: FOR VARIETIES
//-------------------------------------------------


float sexticEqn(vec3 pos){

    float scale=1.;
    vec3 center=vec3(0,0,0);

    float x=scale*(pos.x-center.x);
    float y=scale*(pos.y-center.y);
    float z=scale*(pos.z-center.z);

    float t = 1.618034;
    return 4.*(t*t*x*x - y*y ) * ( t*t *y*y - z*z ) *( t*t* z*z - x*x )
    - ( 1. + 2.*t) *(x*x + y*y + z*z- 1.)*(x*x + y*y + z*z- 1.);
}

float fermat(vec3 pos,float n){

    float scale=1.;
    vec3 center=vec3(0,0,0);

    float x=scale*(pos.x-center.x);
    float y=scale*(pos.y-center.y);
    float z=scale*(pos.z-center.z);


    return pow(x,abs(n))+pow(y,abs(n))+pow(z,abs(n))-1.;

}

float roman(vec3 pos){

    float scale=2.;
    vec3 center=vec3(0,0,-2);

    float x=scale*(pos.x-center.x);
    float y=scale*(pos.y-center.y);
    float z=scale*(pos.z-center.z);

    float x2=x*x;
    float y2=y*y;
    float z2=z*z;

    return x2*y2+y2*z2+z2*x2-2.*x*y*z;

}

float chmutov(vec3 pos,float c){

    float scale=2.;
    vec3 center=vec3(0,0,-2);

    float x=scale*(pos.x-center.x);
    float y=scale*(pos.y-center.y);
    float z=scale*(pos.z-center.z);

    float x2=x*x;
    float y2=y*y;
    float z2=z*z;

    return 8.*(x2*x2 + y2*y2 + z2*z2) - 8.*(x2 + y2 + z2) + 3.-c;

}



float gyroid(vec3 pos){
    float scale=5.;
    vec3 center=vec3(0,0,-2);

    float x=scale*(pos.x-center.x);
    float y=scale*(pos.y-center.y);
    float z=scale*(pos.z-center.z);

    return sin(x)*cos(y)+sin(y)*cos(z)+sin(z)*cos(x);
}



//float kummer(vec3 pos,float mu){
//
//    float scale=2.;
//    vec3 center=vec3(0,0,-2);
//
//    float x=scale*(pos.x-center.x);
//    float y=scale*(pos.y-center.y);
//    float z=scale*(pos.z-center.z);
//    float w=1.;
//
//    float x2=x*x;
//    float y2=y*y;
//    float z2=z*z;
//    float w2=w*w;
//
//    float x4=x2*x2;
//    float y4=y2*y2;
//    float z4=z2*z2;
//    float w4=w2*w2;
//
//    float a=1.;
//    float b=1.;
//    float c=1.;
//    float d=-0.0;
//
//    float term1=x4+y4+z4+w4;
//    float term2=2.*x*y*z*w;
//    float term3=x2*y2+z2*w2;
//    float term4=x2*z2+y2*w2;
//    float term5=x2*w2+y2*z2;
//
//    return term1+d*term2-a*term3-b*term4-c*term5;
//
//}





float kummer(vec3 pos,float mu){

    float scale=1.;
    vec3 center=vec3(0,0,-2.);

    float x=scale*(pos.x-center.x);
    float y=scale*(pos.y-center.y);
    float z=scale*(pos.z-center.z);

    float x2=x*x;
    float y2=y*y;
    float z2=z*z;

    float mu2=mu*mu;
    float lambda=(3.*mu*mu-1.)/(3.-mu*mu);
    float sqrt2=sqrt(2.);

    float p=1.-z-sqrt2*x;
    float q=1.-z+sqrt2*x;
    float r=1.+z+sqrt2*y;
    float s=1.+z-sqrt2*y;

    float quad=x2+y2+z2-mu2;

    return quad*quad-lambda*p*q*r*s;
}





float endrass(vec3 pos){

    float scale=1.;
    vec3 center=vec3(0,0,0);

    float x=scale*(pos.x-center.x);
    float y=scale*(pos.y-center.z);
    float z=scale*(pos.z-center.y);
    float w=1.;

    float x2=x*x;
    float y2=y*y;
    float z2=z*z;
    float w2=w*w;

    float sqrt2=sqrt(2.);

    float term1=64.*(x2-w2)*(y2-w2)*((x+y)*(x+y)-2.*w2)*((x-y)*(x-y)-2.*w2);

    float term21=-4.*(1.+sqrt2)*(x2+y2)*(x2+y2);
    float term22=(8.*(2.+sqrt2)*z2+2.*(2.+7.*sqrt2)*w2)*(x2+y2);
    float term23=-16.*z2*z2+8.*(1.-2.*sqrt2)*z2*w2-(1.+12.*sqrt2)*w2*w2;

    float term2=term21+term22+term23;

    return term1-term2*term2;


}



float togliatti(vec3 pos){

    float scale=5.;
    vec3 center=vec3(0,0,-2.);

    float x=scale*(pos.x-center.x);
    float z=scale*(pos.y-center.y);
    float y=scale*(pos.z-center.z);
    float w=1.;

//    float rt2=sqrt(2.);
//    float z=(u+v)/rt2;
//    float w=(u-v)/rt2;
//


    float x2=x*x;
    float y2=y*y;
    float z2=z*z;
    float w2=w*w;


    float term1 = 64.* (x - w) * (x2*x2 - 4.* x2*x* w - 10. *x2 *y2 - 4.*x2* w2 + 16.* x *w2*w -
    20.* x* y2 *w + 5.* y2*y2 + 16. *w2*w2 - 20. *y2 *w2);

    float term2 = -5.*sqrt(5. - sqrt(5.)) * (2.*z -sqrt(5. - sqrt(5.)* w));

    float term3=(4.*(x2 + y2 - z2) + (1. + 3.*sqrt(5.)) *w2);

    return term1+term2*term3*term3;

}