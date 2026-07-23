//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// a RoomBox (glsl/objects/environments/roomBox.glsl) plus lights
//-------------------------------------------------

RoomBox room;
Sphere light;
Sphere light2;


void buildEnvironment(){

    //----------- THE ROOM -------------------------
    room.low   = -3.0;   room.high  = 14.;   //y of floor / ceiling
    room.left  = -20.;   room.right = 20.;   //x of left / right wall
    room.front = -20.;   room.back  = 10.;   //z of front / back wall

    vec3 color=vec3(0.12, 0.12, 0.14);
    float roughness=0.1;
    vec3 bounce = vec3(0.85);

    room.floorMat = makeGloss(color,0.0,roughness);
    room.ceilMat  = makeLight(vec3(1),1.0);
    room.leftMat  = makeGloss(color,0.0,roughness);
    room.rightMat = makeGloss(color,0.0,roughness);
    room.frontMat = makeGloss(bounce,0.0,roughness);   //front wall (behind camera)
    room.backMat  = makeGloss(color,0.0,roughness);

    //----------- LIGHT 1 -------------------------
    light.frame=makeFrame(vec3(-6,10,-3));
    light.radius=0.5;
    light.mat=makeLight(vec3(1., 0.92, 0.82),400.);

    //----------- LIGHT 2 (right side) -------------------------
    light2.frame=makeFrame(vec3(10,6,-12));
    light2.radius=0.4;
    light2.mat=makeLight(vec3(1., 0.92, 0.82), 300.);

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
