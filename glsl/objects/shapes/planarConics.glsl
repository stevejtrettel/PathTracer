
//----------------------------------------------------------------------------------------------
// PLANAR CONIC CURVES
// Tubes around conic curves Q(x,z) = 0 in the xz plane.
// before including this file, provide:
//   struct Conic2D + conicTubeDist (defined in objects.glsl)
//   const Conic2D PLANE_CONICS[6]
//   float plateBBox(vec3 pos)
//----------------------------------------------------------------------------------------------


struct PlanarConics {
    vec3 center;
    float radius;    // tube thickness
    Material mat;
};

float distR3(vec3 p, PlanarConics obj) {
    vec3 pos = p - obj.center;
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        d = min(d, conicTubeDist(pos, PLANE_CONICS[i], obj.radius));
    }
    return max(d, plateBBox(pos));
}

float distR3(Vector tv, PlanarConics obj) {
    return distR3(tv.pos, obj);
}

float sdf(Vector tv, PlanarConics obj) {
    return distR3(tv.pos, obj);
}

bool at(Vector tv, PlanarConics obj) {
    float d = distR3(tv.pos, obj);
    return (abs(d) - AT_THRESH) < 0.;
}

bool inside(Vector tv, PlanarConics obj) {
    return distR3(tv.pos, obj) < 0.;
}

Vector normalVec(Vector tv, PlanarConics obj) {
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

void setData(inout Path path, PlanarConics obj) {
    if (at(path.tv, obj)) {
        Vector normal = normalVec(path.tv, obj);
        bool side = inside(path.tv, obj);
        setObjectInAir(path.dat, side, normal, obj.mat);
    }
}
