
//---------------------------------------------------------------------
//INCLUDES
//all the other code that runs this shader
//-----------------------------------------------------------------------

#include 1Setup/_setup.glsl
#include 2Space/_space.glsl
#include 3Materials/_materials.glsl
#include 4Objects/_objects.glsl
#include 5Scene/scene.glsl
#include 6Trace/_trace.glsl


//---------------------------------------------------------------------
//New Frame
//this is the main function of the path tracer
// it takes in a pixel coordinate, traces the scene and returns a color
//-----------------------------------------------------------------------



//get the new frame
vec3 newFrame(vec2 fragCoord ){

        // initialize a random number seed
        float rand = floor(1000.*randomFloat());
        seed = randomSeed(fragCoord, frameNumber+rand);

        //set up the camera:
        Camera cam=buildCamFromUniforms();


        //get the initial path at camera
        Vector tv=cameraRay(fragCoord, cam);
        Path path=initializePath(tv);

        //build the scene
        buildScene();

        //do one trace out into the scene
        vec3 col = pathTrace(path);
        float adjust = 1.;
        //do the adjustments from this and exposure
        return adjust * exposure * col;

}







//-------------------------------------------------
//THE MAIN FUNCTION
//-------------------------------------------------

void main() {
    int iter=10;
    vec3 pixel=vec3(0);
   // for(int i =0; i<iter; i++){
        pixel += newFrame(gl_FragCoord.xy);
   // }
   // pixel /= float(iter);
    gl_FragColor=vec4(pixel, 1.);
}

