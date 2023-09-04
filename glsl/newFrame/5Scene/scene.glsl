//-------------------------------------------------
// THE SCENE
// collects all the pieces of the scene from other files to combine
// this contains buildScene, sceneSDF, sceneTrace, and setDataScene
//-------------------------------------------------







//-------------------------------------------------
//Building the Scene
//-------------------------------------------------

void buildScene(){
    buildWalls();
    buildLights();
    buildObjects();
}


//-------------------------------------------------
//Building the SDF
//-------------------------------------------------

float sdf_Scene( Vector tv ){
    float dist=maxDist;

    if(render_Objects){
        dist=min(dist, sdf_Objects( tv ));
    }

    return dist;

}



//-------------------------------------------------
//Setting Up the RayTrace
//-------------------------------------------------

float trace_Scene( Vector tv ){

    float dist=maxDist;

    if(render_Lights){
        dist = min(dist, trace_Lights(tv));
    }

    if(render_Walls){
        dist = min(dist, trace_Walls(tv));
    }

    if(render_Objects){
        dist = min( dist, trace_Objects(tv) );
    }

    return dist;
}



//-------------------------------------------------
//Setting Data Upon Reaching an Object
//-------------------------------------------------

void setData_Scene(inout Path path){

    if(render_Objects){
        setData_Objects(path);
    }

    if(render_Walls){
        setData_Walls(path);
    }

    if(render_Lights){
        setData_Lights(path);
    }



}
