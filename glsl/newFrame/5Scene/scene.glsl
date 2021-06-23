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

float sceneSDF(Path path){
    //no SDF right now - everything is raytraced
    return maxDist;
}



//-------------------------------------------------
//Setting Up the RayTrace
//-------------------------------------------------

float sceneTrace(Path path, float stopDist){

    float dist=stopDist;

    dist=traceLights(path,dist);
    dist=traceWalls(path,dist);
    dist=traceObjects(path,dist);

    return dist;
}



//-------------------------------------------------
//Setting Data Upon Reaching an Object
//-------------------------------------------------

void setDataScene(inout Path path){

    setDataWalls(path);

    setDataLights(path);

    setDataObjects(path);

}
