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
    buildVarieties();
}


//-------------------------------------------------
//Building the SDF
//-------------------------------------------------

float sdf_Scene( Vector tv ){

    //all walls and lights are traced
    return  sdf_Objects( tv );

}



//-------------------------------------------------
//Setting Up the RayTrace
//-------------------------------------------------

float trace_Scene( Vector tv ){

    float dist=maxDist;

    dist = min( dist, trace_Lights(tv) );

    dist = min( dist, trace_Walls(tv) );

    //dist = min( dist, trace_Objects(tv) );

    return dist;
}



//-------------------------------------------------
//Setting Data Upon Reaching an Object
//-------------------------------------------------

void setData_Scene(inout Path path){

    setData_Walls(path);

    setData_Lights(path);

    setData_Objects(path);

    setData_Varieties(path);

}
