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
    Material surface;
};


float barthSexticEqn(vec3 p){

    float x=p.x;
    float y=p.y;
    float z=p.z;

    float t = 1.618034;

    return 4.*(t*t*x*x - y*y ) * ( t*t *y*y - z*z ) *( t*t* z*z - x*x )
    - ( 1. + 2.*t) *(x*x + y*y + z*z- 1.)*(x*x + y*y + z*z- 1.);

}

//overload of variety for the barth sextic struct:
float variety(Path path, BarthSextic Var){

    //if outside the bounding box, dont even bother computing:
    if(sphereDistance(path.tv,Var.boundingBox)>0.){
        return 1.;
    }

    //otherwise, get the value
    vec3 pos=rescaleCoords(path.tv.coords,center,scale);
    return barthSexticEqn(pos);

}






























