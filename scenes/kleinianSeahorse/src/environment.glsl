//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// gradient sky lights the fractal; one warm key light in the sun direction
//-------------------------------------------------

Sphere light;


void buildEnvironment(){

    light.frame  = makeFrame(vec3(-0.3, 2.2, -0.9));   //sun-ish direction, up/left
    light.radius = 0.5;
    light.mat    = makeLight(vec3(1.0, 0.9, 0.78), 18.);

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
