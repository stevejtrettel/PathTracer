
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

//the point-level sdf
float sdf(vec3 p, PlanarConics obj) {
    vec3 pos = p - obj.center;
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        d = min(d, conicTubeDist(pos, PLANE_CONICS[i], obj.radius));
    }
    return max(d, plateBBox(pos));
}

//the standard interface: at, inside, sdf, normalVec, setData
OBJECT_API(PlanarConics)
