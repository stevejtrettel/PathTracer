//------------------------------------------------
//The LOCAL DATA Struct
//-------------------------------------------------

struct localData{

    bool isPhysical;
    bool isSky;

    float side;

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

    Vector normal;//outward pointing (back at you) normal to surface just impacted
};


localData trashDat;

void initializeData(localData dat){
    dat.isSky=false;
    dat.isPhysical=true;

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

    localData dat;


    bool keepGoing;
    float distance; //distance traveled on a bounce

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

    path.type=1;
    path.prob=1.;

    initializeData(path.dat);

    path.debug=vec3(0.);
    path.absorb=vec3(0.);
    return path;

}








