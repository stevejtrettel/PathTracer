
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

float distR3(vec3 p, Checkers obj) {
    vec3 pos = p - obj.center;
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        vec3 localPos = pos - vec3(POINTS[i].x, obj.yOffset, POINTS[i].y);
        d = min(d, sdRoundedCylinder(localPos, obj.cylRadius, obj.cylHeight, obj.rounding));
    }
    return d;
}

float distR3(Vector tv, Checkers obj) {
    return distR3(tv.pos, obj);
}

float sdf(Vector tv, Checkers obj) {
    return distR3(tv.pos, obj);
}

bool at(Vector tv, Checkers obj) {
    float d = distR3(tv.pos, obj);
    return (abs(d) - AT_THRESH) < 0.;
}

bool inside(Vector tv, Checkers obj) {
    return distR3(tv.pos, obj) < 0.;
}

Vector normalVec(Vector tv, Checkers obj) {
    vec3 pos = tv.pos;
    const float ep = 0.0001;
    vec2 e = vec2(1.0, -1.0) * 0.5773;

    float vxyy = distR3(pos + e.xyy * ep, obj);
    float vyyx = distR3(pos + e.yyx * ep, obj);
    float vyxy = distR3(pos + e.yxy * ep, obj);
    float vxxx = distR3(pos + e.xxx * ep, obj);

    vec3 dir = e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;
    return Vector(tv.pos, normalize(dir));
}

void setData(inout Path path, Checkers obj) {
    if (at(path.tv, obj)) {
        Vector normal = normalVec(path.tv, obj);
        bool side = inside(path.tv, obj);
        setObjectInAir(path.dat, side, normal, obj.mat);
    }
}
