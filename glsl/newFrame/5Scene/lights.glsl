//-------------------------------------------------
// LIGHTS OF THE SCENE
// describes the SDF / tracing function for the objects lighting the scene
// of course any object can be emissive, but this is to help plan the "main lights"
//-------------------------------------------------




//-------------------------------------------------
//Defining the Lights
//-------------------------------------------------


//set the names of global variables for the walls here:
Sphere light1, light2, light3;

//this function constructs the objects
void buildLights(){

    vec3 color;
    float intensity;

    //----------- LIGHT 1 -------------------------
    light1.center=vec3(7,0,12);
    light1.radius=0.75;

    color= vec3(0.5);
    intensity=150.;

    light1.mat=makeLight(color,intensity);



    //----------- LIGHT 2 -------------------------
    light2.center=vec3(-10,3,14);
    light2.radius=0.75;

    color= vec3(1.);
    intensity=205.;

    light2.mat=makeLight(color,intensity);



    //----------- LIGHT 3 -------------------------
    light3.center=vec3(-3.,6.,8);

    light3.radius=2.*extra4;

    //vec3(1.,0.8,0.6);
    color= vec3(1.);
    intensity=105.;

    light3.mat=makeLight(color,intensity);

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

   dist=min(dist, trace(tv, light1));

    dist=min(dist, trace(tv, light2));

   // dist=min(dist, trace(tv, light3));

    return dist;

}




//-------------------------------------------------
//Setting the Lights Data
//-------------------------------------------------

void setData_Lights(inout Path path){

    setData(path, light1);

    setData(path, light2);

   // setData(path, light3);

}





//-------------------------------------------------
//Sample the Lights
//-------------------------------------------------

//this needs to be updated in the sampleLight file
//UGHHHHHHHHHHHHHHH