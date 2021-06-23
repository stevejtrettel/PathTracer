//-------------------------------------------------
// RAYTRACE
// this function raytraces a scene
// and updates if a material is intersected within a specified threshhold
//-------------------------------------------------


float raytraceWalls(inout Path path, float stopDist){

    float dist=stopDist;
    dist=planeTrace(path,wall1,dist);
    dist=planeTrace(path,wall2,dist);
    dist=planeTrace(path,wall3,dist);

    return dist;
}

