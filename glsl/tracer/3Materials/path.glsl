//------------------------------------------------
//The LOCAL DATA Struct
// everything the tracer needs to know about the INTERFACE the path just hit.
//
// A surface is the boundary between two media, so an interface is three things:
// the Surface response there, and the Medium on each side. The two media come
// from DIFFERENT objects — which is why no `Material` appears here. A Material
// pairs a surface with its OWN interior, and no single one can describe a
// glass/liquid wall.
//
// Filled in exactly one place: setData_Scene (5Scene/scene.glsl), from the
// classifier. Consumed by scatter(), mediumWalk() and updateFromSurface().
//-------------------------------------------------

//no object: the far side of a lone surface (open air), or — on dat.hit — a
//landing no object claimed, which is a bug rather than a scene feature.
const int ID_NONE = -1;


struct LocalData{

    int     hit;      //object whose boundary we are standing on (owns the Surface)

    //the two sides. Each medium is paired with the object it belongs to, so a
    //scatter can set path.region as well as path.medium: ID_NONE means air.
    int     frontID;  //object whose interior is `front`
    Medium  front;    //medium on the ray's side: reflections stay in it
    int     backID;   //object whose interior is `back`
    Medium  back;     //medium beyond the surface: transmissions enter it

    Surface surf;     //the interface's response — from the object that owns it

    Vector  normal;   //facing the incident ray

    bool    isSky;    //transport outcome; owned by stepForward/odeMarch, not by the hit
    bool    render;   //false: pass straight through (unrendered material)
};


void initializeData(inout LocalData dat){
    dat.hit     = ID_NONE;
    dat.frontID = ID_NONE;
    dat.backID  = ID_NONE;
    dat.surf    = defaultSurface();
    dat.front   = defaultMedium();
    dat.back    = defaultMedium();
    dat.isSky   = false;
    dat.render  = true;
}


//the index ratio across this interface, wavelength-dependent while dispersing.
//DERIVED, not stored: front and back already carry the two indices, and a
//cached third copy is one more thing that can disagree with them.
float iorRatio(LocalData dat){
    return iorAt(dat.front.ior)/iorAt(dat.back.ior);
}


//-------------------------------------------------
//The Path Struct
// the full state of one light path as it bounces through the scene:
// pixel accumulates the color collected so far (from emitters and the sky);
// light is the throughput — how much any light found from here on
// contributes, attenuated at each surface/volume interaction.
//
// LIFETIME is what separates Path from LocalData: Path carries what survives
// BETWEEN hits — where the ray is, what it is worth, and which medium it is
// travelling through. LocalData is scratch from the most recent hit alone.
//-------------------------------------------------


struct Path{

    Vector tv;
    vec3 pixel;//color collected so far along the path
    vec3 light;//throughput: attenuation applied to any light found from here on

    int type;//type of ray chosen at the last scatter: 1=Diffuse, 2=Specular, 3=Transmit

    Medium medium;//the medium currently being traversed: its absorb/emit bill the
                  //segment, its mfp/blur drive the walk
    int region;   //the object whose interior that is (ID_NONE = open air).
                  //mediumWalk needs it — "am I still inside?" is a question about
                  //ONE region, not about objects in general.

    float distance; //distance traveled on a bounce
    float totalDistance;// accumulated distance traveled along a ray.
    float numScatters;//num of scattering events, when this is the useful metric instead of distance
    LocalData dat;

    bool keepGoing;
    bool subSurface;//a transmit event entered a scattering interior: run the walk

};


//starts in open air; newFrame() fixes region/medium up from regionAt() once the
//scene is built, so a camera placed inside glass starts inside glass.
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

    path.medium=defaultMedium();
    path.region=ID_NONE;
    return path;

}
