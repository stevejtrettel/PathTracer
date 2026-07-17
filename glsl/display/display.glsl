#include postprocess.glsl

uniform vec3 iResolution;
uniform sampler2D accTex;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    //sample the accumulated image with normalized coordinates:
    //if the accumulation texture is smaller than the screen (preview mode),
    //it stretches to fill (pixelated, since the texture uses NearestFilter)
    vec3 color = texture(accTex, fragCoord / iResolution.xy).rgb;

    // convert unbounded HDR color range to SDR color range
    // (alternate tone map available: Uncharted2, see postprocess.glsl)
    color = ACESFilm(color);

    // convert from linear to sRGB for display
    // (alternate: the exact piecewise LinearToSRGB in postprocess.glsl)
    color = gammaCorrect(color);

    fragColor = vec4(color, 1.0f);

}



void main() {

    mainImage(gl_FragColor, gl_FragCoord.xy);
}


