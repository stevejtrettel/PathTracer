//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// gradient sky lights the form; one soft key light
//-------------------------------------------------

Sphere light;


void buildEnvironment(){

    light.frame  = makeFrame(vec3(-1.5, 1.5, -0.8));   //sun direction from the shadertoy
    light.radius = 0.6;
    light.mat    = makeLight(vec3(1.0, 0.85, 0.7), 20.);

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
