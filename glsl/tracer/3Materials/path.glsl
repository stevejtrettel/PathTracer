//------------------------------------------------
//The LOCAL DATA Struct
// everything the tracer needs to know about the interface the path just hit:
// the Surface response there, plus what the two adjacent media contribute
// (index ratio, absorption/emission on each side, walk parameters beyond).
// Filled by the wrappers in interaction.glsl, consumed by scatter() and
// updateFromSurface().
//-------------------------------------------------

struct LocalData{

    bool isPhysical;
    bool isSky;
    bool renderMaterial;

    float side;           //-1 hit from inside, +1 from outside (applyMaterial resampling)
    Surface surf;         //the surface response at this hit

    float IOR;            //front/back index ratio (wavelength-dependent when dispersing)
    vec3 reflectAbsorb;   //medium on the ray's side: reflections stay in it
    vec3 reflectEmit;
    vec3 refractAbsorb;   //medium beyond the surface: transmissions enter it
    vec3 refractEmit;
    float mfp;            //scatter mean free path of the medium beyond
    float blur;           //phase width of the medium beyond

    Vector normal;        //facing the incident ray
};


void initializeData(inout LocalData dat){
    dat.isSky=false;
    dat.isPhysical=true;
    dat.renderMaterial=true;
    dat.side=1.;
    initSurface(dat.surf);
    dat.IOR=1.;
    dat.reflectAbsorb=vec3(0.);
    dat.reflectEmit=vec3(0.);
    dat.refractAbsorb=vec3(0.);
    dat.refractEmit=vec3(0.);
    dat.mfp=maxDist;
    dat.blur=1.;
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

    int type;//type of ray chosen at the last scatter: 1=Diffuse, 2=Specular, 3=Transmit
    vec3 absorb;//absorption color of the medium currently being traversed
    vec3 emit;//emission color of the medium currently being traversed
    float distance; //distance traveled on a bounce
    float totalDistance;// accumulated distance traveled along a ray.
    float numScatters;//num of scattering events, when this is the useful metric instead of distance
    LocalData dat;

    bool keepGoing;
    bool subSurface;//a transmit event entered a scattering interior: run the walk

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
