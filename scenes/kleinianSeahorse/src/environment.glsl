//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// a warm RoomBox enclosing the fractal (warm bounce light + real depth) with a
// bright local light inside, brightness driven by the Light Brightness slider.
//-------------------------------------------------

RoomBox room;


void buildEnvironment(){

    //----------- THE WARM ROOM --------------------
    //bounds enclose the camera (z ~ -6.6) and the fractal (origin); tighter walls
    //bounce more warm fill light. Tune to frame.
    room.low   = -6.;    room.high  = 6.;    //y of floor / ceiling
    room.left  = -7.;    room.right = 7.;    //x of left / right wall
    room.front = -9.;    room.back  = 5.;    //z of front / back wall

    vec3  wall      = wallColor;              //wall albedo — live color picker (try blue!)
    float roughness = 0.6;                    //matte, for soft diffuse bounce

    //the CEILING is a big warm area light (slider-driven): even soft fill and much
    //faster to converge than a tiny sphere in an enclosed room. The warm walls
    //bounce it into the fractal's recesses.
    room.ceilMat  = makeLight(vec3(1.0, 0.9, 0.78), lightBrightness);
    room.floorMat = makeDielectric(wall, 0.0, roughness);
    room.leftMat  = makeDielectric(wall, 0.0, roughness);
    room.rightMat = makeDielectric(wall, 0.0, roughness);
    room.frontMat = makeDielectric(wall, 0.0, roughness);
    room.backMat  = makeDielectric(wall, 0.0, roughness);

}


//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    return trace(tv, room);
}

float sdf_Environment(Vector tv ){
    return maxDist;
}


//-------------------------------------------------
//Setting the Environment Data
//-------------------------------------------------

void setData_Environment( inout Path path ){
    setData(path, room);
}
