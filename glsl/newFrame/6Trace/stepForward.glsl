//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------


void stepForward(inout Path path){

    float distance=maxDist;

    //do the raytracing
    distance=raytrace(path,distance);

    //do the raymarching, with threshhold from above
    //distance=raymarch(path,distance);

    //move to this point of intersection
    path.distance=distance;
    flow(path.tv,distance);
    path.dat.isSky=(path.distance==maxDist);

    //if we hit the sky, quit:
    if(path.dat.isSky){
        return;
    }

    //otherwise set the local data
    setDataScene(path);
}