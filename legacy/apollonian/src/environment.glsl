//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// darker gradient sky so the colorful gasket pops; one warm key light in the
// shadertoy's light direction
//-------------------------------------------------

Sphere light;


void buildEnvironment(){

    //shadertoy key light direction ld0 = normalize(-12, 2, -7)
    light.frame  = makeFrame(vec3(-3.4, 0.56, -2.0));
    light.radius = 0.6;
    light.mat    = makeLight(vec3(1.0, 0.9, 0.7), 24.);

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
