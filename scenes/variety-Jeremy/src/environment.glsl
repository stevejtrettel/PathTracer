//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// a RoomBox (glsl/objects/environments/roomBox.glsl) plus lights
//-------------------------------------------------

RoomBox room;
Sphere light1,light2,light3;


void buildEnvironment(){

    //----------- THE ROOM -------------------------
    room.low   = -0.75;  room.high  = 14.;   //y of floor / ceiling
    room.left  = -20.;   room.right = 6.5;   //x of left / right wall
    room.front = -12.;   room.back  = 30.;   //z of front / back wall

    vec3 color=vec3(0.02);
    float roughness=0.1;

    room.floorMat = makeDielectric(color,0.0,roughness);
    room.ceilMat  = makeLight(vec3(1,1,1),5.*roomLight);
    room.leftMat  = makeDielectric(color,0.0,roughness);
    room.leftMat.specularChance=0.5;
    room.rightMat = makeDielectric(color,0.0,roughness);
    room.frontMat = makeDielectric(color,0.0,roughness);
    room.backMat  = makeDielectric(color,0.0,roughness);

    //----------- LIGHT 1 -------------------------
    light1.frame=makeFrame(vec3(7,5,10));
    light1.radius=0.75;
    light1.mat=makeLight(vec3(0.5),100.);

    //----------- LIGHT 2 -------------------------
    light2.frame=makeFrame(vec3(-10,3,10));
    light2.radius=2.*roomLight;
    light2.mat=makeLight(vec3(1.),100.);

    //----------- LIGHT 3 -------------------------
    light3.frame=makeFrame(vec3(-3,4,8));
    light3.radius=0.3;
    light3.mat=makeLight(vec3(1.),100.);

}


//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    float dist=maxDist;
    dist = min(dist, trace(tv,light1));
    dist = min(dist, trace(tv,light2));
    dist = min(dist, trace(tv,light3));
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
    setData(path, light1);
    setData(path, light2);
    setData(path, light3);
    setData(path, room);
}
