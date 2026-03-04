//-------------------------------------------------
// OBJECTS OF THE SCENE
// Combined: cubic surface (left) + blowup diagram plate (right)
//-------------------------------------------------


// ============================================
// SECTION 1: STRUCT DEFINITIONS
// ============================================

// --- 3D Line (for cubic surface lines) ---
#include ../../../glsl/objects/shapes/line.glsl

// --- 2D Line in xz plane (for plate lines) ---
struct Line2D {
    vec2 point;
    vec2 dir;    // must be unit length
};

float lineDist2D(vec3 pos, Line2D l) {
    vec2 diff = pos.xz - l.point;
    vec2 perp = diff - dot(diff, l.dir) * l.dir;
    return sqrt(dot(perp, perp) + pos.y * pos.y);
}

vec3 lineNormal2D(vec3 pos, Line2D l) {
    vec2 diff = pos.xz - l.point;
    vec2 perp = diff - dot(diff, l.dir) * l.dir;
    return normalize(vec3(perp.x, pos.y, perp.y));
}

// --- 2D Conic in xz plane ---
struct Conic2D {
    float c0, c1, c2, c3, c4, c5;
};

float conicVal(vec2 xz, Conic2D c) {
    float x = xz.x, z = xz.y;
    return c.c0*x*x + c.c1*x*z + c.c2*x + c.c3*z*z + c.c4*z + c.c5;
}

vec2 conicGrad2D(vec2 xz, Conic2D c) {
    float x = xz.x, z = xz.y;
    float dx = 2.0*c.c0*x + c.c1*z + c.c2;
    float dz = c.c1*x + 2.0*c.c3*z + c.c4;
    return vec2(dx, dz);
}

float conicTubeDist(vec3 pos, Conic2D c, float radius) {
    float val = conicVal(pos.xz, c);
    vec2 grad = conicGrad2D(pos.xz, c);
    float dConic = abs(val) / max(length(grad), 1e-6);
    float dPlane = abs(pos.y);
    return sqrt(dConic * dConic + dPlane * dPlane) - radius;
}


// ============================================
// SECTION 2: DATA
// ============================================

// Cubic surface data (C[20], PAIR_LINES, CONIC_LINES, EXCEPTIONAL_LINES)
#include ../../cubicSurface/src/scene3d.glsl

// Plate data (POINTS, PLANE_LINES, PLANE_CONICS)
#include ../../cubicPlane/src/scene2d.glsl


// ============================================
// SECTION 3: CUBIC f() AND fGrad()
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
// SECTION 4: BOUNDING SDFs
// ============================================

// Sphere bounding for cubic surface group
float sceneBBox(vec3 pos) {
    return length(pos) - 2.0;
}

// Box bounding for plate group (lines + conics clipped to plate)
const float PLATE_RADIUS = 2.0;

float plateBBox(vec3 pos) {
    vec2 d = abs(pos.xz) - vec2(PLATE_RADIUS);
    return max(d.x, d.y);
}


// ============================================
// SECTION 5: CACHED GLOBALS (for surface)
// ============================================

float _cachedBBox;
float _cachedVal;
vec3  _cachedGrad;
vec3  _cachedPos;


// ============================================
// SECTION 6: SURFACE SHAPES
// ============================================

#include ../../../glsl/objects/shapes/cubicSurface.glsl
#include ../../../glsl/objects/shapes/cubicLines.glsl
#include ../../../glsl/objects/shapes/boundaryRing.glsl


// ============================================
// SECTION 7: PLATE SHAPES
// ============================================

// Box is already available from the tracer setup shader (basic primitive).

#include ../../../glsl/objects/shapes/checkers.glsl
#include ../../../glsl/objects/shapes/plateLines.glsl
#include ../../../glsl/objects/shapes/planarConics.glsl


// ============================================
// SECTION 8: INSTANCES
// ============================================

// Surface group
CubicSurface surface;
PairLines pairLines;
ConicLines conicLines;
ExceptionalLines exceptionalLines;
BoundaryRing ring;

// Plate group
Box plate;
Checkers checkers;
PlateLines plateLines;
PlanarConics planarConics;


// ============================================
// SECTION 9: BUILD
// ============================================

// Offsets to position the two groups side by side
const vec3 SURFACE_POS = vec3(-3, 0, 0);
const vec3 PLATE_POS   = vec3(3.5, -2.4, 0);

void buildObjects() {

    // === SURFACE GROUP (left) ===

    surface.center = SURFACE_POS;
    surface.scale = 1.0;
    surface.thickness = vec2(0.01, 0.0);
    surface.smoothing = 0.05;
    surface.mat = makeGlass(vec3(0.5, 0.3, 0.1), 1.5, 0.95);

    pairLines.center = SURFACE_POS;
    pairLines.radius = 0.02;
    pairLines.mat = makeMetal(vec3(0.55), 0.8, 0.1);

    conicLines.center = SURFACE_POS;
    conicLines.radius = 0.02;
    conicLines.mat = makeMetal(vec3(0.2, 0.45, 0.9), 0.8, 0.1);

    exceptionalLines.center = SURFACE_POS;
    exceptionalLines.radius = 0.02;
    exceptionalLines.mat = makeMetal(vec3(0.9, 0.25, 0.2), 0.8, 0.1);

    ring.center = SURFACE_POS;
    ring.radius = 0.01;
    ring.scale = surface.scale;
    ring.mat = makeMetal(vec3(0.1), 0.6, 0.2);

    // === PLATE GROUP (right, sitting on floor) ===

    plate.center = PLATE_POS;
    plate.sides = vec3(PLATE_RADIUS, 0.05, PLATE_RADIUS);
    plate.rounded = 0.02;
    plate.mat = makeGlass(vec3(0.5, 0.3, 0.1), 1.5, 0.95);

    checkers.center = PLATE_POS;
    checkers.cylRadius = 0.08;
    checkers.cylHeight = 0.03;
    checkers.rounding = 0.01;
    checkers.yOffset = 0.08;
    checkers.mat = makeMetal(vec3(0.9, 0.25, 0.2), 0.8, 0.1);

    plateLines.center = PLATE_POS + vec3(0, 0.05, 0);
    plateLines.radius = 0.025;
    plateLines.mat = makeMetal(vec3(0.55), 0.8, 0.1);

    planarConics.center = PLATE_POS + vec3(0, 0.05, 0);
    planarConics.radius = 0.025;
    planarConics.mat = makeMetal(vec3(0.2, 0.45, 0.9), 0.8, 0.1);
}


// ============================================
// SECTION 10: SCENE WIRING
// ============================================

bool render_Objects = true;

float trace_Objects(Vector tv) {
    return maxDist;   // nothing analytically traced
}

float sdf_Objects(Vector tv) {

    float dist = maxDist;

    // --- Surface group (sphere bbox, with caching) ---
    vec3 surfPos = tv.pos - surface.center;
    _cachedBBox = sceneBBox(surfPos);
    _cachedPos = surfPos;

    if (_cachedBBox <= 0.0) {
        vec3 scaled = surface.scale * surfPos;
        _cachedVal = cubicF(scaled);
        _cachedGrad = cubicGrad(scaled);

        dist = min(dist, sdf_cached(surface));
        dist = min(dist, sdf_cached(pairLines));
        dist = min(dist, sdf_cached(conicLines));
        dist = min(dist, sdf_cached(exceptionalLines));
        dist = min(dist, sdf_cached(ring));
    } else {
        dist = min(dist, _cachedBBox);
    }

    // --- Plate group ---
    dist = min(dist, sdf(tv, plate));
    dist = min(dist, sdf(tv, checkers));
    dist = min(dist, sdf(tv, plateLines));
    dist = min(dist, sdf(tv, planarConics));

    return dist;
}

bool inside_Object(Vector tv) {
    return inside(tv, surface) || inside(tv, plate);
}

void setData_Objects(inout Path path) {
    // Surface group
    setData(path, surface);
    setData(path, pairLines);
    setData(path, conicLines);
    setData(path, exceptionalLines);
    setData(path, ring);

    // Plate group
    setData(path, plate);
    setData(path, checkers);
    setData(path, plateLines);
    setData(path, planarConics);
}
