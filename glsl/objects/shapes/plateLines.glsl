
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
    Frame frame;
    float radius;    // tube thickness
    Material mat;
};

//the local-frame sdf
float sdf(vec3 p, PlateLines obj) {
    float d = 1e6;
    for (int i = 0; i < 15; i++) {
        d = min(d, lineDist2D(p, PLANE_LINES[i]));
    }
    d -= obj.radius;
    return max(d, plateBBox(p));
}

//the standard interface: initObject, at, inside, sdf
OBJECT_INIT(PlateLines)
OBJECT_LOCATORS(PlateLines)

//analytic normalVec: normal of the nearest line, computed in local coordinates
Vector normalVec(Vector tv, PlateLines obj) {
    vec3 q = toLocal(obj.frame, tv.pos);
    float best = 1e6;
    int idx = 0;
    for (int i = 0; i < 15; i++) {
        float d = lineDist2D(q, PLANE_LINES[i]);
        if (d < best) { best = d; idx = i; }
    }
    vec3 n = lineNormal2D(q, PLANE_LINES[idx]);
    return Vector(tv.pos, dirToWorld(obj.frame, n));
}

//the standard setData
OBJECT_SETDATA(PlateLines)
