


//-------------------------------------------------
//Get Previous Frame
//-------------------------------------------------

    vec4 prevFrame(vec2 fragCoord){
    return texture(acc, fragCoord / iResolution.xy);
}








//-------------------------------------------------
//Do the Accumulation
//-------------------------------------------------



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //get new and old frames
    vec3 new=newFrame(fragCoord);
    fragColor=vec4(new,1.);
//
//    vec4 prev=prevFrame(fragCoord);
//
//    float blend =   (iFrame < 2. || prev.a == 0.0f) ? 1.0f :  1. / (1. + 1./prev.a);
//
//
//    //vec3 color= ((iFrame-1.)*prev.rgb+new)/iFrame;
//    vec3 color=mix(prev.rgb,new,blend);
//
//    // show the result
//    fragColor = vec4(color, blend);
}








  void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
  }
