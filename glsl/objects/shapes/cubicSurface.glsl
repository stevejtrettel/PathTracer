
//----------------------------------------------------------------------------------------------
// CUBIC SURFACE IN A BOUNDING REGION
// before including this file, provide:
//   float cubicF(vec3 p)       — evaluates the cubic polynomial
//   vec3 cubicGrad(vec3 p)     — evaluates the analytic gradient
//   float sceneBBox(vec3 pos)  — bounding SDF (centered at object center)
// Also expects cached globals: _cachedVal, _cachedGrad, _cachedBBox
// (cached values are in the object's LOCAL frame: the scene must localize
//  the query point with toLocal(obj.frame, ...) before filling the cache)
//----------------------------------------------------------------------------------------------


struct CubicSurface {
    Frame frame;
    float scale;
    float smoothing;
    vec2 thickness;    // .x = inward, .y = outward
    Material mat;
};


//the local-frame sdf
float sdf(vec3 p, CubicSurface surf) {
    vec3 scaled = surf.scale * p;

    float val = cubicF(scaled);
    float gradLen = length(cubicGrad(scaled)) * surf.scale;
    float dist = val / (gradLen + 0.001);

    // shell thickening
    dist = abs(dist + surf.thickness.x) - surf.thickness.x - surf.thickness.y;

    // clip to bounding region
    float bboxDist = sceneBBox(p);
    dist = smax(dist, bboxDist, surf.smoothing);

    return dist;
}

// Fast path using cached values (called from sdf_Objects only)
float sdf_cached(CubicSurface surf) {
    float gradLen = length(_cachedGrad) * surf.scale;
    float dist = _cachedVal / (gradLen + 0.001);
    dist = abs(dist + surf.thickness.x) - surf.thickness.x - surf.thickness.y;
    dist = smax(dist, _cachedBBox, surf.smoothing);
    return dist;
}

//local bounding radius: the surface is clipped to sceneBBox (radius ~2), so a
//sphere of radius 3 in local coords safely encloses it
float bound( CubicSurface surf ){ return 3.0; }

//the standard interface (custom bound above)
OBJECT_API_B(CubicSurface)
