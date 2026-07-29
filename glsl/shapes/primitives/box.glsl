//----------------------------------------------------------------------------
// BOX — an axis-aligned box, `halfSize` = half-widths.
//
// glsl/shapes/ is the math-only library: plain functions of a point and some
// floats. No structs, no Frame, no Material, no at()/inside()/setData().
// Placement, materials and the region interface are emitted by the scene.
//----------------------------------------------------------------------------


// p is in the box's own coordinates (origin at the centre); halfSize = half-widths.
// Exact, inside and out — which is why it doubles as the library's bounding box.
float boxDistance(vec3 p, vec3 halfSize){
    vec3 q = abs(p) - halfSize;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}


// Exact ray intersection, in world coordinates: the nearest slab crossing in
// front of us, or maxDist. A ray STARTING INSIDE takes the far exit — glass
// needs that, since a transmitted ray has to find the far wall of the box it
// just entered.
float boxTrace(Vector tv, vec3 centre, vec3 halfSize){
    vec3  o   = tv.pos - centre;
    vec3  inv = 1.0/tv.dir;
    vec3  t1  = (-halfSize - o)*inv;
    vec3  t2  = ( halfSize - o)*inv;
    vec3  lo  = min(t1, t2);
    vec3  hi  = max(t1, t2);
    float tN  = max(lo.x, max(lo.y, lo.z));
    float tF  = min(hi.x, min(hi.y, hi.z));
    if(tN > tF || tF < 0.){ return maxDist; }   // miss, or entirely behind us
    float t = (tN > 0.) ? tN : tF;               // outside -> entry; inside -> far exit
    return min(t, maxDist);
}
