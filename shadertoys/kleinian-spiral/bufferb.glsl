

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 halfTexel = 0.5 / iResolution.xy;
    float stepX = BLOOM_STRONG / iResolution.x;
    vec4 sum = vec4(0.0);

    for (int x = -BLOOM_TAPS; x <= BLOOM_TAPS; ++x)
    {
        float nx = float(x) / float(BLOOM_TAPS);
        float wx = 1.0 - nx * nx;
        wx *= wx;

        vec2 sampleUV = vec2(
            clamp(uv.x + float(x) * stepX,
                  halfTexel.x, 1.0 - halfTexel.x),
            clamp(uv.y, halfTexel.y, 1.0 - halfTexel.y)
        );
        sum += texture(iChannel0, sampleUV) * wx;
    }

    fragColor = sum;
}
