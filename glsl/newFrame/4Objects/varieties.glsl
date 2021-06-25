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
// The BARTH SEXTIC variety
//-------------------------------------------------

struct BarthSextic{
    Sphere boundingBox;
    vec3 center;
    float scale;
    Material mat;
};


float barthSexticEqn(vec3 p){

    float x=p.y;
    float y=p.z;
    float z=-p.x;

    //AN ELLIPTIC SURFACE
    //return 4.*(1.-x*x+y+z+y*z)+2.*(x*z+z*z)+(x*x*x-x-x*x*y-y*y-x*y*y-y*y*y+x*y*z-y*y*z+x*z*z+y*z*z+z*z*z);

    float t = 1.618034;

    return 4.*(t*t*x*x - y*y ) * ( t*t *y*y - z*z ) *( t*t* z*z - x*x )
    - ( 1. + 2.*t) *(x*x + y*y + z*z- 1.)*(x*x + y*y + z*z- 1.);

}

//overload of variety for the barth sextic struct:
float variety(Vector tv, BarthSextic var){

    //otherwise, get the value
    vec3 pos=rescaleCoords(tv.pos,var.center,var.scale);
    return barthSexticEqn(pos);

}

//overload of the normal vector function for the barth sextic struct:
Vector normalVec(Vector tv, BarthSextic var){

    vec3 pos=rescaleCoords(tv.pos,var.center,var.scale);

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=barthSexticEqn( pos + e.xyy*ep);
    float vyyx=barthSexticEqn( pos + e.yyx*ep);
    float vyxy=barthSexticEqn( pos + e.yxy*ep);
    float vxxx=barthSexticEqn( pos + e.xxx*ep);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    return Vector(tv.pos,normalize(dir));

}


void setData(inout Path path, BarthSextic var){
    Vector normal;
    bvec2 bBoxLoc=relPosition(path.tv, var.boundingBox);

    if(bBoxLoc.x){
        //if we are at the surface of the bounding box:
        setData(path,var.boundingBox);
    }


    //if we are inside the bounding box AND near the variety, set that material
    float distVar=variety(path.tv, var);
    if (bBoxLoc.y && abs(distVar) < 0.1){
        normal=normalVec(path.tv, var);
        setSurfaceInMat(path.dat, distVar, normal, var.mat,var.boundingBox.mat);
    }

}