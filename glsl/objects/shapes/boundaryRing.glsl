
//----------------------------------------------------------------------------------------------
// BOUNDARY RING
// The tube where the cubic surface zero-set meets the bounding SDF.
// before including this file, provide:
//   float cubicF(vec3 p)       — evaluates the cubic polynomial
//   vec3 cubicGrad(vec3 p)     — evaluates the analytic gradient
//   float sceneBBox(vec3 pos)  — bounding SDF
// Also expects cached globals: _cachedVal, _cachedGrad, _cachedBBox
//----------------------------------------------------------------------------------------------


struct BoundaryRing {
    vec3 center;
    float radius;    // tube thickness
    float scale;     // must match surface.scale
    Material mat;
};

// Helper: compute raw surface DE at arbitrary point
float surfaceDist(vec3 pos, float scale) {
    vec3 scaled = scale * pos;
    float val = cubicF(scaled);
    float gradLen = length(cubicGrad(scaled)) * scale;
    return abs(val) / max(gradLen, 1e-6);
}

// Full evaluation at arbitrary point (used by normalVec, at, inside)
float distR3(vec3 p, BoundaryRing ring) {
    vec3 pos = p - ring.center;
    float dSurf = surfaceDist(pos, ring.scale);
    float dBox = abs(sceneBBox(pos));
    return sqrt(dSurf * dSurf + dBox * dBox) - ring.radius;
}

// Fast path using cached values (called from sdf_Objects only)
float sdf_cached(BoundaryRing ring) {
    float gradLen = length(_cachedGrad) * ring.scale;
    float dSurf = abs(_cachedVal) / max(gradLen, 1e-6);
    float dBox = abs(_cachedBBox);
    return sqrt(dSurf * dSurf + dBox * dBox) - ring.radius;
}

float distR3(Vector tv, BoundaryRing ring) {
    return distR3(tv.pos, ring);
}

float sdf(Vector tv, BoundaryRing ring) {
    return distR3(tv.pos, ring);
}

bool at(Vector tv, BoundaryRing ring) {
    float d = distR3(tv.pos, ring);
    return (abs(d) - AT_THRESH) < 0.;
}

bool inside(Vector tv, BoundaryRing ring) {
    return distR3(tv.pos, ring) < 0.;
}

Vector normalVec(Vector tv, BoundaryRing ring) {
    vec3 pos = tv.pos;
    const float ep = 0.0001;
    vec2 e = vec2(1.0, -1.0) * 0.5773;

    float vxyy = distR3(pos + e.xyy * ep, ring);
    float vyyx = distR3(pos + e.yyx * ep, ring);
    float vyxy = distR3(pos + e.yxy * ep, ring);
    float vxxx = distR3(pos + e.xxx * ep, ring);

    vec3 dir = e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;
    return Vector(tv.pos, normalize(dir));
}

void setData(inout Path path, BoundaryRing ring) {
    if (at(path.tv, ring)) {
        Vector normal = normalVec(path.tv, ring);
        bool side = inside(path.tv, ring);
        setObjectInAir(path.dat, side, normal, ring.mat);
    }
}
