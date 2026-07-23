//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// a near-black room so the dispersed light is all you see, a pale floor to catch
// the rainbow caustics, and TWO SMALL bright lights. Small is the whole game:
// the spectrum fan is only a few degrees wide, so a source subtending more than
// that (seen from the gem) re-overlaps the colours into white. Radius 0.7 at
// ~12 units is ~3 degrees — comfortably inside the fan.
//-------------------------------------------------

RoomBox room;
Sphere keyLight;
Sphere rimLight;


void buildEnvironment(){

    //----------- THE ROOM (big + dark) -------------------------
    room.low   = 0.;     room.high  = 22.;
    room.left  = -16.;   room.right = 16.;
    room.front = -16.;   room.back  = 16.;

    vec3 dark = vec3(0.012);
    float rough = 0.3;

    room.floorMat = makeGloss(vec3(0.55), 0.0, 0.3);  //pale floor: catches the fire
    room.ceilMat  = makeGloss(dark, 0.0, rough);
    room.leftMat  = makeGloss(dark, 0.0, rough);
    room.rightMat = makeGloss(dark, 0.0, rough);
    room.frontMat = makeGloss(dark, 0.0, rough);
    room.backMat  = makeGloss(dark, 0.0, rough);

    //----------- THE LIGHTS (small + bright) -------------------
    //key: high and behind-left of the gem (from the camera), drives the main fire
    keyLight.frame  = makeFrame(vec3(6, 10, -7));
    keyLight.radius = 0.7;
    keyLight.mat    = makeLight(vec3(1.0), lightPower);

    //rim: lower, opposite side — fills the facets the key misses
    rimLight.frame  = makeFrame(vec3(-8, 6, 4));
    rimLight.radius = 0.5;
    rimLight.mat    = makeLight(vec3(1.0), 0.4*lightPower);

}


//-------------------------------------------------
// Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    float dist=maxDist;
    dist = min(dist, trace(tv,keyLight));
    dist = min(dist, trace(tv,rimLight));
    dist = min(dist, trace(tv,room));
    return dist;
}

float sdf_Environment(Vector tv ){
    return maxDist;
}


//-------------------------------------------------
// Setting the Environment Data
//-------------------------------------------------

void setData_Environment( inout Path path ){
    setData(path, keyLight);
    setData(path, rimLight);
    setData(path, room);
}
