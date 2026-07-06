
//----------------------------------------------------------------------------------------------
// CHECKERS — 6 rounded cylinders at exceptional points
// before including this file, provide:
//   const vec2 POINTS[6]  — (x,z) positions
//----------------------------------------------------------------------------------------------


float sdRoundedCylinder(vec3 p, float r, float h, float rnd) {
    vec2 d = abs(vec2(length(p.xz), p.y)) - vec2(r - rnd, h - rnd);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - rnd;
}


struct Checkers {
    vec3 center;
    float cylRadius;   // xz radius of each checker
    float cylHeight;   // half-height
    float rounding;    // edge rounding
    float yOffset;     // y position of checker centers above diagram center
    Material mat;
};

//the point-level sdf
float sdf(vec3 p, Checkers obj) {
    vec3 pos = p - obj.center;
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        vec3 localPos = pos - vec3(POINTS[i].x, obj.yOffset, POINTS[i].y);
        d = min(d, sdRoundedCylinder(localPos, obj.cylRadius, obj.cylHeight, obj.rounding));
    }
    return d;
}

//the standard interface: at, inside, sdf, normalVec, setData
OBJECT_API(Checkers)
