// ---------- glsl/objects/shapes/parametricCurve.glsl ----------
// Generic SDF for a tube around a parametric curve, using capsule union.
//THIS REQUIRES A FILE IMPLEMENTING THE FOLLOWING TWO FUNCTIONS:
//

const int MAX_SEGMENTS = 256;

struct ParametricCurve {
    float t0;
    float t1;
    int   segments;        // <= MAX_SEGMENTS
    int   varyRadiusFlag;  // 0 = constant radius, 1 = use curveRadiusDispatch
    float radius;          // used if varyRadiusFlag==0

    int   curveType;       // which parametric to use (defined by your curve modules)
    int   radiusType;      // which radius profile to use
    Material mat;

    float bboxRad;
    vec3 bboxCenter;
};

struct ClosestInfo {
    float d;
    vec3  q;
    int   segIdx;
};

// ---- Forward declarations (implemented in CurveDispatch.glsl) ----
vec3  curvePosDispatch(in ParametricCurve pc, float t);
float curveRadiusDispatch(in ParametricCurve pc, float t);

// ---- Helpers ----
float ithParam(in ParametricCurve pc, int i) {
    float u = float(i) / float(pc.segments);
    return mix(pc.t0, pc.t1, u);
}

ClosestInfo closestCurveTube(vec3 x, in ParametricCurve pc) {
    float dMin = 1e30;
    vec3  qMin = x;
    int   best = -1;

    int segs = clamp(pc.segments, 1, MAX_SEGMENTS);

    for (int i = 0; i < MAX_SEGMENTS; ++i) {
        if (i >= segs) break;

        float ta = ithParam(pc, i);
        float tb = ithParam(pc, i + 1);

        vec3 A = curvePosDispatch(pc, ta);
        vec3 B = curvePosDispatch(pc, tb);

        vec3 AB = B - A;
        float AB2 = max(dot(AB, AB), 1e-12);
        float h = clamp(dot(x - A, AB) / AB2, 0.0, 1.0);
        vec3  q = A + h * AB;

        float r = (pc.varyRadiusFlag != 0)
        ? mix(curveRadiusDispatch(pc, ta), curveRadiusDispatch(pc, tb), h)
        : pc.radius;

        float d = length(x - q) - r;
        if (d < dMin) { dMin = d; qMin = q; best = i; }
    }

    ClosestInfo ci; ci.d = dMin; ci.q = qMin; ci.segIdx = best;
    return ci;
}

// ---- Public API (mirrors your Sphere) ----
float distR3(vec3 p, in ParametricCurve pc) {

    float bboxDist = length(p-pc.bboxCenter)-pc.bboxRad;

    if(bboxDist>0.){
        return bboxDist + 0.01;
    }

    // Inside bounding sphere → do the expensive capsule loop
    return closestCurveTube(p, pc).d;


}
float sdf(Vector tv, in ParametricCurve pc) { return distR3(tv.pos, pc); }

bool at(Vector tv, in ParametricCurve pc) {
    float d = distR3(tv.pos, pc);
    return (abs(d) - AT_THRESH) < 0.0;
}
bool inside(Vector tv, in ParametricCurve pc) { return distR3(tv.pos, pc) < 0.0; }

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
