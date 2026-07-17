const float BLOOM_INTENSITY = 0.7330961;
const float BLOOM_POWER = 5.22093;


vec3 sigmoid3(vec3 value)
{
    const float k = 0.07585818002124345;
    const float denominator = 0.8482836399575131;
    vec3 mapped = 1.0 / (1.0 + exp(-(value - 0.5) * 5.0)) - k;
    return mapped / denominator;
}


vec4 bloomVertical(vec2 uv)
{
    vec2 halfTexel = 0.5 / iResolution.xy;
    float stepY = BLOOM_STRONG / iResolution.y;
    vec4 sum = vec4(0.0);

    for (int y = -BLOOM_TAPS; y <= BLOOM_TAPS; ++y)
    {
        float ny = float(y) / float(BLOOM_TAPS);
        float wy = 1.0 - ny * ny;
        wy *= wy;

        vec2 sampleUV = vec2(
            clamp(uv.x, halfTexel.x, 1.0 - halfTexel.x),
            clamp(uv.y + float(y) * stepY,
                  halfTexel.y, 1.0 - halfTexel.y)
        );
        sum += texture(iChannel1, sampleUV) * wy;
    }

    return sum;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    vec4 accumulated = texture(iChannel0, uv);
    vec3 color = accumulated.rgb / max(accumulated.a, 1.0e-8);

    vec4 bloom = bloomVertical(uv);
    vec3 bloomColor = bloom.rgb / max(bloom.a, 1.0e-8);
    color += BLOOM_INTENSITY
        * pow(max(bloomColor, vec3(0.0)), vec3(BLOOM_POWER));

    color = sigmoid3(color);
    fragColor = vec4(max(color, vec3(0.0)), 1.0);
}
