#include postprocess.glsl

uniform vec3 iResolution;
uniform float iFrame;
uniform sampler2D accTex;

void mainImage( out vec4 fragColor, in ivec2 pixelCoord )
{

    //directly return the pixel value at fragCoord
    vec3 color = texelFetch(accTex, pixelCoord, 0).rgb;

    ////sample the texture at the given location
    //vec3 color = texture(accTex, fragCoord / iResolution.xy).rgb;

    // convert unbounded HDR color range to SDR color range
    color = ACESFilm(color);
   // color = Uncharted2(color);

    // convert from linear to sRGB for display
    color = LinearToSRGB(color);
    //color = gammaCorrect(color);

    fragColor = vec4(color, 1.0f);
}



void main() {

    mainImage(gl_FragColor, ivec2(gl_FragCoord.xy));
}


