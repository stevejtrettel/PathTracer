//------------------------------------------------
//The LOCAL DATA Struct
//-------------------------------------------------

struct localData{

    bool isPhysical;
    bool isSky;
    bool renderMaterial;

    float side;
    bool subSurface;
    float meanFreePath;
    float isotropicScatter;
    vec3 surfDiffuse;
    vec3 surfSpecular;
    vec3 surfEmit;
    float surfRoughness;
    float probDiffuse;
    float probSpecular;
    float probRefract;
    float IOR;
    vec3 refractAbsorb;
    vec3 reflectAbsorb;
    vec3 refractEmit;
    vec3 reflectEmit;

    Vector normal;//outward pointing (back at you) normal to surface just impacted
};


localData trashDat;

void initializeData(localData dat){
    dat.subSurface=false;
    dat.isSky=false;
    dat.isPhysical=true;
    dat.renderMaterial=true;
    dat.reflectAbsorb=vec3(0.);
    dat.refractAbsorb=vec3(0.);
    dat.surfDiffuse=vec3(1.);
    dat.surfSpecular=vec3(1.);
    dat.surfEmit=vec3(0.);
    dat.surfRoughness=0.;
    dat.isotropicScatter=0.;
    dat.meanFreePath=1.;
    dat.reflectEmit=vec3(0);
    dat.refractEmit=vec3(0);
    dat.IOR=1.;
    dat.probDiffuse=1.;
    dat.probRefract=0.;
    dat.probSpecular=0.;
}






//-------------------------------------------------
//The Path Struct
//-------------------------------------------------


struct Path{

    Vector tv;
    vec3 pixel;//pixel color
    vec3 light;//light along path

    int type;//type of ray: 1=Diffuse, 2=Specular, 3=Refract
    float prob;//probability this type of ray was chosen;
    vec3 absorb;
    vec3 emit;
    float distance; //distance traveled on a bounce
    float totalDistance;// accumulated distance traveled along a ray.
    float numScatters;//num of scattering events, when this is the useful metric instead of distance
    localData dat;

    bool keepGoing;
    bool subSurface;

    vec3 debug;

};





Path initializePath(Vector tv){
    Path path;

    path.tv=tv;//set the initial direction
    path.pixel=vec3(0.);//set the pixel black
    path.light=vec3(1.);
    path.numScatters=0.;
    path.distance=0.;
    path.totalDistance=0.;
    path.keepGoing=true;
    path.subSurface=false;

    path.type=1;
    path.prob=1.;

    initializeData(path.dat);

    path.debug=vec3(0.);
    path.absorb=vec3(0.);
    path.emit = vec3(0);
    return path;

}








