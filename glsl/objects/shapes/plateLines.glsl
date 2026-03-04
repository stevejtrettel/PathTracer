
//----------------------------------------------------------------------------------------------
// PLATE LINES — 15 line tubes in xz plane, clipped to a bounding region
// before including this file, provide:
//   struct Line2D { vec2 point; vec2 dir; };
//   float lineDist2D(vec3, Line2D)
//   vec3 lineNormal2D(vec3, Line2D)
//   const Line2D PLANE_LINES[15]
//   float plateBBox(vec3 pos)
//----------------------------------------------------------------------------------------------


struct PlateLines {
    vec3 center;
    float radius;    // tube thickness
    Material mat;
};

float distR3(vec3 p, PlateLines obj) {
    vec3 pos = p - obj.center;
    float d = 1e6;
    for (int i = 0; i < 15; i++) {
        d = min(d, lineDist2D(pos, PLANE_LINES[i]));
    }
    d -= obj.radius;
    return max(d, plateBBox(pos));
}

float distR3(Vector tv, PlateLines obj) {
    return distR3(tv.pos, obj);
}

float sdf(Vector tv, PlateLines obj) {
    return distR3(tv.pos, obj);
}

bool at(Vector tv, PlateLines obj) {
    float d = distR3(tv.pos, obj);
    return (abs(d) - AT_THRESH) < 0.;
}

bool inside(Vector tv, PlateLines obj) {
    return distR3(tv.pos, obj) < 0.;
}

Vector normalVec(Vector tv, PlateLines obj) {
    vec3 pos = tv.pos - obj.center;
    float best = 1e6;
    int idx = 0;
    for (int i = 0; i < 15; i++) {
        float d = lineDist2D(pos, PLANE_LINES[i]);
        if (d < best) { best = d; idx = i; }
    }
    vec3 n = lineNormal2D(pos, PLANE_LINES[idx]);
    return Vector(tv.pos, n);
}

void setData(inout Path path, PlateLines obj) {
    if (at(path.tv, obj)) {
        Vector normal = normalVec(path.tv, obj);
        bool side = inside(path.tv, obj);
        setObjectInAir(path.dat, side, normal, obj.mat);
    }
}
