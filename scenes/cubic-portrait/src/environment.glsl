//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// a RoomBox (glsl/objects/environments/roomBox.glsl) plus lights
//-------------------------------------------------

RoomBox room;
Sphere light;
Sphere light2;


void buildEnvironment(){

    //----------- THE ROOM -------------------------
    room.low   = -4.0;   room.high  = 14.;   //y of floor / ceiling
    room.left  = -4.;    room.right = 4.;    //x of left / right wall
    room.front = -20.;   room.back  = 10.;   //z of front / back wall

    vec3 color=0.15*vec3(171,203,240)/255.;//sky blue
    float roughness=0.1;

    room.floorMat = makeGloss(color,0.0,roughness);
    room.ceilMat  = makeGloss(vec3(0.5),0.0,roughness);
    room.leftMat  = makeGloss(color,0.0,roughness);
    room.rightMat = makeGloss(color,0.0,roughness);
    room.frontMat = makeGloss(color,0.0,roughness);
    room.backMat  = makeGloss(color,0.0,roughness);

    //----------- LIGHT 1 (upper left) -------------------------
    light.frame=makeFrame(vec3(-3,10,2));
    light.radius=0.5;
    light.mat=makeLight(vec3(1., 0.95, 0.9),400.);

    //----------- LIGHT 2 (right side) -------------------------
    light2.frame=makeFrame(vec3(3,4,-4));
    light2.radius=0.4;
    light2.mat=makeLight(vec3(1.), 300.);

}


//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    float dist=maxDist;
    dist = min(dist, trace(tv,light));
    dist = min(dist, trace(tv,light2));
    dist = min(dist, trace(tv,room));
    return dist;
}

float sdf_Environment(Vector tv ){
    //nothing to raymarch
    return maxDist;
}


//-------------------------------------------------
//Setting the Environment Data
//-------------------------------------------------

void setData_Environment( inout Path path ){
    setData(path, light);
    setData(path, light2);
    setData(path, room);
}
