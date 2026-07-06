
//----------------------------------------------------------------------------------------------
// CUBIC SURFACE IN A BOUNDING REGION
// before including this file, provide:
//   float cubicF(vec3 p)       — evaluates the cubic polynomial
//   vec3 cubicGrad(vec3 p)     — evaluates the analytic gradient
//   float sceneBBox(vec3 pos)  — bounding SDF (centered at object center)
// Also expects cached globals: _cachedVal, _cachedGrad, _cachedBBox
//----------------------------------------------------------------------------------------------


struct CubicSurface {
    vec3 center;
    float scale;
    float smoothing;
    vec2 thickness;    // .x = inward, .y = outward
    Material mat;
};


//the point-level sdf
float sdf(vec3 p, CubicSurface surf) {
    vec3 pos = p - surf.center;
    vec3 scaled = surf.scale * pos;

    float val = cubicF(scaled);
    float gradLen = length(cubicGrad(scaled)) * surf.scale;
    float dist = val / (gradLen + 0.001);

    // shell thickening
    dist = abs(dist + surf.thickness.x) - surf.thickness.x - surf.thickness.y;

    // clip to bounding region
    float bboxDist = sceneBBox(pos);
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

//the standard interface: at, inside, sdf, normalVec, setData
UNFRAMED_OBJECT_API(CubicSurface)
