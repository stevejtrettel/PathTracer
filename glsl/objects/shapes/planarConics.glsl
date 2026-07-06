
//----------------------------------------------------------------------------------------------
// PLANAR CONIC CURVES
// Tubes around conic curves Q(x,z) = 0 in the xz plane.
// before including this file, provide:
//   struct Conic2D + conicTubeDist (defined in objects.glsl)
//   const Conic2D PLANE_CONICS[6]
//   float plateBBox(vec3 pos)
//----------------------------------------------------------------------------------------------


struct PlanarConics {
    Frame frame;
    float radius;    // tube thickness
    Material mat;
};

//the local-frame sdf
float sdf(vec3 p, PlanarConics obj) {
    float d = 1e6;
    for (int i = 0; i < 6; i++) {
        d = min(d, conicTubeDist(p, PLANE_CONICS[i], obj.radius));
    }
    return max(d, plateBBox(p));
}

//the standard interface: initObject, at, inside, sdf, normalVec, setData
OBJECT_API(PlanarConics)
