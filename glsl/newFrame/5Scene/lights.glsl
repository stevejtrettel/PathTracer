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
    light1.center=Point(vec3(-3.5,6.5,2));
    light1.radius=0.5;

    color= vec3(255., 147, 41)/255.;
    intensity=30.;

    light1.mat=makeLight(color,intensity);



    //----------- LIGHT 2 -------------------------
    light2.center=Point(vec3(0,6,4));
    light2.radius=0.6;

    color= vec3(1.,0.6,0.4);
    intensity=5.;

    light2.mat=makeLight(color,intensity);



    //----------- LIGHT 4 -------------------------
    light3.center=Point(vec3(4,7,3));
    light3.radius=0.4;

    color= vec3(1.,0.6,0.4);
    intensity=50.;

    light3.mat=makeLight(color,intensity);

}






//-------------------------------------------------
//Finding the Lights
//-------------------------------------------------


float traceLights( inout Path path, float stopDist ){

    float dist=stopDist;

    dist=sphereTrace(path,light1,dist);

    dist=sphereTrace(path,light2,dist);

    dist=sphereTrace(path,light3,dist);

    return dist;

}




//-------------------------------------------------
//Setting the Lights Data
//-------------------------------------------------

void setDataLights(inout Path path){

    setSphereData(path, light1);

    setSphereData(path, light2);

    setSphereData(path, light3);

}
