//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// metals ARE their reflections, so the room gives them something to mirror:
// a warm left wall, a cool right wall, a bright ceiling, and a key light.
// The F0 tints read in the polished row's reflections of the two walls.
//-------------------------------------------------

RoomBox room;
Sphere keyLight;


void buildEnvironment(){

    //----------- THE ROOM -------------------------
    room.low   = 0.;     room.high  = 18.;
    room.left  = -20.;   room.right = 20.;
    room.front = -20.;   room.back  = 20.;

    room.floorMat = makeDielectric(vec3(0.30), 0.0, 0.25);
    room.ceilMat  = makeLight(vec3(1.), roomLight);
    room.leftMat  = makeDielectric(vec3(0.45, 0.22, 0.10), 0.0, 0.3);  //warm
    room.rightMat = makeDielectric(vec3(0.10, 0.22, 0.40), 0.0, 0.3);  //cool
    room.frontMat = makeDielectric(vec3(0.12), 0.0, 0.3);
    room.backMat  = makeDielectric(vec3(0.12), 0.0, 0.3);

    //----------- THE KEY LIGHT --------------------
    keyLight.frame  = makeFrame(vec3(7, 12, 8));
    keyLight.radius = 1.8;
    keyLight.mat    = makeLight(vec3(1.0), lightPower);

}


//-------------------------------------------------
// Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    float dist=maxDist;
    dist = min(dist, trace(tv,keyLight));
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
    setData(path, room);
}
