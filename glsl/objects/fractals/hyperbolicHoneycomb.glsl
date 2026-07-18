
//-------------------------------------------------
// HYPERBOLIC HONEYCOMB  (the {4,4,5} Coxeter honeycomb)
//
// a regular honeycomb of hyperbolic 3-space H^3, drawn in the UPPER HALF-SPACE
// MODEL: points live in the Euclidean half-space z > 0, the plane z = 0 is the
// ideal boundary (sphere at infinity). we render it with ordinary straight
// Euclidean sightlines -- this is a *model* view, not intrinsic geodesic-ray
// rendering, which is exactly why it drops into our Euclidean raymarcher.
//
// the trick (ported from the Shadertoy): mapScene computes HYPERBOLIC distances
// to the honeycomb's edges / vertex / face, then converts each to a EUCLIDEAN
// distance estimate via hToEuclid (ds_euc = z * ds_hyp). the result is a valid
// Euclidean DE our sphere-tracer can march. all the hyperbolic geometry is
// sealed inside the distance function; the surrounding renderer (AO, fog,
// shadows, lighting, gamma) is discarded -- our path tracer supplies that.
//
// multi-material: mapScene tags each hit with a material id (4 edge segments,
// vertex, face, floor); a custom setData re-evaluates it at the hit point and
// picks the palette color -- the same object-local route as the Kleinian's
// orbit trap. see [[shadertoy-integration]].
//-------------------------------------------------


// --- chamber geometry (direct affine realization of the {4,4,5} chamber) ---
const float HC_INV_PHI       = 0.6180339887498948482;
const float HC_INV_SQRT2     = 0.7071067811865475;
const float HC_MIRROR_R      = 2.0 * HC_INV_PHI;      // mirror-sphere radius
const vec3  HC_MIRROR_C      = vec3(0.0, 1.0, 0.0);   // mirror-sphere center

const vec3  HC_VERTEX_0      = vec3(0.0, 1.0, 2.0);
const vec3  HC_FACE_BD_C     = vec3(1.0, 0.0, 0.0);
const float HC_FACE_BD_R     = 2.4494897427831780982; // sqrt(6)

const vec2  HC_EDGE_A_OTHER  = vec2( 2.0, 1.0);
const vec2  HC_EDGE_A_TARGET = vec2(-2.0, 1.0);
const vec2  HC_EDGE_B_OTHER  = vec2(-1.4142135623730951, 1.0 - 1.4142135623730951);
const vec2  HC_EDGE_B_TARGET = vec2( 1.4142135623730951, 1.0 + 1.4142135623730951);
const vec2  HC_EDGE_C_TARGET = vec2(0.0, 1.0);
const vec2  HC_EDGE_D_OTHER  = vec2(0.0,  2.2360679774997898);
const vec2  HC_EDGE_D_TARGET = vec2(0.0, -2.2360679774997898);

// --- feature sizes (edge/vertex/face thickness, floor height) ---
const float HC_VERTEX_SIZE   = 0.085;
const float HC_EDGE_SIZE     = 0.04254;
const float HC_FACE_THICK    = 0.028;
const float HC_FLOOR_Z       = 1.0e-3;
const float HC_FLOOR_LINE    = 2.22972;

// DEs here are honest distances; a mild fudge keeps the marcher off the thin
// edge tubes. tune by eye (the Shadertoy marched with 1.0 + refine steps).
const float HC_FUDGE         = 0.9;

// --- region ids (returned by region(); the scene maps them to colors) ---
const int HC_NONE   = -1;
const int HC_SEG_A  = 0;
const int HC_SEG_B  = 1;
const int HC_SEG_C  = 2;
const int HC_SEG_D  = 3;
const int HC_VERTEX = 4;
const int HC_FACE   = 5;
const int HC_FLOOR  = 6;

//COLORING lives in the scene: the object exposes region() and the floor grid
//pattern floorTint() below; the scene recolors in a setData followup. see
//[[shadertoy-integration]].

struct HcMap{ float d; int mat; };


//the data of a honeycomb: frame, material (supplies roughness/specular/etc; the
//per-cell diffuse color comes from the palette), and a fold-depth knob.
//foldIterations trades how deep toward the ideal boundary you see for speed
//(~40 snappy preview ... ~350 to match the original). set in buildObjects.
struct HyperbolicHoneycomb{
    Frame frame;
    Material mat;
    int foldIterations;
};


// -----------------------------------------------------------------------------
// hyperbolic geometry helpers (upper half-space model)
// -----------------------------------------------------------------------------

float hc_asinh(float x){
    float ax = abs(x);
    return sign(x) * log(ax + sqrt(ax*ax + 1.0));
}

float hc_acosh(float x){
    x = max(x, 1.0);
    return log(x + sqrt(max(x*x - 1.0, 0.0)));
}

//hyperbolic distance between two points of the half-space model
float hc_pointDist(vec3 a, vec3 b){
    float za = max(a.z, 1e-8);
    float zb = max(b.z, 1e-8);
    float ch = 1.0 + dot(a-b, a-b) / (2.0*za*zb);
    return hc_acosh(ch);
}

//hyperbolic distance from p to the geodesic hemisphere of center c, radius r
float hc_spherePlaneDist(vec3 p, vec3 c, float r){
    vec3 q = p - c;
    return abs(hc_asinh((dot(q,q) - r*r) / (2.0*r*max(p.z, 1e-8))));
}

//inversion in the unit circle centered at a boundary point c
vec3 hc_boundaryInvert(vec3 p, vec2 c){
    vec3 q = p - vec3(c, 0.0);
    return q / max(dot(q,q), 1e-20);
}

//carry a geodesic (endpoints a,b on the boundary) to the vertical axis
vec3 hc_geodesicToVertical(vec3 p, vec2 a, vec2 b){
    vec3 q = hc_boundaryInvert(p, b);
    vec2 ab = a - b;
    q.xy -= ab / max(dot(ab,ab), 1e-20);
    return q;
}

//hyperbolic distance to a geodesic edge (a finite segment, capped at VERTEX_0)
float hc_rayDistFinite(vec3 p, vec2 otherEnd, vec2 targetEnd){
    vec3 q  = hc_geodesicToVertical(p, otherEnd, targetEnd);
    vec3 q0 = hc_geodesicToVertical(HC_VERTEX_0, otherEnd, targetEnd);
    float dLine = hc_asinh(length(q.xy) / max(q.z, 1e-8));
    return (length(q) >= q0.z) ? dLine : hc_pointDist(p, HC_VERTEX_0);
}

//same, for the edge that runs straight down to the boundary
float hc_rayDistVertical(vec3 p, vec2 targetEnd){
    vec3 q  = hc_boundaryInvert(p, targetEnd);
    vec3 q0 = hc_boundaryInvert(HC_VERTEX_0, targetEnd);
    float dLine = hc_asinh(length(q.xy) / max(q.z, 1e-8));
    return (length(q) >= q0.z) ? dLine : hc_pointDist(p, HC_VERTEX_0);
}

//convert a hyperbolic distance to a conservative Euclidean distance estimate
float hc_toEuclid(float dh, float z){
    return (dh <= 0.0) ? dh : max(0.0, z * (1.0 - exp(-dh)));
}


// -----------------------------------------------------------------------------
// folding the point back into the fundamental chamber
// -----------------------------------------------------------------------------

float hc_triWave(float x, inout int parity){
    float cell = floor(x);
    float f = x - cell;
    if(mod(cell, 2.0) > 0.5){ f = 1.0 - f; parity = 1 - parity; }
    return f;
}

//the affine (4,4) triangle-group fold in the xy plane
void hc_foldAffine(inout vec2 p, inout int parity){
    p.x = hc_triWave(p.x, parity);
    p.y = hc_triWave(p.y, parity);
    if(p.x + p.y > 1.0){ p = vec2(1.0 - p.y, 1.0 - p.x); parity = 1 - parity; }
}

//fold a 3D point: alternate the affine fold with inversion in the mirror sphere
bool hc_foldPoint(inout vec3 p, out int parity, int maxIter){
    parity = 0;
    float r2 = HC_MIRROR_R * HC_MIRROR_R;
    for(int i=0;i<maxIter;i++){
        hc_foldAffine(p.xy, parity);
        vec3 q = p - HC_MIRROR_C;
        float d2 = dot(q,q);
        if(d2 >= r2*(1.0 - 2e-7)) return true;
        p = HC_MIRROR_C + q * (r2 / max(d2, 1e-20));
        parity = 1 - parity;
    }
    return false;
}

//fold a boundary point (2D), for the floor pattern
bool hc_foldBoundary(inout vec2 p, out int parity, int maxIter){
    parity = 0;
    float r2 = HC_MIRROR_R * HC_MIRROR_R;
    for(int i=0;i<maxIter;i++){
        hc_foldAffine(p, parity);
        vec2 q = p - HC_MIRROR_C.xy;
        float d2 = dot(q,q);
        if(d2 >= r2*(1.0 - 2e-7)) return true;
        p = HC_MIRROR_C.xy + q * (r2 / max(d2, 1e-20));
        parity = 1 - parity;
    }
    return false;
}

float hc_boundaryMirrorDist(vec2 p){
    float dA = abs(p.x);
    float dD = abs(p.y);
    float dB = abs((p.x + p.y - 1.0) * HC_INV_SQRT2);
    float dC = abs(length(p - HC_MIRROR_C.xy) - HC_MIRROR_R);
    return min(min(dA, dD), min(dB, dC));
}

//chart conversions: render-space half-space <-> affine chamber
vec3 hc_toAffine(vec3 p){
    float r2 = max(dot(p,p), 1e-20);
    vec3 q = p / r2;
    return vec3(HC_MIRROR_R*q.x, 1.0 - HC_MIRROR_R*q.y, HC_MIRROR_R*q.z);
}

vec2 hc_boundaryToAffine(vec2 p){
    float r2 = max(dot(p,p), 1e-20);
    return vec2(HC_MIRROR_R*p.x/r2, 1.0 - HC_MIRROR_R*p.y/r2);
}


// -----------------------------------------------------------------------------
// the scene distance estimator (Euclidean DE + material id)
// -----------------------------------------------------------------------------

HcMap hc_mapScene(vec3 worldP, int foldIter){
    HcMap res;
    res.d = 1e6;
    res.mat = HC_NONE;

    if(worldP.z <= 0.0) return res;

    //the ideal-boundary floor
    res.d = worldP.z - HC_FLOOR_Z;
    res.mat = HC_FLOOR;

    //fold into the fundamental chamber
    vec3 p = hc_toAffine(worldP);
    int parity;
    if(!hc_foldPoint(p, parity, foldIter)) return res;

    //hyperbolic distances to the chamber's 4 edges, vertex, and face
    float hA = hc_rayDistFinite(p, HC_EDGE_A_OTHER, HC_EDGE_A_TARGET) - HC_EDGE_SIZE;
    float hB = hc_rayDistFinite(p, HC_EDGE_B_OTHER, HC_EDGE_B_TARGET) - HC_EDGE_SIZE;
    float hC = hc_rayDistVertical(p, HC_EDGE_C_TARGET)                - HC_EDGE_SIZE;
    float hD = hc_rayDistFinite(p, HC_EDGE_D_OTHER, HC_EDGE_D_TARGET) - HC_EDGE_SIZE;
    float hV = hc_pointDist(p, HC_VERTEX_0)                           - HC_VERTEX_SIZE;

    float hF = 1e6;
    float gateB = p.x*p.x + 10.0*p.x + p.y*p.y + p.z*p.z - 5.0;
    float gateD = p.x*p.x +  4.0*p.x + p.y*p.y - 6.0*p.y + p.z*p.z + 1.0;
    if(gateB >= 0.0 && gateD >= 0.0){
        hF = hc_spherePlaneDist(p, HC_FACE_BD_C, HC_FACE_BD_R) - HC_FACE_THICK;
    }

    //convert each to a Euclidean distance and keep the nearest
    float z = worldP.z;
    float dA = hc_toEuclid(hA, z);
    float dB = hc_toEuclid(hB, z);
    float dC = hc_toEuclid(hC, z);
    float dD = hc_toEuclid(hD, z);
    float dV = hc_toEuclid(hV, z);
    float dF = hc_toEuclid(hF, z);

    if(dA < res.d){ res.d = dA; res.mat = HC_SEG_A; }
    if(dB < res.d){ res.d = dB; res.mat = HC_SEG_B; }
    if(dC < res.d){ res.d = dC; res.mat = HC_SEG_C; }
    if(dD < res.d){ res.d = dD; res.mat = HC_SEG_D; }
    if(dV < res.d){ res.d = dV; res.mat = HC_VERTEX; }
    if(dF < res.d){ res.d = dF; res.mat = HC_FACE; }
    return res;
}


// -----------------------------------------------------------------------------
// shading probes (consumed by the scene's recolor followup)
// -----------------------------------------------------------------------------

//which region is this local point nearest? (HC_SEG_A .. HC_FLOOR, or HC_NONE)
int region( vec3 p, HyperbolicHoneycomb obj ){
    return hc_mapScene(p, obj.foldIterations).mat;
}

//the floor grid pattern, tinted by scene-supplied colors: two checker tints and
//a line color. (fixed-width lines; the original's fwidth AA does not survive
//path-traced sampling, so we use a fixed soft edge.) call from the scene when
//region()==HC_FLOOR.
vec3 floorTint( vec2 worldXY, HyperbolicHoneycomb obj, vec3 c1, vec3 c2, vec3 cLine ){
    vec2 p = hc_boundaryToAffine(worldXY);
    int parity;
    if(!hc_foldBoundary(p, parity, obj.foldIterations)) return cLine;
    vec3 col = (parity == 0) ? c1 : c2;
    float edge  = hc_boundaryMirrorDist(p);
    float width = 0.0015 * HC_FLOOR_LINE;
    float aa    = 0.5 * width;
    return mix(col, cLine, 1.0 - smoothstep(width - aa, width + aa, edge));
}


// -----------------------------------------------------------------------------
// object interface
// -----------------------------------------------------------------------------

//the local-frame sdf (used for marching, at/inside, and normals)
float sdf( vec3 p, HyperbolicHoneycomb obj ){
    return HC_FUDGE * hc_mapScene(p, obj.foldIterations).d;
}

OBJECT_INIT(HyperbolicHoneycomb)
OBJECT_LOCATORS(HyperbolicHoneycomb)


//hand-written normalVec (standard finite difference; kept explicit so the
//epsilon is easy to tune for the honeycomb's thin edges)
Vector normalVec( Vector tv, HyperbolicHoneycomb obj ){
    vec3 q = toLocal(obj.frame, tv.pos);
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    vec3 dir = e.xyy*sdf( q + e.xyy*ep, obj )
             + e.yyx*sdf( q + e.yyx*ep, obj )
             + e.yxy*sdf( q + e.yxy*ep, obj )
             + e.xxx*sdf( q + e.xxx*ep, obj );
    return Vector( tv.pos, dirToWorld(obj.frame, normalize(dir)) );
}


//standard flat-material setData (uses obj.mat); the scene overrides the color
OBJECT_SETDATA(HyperbolicHoneycomb)
