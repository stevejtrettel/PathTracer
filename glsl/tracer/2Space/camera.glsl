

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
Vector initializeRay(vec2 fragCoord, float FOV){

    // the ray starts at the origin; cameraRay() below moves it into world position
    vec3 rayPosition = ORIGIN;

    // calculate subpixel camera jitter for anti aliasing
    vec2 jitter = vec2(randomFloat(), randomFloat()) - 0.5f;

    // calculate coordinates of the ray target on the imaginary pixel plane.
    vec2 planeCoords=((fragCoord+jitter)/iResolution.xy) * 2.0f - 1.0f;

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
       float resize = sqrt(nPanels);
       float panelFraction = panelToRender/resize;

       //get the panel we are on
       float panelRow = floor(panelFraction);
       float panelColumn = floor(fract(panelFraction)*resize);
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

    //rotate position to be in the right spot
    //THIS IS A HACK: based on the lens being centered at the origin.
    //to be correct, should first translate to the origin, rotate, then translate back
    tv.pos=facing*tv.pos;

    //translate by the right amount
    tv.pos+=cam.pos+CAMERA_OFFSET;

    //rotate by facing (a uniform)
    tv=rotateByFacing(tv,cam.facing);

    return tv;
}

