
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

//the point-level sdf
float sdf(vec3 p, PlateLines obj) {
    vec3 pos = p - obj.center;
    float d = 1e6;
    for (int i = 0; i < 15; i++) {
        d = min(d, lineDist2D(pos, PLANE_LINES[i]));
    }
    d -= obj.radius;
    return max(d, plateBBox(pos));
}

//the standard locators: at, inside, sdf
OBJECT_LOCATORS(PlateLines)

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

//the standard setData
OBJECT_SETDATA(PlateLines)
