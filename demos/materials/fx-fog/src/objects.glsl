//-------------------------------------------------
// OBJECTS — FOG / GOD RAYS (the ambient-medium hook, material-system.md §5)
// open air is a scattering medium: rays in flight can scatter before reaching a
// surface. A small bright key light + matte occluders in fog = visible shafts.
// Knobs: fogMFP (scatter mean free path — smaller is thicker), fogBlur (phase:
// 0 forward-scatters like haze, 1 isotropic like milkfog), fogAbsorb.
// Turn roomLight to ~0 and lightPower up to see the shafts.
//-------------------------------------------------

//the ambient-medium hook contract (consumed by 6Trace/stepForward.glsl):
#define SCENE_AMBIENT_MEDIUM
float ambientMFP(){    return fogMFP; }
float ambientBlur(){   return fogBlur; }
vec3  ambientAbsorb(){ return vec3(fogAbsorb); }
vec3  ambientEmit(){   return vec3(0.); }


const int NUM = 3;
Sphere blockers[NUM];


void buildObjects(){

    for(int i = 0; i < NUM; i++){
        float x = -3.5 + 3.5*float(i);
        blockers[i].frame  = makeFrame(vec3(x, 2.2 + 1.4*float(i), 3.));
        blockers[i].radius = 1.2;
        blockers[i].mat    = makeMatte(vec3(0.25));
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, blockers[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    return false;
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, blockers[i]);
    }
}
