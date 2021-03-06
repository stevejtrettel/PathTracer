
//---------------------------------------------------------------------
//New Frame
//this is the main function of the path tracer
// it takes in a pixel coordinate, traces the scene and returns a color
//-----------------------------------------------------------------------


//get the new frame
vec3 newFrame(vec2 fragCoord, float numRuns){

    // initialize a random number seed
    seed = randomSeed(fragCoord,frameSeed+numRuns);

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

    vec3 pixel=vec3(0);
    pixel += newFrame(gl_FragCoord.xy,0.);
//    pixel += newFrame(gl_FragCoord.xy,1239845.);
//    pixel += newFrame(gl_FragCoord.xy,1573655.);
//    pixel += newFrame(gl_FragCoord.xy,1241245.);
//    pixel += newFrame(gl_FragCoord.xy,15738765.);
//    pixel /= 5.;

        gl_FragColor=vec4(pixel, 1.);

}

