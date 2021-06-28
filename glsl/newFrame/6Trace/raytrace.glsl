//-------------------------------------------------
// RAYTRACE
// this function raytraces a scene
// does NOT update the path, but gives the distance to an intersection
//-------------------------------------------------


float raytrace(Vector tv, float stopDist){


    float dist =  trace_Scene( tv ) ;

    //if we hit something
    if(dist<stopDist){
        //move slightly less than the full distance to stop right before the object
        return dist- EPSILON/2.;
    }

    //otherwise, return the threshhold
    return stopDist;
}

