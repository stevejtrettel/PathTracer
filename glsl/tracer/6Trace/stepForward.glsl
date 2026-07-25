//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------


void stepForward(inout Path path){

    if(isMedium(path.region)){
        //curved transport: the ray is inside a MEDIUM REGION (an object whose
        //interior index varies with position), so the segment to the next surface is
        //a geodesic — the ODE marcher advances path.tv along path.region's field. Like
        //the straight branch it sets path.distance + isSky (or keepGoing=false on
        //capture) and leaves the shared segment-end tail below to us. isMedium() is
        //always false for scenes with no media, so those are byte-identical.
        odeMarch(path);
        if(!path.keepGoing){ return; }   //captured/absorbed: no surface and no sky
    }
    else{
        //straight transport: raytrace gives the nearest analytic surface as a stop
        //distance, then raymarch the sdf up to it; the ambient medium (a no-op
        //vacuum unless the scene hooks it — see ambient.glsl) may scatter the ray
        //along the way; move to the intersection point.
        float distance = raytrace( path.tv, maxDist );
        distance       = raymarch( path.tv, distance );
        distance       = ambientTransport( path, distance );
        if(!path.keepGoing){ return; }
        flow(path.tv, distance);
        path.distance  = distance;
        path.dat.isSky = (distance > maxDist - 0.1);
    }

    //shared segment-end tail (both transports): accumulate the path length, and set
    //the impact data from the intersection unless we reached the sky.
    path.totalDistance += path.distance;
    if(!path.dat.isSky){ setData_Scene(path); }
}
