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
    vec3 d = abs(pos) - vec3(PLATE_RADIUS, 0.15, PLATE_RADIUS);
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
// SECTION 7b: CHAIN
// ============================================

struct Chain {
    vec3 center;     // xz position, y is ignored (chain runs vertically)
    float yBottom;   // bottom of chain
    float yTop;      // top of chain
    float R;         // major radius (link size)
    float r;         // minor radius (wire thickness)
    float le;        // link elongation
    Material mat;
};

// Single chain link: elongated torus (stadium shape)
// le = elongation, r1 = major radius, r2 = minor radius
float sdLink(vec3 p, float le, float r1, float r2) {
    vec3 q = vec3(p.x, max(abs(p.y) - le, 0.0), p.z);
    return length(vec2(length(q.xy) - r1, q.z)) - r2;
}

float chainLinkDist(vec3 pos, float R, float r, float le, float isOdd) {
    // Swap x and z for alternating links
    pos.xz = mix(pos.xz, pos.zx, isOdd);
    return sdLink(pos, le, R, r);
}

float distR3(vec3 p, Chain ch) {
    vec3 pos = p - vec3(ch.center.x, 0, ch.center.z);
    // Clip to chain range
    if (pos.y > ch.yTop + ch.R + ch.r || pos.y < ch.yBottom - ch.R - ch.r) {
        return 1.0; // far away
    }

    float spacing = ch.R + ch.le;
    float cell = round(pos.y / spacing);
    float localY = pos.y - cell * spacing;
    float odd = step(0.5, mod(abs(cell), 2.0));

    // Current cell
    float d1 = chainLinkDist(vec3(pos.x, localY, pos.z), ch.R, ch.r, ch.le, odd);
    // Neighbor cell (check the closer one)
    float neighborDir = sign(localY + 0.001);
    float d2 = chainLinkDist(vec3(pos.x, localY - neighborDir * spacing, pos.z), ch.R, ch.r, ch.le, 1.0 - odd);

    return min(d1, d2);
}

float distR3(Vector tv, Chain ch) { return distR3(tv.pos, ch); }
float sdf(Vector tv, Chain ch) { return distR3(tv.pos, ch); }

bool at(Vector tv, Chain ch) {
    return (abs(distR3(tv.pos, ch)) - AT_THRESH) < 0.;
}

bool inside(Vector tv, Chain ch) {
    return distR3(tv.pos, ch) < 0.;
}

Vector normalVec(Vector tv, Chain ch) {
    vec3 pos = tv.pos;
    const float ep = 0.0001;
    vec2 e = vec2(1.0, -1.0) * 0.5773;
    float vxyy = distR3(pos + e.xyy * ep, ch);
    float vyyx = distR3(pos + e.yyx * ep, ch);
    float vyxy = distR3(pos + e.yxy * ep, ch);
    float vxxx = distR3(pos + e.xxx * ep, ch);
    vec3 dir = e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;
    return Vector(tv.pos, normalize(dir));
}

void setData(inout Path path, Chain ch) {
    if (at(path.tv, ch)) {
        Vector normal = normalVec(path.tv, ch);
        bool side = inside(path.tv, ch);
        setObjectInAir(path.dat, side, normal, ch.mat);
    }
}


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

// Chain
Chain chain;

// Plate legs
Cone plateLeg1;
Cone plateLeg2;
Cone plateLeg3;
Cone plateLeg4;


// ============================================
// SECTION 9: BUILD
// ============================================

// Vertical stretch factor for the cubic surface
const float STRETCH_H = 1.4;

// Layout: stretched surface above plate on legs, portrait framing
const float FLOOR_Y = -4.0;
const float LEG_HEIGHT = 0.6;
const float LEG_RADIUS = 0.08;
const vec3 SURFACE_POS = vec3(0, 1.5, 0);
const vec3 PLATE_POS   = vec3(0, FLOOR_Y + LEG_HEIGHT + 0.05, 0);


void buildObjects() {

    // XZ rotation from extra slider (0→2π)
    float angle = extra * 6.2832;
    float ca = cos(angle), sa = sin(angle);
    xzRot = mat2(ca, sa, -sa, ca);
    xzRotInv = mat2(ca, -sa, sa, ca);

    // === SURFACE GROUP (left) ===

    surface.center = SURFACE_POS;
    surface.scale = 1.0;
    surface.thickness = vec2(0.01, 0.0);
    surface.smoothing = 0.05;
    surface.mat =makeGlass(2.*vec3(0.3, 0.05, 0.2), 1.5, 0.95);

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

    // === CHAIN (hanging surface from above) ===
    chain.center = SURFACE_POS + vec3(0, 0, 0.3);
    chain.yBottom = SURFACE_POS.y + 2.0 * STRETCH_H - chain.R * 2.0;  // overlap into top of ellipsoid
    chain.yTop = 15.0;  // off screen above
    chain.R = 0.1;
    chain.r = 0.025;
    chain.le = 0.06;
    chain.mat = makeMetal(vec3(0.04, 0.04, 0.05), 0.3, 0.5);

    // === PLATE GROUP (right, sitting on floor) ===

    plate.center = PLATE_POS;
    plate.sides = vec3(PLATE_RADIUS, 0.05, PLATE_RADIUS);
    plate.rounded = 0.02;
    plate.mat = makeGlass(vec3(0.3, 0.05, 0.2), 1.5, 0.95);

    checkers.center = PLATE_POS;
    checkers.cylRadius = 0.06;
    checkers.cylHeight = 0.02;
    checkers.rounding = 0.008;
    checkers.yOffset = 0.07;
    checkers.mat = makeMetal(vec3(0.75, 0.35, 0.35), 0.6, 0.2);

    plateLines.center = PLATE_POS + vec3(0, 0.05, 0);
    plateLines.radius = 0.02;
    plateLines.mat = makeMetal(vec3(0.7, 0.7, 0.75), 0.6, 0.2);

    planarConics.center = PLATE_POS + vec3(0, 0.05, 0);
    planarConics.radius = 0.02;
    planarConics.mat = makeMetal(vec3(0.85, 0.6, 0.15), 0.6, 0.2);

    // === PLATE LEGS (glass cylinders at corners) ===
    float legInset = PLATE_RADIUS - 0.15;
    float legMidY = FLOOR_Y + LEG_HEIGHT * 0.5;
    Material legMat = makeGlass(vec3(0.1, 0.05, 0.1), 1.5, 0.98);
    vec3 legXZ = vec3(PLATE_POS.x, legMidY, PLATE_POS.z);

    plateLeg1.center = legXZ + vec3(-legInset, 0, -legInset);
    plateLeg1.height = LEG_HEIGHT * 0.5;
    plateLeg1.base = LEG_RADIUS;
    plateLeg1.flare = 1.0;
    plateLeg1.mat = legMat;

    plateLeg2.center = legXZ + vec3(legInset, 0, -legInset);
    plateLeg2.height = LEG_HEIGHT * 0.5;
    plateLeg2.base = LEG_RADIUS;
    plateLeg2.flare = 1.0;
    plateLeg2.mat = legMat;

    plateLeg3.center = legXZ + vec3(-legInset, 0, legInset);
    plateLeg3.height = LEG_HEIGHT * 0.5;
    plateLeg3.base = LEG_RADIUS;
    plateLeg3.flare = 1.0;
    plateLeg3.mat = legMat;

    plateLeg4.center = legXZ + vec3(legInset, 0, legInset);
    plateLeg4.height = LEG_HEIGHT * 0.5;
    plateLeg4.base = LEG_RADIUS;
    plateLeg4.flare = 1.0;
    plateLeg4.mat = legMat;
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

    // --- Surface group (sphere bbox, with squeeze for vertical stretch) ---
    vec3 surfPos = rotXZ(tv.pos - surface.center);
    surfPos.y /= STRETCH_H;  // squeeze y for vertical stretch
    _cachedBBox = sceneBBox(surfPos);   // sphere in squeezed space = ellipsoid
    _cachedPos = surfPos;

    if (_cachedBBox <= 0.0) {
        vec3 scaled = surface.scale * surfPos;
        _cachedVal = cubicF(scaled);
        _cachedGrad = cubicGrad(scaled);

        float sd;
        sd = sdf_cached(surface); dist = min(dist, sd / STRETCH_H);
        sd = sdf_cached(pairLines); dist = min(dist, sd / STRETCH_H);
        sd = sdf_cached(conicLines); dist = min(dist, sd / STRETCH_H);
        sd = sdf_cached(exceptionalLines); dist = min(dist, sd / STRETCH_H);
        sd = sdf_cached(ring); dist = min(dist, sd / STRETCH_H);
    } else {
        dist = min(dist, _cachedBBox / STRETCH_H);
    }

    // --- Chain ---
    dist = min(dist, sdf(tv, chain));

    // --- Plate legs ---
    dist = min(dist, sdf(tv, plateLeg1));
    dist = min(dist, sdf(tv, plateLeg2));
    dist = min(dist, sdf(tv, plateLeg3));
    dist = min(dist, sdf(tv, plateLeg4));

    // --- Plate group (3D bbox early exit, skip if already close to surface) ---
    if (dist > 0.001) {
        vec3 plateLocal = tv.pos - PLATE_POS;
        float plateGroupDist = plateGroupBBox(plateLocal);
        if (plateGroupDist <= 0.0) {
            dist = min(dist, sdf(tv, plate));
            dist = min(dist, sdf(tv, checkers));
            dist = min(dist, sdf(tv, plateLines));
            dist = min(dist, sdf(tv, planarConics));
        } else {
            dist = min(dist, plateGroupDist);
        }
    }

    return dist;
}

bool inside_Object(Vector tv) {
    vec3 squeezed = rotXZ(tv.pos - SURFACE_POS);
    squeezed.y /= STRETCH_H;
    Vector rotTV = Vector(squeezed + SURFACE_POS, tv.dir);
    return inside(rotTV, surface) || inside(tv, plate)
        || inside(tv, plateLeg1) || inside(tv, plateLeg2)
        || inside(tv, plateLeg3) || inside(tv, plateLeg4);
}

void setData_Objects(inout Path path) {
    // Rotate + squeeze query point into surface-local frame
    Vector origTV = path.tv;
    vec3 local = rotXZ(path.tv.pos - SURFACE_POS);
    local.y /= STRETCH_H;
    path.tv.pos = local + SURFACE_POS;

    // Surface group (evaluated in rotated + squeezed frame)
    setData(path, surface);
    setData(path, pairLines);
    setData(path, conicLines);
    setData(path, exceptionalLines);
    setData(path, ring);

    // Un-squeeze normal (inverse transpose), then un-rotate
    path.dat.normal.dir.y *= STRETCH_H;
    path.dat.normal.dir = normalize(path.dat.normal.dir);
    path.dat.normal.dir = unrotXZ(path.dat.normal.dir);
    path.dat.normal.pos = origTV.pos;

    // Restore original tv for chain, legs, plate
    path.tv = origTV;

    // Chain (no rotation)
    setData(path, chain);

    // Legs (no rotation)
    setData(path, plateLeg1);
    setData(path, plateLeg2);
    setData(path, plateLeg3);
    setData(path, plateLeg4);

    // Plate group (no rotation)
    setData(path, plate);
    setData(path, checkers);
    setData(path, plateLines);
    setData(path, planarConics);
}
