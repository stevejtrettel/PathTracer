
//-------------------------------------------------
//A KLEINIAN LIMIT SET
//-------------------------------------------------

//the data of a kleinian limit set is its frame
struct Kleinian{
    Frame frame;
    Material mat;
};



// Kleinian group distance estimator

//some background functions used in both:
//sphere inversion
const bool SI=true;
const vec3 InvCenter=vec3(0,1,1);
//alternate inversion centers:
//vec3(0.25,1,.5);
//vec3(1,1,0.);

const float rad=0.8;

vec2 wrap(vec2 x, vec2 a, vec2 s){
    x -= s;
    return (x-a*floor(x/a)) + s;
}

void TransA(inout vec3 z, inout float DF, float a, float b){
    float iR = 1. / dot(z,z);
    z *= -iR;
    z.x = -b - z.x; z.y = a + z.y;
    DF *= iR;
}


//This is the SEAHORSE FUNCTION
// Jos Leys & Knighty https://www.shadertoy.com/view/XlVXzh
const vec2 box_size = vec2(-0.40445, 0.34) * 2.;

float SeahorseKleinian(vec3 z)
{

    float t = 0.;
    //alternate parameter values (the originals, used by JosKleinian below):
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

    float DE = 1e12;
    float DF = 1.;
    float a = KleinR;
    float b = KleinI;
    float f = sign(b) * .45;
    for (int i = 0; i < 50 ; i++)
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

        //Store previous iterates
        llz=lz; lz=z;
    }

    float y =  min(z.y, a - z.y);
    DE = min(DE, min(y, .3) / max(DF, 2.));
    //SI distance correction, deliberately left disabled here; JosKleinian (below) runs with it enabled
    //    if (SI) {
    //        DE = DE * d2 / (rad + d * DE);
    //    }

    return 0.75*DE;
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

        //Store previous iterates
        llz=lz; lz=z;
    }


    float y =  min(z.y, a-z.y) ;
    DE=min(DE,min(y,0.3)/max(DF,2.));
    if (SI) {DE=DE*d2/(rad+d*DE);}
    return DE;
}





//the local-frame sdf
float sdf( vec3 p, Kleinian klein ){
    return SeahorseKleinian(p);
}


//initObject, at, inside, and the Vector-level sdf
OBJECT_INIT(Kleinian)
OBJECT_LOCATORS(Kleinian)

//overload of normalVec: kept hand-written, uses a smaller epsilon (0.00001)
//than the standard macro (0.0001); finite differences of the local sdf,
//gradient rotated back to world
Vector normalVec( Vector tv, Kleinian klein ){

    vec3 q = toLocal(klein.frame, tv.pos);

    const float ep = 0.00001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=sdf( q + e.xyy*ep, klein);
    float vyyx=sdf( q + e.yyx*ep, klein);
    float vyxy=sdf( q + e.yxy*ep, klein);
    float vxxx=sdf( q + e.xxx*ep, klein);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos, dirToWorld(klein.frame, dir));

}

//the standard setData
OBJECT_SETDATA(Kleinian)

