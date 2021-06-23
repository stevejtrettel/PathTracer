
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
    bool materialInterface;//are we at the interface of two materials, or at an air/material interface

    Vector normal;//outward pointing (back at you) normal to surface just impacted

    float distanceTraveled;
    vec3 surfaceDiffuse;
    vec3 surfaceSpecular;
    vec3 surfaceEmit;
    vec3 currentAbsorb;
    vec3 currentEmit;
    vec3 neighborAbsorb;
    vec3 neighborEmit;
    float IOR;
    float reflectionChance;
    float refractionChance;
    float diffuseChance;
};


localData trashDat;

void initializeData(localData dat){
    dat.isSky=false;
    dat.materialInterface=false;

    dat.distanceTraveled=0.;
    dat.surfaceDiffuse=vec3(0.);
    dat.surfaceSpecular=vec3(0.);
    dat.surfaceEmit=vec3(0.);
    dat.currentAbsorb=vec3(0.);
    dat.currentEmit=vec3(0.);
    dat.neighborAbsorb=vec3(0.);
    dat.neighborEmit=vec3(0.);
    dat.IOR=1.;
    dat.reflectionChance=0.;
    dat.refractionChance=1.;
    dat.diffuseChance=0.;
}







//-------------------------------------------------
//The Path Struct
//-------------------------------------------------


struct Path{
    Vector tv; //direction of tracing
    vec3 pixel;//pixel color
    vec3 light;//light along path

    RayType type;
    localData dat;
    bool keepGoing;
};





Path initializePath(Vector tv){
    Path path;

    path.tv=tv;//set the initial direction
    path.pixel=vec3(0.);//set the pixel black
    path.light=vec3(1.);

    path.keepGoing=true;
    path.type=intializeRayType();
    initializeData(path.dat);

    return path;
}









