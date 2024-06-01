//-------------------------------------------------
// LIGHTS OF THE SCENE
//-------------------------------------------------


//set the names lights contained in the scene
Sphere light;


void buildLights(){

    vec3 color;
    float intensity;

    //----------- LIGHT 1 -------------------------
    light.center=vec3(-15,3,0);
    light.radius=1.;

    color= vec3(0.9);
    intensity=150.;

    light.mat=makeLight(color,intensity);

}



//-------------------------------------------------
//DO WE RENDER THEM?
//-------------------------------------------------
bool render_Lights=true;


//-------------------------------------------------
//Finding the Lights
//-------------------------------------------------

float trace_Lights( Vector tv ){

    float dist=maxDist;

    dist=min(dist, trace(tv, light));

    return dist;

}




//-------------------------------------------------
//Setting the Lights Data
//-------------------------------------------------

void setData_Lights(inout Path path){

    setData(path, light);

}
