

//-------------------------------------------------
//Struct Camera
//-------------------------------------------------

//LEGACY GLOBAL CAMERA OFFSET
//every ray origin is shifted by this before applying location/facing.
//all saved settings.js camera positions were authored with this baked in,
//so removing it would re-frame every existing scene.
const vec3 CAMERA_OFFSET = vec3(-2., 0., 6.);


struct Camera{
    vec3 pos;
    mat3 facing;
    float fov;
    float aperture;
    float focalLength;
    bool renderPanel;
    float numPanels;
    float panelToRender;
};

Camera buildCamFromUniforms(){
    Camera cam;
    cam.pos=location;
    cam.facing=facing;
    cam.fov=fov;
    cam.aperture=aperture;
    cam.focalLength=focalLength;
    cam.renderPanel = renderPanel;
    cam.numPanels = numPanels;
    cam.panelToRender = panelToRender;
    return cam;
}





//-------------------------------------------------
// INTERNAL TO THIS FILE
//-------------------------------------------------

//pinhole camera setup
//fragCoord already carries the subpixel jitter (added in cameraRay, before any
//panel rescaling, so it stays one OUTPUT pixel wide)
Vector initializeRay(vec2 fragCoord, float FOV){

    // the ray starts at the origin; cameraRay() below moves it into world position
    vec3 rayPosition = ORIGIN;

    // calculate coordinates of the ray target on the imaginary pixel plane.
    vec2 planeCoords=(fragCoord/iResolution.xy) * 2.0f - 1.0f;

    // correct for aspect ratio
    float aspectRatio = iResolution.x / iResolution.y;
    planeCoords.y /= aspectRatio;

    //move z-distance for fov:
    float z=-1./ tan(radians(FOV * 0.5));

    // -1 to +1 on the x,y axis, at the fov-determined distance z
    vec3 rayTarget = vec3(planeCoords, z);


    // calculate a normalized vector for the ray direction.
    // it's pointing from the ray position to the ray target.
    vec3 rayDir = normalize(rayTarget);

    //combine into tangent vector
    Vector tv=Vector(rayPosition,rayDir);

    return tv;

}




vec2 sampleAperture(Camera cam){

    float theta=2.*PI*randomFloat();
    float radius=cam.aperture*sqrt(randomFloat());

    vec2 offset=radius*vec2(cos(theta),sin(theta));
    return offset;
}





//for working with panels
vec2 panelFragCoord(vec2 fragCoord, float nPanels, float panelToRender){

    //if we have a valid panel to render chosen:
   if(panelToRender<nPanels){
       //the panels form a resize x resize grid. Integer-safe: sqrt and
       //floor(fract(i/r)*r) can land a hair below an integer on some GPUs
       //(e.g. panel 5 of 9 -> 1.9999999 -> column 1), rendering one tile twice
       //and never rendering another. Must agree with PathTracer.newFrame's
       //row = floor(pr/root), col = pr % root.
       float resize = floor(sqrt(nPanels)+0.5);

       //get the panel we are on
       float panelRow = floor((panelToRender+0.5)/resize);
       float panelColumn = panelToRender - resize*panelRow;
       vec2 chosenPanel=vec2(panelRow, panelColumn);

       //move the fragcoord appropriately so its focused just on this panel
       vec2 newFragCoord = fragCoord/resize;
       vec2 offset = chosenPanel * iResolution.xy/resize;
       newFragCoord += offset;
       return newFragCoord;
   }

    //otherwise do nothing
    return fragCoord;
}



//-------------------------------------------------
// USED OUTSIDE THIS FILE
//  this sets up the initial ray in main.glsl
//-------------------------------------------------

Vector cameraRay(vec2 fragCoord, Camera cam){

    //subpixel camera jitter for anti aliasing. Added BEFORE the panel rescaling:
    //panelFragCoord divides by sqrt(numPanels), so jitter added after it would
    //spread each HD-tile pixel over sqrt(numPanels) output pixels (a box blur).
    //Same random draws in the same order as before, so non-panel renders are
    //unchanged.
    fragCoord += vec2(randomFloat(), randomFloat()) - 0.5f;

    //if we are rendering by panels, set the correct panel
    if(cam.renderPanel){
        fragCoord = panelFragCoord(fragCoord, cam.numPanels, cam.panelToRender);
    }

    //set up pinhole camera at origin
    Vector tv=initializeRay(fragCoord,cam.fov);

    //find the focal point for the ray tv:
    vec3 focalPt=tv.pos+cam.focalLength*tv.dir;

    //reset the position by jittering inside the aperture
    vec2 offset=sampleAperture(cam);
    vec3 pos=tv.pos;
    pos.xy+=offset;

    //now set the direction based on the focal length:
    vec3 dir=normalize(focalPt-pos);

    //update the tangent vector
    tv=Vector(pos,dir);

    //carry the local ray (lens at the origin) into the world: rigid transform
    //p_world = facing * p_local + camPos, dir_world = facing * dir_local. Rotating
    //the aperture-jittered position about the origin is exact BECAUSE the lens
    //center IS the local origin, so no translate-rotate-translate pivot is needed.
    tv.pos = cam.facing * tv.pos;

    //translate by the right amount (CAMERA_OFFSET is the legacy world offset baked
    //into every saved pose — see the note at the top of this file)
    tv.pos += cam.pos + CAMERA_OFFSET;

    //rotate the direction to match
    tv = rotateByFacing(tv, cam.facing);

    return tv;
}

