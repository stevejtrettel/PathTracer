#define FRAME iFrame

const float PI = 3.14159265358979323846264;
const float MIN_EPS = 2.0 / 16777216.0;

// Camera and accumulation
const float FOV = 0.685022;
const vec3 EYE = vec3(0.0480527, 1.022421, 0.1451418);
const vec3 TARGET = vec3(0.7711199, 0.8107938, -0.5924014);
const vec3 CAMERA_UP = vec3(0.0883084, 0.9702494, -0.1918238);
const float FOCAL_PLANE = 0.1849642;
const float APERTURE = 0.02124;
const float IN_FOCUS_WIDTH = 0.9976219;
const float ANTI_ALIAS_SCALE = 1.5;
const float GAUSSIAN_WEIGHT = 1.0;

// Ray marcher
const float MIN_DIST = 0.00031622776601683794; // pow(10.0, -3.5)
const float AO_EPS = 0.010758358199007945;     // pow(10.0, -1.968254)
const int REFINE_STEPS = 3;
const float FUDGE_FACTOR = 0.24;
const int MAX_RAY_STEPS = 800;
const float MAX_DISTANCE = 20.0;
const float DITHER = 0.5;
const float NORMAL_BACK_STEP = 31.0;

// AO
const float CONE_APERTURE_AO = 0.3789847;
const int MAX_ITER_AO = 19;
const float FUDGE_AO = 0.3499434;
const float AO_AMBIENT = 1.0;
const float AO_CAMLIGHT = 1.592166;
const float AO_POINTLIGHT = 0.4495944;
const float AO_CORRECT = 0.7281001;

// Lighting and color
const float SPECULAR = 0.4;
const float SPECULAR_EXP = 16.0;
const vec4 CAM_LIGHT = vec4(1.0, 0.945098, 0.8980392, 0.2816901);
const vec4 AMBIENT_LIGHT = vec4(1.0, 0.972549, 0.9176471, 1.095923);
const vec3 REFLECTION = vec3(0.3529412);
const vec4 SPOT_LIGHT = vec4(1.0, 0.8901961, 0.7921569, 2.190132);
const vec3 LIGHT_POS = vec3(-1.0, 1.0, -1.0);
const float LIGHT_SIZE = 0.02;
const float HARD_SHADOW = 0.9109027;
const float SHADOW_SOFT = 19.01176;

const vec3 BASE_COLOR = vec3(0.776471);
const float ORBIT_STRENGTH = 0.6392111;
const vec4 ORBIT_X = vec4(0.0, 1.0, 0.164706, 1.0);
const vec4 ORBIT_Y = vec4(1.0, 0.533333, 0.0, 1.0);
const vec4 ORBIT_Z = vec4(0.603922, 0.164706, 0.776471, 1.0);
const vec4 ORBIT_R = vec4(0.262745, 0.482353, 1.0, 0.29412);
const vec3 BACKGROUND_COLOR = vec3(0.270588, 0.403922, 0.6);

// Constant-density fog. HF_Intensity is zero in this preset.
const float HF_CONST = 0.0034602;
const vec4 HF_COLOR = vec4(0.5647059, 0.7529412, 0.8784314, 1.0);
const float HF_SCATTER = 10.0;
const vec3 HF_ANISOTROPY = vec3(0.1333333, 0.007843137, 0.0);

// Clouds
const vec3 CLOUD_DIR = vec3(0.2735739, -0.7206054, -0.7804511);
const float CLOUD_TOPS = 1.0;
const float CLOUD_BASE = -1.0;
const float CLOUD_DENSITY = 0.4841363;
const vec3 CLOUD_COLOR = vec3(0.65, 0.68, 0.7);
const vec3 CLOUD_COLOR_2 = vec3(0.07, 0.17, 0.24);
const vec3 SUN_LIGHT_COLOR = vec3(0.7, 0.5, 0.3);

// Kleinian geometry
const int BOX_ITERATIONS = 60;
const float KLEIN_R = 1.965295;
const float KLEIN_I = 0.0182628;
const float BOX_SIZE_Z = 0.7071;
const float BOX_SIZE_X = 0.7071;
const int FINAL_ITERATIONS = 19;
const float CLAMP_Y = 0.4;
const float CLAMP_DF = 3.0;
const float KLEIN_SHEAR = 0.009292650721647385;
const vec2 KLEIN_WRAP_PERIOD = vec2(1.4142);
const vec2 KLEIN_WRAP_OFFSET = vec2(-0.7071);
const float SEPARATION_BASE = 0.9826475;
const float SEPARATION_AMPLITUDE = 0.4951475;
const float SEPARATION_DECAY = 7.429425;
const float KLEIN_HALF_I = 0.0091314;

vec2 gViewCoord = vec2(0.0);
vec2 gCoord = vec2(0.0);
vec2 gPixelScale = vec2(0.0);
vec3 gCameraPos = vec3(0.0);
vec3 gCameraDir = vec3(0.0);
vec3 gCameraUp = vec3(0.0);
vec3 gCameraRight = vec3(0.0);
vec2 gAOSeed = vec2(0.0);
vec4 gOrbitTrap = vec4(10000.0);
bool gLightHit = false;
int gFogStrata = 0;

// -----------------------------------------------------------------------------
// Random numbers
// -----------------------------------------------------------------------------

uint wangHash(uint seed)
{
    seed = (seed ^ 61u) ^ (seed >> 16u);
    seed *= 9u;
    seed ^= seed >> 4u;
    seed *= 0x27d4eb2du;
    seed ^= seed >> 15u;
    return seed;
}

float random2D(vec2 p)
{
    uint x = floatBitsToUint(p.x);
    uint y = floatBitsToUint(p.y);
    return float(wangHash(wangHash(x) + y)) / 4294967296.0;
}

float random3D(vec3 p)
{
    uint x = floatBitsToUint(p.x);
    uint y = floatBitsToUint(p.y);
    uint z = floatBitsToUint(p.z);
    return float(wangHash(wangHash(wangHash(x) + y) + z)) / 4294967296.0;
}

float random1D(float p)
{
    return random2D(vec2(p, p + 17.0));
}

vec2 random2(vec2 p)
{
    return vec2(
        fract(sin(dot(p, vec2(random1D(p.x) * 12.9898,
                               random1D(p.y) * 78.233))) * 43758.5453),
        fract(cos(dot(p, vec2(random1D(p.x) * 4.898,
                               random1D(p.y) * 7.23))) * 23421.631)
    );
}

vec2 uniformDisc(vec2 p)
{
    vec2 r = random2(p);
    float angle = r.x * 2.0 * PI;
    return sqrt(r.y) * vec2(cos(angle), sin(angle));
}

vec2 pentagonalStarAperture(vec2 p)
{
    vec2 r = random2(p);
    float d = 1.0 / tan(PI / 5.0);
    float scale = 1.0 / sqrt(1.0 + d * d);

    // ApStarShaped=true: do not fold p.x into a regular polygon.
    vec2 q = vec2(r.x + r.y, r.x - r.y);
    q.x *= d;
    q *= scale;

    float sectorRandom = dot(random2(11.0 * p + vec2(1.0)), vec2(1.0));
    float angle = floor(sectorRandom * 5.0) * (2.0 * PI / 5.0);
    vec2 cs = vec2(cos(angle), sin(angle));
    return vec2(cs.x * q.x - cs.y * q.y,
                cs.x * q.y + cs.y * q.x);
}

// -----------------------------------------------------------------------------
// Camera ray
// -----------------------------------------------------------------------------

struct SRay
{
    vec3 origin;
    vec3 direction;
    vec3 offset;
    float position;
    float fudge;
    float inverseFocalPlane;
};

vec3 currentPoint(SRay ray)
{
    float t = ray.position;
    vec3 p = ray.origin + ray.direction * t;
    t = 1.0 - t * ray.inverseFocalPlane;

    float d = t - IN_FOCUS_WIDTH *
        (2.0 * smoothstep(-1.5 * IN_FOCUS_WIDTH,
                           1.5 * IN_FOCUS_WIDTH, t) - 1.0);

    return p + ray.offset * d;
}

void advanceRay(inout SRay ray, float distance)
{
    ray.position += distance * ray.fudge;
}

SRay reflectRay(SRay ray, vec3 normal, float epsilon)
{
    vec3 hit = currentPoint(ray);
    ray.direction = reflect(ray.direction, normal);
    ray.offset = reflect(ray.offset, normal);
    ray.origin = hit + reflect(ray.origin - hit, normal);
    ray.position += epsilon;
    return ray;
}

float DE(vec3 p);
float DEFast(vec3 p);
float objectDistance(vec3 p){ return DEFast(p); }
float marchDistance(vec3 p){ return DE(p)*FUDGE_FACTOR; }
float marchDistanceFast(vec3 p){ return DEFast(p)*FUDGE_FACTOR; }

float lightDistance(vec3 p)
{
    return length(LIGHT_POS - p) - LIGHT_SIZE;
}

vec3 surfaceNormal(vec3 p, float normalDistance)
{
    normalDistance = max(normalDistance * 0.5, 1.0e-5);
    vec3 e = vec3(0.0, normalDistance, 0.0);
    vec3 n = vec3(
        DE(p + e.yxx) - DE(p - e.yxx),
        DE(p + e.xyx) - DE(p - e.xyx),
        DE(p + e.xxy) - DE(p - e.xxy)
    );
    n = normalize(n);
    return all(equal(n, n)) ? n : vec3(0.0);
}

// HF_Intensity=0, so the directional exponential-density term vanishes.
vec3 fogTransmission(vec3 p0, vec3 p1)
{
    float distance = length(p1 - p0);
    vec3 opticalDepth = HF_COLOR.rgb * HF_CONST * distance;
    return exp(-opticalDepth);
}

vec3 pointLightGlow(float glow)
{
    float g = max(glow, 0.0);
    float narrowGlow = exp(-1.0e8 * g); // LightGlowRad=0, LightGlowExp=1
    float broadGlow = exp(-20.0 * g);
    return SPOT_LIGHT.rgb * (broadGlow * SPOT_LIGHT.a + narrowGlow);
}

float linearStep(float a, float b, float t)
{
    return clamp((t - a) / (b - a), 0.0, 1.0);
}

// Eiffie shadow, specialized to perf=false and ShadowBlur=0.
float shadowAmount(vec3 origin, vec3 lightPosition, float epsilon)
{
    vec3 direction = lightPosition - origin;
    float lightLength = length(direction);
    direction /= lightLength;

    float coneRadius = epsilon;
    float t = marchDistanceFast(origin) + coneRadius;
    float shadow = 1.0;
    float jitter = DITHER *
        (random2D(origin.xy * (float(FRAME) + 1.0)) - 0.5);

    for (int i = 0; i < MAX_RAY_STEPS; ++i)
    {
        if (t > lightLength || shadow < 0.001)
            break;

        float d = marchDistanceFast(origin + direction * (t + coneRadius * jitter))
                + coneRadius;
        shadow *= linearStep(0.0, 2.0 * coneRadius, d);
        t += abs(0.75 * d + SHADOW_SOFT * coneRadius);
    }

    shadow = max(0.0, shadow - 0.001) / 0.999;
    return clamp(1.0 - shadow, 0.0, 1.0);
}

vec2 nextAORandom()
{
    gAOSeed += vec2(-1.0, 1.0);
    return vec2(
        fract(sin(dot(gAOSeed, vec2(12.9898, 78.233))) * 43758.5453),
        fract(cos(dot(gAOSeed, vec2(4.898, 7.23))) * 23421.631)
    );
}

vec3 orthogonalVector(vec3 v)
{
    return abs(v.x) > abs(v.z)
        ? vec3(-v.y, v.x, 0.0)
        : vec3(0.0, -v.z, v.y);
}

vec3 randomAODirection(vec3 normal)
{
    vec3 axis1 = normalize(orthogonalVector(normal));
    vec3 axis2 = cross(normal, axis1);
    vec2 r = nextAORandom();

    float angle = r.x * 2.0 * PI;
    float radial = sqrt(r.y * CONE_APERTURE_AO);
    float normalPart = sqrt(1.0 - r.y * CONE_APERTURE_AO);

    return cos(angle) * radial * axis1
         + sin(angle) * radial * axis2
         + normalPart * normal;
}

float ambientOcclusion(vec3 p, vec3 normal)
{
    vec3 direction = randomAODirection(normal);
    float baseDistance = objectDistance(p) / AO_EPS;
    float sampleDistance = 1.0 - DITHER * random2D(p.xy);
    float previousVisibility = 1.0;
    float occlusion = 0.0;

    for (int i = 1; i < MAX_ITER_AO; ++i)
    {
        float visibility = objectDistance(p + sampleDistance * direction * baseDistance);
        visibility /= sampleDistance * baseDistance
                    * dot(direction, normal) * FUDGE_AO;
        visibility = min(previousVisibility, visibility);

        occlusion += clamp(1.0 - visibility, 0.0, 1.0);
        previousVisibility = visibility;
        sampleDistance *= 1.61;
    }

    return occlusion / float(MAX_ITER_AO - 1);
}

vec3 applyLighting(
    vec3 normal,
    vec3 materialColor,
    vec3 position,
    vec3 rayDirection,
    float epsilon,
    float ao)
{
    vec3 color = vec3(0.0);
    vec3 lightDirection = normalize(LIGHT_POS - position);

    float nDotL = max(AO_CORRECT, dot(normal, lightDirection));
    vec3 halfVector = normalize(-rayDirection + lightDirection);
    float hDotN = max(0.0, dot(normal, halfVector));

    float f0 = (SPECULAR_EXP - 1.0) / (SPECULAR_EXP + 1.0);
    f0 *= f0;
    float fresnel = f0 + (1.0 - f0)
        * pow(1.0 + dot(normal, rayDirection), 5.0);

    float diffuse = nDotL;
    float specular = ((SPECULAR_EXP + 2.0) / 8.0)
        * fresnel * nDotL
        * pow(hDotN, SPECULAR_EXP + 0.00001) * SPECULAR;

    float shadow = shadowAmount(position + normal * epsilon,
                                LIGHT_POS, epsilon);
    diffuse = mix(diffuse, 0.0, HARD_SHADOW * shadow);
    specular *= 1.0 - shadow;

    vec3 lightFog = fogTransmission(position, LIGHT_POS);
    color += lightFog * SPOT_LIGHT.rgb * SPOT_LIGHT.a
        * (diffuse + specular)
        * (1.0 - clamp(AO_POINTLIGHT * ao, 0.0, 1.0));

    nDotL = max(AO_CORRECT, dot(normal, -rayDirection));
    hDotN = max(0.0, dot(normal, -rayDirection));
    diffuse = nDotL;
    specular = ((SPECULAR_EXP + 2.0) / 8.0)
        * fresnel * nDotL
        * pow(hDotN, SPECULAR_EXP + 0.00001) * SPECULAR;

    color += CAM_LIGHT.rgb * CAM_LIGHT.a
        * (diffuse + specular)
        * (1.0 - clamp(AO_CAMLIGHT * ao, 0.0, 1.0));

    color += AMBIENT_LIGHT.rgb * AMBIENT_LIGHT.a
        * (1.0 - clamp(AO_AMBIENT * ao, 0.0, 1.0));

    return color * materialColor;
}

vec3 orbitColor()
{
    gOrbitTrap.w = sqrt(gOrbitTrap.w);

    vec3 trapped =
        ORBIT_X.rgb * ORBIT_X.a * gOrbitTrap.x +
        ORBIT_Y.rgb * ORBIT_Y.a * gOrbitTrap.y +
        ORBIT_Z.rgb * ORBIT_Z.a * gOrbitTrap.z +
        ORBIT_R.rgb * ORBIT_R.a * gOrbitTrap.w;

    return mix(BASE_COLOR, 3.0 * trapped, ORBIT_STRENGTH);
}

vec3 traceScene(inout SRay ray, out vec3 hitNormal, out float glow)
{
    glow = 1000.0;
    hitNormal = vec3(0.0);
    gOrbitTrap = vec4(10000.0);

    float distance = 0.0;
    float lightDE = 0.0;
    float epsilon = max(MIN_EPS, ray.position * MIN_DIST * FUDGE_FACTOR);
    bool hitSomething = false;
    int steps = 0;

    vec3 p = currentPoint(ray);
    float firstStep = min(marchDistance(p), lightDistance(p));
    firstStep *= (1.0 - DITHER)
               + DITHER * random2D(ray.direction.xy);
    advanceRay(ray, firstStep);

    for (steps = 0; steps < MAX_RAY_STEPS; ++steps)
    {
        p = currentPoint(ray);
        lightDE = lightDistance(p);
        distance = min(lightDE, marchDistance(p));
        glow = min(glow, lightDE);
        advanceRay(ray, distance);

        epsilon = max(MIN_EPS,
                      ray.position * MIN_DIST * FUDGE_FACTOR);

        if (distance < epsilon)
        {
            for (int i = 0; i < REFINE_STEPS; ++i)
            {
                advanceRay(ray, distance - 1.5 * epsilon);
                p = currentPoint(ray);
                lightDE = lightDistance(p);
                distance = min(lightDE, marchDistance(p));
                glow = min(glow, lightDE);
            }
            hitSomething = true;
            break;
        }

        if (ray.position > MAX_DISTANCE)
            break;
    }

    if (steps == MAX_RAY_STEPS)
        gOrbitTrap = vec4(0.0);

    if (!hitSomething)
    {
        ray.position = MAX_DISTANCE;
        return BACKGROUND_COLOR;
    }

    if (distance == lightDE)
    {
        gLightHit = true;
        return SPOT_LIGHT.rgb * SPOT_LIGHT.a / (LIGHT_SIZE + 0.01);
    }

    vec3 hit = currentPoint(ray);
    hitNormal = surfaceNormal(
        hit - NORMAL_BACK_STEP * epsilon * ray.direction,
        epsilon
    );

    // Gamma=1 in the preset, so this is only the original clamp.
    vec3 material = clamp(orbitColor(), 0.0, 1.0);
    float ao = ambientOcclusion(hit, hitNormal);
    return applyLighting(hitNormal, material, hit,
                         ray.direction, epsilon, ao);
}

// -----------------------------------------------------------------------------
// Clouds and volumetric point-light scattering
// -----------------------------------------------------------------------------

float hashToUnit(uint value)
{
    return float(value) / 4294967296.0;
}

float cloudNoise(vec3 p)
{
    vec3 f = smoothstep(0.0, 1.0, fract(p));
    vec3 i = floor(p);
    uvec3 b0 = floatBitsToUint(i);
    uvec3 b1 = floatBitsToUint(i + vec3(1.0));
    uint hx0 = wangHash(b0.x), hx1 = wangHash(b1.x);
    uint hxy00 = wangHash(hx0 + b0.y);
    uint hxy10 = wangHash(hx1 + b0.y);
    uint hxy01 = wangHash(hx0 + b1.y);
    uint hxy11 = wangHash(hx1 + b1.y);
    float n000 = hashToUnit(wangHash(hxy00 + b0.z));
    float n100 = hashToUnit(wangHash(hxy10 + b0.z));
    float n010 = hashToUnit(wangHash(hxy01 + b0.z));
    float n110 = hashToUnit(wangHash(hxy11 + b0.z));
    float n001 = hashToUnit(wangHash(hxy00 + b1.z));
    float n101 = hashToUnit(wangHash(hxy10 + b1.z));
    float n011 = hashToUnit(wangHash(hxy01 + b1.z));
    float n111 = hashToUnit(wangHash(hxy11 + b1.z));
    return mix(mix(mix(n000,n100,f.x),mix(n010,n110,f.x),f.y),
               mix(mix(n001,n101,f.x),mix(n011,n111,f.x),f.y),f.z);
}

float cloudDensityAt(vec3 p, vec3 cloudDirection)
{
    vec3 q = p; // CloudScale=1 and CloudFlatness=0
    float noise = 0.0;
    float amplitude = 0.5;

    for (int i = 0; i < 3; ++i)
    {
        noise += amplitude * cloudNoise(q);
        q *= 2.03;
        amplitude *= 0.5;
    }

    float height = dot(p, cloudDirection);
    float verticalProfile = 1.0 - abs(height);

    return clamp(CLOUD_DENSITY * verticalProfile - noise, 0.0, 1.0);
}

vec4 integrateCloudSample(vec4 sum, float diffuse,
                          float density, float distance)
{
    vec3 lighting = CLOUD_COLOR * 1.3 + SUN_LIGHT_COLOR * diffuse;
    vec4 sampleColor = vec4(
        mix(1.15 * vec3(1.0, 0.95, 0.8), CLOUD_COLOR_2, density),
        density
    );

    sampleColor.rgb *= lighting;
    sampleColor = clamp(sampleColor, 0.0, 1.0);

    // CloudBgMix=1.
    sampleColor.rgb = mix(
        sampleColor.rgb,
        BACKGROUND_COLOR,
        1.0 - exp(-0.0025 * distance * distance)
    );

    sampleColor.a *= mix(
        0.9, 0.0,
        clamp(distance * distance / (MAX_DISTANCE * MAX_DISTANCE),
              0.0, 1.0)
    );
    sampleColor.rgb *= sampleColor.a;

    return sum + sampleColor * (1.0 - sum.a);
}

vec4 renderClouds(vec3 p0, vec3 p1)
{
    vec3 rayDirection = normalize(p1 - p0);
    vec3 cloudDirection = normalize(CLOUD_DIR);
    vec4 sum = vec4(0.0);

    float t = 0.1 * random3D(
        vec3(gl_FragCoord.xyy + float(FRAME) * 30.0)
    );
    float maxT = length(p1 - p0);
    bool goingUp = dot(rayDirection, cloudDirection) > 0.0;

    while (t < maxT)
    {
        vec3 p = p0 + t * rayDirection;
        float height = dot(p, cloudDirection);

        if ((!goingUp && height < CLOUD_BASE)
            || (goingUp && height > CLOUD_TOPS)
            || sum.a > 0.99)
            break;

        float density = cloudDensityAt(p, cloudDirection);
        if (density > 0.01)
        {
            vec3 sunDirection = normalize(LIGHT_POS - p);
            float diffuse = clamp(
                (density - cloudDensityAt(p + 0.3 * sunDirection,
                                          cloudDirection)) / 0.6,
                -1.0, 1.0
            );
            sum = integrateCloudSample(sum, diffuse, density, t);
        }

        t += 0.1 + 0.0198 * t; // Cloudvar1=0.99
    }

    return clamp(sum, 0.0, 1.0);
}

float squaredLength(vec3 p)
{
    return dot(p, p);
}

vec3 volumetricPointLight(vec3 p0, vec3 p1)
{
    float a = squaredLength(p0 - LIGHT_POS);
    float b = dot(p1 - p0, p0 - LIGHT_POS);
    float c = squaredLength(p1 - p0);
    float delta = sqrt(max(a * c - b * b, 1.0e-12));

    float randomValue = random2D(
        gViewCoord + vec2(1.6183 + float(FRAME + gFogStrata))
    );
    gFogStrata++;

    float atanB = atan(b / delta);
    float atanBC = atan((b + c) / delta);
    float pdfNormalization = (atanBC - atanB) / delta;

    float t = (tan(mix(atanB, atanBC, randomValue)) * delta - b)
            / max(c, 1.0e-12);
    t = clamp(t, 0.00001, 1.0);

    vec3 samplePoint = p0 + t * (p1 - p0);
    vec3 eyeTransmission = fogTransmission(p0, samplePoint);
    vec3 lightTransmission = fogTransmission(samplePoint, LIGHT_POS);
    vec3 density = HF_COLOR.rgb * HF_CONST;

    float visibility = 1.0
        - shadowAmount(samplePoint, LIGHT_POS, 0.001);

    float cosTheta = dot(normalize(samplePoint - p0),
                         normalize(LIGHT_POS - samplePoint));
    vec3 denominator = 1.0 + HF_ANISOTROPY * HF_ANISOTROPY
        - 2.0 * HF_ANISOTROPY * cosTheta;
    vec3 anisotropy = (1.0 - HF_ANISOTROPY * HF_ANISOTROPY)
        / sqrt(denominator * denominator * denominator);

    vec3 scattering = eyeTransmission * lightTransmission
        * density * anisotropy * visibility * sqrt(max(c, 0.0));

    return SPOT_LIGHT.rgb * SPOT_LIGHT.a
        * pdfNormalization * scattering * HF_SCATTER;
}

vec3 renderColor(SRay ray)
{
    vec3 color = vec3(0.0);
    vec3 reflectionWeight = vec3(1.0);
    gLightHit = false;
    gFogStrata = 0;

    // ReflectionsNumber=1: primary ray plus one reflected ray.
    for (int bounce = 0; bounce < 2; ++bounce)
    {
        vec3 previousPosition = currentPoint(ray);
        vec3 hitNormal;
        float glow;
        vec3 layer = traceScene(ray, hitNormal, glow);
        vec3 currentPosition = currentPoint(ray);

        vec3 fog = fogTransmission(previousPosition, currentPosition);
        layer = mix(HF_COLOR.rgb * HF_COLOR.a, layer, fog);
        if (bounce == 0)
{
        layer += pointLightGlow(glow);
        layer += volumetricPointLight(previousPosition, currentPosition);

        vec4 clouds = renderClouds(previousPosition, currentPosition);
        layer = layer * (1.0 - clouds.a) + clouds.rgb;
}
        color += layer * reflectionWeight;
        reflectionWeight *= REFLECTION * fog;

        if (all(equal(hitNormal, vec3(0.0)))
            || dot(reflectionWeight, reflectionWeight) < 0.0001
            || gLightHit
            || ray.position >= MAX_DISTANCE)
            break;

        ray = reflectRay(ray, hitNormal, MIN_DIST);
    }

    return max(color, vec3(0.0));
}

// -----------------------------------------------------------------------------
// Kleinian distance estimator
// -----------------------------------------------------------------------------

float squaredNorm(vec3 p)
{
    return dot(p, p);
}

vec2 wrap2(vec2 p, vec2 period, vec2 offset)
{
    p -= offset;
    return p - period * floor(p / period) + offset;
}

void transformA(inout vec3 p, inout float derivative,
                float a, float b)
{
    float inverseRadius = 1.0 / squaredNorm(p);
    p *= -inverseRadius;
    p.x = -b - p.x;
    p.y = a + p.y;
    derivative *= inverseRadius;
}

void transformAWithRadiusSquared(inout vec3 p, inout float derivative,
                                 float radiusSquared, float a, float b)
{
    float inverseRadius = 1.0 / radiusSquared;
    p *= -inverseRadius;
    p.x = -b - p.x;
    p.y = a + p.y;
    derivative *= inverseRadius;
}

float josKleinian(vec3 p)
{
    vec3 previous = p + vec3(1.0);
    vec3 previous2 = p - vec3(1.0);
    float distance = 1.0e10;
    float derivative = 1.0;
    float a = KLEIN_R;
    float b = KLEIN_I;
    float signB = sign(b);

    for (int i = 0; i < BOX_ITERATIONS; ++i)
    {
        p.x += KLEIN_SHEAR * p.y;
        p.xz = wrap2(
            p.xz,
            KLEIN_WRAP_PERIOD,
            KLEIN_WRAP_OFFSET
        );
        p.x -= KLEIN_SHEAR * p.y;

        float centeredX = p.x + KLEIN_HALF_I;
        float separation = SEPARATION_BASE
            + SEPARATION_AMPLITUDE * sign(centeredX)
            * (1.0 - exp(-SEPARATION_DECAY * abs(centeredX)));

        if (p.y >= separation)
            p = vec3(-b, a, 0.0) - p;

        float radiusSquared = dot(p, p);
        gOrbitTrap = min(gOrbitTrap, abs(vec4(p, radiusSquared)));
        transformAWithRadiusSquared(p, derivative, radiusSquared, a, b);

        if (squaredNorm(p - previous2) < 1.0e-12)
            break;

        previous2 = previous;
        previous = p;
    }

    for (int i = 0; i < FINAL_ITERATIONS; ++i)
    {
        float y = min(p.y, a - p.y); // ShowBalls=true
        distance = min(distance,
                       min(y, CLAMP_Y) / max(derivative, CLAMP_DF));
        transformA(p, derivative, a, b);
    }

    float y = min(p.y, a - p.y);
    distance = min(distance,
                   min(y, CLAMP_Y) / max(derivative, CLAMP_DF));
    return distance;
}

float josKleinianFast(vec3 p)
{
    vec3 previous = p + vec3(1.0);
    vec3 previous2 = p - vec3(1.0);
    float distance = 1.0e10;
    float derivative = 1.0;
    float a = KLEIN_R;
    float b = KLEIN_I;
    float signB = sign(b);

    for (int i = 0; i < BOX_ITERATIONS; ++i)
    {
        p.x += KLEIN_SHEAR * p.y;
        p.xz = wrap2(
            p.xz,
            KLEIN_WRAP_PERIOD,
            KLEIN_WRAP_OFFSET
        );
        p.x -= KLEIN_SHEAR * p.y;

        float centeredX = p.x + KLEIN_HALF_I;
        float separation = SEPARATION_BASE
            + SEPARATION_AMPLITUDE * sign(centeredX)
            * (1.0 - exp(-SEPARATION_DECAY * abs(centeredX)));

        if (p.y >= separation)
            p = vec3(-b, a, 0.0) - p;

        transformA(p, derivative, a, b);

        if (squaredNorm(p - previous2) < 1.0e-12)
            break;

        previous2 = previous;
        previous = p;
    }

    for (int i = 0; i < FINAL_ITERATIONS; ++i)
    {
        float y = min(p.y, a - p.y); // ShowBalls=true
        distance = min(distance,
                       min(y, CLAMP_Y) / max(derivative, CLAMP_DF));
        transformA(p, derivative, a, b);
    }

    float y = min(p.y, a - p.y);
    distance = min(distance,
                   min(y, CLAMP_Y) / max(derivative, CLAMP_DF));
    return distance;
}

float DE(vec3 p)
{
    // roty=0, DoAnimation=false and DoInversion=false.
    return josKleinian(p);
}

float DEFast(vec3 p)
{
    return josKleinianFast(p);
}

// -----------------------------------------------------------------------------
// Shadertoy entry point and accumulation
// -----------------------------------------------------------------------------

void setupCamera(vec2 fragCoord)
{
    gViewCoord = 2.0 * fragCoord / iResolution.xy - 1.0;
    gCoord = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
    gCoord *= FOV;
    gPixelScale = 2.0 / iResolution.xy;

    gCameraPos = EYE;
    gCameraDir = normalize(TARGET - EYE);

    vec3 up = normalize(CAMERA_UP); // UpLock=false
    gCameraUp = normalize(up - dot(gCameraDir, up) * gCameraDir);
    gCameraRight = normalize(cross(gCameraDir, gCameraUp));
    gAOSeed = gViewCoord * (float(FRAME) + 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    setupCamera(fragCoord);

    vec2 apertureSample = APERTURE * pentagonalStarAperture(
        gViewCoord * (float(FRAME) + 1.0)
    );

    vec2 disc = uniformDisc(gCoord * float(FRAME + 1));
    vec2 jitteredCoord = gCoord - vec2(0.3, 0.)
        + ANTI_ALIAS_SCALE * gPixelScale.y * FOV * disc;

    vec3 lensOffset = apertureSample.x * gCameraRight
                    + apertureSample.y * gCameraUp;
    vec3 unnormalizedDirection = gCameraDir
        + jitteredCoord.x * gCameraRight
        + jitteredCoord.y * gCameraUp;

    float rayLength = length(unnormalizedDirection);
    float focusCorrection = length(
        unnormalizedDirection
        + lensOffset * (
            1.0 - 1.0 / FOCAL_PLANE
            + clamp(1.0 / FOCAL_PLANE - 1.0,
                    -IN_FOCUS_WIDTH, IN_FOCUS_WIDTH)
        )
    );

    SRay ray = SRay(
        gCameraPos,
        unnormalizedDirection / rayLength,
        lensOffset,
        0.0,
        1.0 / max(1.0, focusCorrection),
        1.0 / FOCAL_PLANE
    );

    vec3 sampleColor = renderColor(ray);

    vec2 uv = fragCoord / iResolution.xy;
    vec4 previous = FRAME == 0 ? vec4(0.0) : texture(iChannel0, uv);

    float weight = exp(-dot(disc, disc) / GAUSSIAN_WEIGHT)
                 - exp(-1.0 / GAUSSIAN_WEIGHT);

    fragColor = previous + vec4(sampleColor * weight, weight);
}
