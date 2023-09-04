//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------


void stepForward(inout Path path){
    bool insideVar=false;
    float distance=maxDist;

    //do the raytracing: now distance is set to closest object
    distance=raytrace( path.tv, distance );

    //do the raymarching, with distance threshhold from above
    distance=raymarch( path.tv, distance );

    //dist now stores shortest distance between tracing and marching
    //move to this point of intersection
    path.distance=distance;
    path.totalDistance+=distance;
    flow(path.tv,distance);

    //check if we hit the sky: if not, set the data from our intersection point.
    path.dat.isSky=(path.distance>maxDist-0.1);
    if(!path.dat.isSky){
        setData_Scene(path);
    }

}

