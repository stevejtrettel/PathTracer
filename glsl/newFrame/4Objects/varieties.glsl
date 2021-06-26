//-------------------------------------------------
// ALGEBRAIC VARIETIES
// a Variety is a bounding box (some basic object)
// together with an equation describing a surface in its interior
//-------------------------------------------------



//----useful funtion for rescaling:
vec3 rescaleCoords(vec3 p, vec3 center, float scale){
    return scale*(p-center);
}


//-------------------------------------------------
// The GENERIC variety
//-------------------------------------------------

struct IsoSurface{
    Sphere boundingBox;
    vec3 center;
    float scale;
    Material mat;
};


float isoSurfEqn(vec3 p){

    float x=p.y;
    float y=p.z;
    float z=-p.x;

    //AN ELLIPTIC SURFACE
    //return 4.*(1.-x*x+y+z+y*z)+2.*(x*z+z*z)+(x*x*x-x-x*x*y-y*y-x*y*y-y*y*y+x*y*z-y*y*z+x*z*z+y*z*z+z*z*z);

    float t = 1.618034;

    return 4.*(t*t*x*x - y*y ) * ( t*t *y*y - z*z ) *( t*t* z*z - x*x )
    - ( 1. + 2.*t) *(x*x + y*y + z*z- 1.)*(x*x + y*y + z*z- 1.);

}

//overload of variety for this case
float variety(Vector tv, IsoSurface var){

    //otherwise, get the value
    vec3 pos=rescaleCoords(tv.pos,var.center,var.scale);
    return isoSurfEqn(pos);

}

//overload of the normal vector function for the barth sextic struct:
Vector normalVec(Vector tv, IsoSurface var){

    vec3 pos=rescaleCoords(tv.pos,var.center,var.scale);

    const float ep = 0.001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=isoSurfEqn( pos + e.xyy*ep);
    float vyyx=isoSurfEqn( pos + e.yyx*ep);
    float vyxy=isoSurfEqn( pos + e.yxy*ep);
    float vxxx=isoSurfEqn( pos + e.xxx*ep);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    return Vector(tv.pos,normalize(dir));

}


void setData(inout Path path, IsoSurface var){
    Vector normal;

    bool inBBox = inside(path.tv, var.boundingBox);

    if(at(path.tv, var.boundingBox)){
        //if we are at the surface of the bounding box:
        //set the bounding box material against air
        Vector normal=normalVec(path.tv, var.boundingBox);
        setObjectInAir(path.dat, inBBox, normal, var.boundingBox.mat);
    }

    //if we are inside the bounding box AND near the variety, set that material
    float distVar=variety(path.tv, var);
    if(inBBox && abs(distVar) < 0.1){
        normal=normalVec(path.tv, var);
        setSurfaceInMat(path.dat, distVar, normal, var.mat, var.boundingBox.mat);
    }

}









//-------------------------------------------------
// The BARTH SEXTIC variety
//-------------------------------------------------

struct BarthSextic{
    Sphere boundingBox;
    vec3 center;
    float scale;
    Material mat;
};


float barthSexticEqn(vec3 p){

        float x=p.x;
        float y=p.y;
        float z=p.z;
        float w=1.;

        float x2=x*x;
        float y2=y*y;
        float z2=z*z;
        float w2=1.;
        float r2=x2+y2+z2;

    float sqrt2=sqrt(2.);

    float term1=64.*(x2-w2)*(y2-w2)*((x+y)*(x+y)-2.*w2)*((x-y)*(x-y)-2.*w2);

    float term21=-4.*(1.+sqrt2)*(x2+y2)*(x2+y2);
    float term22=(8.*(2.+sqrt2)*z2+2.*(2.+7.*sqrt2)*w2)*(x2+y2);
    float term23=-16.*z2*z2+8.*(1.-2.*sqrt2)*z2*w2-(1.+12.*sqrt2)*w2*w2;

    float term2=term21+term22+term23;

    float val = term1-term2*term2;

    return val;

//
//    float x=p.x;
//    float y=p.y;
//    float z=p.z;
//
//    float x2=x*x;
//    float y2=y*y;
//    float z2=z*z;
//    float r2=x2+y2+z2;
//
//    float t = 1.618034;
//    float t2=t*t;
//
//    return 4.*(t2*x2 - y2) * ( t2*y2 - z2 ) *( t2*z2 - x2 )
//    - ( 1. + 2.*t) *(r2- 1.)*(r2- 1.);

}



//overload of variety for the barth sextic struct:
float variety(Vector tv, BarthSextic var){

    //otherwise, get the value
    vec3 pos=rescaleCoords(tv.pos,var.center,var.scale);
    return barthSexticEqn(pos);
}



//overload of the gradient function for the barth sextic struct:
Vector normalVec(Vector tv, BarthSextic var){

    //do the rescalings
    vec3 pos=rescaleCoords(tv.pos,var.center,var.scale);

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=barthSexticEqn( pos + e.xyy*ep);
    float vyyx=barthSexticEqn( pos + e.yyx*ep);
    float vyxy=barthSexticEqn( pos + e.yxy*ep);
    float vxxx=barthSexticEqn( pos + e.xxx*ep);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    //divide by epsilon to give the gradient
    return Vector(tv.pos,normalize(dir));
}


void setData(inout Path path, BarthSextic var){
    Vector normal;
    float distVar;

    bool atBBox = at(path.tv, var.boundingBox);
    bool inBBox = inside(path.tv, var.boundingBox);

    if(atBBox){
        //if we are at the surface of the bounding box:
        //set the bounding box material against air
        Vector normal=normalVec(path.tv, var.boundingBox);
        setObjectInAir(path.dat, inBBox, normal, var.boundingBox.mat);
    }

    else if(inBBox ){
        //otherwise if we are inside, we must be on the variety itself
        distVar = variety(path.tv, var);
        normal = normalVec(path.tv, var);
        setSurfaceInMat(path.dat, distVar, normal, var.mat, var.boundingBox.mat);
    }

}