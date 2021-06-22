
//---------------------------------------------------------------------
//New Frame
//this is the main function of the path tracer
// it takes in a pixel coordinate, traces the scene and returns a color
//-----------------------------------------------------------------------


//get the new frame
vec3 newFrame(vec2 fragCoord ){

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
    gl_FragColor=vec4(newFrame(gl_FragCoord.xy),1.);
}

