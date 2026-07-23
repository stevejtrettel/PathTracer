//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// no RoomBox: the honeycomb carries its own ideal-boundary floor and the
// gradient sky (settings.js) lights the scene; one soft key light adds a highlight
//-------------------------------------------------

Sphere light;


void buildEnvironment(){

    //warm key light, roughly where the Shadertoy preset put its spot light
    light.frame  = makeFrame(vec3(-1.7558, -2.2138, 4.6564));
    light.radius = 0.4;
    light.mat    = makeLight(vec3(0.95, 0.88, 0.77), 24.);

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
