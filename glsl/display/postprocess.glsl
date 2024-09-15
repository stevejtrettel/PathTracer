
vec3 LessThan(vec3 f, float value)
{
    return vec3(
    (f.x < value) ? 1.0f : 0.0f,
    (f.y < value) ? 1.0f : 0.0f,
    (f.z < value) ? 1.0f : 0.0f);
}


vec3 gammaCorrect(vec3 color){
    return pow(color, vec3(0.4545));
}

vec3 LinearToSRGB(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);

    return mix(
    pow(rgb, vec3(1.0f / 2.4f)) * 1.055f - 0.055f,
    rgb * 12.92f,
    LessThan(rgb, 0.0031308f)
    );
}

vec3 SRGBToLinear(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);

    return mix(
    pow(((rgb + 0.055f) / 1.055f), vec3(2.4f)),
    rgb / 12.92f,
    LessThan(rgb, 0.04045f)
    );
}

// ACES tone mapping curve fit to go from HDR to LDR
//https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
vec3 ACESFilm(vec3 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((x*(a*x + b)) / (x*(c*x + d) + e), 0.0f, 1.0f);
}

vec3 Uncharted2(in vec3 color) {
    color *= 2.0;

    float A = 0.15, B = 0.50, C = 0.10;
    float D = 0.20, E = 0.02, F = 0.30;
    color = (((A * color + C * B) * color + D * E) / ((A * color + B) * color + D * F)) - E / F;

    //float whiteMax = 4.0;
    //color /= (((A * whiteMax + C * B) * whiteMax + D * E) / ((A * whiteMax + B) * whiteMax + D * F)) - E / F;
    color *= 1.9335;

    return color;
}
