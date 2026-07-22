//------------------------------------------------
//The LOCAL DATA Struct
// everything the tracer needs to know about the surface the path just hit:
// filled in by the scene's setData functions (see objects/objectAPI.glsl and
// 3Materials/setImpactData.glsl), consumed by scatter() and updateFromSurface()
//-------------------------------------------------

struct LocalData{

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


void initializeData(inout LocalData dat){
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
// the full state of one light path as it bounces through the scene:
// pixel accumulates the color collected so far (from emitters and the sky);
// light is the throughput — how much any light found from here on
// contributes, attenuated at each surface/volume interaction.
//-------------------------------------------------


struct Path{

    Vector tv;
    vec3 pixel;//color collected so far along the path
    vec3 light;//throughput: attenuation applied to any light found from here on

    int type;//type of ray chosen at the last scatter: 1=Diffuse, 2=Specular, 3=Refract
    vec3 absorb;//absorption color of the medium currently being traversed
    vec3 emit;//emission color of the medium currently being traversed
    float distance; //distance traveled on a bounce
    float totalDistance;// accumulated distance traveled along a ray.
    float numScatters;//num of scattering events, when this is the useful metric instead of distance
    LocalData dat;

    bool keepGoing;
    bool subSurface;

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

    initializeData(path.dat);

    path.absorb=vec3(0.);
    path.emit = vec3(0);
    return path;

}








