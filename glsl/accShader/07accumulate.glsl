
//-------------------------------------------------
// Set the Initial Tangent Vector
//-------------------------------------------------


Vector initializeRay(vec2 fragCoord,inout uint rngState){
    
    // The ray starts at the camera position (a uniform)
    Point rayPosition = Point(location);
    
    // calculate subpixel camera jitter for anti aliasing
    vec2 jitter = vec2(RandomFloat01(rngState), RandomFloat01(rngState)) - 0.5f;
    
     // calculate coordinates of the ray target on the imaginary pixel plane.
    vec2 planeCoords=((fragCoord+jitter)/iResolution.xy) * 2.0f - 1.0f;

    // correct for aspect ratio
    float aspectRatio = iResolution.x / iResolution.y;
    planeCoords.y /= aspectRatio;
    
    //move z-distance for fov:
    float z=-1./ tan(radians(fov * 0.5));
    
    // -1 to +1 on x,y axis. 1 unit away on the z axis
    vec3 rayTarget = vec3(planeCoords, z);
     

    // calculate a normalized vector for the ray direction.
    // it's pointing from the ray position to the ray target.
    vec3 rayDir = normalize(rayTarget);
    
    //combine into tangent vector
    Vector tv=Vector(rayPosition,rayDir);
    
    
    //rotate by facing (a uniform)
    tv=rotateByFacing(tv,facing);
    
    
    return tv;
    
}






//-------------------------------------------------
//New and Old Frames
//-------------------------------------------------





//get the new frame
vec3 newFrame(vec2 fragCoord){
    
     // initialize a random number state based on frag coord and frame number (stored as "seed" instead of iFrame so it doean't get reset when flying)
    uint rngState = randomSeed(fragCoord,iFrame);
    
    //get the initial tangent vector, path data
    Vector tv=initializeRay(fragCoord,rngState);
    Path path=initializePath(tv);
    
    //build the scene
    buildScene();
    
    //do one trace out into the scene
    return pathTrace(path,rngState);
    
}


    //call the previous frame from memory
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
  
    vec4 prev=prevFrame(fragCoord);
    
    float blend =   (iFrame < 2. || prev.a == 0.0f) ? 1.0f :  1. / (1. + 1./prev.a);
    

    //vec3 color= ((iFrame-1.)*prev.rgb+new)/iFrame;
    vec3 color=mix(prev.rgb,new,blend);

    // show the result
    fragColor = vec4(color, blend);
}
























  void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
  }
