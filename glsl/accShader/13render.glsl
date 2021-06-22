


//-------------------------------------------------
// Set the Initial Tangent Vector
//-------------------------------------------------

//pinhole camera setup
Vector initializeRay(vec2 fragCoord,float FOV, inout uint rngState){
    
    // The ray starts at the camera position (a uniform)
    Point rayPosition = ORIGIN;
    
    // calculate subpixel camera jitter for anti aliasing
    vec2 jitter = vec2(RandomFloat01(rngState), RandomFloat01(rngState)) - 0.5f;
    
     // calculate coordinates of the ray target on the imaginary pixel plane.
    vec2 planeCoords=((fragCoord+jitter)/iResolution.xy) * 2.0f - 1.0f;

    // correct for aspect ratio
    float aspectRatio = iResolution.x / iResolution.y;
    planeCoords.y /= aspectRatio;
    
    //move z-distance for fov:
    float z=-1./ tan(radians(FOV * 0.5));
    
    // -1 to +1 on x,y axis. 1 unit away on the z axis
    vec3 rayTarget = vec3(planeCoords, z);
     

    // calculate a normalized vector for the ray direction.
    // it's pointing from the ray position to the ray target.
    vec3 rayDir = normalize(rayTarget);
    
    //combine into tangent vector
    Vector tv=Vector(rayPosition,rayDir);
    
    
    //rotate by facing (a uniform)
    //not done here because we are going to simulate an aperture first
    //tv=rotateByFacing(tv,cam.facing);
    
    
    return tv;
    
}








//-------------------------------------------------
//Struct Camera
//-------------------------------------------------


struct Camera{
    vec3 pos;
    mat3 facing;
    float fov;
    float aperture;
    float focalLength;
};









//-------------------------------------------------
//Simulate Camera
//-------------------------------------------------


vec2 sampleAperture(Camera cam,inout uint rngState){
    
    float theta=6.28*RandomFloat01(rngState);
    float radius=cam.aperture*sqrt(RandomFloat01(rngState));
    
    vec2 offset=radius*vec2(cos(theta),sin(theta));
    return offset;
}



Vector cameraRay(Vector tv, Camera cam, inout uint rngState){

    //find the focal point for the ray tv:
    vec3 focalPt=tv.pos.coords+cam.focalLength*tv.dir;
    
    //reset the position by jittering inside the aperture
    vec2 offset=sampleAperture(cam,rngState);
    vec3 pos=tv.pos.coords;
    pos.xy+=offset;
    
    //now set the direction based on the focal length:
    vec3 dir=normalize(focalPt-pos); 
    
    //update the tangent vector
    tv=Vector(Point(pos),dir);
    
    
    //rotate position to be in the right spot
    //THIS IS A HACK: BASED ON LENS BEING CENTERED AT ORIGIN
    //to be corect should first translate to origin; do this, then translate back
    tv.pos.coords=facing*tv.pos.coords;
    
    //translate by the right amount
    tv.pos.coords+=cam.pos;
    
    
    //rotate by facing (a uniform)
    tv=rotateByFacing(tv,cam.facing);
    
    return tv;
}










//-------------------------------------------------
//New Frame
//-------------------------------------------------


//get the new frame
vec3 newFrame(vec2 fragCoord ){

    // initialize a random number state based on frag coord and frame number (stored as "seed" instead of iFrame so it doean't get reset when flying)
    uint rngState = randomSeed(fragCoord,seed);

    //now set up the camera:
    //all the entries are uniforms or constants in setup
    Camera cam;
    vec3 camLoc=location+vec3(7.,3.,6.);
    //+vec3(7.,3.,6.);
    cam=Camera(camLoc,facing,fov,aperture,focalLength);

    //get the initial tangent vector, path data
    Vector tv=initializeRay(fragCoord,cam.fov,rngState);

    tv=cameraRay(tv,cam,rngState);

    Path path=initializePath(tv,rngState);

    //build the scene
    buildScene();

    //do one trace out into the scene
    vec3 pixelColor= pathTrace(path,rngState);

    return pixelColor;
}








//-------------------------------------------------
//THE MAIN FUNCTION
//-------------------------------------------------

void main() {
    gl_FragColor=vec4(newFrame(gl_FragCoord.xy),1.);
}
