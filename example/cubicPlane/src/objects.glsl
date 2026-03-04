//-------------------------------------------------
// OBJECTS OF THE SCENE
// Blowup diagram: 6 points, 15 lines, 6 conics on a glass plate
//-------------------------------------------------


// ============================================
// SECTION 1: STRUCT DEFINITIONS (before data)
// ============================================

// 2D line in the xz plane
struct Line2D {
    vec2 point;
    vec2 dir;    // must be unit length
};

// Distance from 3D point to infinite line in xz plane (tube distance)
float lineDist2D(vec3 pos, Line2D l) {
    vec2 diff = pos.xz - l.point;
    vec2 perp = diff - dot(diff, l.dir) * l.dir;
    return sqrt(dot(perp, perp) + pos.y * pos.y);
}

// Normal direction from 3D point toward line in xz plane
vec3 lineNormal2D(vec3 pos, Line2D l) {
    vec2 diff = pos.xz - l.point;
    vec2 perp = diff - dot(diff, l.dir) * l.dir;
    return normalize(vec3(perp.x, pos.y, perp.y));
}

// 2D conic in the xz plane: Q(x,z) = c0*x² + c1*xz + c2*x + c3*z² + c4*z + c5
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

// All data comes from this file — swap to change the configuration
#include ./scene2d.glsl


// ============================================
// SECTION 3: BOUNDING SDF
// ============================================

const float PLATE_RADIUS = 2.0;

float plateBBox(vec3 pos) {
    // Box bounding in xz to match the plate shape
    vec2 d = abs(pos.xz) - vec2(PLATE_RADIUS);
    return max(d.x, d.y);
}


// ============================================
// SECTION 4: SHAPES
// ============================================

// Box is already available from the tracer setup shader (basic primitive).

// Checker pieces at 6 exceptional points
#include ../../../glsl/objects/shapes/checkers.glsl

// 15 line tubes
#include ../../../glsl/objects/shapes/plateLines.glsl

// 6 conic curve tubes
#include ../../../glsl/objects/shapes/planarConics.glsl


// ============================================
// SECTION 5: INSTANCES
// ============================================

Box plate;
Checkers checkers;
PlateLines plateLines;
PlanarConics planarConics;


// ============================================
// SECTION 6: BUILD
// ============================================

void buildObjects() {

    // --- Glass plate ---
    plate.center = vec3(0);
    plate.sides = vec3(PLATE_RADIUS, 0.05, PLATE_RADIUS);
    plate.rounded = 0.02;
    plate.mat = makeGlass(vec3(0.5, 0.3, 0.1), 1.5, 0.95);

    // --- Checker pieces (red) ---
    checkers.center = vec3(0);
    checkers.cylRadius = 0.08;
    checkers.cylHeight = 0.03;
    checkers.rounding = 0.01;
    checkers.yOffset = 0.08;   // sit on top of plate
    checkers.mat = makeMetal(vec3(0.9, 0.25, 0.2), 0.8, 0.1);

    // --- 15 lines (gray) ---
    plateLines.center = vec3(0, 0.05, 0);   // sit on plate top surface
    plateLines.radius = 0.025;
    plateLines.mat = makeMetal(vec3(0.55), 0.8, 0.1);

    // --- 6 conics (blue) ---
    planarConics.center = vec3(0, 0.05, 0);   // sit on plate top surface
    planarConics.radius = 0.025;
    planarConics.mat = makeMetal(vec3(0.2, 0.45, 0.9), 0.8, 0.1);
}


// ============================================
// SECTION 7: SCENE WIRING
// ============================================

bool render_Objects = true;

float trace_Objects(Vector tv) {
    return maxDist;   // nothing analytically traced
}

float sdf_Objects(Vector tv) {

    float dist = maxDist;

    // Plate
    dist = min(dist, sdf(tv, plate));

    // Checkers
    dist = min(dist, sdf(tv, checkers));

    // Lines and conics clipped to plate region
    dist = min(dist, sdf(tv, plateLines));
    dist = min(dist, sdf(tv, planarConics));

    return dist;
}

bool inside_Object(Vector tv) {
    return inside(tv, plate);
}

void setData_Objects(inout Path path) {
    setData(path, plate);
    setData(path, checkers);
    setData(path, plateLines);
    setData(path, planarConics);
}
