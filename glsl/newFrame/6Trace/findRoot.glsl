//-------------------------------------------------
// BISECT
// this traces a scene numerically along a ray
// finds the nearest intersection, and updates if this is before a given threshhold.
// this may use RAYTRACE or RAYMARCH to get to the bounding box.
//-------------------------------------------------



float findRoot(Path path, float stopDist){
    return stopDist;
}





float bisectvar(Path path, float stopDist){

    float dist=stopDist;
    float distToBBox;

    //trace bounding box, see if outside
    bool outside=true;

    //if it is, return this distance
    if(outside){
        return min(dist,stopDist);
    }

    //otherwise, we know from traceBoundingBox how far
    //we have to look on the interior for a root:
    dist+=findRoot(path,distToBBox);

    return min(dist,stopDist);
}