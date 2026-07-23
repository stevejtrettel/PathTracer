//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// no RoomBox: the honeycomb carries its own ideal-boundary floor, and the
// gradient sky (set in settings.js) lights the scene. one key light adds
// the warm highlight the original preset used.
//-------------------------------------------------

Sphere light;


void buildEnvironment(){

    //warm key light, roughly where the Shadertoy preset put its spot light
    light.frame  = makeFrame(vec3(0.04, -2.24, 0.92));
    light.radius = 0.45;
    light.mat    = makeLight(vec3(0.95, 0.88, 0.77), 22.);

}


//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    return trace(tv, light);
}

float sdf_Environment(Vector tv ){
    //nothing to raymarch
    return maxDist;
}


//-------------------------------------------------
//Setting the Environment Data
//-------------------------------------------------

void setData_Environment( inout Path path ){
    setData(path, light);
}
