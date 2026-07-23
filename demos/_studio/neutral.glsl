//-------------------------------------------------
// STUDIO · NEUTRAL — the reference room: grey box, bright ceiling, one key
// light. Deliberately plain, because these pages are parameter references and
// anything colored in the walls shows up in the glossy sweeps.
//
// Shared rig — do NOT import this from another demo's folder; every demo
// imports it from here (demos/README.md). Requires two scene params:
//   lightPower  — key light brightness
//   roomLight   — ceiling fill
// Companion: accent.glsl (same rig, warm/cool side walls).
//-------------------------------------------------

RoomBox room;
Sphere keyLight;


void buildEnvironment(){

    //----------- THE ROOM -------------------------
    room.low   = 0.;     room.high  = 18.;
    room.left  = -18.;   room.right = 18.;
    room.front = -18.;   room.back  = 18.;

    vec3 wall = vec3(0.10);

    room.floorMat = makeMatte(vec3(0.35));
    room.ceilMat  = makeLight(vec3(1.), roomLight);
    room.leftMat  = makeMatte(wall);
    room.rightMat = makeMatte(wall);
    room.frontMat = makeMatte(wall);
    room.backMat  = makeMatte(wall);

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
