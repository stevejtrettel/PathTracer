//----------------------------------------------------------------------------
// SPHERE
//
// glsl/shapes/ is the math-only library: plain functions of a point and some
// floats. No structs, no Frame, no Material, no at()/inside()/setData().
// Placement, materials and the region interface are emitted by the scene.
//----------------------------------------------------------------------------


// p is in the sphere's own coordinates (origin at the centre)
float sphereDistance(vec3 p, float radius){
    return length(p) - radius;
}


// Exact ray intersection, in world coordinates: the distance along tv to the
// sphere, or maxDist if it is not in front of us. tv.dir is unit length.
//
// A ray STARTING INSIDE takes the far root — glass needs that, since a
// transmitted ray has to find the far wall of the object it just entered.
float sphereTrace(Vector tv, vec3 centre, float radius){
    vec3  oc = tv.pos - centre;
    float b  = dot(oc, tv.dir);
    float c  = dot(oc, oc) - radius*radius;
    float disc = b*b - c;
    if(disc < 0.){ return maxDist; }

    float s = sqrt(disc);
    float t = -b - s;
    if(t < 0.){ t = -b + s; }
    if(t < 0.){ return maxDist; }
    return min(t, maxDist);
}
