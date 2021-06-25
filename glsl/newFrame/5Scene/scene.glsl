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

float sceneSDF(Path path){
    return maxDist;
    //return sdfObjects(path);
}



//-------------------------------------------------
//Setting Up the RayTrace
//-------------------------------------------------

float sceneTrace(Path path, float stopDist){

    float dist=stopDist;

    dist=traceLights(path, dist);

    dist=traceWalls(path, dist);

    dist=traceObjects(path, dist);

    return dist;
}



//-------------------------------------------------
//Setting Data Upon Reaching an Object
//-------------------------------------------------

void setDataScene(inout Path path){

    setDataWalls(path);

    setDataLights(path);

    setDataObjects(path);

    setDataVarieties(path);

}
