//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------

void stepForward(inout Path path){

    float distance;
    //do the raymarching, move to the next point of intersection
    raymarch( path.tv, distance);

    //update the distance traveled
    path.distance=distance;
    path.totalDistance+=distance;

    //check if we hit the sky: if not, set the data from our intersection point.
    path.dat.isSky=(path.distance>maxDist-0.1);
    if(!path.dat.isSky){
        setData_Scene(path);
    }

}
