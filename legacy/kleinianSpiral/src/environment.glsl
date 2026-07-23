//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// NO RoomBox: the original spiral fades to a flat sky. rays that escape (past
// the maxDist cutoff set in objects.glsl) show the sky set in settings.js. one
// key light sphere adds shading depth.
//-------------------------------------------------

Sphere light;


void buildEnvironment(){

    light.frame  = makeFrame(vec3(-7, 8, 2));
    light.radius = 1.0;
    light.mat    = makeLight(vec3(0.95, 0.92, 0.85), 160.*lightIntensity);

}


//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    return trace(tv, light);
}

float sdf_Environment(Vector tv ){
    return maxDist;
}


//-------------------------------------------------
//Setting the Environment Data
//-------------------------------------------------

void setData_Environment( inout Path path ){
    setData(path, light);
}
