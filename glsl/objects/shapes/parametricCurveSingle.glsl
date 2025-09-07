// ---------- glsl/objects/shapes/parametricCurve.glsl ----------
// Tube SDF around a parametric curve via union of capsules.
// The curve itself is defined elsewhere by:
//    vec3  curvePos(float t);
//    float curveRadius(float t);   // only used if varyRadiusFlag != 0

const int MAX_SEGMENTS = 256;

struct ParametricCurve {
// Parameter range and sampling
    float t0;
    float t1;
    int   segments;         // <= MAX_SEGMENTS

// Radius control
    int   varyRadiusFlag;   // 0 = constant radius, 1 = use curveRadius(t)
    float radius;           // used if varyRadiusFlag == 0

// Material
    Material mat;

// Optional bounding sphere for the *tube* (centerline + thickness).
// If bboxRad <= 0.0, the bound is disabled.
    vec3  bboxCenter;
    float bboxRad;
};

struct ClosestInfo {
    float d;
    vec3  q;
    int   segIdx;
};

// ---- Forward declarations (must be implemented in your curve file) ----
vec3  curvePos(float t);
float curveRadius(float t);   // only called if varyRadiusFlag != 0

// ---- Helpers ----
float ithParam(in ParametricCurve pc, int i) {
    float u = float(i) / float(pc.segments);
    return mix(pc.t0, pc.t1, u);
}

// Lower bound outside the bounding sphere; disabled if bboxRad <= 0.
float bboxDistance(vec3 p, in ParametricCurve pc) {
    if (pc.bboxRad <= 0.0) return -1e30; // disabled
    return length(p - pc.bboxCenter) - pc.bboxRad; // safe lower bound outside
}

// Core: nearest distance to tube (capsule union) with bound early-out
ClosestInfo closestCurveTube(vec3 x, in ParametricCurve pc) {
    // Quick outer lower bound: skip expensive work if clearly outside
    float db = bboxDistance(x, pc);
    if (db > 0.0) {
        ClosestInfo info;
        info.d = db;
        info.q = pc.bboxCenter;
        info.segIdx = -2;
        return info;
    }

    float dMin = 1e30;
    vec3  qMin = x;
    int   best = -1;

    int segs = clamp(pc.segments, 1, MAX_SEGMENTS);

    for (int i = 0; i < MAX_SEGMENTS; ++i) {
        if (i >= segs) break;

        float ta = ithParam(pc, i);
        float tb = ithParam(pc, i + 1);

        vec3 A = curvePos(ta);
        vec3 B = curvePos(tb);

        vec3 AB  = B - A;
        float AB2 = max(dot(AB, AB), 1e-12);
        float h   = clamp(dot(x - A, AB) / AB2, 0.0, 1.0);
        vec3  q   = A + h * AB;

        float r = (pc.varyRadiusFlag != 0)
        ? mix(curveRadius(ta), curveRadius(tb), h)
        : pc.radius;

        float d = length(x - q) - r;
        if (d < dMin) { dMin = d; qMin = q; best = i; }
    }

    ClosestInfo ci;
    ci.d = dMin;
    ci.q = qMin;
    ci.segIdx = best;
    return ci;
}

// ---- Public API (mirrors your Sphere) ----

float distR3(vec3 p, in ParametricCurve pc) {
    float db = bboxDistance(p, pc);
    if (db > 0.) return db+0.01;           // outside → cheap, safe step
    return closestCurveTube(p, pc).d;  // inside → full evaluation
}

float sdf(Vector tv, in ParametricCurve pc) { return distR3(tv.pos, pc); }

bool at(Vector tv, in ParametricCurve pc) {
    float d = distR3(tv.pos, pc);
    return (abs(d) - AT_THRESH) < 0.0;
}

bool inside(Vector tv, in ParametricCurve pc) {
    return distR3(tv.pos, pc) < 0.0;
}

Vector normalVec(Vector tv, in ParametricCurve pc) {
    ClosestInfo ci = closestCurveTube(tv.pos, pc);
    vec3 n = normalize(tv.pos - ci.q);
    if (length(n) < 1e-5) {
        const vec2 e = vec2(1.0, -1.0) * 1e-4;
        vec3 g = vec3(
        distR3(tv.pos + vec3(e.x,0,0), pc) - distR3(tv.pos + vec3(e.y,0,0), pc),
        distR3(tv.pos + vec3(0,e.x,0), pc) - distR3(tv.pos + vec3(0,e.y,0), pc),
        distR3(tv.pos + vec3(0,0,e.x), pc) - distR3(tv.pos + vec3(0,0,e.y), pc)
        );
        n = normalize(g);
    }
    return Vector(tv.pos, n);
}

void setData(inout Path path, in ParametricCurve pc) {
    if (at(path.tv, pc)) {
        Vector N = normalVec(path.tv, pc);
        bool side = inside(path.tv, pc);
        setObjectInAir(path.dat, side, N, pc.mat);
    }
}
