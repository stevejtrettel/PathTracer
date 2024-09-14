
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

        //Store prévious iterates
        llz=lz; lz=z;

        // orbitTrap = min(orbitTrap, z);
    }

    float y =  min(z.y, a - z.y);
    DE = min(DE, min(y, .3) / max(DF, 2.));
    //    if (SI) {
    //        DE = DE * d2 / (rad + d * DE);
    //    }

    return 0.75*DE;
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





