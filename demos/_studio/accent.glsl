//-------------------------------------------------
// STUDIO · ACCENT — the field-chart room: same rig as neutral.glsl, but
// brighter, with warm/cool side walls (the metals-demo trick) so glossy and
// metallic spheres have something COLORED to reflect. Use it wherever the
// point of the page is how a material looks; use neutral.glsl wherever the
// point is a measured parameter sweep.
//
// Shared rig — do NOT import this from another demo's folder; every demo
// imports it from here (demos/README.md). Requires two scene params:
//   lightPower  — key light brightness
//   roomLight   — ceiling fill
//-------------------------------------------------

RoomBox room;
Sphere keyLight;


void buildEnvironment(){

    //----------- THE ROOM -------------------------
    room.low   = 0.;     room.high  = 18.;
    room.left  = -18.;   room.right = 18.;
    room.front = -18.;   room.back  = 18.;

    room.floorMat = makeMatte(vec3(0.42));
    room.ceilMat  = makeLight(vec3(1.), roomLight);
    room.leftMat  = makeMatte(vec3(0.45, 0.22, 0.10));   //warm
    room.rightMat = makeMatte(vec3(0.10, 0.22, 0.40));   //cool
    room.frontMat = makeMatte(vec3(0.16));
    room.backMat  = makeMatte(vec3(0.16));

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
