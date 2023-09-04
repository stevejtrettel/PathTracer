//-------------------------------------------------
// FRACTALS
// a Fractal is raymarched with distance estimation
// these are "basic objects" that can be used to build more complex ones
//-------------------------------------------------









//-------------------------------------------------
//The APOLLONIAN GASKET sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Gasket{
    vec3 center;
    float radius;
    Material mat;
};


//auxillary function for calculating this
float apollonian(vec3 p)
{
    float K=0.4;
    float scale = 1.0;
    vec4 orb = vec4(1000.0);

    for( int i=0; i < 10;  i++ )
    {
        p = -1.0 + 2.0*fract(0.5*p+0.5);
        float r2 = dot(p,p);
        orb = min( orb, vec4(abs(p),r2) );
        float k = (1.0 + K)/r2;
        p *= k;
        scale *= k;
    }

    //this adds in balls insteaad
    float res = abs(p.y);
    //
    //    float  res = min(abs(p.z)+abs(p.x),
    //    min(abs(p.x)+abs(p.y),
    //    abs(p.y)+abs(p.z)));

    return 0.25/scale*res;
}

float sqrt3=sqrt(3.);
vec3 triangles(vec3 p){
    float zm = 1.;
    p.x = p.x-sqrt3*(p.y+.5)/3.;
    p = vec3(mod(p.x+sqrt3/2.,sqrt3)-sqrt3/2., mod(p.y+.5,1.5)-.5 , mod(p.z+.5*zm,zm)-.5*zm);
    p = vec3(p.x/sqrt3, (p.y+.5)*2./3. -.5 , p.z);
    p = p.y>-p.x ? vec3(-p.y,-p.x , p.z) : p;
    p = vec3(p.x*sqrt3, (p.y+.5)*3./2.-.5 , p.z);
    return vec3(p.x+sqrt3*(p.y+.5)/3., p.y , p.z);
}


vec4 orb;
//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Gasket gasket ){

    p-=gasket.center;
    p=gasket.radius*p;

    p /= dot(p,p);
    p += vec3(1.0);
    p*=5.;



    //    float scale = 1.;
    //    float s = 1./3.;
    //    for( int i=0; i<20;i++ )
    //    {
    //        p = triangles(p);
    //        float r2= dot(p,p);
    //        float k = s/r2;
    //        p = p * k;
    //        scale=scale*k;
    //    }
    //    return .3*length(p)/scale -.001/sqrt(scale);


    //********************************************************************************
    //

    float scale = 1.0;
    float s=1.5;
    orb = vec4(1000.0);

    for( int i=0; i<10;i++ )
    {
        p = -1.0 + 2.0*fract(0.5*p+0.5);

        float r2 = dot(p,p);

        orb = min( orb, vec4(abs(p),r2) );

        float k = s/r2;
        p     *= k;
        scale *= k;
    }
    float  res = min(abs(p.z)+abs(p.x),min(abs(p.x)+abs(p.y),abs(p.y)+abs(p.z)))+0.2;
    //float res=abs(p.y);
    float dist= 0.25*res/scale;
    return dist;

    //********************************************************************************


    //    float scale = 6.0;
    //    vec3 q=p;
    //    p /= scale;
    //    float s = 1.0;
    ////    if (doInversion) {
    //        s = dot(p,p);
    //        p /= s;
    //        p += vec3(1.0);
    ////    }
    //    //if (doTranslate) p.y += 0.1*iTime;
    //    float d0=apollonian(p)*scale;
    //    float d = d0;
    //    return d*s;
}






//-------------------
// ONE ALTERNATIVE GASKET
//-------------------
//
//float sqrt3 =1.73205080757;
//vec3 triangles(vec3 p){
//    float zm = 1.;
//    p.x = p.x-sqrt3*(p.y+.5)/3.;
//    p = vec3(mod(p.x+sqrt3/2.,sqrt3)-sqrt3/2., mod(p.y+.5,1.5)-.5 , mod(p.z+.5*zm,zm)-.5*zm);
//    p = vec3(p.x/sqrt3, (p.y+.5)*2./3. -.5 , p.z);
//    p = p.y>-p.x ? vec3(-p.y,-p.x , p.z) : p;
//    p = vec3(p.x*sqrt3, (p.y+.5)*3./2.-.5 , p.z);
//    return vec3(p.x+sqrt3*(p.y+.5)/3., p.y , p.z);
//}
//float distR3(vec3 p, Gasket gasket){
//
//    p-=gasket.center;
//    p=gasket.radius*p;
//
//    p /= dot(p,p);
//    p += vec3(1.0);
//    p*=5.;
//
//    float scale = 1.;
//    float s = 1./3.;
//    for( int i=0; i<10;i++ )
//    {
//        p = triangles(p);
//        float r2= dot(p,p);
//        float k = s/r2;
//        p = p * k;
//        scale=scale*k;
//    }
//    return .3*length(p)/scale		-.001/sqrt(scale);
//}
//


//-------------------
// ANOTHER ALTERNATIVE GASKET: SIMPLE!
//-------------------
//float distR3( vec3 p, Gasket gasket )
//{
//
//    p-=gasket.center;
//    p=gasket.radius*p;
//
//    p /= dot(p,p);
//    p += vec3(1.0);
//    p*=5.;
//
//
//    float s = 1.1;
//    float scale = 1.0;
//
//    for( int i=0; i<8;i++ )
//    {
//        p = -1.0 + 2.0*fract(0.5*p+0.5);
//
//        float r2 = dot(p,p);
//
//        float k = s/r2;
//        p     *= k;
//        scale *= k;
//    }
//
//    return 0.25*abs(p.y)/scale;
//}


//overload of location booleans:
bool at( Vector tv, Gasket gasket){
    return true;
    float d = distR3( tv.pos, gasket );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Gasket gasket ){
    //return false;
    float d = distR3( tv.pos, gasket );
    return (d<0.);
}




//overload of sdf for a gasket
float sdf( Vector tv, Gasket gasket ){

    //distance to closest point on fractal
    return distR3(tv.pos, gasket);

}

//overload of normalVec for a sphere
Vector normalVec( Vector tv, Gasket gasket ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, gasket);
    float vyyx=distR3( pos + e.yyx*ep, gasket);
    float vyxy=distR3( pos + e.yxy*ep, gasket);
    float vxxx=distR3( pos + e.xxx*ep, gasket);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}


//overload of trace for a gasket
float trace( Vector tv, Gasket gasket ){
    vec3 ro=tv.pos;
    vec3 rd=tv.dir;

    //
    //        float pixelRadius= 1.0/(iResolution.y * 2.0);
    //        float t = 0.002;
    //        float h = 5.;
    //        for( int i=0; i<512; i++ )
    //        {
    //            if(h<t*pixelRadius || t>maxDist){break;}
    //            h =distR3( ro+rd*t, gasket );
    //            t += h;
    //        }
    //        if(h>t*pixelRadius){t=maxDist*2.;}
    //        return t;
    //


    //**************************************************************


    float t = 0.001;
    for( int i=0; i<512; i++ )
    {
        float precis = 0.001*t;
        // float precis = 0.001;
        float h = distR3( ro+rd*t, gasket);
        if( h<precis||t>maxDist) break;
        t += h;
    }
    return t;
    //**************************************************************
    //    vec3 ro=tv.pos;
    //    vec3 rd=tv.dir;
    //    float pixel_size = 1.0/(iResolution.y * 2.0);
    //    float t = 1.0;
    //
    //    for( int i=0; i<2048; i++ )
    //    {
    //        float c = distR3(ro + rd*t,gasket);
    //        if( c<0.5*pixel_size*t ) break;
    //        t += c;
    //        if( t>100.0 ) return maxDist;
    //    }
    //    return t;

}



//overload of setData for a sphere
void setData( inout Path path, Gasket gasket){

    //if we are at the surface
    if(at(path.tv, gasket)){
        //compute the normal
        Vector normal=normalVec(path.tv,gasket);
        bool side = inside(path.tv, gasket);
        //set the material
        setObjectInAir(path.dat, side, normal, gasket.mat);
    }
}










//-------------------------------------------------
//A KLEINIAN LIMIT SET
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Kleinian{
    vec3 center;
    Material mat;
};



// Kleinian group distance estimator

//some background functions used in both:
//sphere inversion
bool SI=true;
vec3 InvCenter=vec3(0,1,1);
//vec3(0.25,1,.5);
//vec3(1,1,0.);

float rad=0.8;

vec2 wrap(vec2 x, vec2 a, vec2 s){
    x -= s;
    return (x-a*floor(x/a)) + s;
}

void TransA(inout vec3 z, inout float DF, float a, float b){
    float iR = 1. / dot(z,z);
    z *= -iR;
    z.x = -b - z.x; z.y = a + z.y;
    DF *= iR;//max(1.,iR);
}


//This is the SEAHORSE FUNCTION
// Jos Leys & Knighty https://www.shadertoy.com/view/XlVXzh
vec2 box_size = vec2(-0.40445, 0.34) * 2.;

float SeahorseKleinian(vec3 z)
{

    float t = 0.;
    //float KleinR = 1.95859103011179;
    //float KleinI = 0.0112785606117658;
    float KleinR = 1.5 + .39;
    float KleinI = (.55 * 2. - 1.);
    vec3 lz=z+vec3(1.), llz=z+vec3(-1.);
    float d=0.; float d2=0.;

    if (SI) {
        z=z-InvCenter;
        d=length(z);
        d2=d*d;
        z=(rad*rad/d2)*z+InvCenter;
    }

    // vec3 orbitTrap = vec3(1e20);

    float DE = 1e12;
    float DF = 1.;
    float a = KleinR;
    float b = KleinI;
    float f = sign(b) * .45;
    for (int i = 0; i < 80 ; i++)
    {
        z.x += b / a * z.y;
        z.xz = wrap(z.xz, box_size * 2., -box_size);
        z.x -= b / a * z.y;

        //If above the separation line, rotate by 180° about (-b/2, a/2)
        if  (z.y >= a * 0.5 + f *(2.*a-1.95)/4. * sign(z.x + b * 0.5)* (1. - exp(-(7.2-(1.95-a)*15.)* abs(z.x + b * 0.5))))
        {z = vec3(-b, a, 0.) - z;}

        //Apply transformation a
        TransA(z, DF, a, b);

        //If the iterated points enters a 2-cycle , bail out.
        if(dot(z-llz,z-llz) < 1e-5) {break;}

        //Store prévious iterates
        llz=lz; lz=z;

        // orbitTrap = min(orbitTrap, z);
    }

    float y =  min(z.y, a - z.y);
    DE = min(DE, min(y, .3) / max(DF, 2.));
    if (SI) {
        DE = DE * d2 / (rad + d * DE);
    }

    return DE;
    // return vec4(DE, orbitTrap);
}







//alternative (original) distance function

float box_size_x=1.;
float box_size_z=1.;
float  JosKleinian(vec3 z)
{
    float KleinR = 1.95859103011179;
    float KleinI = 0.0112785606117658;
    vec3 lz=z+vec3(1.), llz=z+vec3(-1.);
    float d=0.; float d2=0.;

    if(SI) {
        z=z-InvCenter;
        d=length(z);
        d2=d*d;
        z=(rad*rad/d2)*z+InvCenter;
    }

    float DE=1e10;
    float DF = 1.0;
    float a = KleinR;
    float b = KleinI;
    float f = sign(b)*1. ;
    for (int i = 0; i < 20 ; i++)
    {
        z.x=z.x+b/a*z.y;
        z.xz = wrap(z.xz, vec2(2. * box_size_x, 2. * box_size_z), vec2(- box_size_x, - box_size_z));
        z.x=z.x-b/a*z.y;

        //If above the separation line, rotate by 180° about (-b/2, a/2)
        if  (z.y >= a * 0.5 + f *(2.*a-1.95)/4. * sign(z.x + b * 0.5)* (1. - exp(-(7.2-(1.95-a)*15.)* abs(z.x + b * 0.5))))
        {z = vec3(-b, a, 0.) - z;}

        //Apply transformation a
        TransA(z, DF, a, b);

        //If the iterated points enters a 2-cycle , bail out.
        if(dot(z-llz,z-llz) < 1e-5) {break;}

        //Store prévious iterates
        llz=lz; lz=z;
    }


    float y =  min(z.y, a-z.y) ;
    DE=min(DE,min(y,0.3)/max(DF,2.));
    if (SI) {DE=DE*d2/(rad+d*DE);}
    return DE;
}





//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Kleinian klein ){
    //normalize position
    vec3 pos = p - klein.center;
    return SeahorseKleinian(pos);
}


//overload of location booleans:
bool at( Vector tv, Kleinian klein){

    float d = distR3( tv.pos, klein );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Kleinian klein ){
    float d = distR3( tv.pos, klein );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, Kleinian klein ){

    //distance to closest point on sphere
    return distR3(tv.pos, klein);

}

//overload of normalVec for a sphere
Vector normalVec( Vector tv, Kleinian klein ){

    vec3 pos=tv.pos;

    const float ep = 0.00001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, klein);
    float vyyx=distR3( pos + e.yyx*ep, klein);
    float vyxy=distR3( pos + e.yxy*ep, klein);
    float vxxx=distR3( pos + e.xxx*ep, klein);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}

//overload of setData for a sphere
void setData( inout Path path, Kleinian klein ){

    //if we are at the surface
    if(at(path.tv, klein)){
        //compute the normal
        Vector normal=normalVec(path.tv,klein);
        bool side = inside(path.tv, klein);
        //set the material
        // vec4 col = JosKleinian(path.tv.pos);
        //klein.mat.diffuseColor=col.yzw;
        setObjectInAir(path.dat, side, normal, klein.mat);
    }

}






















