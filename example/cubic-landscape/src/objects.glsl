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
#include ./scene3d.glsl

// Plate data (POINTS, PLANE_LINES, PLANE_CONICS)
#include ./scene2d.glsl


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
const float PLATE_RADIUS = 1.8;

float plateBBox(vec3 pos) {
    vec2 d = abs(pos.xz) - vec2(PLATE_RADIUS);
    return max(d.x, d.y);
}

// 3D bounding box for entire plate group (early exit in sdf_Objects)
float plateGroupBBox(vec3 pos) {
    vec3 d = abs(pos) - vec3(PLATE_RADIUS, PLATE_RADIUS, 0.15);
    vec3 q = max(d, 0.0);
    return length(q) + min(max(d.x, max(d.y, d.z)), 0.0);
}


// ============================================
// SECTION 5: CACHED GLOBALS (for surface)
// ============================================

float _cachedBBox;
float _cachedVal;
vec3  _cachedGrad;
vec3  _cachedPos;

// XZ rotation for the surface group (controlled by extra slider)
mat2 xzRot;
mat2 xzRotInv;

vec3 rotXZ(vec3 p) {
    vec2 r = xzRot * p.xz;
    return vec3(r.x, p.y, r.y);
}

vec3 unrotXZ(vec3 p) {
    vec2 r = xzRotInv * p.xz;
    return vec3(r.x, p.y, r.y);
}

// 90° rotation around x-axis: stands the xz plate up into xy plane
vec3 standUp(vec3 p) { return vec3(p.x, -p.z, p.y); }
vec3 layDown(vec3 p) { return vec3(p.x, p.z, -p.y); }

// Plate yaw (rotation around y-axis)
mat2 plateYawRot;
mat2 plateYawInv;

vec3 plateRot(vec3 p) {
    vec2 r = plateYawRot * p.xz;
    return vec3(r.x, p.y, r.y);
}
vec3 plateUnrot(vec3 p) {
    vec2 r = plateYawInv * p.xz;
    return vec3(r.x, p.y, r.y);
}


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

// Pedestals
Box pedestal;
Box platePedestal;

// Plate group
Box plate;
Checkers checkers;
PlateLines plateLines;
PlanarConics planarConics;


// ============================================
// SECTION 9: BUILD
// ============================================

// Layout: surface on pedestal (right), plate standing vertical on pedestal (left)
const float PEDESTAL_HEIGHT = 1.5;
const float PLATE_PED_HEIGHT = 0.8;
const float FLOOR_Y = -3.0;
const vec3 SURFACE_POS = vec3(3.0, FLOOR_Y + PEDESTAL_HEIGHT + 2.0, 0);
const vec3 PEDESTAL_POS = vec3(3.0, FLOOR_Y + PEDESTAL_HEIGHT * 0.5, 0);
const vec3 PLATE_PED_POS = vec3(-2.5, FLOOR_Y + PLATE_PED_HEIGHT * 0.5, 0);
// Plate center: on top of its pedestal, raised by PLATE_RADIUS so bottom edge rests on pedestal
const vec3 PLATE_POS    = vec3(-2.5, FLOOR_Y + PLATE_PED_HEIGHT + PLATE_RADIUS, 0);


void buildObjects() {

    // XZ rotation from extra slider (0→2π)
    float angle = extra * 6.2832;
    float ca = cos(angle), sa = sin(angle);
    xzRot = mat2(ca, sa, -sa, ca);
    xzRotInv = mat2(ca, -sa, sa, ca);

    // Plate yaw (fixed angle)
    float plateAngle = 0.5;
    float pca = cos(plateAngle), psa = sin(plateAngle);
    plateYawRot = mat2(pca, psa, -psa, pca);
    plateYawInv = mat2(pca, -psa, psa, pca);

    // === PEDESTAL ===

    pedestal.center = PEDESTAL_POS;
    pedestal.sides = vec3(0.8, PEDESTAL_HEIGHT * 0.5, 0.8);
    pedestal.rounded = 0.05;
    pedestal.mat = makeGlass(vec3(0.1, 0.05, 0.1), 1.5, 0.98);

    // === SURFACE GROUP (on pedestal) ===

    surface.center = SURFACE_POS;
    surface.scale = 1.0;
    surface.thickness = vec2(0.05, 0.0);
    surface.smoothing = 0.05;
    surface.mat = makeGlass(3.*vec3(0.3, 0.05, 0.2), 1.3, 0.97);

    pairLines.center = SURFACE_POS;
    pairLines.radius = 0.02;
    pairLines.mat = makeMetal(vec3(0.7, 0.7, 0.75), 0.6, 0.2);

    conicLines.center = SURFACE_POS;
    conicLines.radius = 0.02;
    conicLines.mat = makeMetal(vec3(0.85, 0.6, 0.15), 0.6, 0.2);

    exceptionalLines.center = SURFACE_POS;
    exceptionalLines.radius = 0.02;
    exceptionalLines.mat = makeMetal(vec3(0.75, 0.35, 0.35), 0.6, 0.2);

    ring.center = SURFACE_POS;
    ring.radius = 0.05;
    ring.scale = surface.scale;
    ring.mat = makeMetal(vec3(0.1), 0.3, 0.4);

    // === PLATE PEDESTAL (glass box, wider and shorter than surface pedestal) ===

    platePedestal.center = PLATE_PED_POS;
    platePedestal.sides = vec3(1.2, PLATE_PED_HEIGHT * 0.5, 0.4);
    platePedestal.rounded = 0.05;
    platePedestal.mat = makeGlass(vec3(0.1, 0.05, 0.1), 1.5, 0.98);

    // === PLATE GROUP (standing vertical — shapes evaluate in rotated frame) ===
    // Shapes work in xz plane; standUp() rotates query so xy plane maps to xz

    plate.center = PLATE_POS;
    plate.sides = vec3(PLATE_RADIUS, PLATE_RADIUS, 0.05);
    plate.rounded = 0.02;
    plate.mat = makeGlass(vec3(0.3, 0.05, 0.2), 1.5, 0.97);

    checkers.center = PLATE_POS;
    checkers.cylRadius = 0.06;
    checkers.cylHeight = 0.02;
    checkers.rounding = 0.008;
    checkers.yOffset = 0.07;
    checkers.mat = makeMetal(vec3(0.75, 0.35, 0.35), 0.6, 0.2);

    plateLines.center = PLATE_POS + vec3(0, 0.06, 0);
    plateLines.radius = 0.02;
    plateLines.mat = makeMetal(vec3(0.7, 0.7, 0.75), 0.6, 0.2);

    planarConics.center = PLATE_POS + vec3(0, 0.06, 0);
    planarConics.radius = 0.02;
    planarConics.mat = makeMetal(vec3(0.85, 0.6, 0.15), 0.6, 0.2);
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
    vec3 surfPos = rotXZ(tv.pos - surface.center);
    _cachedBBox = sceneBBox(surfPos);   // sphere: rotation-invariant
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

    // --- Pedestal (surface) ---
    dist = min(dist, sdf(tv, pedestal));

    // --- Plate group + pedestal (yaw-rotated, standing vertical) ---
    vec3 plateLocalYaw = plateRot(tv.pos - PLATE_POS);
    Vector plateTVYaw = Vector(plateLocalYaw + PLATE_POS, tv.dir);

    dist = min(dist, sdf(plateTVYaw, platePedestal));

    if (dist > 0.001) {
        float plateGroupDist = plateGroupBBox(plateLocalYaw);
        if (plateGroupDist <= 0.0) {
            dist = min(dist, sdf(plateTVYaw, plate));
            // Compose yaw + standUp for shapes that work in xz
            Vector rotTV = Vector(standUp(plateLocalYaw) + PLATE_POS, tv.dir);
            dist = min(dist, sdf(rotTV, checkers));
            dist = min(dist, sdf(rotTV, plateLines));
            dist = min(dist, sdf(rotTV, planarConics));
        } else {
            dist = min(dist, plateGroupDist);
        }
    }

    return dist;
}

bool inside_Object(Vector tv) {
    Vector rotTV = Vector(rotXZ(tv.pos - SURFACE_POS) + SURFACE_POS, tv.dir);
    Vector plateTV = Vector(plateRot(tv.pos - PLATE_POS) + PLATE_POS, tv.dir);
    return inside(rotTV, surface) || inside(plateTV, plate)
        || inside(tv, pedestal) || inside(plateTV, platePedestal);
}

void setData_Objects(inout Path path) {
    // Rotate query point into surface-local frame
    Vector origTV = path.tv;
    path.tv.pos = rotXZ(path.tv.pos - SURFACE_POS) + SURFACE_POS;

    // Surface group (evaluated in rotated frame)
    setData(path, surface);
    setData(path, pairLines);
    setData(path, conicLines);
    setData(path, exceptionalLines);
    setData(path, ring);

    // Un-rotate the normal back to world space
    path.dat.normal.dir = unrotXZ(path.dat.normal.dir);
    path.dat.normal.pos = origTV.pos;

    // Restore original tv for plate group
    path.tv = origTV;

    // Surface pedestal (no rotation)
    setData(path, pedestal);

    // Plate group: apply yaw rotation
    Vector plateOrigTV = path.tv;
    vec3 plateLocalYaw = plateRot(path.tv.pos - PLATE_POS);

    // Plate box + pedestal (yaw only)
    path.tv.pos = plateLocalYaw + PLATE_POS;
    vec3 prevNormal1 = path.dat.normal.dir;

    setData(path, platePedestal);
    setData(path, plate);

    if (any(notEqual(path.dat.normal.dir, prevNormal1))) {
        path.dat.normal.dir = plateUnrot(path.dat.normal.dir);
        path.dat.normal.pos = plateOrigTV.pos;
    }

    // Plate shapes (yaw + standUp)
    path.tv.pos = standUp(plateLocalYaw) + PLATE_POS;
    vec3 prevNormal2 = path.dat.normal.dir;

    setData(path, checkers);
    setData(path, plateLines);
    setData(path, planarConics);

    if (any(notEqual(path.dat.normal.dir, prevNormal2))) {
        path.dat.normal.dir = plateUnrot(layDown(path.dat.normal.dir));
        path.dat.normal.pos = plateOrigTV.pos;
    }

    path.tv = plateOrigTV;
}
