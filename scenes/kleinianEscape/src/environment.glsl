//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// gradient sky lights the fractal; one warm key light
//-------------------------------------------------

Sphere light;


void buildEnvironment(){

    light.frame  = makeFrame(vec3(6.0, 6.0, -4.0));
    light.radius = 0.9;
    light.mat    = makeLight(vec3(1.0, 0.92, 0.8), 26.);

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
