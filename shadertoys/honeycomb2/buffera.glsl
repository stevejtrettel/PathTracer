const float PI = 3.14159265358979323846;
const float MIN_EPS = 1.1920928955078125e-7;

const float FOV = 0.66;
const vec3 CAMERA_POS   = vec3(0.68534756, 1.50286375, 6.02741241);
const vec3 CAMERA_DIR   = vec3(-0.069559431916197, -0.181127092711777, -0.980996667536274);
const vec3 CAMERA_UP    = vec3(-0.453970180144104, -0.869906389479763,  0.192805469533965);
const vec3 CAMERA_RIGHT = vec3(-0.888297563303776,  0.458754672813326, -0.021716104634861);

const float GAMMA = 2.2;
const float ANTI_ALIAS_SCALE = 2.0;
const float MIN_DIST = 1.0e-7;
const int REFINE_STEPS = 2;
const float FUDGE_FACTOR = 0.95;
const int MAX_RAY_STEPS = 1200;
const int MAX_SHADOW_STEPS = 300;
const float MAX_DISTANCE = 100.0;
const float DITHER = 0.55852;
const float NORMAL_BACK_STEP = 6.5875;

const float AO_EPS = 0.05186447666087581;
const float AO_CONE_APERTURE = 0.85;
const int AO_ITERATIONS = 7;
const float AO_AMBIENT = 0.7;

const float SPECULAR = 0.21538;
const float SPECULAR_EXP = 248.51;
const float AMBIENT_STRENGTH = 0.59682;
const vec3 REFLECTION = vec3(0.254902);
const int REFLECTION_COUNT = 1;

const vec3 SPOT_COLOR = vec3(0.94902, 0.882353, 0.772549);
const float SPOT_STRENGTH = 10.0;
const vec3 LIGHT_POS = vec3(-1.7558, -2.2138, 4.6564);
const float LIGHT_SIZE = 0.03475;
const float LIGHT_FALLOFF = 0.50202;
const float SHADOW_CONE_BIAS = 0.201;

const vec3 BASE_COLOR = vec3(0.67451);
const float ORBIT_STRENGTH = 0.55319;
const vec3 BACKGROUND_COLOR = vec3(0.172549, 0.235294, 0.294118);
const float BACKGROUND_GRADIENT = 0.47295;

const vec3 SEG_A_COLOR = vec3(0.811765, 0.733333, 0.32549);
const vec3 SEG_B_COLOR = vec3(0.0, 0.486275, 0.729412);
const vec3 SEG_C_COLOR = vec3(0.647059, 0.866667, 0.843137);
const vec3 SEG_D_COLOR = vec3(0.717647, 0.415686, 0.847059);
const vec3 FACE_BD_COLOR = vec3(0.835294118, 0.647058824, 0.784313725);
const vec3 VERTEX_COLOR = vec3(0.909804, 0.937255, 0.976471);
const vec3 FLOOR_COLOR_1 = vec3(0.968627451, 1.0, 0.6);
const vec3 FLOOR_COLOR_2 = vec3(0.552941176, 0.380392157, 0.521568627);
const vec3 FLOOR_LINE_COLOR = vec3(0.0);

const float FLOOR_Z = 1.0e-3;
const float FLOOR_LINE_THICKNESS = 0.008;
const int FOLD4_ITERATIONS = 180;
const int FOLD3_ITERATIONS = 70;

const vec4 MIRROR_A = vec4(1.0, 0.0, 0.0, 0.0);
const vec4 MIRROR_B = vec4(-0.5, 0.8660254037844386, 0.0, 0.0);
const vec4 MIRROR_C = vec4(0.0, 0.0, 1.0, 0.0);
const vec4 MIRROR_D = vec4(0.0, -0.57735026918962595, -0.92387953251128685, -0.43230397167572659);
const vec4 INITIAL_VERTEX = vec4(0.0, 0.0, 0.0, 1.0);
const vec4 INVERSION_SPHERE = vec4(0.0, 1.335519232014724, 2.1371062825819451, 2.3131871672861219);

const float VERTEX_COSH = 1.0050041680558035;
const float VERTEX_SINH = 0.10016675001984403;
const float EDGE_COSH = 1.0012502604383691;
const float EDGE_SINH = 0.050020835937655016;
const float FACE_COSH = 1.0000125000260416;
const float FACE_SINH = 0.0050000208333593754;

const mat3 FACE_BD_INV = mat3(
   -0.80052367148149761,  0.23071304173459076,  0.4614260834691814,
    0.23071304173459076,  1.266841223827166,    0.53368244765433193,
    0.4614260834691814,   0.53368244765433193,  1.0673648953086636
);

vec2 viewCoord, coord, aoSeed;
float lastHoneycombDistance = 1.0e20;
float lastPatternFloorHeight = 1.0e20;

float random1(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 random2(vec2 p) {
    return vec2(
        fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453),
        fract(cos(dot(p, vec2(4.898, 7.23))) * 23421.631)
    );
}

vec2 uniformDisc(vec2 p) {
    vec2 r = random2(p);
    float a = 6.28 * r.x;
    return sqrt(r.y) * vec2(cos(a), sin(a));
}

vec3 currentPoint(vec3 origin, vec3 direction, float pos) {
    return origin + direction * pos;
}

void reflectRay(inout vec3 origin, inout vec3 direction, inout float pos, vec3 normal) {
    vec3 hit = currentPoint(origin, direction, pos);
    direction = reflect(direction, normal);
    origin = hit + reflect(origin - hit, normal);
    pos += MIN_DIST;
}

float hdot(vec4 p, vec4 q) {
    return dot(p.xyz, q.xyz) - p.w * q.w;
}

vec4 hnormalize(vec4 p) {
    return p * inversesqrt(-hdot(p, p));
}

float tryReflect4(inout vec4 p, vec4 n) {
    float k = min(0.0, hdot(p, n));
    p -= 2.0 * k * n;
    return k;
}

bool fold4d(inout vec4 p) {
    for (int i = 0; i < FOLD4_ITERATIONS; ++i) {
        float k = 0.0;
        p.x = abs(p.x);
        k += tryReflect4(p, MIRROR_B);
        k += tryReflect4(p, MIRROR_C);
        k += tryReflect4(p, MIRROR_D);
        if (k == 0.0) return true;
    }
    return false;
}

bool foldB(inout vec3 p, inout int count) {
    float k = dot(p, MIRROR_B.xyz);
    if (k >= 0.0) return true;
    p -= 2.0 * k * MIRROR_B.xyz;
    count += 1;
    return false;
}

bool foldSphere(inout vec3 p, inout int count) {
    vec3 q = p - INVERSION_SPHERE.xyz;
    float d2 = dot(q, q);
    if (d2 == 0.0) return true;

    float k = INVERSION_SPHERE.w * INVERSION_SPHERE.w / d2;
    if (k < 1.0) return true;

    p = k * q + INVERSION_SPHERE.xyz;
    count += 1;
    return false;
}

bool fold3d(inout vec3 p, inout int count) {
    for (int i = 0; i < FOLD3_ITERATIONS; ++i) {
        bool inA = p.x >= 0.0;
        if (!inA) { p.x = -p.x; count += 1; }

        bool inB = foldB(p, count);

        bool inC = p.z >= 0.0;
        if (!inC) { p.z = -p.z; count += 1; }

        bool inD = foldSphere(p, count);
        if (inA && inB && inC && inD) return true;
    }
    return false;
}

float distABCD(vec3 p) {
    return min(
        min(abs(p.x), abs(dot(p, MIRROR_B.xyz))),
        min(abs(p.z), abs(length(p - INVERSION_SPHERE.xyz) - INVERSION_SPHERE.w))
    );
}

vec3 planeToSphere(vec2 p) {
    float r2 = dot(p, p);
    return vec3(2.0 * p, r2 - 1.0) / (1.0 + r2);
}

float knightyDD(float ca, float sa, float r) {
    float rr = r * r;
    float cm1 = ca - 1.0;
    return (1.0 - rr) * (sa + r * cm1) /
           (1.0 + ca + rr * cm1 + 2.0 * r * sa);
}

float hsind(vec4 p, vec4 q) {
    return 0.5 * sqrt(-hdot(p - q, p - q) * hdot(p + q, p + q));
}

float dVertexCached(vec4 p, float r, float pv) {
    float ca = -pv;
    float sa = hsind(p, INITIAL_VERTEX);
    return knightyDD(ca * VERTEX_COSH - sa * VERTEX_SINH,
                     sa * VERTEX_COSH - ca * VERTEX_SINH, r);
}

float dSegmentCached(vec4 p, vec4 n, float r, float pv, float pn) {
    float nv = -n.w;
    float det = -1.0 - nv * nv;
    vec4 q = hnormalize(min((-nv * pv - pn) / det, 0.0) * n +
                        ((pv - pn * nv) / det) * INITIAL_VERTEX);

    float ca = -hdot(p, q);
    float sa = hsind(p, q);
    return knightyDD(ca * EDGE_COSH - sa * EDGE_SINH,
                     sa * EDGE_COSH - ca * EDGE_SINH, r);
}

float dFaceBDCached(vec4 p, float r, float pv, float pB, float pD) {
    vec3 c = vec3(pv, pB, pD) * FACE_BD_INV;
    if (c.y > 0.0 || c.z > 0.0) return 1.0e5;

    vec4 q = hnormalize(c.x * INITIAL_VERTEX + c.y * MIRROR_B + c.z * MIRROR_D);
    float ca = -hdot(p, q);
    float sa = hsind(p, q);
    return knightyDD(ca * FACE_COSH - sa * FACE_SINH,
                     sa * FACE_COSH - ca * FACE_SINH, r);
}

float dSegmentsCached(vec4 p, float r, float pv, float pA, float pB, float pC, float pD) {
    return min(
        min(dSegmentCached(p, MIRROR_A, r, pv, pA), dSegmentCached(p, MIRROR_B, r, pv, pB)),
        min(dSegmentCached(p, MIRROR_C, r, pv, pC), dSegmentCached(p, MIRROR_D, r, pv, pD))
    );
}

vec4 toHyperboloid(inout vec3 p, out float r) {
    p.z += 1.0;
    p *= 2.0 / dot(p, p);
    p.z -= 1.0;
    r = length(p);
    return vec4(2.0 * p, 1.0 + r * r) / (1.0 - r * r);
}

void getDots(vec4 q, out float qV, out float qA, out float qB, out float qC, out float qD) {
    qV = -q.w;
    qA = q.x;
    qB = dot(q.xyz, MIRROR_B.xyz);
    qC = q.z;
    qD = hdot(q, MIRROR_D);
}

float DE(vec3 p) {
    float h = p.z - FLOOR_Z;
    float r;
    vec4 q = toHyperboloid(p, r);
    fold4d(q);

    float qV, qA, qB, qC, qD;
    getDots(q, qV, qA, qB, qC, qD);

    float dHoneycomb = min(
        dFaceBDCached(q, r, qV, qB, qD),
        min(dVertexCached(q, r, qV), dSegmentsCached(q, r, qV, qA, qB, qC, qD))
    );

    lastHoneycombDistance = dHoneycomb;
    lastPatternFloorHeight = h;
    return min(h, dHoneycomb);
}

vec3 baseColor(vec3 pos) {
    vec3 floorPoint = pos;
    float h = pos.z - FLOOR_Z;

    float r;
    vec4 q = toHyperboloid(pos, r);
    if (!fold4d(q)) return BACKGROUND_COLOR;

    float qV, qA, qB, qC, qD;
    getDots(q, qV, qA, qB, qC, qD);

    float dA = dSegmentCached(q, MIRROR_A, r, qV, qA);
    float dB = dSegmentCached(q, MIRROR_B, r, qV, qB);
    float dC = dSegmentCached(q, MIRROR_C, r, qV, qC);
    float dD = dSegmentCached(q, MIRROR_D, r, qV, qD);
    float dV = dVertexCached(q, r, qV);
    float dF = dFaceBDCached(q, r, qV, qB, qD);

    float d = min(min(dF, dV), min(min(dA, dB), min(dC, dD)));
    d = min(d, h);

    vec3 color = SEG_A_COLOR;
    if (d == dB) color = SEG_B_COLOR;
    if (d == dC) color = SEG_C_COLOR;
    if (d == dD) color = SEG_D_COLOR;
    if (d == dV) color = VERTEX_COLOR;
    if (d == dF) color = FACE_BD_COLOR;

    if (d == h) {
        int count = 0;
        vec3 folded = planeToSphere(floorPoint.xy);
        bool found = fold3d(folded, count);
        color = found ? ((count % 2 == 0) ? FLOOR_COLOR_1 : FLOOR_COLOR_2) : FLOOR_LINE_COLOR;

        float edgeDistance = distABCD(folded);
        float aa = 0.5 * fwidth(edgeDistance);
        float lineMask = 1.0 - smoothstep(
            FLOOR_LINE_THICKNESS - aa,
            FLOOR_LINE_THICKNESS + aa,
            edgeDistance
        );
        color = mix(color, FLOOR_LINE_COLOR, lineMask);
    }

    return color;
}

float sceneDistanceAlongRay(vec3 p, vec3 rd, float floorClearance) {
    DE(p);
    float h = lastPatternFloorHeight;
    float floorRayDistance = 1.0e20;

    if (h <= floorClearance) floorRayDistance = h;
    else if (rd.z < -1.0e-7) floorRayDistance = (h - floorClearance) / (-rd.z);

    return min(lastHoneycombDistance, floorRayDistance);
}

float lightDistance(vec3 p) {
    return length(LIGHT_POS - p) - LIGHT_SIZE;
}

vec3 surfaceNormal(vec3 p, float normalDistance) {
    float e = max(0.5 * normalDistance, 1.0e-5);
    vec3 ex = vec3(e, 0.0, 0.0);
    vec3 ey = vec3(0.0, e, 0.0);
    vec3 ez = vec3(0.0, 0.0, e);
    vec3 n = normalize(vec3(
        DE(p + ex) - DE(p - ex),
        DE(p + ey) - DE(p - ey),
        DE(p + ez) - DE(p - ez)
    ));
    return all(equal(n, n)) ? n : vec3(0.0);
}

float softShadow(vec3 ro, float eps) {
    vec3 rd = LIGHT_POS - ro;
    float lightDist = length(rd);
    rd /= lightDist;

    float coneGrad = lightDist / SHADOW_CONE_BIAS;
    float totalDist = 2.0 * eps;
    float visibility = 1.0;
    float jitterScale = 1.0 + DITHER * (random1(ro.xy) - 0.5) / coneGrad;

    for (int i = 0; i < MAX_SHADOW_STEPS && totalDist < lightDist; ++i) {
        float dist = DE(ro + totalDist * jitterScale * rd) * FUDGE_FACTOR;
        if (dist < eps) return 1.0;
        visibility = min(visibility, coneGrad * dist / totalDist);
        totalDist += dist;
    }
    return 1.0 - visibility;
}

vec3 orthogonal(vec3 v) {
    return abs(v.x) > abs(v.z) ? vec3(-v.y, v.x, 0.0) : vec3(0.0, -v.z, v.y);
}

vec3 aoDirection(vec3 n) {
    aoSeed += vec2(-1.0, 1.0);
    vec2 r = random2(aoSeed);
    r.x *= 2.0 * PI;
    r.y *= AO_CONE_APERTURE;

    vec3 o1 = normalize(orthogonal(n));
    vec3 o2 = cross(n, o1);
    float radial = sqrt(r.y);
    return cos(r.x) * radial * o1 +
           sin(r.x) * radial * o2 +
           sqrt(1.0 - r.y) * n;
}

float ambientOcclusion(vec3 p, vec3 n) {
    vec3 direction = aoDirection(n);
    float de = DE(p) / AO_EPS;
    float d = 1.0 - DITHER * random1(p.xy);
    float previous = 1.0;
    float ao = 0.0;
    float directionDotNormal = dot(direction, n);

    for (int i = 1; i < AO_ITERATIONS; ++i) {
        float current = DE(p + d * direction * de) / (d * de * directionDotNormal);
        current = min(previous, current);
        previous = current;
        ao += clamp(1.0 - current, 0.0, 1.0);
        d *= 1.61;
    }

    return ao / float(AO_ITERATIONS - 1);
}

vec3 pointLightGlow(float glow) {
    return SPOT_COLOR * (SPOT_STRENGTH * exp(-20.0 * glow) + exp(-1.0e8 * glow));
}

vec3 lighting(vec3 n, vec3 surfaceColor, vec3 pos, vec3 rayDir, float eps, float ao) {
    vec3 toLight = LIGHT_POS - pos;
    float d2 = dot(toLight, toLight);
    float falloff = pow(d2, -LIGHT_FALLOFF);
    vec3 lightDir = toLight * inversesqrt(d2);

    float nDotL = max(0.0, dot(n, lightDir));
    vec3 halfVector = normalize(lightDir - rayDir);
    float hDotN = max(0.0, dot(n, halfVector));

    float f0 = (SPECULAR_EXP - 1.0) / (SPECULAR_EXP + 1.0);
    f0 *= f0;
    float fresnel = f0 + (1.0 - f0) * pow(1.0 + dot(n, rayDir), 5.0);
    float specular = ((SPECULAR_EXP + 2.0) / 8.0) *
                     fresnel * nDotL *
                     pow(hDotN, SPECULAR_EXP + 0.00001) *
                     SPECULAR;

    float lightVisibility = 1.0 - softShadow(pos + n * eps, eps);
    vec3 direct = SPOT_COLOR * SPOT_STRENGTH * falloff *
                  (nDotL + specular) * lightVisibility;

    vec3 ambient = vec3(AMBIENT_STRENGTH) *
                   (1.0 - clamp(AO_AMBIENT * ao, 0.0, 1.0));

    return (direct + ambient) * surfaceColor;
}

float rayEps(float rayPos) {
    return max(MIN_EPS, rayPos * MIN_DIST * FUDGE_FACTOR);
}

vec3 trace(
    inout vec3 origin,
    inout vec3 direction,
    inout float rayPos,
    float rayFudge,
    out vec3 hitNormal,
    out float glow,
    out bool hitLight
) {
    glow = 1000.0;
    hitLight = false;
    bool hitSomething = false;

    float dist = 0.0;
    float lightDE = 0.0;
    float eps = rayEps(rayPos);

    vec3 p = currentPoint(origin, direction, rayPos);
    float initialStep = min(
        sceneDistanceAlongRay(p, direction, 0.5 * eps) * FUDGE_FACTOR,
        lightDistance(p)
    );
    initialStep *= DITHER * random1(direction.xy) + (1.0 - DITHER);
    rayPos += initialStep * rayFudge;

    for (int steps = 0; steps < MAX_RAY_STEPS; ++steps) {
        p = currentPoint(origin, direction, rayPos);
        lightDE = lightDistance(p);
        dist = min(lightDE, sceneDistanceAlongRay(p, direction, 0.5 * eps) * FUDGE_FACTOR);

        glow = min(lightDE, glow);
        rayPos += dist * rayFudge;
        eps = rayEps(rayPos);

        if (dist < eps) {
            for (int i = 0; i < REFINE_STEPS; ++i) {
                rayPos += (dist - 1.5 * eps) * rayFudge;
                p = currentPoint(origin, direction, rayPos);
                lightDE = lightDistance(p);
                dist = min(lightDE, sceneDistanceAlongRay(p, direction, 0.5 * eps) * FUDGE_FACTOR);
                glow = min(lightDE, glow);
            }
            hitSomething = true;
            break;
        }

        if (rayPos > MAX_DISTANCE) break;
    }

    vec3 background = mix(BACKGROUND_COLOR, vec3(0.0), length(coord) * BACKGROUND_GRADIENT);

    if (!hitSomething) {
        hitNormal = vec3(0.0);
        rayPos = MAX_DISTANCE;
        return background;
    }

    if (dist == lightDE && dist == glow) {
        hitLight = true;
        return SPOT_COLOR * SPOT_STRENGTH / (LIGHT_SIZE + 0.01);
    }

    vec3 hit = currentPoint(origin, direction, rayPos);
    hitNormal = surfaceNormal(hit - NORMAL_BACK_STEP * eps * direction, eps);

    vec3 hitColor = mix(BASE_COLOR, baseColor(hit), ORBIT_STRENGTH);
    hitColor = pow(clamp(hitColor, 0.0, 1.0), vec3(GAMMA));

    return lighting(hitNormal, hitColor, hit, direction, eps, ambientOcclusion(hit, hitNormal));
}

vec3 render(vec3 origin, vec3 direction, float rayFudge) {
    aoSeed = viewCoord * (float(iFrame) + 1.0);

    float glow = 0.5;
    float rayPos = 0.0;
    bool hitLight = false;
    vec3 hitNormal = vec3(0.0);
    vec3 color = vec3(0.0);
    vec3 reflectionWeight = vec3(1.0);

    for (int i = 0; i <= REFLECTION_COUNT; ++i) {
        vec3 passColor = trace(origin, direction, rayPos, rayFudge, hitNormal, glow, hitLight);
        passColor += pointLightGlow(max(0.0, glow));

        color += passColor * reflectionWeight;
        reflectionWeight *= REFLECTION;

        if (all(equal(hitNormal, vec3(0.0))) ||
            dot(reflectionWeight, reflectionWeight) < 0.00001 ||
            hitLight || rayPos >= MAX_DISTANCE) {
            break;
        }

        reflectRay(origin, direction, rayPos, hitNormal);
    }

    return max(color, vec3(0.0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    viewCoord = 2.0 * fragCoord / iResolution.xy - 1.0;
    coord = vec2(viewCoord.x * iResolution.x / iResolution.y, viewCoord.y) * FOV;

    vec2 disc = uniformDisc(coord * float(1 + iFrame));
    vec2 jitteredCoord = coord + ANTI_ALIAS_SCALE * FOV * disc / iResolution.xy;

    vec3 rayDirection =
        CAMERA_DIR +
        jitteredCoord.x * CAMERA_RIGHT +
        jitteredCoord.y * CAMERA_UP;

    float directionLength = length(rayDirection);
    vec3 sampleColor = render(
        CAMERA_POS,
        rayDirection / directionLength,
        1.0 / max(1.0, directionLength)
    );

    float weight = exp(-dot(disc, disc)) - exp(-1.0);
    vec4 previous = (iFrame == 0) ? vec4(0.0) : texture(iChannel0, fragCoord / iResolution.xy);
    fragColor = previous + vec4(sampleColor * weight, weight);
}
