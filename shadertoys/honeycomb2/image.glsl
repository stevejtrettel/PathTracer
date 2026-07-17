/*

Adapted from Fragmentarium code:

    https://github.com/neozhaoliang/Hyperbolic-Honeycombs

The honeycomb data are precomputed for performance optimization. 
See the GitHub repository for details on how the data are defined
and generated.

You can see a circle-packing pattern in the plane, 
where each circle contains a (8,3) hyperbolic tiling.

*/
const float GAMMA_VALUE = 2.2;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec4 accumulated = texture(iChannel0, uv);

    if (accumulated.a <= 1.0e-8)
    {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // Resolve the weighted accumulation buffer.
    vec3 color = max(accumulated.rgb / accumulated.a, vec3(0.0));

    // Preset: ToneMapping = 4, Exposure = 1.
    color = color / (1.0 + color);

    // Brightness = Contrast = Saturation = 1, so that stage is an identity.
    color = clamp(color, 0.0, 1.0);
    color = pow(color, vec3(1.0 / GAMMA_VALUE));

    fragColor = vec4(color, 1.0);
}
