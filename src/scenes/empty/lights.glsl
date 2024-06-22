//-------------------------------------------------
// LIGHTS OF THE SCENE
//-------------------------------------------------


//set the names lights contained in the scene
Sphere light1,light2,light3;


void buildLights(){

    vec3 color;
    float intensity;
    intensity=150.;

    //----------- LIGHT 1 -------------------------
    light1.center=vec3(-7,5,0);
    light1.radius=0.3;
    color= vec3(0.9,0.2,0.2);
    light1.mat=makeLight(color,intensity);

    //----------- LIGHT 2 -------------------------
    light2.center=vec3(0,5,0);
    light2.radius=0.3;
    color= vec3(0.2,0.9,0.2);
    light2.mat=makeLight(color,intensity);

    //----------- LIGHT 3 -------------------------
    light3.center=vec3(0,5,3);
    light3.radius=0.3;
    color= vec3(0.2,0.2,0.9);
    light3.mat=makeLight(color,intensity);

}



//-------------------------------------------------
//DO WE RENDER THEM?
//-------------------------------------------------
bool render_Lights=true;


//-------------------------------------------------
//Finding the Lights
//-------------------------------------------------


//copy as many lines of dist=min(dist, sdf(tv, NEW_OBJ)), one for each object in the scene
float sdf_Lights( Vector tv ){
    float dist=maxDist;
    dist=min(dist, sdf(tv, light1));
    dist=min(dist, sdf(tv, light2));
    dist=min(dist, sdf(tv, light3));
    return dist;

}


//-------------------------------------------------
//Setting the Lights Data
//-------------------------------------------------

void setData_Lights(inout Path path){
    setData(path, light1);
    setData(path, light2);
    setData(path, light3);
}
