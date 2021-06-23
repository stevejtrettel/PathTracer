//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------



void stepForward(inout Path path){

    Path wallsPath=path;
    Path scenePath=path;

    //march the walls
    //start with threshhold=maxDist
    float wallsDist=raymarchWalls(wallsPath,maxDist);

    //march the scene, use wallDist as threshhold
    float sceneDist=raymarchScene(scenePath,wallsDist);

    //did we reach the sky?
    if(min(wallsDist,sceneDist)==maxDist){
        path.distance=maxDist;
        path.dat.isSky=true;
        return;
    }

    //otherwise, figure out what we hit, and collect the right data
    if(sceneDist<wallsDist){
        path.distance=sceneDist;
        path=scenePath;
        return;
    }

    else{
        path.distance=wallsDist;
        path=wallsPath;

        return;
    }

}