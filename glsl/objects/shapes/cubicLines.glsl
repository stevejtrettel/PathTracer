
//----------------------------------------------------------------------------------------------
// CUBIC SURFACE LINES — THREE CLASS STRUCTS
// before including this file, provide:
//   Line struct + lineDist + lineNormal (from line.glsl)
//   const Line PAIR_LINES[15]
//   const Line CONIC_LINES[6]
//   const Line EXCEPTIONAL_LINES[6]
//   float sceneBBox(vec3 pos)
// Also expects cached globals: _cachedBBox, _cachedPos
// (cached values are in the object's LOCAL frame: the scene must localize
//  the query point with toLocal(obj.frame, ...) before filling the cache)
//----------------------------------------------------------------------------------------------


// ============================================================
// PAIR LINES (15 lines)
// ============================================================

struct PairLines {
    Frame frame;
    float radius;
    Material mat;
};

//the local-frame sdf
float sdf(vec3 p, PairLines obj) {
    float d = 1e6;
    for (int i = 0; i < 15; i++) {
        d = min(d, lineDist(p, PAIR_LINES[i]));
    }
    d -= obj.radius;
    return max(d, sceneBBox(p));
}

float sdf_cached(PairLines obj) {
    float d = 1e6;
    for (int i = 0; i < 15; i++) {
        d = min(d, lineDist(_cachedPos, PAIR_LINES[i]));
    }
    d -= obj.radius;
    return max(d, _cachedBBox);
}

//the standard interface: initObject, at, inside, sdf
OBJECT_INIT(PairLines)
OBJECT_LOCATORS(PairLines)

//analytic normalVec: normal of the nearest line, computed in local coordinates
Vector normalVec(Vector tv, PairLines obj) {
    vec3 q = toLocal(obj.frame, tv.pos);
    float best = 1e6;
    int idx = 0;
    for (int i = 0; i < 15; i++) {
        float d = lineDist(q, PAIR_LINES[i]);
        if (d < best) { best = d; idx = i; }
    }
    vec3 n = lineNormal(q, PAIR_LINES[idx]);
    return Vector(tv.pos, dirToWorld(obj.frame, n));
}

//the standard setData
OBJECT_SETDATA(PairLines)


// ============================================================
// CONIC LINES (6 lines)
// ============================================================

struct ConicLines {
    Frame frame;
    float radius;
    Material mat;
};

//the local-frame sdf
float sdf(vec3 p, ConicLines obj) {
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        d = min(d, lineDist(p, CONIC_LINES[i]));
    }
    d -= obj.radius;
    return max(d, sceneBBox(p));
}

float sdf_cached(ConicLines obj) {
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        d = min(d, lineDist(_cachedPos, CONIC_LINES[i]));
    }
    d -= obj.radius;
    return max(d, _cachedBBox);
}

//the standard interface: initObject, at, inside, sdf
OBJECT_INIT(ConicLines)
OBJECT_LOCATORS(ConicLines)

//analytic normalVec: normal of the nearest line, computed in local coordinates
Vector normalVec(Vector tv, ConicLines obj) {
    vec3 q = toLocal(obj.frame, tv.pos);
    float best = 1e6;
    int idx = 0;
    for (int i = 0; i < 6; i++) {
        float d = lineDist(q, CONIC_LINES[i]);
        if (d < best) { best = d; idx = i; }
    }
    vec3 n = lineNormal(q, CONIC_LINES[idx]);
    return Vector(tv.pos, dirToWorld(obj.frame, n));
}

//the standard setData
OBJECT_SETDATA(ConicLines)


// ============================================================
// EXCEPTIONAL LINES (6 lines)
// ============================================================

struct ExceptionalLines {
    Frame frame;
    float radius;
    Material mat;
};

//the local-frame sdf
float sdf(vec3 p, ExceptionalLines obj) {
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        d = min(d, lineDist(p, EXCEPTIONAL_LINES[i]));
    }
    d -= obj.radius;
    return max(d, sceneBBox(p));
}

float sdf_cached(ExceptionalLines obj) {
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        d = min(d, lineDist(_cachedPos, EXCEPTIONAL_LINES[i]));
    }
    d -= obj.radius;
    return max(d, _cachedBBox);
}

//the standard interface: initObject, at, inside, sdf
OBJECT_INIT(ExceptionalLines)
OBJECT_LOCATORS(ExceptionalLines)

//analytic normalVec: normal of the nearest line, computed in local coordinates
Vector normalVec(Vector tv, ExceptionalLines obj) {
    vec3 q = toLocal(obj.frame, tv.pos);
    float best = 1e6;
    int idx = 0;
    for (int i = 0; i < 6; i++) {
        float d = lineDist(q, EXCEPTIONAL_LINES[i]);
        if (d < best) { best = d; idx = i; }
    }
    vec3 n = lineNormal(q, EXCEPTIONAL_LINES[idx]);
    return Vector(tv.pos, dirToWorld(obj.frame, n));
}

//the standard setData
OBJECT_SETDATA(ExceptionalLines)
