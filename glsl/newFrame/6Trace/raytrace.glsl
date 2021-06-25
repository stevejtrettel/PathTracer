//-------------------------------------------------
// RAYTRACE
// this function raytraces a scene
// does NOT update the path, but gives the distance to an intersection
//-------------------------------------------------


float raytrace(Vector tv, float stopDist){

    float dist=stopDist;

    //right now just tracing the scene
    dist = trace_Scene(tv, dist);

    //move slightly less than the full distance to stop right before the object
    return dist-EPSILON/2.;

}

