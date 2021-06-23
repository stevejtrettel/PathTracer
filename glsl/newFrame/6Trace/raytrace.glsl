//-------------------------------------------------
// RAYTRACE
// this function raytraces a scene
// does NOT update the path, but gives the distance to an intersection
//-------------------------------------------------


float raytrace(Path path, float stopDist){

    float dist=stopDist;

    //right now just tracing the scene
    dist= sceneTrace(path,dist);

    return dist;

}

