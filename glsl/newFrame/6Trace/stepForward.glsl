//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------


void stepForward(inout Path path){
    bool insideVar=false;
    float distance=maxDist;

    //do the raytracing
    distance=raytrace( path.tv, distance );

    //do the raymarching, with threshhold from above
    distance=raymarch( path.tv, distance );

    //trace the varieties, if we are inside a bounding box
    float varDist=trace_VarietyBBox( path.tv );
    if(varID!=0){
        varDist = findRoot( path.tv, varDist );
    }
    distance=min(distance, varDist);

    //move to this point of intersection
    path.distance=distance;
    flow(path.tv,distance);
    path.dat.isSky=(path.distance>maxDist-0.1);

    if(!path.dat.isSky){
        setData_Scene(path);
    }

}