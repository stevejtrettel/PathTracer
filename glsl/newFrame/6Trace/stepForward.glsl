//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------


void stepForward(inout Path path){

    float distance=maxDist;
    Vector origTV=path.tv;

    //march the walls
    //start with threshhold=maxDist
    distance=raymarchWalls(path,distance);
    path.tv=origTV;//reset to orig loc

    //march the scene, use wallDist as threshhold
    distance=raymarchScene(path,distance);
    path.tv=origTV;//reset to orig loc

    //set the path data:
    path.distance=distance;
    flow(path.tv,distance);
    path.dat.isSky=(path.distance==maxDist);

}