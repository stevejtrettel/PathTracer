vec3 contrastSaturationBrightness(vec3 color,
                                  float brightness,
                                  float saturation,
                                  float contrast) {
    const vec3 lumCoeff = vec3(0.2125, 0.7154, 0.0721);
    vec3 avgLumin = vec3(0.5);
    vec3 brightColor = color * brightness;
    float intensity = dot(brightColor, lumCoeff);
    vec3 satColor = mix(vec3(intensity), brightColor, saturation);
    vec3 conColor = mix(avgLumin, satColor, contrast);
    return clamp(conColor, 0.0, 1.0);
}


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 tex = texelFetch(iChannel0, ivec2(fragCoord), 0);
    vec3 c = tex.rgb / max(tex.a, 1.0e-12);
    c = c / (1.0 + c);
    c = contrastSaturationBrightness(c, 1.0, 1.0, 1.0);
    c = pow(c, vec3(1.0 / 2.2));
    fragColor = vec4(c, 1.0);
}
