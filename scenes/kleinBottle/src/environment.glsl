//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// a RoomBox (glsl/objects/environments/roomBox.glsl) plus lights
//-------------------------------------------------

RoomBox room;
Sphere light;


void buildEnvironment(){

    //----------- THE ROOM -------------------------
    room.low   = -1.;   room.high  = 14.;   //y of floor / ceiling
    room.left  = -20.;   room.right = 8.5;   //x of left / right wall
    room.front = -20.;   room.back  = 10.;   //z of front / back wall

    vec3 color=0.15*vec3(171,203,240)/255.;//sky blue
    float roughness=0.1;

    room.floorMat = makeGloss(color,0.0,roughness);
    room.ceilMat  = makeLight(vec3(1,1,1),1.*roomLight);
    room.leftMat  = makeGloss(color,0.0,roughness);
    room.rightMat = makeGloss(color,0.0,roughness);
    room.frontMat = makeGloss(color,0.0,roughness);
    room.backMat  = makeGloss(color,0.0,roughness);

    //----------- LIGHT 1 -------------------------
    light.frame=makeFrame(vec3(-15,3,0));
    light.radius=1.5;
    light.mat=makeLight(vec3(0.9),100.);

}


//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    float dist=maxDist;
    dist = min(dist, trace(tv,light));
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
    setData(path, room);
}
