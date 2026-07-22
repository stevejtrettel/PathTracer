//-------------------------------------------------
// ENVIRONMENT — neutral reference room + one key light.
// Deliberately plain: demos are parameter references, and anything in the walls
// shows up in the glossy sweeps.
//-------------------------------------------------

RoomBox room;
Sphere keyLight;


void buildEnvironment(){

    //----------- THE ROOM -------------------------
    room.low   = 0.;     room.high  = 18.;
    room.left  = -18.;   room.right = 18.;
    room.front = -18.;   room.back  = 18.;

    vec3 wall = vec3(0.10);
    float rough = 0.3;

    room.floorMat = makeDielectric(vec3(0.35), 0.0, 0.25);
    room.ceilMat  = makeLight(vec3(1.), roomLight);
    room.leftMat  = makeDielectric(wall, 0.0, rough);
    room.rightMat = makeDielectric(wall, 0.0, rough);
    room.frontMat = makeDielectric(wall, 0.0, rough);
    room.backMat  = makeDielectric(wall, 0.0, rough);

    //----------- THE KEY LIGHT --------------------
    keyLight.frame  = makeFrame(vec3(8, 11, 9));
    keyLight.radius = 1.5;
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
