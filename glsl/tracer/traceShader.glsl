
//---------------------------------------------------------------------
//INCLUDES
//all the other code that runs this shader AFTER defining walls lights and objects
//-----------------------------------------------------------------------

#include 5Scene/scene.glsl
#include 6Trace/_trace.glsl


//---------------------------------------------------------------------
//New Frame
//this is the main function of the path tracer
// it takes in a pixel coordinate, traces the scene and returns a color
//-----------------------------------------------------------------------



//get the new frame
vec3 newFrame(vec2 fragCoord ){

    // initialize the random number seed from pixel and frame
    seed = randomSeed(fragCoord, frameNumber);

    //set up the camera:
    Camera cam=buildCamFromUniforms();


    //get the initial path at camera
    Vector tv=cameraRay(fragCoord, cam);
    Path path=initializePath(tv);

    //build the scene
    buildScene();

    //debug fork: a non-zero mode replaces path tracing with a cheap one-shot debug
    //pass (preview shading / diagnostics). This is the ONLY debug branch in the
    //tracer — per pixel, once, coherent — so with debug off (mode 0) the path-trace
    //and march loops are untouched. See glsl/tracer/6Trace/debugPass.glsl.
    if(uDebugMode != 0){
        return debugPass(uDebugMode, tv);
    }

    //do one trace out into the scene, adjusted by the exposure
    vec3 col = pathTrace(path);
    return exposure * col;

}





//-------------------------------------------------
//THE MAIN FUNCTION
//-------------------------------------------------

void main() {
    vec3 pixel = newFrame(gl_FragCoord.xy);
    gl_FragColor=vec4(pixel, 1.);
}

