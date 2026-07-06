
//----------------------------------------------------------------------------------------------
// CUBIC SURFACE LINES — THREE CLASS STRUCTS
// before including this file, provide:
//   Line struct + lineDist + lineNormal (from line.glsl)
//   const Line PAIR_LINES[15]
//   const Line CONIC_LINES[6]
//   const Line EXCEPTIONAL_LINES[6]
//   float sceneBBox(vec3 pos)
// Also expects cached globals: _cachedBBox, _cachedPos
//----------------------------------------------------------------------------------------------


// ============================================================
// PAIR LINES (15 lines)
// ============================================================

struct PairLines {
    vec3 center;
    float radius;
    Material mat;
};

//the point-level sdf
float sdf(vec3 p, PairLines obj) {
    vec3 pos = p - obj.center;
    float d = 1e6;
    for (int i = 0; i < 15; i++) {
        d = min(d, lineDist(pos, PAIR_LINES[i]));
    }
    d -= obj.radius;
    return max(d, sceneBBox(pos));
}

float sdf_cached(PairLines obj) {
    float d = 1e6;
    for (int i = 0; i < 15; i++) {
        d = min(d, lineDist(_cachedPos, PAIR_LINES[i]));
    }
    d -= obj.radius;
    return max(d, _cachedBBox);
}

//the standard locators: at, inside, sdf
OBJECT_LOCATORS(PairLines)

Vector normalVec(Vector tv, PairLines obj) {
    vec3 pos = tv.pos - obj.center;
    float best = 1e6;
    int idx = 0;
    for (int i = 0; i < 15; i++) {
        float d = lineDist(pos, PAIR_LINES[i]);
        if (d < best) { best = d; idx = i; }
    }
    vec3 n = lineNormal(pos, PAIR_LINES[idx]);
    return Vector(tv.pos, n);
}

//the standard setData
OBJECT_SETDATA(PairLines)


// ============================================================
// CONIC LINES (6 lines)
// ============================================================

struct ConicLines {
    vec3 center;
    float radius;
    Material mat;
};

//the point-level sdf
float sdf(vec3 p, ConicLines obj) {
    vec3 pos = p - obj.center;
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        d = min(d, lineDist(pos, CONIC_LINES[i]));
    }
    d -= obj.radius;
    return max(d, sceneBBox(pos));
}

float sdf_cached(ConicLines obj) {
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        d = min(d, lineDist(_cachedPos, CONIC_LINES[i]));
    }
    d -= obj.radius;
    return max(d, _cachedBBox);
}

//the standard locators: at, inside, sdf
OBJECT_LOCATORS(ConicLines)

Vector normalVec(Vector tv, ConicLines obj) {
    vec3 pos = tv.pos - obj.center;
    float best = 1e6;
    int idx = 0;
    for (int i = 0; i < 6; i++) {
        float d = lineDist(pos, CONIC_LINES[i]);
        if (d < best) { best = d; idx = i; }
    }
    vec3 n = lineNormal(pos, CONIC_LINES[idx]);
    return Vector(tv.pos, n);
}

//the standard setData
OBJECT_SETDATA(ConicLines)


// ============================================================
// EXCEPTIONAL LINES (6 lines)
// ============================================================

struct ExceptionalLines {
    vec3 center;
    float radius;
    Material mat;
};

//the point-level sdf
float sdf(vec3 p, ExceptionalLines obj) {
    vec3 pos = p - obj.center;
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        d = min(d, lineDist(pos, EXCEPTIONAL_LINES[i]));
    }
    d -= obj.radius;
    return max(d, sceneBBox(pos));
}

float sdf_cached(ExceptionalLines obj) {
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        d = min(d, lineDist(_cachedPos, EXCEPTIONAL_LINES[i]));
    }
    d -= obj.radius;
    return max(d, _cachedBBox);
}

//the standard locators: at, inside, sdf
OBJECT_LOCATORS(ExceptionalLines)

Vector normalVec(Vector tv, ExceptionalLines obj) {
    vec3 pos = tv.pos - obj.center;
    float best = 1e6;
    int idx = 0;
    for (int i = 0; i < 6; i++) {
        float d = lineDist(pos, EXCEPTIONAL_LINES[i]);
        if (d < best) { best = d; idx = i; }
    }
    vec3 n = lineNormal(pos, EXCEPTIONAL_LINES[idx]);
    return Vector(tv.pos, n);
}

//the standard setData
OBJECT_SETDATA(ExceptionalLines)
