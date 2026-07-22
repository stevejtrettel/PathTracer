//-------------------------------------------------
// ENVIRONMENT — a dark room with a bright light behind the lens, so we can see
// the graded-index bending: rays refract through the lens toward the light and
// converge. A pale floor catches the focused caustic.
//-------------------------------------------------

RoomBox room;
Sphere light;


void buildEnvironment(){

    room.low   = -2.;    room.high  = 28.;
    room.left  = -30.;   room.right = 30.;
    room.front = -30.;   room.back  = 18.;

    vec3 dark = vec3(0.015);
    float rough = 0.25;

    room.floorMat = makeDielectric(vec3(0.55), 0.0, 0.35);
    room.ceilMat  = makeDielectric(dark, 0.0, rough);
    room.leftMat  = makeDielectric(dark, 0.0, rough);
    room.rightMat = makeDielectric(dark, 0.0, rough);
    room.frontMat = makeDielectric(dark, 0.0, rough);
    room.backMat  = makeDielectric(dark, 0.0, rough);

    //bright backdrop directly behind the lens (from the camera), so the lens is
    //back-lit and its bending is legible.
    light.frame  = makeFrame(vec3(6, 4, -14));
    light.radius = 6.0;
    light.mat    = makeLight(vec3(1.0), lightPower);

}


float trace_Environment(Vector tv ){
    float dist=maxDist;
    dist = min(dist, trace(tv,light));
    dist = min(dist, trace(tv,room));
    return dist;
}

float sdf_Environment(Vector tv ){
    return maxDist;
}

void setData_Environment( inout Path path ){
    setData(path, light);
    setData(path, room);
}
