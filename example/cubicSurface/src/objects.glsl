//-------------------------------------------------
// OBJECTS OF THE SCENE
// Cubic surface with 27 lines
//-------------------------------------------------


// ============================================
// SECTION 1: DATA (coefficients + lines)
// ============================================

// Line primitive (needed before data.glsl)
#include ../../../glsl/objects/shapes/line.glsl

// Surface data — swap this file to change the cubic
#include ./scene3d.glsl


// ============================================
// SECTION 2: CUBIC f() AND fGrad()
// ============================================

float cubicF(vec3 p) {
    float x = p.x, y = p.y, z = p.z;
    float x2 = x*x, y2 = y*y, z2 = z*z;

    return C[0]*x2*x   + C[1]*x2*y   + C[2]*x2*z   + C[3]*x2
         + C[4]*x*y2   + C[5]*x*y*z  + C[6]*x*y     + C[7]*x*z2
         + C[8]*x*z    + C[9]*x
         + C[10]*y2*y  + C[11]*y2*z  + C[12]*y2     + C[13]*y*z2
         + C[14]*y*z   + C[15]*y
         + C[16]*z2*z  + C[17]*z2    + C[18]*z      + C[19];
}

vec3 cubicGrad(vec3 p) {
    float x = p.x, y = p.y, z = p.z;
    float x2 = x*x, y2 = y*y, z2 = z*z;

    float dx = 3.0*C[0]*x2   + 2.0*C[1]*x*y  + 2.0*C[2]*x*z + 2.0*C[3]*x
             +     C[4]*y2   +     C[5]*y*z   +     C[6]*y    +     C[7]*z2
             +     C[8]*z    +     C[9];

    float dy =     C[1]*x2   + 2.0*C[4]*x*y   +     C[5]*x*z +     C[6]*x
             + 3.0*C[10]*y2  + 2.0*C[11]*y*z  + 2.0*C[12]*y  +     C[13]*z2
             +     C[14]*z   +     C[15];

    float dz =     C[2]*x2   +     C[5]*x*y   + 2.0*C[7]*x*z +     C[8]*x
             +     C[11]*y2  + 2.0*C[13]*y*z  +     C[14]*y
             + 3.0*C[16]*z2  + 2.0*C[17]*z    +     C[18];

    return vec3(dx, dy, dz);
}


// ============================================
// SECTION 3: BOUNDING SDF
// ============================================

// Shared by surface + lines + boundary ring.
// Change this to swap bounding shape.
float sceneBBox(vec3 pos) {
    return length(pos) - 2.0;   // sphere of radius 2
}


// ============================================
// SECTION 4: CACHED GLOBALS
// ============================================

// Computed once per sdf_Objects call, reused by all objects.
float _cachedBBox;
float _cachedVal;
vec3  _cachedGrad;
vec3  _cachedPos;


// ============================================
// SECTION 5: SURFACE
// ============================================
#include ../../../glsl/objects/shapes/cubicSurface.glsl


// ============================================
// SECTION 6: LINES
// ============================================
#include ../../../glsl/objects/shapes/cubicLines.glsl


// ============================================
// SECTION 7: BOUNDARY RING
// ============================================
#include ../../../glsl/objects/shapes/boundaryRing.glsl


// ============================================
// SECTION 8: INSTANCES
// ============================================

CubicSurface surface;
PairLines pairLines;
ConicLines conicLines;
ExceptionalLines exceptionalLines;
BoundaryRing ring;


// ============================================
// SECTION 9: BUILD
// ============================================

void buildObjects() {

    // --- Surface ---
    surface.center = vec3(0);
    surface.scale = 1.0;
    surface.thickness = vec2(0.01, 0.0);   // thin shell
    surface.smoothing = 0.05;
    surface.mat = makeGlass(vec3(0.5, 0.3, 0.1), 1.5, 0.95);

    // --- Pair lines (gray) ---
    pairLines.center = vec3(0);
    pairLines.radius = 0.02;
    pairLines.mat = makeMetal(vec3(0.55), 0.8, 0.1);

    // --- Conic lines (blue) ---
    conicLines.center = vec3(0);
    conicLines.radius = 0.02;
    conicLines.mat = makeMetal(vec3(0.2, 0.45, 0.9), 0.8, 0.1);

    // --- Exceptional lines (red) ---
    exceptionalLines.center = vec3(0);
    exceptionalLines.radius = 0.02;
    exceptionalLines.mat = makeMetal(vec3(0.9, 0.25, 0.2), 0.8, 0.1);

    // --- Boundary ring ---
    ring.center = vec3(0);
    ring.radius = 0.01;
    ring.scale = surface.scale;
    ring.mat = makeMetal(vec3(0.1), 0.6, 0.2);
}


// ============================================
// SECTION 10: SCENE WIRING
// ============================================

bool render_Objects = true;

float trace_Objects(Vector tv) {
    return maxDist;   // nothing analytically traced
}

float sdf_Objects(Vector tv) {
    // All objects share surface.center — compute bbox ONCE
    vec3 pos = tv.pos - surface.center;
    _cachedBBox = sceneBBox(pos);
    _cachedPos = pos;

    // Early exit: most march steps are far from the object.
    if (_cachedBBox > 0.0) return _cachedBBox;

    // Inside bbox: evaluate cubic ONCE, cache for surface + ring
    vec3 scaled = surface.scale * pos;
    _cachedVal = cubicF(scaled);
    _cachedGrad = cubicGrad(scaled);

    float dist = maxDist;
    dist = min(dist, sdf_cached(surface));
    dist = min(dist, sdf_cached(pairLines));
    dist = min(dist, sdf_cached(conicLines));
    dist = min(dist, sdf_cached(exceptionalLines));
    dist = min(dist, sdf_cached(ring));
    return dist;
}

bool inside_Object(Vector tv) {
    return inside(tv, surface);
}

void setData_Objects(inout Path path) {
    setData(path, surface);
    setData(path, pairLines);
    setData(path, conicLines);
    setData(path, exceptionalLines);
    setData(path, ring);
}
