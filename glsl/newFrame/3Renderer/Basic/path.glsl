
//-------------------------------------------------
//The RayType Struct
//-------------------------------------------------

struct RayType{
    bool diffuse;
    bool specular;
    bool refract;
    float probability;
};



RayType intializeRayType(){

    //default behavior for a ray is diffuse
    RayType type;
    type.diffuse=true;
    type.specular=false;
    type.refract=false;
    type.probability=1.;

    return type;
}




void setSpecular(inout RayType type,float prob){

    type.diffuse=false;
    type.specular=true;
    type.refract=false;
    type.probability=prob;
}


void setDiffuse(inout RayType type,float prob){

    type.diffuse=true;
    type.specular=false;
    type.refract=false;
    type.probability=prob;
}


void setRefract(inout RayType type,float prob){

    type.diffuse=false;
    type.specular=false;
    type.refract=true;
    type.probability=prob;
}





//------------------------------------------------
//The LOCAL DATA Struct
//-------------------------------------------------

struct localData{
    bool isSky;
    bool isLight;
    bool materialInterface;//are we at the interface of two materials, or at an air/material interface

    Vector normal;//outward pointing (back at you) normal to surface just impacted

    Material mat;//material used in coloring

    float IOR;//the ratio of index of refraction
//curernt material divided by entering material

    vec3 reflectAbsorb;//absorbtion of material if we reflect
    vec3 refractAbsorb;//absorbation of material if we refract

};


localData trashDat;

void initializeData(localData dat){
    dat.isSky=false;
    dat.isLight=false;
    dat.materialInterface=false;
    dat.reflectAbsorb=vec3(0.);
    dat.refractAbsorb=vec3(0.);
}




























//-------------------------------------------------
//The Path Struct
//-------------------------------------------------


struct Path{

    Vector tv; //direction of tracing
    vec3 pixel;//pixel color
    vec3 light;//light along path

    bool keepGoing;
    float distance; //distance traveled on a bounce
    RayType type;

    localData dat;

    vec3 absorb;
    vec3 debug;
};





Path initializePath(Vector tv){
    Path path;

    path.tv=tv;//set the initial direction
    path.pixel=vec3(0.);//set the pixel black
    path.light=vec3(1.);

    path.distance=0.;
    path.keepGoing=true;
    // path.inside=false;
    path.type=intializeRayType();

    initializeData(path.dat);

    path.debug=vec3(0.);
    path.absorb=vec3(0.);
    return path;
}









