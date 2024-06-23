//-------------------------------------------------
// LIGHTS OF THE SCENE
//-------------------------------------------------


//set the names lights contained in the scene
Sphere light1,light2,light3;


void buildLights(){

    vec3 color;
    float intensity;
    intensity=150.;
    color = vec3(1);

    //----------- LIGHT 1 -------------------------
    light1.center=vec3(1,2,0);
    light1.radius=0.3;
    color= vec3(0.9,0.2,0.2);
    light1.mat=makeLight(color,intensity);

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
    return dist;

}


//-------------------------------------------------
//Setting the Lights Data
//-------------------------------------------------

void setData_Lights(inout Path path){
    setData(path, light1);
}
