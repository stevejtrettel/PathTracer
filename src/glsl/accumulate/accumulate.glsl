
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

vec4 newFrame(vec2 fragCoord){
    return texture(newTex, fragCoord / iResolution.xy);
}

vec4 accFrame(vec2 fragCoord){
    return texture(accTex, fragCoord / iResolution.xy);
}






//-------------------------------------------------
//Do the Accumulation
//-------------------------------------------------

void mainImage(out vec4 fragColor, in vec2 fragCoord )
{
    //get new and old frames
    vec4 new = newFrame(fragCoord);
    vec4 prev = accFrame(fragCoord);

    //discard a pixel if it has 'nan' values in the new frame
    new = isnan(length(new)) ? vec4(0,0,0,1) : new;

    //blend them together
    float blend = (frameNumber < 2. || prev.a == 0.0f) ? 1.0f :  1. / (1. + 1./prev.a);
    vec3 color = mix(prev.rgb,new.rgb,blend);

    // output the result
    fragColor = vec4(color, blend);
}








void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}
