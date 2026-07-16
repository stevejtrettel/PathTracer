// ---------- glsl/objects/shapes/curves/Helix.glsl ----------
const int CURVE_HELIX  = 1;
const int RAD_CONST    = 0;
const int RAD_TAPER    = 2;

vec3 helixPos(float t, float R, float pitch) {
    return vec3(R * cos(t), R * sin(t), pitch * t);
}

float helixRadiusTaper(float t, float baseR, float k) {
    // simple cosine taper
    return baseR * (0.75 + 0.25 * cos(k * t));
}
