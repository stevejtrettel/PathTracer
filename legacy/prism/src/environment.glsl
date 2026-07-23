//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// a dark room so the dispersed light pops, a pale floor to catch the caustic,
// and a small very bright light placed BEHIND the prism (from the camera) so
// rays refract through the glass toward it and separate into colours.
//-------------------------------------------------

RoomBox room;
Sphere light;


void buildEnvironment(){

    //----------- THE ROOM (big + dark) -------------------------
    room.low   = -2.;    room.high  = 26.;
    room.left  = -30.;   room.right = 30.;
    room.front = -30.;   room.back  = 16.;

    vec3 dark = vec3(0.015);
    float rough = 0.25;

    room.floorMat = makeGloss(vec3(0.55), 0.0, 0.35);  //pale floor: catches the rainbow caustic
    room.ceilMat  = makeGloss(dark, 0.0, rough);
    room.leftMat  = makeGloss(dark, 0.0, rough);
    room.rightMat = makeGloss(dark, 0.0, rough);
    room.frontMat = makeGloss(dark, 0.0, rough);
    room.backMat  = makeGloss(dark, 0.0, rough);

    //----------- THE LIGHT (SMALL, bright, behind the prism) ----
    //the source's angular size (seen from the prism) must be smaller than the
    //dispersion fan (~14 degrees at dispersion 0.15) or the colours re-overlap
    //into white. Radius 1.5 at ~15 units is ~11 degrees — bands resolve; the old
    //radius-6 source subtended ~44 degrees and washed the spectrum out.
    light.frame  = makeFrame(vec3(9, 4, -12));
    light.radius = 1.5;
    light.mat    = makeLight(vec3(1.0), lightPower);

}


//-------------------------------------------------
// Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    float dist=maxDist;
    dist = min(dist, trace(tv,light));
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
    setData(path, light);
    setData(path, room);
}
