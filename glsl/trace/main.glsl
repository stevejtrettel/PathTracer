
//---------------------------------------------------------------------
//New Frame
//this is the main function of the path tracer
// it takes in a pixel coordinate, traces the scene and returns a color
//-----------------------------------------------------------------------


//get the new frame
vec3 newFrame(vec2 fragCoord, float numRuns){
    bool render=true;
//    float corner = mod(frameSeed,4.);
//    if(corner == 1.){
//        render = (fragCoord.x<iResolution.x/2.)&&(fragCoord.y<iResolution.y/2.);
//    }
//    else if( corner == 2.){
//        render = (fragCoord.x<iResolution.x/2.)&&(fragCoord.y>iResolution.y/2.);
//    }
//    else if( corner == 3.){
//        render = (fragCoord.x>iResolution.x/2.)&&(fragCoord.y<iResolution.y/2.);
//    }
//    else{
//        render = (fragCoord.x>iResolution.x/2.)&&(fragCoord.y>iResolution.y/2.);
//    }
    if(render){
        // initialize a random number seed
        seed = randomSeed(fragCoord, frameSeed+numRuns);

        //set up the camera:
        Camera cam=buildCamFromUniforms();

        //get the initial path at camera
        Vector tv=cameraRay(fragCoord, cam);
        Path path=initializePath(tv);

        //build the scene
        buildScene();

        //do one trace out into the scene
        return pathTrace(path);
    }

    return vec3(0);
}







//-------------------------------------------------
//THE MAIN FUNCTION
//-------------------------------------------------

void main() {

    vec3 pixel=vec3(0);
    pixel += newFrame(gl_FragCoord.xy,0.);
    pixel += newFrame(gl_FragCoord.xy,1239845.);
    pixel += newFrame(gl_FragCoord.xy,1573655.);
   pixel += newFrame(gl_FragCoord.xy,1241245.);
    pixel += newFrame(gl_FragCoord.xy,15738765.);
    pixel += newFrame(gl_FragCoord.xy,1269845.);
    pixel += newFrame(gl_FragCoord.xy,1973655.);
    pixel += newFrame(gl_FragCoord.xy,2241245.);
    pixel += newFrame(gl_FragCoord.xy,98738765.);
    pixel /= 10.;

        gl_FragColor=vec4(pixel, 1.);

}

