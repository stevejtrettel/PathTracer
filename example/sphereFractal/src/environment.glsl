//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
//-------------------------------------------------

bool render_Environment=true;


//set the names of the lights:
Sphere light;

//set the names of the walls:
Plane bottomWall, topWall, leftWall, rightWall, backWall, frontWall;



void buildEnvironment(){

    vec3 lightColor;
    float lightIntensity;

    //----------- LIGHT 1 -------------------------
    light.center=vec3(0,8,0);
    light.radius=1.5;
    lightColor= vec3(0.9);
    lightIntensity=50.;
    light.mat=makeLight(lightColor,lightIntensity);

    //------------------------------------
    // THE WALLS
    //------------------------------------

    Vector orientation;
    vec3 color=0.15*vec3(171,203,240)/255.;//sky blue
    float specularity=0.;
    float roughness=0.1;

    //----------- THE FLOOR -------------------------
    orientation.pos=vec3(0,-3,0);
    orientation.dir=vec3(0,1,0);
    bottomWall.orientation=orientation;
    bottomWall.mat=makeDielectric(color,0.0,roughness);

    //----------- THE CEILING -------------------------
    orientation.pos=vec3(0,14,0);
    orientation.dir=vec3(0,-1,0);
    topWall.orientation=orientation;
    topWall.mat=makeLight(vec3(1,1,1),1.*extra4);


    //----------- THE FRONT -------------------------
    orientation.pos=vec3(0,0,-20);
    orientation.dir=vec3(0,0,1);
    frontWall.orientation=orientation;
    frontWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE BACK -------------------------
    orientation.pos=vec3(0,0,10);
    orientation.dir=vec3(0,0,-1);
    backWall.orientation=orientation;
    backWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE LEFT -------------------------
    orientation.pos=vec3(-20,0,0);
    orientation.dir=vec3(1,0,0);
    leftWall.orientation=orientation;
    leftWall.mat=makeDielectric(color,0.0,roughness);



    //----------- THE RIGHT -------------------------
    orientation.pos=vec3(8.5,0,0);
    orientation.dir=vec3(-1,0,0);
    rightWall.orientation=orientation;
    rightWall.mat=makeDielectric(color,0.0,roughness);

}











//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------


float trace_Environment(Vector tv ){

    float dist=maxDist;

    dist = min(dist, trace(tv,light));

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

    setData(path, bottomWall);

    setData(path, topWall);

    setData(path, frontWall);

    setData(path, backWall);

    setData(path, leftWall);

    setData(path, rightWall);

}
