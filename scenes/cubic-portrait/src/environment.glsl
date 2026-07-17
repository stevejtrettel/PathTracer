//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
//-------------------------------------------------



//set the names of the lights:
Sphere light;
Sphere light2;

//set the names of the walls:
Plane bottomWall, topWall, leftWall, rightWall, backWall, frontWall;



void buildEnvironment(){

    vec3 lightColor;
    float lightIntensity;

    //----------- LIGHT 1 (upper left) -------------------------
    light.frame=makeFrame(vec3(-3,10,2));
    light.radius=0.5;

    lightColor= vec3(1., 0.95, 0.9);
    lightIntensity=400.;
    light.mat=makeLight(lightColor,lightIntensity);

    //----------- LIGHT 2 (right side) -------------------------
    light2.frame=makeFrame(vec3(3,4,-4));
    light2.radius=0.4;
    light2.mat=makeLight(vec3(1.), 300.);

    //------------------------------------
    // THE WALLS
    //------------------------------------

    vec3 color=0.15*vec3(171,203,240)/255.;//sky blue
    float roughness=0.1;

    //----------- THE FLOOR -------------------------
    bottomWall.frame=makeFrameNormal(vec3(0,-4.0,0), vec3(0,1,0));
    bottomWall.mat=makeDielectric(color,0.0,roughness);

    //----------- THE CEILING -------------------------
    topWall.frame=makeFrameNormal(vec3(0,14,0), vec3(0,-1,0));
    topWall.mat=makeDielectric(vec3(0.5),0.0,roughness);


    //----------- THE FRONT -------------------------
    frontWall.frame=makeFrameNormal(vec3(0,0,-20), vec3(0,0,1));
    frontWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE BACK -------------------------
    backWall.frame=makeFrameNormal(vec3(0,0,10), vec3(0,0,-1));
    backWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE LEFT -------------------------
    leftWall.frame=makeFrameNormal(vec3(-4,0,0), vec3(1,0,0));
    leftWall.mat=makeDielectric(color,0.0,roughness);



    //----------- THE RIGHT -------------------------
    rightWall.frame=makeFrameNormal(vec3(4,0,0), vec3(-1,0,0));
    rightWall.mat=makeDielectric(color,0.0,roughness);

}




//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------


float trace_Environment(Vector tv ){

    float dist=maxDist;

    dist = min(dist, trace(tv,light));
    dist = min(dist, trace(tv,light2));

    dist=min(dist, trace(tv, bottomWall));
    dist=min(dist, trace(tv, topWall));
    dist=min(dist, trace(tv, frontWall));
    dist=min(dist, trace(tv, backWall));
    dist=min(dist, trace(tv, leftWall));
    dist=min(dist, trace(tv, rightWall));

    return dist;

}

float sdf_Environment(Vector tv ){

    float dist=maxDist;

    //nothing to raymarch!

    return dist;

}




//-------------------------------------------------
//Setting the Walls Data
//-------------------------------------------------



void setData_Environment( inout Path path ){

    setData(path, light);
    setData(path, light2);

    setData(path, bottomWall);

    setData(path, topWall);

    setData(path, frontWall);

    setData(path, backWall);

    setData(path, leftWall);

    setData(path, rightWall);

}
