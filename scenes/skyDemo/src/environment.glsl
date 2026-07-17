//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
// deliberately NO RoomBox: just a floor, so rays escape to the image sky
// (set in settings.js). This scene is the test of the equirectangular
// sky path — the image provides all the lighting.
//-------------------------------------------------

Plane floor;


void buildEnvironment(){

    floor.frame = makeFrameNormal(vec3(0,-1,0), vec3(0,1,0));
    floor.mat = makeDielectric(vec3(0.4), 0.1, 0.2);

}


//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------

float trace_Environment(Vector tv ){
    return trace(tv, floor);
}

float sdf_Environment(Vector tv ){
    //nothing to raymarch
    return maxDist;
}


//-------------------------------------------------
//Setting the Environment Data
//-------------------------------------------------

void setData_Environment( inout Path path ){
    setData(path, floor);
}
