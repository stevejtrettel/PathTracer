//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------


//
//void stepForward(inout Path path){
//
//    Path wallsPath=path;
//    Path scenePath=path;
//
//    //march the walls
//    //start with threshhold=maxDist
//    float wallsDist=raymarchWalls(wallsPath,maxDist);
//
//    //march the scene, use wallDist as threshhold
//    float sceneDist=raymarchScene(scenePath,wallsDist);
//
//    //did we reach the sky?
//    if(min(wallsDist,sceneDist)==maxDist){
//        path.distance=maxDist;
//        path.dat.isSky=true;
//        return;
//    }
//
//    //otherwise, figure out what we hit, and collect the right data
//    if(sceneDist<wallsDist){
//        path.distance=sceneDist;
//        path=scenePath;
//        return;
//    }
//
//    else{
//        path.distance=wallsDist;
//        path=wallsPath;
//
//        return;
//    }
//
//}
//
//
//



void stepForward(inout Path path){

    float distance=maxDist;
    Vector origTV=path.tv;

    //march the walls
    //start with threshhold=maxDist
    distance=raymarchWalls(path,distance);
    path.tv=origTV;

    //march the scene, use wallDist as threshhold
    distance=raymarchScene(path,distance);
    path.tv=origTV;

    //set the path data:
    path.distance=distance;
    flow(path.tv,distance);

    //did we reach the sky?
    if(path.distance==maxDist){
        path.dat.isSky=true;
        return;
    }
}