
//---------------------------------------------------------------------
//INCLUDES
//all the other code that runs this shader
//-----------------------------------------------------------------------

#include 1Setup/_setup.glsl
#include 2Space/_space.glsl
#include 3Materials/_materials.glsl
#include 4Objects/_objects.glsl
#include 5Scene/_scene.glsl
#include 6Trace/_trace.glsl


//---------------------------------------------------------------------
//New Frame
//this is the main function of the path tracer
// it takes in a pixel coordinate, traces the scene and returns a color
//-----------------------------------------------------------------------

//decide if a pixel is rendered this round (when using renderblocks)
bool renderPixel(vec2 fragCoord){
    bool render=true;
    if(renderBlocks){
        float corner = mod(frameNumber, 4.);
        if (corner == 1.){
            render = (fragCoord.x<iResolution.x/2.)&&(fragCoord.y<iResolution.y/2.);
        }
        else if (corner == 2.){
            render = (fragCoord.x<iResolution.x/2.)&&(fragCoord.y>iResolution.y/2.);
        }
        else if (corner == 3.){
            render = (fragCoord.x>iResolution.x/2.)&&(fragCoord.y<iResolution.y/2.);
        }
        else {
            render = (fragCoord.x>iResolution.x/2.)&&(fragCoord.y>iResolution.y/2.);
        }
    }
    return render;
}



//get the new frame
vec3 newFrame(vec2 fragCoord ){

    if(renderPixel(fragCoord)){
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
        //if we use renderblocks, need to increase brightness to account for black pixels
        if(renderBlocks){ adjust = 4.;}
        //do the adjustments from this and exposure
        return adjust * exposure * col;
    }

    //if we don't render the pixel; just return black
    return vec3(0);
}







//-------------------------------------------------
//THE MAIN FUNCTION
//-------------------------------------------------

void main() {

    vec3 pixel=vec3(0);
  //  for(int i =0; i<5; i++){
        pixel += newFrame(gl_FragCoord.xy);
    //}
   // pixel /= 5.;
    gl_FragColor=vec4(pixel, 1.);
}

