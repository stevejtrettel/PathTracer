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
    //buildVarieties();
}


//-------------------------------------------------
//Building the SDF
//-------------------------------------------------

float sdf_Scene(Path path){
    return maxDist;
    //return sdf_Objects(path);
}



//-------------------------------------------------
//Setting Up the RayTrace
//-------------------------------------------------

float trace_Scene(Vector tv, float stopDist){

    float dist=stopDist;

    dist=trace_Lights(tv, dist);

    //dist=trace_Walls(tv, dist);

    dist=trace_Objects(tv, dist);

    return dist;
}



//-------------------------------------------------
//Setting Data Upon Reaching an Object
//-------------------------------------------------

void setData_Scene(inout Path path){

    //setData_Walls(path);

    setData_Lights(path);

    setData_Objects(path);

    //setDataVarieties(path);

}
