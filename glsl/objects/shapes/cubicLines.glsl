
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

float distR3(vec3 p, PairLines obj) {
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

float distR3(Vector tv, PairLines obj) {
    return distR3(tv.pos, obj);
}

float sdf(Vector tv, PairLines obj) {
    return distR3(tv.pos, obj);
}

bool at(Vector tv, PairLines obj) {
    float d = distR3(tv.pos, obj);
    return (abs(d) - AT_THRESH) < 0.;
}

bool inside(Vector tv, PairLines obj) {
    return distR3(tv.pos, obj) < 0.;
}

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

void setData(inout Path path, PairLines obj) {
    if (at(path.tv, obj)) {
        Vector normal = normalVec(path.tv, obj);
        bool side = inside(path.tv, obj);
        setObjectInAir(path.dat, side, normal, obj.mat);
    }
}


// ============================================================
// CONIC LINES (6 lines)
// ============================================================

struct ConicLines {
    vec3 center;
    float radius;
    Material mat;
};

float distR3(vec3 p, ConicLines obj) {
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

float distR3(Vector tv, ConicLines obj) {
    return distR3(tv.pos, obj);
}

float sdf(Vector tv, ConicLines obj) {
    return distR3(tv.pos, obj);
}

bool at(Vector tv, ConicLines obj) {
    float d = distR3(tv.pos, obj);
    return (abs(d) - AT_THRESH) < 0.;
}

bool inside(Vector tv, ConicLines obj) {
    return distR3(tv.pos, obj) < 0.;
}

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

void setData(inout Path path, ConicLines obj) {
    if (at(path.tv, obj)) {
        Vector normal = normalVec(path.tv, obj);
        bool side = inside(path.tv, obj);
        setObjectInAir(path.dat, side, normal, obj.mat);
    }
}


// ============================================================
// EXCEPTIONAL LINES (6 lines)
// ============================================================

struct ExceptionalLines {
    vec3 center;
    float radius;
    Material mat;
};

float distR3(vec3 p, ExceptionalLines obj) {
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

float distR3(Vector tv, ExceptionalLines obj) {
    return distR3(tv.pos, obj);
}

float sdf(Vector tv, ExceptionalLines obj) {
    return distR3(tv.pos, obj);
}

bool at(Vector tv, ExceptionalLines obj) {
    float d = distR3(tv.pos, obj);
    return (abs(d) - AT_THRESH) < 0.;
}

bool inside(Vector tv, ExceptionalLines obj) {
    return distR3(tv.pos, obj) < 0.;
}

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

void setData(inout Path path, ExceptionalLines obj) {
    if (at(path.tv, obj)) {
        Vector normal = normalVec(path.tv, obj);
        bool side = inside(path.tv, obj);
        setObjectInAir(path.dat, side, normal, obj.mat);
    }
}
