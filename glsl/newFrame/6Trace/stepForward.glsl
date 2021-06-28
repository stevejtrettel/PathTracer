//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------



//get the minimum distance to an object in the scene
float distToObj(Vector tv){

    bool insideVar=false;
    float distance=maxDist;

    //do the raytracing
    distance=raytrace( tv, distance );

    //do the raymarching, with threshhold from above
    distance=raymarch( tv, distance );

    //trace the varieties, if we are inside a bounding box
    if(render_Varieties){
        float varDist=trace_VarietyBBox( tv );
        if (varID!=0){
            varDist = findRoot( tv, varDist);
        }
        distance=min(distance, varDist);
    }

    return distance;
}



void stepForward(inout Path path){

    float distance=distToObj( path.tv );

    //move to this point of intersection
    path.distance=distance;
    flow(path.tv,distance);
    path.dat.isSky=(path.distance>maxDist-0.1);

    if(!path.dat.isSky){
        setData_Scene(path);
    }

}