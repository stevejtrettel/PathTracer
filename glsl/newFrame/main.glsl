
//---------------------------------------------------------------------
//New Frame
//this is the main function of the path tracer
// it takes in a pixel coordinate, traces the scene and returns a color
//-----------------------------------------------------------------------


//get the new frame
vec3 newFrame(vec2 fragCoord ){

    // initialize a random number state based on frag coord and frame number
    seed = randomSeed(fragCoord,frameSeed);

    //now set up the camera:
    //all the entries are uniforms or constants in setup
    Camera cam;
    vec3 camLoc=location+vec3(7.,3.,6.);
    cam=Camera(camLoc,facing,fov,aperture,focalLength);

    //get the initial tangent vector, path data
    Vector tv=initializeRay(fragCoord,cam.fov);

    tv=cameraRay(tv,cam);

    Path path=initializePath(tv);

    //build the scene
    buildScene();

    //do one trace out into the scene
    vec3 pixelColor= pathTrace(path);

    return pixelColor;
}







//-------------------------------------------------
//THE MAIN FUNCTION
//-------------------------------------------------

void main() {
    gl_FragColor=vec4(newFrame(gl_FragCoord.xy),1.);
}

