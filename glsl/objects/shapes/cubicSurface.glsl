
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


// Full evaluation at arbitrary point (used by normalVec, at, inside)
float distR3(vec3 p, CubicSurface surf) {
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

float distR3(Vector tv, CubicSurface surf) {
    return distR3(tv.pos, surf);
}

float sdf(Vector tv, CubicSurface surf) {
    return distR3(tv.pos, surf);
}

bool at(Vector tv, CubicSurface surf) {
    float d = distR3(tv.pos, surf);
    return (abs(d) - AT_THRESH) < 0.;
}

bool inside(Vector tv, CubicSurface surf) {
    return distR3(tv.pos, surf) < 0.;
}

Vector normalVec(Vector tv, CubicSurface surf) {
    vec3 pos = tv.pos;
    const float ep = 0.0001;
    vec2 e = vec2(1.0, -1.0) * 0.5773;

    float vxyy = distR3(pos + e.xyy * ep, surf);
    float vyyx = distR3(pos + e.yyx * ep, surf);
    float vyxy = distR3(pos + e.yxy * ep, surf);
    float vxxx = distR3(pos + e.xxx * ep, surf);

    vec3 dir = e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;
    return Vector(tv.pos, normalize(dir));
}

void setData(inout Path path, CubicSurface surf) {
    if (at(path.tv, surf)) {
        Vector normal = normalVec(path.tv, surf);
        bool side = inside(path.tv, surf);
        setObjectInAir(path.dat, side, normal, surf.mat);
    }
}
