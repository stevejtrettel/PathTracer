
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

// Helper: compute surface DE with gradient projected orthogonal to bbox
float surfaceDist(vec3 pos, float scale) {
    vec3 scaled = scale * pos;
    float val = cubicF(scaled);
    vec3 grad = cubicGrad(scaled) * scale;
    // Project surface gradient orthogonal to sphere normal
    vec3 nb = normalize(pos);
    grad -= dot(grad, nb) * nb;
    return abs(val) / max(length(grad), 1e-6);
}

//the point-level sdf
float sdf(vec3 p, BoundaryRing ring) {
    vec3 pos = p - ring.center;
    float dSurf = surfaceDist(pos, ring.scale);
    float dBox = abs(sceneBBox(pos));
    return 0.5 * (sqrt(dSurf * dSurf + dBox * dBox) - ring.radius);
}

// Fast path using cached values (called from sdf_Objects only)
float sdf_cached(BoundaryRing ring) {
    vec3 grad = _cachedGrad * ring.scale;
    // Project surface gradient orthogonal to sphere normal
    vec3 nb = normalize(_cachedPos);
    grad -= dot(grad, nb) * nb;
    float dSurf = abs(_cachedVal) / max(length(grad), 1e-6);
    float dBox = abs(_cachedBBox);
    return 0.5 * (sqrt(dSurf * dSurf + dBox * dBox) - ring.radius);
}

//the standard interface: at, inside, sdf, normalVec, setData
OBJECT_API(BoundaryRing)
