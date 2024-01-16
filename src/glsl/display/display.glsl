#include postprocess.glsl

uniform vec3 iResolution;
uniform float iFrame;
uniform sampler2D accTex;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec3 color = texture(accTex, fragCoord / iResolution.xy).rgb;

    // convert unbounded HDR color range to SDR color range
    color = ACESFilm(color);

    // convert from linear to sRGB for display
    color = LinearToSRGB(color);

    fragColor = vec4(color, 1.0f);
}



void main() {

    mainImage(gl_FragColor, gl_FragCoord.xy);
}


