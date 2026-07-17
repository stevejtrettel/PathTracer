//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
//-------------------------------------------------



//set the names of the lights:
Sphere light1,light2,light3;

//set the names of the walls:
Plane bottomWall, topWall, leftWall, rightWall, backWall, frontWall;



void buildEnvironment(){

    vec3 lightColor;
    float lightIntensity;

    //----------- LIGHT 1 -------------------------
    light1.frame=makeFrame(vec3(7,5,10));
    light1.radius=0.75;
    lightColor= vec3(0.5);
    lightIntensity=100.;
    light1.mat=makeLight(lightColor,lightIntensity);



    //----------- LIGHT 2 -------------------------
    light2.frame=makeFrame(vec3(-10,3,10));
    light2.radius=2.*scratch4;
    lightColor= vec3(1.);
    lightIntensity=100.;
    light2.mat=makeLight(lightColor,lightIntensity);



    //----------- LIGHT 3 -------------------------
    light3.frame=makeFrame(vec3(-3,4,8));
    light3.radius=0.3;
    lightColor= vec3(1.);
    lightIntensity=100.;
    light3.mat=makeLight(lightColor,lightIntensity);



    //------------------------------------
    // THE WALLS
    //------------------------------------
    vec3 color;
    float roughness;
    //-----------GENERAL FOR THE WALLS -------------------------
    color=vec3(0.02);
    roughness=0.1;


    //----------- THE FLOOR -------------------------
        bottomWall.frame=makeFrameNormal(vec3(0,-0.75,0), vec3(0,1,0));
    bottomWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE CEILING -------------------------
        topWall.frame=makeFrameNormal(vec3(0,14,0), vec3(0,-1,0));
    topWall.mat=makeLight(vec3(1,1,1),5.*scratch4);


    //----------- THE FRONT -------------------------
        frontWall.frame=makeFrameNormal(vec3(0,0,-12), vec3(0,0,1));
    frontWall.mat=makeDielectric(color,0.0,roughness);

    //----------- THE BACK -------------------------
        backWall.frame=makeFrameNormal(vec3(0,0,30), vec3(0,0,-1));
    backWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE LEFT -------------------------
        leftWall.frame=makeFrameNormal(vec3(-20,0,0), vec3(1,0,0));
    leftWall.mat=makeDielectric(color,0.0,roughness);
    leftWall.mat.specularChance=0.5;


    //----------- THE RIGHT -------------------------
        rightWall.frame=makeFrameNormal(vec3(6.5,0,0), vec3(-1,0,0));
    rightWall.mat=makeDielectric(color,0.0,roughness);

}











//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------


float trace_Environment(Vector tv ){

    float dist=maxDist;

    dist = min(dist, trace(tv,light1));
    dist = min(dist, trace(tv,light2));
    dist = min(dist, trace(tv,light3));

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

    setData(path, light1);

    setData(path, light2);

    setData(path, light3);



    setData(path, bottomWall);

    setData(path, topWall);

    setData(path, frontWall);

    setData(path, backWall);

    setData(path, leftWall);

    setData(path, rightWall);

}
