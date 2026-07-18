//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// a RoomBox (floor at y=0) plus a key light
//-------------------------------------------------

RoomBox room;
Sphere  light;


void buildEnvironment(){

    room.low   =  0.;   room.high  = 14.;
    room.left  = -14.;  room.right = 14.;
    room.front = -14.;  room.back  =  8.;

    float rough = 0.3;
    room.floorMat = makeDielectric(vec3(0.45),        0.0, rough);
    room.ceilMat  = makeLight(vec3(1.0), roomLight);
    room.leftMat  = makeDielectric(vec3(0.55,0.32,0.32), 0.0, rough);
    room.rightMat = makeDielectric(vec3(0.32,0.35,0.55), 0.0, rough);
    room.frontMat = makeDielectric(vec3(0.4),         0.0, rough);
    room.backMat  = makeDielectric(vec3(0.4),         0.0, rough);

    light.frame  = makeFrame(vec3(-4, 10, 4));
    light.radius = 1.5;
    light.mat    = makeLight(vec3(1.0, 0.95, 0.9), 45.);

}


//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    float dist = maxDist;
    dist = min(dist, trace(tv, light));
    dist = min(dist, trace(tv, room));
    return dist;
}

float sdf_Environment(Vector tv ){
    return maxDist;
}


//-------------------------------------------------
//Setting the Environment Data
//-------------------------------------------------

void setData_Environment( inout Path path ){
    setData(path, light);
    setData(path, room);
}
