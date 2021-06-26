
//---------------------------------------------------------------------
//New Frame
//this is the main function of the path tracer
// it takes in a pixel coordinate, traces the scene and returns a color
//-----------------------------------------------------------------------


//get the new frame
vec3 newFrame(vec2 fragCoord, float numRuns){

    // initialize a random number seed
    seed = randomSeed(fragCoord,frameSeed);

    //set up the camera:
    Camera cam=buildCamFromUniforms();

    //get the initial path at camera
    Vector tv=cameraRay(fragCoord,cam);
    Path path=initializePath(tv);

    //build the scene
    buildScene();

    //do one trace out into the scene
    return pathTrace(path);
}







//-------------------------------------------------
//THE MAIN FUNCTION
//-------------------------------------------------

void main() {

    vec3 pixel;
    pixel += newFrame(gl_FragCoord.xy,0.);
    pixel += newFrame(gl_FragCoord.xy,1239845.);
    pixel /= 2.;


    //get rid of black pixels which ruin the accumulation!
//    float len=length(pixel);
//    if(!isnan(len)){

        gl_FragColor=vec4(pixel, 1.);
//    }
//    else{
//        gl_FragColor=vec4(0,0,0, 1.);
//    }

}

