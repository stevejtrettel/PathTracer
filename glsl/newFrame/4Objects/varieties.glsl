//-------------------------------------------------
// ALGEBRAIC VARIETIES
// a Variety is a bounding box (some basic object)
// together with an equation describing a surface in its interior
//-------------------------------------------------



//----useful funtion for rescaling:
vec3 rescaleCoords(Point p,Point center, float scale){
    return scale*(p.coords-center.coords);
}







//-------------------------------------------------
// The BARTH SEXTIC variety
//-------------------------------------------------

struct BarthSextic{
    Sphere boundingBox;
    Point center;
    float scale;
    Material mat;
};


float barthSexticEqn(vec3 p){

    float x=p.x;
    float y=p.y;
    float z=p.z;

    return x*x+y*y+z*z-0.2;

//    float t = 1.618034;
//
//    return 4.*(t*t*x*x - y*y ) * ( t*t *y*y - z*z ) *( t*t* z*z - x*x )
//    - ( 1. + 2.*t) *(x*x + y*y + z*z- 1.)*(x*x + y*y + z*z- 1.);

}

//overload of variety for the barth sextic struct:
float variety(Vector tv, BarthSextic var){

    //if outside the bounding box, dont even bother computing:
    if(sphereDistance(tv,var.boundingBox)>0.){
        return 1.;
    }

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

    //see if we are at the plane: if not, do nothing
    float dist=variety(path.tv,var);

    if(abs(dist)<5.*EPSILON&&sphereDistance(path.tv,var.boundingBox)<0.){

        path.pixel+=vec3(1,0,0);
//        //compute the normal
//        Vector normal=normalVec(path.tv,var);
//
//        //set the material
//        setObjectInAir(path.dat,dist,normal,var.mat);
    }

}




























