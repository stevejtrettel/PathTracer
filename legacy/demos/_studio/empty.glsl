//-------------------------------------------------
// STUDIO · EMPTY — a bare room whose CEILING is the light. No key-light
// sphere, nothing else in the box: the only thing to look at is the object.
//
// This is the rig for the objects/ pages. A single broad overhead emitter is
// the softbox look — it lights a shape evenly, keeps the silhouette readable,
// and gives glass a large clean source to refract, instead of the hard pinpoint
// highlight a key-light sphere would stamp on it.
//
// Shared rig — do NOT import this from another demo's folder; every demo
// imports it from here (demos/README.md). Requires ONE scene param:
//   roomLight   — ceiling brightness
// Companions: neutral.glsl / accent.glsl (both add a key light, for materials/).
//-------------------------------------------------

RoomBox room;


void buildEnvironment(){

    //a tighter box than the materials studios: with one object in frame, near
    //walls give the glass something structured to bend
    room.low   = 0.;     room.high  = 12.;
    room.left  = -10.;   room.right = 10.;
    room.front = -10.;   room.back  = 10.;

    vec3 wall = vec3(0.25);

    room.floorMat = makeMatte(vec3(0.4));
    room.ceilMat  = makeLight(vec3(1.), roomLight);
    room.leftMat  = makeMatte(wall);
    room.rightMat = makeMatte(wall);
    room.frontMat = makeMatte(wall);
    room.backMat  = makeMatte(wall);

}


//-------------------------------------------------
// Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    return trace(tv, room);
}

float sdf_Environment(Vector tv ){
    return maxDist;
}


//-------------------------------------------------
// Setting the Environment Data
//-------------------------------------------------

void setData_Environment( inout Path path ){
    setData(path, room);
}
