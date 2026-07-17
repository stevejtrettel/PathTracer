// -----------------------------------------------------------------------------
// 445-0011 honeycomb in the upper-half-space view
// -----------------------------------------------------------------------------
#define PI 3.14159265358979323846264

const float CFG_FOV = 0.71;

const vec3 CFG_EYE = vec3(0.859194, -0.390543, 0.5);

const vec3 CFG_TARGET = vec3(0.000000, -2.456415, 0.2);

const vec3  CFG_UP               = vec3(0.0, 0.0, 1.0);

const vec4  CFG_SPOT_LIGHT       = vec4(0.949020, 0.882353, 0.772549, 10.0);
const vec3  CFG_LIGHT_POS = vec3(0.040000, -2.240000, 0.920000);
const float CFG_GAMMA            = 2.2;
const float CFG_GAUSSIAN_WEIGHT  = 1.0;
const float CFG_AA_SCALE         = 2.0;

const float CFG_DETAIL_LOG10     = -4.7124;
const int   CFG_REFINE_STEPS     = 16;
const float CFG_FUDGE            = 1.0;
const int   CFG_MAX_RAY_STEPS    = 500;
const float CFG_MAX_DISTANCE     = 50.0;
const float CFG_DITHER           = 0.55852;
const float CFG_NORMAL_BACKSTEP  = 10.075;

const float CFG_DETAIL_AO_LOG10  = -1.28513;
const int   CFG_MAX_ITER_AO      = 17;
const float CFG_FUDGE_AO         = 1.0;
const float CFG_AO_AMBIENT       = 0.7;
const float CFG_AO_CAMLIGHT      = 0.0;
const float CFG_AO_POINTLIGHT    = 0.0;
const float CFG_CONE_APERTURE_AO = 0.85;
const float CFG_AO_CORRECT       = 0.0;

const float CFG_SPECULAR         = 0.21538;
const float CFG_SPECULAR_EXP     = 147.825;
const vec4  CFG_CAM_LIGHT        = vec4(0.878431, 0.921569, 0.956863, 0.0);
const vec4  CFG_AMBIENT_LIGHT    = vec4(1.0, 1.0, 1.0, 0.59682);
const vec3  CFG_REFLECTION       = vec3(0.294118, 0.294118, 0.415686);
const int   CFG_REFLECTIONS      = 1;

const float CFG_LIGHT_SIZE       = 0.0;
const float CFG_LIGHT_FALLOFF    = 0.4138;
const float CFG_LIGHT_GLOW_RAD   = 0.0;
const float CFG_LIGHT_GLOW_EXP   = 1.0;
const bool  CFG_SPOT_GLOW        = true;
const float CFG_HARD_SHADOW      = 1.0;
const float CFG_SHADOW_SOFT      = 1.081;
const float CFG_SHADOW_BLUR      = 0.075;
const bool  CFG_PERF_SHADOW      = false;
const bool  CFG_SSS              = false;
const float CFG_SSS1             = 0.1;
const float CFG_SSS2             = 0.5;

const vec3  CFG_BACKGROUND       = vec3(0.172549, 0.235294, 0.294118);

const float CFG_HF_FALLOFF       = 2.57579;
const float CFG_HF_CONST         = 0.02138;
const float CFG_HF_INTENSITY     = 0.0467;
const vec3  CFG_HF_DIR           = vec3(-0.03402, -0.06122, 1.0);
const float CFG_HF_OFFSET        = -10.0;
const vec4  CFG_HF_COLOR         = vec4(0.6, 0.8, 1.0, 0.10257);
const float CFG_HF_SCATTER       = 1.1111;
const vec3  CFG_HF_ANISOTROPY    = vec3(0.168627, 0.192157, 0.137255);
const int   CFG_HF_FOG_ITER      = 3;
const bool  CFG_HF_CAST_SHADOW   = true;

const vec3 COL_SEG_A      = vec3(0.55, 0.24, 0.13);
const vec3 COL_SEG_B      = vec3(0.08, 0.38, 0.40);
const vec3 COL_SEG_C      = vec3(0.06, 0.18, 0.20);
const vec3 COL_SEG_D      = vec3(0.46, 0.32, 0.18);

const vec3 COL_FACE_BD    = vec3(0.4, 0.4, 0.65);
const vec3 COL_VERTEX     = vec3(0.76, 0.66, 0.50);

const vec3 COL_FLOOR_1    = vec3(0.34, 0.13, 0.09);
const vec3 COL_FLOOR_2    = vec3(0.06, 0.25, 0.28);
const vec3 COL_FLOOR_LINE = vec3(0.72, 0.55, 0.30);

const float CFG_VERTEX_SIZE      = 0.085;
const float CFG_EDGE_SIZE        = 0.04254;
const float CFG_FACE_THICKNESS   = 0.028;
const float CFG_FLOOR_LINE_RAW   = 2.22972;
const int   CFG_FOLD_ITERATIONS  = 353;
const float CFG_FLOOR_Z          = 1.0e-3;

const float MIN_EPS              = 1.1920928955078125e-7;
const float INV_SQRT2            = 0.7071067811865475;

// -----------------------------------------------------------------------------
// Direct affine realization of the (4,4,5) Coxeter chamber in upper half space
// -----------------------------------------------------------------------------

const float INV_PHI        = 0.6180339887498948482;
const float MIRROR_SPHERE_R = 2.0 * INV_PHI;
const vec3  MIRROR_SPHERE_C = vec3(0.0, 1.0, 0.0);

const vec3  VERTEX_0        = vec3(0.0, 1.0, 2.0);
const vec3  FACE_BD_C       = vec3(1.0, 0.0, 0.0);
const float FACE_BD_R       = 2.4494897427831780982; // sqrt(6)

const vec2 EDGE_A_OTHER  = vec2( 2.0, 1.0);
const vec2 EDGE_A_TARGET = vec2(-2.0, 1.0);
const vec2 EDGE_B_OTHER  = vec2(-1.4142135623730951, 1.0 - 1.4142135623730951);
const vec2 EDGE_B_TARGET = vec2( 1.4142135623730951, 1.0 + 1.4142135623730951);
const vec2 EDGE_C_TARGET = vec2(0.0, 1.0);
const vec2 EDGE_D_OTHER  = vec2(0.0,  2.2360679774997898);
const vec2 EDGE_D_TARGET = vec2(0.0, -2.2360679774997898);

const int MAT_NONE   = -1;
const int MAT_SEG_A  = 0;
const int MAT_SEG_B  = 1;
const int MAT_SEG_C  = 2;
const int MAT_SEG_D  = 3;
const int MAT_VERTEX = 4;
const int MAT_FACEBD = 5;
const int MAT_FLOOR  = 6;

struct MapResult {
    float d;
    int mat;
};

struct SRay {
    vec3 Origin;
    vec3 Direction;
    float Pos;
    float fudge;
};

float saturate(float x) { return clamp(x, 0.0, 1.0); }
vec3 saturate(vec3 x)   { return clamp(x, vec3(0.0), vec3(1.0)); }

// -----------------------------------------------------------------------------
// Random helpers
// -----------------------------------------------------------------------------

float rnd(float v) {
    return fract(sin(v * 78.233) * 43758.5453);
}

float rnd(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float rnd(vec3 p) {
    return fract(sin(dot(p * 0.123, vec3(12.9898, 78.233, 112.166))) * 43758.5453);
}

vec2 rnd2(vec2 p) {
    return vec2(
        fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453),
        fract(cos(dot(p, vec2(4.898, 7.23))) * 23421.631)
    );
}

vec2 uniformDisc(vec2 co) {
    vec2 r = rnd2(co);
    return sqrt(r.y) * vec2(cos(r.x * 6.28318530718), sin(r.x * 6.28318530718));
}

// -----------------------------------------------------------------------------
// Hyperbolic geometry helpers
// -----------------------------------------------------------------------------

float asinhSafe(float x) {
    float ax = abs(x);
    return sign(x) * log(ax + sqrt(ax * ax + 1.0));
}

float acoshSafe(float x) {
    x = max(x, 1.0);
    return log(x + sqrt(max(x * x - 1.0, 0.0)));
}

float hPointDistance(vec3 a, vec3 b) {
    float za = max(a.z, 1e-8);
    float zb = max(b.z, 1e-8);
    float ch = 1.0 + dot(a - b, a - b) / (2.0 * za * zb);
    return acoshSafe(ch);
}

float hSpherePlaneDistance(vec3 p, vec3 c, float r) {
    vec3 q = p - c;
    return abs(asinhSafe((dot(q, q) - r * r) / (2.0 * r * max(p.z, 1e-8))));
}

vec3 boundaryInvert(vec3 p, vec2 c) {
    vec3 q = p - vec3(c, 0.0);
    return q / max(dot(q, q), 1e-20);
}

vec3 geodesicToVertical(vec3 p, vec2 a, vec2 b) {
    vec3 q = boundaryInvert(p, b);
    vec2 ab = a - b;
    q.xy -= ab / max(dot(ab, ab), 1e-20);
    return q;
}

float hRayDistanceFinite(vec3 p, vec2 otherEnd, vec2 targetEnd) {
    vec3 q  = geodesicToVertical(p, otherEnd, targetEnd);
    vec3 q0 = geodesicToVertical(VERTEX_0, otherEnd, targetEnd);
    float dLine = asinhSafe(length(q.xy) / max(q.z, 1e-8));
    return (length(q) >= q0.z) ? dLine : hPointDistance(p, VERTEX_0);
}

float hRayDistanceVerticalDown(vec3 p, vec2 targetEnd) {
    vec3 q  = boundaryInvert(p, targetEnd);
    vec3 q0 = boundaryInvert(VERTEX_0, targetEnd);
    float dLine = asinhSafe(length(q.xy) / max(q.z, 1e-8));
    return (length(q) >= q0.z) ? dLine : hPointDistance(p, VERTEX_0);
}

float hToEuclid(float dh, float z) {
    return (dh <= 0.0) ? dh : max(0.0, z * (1.0 - exp(-dh)));
}

// -----------------------------------------------------------------------------
// Folding
// -----------------------------------------------------------------------------

float triangleWave01(float x, inout int parity) {
    float cell = floor(x);
    float f = x - cell;
    if (mod(cell, 2.0) > 0.5) {
        f = 1.0 - f;
        parity = 1 - parity;
    }
    return f;
}

void foldAffine44(inout vec2 p, inout int parity) {
    p.x = triangleWave01(p.x, parity);
    p.y = triangleWave01(p.y, parity);
    if (p.x + p.y > 1.0) {
        p = vec2(1.0 - p.y, 1.0 - p.x);
        parity = 1 - parity;
    }
}

bool foldPoint(inout vec3 p, out int parity) {
    parity = 0;
    float r2 = MIRROR_SPHERE_R * MIRROR_SPHERE_R;
    for (int i = 0; i < CFG_FOLD_ITERATIONS; ++i) {
        foldAffine44(p.xy, parity);
        vec3 q = p - MIRROR_SPHERE_C;
        float d2 = dot(q, q);
        if (d2 >= r2 * (1.0 - 2e-7)) return true;
        p = MIRROR_SPHERE_C + q * (r2 / max(d2, 1e-20));
        parity = 1 - parity;
    }
    return false;
}

bool foldBoundary(inout vec2 p, out int parity) {
    parity = 0;
    float r2 = MIRROR_SPHERE_R * MIRROR_SPHERE_R;
    for (int i = 0; i < CFG_FOLD_ITERATIONS; ++i) {
        foldAffine44(p, parity);
        vec2 q = p - MIRROR_SPHERE_C.xy;
        float d2 = dot(q, q);
        if (d2 >= r2 * (1.0 - 2e-7)) return true;
        p = MIRROR_SPHERE_C.xy + q * (r2 / max(d2, 1e-20));
        parity = 1 - parity;
    }
    return false;
}

float boundaryMirrorDistance(vec2 p) {
    float dA = abs(p.x);
    float dD = abs(p.y);
    float dB = abs((p.x + p.y - 1.0) * INV_SQRT2);
    float dC = abs(length(p - MIRROR_SPHERE_C.xy) - MIRROR_SPHERE_R);
    return min(min(dA, dD), min(dB, dC));
}

// -----------------------------------------------------------------------------
// Chart conversion
// -----------------------------------------------------------------------------

vec3 presetPointToAffine(vec3 p) {
    float r2 = max(dot(p, p), 1e-20);
    vec3 q = p / r2;
    return vec3(MIRROR_SPHERE_R * q.x,
                1.0 - MIRROR_SPHERE_R * q.y,
                MIRROR_SPHERE_R * q.z);
}

vec2 presetBoundaryToAffine(vec2 p) {
    float r2 = max(dot(p, p), 1e-20);
    return vec2(MIRROR_SPHERE_R * p.x / r2,
                1.0 - MIRROR_SPHERE_R * p.y / r2);
}

// -----------------------------------------------------------------------------
// Scene DE
// -----------------------------------------------------------------------------

MapResult mapScene(vec3 worldP) {
    MapResult res;
    res.d = 1e6;
    res.mat = MAT_NONE;

    if (worldP.z <= 0.0) return res;

    res.d = worldP.z - CFG_FLOOR_Z;
    res.mat = MAT_FLOOR;

    vec3 p = presetPointToAffine(worldP);
    int parity;
    if (!foldPoint(p, parity)) return res;

    float hA = hRayDistanceFinite(p, EDGE_A_OTHER, EDGE_A_TARGET) - CFG_EDGE_SIZE;
    float hB = hRayDistanceFinite(p, EDGE_B_OTHER, EDGE_B_TARGET) - CFG_EDGE_SIZE;
    float hC = hRayDistanceVerticalDown(p, EDGE_C_TARGET)         - CFG_EDGE_SIZE;
    float hD = hRayDistanceFinite(p, EDGE_D_OTHER, EDGE_D_TARGET) - CFG_EDGE_SIZE;
    float hV = hPointDistance(p, VERTEX_0)                        - CFG_VERTEX_SIZE;

    float hF = 1e6;
    float gateB = p.x * p.x + 10.0 * p.x + p.y * p.y + p.z * p.z - 5.0;
    float gateD = p.x * p.x +  4.0 * p.x + p.y * p.y - 6.0 * p.y + p.z * p.z + 1.0;
    if (gateB >= 0.0 && gateD >= 0.0) {
        hF = hSpherePlaneDistance(p, FACE_BD_C, FACE_BD_R) - CFG_FACE_THICKNESS;
    }

    float z = worldP.z;
    float dA = hToEuclid(hA, z);
    float dB = hToEuclid(hB, z);
    float dC = hToEuclid(hC, z);
    float dD = hToEuclid(hD, z);
    float dV = hToEuclid(hV, z);
    float dF = hToEuclid(hF, z);

    if (dA < res.d) { res.d = dA; res.mat = MAT_SEG_A; }
    if (dB < res.d) { res.d = dB; res.mat = MAT_SEG_B; }
    if (dC < res.d) { res.d = dC; res.mat = MAT_SEG_C; }
    if (dD < res.d) { res.d = dD; res.mat = MAT_SEG_D; }
    if (dV < res.d) { res.d = dV; res.mat = MAT_VERTEX; }
    if (dF < res.d) { res.d = dF; res.mat = MAT_FACEBD; }
    return res;
}

vec3 materialColor(int mat) {
    if (mat == MAT_SEG_A)  return COL_SEG_A;
    if (mat == MAT_SEG_B)  return COL_SEG_B;
    if (mat == MAT_SEG_C)  return COL_SEG_C;
    if (mat == MAT_SEG_D)  return COL_SEG_D;
    if (mat == MAT_VERTEX) return COL_VERTEX;
    if (mat == MAT_FACEBD) return COL_FACE_BD;
    if (mat == MAT_FLOOR)  return COL_FLOOR_1;
    return CFG_BACKGROUND;
}

vec3 floorPattern(vec2 pWorldXY) {
    vec2 p = presetBoundaryToAffine(pWorldXY);
    int parity;
    if (!foldBoundary(p, parity)) return COL_FLOOR_LINE;
    vec3 col = (parity == 0) ? COL_FLOOR_1 : COL_FLOOR_2;
    float edge = boundaryMirrorDistance(p);
    float aa = 0.5 * fwidth(edge);
    float width = 0.0015 * CFG_FLOOR_LINE_RAW;
    return mix(col, COL_FLOOR_LINE, 1.0 - smoothstep(width - aa, width + aa, edge));
}

// -----------------------------------------------------------------------------
// Ray representation (preset-optimized: Aperture == 0, so no lens offset path)
// -----------------------------------------------------------------------------

vec3 SRCurrentPt(SRay ray) {
    return ray.Origin + ray.Direction * ray.Pos;
}

void SRAdvance(inout SRay ray, float dist) {
    ray.Pos += dist * ray.fudge;
}

SRay SRReflect(SRay ray, vec3 normal, float eps) {
    vec3 hit = SRCurrentPt(ray);
    ray.Direction = reflect(ray.Direction, normal);
    ray.Origin = hit + reflect(ray.Origin - hit, normal);
    ray.Pos += eps;
    return ray;
}

// -----------------------------------------------------------------------------
// DE/light/fog helpers
// -----------------------------------------------------------------------------

float DElight(vec3 p) {
    return length(CFG_LIGHT_POS - p) - CFG_LIGHT_SIZE;
}

vec3 calcNormal(vec3 p, float normalDistance) {
    normalDistance = max(normalDistance * 0.5, 1.0e-5);
    vec3 e = vec3(0.0, normalDistance, 0.0);
    vec3 n = vec3(
        mapScene(p + e.yxx).d - mapScene(p - e.yxx).d,
        mapScene(p + e.xyx).d - mapScene(p - e.xyx).d,
        mapScene(p + e.xxy).d - mapScene(p - e.xxy).d
    );
    n = normalize(n);
    return all(equal(n, n)) ? n : vec3(0.0);
}

float exp1(float x) {
    return exp(clamp(x, -80.0, 80.0));
}

vec3 exp1(vec3 x) {
    return exp(clamp(x, vec3(-80.0), vec3(80.0)));
}

vec3 fogAmount3(vec3 p0, vec3 p1) {
    vec3 hfdir = normalize(CFG_HF_DIR);
    vec3 dp = p1 - p0;
    float t = length(dp);
    float A = CFG_HF_FALLOFF * dot(dp, hfdir);
    A = (abs(A) < 1.0e-7) ? 1.0 : (1.0 - exp1(-A)) / A;
    vec3 amount = CFG_HF_COLOR.rgb
                * (CFG_HF_INTENSITY
                * exp1(-CFG_HF_FALLOFF * (dot(p0, hfdir) - CFG_HF_OFFSET))
                * A + CFG_HF_CONST) * t;
    return clamp(exp1(-amount), vec3(0.0), vec3(1.0));
}

vec3 ptLightGlow(float glow) {
    if (!CFG_SPOT_GLOW) return vec3(0.0);
    float glow1 = exp(-pow(CFG_LIGHT_GLOW_RAD + 0.0001, -2.0) * pow(glow, CFG_LIGHT_GLOW_EXP));
    float glow2 = exp(-20.0 * glow);
    return CFG_SPOT_LIGHT.rgb * (glow2 * CFG_SPOT_LIGHT.a + glow1);
}

// -----------------------------------------------------------------------------
// Eiffie soft shadow (returns 0 = lit, 1 = shadowed)
// -----------------------------------------------------------------------------

float linstep(float a, float b, float t) {
    return clamp((t - a) / (b - a), 0.0, 1.0);
}

float shadow(vec3 ro, vec3 lightPos, float eps) {
    float rCoC = eps;
    vec3 rd = lightPos - ro;
    float lightDist = length(rd);
    rd /= max(lightDist, 1.0e-12);

    float coneGrad = CFG_SHADOW_BLUR / max(lightDist, 1.0e-12);
    float t = mapScene(ro).d * CFG_FUDGE + rCoC;
    float s = 1.0;
    float jitter = CFG_DITHER * (rnd(ro.xy * float(iFrame + 1)) - 0.5);

    for (int i = 0; i < CFG_MAX_RAY_STEPS; ++i) {
        if (t > lightDist || s < 0.001) break;
        float r = rCoC + t * coneGrad;
        float d;
        if (CFG_PERF_SHADOW) {
            d = mapScene(ro + rd * (t + r * jitter)).d * CFG_FUDGE;
            s *= linstep(-r, r, d);
            t += abs(0.75 * d + CFG_SHADOW_SOFT * r);
        } else {
            d = mapScene(ro + rd * (t + r * jitter)).d * CFG_FUDGE + r;
            s *= linstep(0.0, 2.0 * r, d);
            t += abs(0.75 * d + CFG_SHADOW_SOFT * r);
        }
    }

    s = max(0.0, s - 0.001) / 0.999;
    return clamp(1.0 - s, 0.0, 1.0);
}

// -----------------------------------------------------------------------------
// Multi-sample AO
// -----------------------------------------------------------------------------

vec2 rand2n(inout vec2 seed) {
    seed += vec2(-1.0, 1.0);
    return rnd2(seed);
}

vec3 ortho(vec3 v) {
    return abs(v.x) > abs(v.z) ? vec3(-v.y, v.x, 0.0) : vec3(0.0, -v.z, v.y);
}

vec3 getVdirAO(vec3 dir, inout vec2 seed) {
    vec3 o1 = normalize(ortho(dir));
    vec3 o2 = cross(dir, o1);
    vec2 r = rand2n(seed);
    r.x *= 2.0 * PI;
    r.y *= CFG_CONE_APERTURE_AO;
    float ry = sqrt(max(r.y, 0.0));
    float rz = sqrt(max(1.0 - r.y, 0.0));
    return cos(r.x) * ry * o1 + sin(r.x) * ry * o2 + rz * dir;
}

float ambientOcclusionOriginal(vec3 p, vec3 n, float aoEps, inout vec2 seed) {
    vec3 vdir = getVdirAO(n, seed);
    float ao = 0.0;
    float de = mapScene(p).d / aoEps;
    float wSum = 0.0;
    float d = 1.0 - CFG_DITHER * rnd(p.xy);
    float D = 1.0;

    for (int i = 1; i < CFG_MAX_ITER_AO; ++i) {
        float prevD = D;
        D = mapScene(p + d * vdir * de).d;
        float denom = d * de * dot(vdir, n) * CFG_FUDGE_AO;
        D /= (abs(denom) < 1.0e-12) ? (denom < 0.0 ? -1.0e-12 : 1.0e-12) : denom;
        D = min(prevD, D);
        d *= 1.61;
        ao += clamp(1.0 - D, 0.0, 1.0);
        wSum += 1.0;
    }
    return ao / max(wSum, 1.0e-12);
}

// -----------------------------------------------------------------------------
// Blinn-Phong/Schlick lighting
// -----------------------------------------------------------------------------

vec3 lightingOriginal(vec3 n, vec3 color, vec3 pos, vec3 dir,
                      float eps, out float shadowStrength, float ao) {
    shadowStrength = 0.0;
    vec3 col = vec3(0.0);

    vec3 lightVec = CFG_LIGHT_POS - pos;
    float d2l2 = dot(lightVec, lightVec);
    float falloff = pow(max(d2l2, 1.0e-12), -CFG_LIGHT_FALLOFF);
    vec3 spotDir = normalize(lightVec);

    float nDotL = max(CFG_AO_CORRECT, dot(n, spotDir));
    vec3 halfVector = normalize(-dir + spotDir);
    float diffuse = nDotL;
    float hDotN = max(0.0, dot(n, halfVector));

    float f0 = (CFG_SPECULAR_EXP - 1.0) / (CFG_SPECULAR_EXP + 1.0);
    f0 *= f0;
    float fresnel = f0 + (1.0 - f0) * pow(1.0 + dot(n, dir), 5.0);
    float specular = ((CFG_SPECULAR_EXP + 2.0) / 8.0)
                   * fresnel * nDotL
                   * pow(hDotN, CFG_SPECULAR_EXP + 0.00001)
                   * CFG_SPECULAR;

    if (CFG_HARD_SHADOW > 0.0) {
        shadowStrength = shadow(pos + n * eps, CFG_LIGHT_POS, eps);
        if (CFG_SSS) {
            float shS = shadow(pos + n * eps, CFG_LIGHT_POS, CFG_SSS1);
            shadowStrength = mix(shadowStrength, sqrt(shS), CFG_SSS2);
        }
        diffuse = mix(diffuse, 0.0, CFG_HARD_SHADOW * shadowStrength);
        specular *= 1.0 - shadowStrength;
    }

    vec3 FG = fogAmount3(pos, CFG_LIGHT_POS);
    col += FG * CFG_SPOT_LIGHT.rgb * CFG_SPOT_LIGHT.a * falloff
         * (diffuse + specular)
         * (1.0 - clamp(CFG_AO_POINTLIGHT * ao, 0.0, 1.0));

    nDotL = max(CFG_AO_CORRECT, dot(n, -dir));
    hDotN = max(0.0, dot(n, -dir));
    specular = ((CFG_SPECULAR_EXP + 2.0) / 8.0)
             * fresnel * nDotL
             * pow(hDotN, CFG_SPECULAR_EXP + 0.00001)
             * CFG_SPECULAR;

    col += CFG_CAM_LIGHT.rgb * CFG_CAM_LIGHT.a * (nDotL + specular)
         * (1.0 - clamp(CFG_AO_CAMLIGHT * ao, 0.0, 1.0));

    col += CFG_AMBIENT_LIGHT.rgb * CFG_AMBIENT_LIGHT.a
         * (1.0 - clamp(CFG_AO_AMBIENT * ao, 0.0, 1.0));

    return col * color;
}

// -----------------------------------------------------------------------------
// Main tracing
// -----------------------------------------------------------------------------

vec3 traceOriginal(inout SRay ray,
                   inout vec3 hitNormal,
                   inout float glow,
                   float minDist,
                   float aoEps,
                   inout vec2 aoSeed,
                   out bool lightHit) {
    glow = 1000.0;
    lightHit = false;

    float eps = minDist;
    float epsModified = max(MIN_EPS, ray.Pos * eps * CFG_FUDGE);
    vec3 p = SRCurrentPt(ray);
    float ldist = min(mapScene(p).d * CFG_FUDGE, DElight(p));
    ldist *= CFG_DITHER * rnd(ray.Direction.xy) + (1.0 - CFG_DITHER);
    SRAdvance(ray, ldist);

    float dist = 0.0;
    float lightde = 0.0;
    bool hitSomething = false;

    for (int steps = 0; steps < CFG_MAX_RAY_STEPS; ++steps) {
        p = SRCurrentPt(ray);
        dist = min(DElight(p), mapScene(p).d * CFG_FUDGE);
        lightde = DElight(p);
        glow = min(lightde, glow);
        SRAdvance(ray, dist);
        epsModified = max(MIN_EPS, ray.Pos * eps * CFG_FUDGE);

        if (dist < epsModified) {
            for (int i = 0; i < CFG_REFINE_STEPS; ++i) {
                SRAdvance(ray, dist - 1.5 * epsModified);
                p = SRCurrentPt(ray);
                lightde = DElight(p);
                dist = min(lightde, mapScene(p).d * CFG_FUDGE);
                glow = min(lightde, glow);
            }
            hitSomething = true;
            break;
        }

        if (ray.Pos > CFG_MAX_DISTANCE) break;
    }

    if (!hitSomething) {
        hitNormal = vec3(0.0);
        ray.Pos = CFG_MAX_DISTANCE;
        return CFG_BACKGROUND;
    }

    if (dist == lightde && dist == glow) {
        lightHit = true;
        return CFG_SPOT_LIGHT.rgb * CFG_SPOT_LIGHT.a / (CFG_LIGHT_SIZE + 0.01);
    }

    vec3 hit = SRCurrentPt(ray);
    hitNormal = calcNormal(hit - CFG_NORMAL_BACKSTEP * epsModified * ray.Direction, epsModified);

    MapResult mr = mapScene(hit);
    vec3 hitColor = (mr.mat == MAT_FLOOR) ? floorPattern(hit.xy) : materialColor(mr.mat);
    hitColor = pow(clamp(hitColor, 0.0, 1.0), vec3(CFG_GAMMA));

    float ao = (CFG_DETAIL_AO_LOG10 < 0.0)
             ? ambientOcclusionOriginal(hit, hitNormal, aoEps, aoSeed)
             : 0.0;

    float shadowStrength;
    return lightingOriginal(hitNormal, hitColor, hit, ray.Direction, epsModified, shadowStrength, ao);
}

// -----------------------------------------------------------------------------
// Volumetric point-light importance sample
// -----------------------------------------------------------------------------

float length2(vec3 p) {
    return dot(p, p);
}

vec3 ptLightGlow3(vec3 p0, vec3 p1, inout int fogStrata) {
    float A = length2(p0 - CFG_LIGHT_POS);
    float B = dot(p1 - p0, p0 - CFG_LIGHT_POS);
    float C = max(length2(p1 - p0), 1.0e-16);
    float Delta = sqrt(max(A * C - B * B, 1.0e-16));

    vec2 viewCoord = 2.0 * gl_FragCoord.xy / iResolution.xy - 1.0;
    float x = CFG_DITHER
            * (rnd(viewCoord + vec2(1.6183 + float(iFrame + fogStrata))) + float(fogStrata))
            / float(CFG_HF_FOG_ITER);
    fogStrata++;

    float atanB = atan(B / Delta);
    float atanBC = atan((B + C) / Delta);
    float PDF_NF = (atanBC - atanB) / Delta;
    float t = (tan(mix(atanB, atanBC, x)) * Delta - B) / C;
    t = clamp(t, 0.00001, 1.0);

    vec3 pt = p0 + t * (p1 - p0);
    vec3 extP0t = fogAmount3(p0, pt);
    vec3 extLt = fogAmount3(pt, CFG_LIGHT_POS);

    vec3 hfdir = normalize(CFG_HF_DIR);
    float ty = CFG_HF_FALLOFF * (dot(pt, hfdir) - CFG_HF_OFFSET);
    vec3 density = CFG_HF_COLOR.rgb * CFG_HF_INTENSITY * exp1(-ty) + vec3(CFG_HF_CONST);

    float shadowVisibility = 1.0;
    if (CFG_HF_CAST_SHADOW) {
        shadowVisibility = 1.0 - shadow(pt, CFG_LIGHT_POS, 0.001);
    }

    float cosTheta = dot(normalize(pt - p0), normalize(CFG_LIGHT_POS - pt));
    vec3 denom = vec3(1.0) + CFG_HF_ANISOTROPY * CFG_HF_ANISOTROPY
               - 2.0 * CFG_HF_ANISOTROPY * cosTheta;
    vec3 anie = (vec3(1.0) - CFG_HF_ANISOTROPY * CFG_HF_ANISOTROPY)
              / sqrt(max(denom * denom * denom, vec3(1.0e-12)));

    vec3 sampleValue = extP0t * extLt * density * anie * shadowVisibility * sqrt(C);
    return CFG_SPOT_LIGHT.rgb * CFG_SPOT_LIGHT.a * PDF_NF * sampleValue * CFG_HF_SCATTER;
}

// -----------------------------------------------------------------------------
// Reflection / fog / volumetric composition
// -----------------------------------------------------------------------------

vec3 renderOriginal(SRay ray, vec2 viewCoord) {
    float aoEps = pow(10.0, CFG_DETAIL_AO_LOG10);
    float minDist = pow(10.0, CFG_DETAIL_LOG10);
    vec2 aoSeed = viewCoord * float(iFrame + 1);

    float glow = 0.5;
    vec3 hitNormal = vec3(0.0);
    vec3 col = vec3(0.0);
    vec3 reflectionWeight = vec3(1.0);
    vec3 prevPos = SRCurrentPt(ray);
    bool lightHit = false;

    for (int i = 0; i <= CFG_REFLECTIONS; ++i) {
        vec3 col0 = traceOriginal(ray, hitNormal, glow, minDist, aoEps, aoSeed, lightHit);
        vec3 curPos = SRCurrentPt(ray);

        vec3 FG = fogAmount3(prevPos, curPos);
        col0 = mix(CFG_HF_COLOR.rgb * CFG_HF_COLOR.a, col0, FG);
        col0 += ptLightGlow(max(0.0, glow));

        if (CFG_HF_SCATTER * (CFG_HF_INTENSITY + CFG_HF_CONST) > 0.0) {
            int fogStrata = 0;
            vec3 fogGlow = vec3(0.0);
            for (int j = 0; j < CFG_HF_FOG_ITER; ++j) {
                fogGlow += ptLightGlow3(prevPos, curPos, fogStrata);
            }
            col0 += fogGlow / float(CFG_HF_FOG_ITER);
        }

        col += col0 * reflectionWeight;
        reflectionWeight *= CFG_REFLECTION * FG;

        if (dot(hitNormal, hitNormal) == 0.0
            || dot(reflectionWeight, reflectionWeight) < 0.00001
            || lightHit
            || ray.Pos >= CFG_MAX_DISTANCE) {
            break;
        }

        ray = SRReflect(ray, hitNormal, minDist);
        prevPos = curPos;
        lightHit = false;
    }

    return max(col, vec3(0.0));
}


// -----------------------------------------------------------------------------
// Mouse orbit camera
// -----------------------------------------------------------------------------
// Move the mouse while holding the button. The last view is kept after release.
// Screen centre corresponds to the default camera above.
void getCamera(vec2 resolution, out vec3 eye, out vec3 target) {
    target = CFG_TARGET;

    vec3 baseOffset = CFG_EYE - CFG_TARGET;
    float radius = length(baseOffset);
    float yaw = atan(baseOffset.y, baseOffset.x);
    float pitch = asin(clamp(baseOffset.z / radius, -1.0, 1.0));

    bool hasMouseView = dot(abs(iMouse.zw), vec2(1.0)) > 0.0;
    if (hasMouseView) {
        vec2 m = clamp(iMouse.xy / resolution, 0.0, 1.0) - 0.5;

        // Horizontal orbit: about +/- 80 degrees.
        yaw -= m.x * 2.8;

        // Vertical orbit. Keep the camera above the ideal boundary.
        pitch = clamp(pitch + m.y * 1.55, 0.08, 1.22);
    }

    float cp = cos(pitch);
    eye = target + radius * vec3(cp * cos(yaw), cp * sin(yaw), sin(pitch));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 resolution = iResolution.xy;
    vec2 viewCoord = 2.0 * fragCoord / resolution - 1.0;
    vec2 coord = ((2.0 * (fragCoord + 0.5) - resolution) / resolution.y) * CFG_FOV;

    vec3 eye, target;
    getCamera(resolution, eye, target);

    vec3 forward = normalize(target - eye);
    vec3 upOrtho = normalize(CFG_UP - dot(forward, CFG_UP) * forward);
    vec3 right = normalize(cross(forward, upOrtho));

    vec2 disc = uniformDisc(coord * float(iFrame + 1));
    vec2 pixelScale = vec2(2.0 / resolution.y);
    vec2 jitteredCoord = coord + CFG_AA_SCALE * pixelScale * CFG_FOV * disc;

    vec3 rayDir = forward + jitteredCoord.x * right + jitteredCoord.y * upOrtho;
    float rayDirLength = length(rayDir);

    SRay ray = SRay(
        eye,
        rayDir / rayDirLength,
        0.0,
        1.0 / max(1.0, rayDirLength)
    );

    vec3 c = renderOriginal(ray, viewCoord);

    // Do not blend different camera views while dragging. On release, the final
    // drag frame becomes the first accumulation sample for the retained view.
    bool cameraDragging = iMouse.z > 0.0;
    vec4 prev = (iFrame == 0 || cameraDragging)
              ? vec4(0.0)
              : texelFetch(iChannel0, ivec2(fragCoord), 0);

    float w = 1.0 - length(disc);
    if (CFG_GAUSSIAN_WEIGHT > 0.0) {
        w = exp(-dot(disc, disc) / CFG_GAUSSIAN_WEIGHT) - exp(-1.0 / CFG_GAUSSIAN_WEIGHT);
    }

    fragColor = prev + vec4(c * w, w);
}
