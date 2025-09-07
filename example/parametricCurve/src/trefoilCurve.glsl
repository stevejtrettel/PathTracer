// ---------- glsl/objects/shapes/curves/Trefoil.glsl ----------
const int CURVE_TREFOIL = 3;

vec3 trefoilPos(float t) {
    // classic trefoil (scaled nicely)
    float x = (2.0 + cos(3.0*t)) * cos(2.0*t);
    float y = (2.0 + cos(3.0*t)) * sin(2.0*t);
    float z = sin(3.0*t);
    return vec3(x, y, z);
}
