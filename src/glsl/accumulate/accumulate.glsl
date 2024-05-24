
//-------------------------------------------------
//Uniforms
//-------------------------------------------------

uniform float frameNumber;
uniform vec3 iResolution;
uniform sampler2D newTex;
uniform sampler2D accTex;

//-------------------------------------------------
//Read in the Data
//-------------------------------------------------

vec4 newFrame(ivec2 pixelCoord){
    return texelFetch(newTex, pixelCoord,0);
    //return texture(newTex, fragCoord / iResolution.xy);
}

vec4 accFrame(ivec2 pixelCoord){
    return texelFetch(accTex, pixelCoord, 0);
    //return texture(accTex, fragCoord / iResolution.xy);
}




//-------------------------------------------------
//Do the Accumulation
//-------------------------------------------------

void mainImage(out vec4 fragColor, in ivec2 pixelCoord )
{
    //get new and old frames
    vec4 new = newFrame(pixelCoord);
    vec4 prev = accFrame(pixelCoord);

    //discard a pixel if it has 'nan' values in the new frame
    new = isnan(length(new)) ? vec4(0,0,0,1) : new;

    //blend them together
    float blend = (frameNumber < 2. || prev.a == 0.0f) ? 1.0f :  1. / (1. + 1./prev.a);
    vec3 color = mix(prev.rgb,new.rgb,blend);

    // output the result
    fragColor = vec4(color, blend);
}






void main() {
    mainImage(gl_FragColor, ivec2(gl_FragCoord.xy));
}
